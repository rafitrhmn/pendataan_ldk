// lib/widgets/circular_icon_button.dart

import 'package:flutter/material.dart';

class CircularIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;
  final String tooltip; // Tambahan agar ada tooltip seperti IconButton

  const CircularIconButton({
    super.key,
    required this.icon,
    required this.onPressed,
    this.tooltip = '',
  });

  @override
  Widget build(BuildContext context) {
    // Logika dari method _buildCircularIconButton dipindahkan ke sini
    return Tooltip(
      message: tooltip,
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onPressed,
        child: Container(
          padding: const EdgeInsets.all(6), // Sedikit penyesuaian padding
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white,
            border: Border.all(color: Colors.grey.shade300, width: 1.5),
          ),
          child: Icon(icon, size: 20, color: Colors.grey.shade700),
        ),
      ),
    );
  }
}
