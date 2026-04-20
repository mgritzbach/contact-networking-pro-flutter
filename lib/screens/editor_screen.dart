import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../models.dart';
import '../qr_decoder.dart';
import '../storage.dart';
import '../theme.dart';

class EditorScreen extends StatefulWidget {
  final List<PanelConfig> panels;
  final ContactStorage storage;
  final VoidCallback onSaved;
  const EditorScreen({super.key, required this.panels, required this.storage, required this.onSaved});

  @override
  State<EditorScreen> createState() => _EditorScreenState();
}

class _EditorScreenState extends State<EditorScreen> with SingleTickerProviderStateMixin {
  late TabController _tabs;

  // Contact fields
  late TextEditingController _name, _title, _company, _phoneMobile, _phoneWork,
      _email, _website, _linkedin, _address;

  // QR contents per panel id
  final Map<String, String> _qrContents = {};
  final Map<String, bool> _qrLoading = {};
  final Map<String, String?> _qrError = {};

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: widget.panels.length, vsync: this);

    final c = widget.storage.loadContact();
    _name        = TextEditingController(text: c.fullName);
    _title       = TextEditingController(text: c.jobTitle);
    _company     = TextEditingController(text: c.company);
    _phoneMobile = TextEditingController(text: c.phoneMobile);
    _phoneWork   = TextEditingController(text: c.phoneWork);
    _email       = TextEditingController(text: c.email);
    _website     = TextEditingController(text: c.website);
    _linkedin    = TextEditingController(text: c.linkedinUrl);
    _address     = TextEditingController(text: c.address);

    for (final p in widget.panels) {
      if (p.id != 'contact') {
        _qrContents[p.id] = widget.storage.loadPanelQrContent(p.id);
      }
    }
  }

  @override
  void dispose() {
    _tabs.dispose();
    for (final c in [_name, _title, _company, _phoneMobile, _phoneWork, _email, _website, _linkedin, _address]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _save() async {
    final draft = ContactDraft(
      fullName:    _name.text.trim(),
      jobTitle:    _title.text.trim(),
      company:     _company.text.trim(),
      phoneMobile: _phoneMobile.text.trim(),
      phoneWork:   _phoneWork.text.trim(),
      email:       _email.text.trim(),
      website:     _website.text.trim(),
      linkedinUrl: _linkedin.text.trim(),
      address:     _address.text.trim(),
    );
    await widget.storage.saveContact(draft);
    for (final entry in _qrContents.entries) {
      await widget.storage.savePanelQrContent(entry.key, entry.value);
    }
    widget.onSaved();
  }

  Future<void> _pickAndDecode(String panelId) async {
    final picker = ImagePicker();
    final file = await picker.pickImage(source: ImageSource.gallery);
    if (file == null) return;

    setState(() { _qrLoading[panelId] = true; _qrError[panelId] = null; });

    final content = await QrDecoder.decodeFromPath(file.path);

    setState(() {
      _qrLoading[panelId] = false;
      if (content != null && content.isNotEmpty) {
        _qrContents[panelId] = content;
        _qrError[panelId] = null;
      } else {
        _qrError[panelId] = 'No QR code found in image';
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackground,
      appBar: AppBar(
        backgroundColor: kBackground,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: kTextSecondary),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text('EDIT PROFILE', style: Theme.of(context).textTheme.titleMedium),
        actions: [
          TextButton(
            onPressed: _save,
            child: Text('SAVE', style: TextStyle(color: kCopper, fontWeight: FontWeight.w700, letterSpacing: 1.2)),
          ),
        ],
        bottom: TabBar(
          controller: _tabs,
          isScrollable: true,
          indicatorColor: kCopper,
          labelColor: kCopper,
          unselectedLabelColor: kTextTertiary,
          labelStyle: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, letterSpacing: 1.5),
          tabs: widget.panels.map((p) => Tab(text: p.label)).toList(),
        ),
      ),
      body: TabBarView(
        controller: _tabs,
        children: widget.panels.map((p) {
          if (p.id == 'contact') return _ContactTab(
            name: _name, title: _title, company: _company,
            phoneMobile: _phoneMobile, phoneWork: _phoneWork,
            email: _email, website: _website, linkedin: _linkedin, address: _address,
          );
          return _QrTab(
            panel: p,
            content: _qrContents[p.id] ?? '',
            loading: _qrLoading[p.id] ?? false,
            error: _qrError[p.id],
            onPick: () => _pickAndDecode(p.id),
            onClear: () => setState(() => _qrContents[p.id] = ''),
          );
        }).toList(),
      ),
    );
  }
}

class _ContactTab extends StatelessWidget {
  final TextEditingController name, title, company, phoneMobile, phoneWork,
      email, website, linkedin, address;
  const _ContactTab({
    required this.name, required this.title, required this.company,
    required this.phoneMobile, required this.phoneWork, required this.email,
    required this.website, required this.linkedin, required this.address,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionLabel('IDENTITY'),
          _Field(controller: name, label: 'Full Name'),
          _Field(controller: title, label: 'Job Title'),
          _Field(controller: company, label: 'Company'),
          const SizedBox(height: 24),
          _SectionLabel('PHONE'),
          _Field(controller: phoneMobile, label: 'Mobile', keyboard: TextInputType.phone),
          _Field(controller: phoneWork, label: 'Work', keyboard: TextInputType.phone),
          const SizedBox(height: 24),
          _SectionLabel('ONLINE'),
          _Field(controller: email, label: 'Email', keyboard: TextInputType.emailAddress),
          _Field(controller: website, label: 'Website', keyboard: TextInputType.url),
          _Field(controller: linkedin, label: 'LinkedIn URL', keyboard: TextInputType.url),
          const SizedBox(height: 24),
          _SectionLabel('ADDRESS'),
          _Field(controller: address, label: 'Address', maxLines: 2),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: Text(text, style: TextStyle(
      fontSize: 9, letterSpacing: 2, fontWeight: FontWeight.w700, color: kCopper,
    )),
  );
}

class _Field extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final TextInputType? keyboard;
  final int maxLines;
  const _Field({required this.controller, required this.label, this.keyboard, this.maxLines = 1});

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 16),
    child: TextField(
      controller: controller,
      keyboardType: keyboard,
      maxLines: maxLines,
      style: const TextStyle(color: kTextPrimary),
      decoration: InputDecoration(labelText: label),
    ),
  );
}

class _QrTab extends StatelessWidget {
  final PanelConfig panel;
  final String content;
  final bool loading;
  final String? error;
  final VoidCallback onPick;
  final VoidCallback onClear;
  const _QrTab({
    required this.panel, required this.content, required this.loading,
    required this.error, required this.onPick, required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Upload a screenshot or image containing your ${panel.label} QR code.',
            style: TextStyle(color: kTextSecondary, fontSize: 13),
          ),
          const SizedBox(height: 24),
          if (loading) ...[
            const Center(child: CircularProgressIndicator(color: kCopper)),
            const SizedBox(height: 16),
            Center(child: Text('Decoding QR...', style: TextStyle(color: kTextSecondary, fontSize: 12))),
          ] else if (error != null) ...[
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFF3A1A1A),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFF7A2A2A)),
              ),
              child: Row(children: [
                const Icon(Icons.error_outline, color: Color(0xFFE57373), size: 18),
                const SizedBox(width: 10),
                Text(error!, style: const TextStyle(color: Color(0xFFE57373), fontSize: 13)),
              ]),
            ),
            const SizedBox(height: 20),
          ] else if (content.isNotEmpty) ...[
            Center(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [BoxShadow(color: kCopper.withOpacity(0.15), blurRadius: 20)],
                ),
                padding: const EdgeInsets.all(16),
                child: QrImageView(
                  data: content,
                  version: QrVersions.auto,
                  size: 220,
                  backgroundColor: Colors.white,
                  errorCorrectionLevel: QrErrorCorrectLevel.M,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Center(
              child: TextButton.icon(
                onPressed: onClear,
                icon: const Icon(Icons.delete_outline, size: 16, color: kTextTertiary),
                label: Text('Clear', style: TextStyle(color: kTextTertiary, fontSize: 13)),
              ),
            ),
            const SizedBox(height: 8),
          ],
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: loading ? null : onPick,
              icon: const Icon(Icons.upload_outlined, size: 18),
              label: Text(content.isNotEmpty ? 'REPLACE QR IMAGE' : 'UPLOAD QR IMAGE'),
              style: OutlinedButton.styleFrom(
                foregroundColor: kCopper,
                side: const BorderSide(color: kCopper),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
