enum UserRole {
  user('user'),
  admin('admin');

  const UserRole(this.value);
  final String value;

  static UserRole fromString(String value) {
    switch (value.toLowerCase()) {
      case 'admin':
        return UserRole.admin;
      case 'user':
      default:
        return UserRole.user;
    }
  }
}