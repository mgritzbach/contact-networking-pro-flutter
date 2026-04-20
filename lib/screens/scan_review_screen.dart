import 'package:flutter/material.dart';
import '../models.dart';
import '../theme.dart';

class ScanReviewScreen extends StatefulWidget {
  final ScanResult result;
  final bool forOwnProfile;
  final void Function(ContactDraft draft) onConfirm;
  const ScanReviewScreen({
    super.key,
    required this.result,
    required this.forOwnProfile,
    required this.onConfirm,
  });

  @override
  State<ScanReviewScreen> createState() => _ScanReviewScreenState();
}

class _ScanReviewScreenState extends State<ScanReviewScreen> {
  late String _name, _title, _company, _phoneMobile, _phoneWork, _email, _website, _linkedin;

  @override
  void initState() {
    super.initState();
    final d = widget.result.draft;
    _name        = d.fullName;
    _title       = d.jobTitle;
    _company     = d.company;
    _phoneMobile = d.phoneMobile;
    _phoneWork   = d.phoneWork;
    _email       = d.email;
    _website     = d.website;
    _linkedin    = d.linkedinUrl;
  }

  void _confirm() {
    widget.onConfirm(ContactDraft(
      fullName:    _name,
      jobTitle:    _title,
      company:     _company,
      phoneMobile: _phoneMobile,
      phoneWork:   _phoneWork,
      email:       _email,
      website:     _website,
      linkedinUrl: _linkedin,
    ));
  }

  @override
  Widget build(BuildContext context) {
    final lines = widget.result.lines;
    final options = ['', ...lines];

    return Scaffold(
      backgroundColor: kBackground,
      appBar: AppBar(
        backgroundColor: kBackground,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: kTextSecondary),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text('REVIEW SCAN', style: Theme.of(context).textTheme.titleMedium),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _SectionLabel('DETECTED LINES'),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: lines.map((l) => Chip(
                      label: Text(l, style: const TextStyle(fontSize: 12, color: kTextPrimary)),
                      backgroundColor: kSurfaceDark,
                      side: const BorderSide(color: kBorder),
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                    )).toList(),
                  ),
                  const SizedBox(height: 28),
                  _SectionLabel('ASSIGN FIELDS'),
                  _ReviewDropdown(label: 'Full Name',   value: _name,        options: options, onChanged: (v) => setState(() => _name = v)),
                  _ReviewDropdown(label: 'Job Title',   value: _title,       options: options, onChanged: (v) => setState(() => _title = v)),
                  _ReviewDropdown(label: 'Company',     value: _company,     options: options, onChanged: (v) => setState(() => _company = v)),
                  _ReviewDropdown(label: 'Mobile',      value: _phoneMobile, options: options, onChanged: (v) => setState(() => _phoneMobile = v)),
                  _ReviewDropdown(label: 'Work Phone',  value: _phoneWork,   options: options, onChanged: (v) => setState(() => _phoneWork = v)),
                  _ReviewDropdown(label: 'Email',       value: _email,       options: options, onChanged: (v) => setState(() => _email = v)),
                  _ReviewDropdown(label: 'Website',     value: _website,     options: options, onChanged: (v) => setState(() => _website = v)),
                  _ReviewDropdown(label: 'LinkedIn',    value: _linkedin,    options: options, onChanged: (v) => setState(() => _linkedin = v)),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(24),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _confirm,
                child: Text(widget.forOwnProfile ? 'USE FOR MY PROFILE' : 'SAVE TO CONTACTS'),
              ),
            ),
          ),
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
    child: Text(text, style: const TextStyle(
      fontSize: 9, letterSpacing: 2, fontWeight: FontWeight.w700, color: kCopper,
    )),
  );
}

class _ReviewDropdown extends StatelessWidget {
  final String label;
  final String value;
  final List<String> options;
  final ValueChanged<String> onChanged;
  const _ReviewDropdown({required this.label, required this.value, required this.options, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final safeValue = options.contains(value) ? value : '';
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: DropdownButtonFormField<String>(
        value: safeValue,
        decoration: InputDecoration(labelText: label),
        dropdownColor: kSurfaceDark,
        style: const TextStyle(color: kTextPrimary, fontSize: 14),
        items: options.map((o) => DropdownMenuItem(
          value: o,
          child: Text(o.isEmpty ? '— clear —' : o, style: TextStyle(
            color: o.isEmpty ? kTextTertiary : kTextPrimary,
            fontSize: 13,
          )),
        )).toList(),
        onChanged: (v) => onChanged(v ?? ''),
      ),
    );
  }
}
