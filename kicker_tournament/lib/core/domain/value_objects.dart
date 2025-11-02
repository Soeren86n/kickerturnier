import 'package:equatable/equatable.dart';
import 'package:kicker_tournament/core/exceptions.dart';

/// Value Object für Spielernamen mit eingebauter Validierung.
///
/// Why: Business-Regeln (min. 2 Zeichen, nicht leer) werden zentral erzwungen,
/// nicht nur in der UI. Verhindert ungültige Daten im System.
class PlayerName extends Equatable {
  final String value;

  const PlayerName._(this.value);

  /// Erstellt einen validierten Spielernamen.
  ///
  /// Wirft [ValidationException] wenn:
  /// - Name leer oder nur Whitespace
  /// - Name kürzer als 2 Zeichen
  factory PlayerName(String input) {
    final trimmed = input.trim();
    
    if (trimmed.isEmpty) {
      throw ValidationException(
        'Spielername darf nicht leer sein',
        field: 'playerName',
      );
    }
    
    if (trimmed.length < 2) {
      throw ValidationException(
        'Spielername muss mindestens 2 Zeichen lang sein',
        field: 'playerName',
      );
    }
    
    return PlayerName._(trimmed);
  }

  @override
  List<Object?> get props => [value];

  @override
  String toString() => value;
}

/// Value Object für Tore mit eingebauter Validierung.
///
/// Why: Stellt sicher, dass nur nicht-negative Torzahlen gespeichert werden.
class Goals extends Equatable {
  final int value;

  const Goals._(this.value);

  /// Erstellt eine validierte Torzahl.
  ///
  /// Wirft [ValidationException] wenn:
  /// - Wert negativ ist
  factory Goals(int input) {
    if (input < 0) {
      throw ValidationException(
        'Tore können nicht negativ sein',
        field: 'goals',
      );
    }
    
    return Goals._(input);
  }

  @override
  List<Object?> get props => [value];

  @override
  String toString() => value.toString();
}
