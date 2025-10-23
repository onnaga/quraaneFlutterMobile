import 'package:flutter/material.dart';

void showStyledSnackBar(BuildContext context, {required String message, bool isError = false}) {
  // إخفاء أي SnackBar حالي قبل إظهار واحد جديد
  ScaffoldMessenger.of(context).hideCurrentSnackBar();

  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Row(
        children: [
          Icon(isError ? Icons.error_outline : Icons.check_circle_outline, color: Colors.white, size: 28),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white),
            ),
          ),
        ],
      ),
      backgroundColor: isError ? const Color(0xFFD32F2F) : const Color(0xFF388E3C), // أحمر غامق أو أخضر غامق
      behavior: SnackBarBehavior.floating, // يجعله يطفو فوق المحتوى
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: const EdgeInsets.all(12),
      duration: const Duration(seconds: 4),
    ),
  );
}