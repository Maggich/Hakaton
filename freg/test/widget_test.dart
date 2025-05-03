import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:freg/main.dart';  // Убедитесь, что этот путь правильный

void main() {
  testWidgets('Login tab renders all elements', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: LoginSignupScreen()));

    // Убедимся, что мы на вкладке "Ingresa"
    expect(find.text('Ingresa'), findsOneWidget);
    expect(find.text('Registrate'), findsOneWidget);

    // Email и парольные поля (2 TextField)
    expect(find.byType(TextField), findsNWidgets(2));

    // Кнопка "Ingresar"
    expect(find.text('Ingresar'), findsOneWidget);
  });

  testWidgets('Password visibility toggle works', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: LoginSignupScreen()));

    // Проверяем иконку скрытого пароля
    expect(find.byIcon(Icons.visibility_off), findsOneWidget);

    // Нажимаем на иконку
    await tester.tap(find.byIcon(Icons.visibility_off));
    await tester.pump();

    // Проверяем, что иконка поменялась
    expect(find.byIcon(Icons.visibility), findsOneWidget);
  });

  testWidgets('Text fields accept input', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: LoginSignupScreen()));

    const testEmail = 'test@example.com';
    const testPassword = 'securepassword123';

    // Вводим email и пароль
    await tester.enterText(find.byType(TextField).at(0), testEmail);
    await tester.enterText(find.byType(TextField).at(1), testPassword);

    // Проверяем отображение email
    expect(find.text(testEmail), findsOneWidget);

    // Пароль скрыт — не должен отображаться напрямую
    expect(find.text(testPassword), findsNothing);

    // Показываем пароль
    await tester.tap(find.byIcon(Icons.visibility_off));
    await tester.pump();

    // Теперь пароль должен быть виден
    expect(find.text(testPassword), findsOneWidget);
  });

  testWidgets('Ingresar button is tappable', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: LoginSignupScreen()));

    // Проверяем, что кнопка "Ingresar" есть
    expect(find.text('Ingresar'), findsOneWidget);

    // Нажимаем на кнопку (пока просто проверяем, что нажатие не ломает экран)
    await tester.tap(find.text('Ingresar'));
    await tester.pump();

    // Можно добавить здесь проверку SnackBar или другого действия (если появится)
  });
}
