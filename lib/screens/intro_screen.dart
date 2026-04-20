import 'package:flutter/material.dart';
import '../theme.dart';

class IntroScreen extends StatefulWidget {
  final void Function(int count, List<String> customNames) onComplete;
  const IntroScreen({super.key, required this.onComplete});

  @override
  State<IntroScreen> createState() => _IntroScreenState();
}

class _IntroScreenState extends State<IntroScreen> {
  int _count = 3;
  final _name0 = TextEditingController();
  final _name1 = TextEditingController();

  @override
  void dispose() {
    _name0.dispose();
    _name1.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackground,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(width: double.infinity, height: 2, color: kCopper),
              const SizedBox(height: 40),
              Text('CONTACT\nNETWORKING\nPRO',
                  style: Theme.of(context).textTheme.displayMedium),
              const SizedBox(height: 12),
              Text('Professional networking, elevated.',
                  style: Theme.of(context).textTheme.bodyMedium),
              const SizedBox(height: 48),
              Text('HOW MANY QR PANELS?',
                  style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 4),
              Text('Contact QR is always included. Choose additional panels.',
                  style: Theme.of(context).textTheme.bodySmall),
              const SizedBox(height: 20),
              Row(children: [3, 4, 5].map((n) => _CountCard(
                n: n,
                selected: _count == n,
                onTap: () => setState(() => _count = n),
              )).toList()),
              if (_count >= 4) ...[
                const SizedBox(height: 28),
                Text('CUSTOM PANEL NAMES', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 16),
                _LuxField(controller: _name0, label: 'Panel 4 name (e.g. Telegram)'),
              ],
              if (_count >= 5) ...[
                const SizedBox(height: 12),
                _LuxField(controller: _name1, label: 'Panel 5 name (e.g. Signal)'),
              ],
              const SizedBox(height: 48),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => widget.onComplete(
                    _count, [_name0.text.trim(), _name1.text.trim()]),
                  child: const Text('GET STARTED'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CountCard extends StatelessWidget {
  final int n;
  final bool selected;
  final VoidCallback onTap;
  const _CountCard({required this.n, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.only(right: 10),
          padding: const EdgeInsets.symmetric(vertical: 20),
          decoration: BoxDecoration(
            color: selected ? kCopperContainer : kSurfaceDark,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: selected ? kCopper : kBorder,
              width: selected ? 1.5 : 1,
            ),
          ),
          child: Column(
            children: [
              Text('$n', style: TextStyle(
                fontSize: 32, fontWeight: FontWeight.w300,
                color: selected ? kCopper : kTextSecondary,
              )),
              const SizedBox(height: 4),
              Text('PANELS', style: TextStyle(
                fontSize: 9, letterSpacing: 1.5,
                fontWeight: FontWeight.w700,
                color: selected ? kCopper : kTextTertiary,
              )),
            ],
          ),
        ),
      ),
    );
  }
}

class _LuxField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  const _LuxField({required this.controller, required this.label});

  @override
  Widget build(BuildContext context) => TextField(
    controller: controller,
    style: const TextStyle(color: kTextPrimary),
    decoration: InputDecoration(labelText: label),
  );
}
