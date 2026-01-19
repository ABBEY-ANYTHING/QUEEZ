import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quiz_app/providers/session_provider.dart';
import 'package:quiz_app/services/websocket_service.dart';
import 'package:quiz_app/widgets/core/app_dialog.dart';

class ReconnectionOverlay extends ConsumerWidget {
  final Widget child;

  const ReconnectionOverlay({super.key, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final connectionStatus = ref.watch(connectionStatusProvider);

    return Stack(
      children: [
        child,
        connectionStatus.when(
          data: (status) {
            if (status == ConnectionStatus.reconnecting) {
              return _buildReconnectingOverlay(context);
            } else if (status == ConnectionStatus.disconnected) {
              return _buildDisconnectedOverlay(context);
            }
            return const SizedBox.shrink();
          },
          loading: () => const SizedBox.shrink(),
          error: (_, __) => const SizedBox.shrink(),
        ),
      ],
    );
  }

  Widget _buildReconnectingOverlay(BuildContext context) {
    return Container(
      color: Colors.black.withValues(alpha: 0.8),
      child: Center(
        child: Card(
          elevation: 8,
          margin: const EdgeInsets.all(24.0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 60,
                  height: 60,
                  child: CircularProgressIndicator(
                    strokeWidth: 4,
                    color: Colors.amber,
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'RECONNECTING...',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.amber,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Please wait while we restore your connection',
                  style: TextStyle(color: Colors.grey[400]),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDisconnectedOverlay(BuildContext context) {
    return Container(
      color: Colors.black.withValues(alpha: 0.9),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Card(
            elevation: 8,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(32.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.signal_wifi_off,
                    size: 80,
                    color: Colors.red,
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'CONNECTION LOST',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.red,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Unable to connect to the server.\nPlease check your internet connection.',
                    style: TextStyle(color: Colors.grey[400]),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// Error listener widget
class ErrorListener extends ConsumerStatefulWidget {
  final Widget child;

  const ErrorListener({super.key, required this.child});

  @override
  ConsumerState<ErrorListener> createState() => _ErrorListenerState();
}

class _ErrorListenerState extends ConsumerState<ErrorListener> {
  @override
  void initState() {
    super.initState();

    // Listen to error stream
    Future.microtask(() {
      final notifier = ref.read(sessionProvider.notifier);
      notifier.errorStream.listen((error) {
        if (mounted) {
          _showErrorDialog(error);
        }
      });
    });
  }

  void _showErrorDialog(String message) {
    AppDialog.show(
      context: context,
      title: 'ERROR',
      content: message,
      primaryActionText: 'OK',
      // No callback needed - dialog will close automatically
    );
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
