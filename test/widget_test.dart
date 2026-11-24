import 'package:barangay_sumbungan/app.dart';
import 'package:barangay_sumbungan/core/routes/app_routes.dart';
import 'package:barangay_sumbungan/providers/app_state.dart';
import 'package:barangay_sumbungan/screens/admin/admin_home_screen.dart';
import 'package:barangay_sumbungan/screens/authentication/login_screen.dart';
import 'package:barangay_sumbungan/screens/resident/resident_shell.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<AppState> _buildState({String? sessionUserId}) async {
  SharedPreferences.setMockInitialValues(<String, Object>{
    if (sessionUserId != null)
      'barangay_sumbungan_session_user': sessionUserId,
    'barangay_sumbungan_onboarding_seen': true,
  });
  final AppState state = AppState();
  await state.bootstrap();
  return state;
}

void main() {
  testWidgets('signed-out launch shows the sign-in screen', (WidgetTester tester) async {
    final AppState state = await _buildState();
    await tester.pumpWidget(BarangaySumbunganApp(state: state));
    await tester.pumpAndSettle();

    expect(find.byType(LoginScreen), findsOneWidget);
    expect(find.text('Welcome Back'), findsOneWidget);

    await tester.tap(find.text('Sign in').last);
    await tester.pumpAndSettle();
    expect(find.text('Email is required.'), findsOneWidget);
    expect(find.text('Password is required.'), findsOneWidget);
  });

  testWidgets('restored resident session opens the resident dashboard',
      (WidgetTester tester) async {
    final AppState state = await _buildState(sessionUserId: 'u_maria');
    await tester.pumpWidget(BarangaySumbunganApp(state: state));
    await tester.pumpAndSettle();

    expect(find.byType(ResidentShell), findsOneWidget);
    expect(find.text('Maria!'), findsOneWidget);
    expect(find.text('What do you need?'), findsOneWidget);
    expect(find.text('Submit Report'), findsOneWidget);
    expect(find.text('Emergency assistance'), findsOneWidget);
  });

  testWidgets('resident cannot open the administrator dashboard',
      (WidgetTester tester) async {
    final AppState state = await _buildState(sessionUserId: 'u_maria');
    await tester.pumpWidget(BarangaySumbunganApp(state: state));
    await tester.pumpAndSettle();

    final NavigatorState navigator = tester
        .state<NavigatorState>(find.byType(Navigator).first);
    navigator.pushNamed(AppRoutes.adminHome);
    await tester.pumpAndSettle();

    expect(find.byType(AdminHomeScreen), findsOneWidget);
    expect(find.text('Restricted'), findsOneWidget);
    expect(find.text('Administrator access required'), findsOneWidget);
  });

  testWidgets('administrator session opens the administrator dashboard',
      (WidgetTester tester) async {
    final AppState state = await _buildState(sessionUserId: 'u_admin');
    await tester.pumpWidget(BarangaySumbunganApp(state: state));
    await tester.pumpAndSettle();

    expect(find.byType(AdminHomeScreen), findsOneWidget);
    expect(find.text('Barangay operations'), findsOneWidget);
    expect(find.text('Registered residents'), findsOneWidget);
  });
}
