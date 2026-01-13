import 'package:flutter/material.dart';
import 'package:quiz_app/utils/color.dart';

class CustomDropdown extends StatefulWidget {
  final String? value;
  final List<String> items;
  final String hintText;
  final String? Function(String?)? validator;
  final bool autoValidate;
  final void Function(String?)? onChanged;
  final double? menuMaxHeight;
  final bool enabled; // New enabled property

  const CustomDropdown({
    super.key,
    required this.value,
    required this.items,
    required this.hintText,
    this.validator,
    this.autoValidate = false,
    required this.onChanged,
    this.menuMaxHeight,
    this.enabled = true, // Default to enabled
  });

  @override
  State<CustomDropdown> createState() => _CustomDropdownState();
}

class _CustomDropdownState extends State<CustomDropdown> {


  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: widget.enabled ? AppColors.white : AppColors.disabledBackground,
        borderRadius: BorderRadius.circular(12),
        boxShadow: widget.enabled
            ? [
                BoxShadow(
                  color: AppColors.secondary.withValues(alpha: 0.1),
                  spreadRadius: 1,
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ]
            : [],
      ),
      child: DropdownButtonFormField<String>(
        autovalidateMode: widget.autoValidate
            ? AutovalidateMode.onUserInteraction
            : AutovalidateMode.disabled,
        decoration: InputDecoration(
          hintText: widget.hintText,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: widget.enabled ? AppColors.primary : AppColors.textDisabled,
              width: 2,
            ),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(
              color: AppColors.error,
              width: 2,
            ),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(
              color: AppColors.error,
              width: 2,
            ),
          ),
          filled: true,
          fillColor: widget.enabled ? AppColors.white : AppColors.disabledBackground,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
          hintStyle: TextStyle(
            color: widget.enabled ? AppColors.textSecondary : AppColors.textDisabled,
            fontWeight: FontWeight.w400,
          ),
        ),
        initialValue: widget.value, // Explicitly pass value to make it controlled
        isExpanded: true,
        icon: Icon(
          Icons.keyboard_arrow_down_rounded,
          color: widget.enabled ? AppColors.textSecondary : AppColors.textDisabled,
          size: 24,
        ),
        iconSize: 24,
        elevation: 2,
        dropdownColor: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        menuMaxHeight: widget.menuMaxHeight ?? 300,
        style: TextStyle(
          color: widget.enabled ? AppColors.textPrimary : AppColors.textDisabled,
          fontSize: 16,
        ),
        items: widget.items.map((item) {
          final isSelected = widget.value == item;
          return DropdownMenuItem<String>(
            value: item,
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    item,
                    style: TextStyle(
                      color: isSelected
                          ? AppColors.primary
                          : (widget.enabled ? AppColors.textPrimary : AppColors.textDisabled),
                      fontWeight: isSelected
                          ? FontWeight.w600
                          : FontWeight.w400,
                    ),
                  ),
                ),
                if (isSelected && widget.enabled) ...[
                  const SizedBox(width: 8),
                  Icon(
                    Icons.check_rounded,
                    color: AppColors.primary,
                    size: 18,
                  ),
                ],
              ],
            ),
          );
        }).toList(),
        onChanged: widget.enabled ? widget.onChanged : null, // Disable when not enabled
        validator: widget.validator,
        onTap: null,
        selectedItemBuilder: (BuildContext context) {
          return widget.items.map<Widget>((String item) {
            return Text(
              item,
              style: TextStyle(
                color: widget.enabled ? AppColors.textPrimary : AppColors.textDisabled,
                fontSize: 16,
              ),
            );
          }).toList();
        },
      ),
    );
  }
}
