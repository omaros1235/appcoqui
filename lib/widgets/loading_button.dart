import 'package:flutter/material.dart';

class LoadingButton extends StatelessWidget {
  const LoadingButton({
    super.key,
    required this.texto,
    required this.onPressed,
    required this.isLoading,
    this.icono,
  });

  final String texto;
  final VoidCallback? onPressed;
  final bool isLoading;
  final IconData? icono;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: FilledButton.icon(
        onPressed: isLoading ? null : onPressed,
        icon: isLoading
            ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : icono != null
                ? Icon(icono)
                : const SizedBox.shrink(),
        label: Text(
          texto,
          style: const TextStyle(fontWeight: FontWeight.w800),
        ),
        style: FilledButton.styleFrom(
          backgroundColor: const Color(0xFFC63D2F),
          foregroundColor: Colors.white,
        ),
      ),
    );
  }
}
