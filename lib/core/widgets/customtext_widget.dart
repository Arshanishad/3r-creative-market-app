import 'package:flutter/cupertino.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/palette.dart';
import '../globals.dart';

class CustomTextWidget extends StatelessWidget {
  final String text;
  final double fontSizeMultiplier;
  final double fontHeight;
  final double letterSpacing;
  final Color color;
  final FontWeight weight;
  final TextAlign align;
  final TextOverflow? overFlow;
  final TextDecoration? underline;
  final int? maxLines;

  const CustomTextWidget({
    super.key,
    required this.text,
    this.fontSizeMultiplier = 0.033,
    this.fontHeight = 1.25,
    this.letterSpacing = 0,
    this.color = Palette.blackColor,
    this.weight = FontWeight.w400,
    this.align = TextAlign.start,
    this.overFlow,
    this.underline,
    this.maxLines,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      textAlign: align,
      overflow: overFlow,
      maxLines: maxLines,
      style: GoogleFonts.roboto(
          letterSpacing: letterSpacing,
          color: color,
          fontSize: w * fontSizeMultiplier,
          height: fontHeight,
          fontWeight: weight,
          decoration: underline),
    );
  }
}