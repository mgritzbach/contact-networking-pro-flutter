class ContactDraft {
  final String fullName;
  final String jobTitle;
  final String company;
  final String phoneMobile;
  final String phoneWork;
  final String email;
  final String website;
  final String linkedinUrl;
  final String address;

  const ContactDraft({
    this.fullName    = '',
    this.jobTitle    = '',
    this.company     = '',
    this.phoneMobile = '',
    this.phoneWork   = '',
    this.email       = '',
    this.website     = '',
    this.linkedinUrl = '',
    this.address     = '',
  });

  ContactDraft copyWith({
    String? fullName, String? jobTitle, String? company,
    String? phoneMobile, String? phoneWork, String? email,
    String? website, String? linkedinUrl, String? address,
  }) => ContactDraft(
    fullName:    fullName    ?? this.fullName,
    jobTitle:    jobTitle    ?? this.jobTitle,
    company:     company     ?? this.company,
    phoneMobile: phoneMobile ?? this.phoneMobile,
    phoneWork:   phoneWork   ?? this.phoneWork,
    email:       email       ?? this.email,
    website:     website     ?? this.website,
    linkedinUrl: linkedinUrl ?? this.linkedinUrl,
    address:     address     ?? this.address,
  );

  bool get isEmpty => [fullName, jobTitle, company, phoneMobile,
      phoneWork, email, website, linkedinUrl].every((s) => s.isEmpty);

  Map<String, String> toMap() => {
    'fullName': fullName, 'jobTitle': jobTitle, 'company': company,
    'phoneMobile': phoneMobile, 'phoneWork': phoneWork, 'email': email,
    'website': website, 'linkedinUrl': linkedinUrl, 'address': address,
  };

  factory ContactDraft.fromMap(Map<String, String> m) => ContactDraft(
    fullName:    m['fullName']    ?? '',
    jobTitle:    m['jobTitle']    ?? '',
    company:     m['company']     ?? '',
    phoneMobile: m['phoneMobile'] ?? '',
    phoneWork:   m['phoneWork']   ?? '',
    email:       m['email']       ?? '',
    website:     m['website']     ?? '',
    linkedinUrl: m['linkedinUrl'] ?? '',
    address:     m['address']     ?? '',
  );
}

class PanelConfig {
  final String id;
  final String label;
  const PanelConfig({required this.id, required this.label});
}

List<PanelConfig> buildPanelList(int count, List<String> customNames) {
  final panels = [
    const PanelConfig(id: 'contact',  label: 'CONTACT'),
    const PanelConfig(id: 'linkedin', label: 'LINKEDIN'),
    const PanelConfig(id: 'whatsapp', label: 'WHATSAPP'),
  ];
  if (count >= 4) panels.add(PanelConfig(
      id: 'custom_0', label: customNames[0].isNotEmpty ? customNames[0].toUpperCase() : 'CUSTOM 1'));
  if (count >= 5) panels.add(PanelConfig(
      id: 'custom_1', label: customNames[1].isNotEmpty ? customNames[1].toUpperCase() : 'CUSTOM 2'));
  return panels;
}

class ScanResult {
  final ContactDraft draft;
  final List<String> lines;
  const ScanResult({required this.draft, required this.lines});
}

// ── vCard builder ─────────────────────────────────────────────────────────────
String buildVCard(ContactDraft d) {
  final rows = ['BEGIN:VCARD', 'VERSION:3.0'];
  if (d.fullName.isNotEmpty)    rows.add('FN:${_vc(d.fullName)}');
  if (d.company.isNotEmpty)     rows.add('ORG:${_vc(d.company)}');
  if (d.jobTitle.isNotEmpty)    rows.add('TITLE:${_vc(d.jobTitle)}');
  if (d.phoneMobile.isNotEmpty) rows.add('TEL;TYPE=CELL:${_vc(d.phoneMobile)}');
  if (d.phoneWork.isNotEmpty)   rows.add('TEL;TYPE=WORK:${_vc(d.phoneWork)}');
  if (d.email.isNotEmpty)       rows.add('EMAIL:${_vc(d.email)}');
  if (d.website.isNotEmpty)     rows.add('URL:${_vc(d.website)}');
  if (d.linkedinUrl.isNotEmpty) rows.add('URL;TYPE=LINKEDIN:${_vc(d.linkedinUrl)}');
  if (d.address.isNotEmpty)     rows.add('ADR:;;${_vc(d.address)};;;;');
  rows.add('END:VCARD');
  return rows.join('\n');
}

String _vc(String v) => v
    .replaceAll(r'\', r'\\')
    .replaceAll(';', r'\;')
    .replaceAll(',', r'\,')
    .replaceAll('\n', r'\n');
