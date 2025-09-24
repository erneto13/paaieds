import 'package:flutter/material.dart';

class PrimaryButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final bool isOutlined;

  const PrimaryButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.isOutlined = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: isOutlined
          ? OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0),
          ),
          side: const BorderSide(color: Colors.white, width: 2),
        ),
        child: Text(text, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      )
          : ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0),
          ),
        ),
        child: Text(text, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      ),
    );
  }
}