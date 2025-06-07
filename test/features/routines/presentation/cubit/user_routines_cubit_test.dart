// FILE: test/features/routines/presentation/cubit/user_routines_cubit_test.dart

import 'package:bloc_test/bloc_test.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb_auth;
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:muscle_up/core/domain/entities/routine.dart';
import 'package:muscle_up/core/domain/repositories/routine_repository.dart';
import 'package:muscle_up/features/routines/presentation/cubit/user_routines_cubit.dart';

// --- Mocks ---
// Створюємо мок-класи для залежностей, щоб ізолювати наш Cubit під час тестування.
// Це дозволяє нам контролювати, що повертають залежності, і перевіряти, чи були викликані їхні методи.

class MockRoutineRepository extends Mock implements RoutineRepository {}
class MockFirebaseAuth extends Mock implements fb_auth.FirebaseAuth {}
class MockUser extends Mock implements fb_auth.User {}

void main() {
  // Групуємо всі тести, що стосуються UserRoutinesCubit.
  group('UserRoutinesCubit', () {
    // --- Setup Variables ---
    // Оголошуємо змінні, які будуть використовуватися в тестах.
    // 'late' означає, що ми ініціалізуємо їх у функції setUp.
    late UserRoutinesCubit userRoutinesCubit;
    late MockRoutineRepository mockRoutineRepository;
    late MockFirebaseAuth mockFirebaseAuth;
    late MockUser mockUser;

    // --- Test Data ---
    // Створюємо тестові дані для консистентності тестів.
    const tUserId = 'test_user_id';
    final tRoutine = UserRoutine(
      id: 'routine1',
      userId: tUserId,
      name: 'My Test Routine',
      exercises: const [],
      scheduledDays: const ['MON'],
      isPublic: false,
      createdAt: Timestamp.now(),
      updatedAt: Timestamp.now(),
    );
    final tRoutine2 = UserRoutine(
      id: 'routine2',
      userId: tUserId,
      name: 'Another Routine',
      exercises: const [],
      scheduledDays: const ['WED', 'FRI'],
      isPublic: false,
      createdAt: Timestamp.now(),
      updatedAt: Timestamp.now(),
    );

    // --- setUp & tearDown ---
    // setUp виконується перед кожним тестом. Тут ми ініціалізуємо наші моки та сам Cubit.
    setUp(() {
      mockRoutineRepository = MockRoutineRepository();
      mockFirebaseAuth = MockFirebaseAuth();
      mockUser = MockUser();

      // Імітуємо поведінку, ніби користувач увійшов у систему.
      when(() => mockUser.uid).thenReturn(tUserId);
      when(() => mockFirebaseAuth.currentUser).thenReturn(mockUser);

      // Створюємо екземпляр Cubit з мок-залежностями.
      userRoutinesCubit = UserRoutinesCubit(mockRoutineRepository, mockFirebaseAuth);
    });

    // tearDown виконується після кожного тесту. Тут ми закриваємо Cubit, щоб уникнути витоків пам'яті.
    tearDown(() {
      userRoutinesCubit.close();
    });

    // --- Test Cases ---

    test('початковий стан має бути UserRoutinesInitial', () {
      // Assert: Перевіряємо, що початковий стан кубіта є `UserRoutinesInitial`.
      expect(userRoutinesCubit.state, isA<UserRoutinesInitial>());
    });

    // Використовуємо blocTest для тестування послідовності станів (state transitions).
    blocTest<UserRoutinesCubit, UserRoutinesState>(
      'випромінює [UserRoutinesLoading, UserRoutinesLoaded] при успішному завантаженні програм',
      // Arrange: Налаштовуємо мок-репозиторій, щоб він повертав список програм при виклику.
      setUp: () {
        when(() => mockRoutineRepository.getUserRoutines(any()))
            .thenAnswer((_) async => [tRoutine]);
      },
      // Build: Створюємо Cubit для цього конкретного тесту.
      build: () => userRoutinesCubit,
      // Act: Виконуємо дію, яку тестуємо – викликаємо метод fetchUserRoutines.
      act: (cubit) => cubit.fetchUserRoutines(),
      // Expect: Перевіряємо, що Cubit випромінює очікувану послідовність станів.
      expect: () => <UserRoutinesState>[
        const UserRoutinesLoading(routines: []), // Спочатку стан завантаження
        UserRoutinesLoaded([tRoutine]), // Потім стан успішного завантаження з даними
      ],
      // Verify: Переконуємось, що метод репозиторію був викликаний рівно один раз.
      verify: (_) {
        verify(() => mockRoutineRepository.getUserRoutines(tUserId)).called(1);
      },
    );

    blocTest<UserRoutinesCubit, UserRoutinesState>(
      'випромінює [UserRoutinesLoading, UserRoutinesLoaded з порожнім списком] коли програм немає',
      setUp: () {
        when(() => mockRoutineRepository.getUserRoutines(any()))
            .thenAnswer((_) async => []);
      },
      build: () => userRoutinesCubit,
      act: (cubit) => cubit.fetchUserRoutines(),
      expect: () => const <UserRoutinesState>[
        UserRoutinesLoading(routines: []),
        UserRoutinesLoaded([]), // Очікуємо стан з порожнім списком
      ],
    );

    blocTest<UserRoutinesCubit, UserRoutinesState>(
      'випромінює [UserRoutinesLoading, UserRoutinesError] при помилці завантаження',
      setUp: () {
        // Arrange: Налаштовуємо мок так, щоб він кидав виняток.
        when(() => mockRoutineRepository.getUserRoutines(any()))
            .thenThrow(Exception('Failed to fetch'));
      },
      build: () => userRoutinesCubit,
      act: (cubit) => cubit.fetchUserRoutines(),
      expect: () => const <UserRoutinesState>[
        UserRoutinesLoading(routines: []),
        UserRoutinesError('Failed to fetch'), // Очікуємо стан помилки
      ],
    );

    blocTest<UserRoutinesCubit, UserRoutinesState>(
      'випромінює [UserRoutinesError] якщо користувач не автентифікований',
      setUp: () {
        // Arrange: Імітуємо ситуацію, коли користувач не увійшов.
        when(() => mockFirebaseAuth.currentUser).thenReturn(null);
      },
      // Build: Створюємо новий екземпляр кубіта з оновленою мок-поведінкою.
      build: () => UserRoutinesCubit(mockRoutineRepository, mockFirebaseAuth),
      act: (cubit) => cubit.fetchUserRoutines(),
      expect: () => const <UserRoutinesState>[
        UserRoutinesError('User not logged in. Cannot fetch routines.'),
      ],
      // Verify: Переконуємось, що репозиторій не викликався, бо перевірка на userId не пройшла.
      verify: (_) {
        verifyNever(() => mockRoutineRepository.getUserRoutines(any()));
      },
    );

    blocTest<UserRoutinesCubit, UserRoutinesState>(
      'оптимістично видаляє програму зі стану при виклику routineDeleted',
      // Seed: Встановлюємо початковий стан, ніби дані вже завантажені.
      seed: () => UserRoutinesLoaded([tRoutine, tRoutine2]),
      build: () => userRoutinesCubit,
      // Act: Викликаємо метод для локального видалення.
      act: (cubit) => cubit.routineDeleted(tRoutine.id),
      // Expect: Очікуємо, що Cubit випромінить новий стан UserRoutinesLoaded з оновленим списком.
      expect: () => <UserRoutinesState>[
        UserRoutinesLoaded([tRoutine2]),
      ],
    );
  });
}