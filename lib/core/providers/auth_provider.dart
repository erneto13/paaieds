import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:paaieds/core/models/user.dart';
import 'package:paaieds/core/services/auth_service.dart';
import 'package:paaieds/core/services/user_service.dart';

//provider para manejar todo lo relacionado con autenticacion
class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  final UserService _userService = UserService();

  UserModel? _currentUser;
  // ignore: unused_field
  bool _isLoading = true;
  final bool _isAuthLoading = false; //para operaciones como login/register
  String? _errorMessage;

  UserModel? get currentUser => _currentUser;
  bool get isLoading => _isAuthLoading; //para operaciones de auth
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _currentUser != null;

  AuthProvider() {
    _initAuthListener();
  }

  //escucha cambios en el estado de autenticacion de firebase
  void _initAuthListener() {
    _authService.authStateChanges.listen((User? firebaseUser) async {
      if (firebaseUser != null) {
        await _loadUserData(firebaseUser.uid);
      } else {
        _currentUser = null;
        notifyListeners();
      }
    });
  }

  //carga los datos del usuario desde firestore
  Future<void> _loadUserData(String uid) async {
    try {
      final user = await _userService.getCurrentUser();
      _currentUser = user;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Error al cargar datos del usuario: $e';
      notifyListeners();
    }
  }

  //registro con email
  Future<bool> registerWithEmail({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final userModel = await _authService.registerWithEmail(
        email: email,
        password: password,
        firstName: firstName,
        lastName: lastName,
      );

      _currentUser = userModel;
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  //inicio de sesion con email
  Future<bool> signInWithEmail({
    required String email,
    required String password,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final userModel = await _authService.signInWithEmail(
        email: email,
        password: password,
      );

      _currentUser = userModel;
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  //cerrar sesion
  Future<void> signOut() async {
    _isLoading = true;
    notifyListeners();

    try {
      await _authService.signOut();
      _currentUser = null;
      _errorMessage = null;
    } catch (e) {
      _errorMessage = 'Error al cerrar sesión: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  //restablecer contraseña
  Future<Map<String, dynamic>> resetPassword(String email) async {
    return await _authService.resetPassword(email);
  }

  //actualizar perfil del usuario
  Future<bool> updateProfile({
    String? firstName,
    String? lastName,
    dynamic profileImage,
  }) async {
    if (_currentUser == null) return false;

    _isLoading = true;
    notifyListeners();

    try {
      final updatedUser = await _userService.updateUserProfile(
        uid: _currentUser!.uid,
        firstName: firstName,
        lastName: lastName,
        profileImage: profileImage,
      );

      if (updatedUser != null) {
        _currentUser = updatedUser;
        _isLoading = false;
        notifyListeners();
        return true;
      }

      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = 'Error al actualizar perfil: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  //cambiar contraseña
  Future<bool> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      final success = await _userService.changePassword(
        currentPassword: currentPassword,
        newPassword: newPassword,
      );

      _isLoading = false;
      notifyListeners();
      return success;
    } catch (e) {
      _errorMessage = 'Error al cambiar contraseña: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  //limpiar mensajes de error
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
