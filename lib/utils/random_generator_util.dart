import 'dart:math';
import 'dart:convert';
import 'package:crypto/crypto.dart';

int getRandomRoomId() {
  var rng = Random();
  return 1000000000 +
      rng.nextInt(9000000000); // Generates a random 10 digit number
}

String getRandomRoomPassword() {
  var rng = Random();
  const String upperCaseLetters = "ABCDEFGHIJKLMNOPQRSTUVWXYZ";
  const String lowerCaseLetters = "abcdefghijklmnopqrstuvwxyz";
  const String digits = "0123456789";

  // Ensure at least one upper case, one lower case and one digit character is included.
  String password = upperCaseLetters[rng.nextInt(upperCaseLetters.length)] +
      lowerCaseLetters[rng.nextInt(lowerCaseLetters.length)] +
      digits[rng.nextInt(digits.length)];

  // Complete the password with random characters
  const String allChars = "$upperCaseLetters$lowerCaseLetters$digits";
  password +=
      List.generate(5, (index) => allChars[rng.nextInt(allChars.length)])
          .join();

  // Randomize the order of characters in the password
  password = (password.split('')..shuffle()).join();

  return password;
}

String hashPassword(String password) {
  var bytes = utf8.encode(password); // data being hashed
  var digest = sha256.convert(bytes);
  return digest.toString();
}
