import 'package:flutter/material.dart';

class SearchField extends StatelessWidget {
  const SearchField({
    super.key,
    required this.onChanged,
    this.onFilterTap,
    this.isFilterActive = false,
    this.hintText = 'Ketik sesuatu',
  });

  final ValueChanged<String> onChanged;
  final VoidCallback? onFilterTap;
  final bool isFilterActive;
  final String hintText;

  @override
  Widget build(BuildContext context) {
    return TextField(
      onChanged: onChanged,
      decoration: InputDecoration(
        hintText: hintText,
        prefixIcon: const Icon(Icons.search),
        suffixIcon: IconButton(
          onPressed: onFilterTap,
          icon: Icon(
            Icons.tune,
            color: isFilterActive
                ? Theme.of(context).colorScheme.primary
                : null,
          ),
        ),
      ),
    );
  }
}
