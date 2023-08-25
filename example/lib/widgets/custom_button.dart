import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final void Function()? onPressed;
  final bool enabled;
  const CustomButton({Key? key, required this.text, required this.onPressed, this.enabled = true}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: SizedBox(
        width: double.infinity,
        height: 50,
        child: ElevatedButton(
          onPressed: enabled ? onPressed : null,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(text, style: const TextStyle(fontSize: 20)),
              if (!enabled) const CircularProgressIndicator(),
            ],
          ),
        ),
      ),
    );
  }
}
