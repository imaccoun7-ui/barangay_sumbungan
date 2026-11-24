import 'package:flutter/material.dart';

import 'app.dart';
import 'providers/app_state.dart';
import 'services/backend/firebase_backend.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  final AppState state = AppState(backend: FirebaseBackend());
  state.bootstrap();
  runApp(BarangaySumbunganApp(state: state));
}
