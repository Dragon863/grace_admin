import 'package:supabase_flutter/supabase_flutter.dart';

import 'constants.dart';
import 'package:flutter/widgets.dart';

enum AccountStatus {
  uninitialized,
  authenticated,
  unauthenticated,
}

class AuthAPI extends ChangeNotifier {
  late SupabaseClient _currentUser;

  AccountStatus _status = AccountStatus.uninitialized;

  SupabaseClient get currentUser => _currentUser;
  AccountStatus get status => _status;
  SupabaseClient get client => Supabase.instance.client;

  AuthAPI() {
    init();
  }

  init() async {
    await Supabase.initialize(
      url: projectUrl,
      anonKey: anonKey,
    );
  }

  Future<User?> createUser(
      {required String email, required String password}) async {
    await client.auth.signUp(
      email: email,
      password: password,
    );
    notifyListeners();

    return client.auth.currentUser;
  }

  Future<bool> loginAsAdmin({required String serviceKey}) async {
    try {
      final supabaseAdmin = SupabaseClient(
        projectUrl,
        serviceKey,
      );

      _status = AccountStatus.authenticated;
      _currentUser = supabaseAdmin;
      return true;
    } catch (e) {
      print(e);
      _status = AccountStatus.unauthenticated;
      return false;
    } finally {
      notifyListeners();
    }
  }

  String getImgUrl(String fileName, String folder) {
    final response =
        client.storage.from('images').getPublicUrl("$folder/$fileName");
    return response.toString();
  }

  signOut() async {
    try {
      await _currentUser.auth.signOut();
      _status = AccountStatus.unauthenticated;
    } finally {
      notifyListeners();
    }
  }

  Future<List<List<String>>> getAllUsers() async {
    final List<User> response = await _currentUser.auth.admin.listUsers();
    /*return response
        .map((e) =>
            (e.userMetadata!['display_name'] ?? "Unknown User").toString())
        .toList();*/ // Just returns list of users' names, we want [name, UUID]
    return response
        .map((e) => [
              (e.userMetadata!['display_name'] ?? "Unknown User").toString(),
              e.id.toString()
            ])
        .toList();
  }

  Future<String?> fetchUserIDByName(String name) async {
    final List<User> response = await _currentUser.auth.admin.listUsers();
    for (var user in response) {
      if (user.userMetadata!['display_name'] == name) {
        return user.id.toString();
      }
    }
    return null;
  }
}
