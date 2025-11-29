// lib/CreateSection/widgets/quiz_saved_dialog.dart
import 'package:flutter/material.dart';
import 'package:quiz_app/utils/color.dart';

class QuizSavedDialog extends StatefulWidget {
  final String title;
  final String message;
  final Future<void> Function()? onDismiss;

  const QuizSavedDialog({
    super.key,
    required this.title,
    required this.message,
    this.onDismiss,
  });

  @override
  State<QuizSavedDialog> createState() => _QuizSavedDialogState();

  static Future<void> show(
    BuildContext context, {
    required String title,
    required String message,
    Future<void> Function()? onDismiss,
  }) {
    return showDialog<void>(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black.withValues(alpha: 0.3),
      builder: (BuildContext context) {
        return QuizSavedDialog(
          title: title,
          message: message,
          onDismiss: onDismiss,
        );
      },
    );
  }
}

class _QuizSavedDialogState extends State<QuizSavedDialog>
    with TickerProviderStateMixin {
  late AnimationController _scaleController;
  late AnimationController _checkController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _checkAnimation;

  @override
  void initState() {
    super.initState();

    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _checkController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _scaleAnimation = CurvedAnimation(
      parent: _scaleController,
      curve: Curves.elasticOut,
    );

    _checkAnimation = CurvedAnimation(
      parent: _checkController,
      curve: Curves.easeInOut,
    );

    // Start animations
    _scaleController.forward();
    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) {
        _checkController.forward();
      }
    });

    // Auto dismiss after 3 seconds
    Future.delayed(const Duration(seconds: 3), () async {
      if (mounted && Navigator.canPop(context)) {
        Navigator.of(context).pop();
        await widget.onDismiss?.call();
      }
    });
  }

  @override
  void dispose() {
    _scaleController.dispose();
    _checkController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Success Icon with Animation
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.green, width: 3),
                ),
                child: AnimatedBuilder(
                  animation: _checkAnimation,
                  builder: (context, child) {
                    return CustomPaint(
                      painter: CheckmarkPainter(_checkAnimation.value),
                      size: const Size(80, 80),
                    );
                  },
                ),
              ),

              const SizedBox(height: 20),

              // Title
              Text(
                widget.title,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 12),

              // Message
              Text(
                widget.message,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey.shade700,
                  height: 1.4,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 24),

              // Decorative elements
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildDot(Colors.blue),
                  const SizedBox(width: 8),
                  _buildDot(Colors.purple),
                  const SizedBox(width: 8),
                  _buildDot(Colors.orange),
                  const SizedBox(width: 8),
                  _buildDot(Colors.pink),
                ],
              ),

              const SizedBox(height: 20),

              // Close Button
              GestureDetector(
                onTap: () async {
                  Navigator.of(context).pop();
                  await widget.onDismiss?.call();
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(25),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.3),
                        blurRadius: 8,
                        offset: const Offset(4, 4),
                      ),
                    ],
                  ),
                  child: const Text(
                    'Continue',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDot(Color color) {
    return Container(
      width: 8,
      height: 8,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }
}

class CheckmarkPainter extends CustomPainter {
  final double progress;

  CheckmarkPainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.green
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final center = Offset(size.width / 2, size.height / 2);
    final checkPath = Path();

    // Define checkmark points
    final startPoint = Offset(center.dx - 12, center.dy);
    final middlePoint = Offset(center.dx - 2, center.dy + 8);
    final endPoint = Offset(center.dx + 12, center.dy - 8);

    if (progress <= 0.5) {
      // First half: draw line from start to middle
      final currentProgress = progress * 2;
      final currentPoint = Offset.lerp(
        startPoint,
        middlePoint,
        currentProgress,
      )!;

      checkPath.moveTo(startPoint.dx, startPoint.dy);
      checkPath.lineTo(currentPoint.dx, currentPoint.dy);
    } else {
      // Second half: draw line from middle to end
      final currentProgress = (progress - 0.5) * 2;
      final currentPoint = Offset.lerp(middlePoint, endPoint, currentProgress)!;

      checkPath.moveTo(startPoint.dx, startPoint.dy);
      checkPath.lineTo(middlePoint.dx, middlePoint.dy);
      checkPath.lineTo(currentPoint.dx, currentPoint.dy);
    }

    canvas.drawPath(checkPath, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}
