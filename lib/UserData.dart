class UserData {
  static String name = "Guest";
  static String email = "";
  static String phone = "";
  // static String token = ""; // Removed API token
  static bool isLoggedIn = false;

  static void setUser({required String name, required String email, String phone = ""}) {
    UserData.name = name;
    UserData.email = email;
    UserData.phone = phone;
    // UserData.token = token;
    UserData.isLoggedIn = true;
  }

  static void clear() {
    name = "Guest";
    email = "";
    phone = "";
    // token = "";
    isLoggedIn = false;
  }
}
