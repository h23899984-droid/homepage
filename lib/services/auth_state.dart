class AuthState {
  static AuthState _instance = AuthState._internal();
  factory AuthState() => _instance;
  AuthState._internal();

  Map<String, dynamic>? _currentUser;

  Map<String, dynamic>? get currentUser => _currentUser;
  bool get isLoggedIn => _currentUser != null;
  String? get userId => _currentUser?['id'];
  String? get userName => _currentUser?['name'];

  void setUser(Map<String, dynamic> user) {
    _currentUser = user;
  }

  void clearUser() {
    _currentUser = null;
  }
}

final authState = AuthState();
