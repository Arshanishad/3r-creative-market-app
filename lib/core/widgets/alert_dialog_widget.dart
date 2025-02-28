import 'package:flutter/material.dart';
import '../../theme/palette.dart';
import '../globals.dart';
import 'customtext_widget.dart';

customAlertBox(
    {required BuildContext context,
      required String title,
      required String content,
      required Function yes}) {
  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(w * 0.03),
        ),
        title: CustomTextWidget(
          text: title,
          weight: FontWeight.w500,
          fontSizeMultiplier: 0.04,
        ),
        content: CustomTextWidget(
          text: content,
          fontSizeMultiplier: 0.036,
        ),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                padding: EdgeInsets.zero,
                visualDensity: VisualDensity.compact,
                elevation: 0,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(w * 0.015)),
                side: const BorderSide(color: Palette.primaryColor)),
            onPressed: () {
              Navigator.pop(context);
            },
            child: const CustomTextWidget(text: "No",color: Palette.primaryColor,),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: Palette.primaryColor,
                padding: EdgeInsets.zero,
                visualDensity: VisualDensity.compact,
                elevation: 0,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(w * 0.015)),
                side: const BorderSide(color: Palette.primaryColor)),
            onPressed: () {
              yes();
            },
            child: const CustomTextWidget(text: "Yes",color: Colors.white,),
          ),
        ],
      );
    },
  );
}