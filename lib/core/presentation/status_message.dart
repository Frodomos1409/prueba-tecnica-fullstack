import 'package:flutter/material.dart';

class StatusMessage extends StatelessWidget {
  final String message;
  final IconData icon;
  final VoidCallback? retry;
  const StatusMessage({
    super.key,
    required this.message,
    required this.icon,
    this.retry,
  });
  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 48),
          const SizedBox(height: 16),
          Text(message, textAlign: TextAlign.center),
          if (retry != null)
            Padding(
              padding: const EdgeInsets.only(top: 16),
              child: FilledButton(
                onPressed: retry,
                child: const Text('Reintentar'),
              ),
            ),
        ],
      ),
    ),
  );
}
