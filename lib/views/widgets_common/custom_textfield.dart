import 'package:e_comapp/consts/consts.dart';
import 'package:flutter/material.dart';

Widget customTextField({
  String? title,
  String? hint,
  required TextEditingController controller,
  bool isPass = false,
  String? Function(String?)? validator, // Added validator parameter
}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start, // Aligning text to the left
    children: [
      if (title != null) // Null safety check for title
        title.text.color(redColor).fontFamily(semibold).size(16).make(),
      5.heightBox, // Spacer between the label and the text field
      TextFormField(
        obscureText: isPass,
        controller: controller,
        validator: validator, // Pass validator function here
        decoration: InputDecoration(
          hintStyle: TextStyle(
            fontFamily: semibold,
            color:
                textfieldGrey, // Assuming textfieldGrey is a valid color constant
          ),
          hintText: hint,
          isDense: true,
          fillColor: lightGrey, // Assuming lightGrey is a valid color constant
          filled: true,
          border: InputBorder.none,
          focusedBorder: const OutlineInputBorder(
            borderSide: BorderSide(color: redColor), // Corrected color
          ),
        ),
      ),
      5.heightBox,
    ],
  );
}
