import 'dart:async';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../models.dart';
import '../storage.dart';
import '../theme.dart';

class HomeScreen extends StatefulWidget {
  final List<PanelConfig> panels;
  final ContactStorage storage;
  final VoidCallback onEditContact;
  final VoidCallback onScanCard;
  const HomeScreen({
    super.key,
    required this.panels,
    required this.storage,
    required this.onEditContact,
    required this.onScanCard,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _activeIndex = 0;
  final Map<String, String> _qrContents = {};

  @override
  void initState() {
    super.initState();
    _loadContents();
  }

  void _loadContents() {
    final contact = widget.storage.loadContact();
    final vcard = buildVCard(contact);
    setState(() {
      _qrContents['contact'] = vcard;
      for (final p in widget.panels) {
        if (p.id != 'contact') {
          _qrContents[p.id] = widget.storage.loadPanelQrContent(p.id);
        }
      }
    });
  }

  @override
  void didUpdateWidget(HomeScreen old) {
    super.didUpdateWidget(old);
    _loadContents();
  }

  @override
  Widget build(BuildContext context) {
    final panel = widget.panels[_activeIndex];
    final content = _qrContents[panel.id] ?? '';

    return Scaffold(
      backgroundColor: kBackground,
      body: SafeArea(
        child: Column(
          children: [
            _TopBar(
              onEdit: widget.onEditContact,
              onScan: widget.onScanCard,
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _PanelTabs(
                      panels: widget.panels,
                      activeIndex: _activeIndex,
                      onSelect: (i) => setState(() => _activeIndex = i),
                    ),
                    const SizedBox(height: 32),
                    _QrCard(content: content, label: panel.label),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  final VoidCallback onEdit;
  final VoidCallback onScan;
  const _TopBar({required this.onEdit, required this.onScan});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        children: [
          Container(width: 3, height: 28, color: kCopper),
          const SizedBox(width: 12),
          Text('CNP', style: Theme.of(context).textTheme.titleMedium),
          const Spacer(),
          _IconBtn(icon: Icons.credit_card_outlined, tooltip: 'Scan Card', onTap: onScan),
          const SizedBox(width: 4),
          _IconBtn(icon: Icons.edit_outlined, tooltip: 'Edit Contact', onTap: onEdit),
        ],
      ),
    );
  }
}

class _IconBtn extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;
  const _IconBtn({required this.icon, required this.tooltip, required this.onTap});

  @override
  Widget build(BuildContext context) => IconButton(
    icon: Icon(icon, color: kTextSecondary, size: 22),
    tooltip: tooltip,
    onPressed: onTap,
  );
}

class _PanelTabs extends StatelessWidget {
  final List<PanelConfig> panels;
  final int activeIndex;
  final ValueChanged<int> onSelect;
  const _PanelTabs({required this.panels, required this.activeIndex, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(panels.length, (i) {
        final active = i == activeIndex;
        return Expanded(
          child: GestureDetector(
            onTap: () => onSelect(i),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              margin: EdgeInsets.only(right: i < panels.length - 1 ? 8 : 0),
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                color: active ? kCopperContainer : kSurfaceDark,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: active ? kCopper : kBorder, width: active ? 1.5 : 1),
              ),
              child: Text(
                panels[i].label,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 8,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.2,
                  color: active ? kCopper : kTextTertiary,
                ),
              ),
            ),
          ),
        );
      }),
    );
  }
}

class _QrCard extends StatelessWidget {
  final String content;
  final String label;
  const _QrCard({required this.content, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(28),
      decoration: copperCardDecoration(),
      child: Column(
        children: [
          if (content.isNotEmpty)
            QrImageView(
              data: content,
              version: QrVersions.auto,
              size: 240,
              backgroundColor: Colors.white,
              errorCorrectionLevel: QrErrorCorrectLevel.M,
            )
          else
            Container(
              width: 240,
              height: 240,
              decoration: BoxDecoration(
                color: kSurfaceDark,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: kBorder),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.qr_code_2, color: kTextTertiary, size: 48),
                  const SizedBox(height: 12),
                  Text(
                    'No content saved',
                    style: TextStyle(color: kTextTertiary, fontSize: 12),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 20),
          Text(label, style: TextStyle(
            fontSize: 10, letterSpacing: 2, fontWeight: FontWeight.w700, color: kCopper,
          )),
        ],
      ),
    );
  }
}
