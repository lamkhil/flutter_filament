import 'dart:developer' as developer;

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../theme/filament_theme.dart';

/// Reusable error widget that:
///   - Renders the error message as `SelectableText` (admin can copy).
///   - Extracts URLs from the message and renders an "Open link" button per
///     URL — utamanya untuk menghandle error Firestore yang menyertakan
///     create-index URL ("FAILED_PRECONDITION: The query requires an
///     index. You can create it here: https://console.firebase...").
///   - Optionally exposes a "Coba lagi" button when [onRetry] is given.
///   - Otomatis `developer.log` setiap error masuk (sekali per identitas
///     error). Index URL juga di-print terpisah supaya gampang di-copy
///     dari devtools / browser console.
///
/// Pakai di mana saja yang punya error state (StreamBuilder, FutureBuilder,
/// halaman custom). `TableBuilderWidget` juga pakai ini.
class ErrorView extends StatefulWidget {
  final Object error;
  final VoidCallback? onRetry;
  final EdgeInsetsGeometry padding;
  final double maxWidth;

  /// Optional override untuk pesan error. Default: `error.toString()`.
  final String? message;

  const ErrorView({
    super.key,
    required this.error,
    this.onRetry,
    this.message,
    this.padding = const EdgeInsets.all(40),
    this.maxWidth = 560,
  });

  static final RegExp _urlRegex =
      RegExp(r'https?://[^\s)\]]+', multiLine: true, caseSensitive: false);

  /// Ekstrak semua URL dari `text`. Public agar caller bisa
  /// menggunakannya untuk kondisional UI sendiri kalau perlu.
  static List<String> extractUrls(String text) =>
      _urlRegex.allMatches(text).map((m) => m.group(0)!).toList();

  static bool isIndexUrl(String url) =>
      url.contains('/indexes') || url.contains('create_composite=');

  static String linkLabel(String url) =>
      isIndexUrl(url) ? 'Buka link untuk buat index' : 'Buka link';

  /// Log error ke `developer.log` + `print` URL index kalau ada.
  /// Pakai dari catch block / snackbar / mana saja yang tidak render
  /// `ErrorView` widget tapi tetap mau jejak error masuk ke console.
  static void report(Object error, {String? message}) {
    final text = message ?? error.toString();
    final urls = extractUrls(text);
    final indexUrls = urls.where(isIndexUrl).toList();
    developer.log(
      text,
      name: indexUrls.isNotEmpty ? 'firestore.index' : 'ErrorView',
      error: error,
    );
    for (final u in indexUrls) {
      // ignore: avoid_print
      print('[firestore.index] Buat index: $u');
    }
  }

  /// Tampilkan error sebagai SnackBar dan otomatis log via [report].
  /// Kalau pesan error mengandung index URL, SnackBar punya action
  /// "Buka link" yang open URL di tab/browser baru.
  static void showAsSnackBar(BuildContext context, Object error,
      {String? message, Duration? duration}) {
    final text = message ?? error.toString();
    report(error, message: message);
    final urls = extractUrls(text);
    final actionable = urls.where(isIndexUrl).firstOrNull ?? urls.firstOrNull;
    final messenger = ScaffoldMessenger.of(context);
    messenger.showSnackBar(
      SnackBar(
        content: Text(
          text,
          maxLines: 4,
          overflow: TextOverflow.ellipsis,
        ),
        duration: duration ??
            (actionable != null
                ? const Duration(seconds: 12)
                : const Duration(seconds: 4)),
        action: actionable == null
            ? null
            : SnackBarAction(
                label: linkLabel(actionable),
                onPressed: () => launchUrl(
                  Uri.parse(actionable),
                  mode: LaunchMode.externalApplication,
                ),
              ),
      ),
    );
  }

  @override
  State<ErrorView> createState() => _ErrorViewState();
}

class _ErrorViewState extends State<ErrorView> {
  @override
  void initState() {
    super.initState();
    _logError();
  }

  @override
  void didUpdateWidget(covariant ErrorView old) {
    super.didUpdateWidget(old);
    if (!identical(old.error, widget.error)) _logError();
  }

  void _logError() =>
      ErrorView.report(widget.error, message: widget.message);

  @override
  Widget build(BuildContext context) {
    final theme = FilamentThemeScope.of(context);
    final text = widget.message ?? widget.error.toString();
    final urls = ErrorView.extractUrls(text);

    return Padding(
      padding: widget.padding,
      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: widget.maxWidth),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.error_outline, color: theme.colors.danger, size: 36),
              const SizedBox(height: 8),
              SelectableText(
                text,
                textAlign: TextAlign.center,
                style: TextStyle(color: theme.textSecondary),
              ),
              if (urls.isNotEmpty) ...[
                const SizedBox(height: 16),
                for (final u in urls)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: FilledButton.icon(
                      onPressed: () => launchUrl(
                        Uri.parse(u),
                        mode: LaunchMode.externalApplication,
                      ),
                      icon: const Icon(Icons.open_in_new, size: 16),
                      label: Text(ErrorView.linkLabel(u)),
                      style: FilledButton.styleFrom(
                        backgroundColor: theme.colors.primary,
                      ),
                    ),
                  ),
              ],
              if (widget.onRetry != null) ...[
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  onPressed: widget.onRetry,
                  icon: const Icon(Icons.refresh, size: 16),
                  label: const Text('Coba lagi'),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
