# EyeVoices App - Theme System Documentation

## Übersicht

Die EyeVoices App nutzt jetzt ein zentralisiertes Theme-System, das auf Flutter's Material 3 Design System und `ColorScheme.fromSeed` basiert. Dies gewährleistet konsistente Farben und einfache Wartung.

## Theme-Struktur

### Zentrale Theme-Konfiguration

- **Datei**: `lib/config/app_theme.dart`
- **Basis**: Material 3 mit ColorScheme.fromSeed
- **Primärfarbe**: Purple (#6A1B9A)

### Brand-spezifische Farben (ThemeExtension)

- **successGreen**: Für erfolgreiche Aktionen (Blink Detection ON, ausgewählte Sätze)
- **warningOrange**: Für Warnungen (Blink Detection OFF)
- **focusBlue**: Für Fokus-Zustände (hervorgehobene Sätze)
- **sentenceGray**: Für normale Satz-Karten
- **statusBackground**: Für Status-Widget Hintergrund
- **previewBorder**: Für Kamera-Vorschau Ränder
- **highlightOverlay**: Für Überlagerungseffekte

### Theme Extensions

- **Datei**: `lib/config/theme_extensions.dart`
- Stellt praktische Extension-Methods für einfachen Zugriff auf Theme-Farben bereit

## Verwendung

### Standard ColorScheme Farben

```dart
// Primärfarben
context.primaryColor
context.onPrimary

// Oberflächen
context.surface
context.onSurface
context.background
context.onBackground
```

### Brand-spezifische Farben

```dart
// Status-Farben
context.successGreen    // Für erfolgreiche Aktionen
context.warningOrange   // Für Warnungen
context.focusBlue       // Für Fokus-Zustände

// UI-Farben
context.sentenceGray    // Für normale Text-Elemente
context.statusBackground // Für Container-Hintergründe
context.previewBorder   // Für Ränder
```

### Theme-Modi

- **Light Theme**: Weiße Hintergründe, dunkle Texte
- **Dark Theme**: Dunkle Hintergründe (#0A0A0A), helle Texte
- **Standard**: Dark Mode

## Datei-Updates

### Aktualisierte Komponenten

1. **main.dart**: Theme-Integration
2. **control_button_widget.dart**: Theme-konforme Button-Farben
3. **status_widget.dart**: Theme-konforme Status-Anzeige
4. **sentence_wheel_widget.dart**: Theme-konforme Satz-Karten
5. **camera_preview_widget.dart**: Theme-konforme Kamera-Ränder
6. **header_widget.dart**: Theme-konforme Text-Farben
7. **home_screen.dart**: Theme-konforme Hintergründe

### Entfernte hartcodierte Farben

- `Colors.green` → `context.successGreen`
- `Colors.orange` → `context.warningOrange`
- `Colors.blue` → `context.focusBlue`
- `Colors.grey` → `context.sentenceGray`
- `Colors.purple` → `context.primaryColor`
- `Colors.black/white` → `context.onSurface`

## Konfiguration

### App-Theme ändern

```dart
// In main.dart
MaterialApp(
  theme: AppTheme.lightTheme,     // Helles Theme
  darkTheme: AppTheme.darkTheme,  // Dunkles Theme
  themeMode: ThemeMode.system,    // Folgt System-Einstellung
)
```

### Neue Markenfarben hinzufügen

1. Farbe in `BrandColors` class hinzufügen
2. `copyWith` und `lerp` Methoden aktualisieren
3. `light` und `dark` Konstanten erweitern
4. Extension method in `theme_extensions.dart` hinzufügen

## Vorteile

### Konsistenz

- Alle Farben sind zentral verwaltet
- Automatische Light/Dark Theme Unterstützung
- Material 3 Design Guidelines

### Wartbarkeit

- Einfache Farbanpassungen an einem Ort
- Typsichere Farbzugriffe
- Klare Trennung zwischen System- und Brand-Farben

### Erweiterbarkeit

- Einfaches Hinzufügen neuer Brand-Farben
- Unterstützung für Theme-Animationen
- Vorbereitet für zukünftige Design-Updates

## Best Practices

1. **Verwende immer Theme-Farben** statt hartkodierten Werten
2. **Nutze Extension-Methods** für sauberen Code
3. **Teste beide Theme-Modi** (Light/Dark)
4. **Dokumentiere neue Farben** bei Erweiterungen

## Migration von alten Farben

| Alt             | Neu                     |
| --------------- | ----------------------- |
| `Colors.green`  | `context.successGreen`  |
| `Colors.orange` | `context.warningOrange` |
| `Colors.blue`   | `context.focusBlue`     |
| `Colors.grey`   | `context.sentenceGray`  |
| `Colors.purple` | `context.primaryColor`  |
| `Colors.black`  | `context.onSurface`     |
| `Colors.white`  | `context.surface`       |
