import 'package:shared_preferences/shared_preferences.dart';
import 'models.dart';

class ContactStorage {
  final SharedPreferences _prefs;
  ContactStorage(this._prefs);

  static Future<ContactStorage> create() async {
    final prefs = await SharedPreferences.getInstance();
    return ContactStorage(prefs);
  }

  // ── Setup ──────────────────────────────────────────────────────────────────
  bool  get isSetupComplete        => _prefs.getBool('setup_complete') ?? false;
  Future<void> markSetupComplete() => _prefs.setBool('setup_complete', true);

  int   get panelCount             => _prefs.getInt('panel_count') ?? 3;
  Future<void> savePanelCount(int n) => _prefs.setInt('panel_count', n);

  String getCustomPanelName(int slot) => _prefs.getString('custom_name_$slot') ?? '';
  Future<void> saveCustomPanelName(int slot, String name) =>
      _prefs.setString('custom_name_$slot', name);

  // ── Contact ────────────────────────────────────────────────────────────────
  ContactDraft loadContact() => ContactDraft(
    fullName:    _prefs.getString('c_name')         ?? '',
    jobTitle:    _prefs.getString('c_title')        ?? '',
    company:     _prefs.getString('c_company')      ?? '',
    phoneMobile: _prefs.getString('c_phone_mobile') ?? '',
    phoneWork:   _prefs.getString('c_phone_work')   ?? '',
    email:       _prefs.getString('c_email')        ?? '',
    website:     _prefs.getString('c_website')      ?? '',
    linkedinUrl: _prefs.getString('c_linkedin')     ?? '',
    address:     _prefs.getString('c_address')      ?? '',
  );

  Future<void> saveContact(ContactDraft d) async {
    await _prefs.setString('c_name',         d.fullName);
    await _prefs.setString('c_title',        d.jobTitle);
    await _prefs.setString('c_company',      d.company);
    await _prefs.setString('c_phone_mobile', d.phoneMobile);
    await _prefs.setString('c_phone_work',   d.phoneWork);
    await _prefs.setString('c_email',        d.email);
    await _prefs.setString('c_website',      d.website);
    await _prefs.setString('c_linkedin',     d.linkedinUrl);
    await _prefs.setString('c_address',      d.address);
  }

  // ── QR content strings ─────────────────────────────────────────────────────
  String loadPanelQrContent(String panelId) =>
      _prefs.getString('qr_$panelId') ?? '';

  Future<void> savePanelQrContent(String panelId, String content) =>
      _prefs.setString('qr_$panelId', content);
}
