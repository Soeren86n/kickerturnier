import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kicker_tournament/features/kicker/cubit/games_cubit.dart';

class NewGameScreen extends StatefulWidget {
  static const route = '/new';
  const NewGameScreen({super.key});

  @override
  State<NewGameScreen> createState() => _NewGameScreenState();
}

class _NewGameScreenState extends State<NewGameScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameA = TextEditingController();
  final _nameB = TextEditingController();
  final _goalsA = TextEditingController(text: '0');
  final _goalsB = TextEditingController(text: '0');

  @override
  void dispose() {
    _nameA.dispose();
    _nameB.dispose();
    _goalsA.dispose();
    _goalsB.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final loading = context.select<GamesCubit, bool>((c) => c.state.isLoading);

    return Scaffold(
      appBar: AppBar(title: const Text('Neues Spiel')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                key: const Key('playerANameField'),
                controller: _nameA,
                decoration: const InputDecoration(labelText: 'Spieler A'),
                validator: (inputValue) =>
                    (inputValue == null || inputValue.trim().isEmpty) ? 'Bitte Name eingeben' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                key: const Key('goalsAField'),
                controller: _goalsA,
                decoration: const InputDecoration(labelText: 'Tore A'),
                keyboardType: TextInputType.number,
                validator: _validateInt,
                onTap: () {
                  if (_goalsA.text == '0') {
                    _goalsA.clear();
                  }
                },
              ),
              const SizedBox(height: 24),
              TextFormField(
                key: const Key('playerBNameField'),
                controller: _nameB,
                decoration: const InputDecoration(labelText: 'Spieler B'),
                validator: (inputValue) =>
                    (inputValue == null || inputValue.trim().isEmpty) ? 'Bitte Name eingeben' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                key: const Key('goalsBField'),
                controller: _goalsB,
                decoration: const InputDecoration(labelText: 'Tore B'),
                keyboardType: TextInputType.number,
                validator: _validateInt,
                onTap: () {
                  if (_goalsB.text == '0') {
                    _goalsB.clear();
                  }
                },
              ),
              const SizedBox(height: 24),
              FilledButton.icon(
                key: const Key('submitNewGameButton'),
                icon: const Icon(Icons.check),
                label: Text(loading ? 'Speichere…' : 'Speichern'),
                onPressed: loading
                    ? null
                    : () async {
                        if (!_formKey.currentState!.validate()) return;

                        final goalsA = int.parse(_goalsA.text);
                        final goalsB = int.parse(_goalsB.text);

                        final cubit = context.read<GamesCubit>();
                        final navigator = Navigator.of(context);
                        final messenger = ScaffoldMessenger.of(context);

                        await cubit.addGame(
                          nameA: _nameA.text,
                          nameB: _nameB.text,
                          goalsA: goalsA,
                          goalsB: goalsB,
                        );

                        if (!context.mounted) return;

                        navigator.pop();
                        messenger.showSnackBar(
                          const SnackBar(content: Text('Spiel gespeichert')),
                        );
                      },
              )
            ],
          ),
        ),
      ),
    );
  }

  String? _validateInt(String? value) {
    if (value == null || value.isEmpty) return 'Zahl eingeben';
    final n = int.tryParse(value);
    if (n == null || n < 0) return 'Ungültige Zahl';
    return null;
  }
}
