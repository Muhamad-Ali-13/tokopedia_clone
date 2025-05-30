import 'package:flutter/material.dart';

class Utils {
  static const Color mainThemeColor = Colors.green;

  static bool validateEmail(String? value) {
    String pattern = r"^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?)*$";
    RegExp regex = RegExp(pattern);
    return value != null && value.isNotEmpty && regex.hasMatch(value);
  }

  static Widget generateInputField(
    String hintText,
    IconData iconData,
    TextEditingController controller,
    bool isPasswordField,
    Function onChanged,
  ) {
    return Container(
      padding: const EdgeInsets.all(5),
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.grey.withOpacity(0.2),
        borderRadius: BorderRadius.circular(50),
      ),
      child: TextField(
        onChanged: (text) => onChanged(text),
        obscureText: isPasswordField,
        obscuringCharacter: "*",
        decoration: InputDecoration(
          prefixIcon: Icon(iconData, color: mainThemeColor),
          border: InputBorder.none,
          focusedBorder: InputBorder.none,
          enabledBorder: InputBorder.none,
          errorBorder: InputBorder.none,
          disabledBorder: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 15, vertical: 11),
          hintText: hintText,
        ),
        controller: controller,
        style: const TextStyle(fontSize: 16),
      ),
    );
  }
}