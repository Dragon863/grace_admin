import 'package:flutter/material.dart';
import 'package:grace_admin/utils/api.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Future<bool> setName(String name, BuildContext context) async {
  try {
    final api = context.read<AuthAPI>();
    await api.client.auth.updateUser(
      UserAttributes(
        data: {'display_name': name},
      ),
    );
    return true;
  } catch (e) {
    return false;
  }
}
