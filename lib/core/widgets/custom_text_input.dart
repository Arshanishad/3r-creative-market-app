import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/palette.dart';
import '../globals.dart';

class CustomTextInput extends StatelessWidget {
  final TextEditingController controller;
  final double width;
  final double borderWidth;
  final double height;
  final TextInputType keyboardType;
  final String? Function(String?)? validator;
  final String? Function(String?)? onChanged;
  final String? Function(String?)? onSaved;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final FocusNode? focusNode;
  final VoidCallback? onPrefixIconTap;
  final VoidCallback? onSuffixIconTap;
  final int? maxLines;
  final int? maxLength;
  final int? minLines;
  final TextCapitalization textCapitalization;
  final bool? obscureText;
  final List<TextInputFormatter>? inputFormatters;
  final Color borderColor;
  final double radius;
  final String? label;
  final String? hintText;
  final double fontSizeMultiplier;
  final bool readOnly;
  final bool enabled;

  const CustomTextInput({
    super.key,
    required this.controller,
    this.keyboardType = TextInputType.text,
    this.validator,
    this.prefixIcon,
    this.suffixIcon,
    this.focusNode,
    this.onPrefixIconTap,
    this.onSuffixIconTap,
    this.maxLines,
    this.minLines,
    this.maxLength,
    this.textCapitalization = TextCapitalization.none,
    this.width = 1,
    this.borderWidth = 0.4,
    this.height = 0.13,
    this.onChanged,
    this.obscureText = false,
    this.inputFormatters,
    this.borderColor = Palette.grayColor,
    this.readOnly = false,
    this.radius = 0.03,
    this.label,
    this.hintText,
    this.fontSizeMultiplier = 0.033,
    this.onSaved,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: w * height,
      width: w * width,
      child: TextFormField(
        focusNode: focusNode,
        minLines: minLines,
        enabled: enabled,
        maxLength: maxLength,
        readOnly: readOnly,
        style: GoogleFonts.roboto(
            fontSize: w * fontSizeMultiplier, fontWeight: FontWeight.w400),
        obscureText: obscureText ?? false,
        onChanged: onChanged,
        // onSaved: onSaved,
        onFieldSubmitted: onSaved,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        cursorColor: Colors.black,
        keyboardType: keyboardType,
        inputFormatters: inputFormatters,
        validator: validator,
        controller: controller,
        maxLines: maxLines,
        // added maxLines
        textCapitalization: textCapitalization,
        decoration: InputDecoration(
          counterText: "",
          // isDense: true,
          contentPadding:
          EdgeInsets.symmetric(vertical: w * 0.002, horizontal: w * 0.025),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(w * radius),
            borderSide: const BorderSide(color: Colors.red),
          ),
          errorStyle: GoogleFonts.roboto(
              fontWeight: FontWeight.w400,
              color: Colors.red,
              fontSize: w * 0.03),
          hintText: hintText,
          hintStyle: GoogleFonts.roboto(
              fontWeight: FontWeight.w400,
              color:Palette.textGreyColor,
              fontSize: w * fontSizeMultiplier),
          // label: Text(
          //   label ?? "",
          //   style: TextStyle(color: Colors.black, fontSize: w * 0.009),
          // ),
          prefixIcon: prefixIcon != null
              ? InkWell(
            onTap: onPrefixIconTap,
            child: prefixIcon,
          )
              : null,
          suffixIcon: suffixIcon != null
              ? InkWell(
            onTap: onSuffixIconTap,
            child: suffixIcon,
          )
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(w * radius),
            borderSide: BorderSide(color: Palette.primaryColor, width: borderWidth),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(w * radius),
            borderSide: BorderSide(color: borderColor, width: borderWidth),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(w * radius),
            borderSide: BorderSide(color: borderColor, width: borderWidth),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(w * radius),
            borderSide: BorderSide(color: borderColor, width: borderWidth),
          ),
        ),
      ),
    );
  }
}