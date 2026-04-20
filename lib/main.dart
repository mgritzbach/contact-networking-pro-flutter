import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:image_picker/image_picker.dart';
import 'card_scanner.dart';
import 'models.dart';
import 'screens/editor_screen.dart';
import 'screens/home_screen.dart';
import 'screens/intro_screen.dart';
import 'screens/scan_review_screen.dart';
import 'storage.dart';
import 'theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final storage = await ContactStorage.create();
  runApp(App(storage: storage));
}

class App extends StatelessWidget {
  final ContactStorage storage;
  const App({super.key, required this.storage});

  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'Contact Networking Pro',
    theme: AppTheme.theme,
    debugShowCheckedModeBanner: false,
    home: RootScreen(storage: storage),
  );
}

enum _Screen { intro, home, editor, scan }

class RootScreen extends StatefulWidget {
  final ContactStorage storage;
  const RootScreen({super.key, required this.storage});

  @override
  State<RootScreen> createState() => _RootScreenState();
}

class _RootScreenState extends State<RootScreen> {
  late _Screen _screen;
  List<PanelConfig> _panels = [];
  ScanResult? _scanResult;
  bool _scanForOwnProfile = false;
  int _homeKey = 0; // increment to force HomeScreen reload after save

  @override
  void initState() {
    super.initState();
    final s = widget.storage;
    if (s.isSetupComplete) {
      _panels = buildPanelList(
        s.panelCount,
        [s.getCustomPanelName(0), s.getCustomPanelName(1)],
      );
      _screen = _Screen.home;
    } else {
      _screen = _Screen.intro;
    }
  }

  Future<void> _completeIntro(int count, List<String> customNames) async {
    final s = widget.storage;
    await s.savePanelCount(count);
    await s.saveCustomPanelName(0, customNames[0]);
    await s.saveCustomPanelName(1, customNames[1]);
    await s.markSetupComplete();
    setState(() {
      _panels = buildPanelList(count, customNames);
      _screen = _Screen.home;
    });
  }

  Future<void> _scanCard({bool forOwnProfile = false}) async {
    final picker = ImagePicker();
    final file = await picker.pickImage(source: ImageSource.camera);
    if (file == null) return;
    final result = await CardScanner.scan(File(file.path));
    setState(() {
      _scanResult = result;
      _scanForOwnProfile = forOwnProfile;
      _screen = _Screen.scan;
    });
  }

  Future<void> _confirmScan(ContactDraft draft) async {
    if (_scanForOwnProfile) {
      await widget.storage.saveContact(draft);
      setState(() { _screen = _Screen.editor; _homeKey++; });
    } else {
      await _saveToPhoneContacts(draft);
      setState(() => _screen = _Screen.home);
    }
  }

  Future<void> _saveToPhoneContacts(ContactDraft d) async {
    final hasPermission = await FlutterContacts.requestPermission();
    if (!hasPermission) return;

    final contact = Contact()
      ..name.first = d.fullName.split(' ').first
      ..name.last  = d.fullName.split(' ').skip(1).join(' ')
      ..organizations = [Organization(company: d.company, title: d.jobTitle)]
      ..phones = [
        if (d.phoneMobile.isNotEmpty) Phone(d.phoneMobile, label: PhoneLabel.mobile),
        if (d.phoneWork.isNotEmpty)   Phone(d.phoneWork,   label: PhoneLabel.work),
      ]
      ..emails = [if (d.email.isNotEmpty) Email(d.email)]
      ..websites = [if (d.website.isNotEmpty) Website(d.website)];

    await FlutterContacts.insertContact(contact);
  }

  @override
  Widget build(BuildContext context) {
    switch (_screen) {
      case _Screen.intro:
        return IntroScreen(onComplete: _completeIntro);

      case _Screen.home:
        return HomeScreen(
          key: ValueKey(_homeKey),
          panels: _panels,
          storage: widget.storage,
          onEditContact: () => setState(() => _screen = _Screen.editor),
          onScanCard: _scanCard,
        );

      case _Screen.editor:
        return EditorScreen(
          panels: _panels,
          storage: widget.storage,
          onSaved: () => setState(() { _screen = _Screen.home; _homeKey++; }),
        );

      case _Screen.scan:
        return ScanReviewScreen(
          result: _scanResult!,
          forOwnProfile: _scanForOwnProfile,
          onConfirm: _confirmScan,
        );
    }
  }
}
