# Ayawe Development Guide

## Getting Started

### Prerequisites
- Flutter SDK >= 3.10.0
- Dart SDK >= 3.0.0
- Android Studio / VS Code with Flutter extensions

### Setup

1. Clone the repository:
```bash
git clone <repository-url>
cd ayawe
```

2. Install dependencies:
```bash
flutter pub get
```

3. Run the application:
```bash
flutter run
```

## Development Workflow

### Feature Development

1. **Create Feature Branch**:
```bash
git checkout -b feature/account-management
```

2. **Implement Feature**:
   - Follow Clean Architecture structure
   - Write tests first (TDD approach preferred)
   - Update documentation

3. **Testing**:
```bash
flutter test
flutter analyze
```

4. **Code Review**:
   - Ensure all tests pass
   - Check code coverage
   - Verify architecture compliance

### Code Quality

#### Linting Rules
Run linting before committing:
```bash
flutter analyze
```

Common issues to fix:
- Use English naming conventions
- Follow Clean Architecture principles
- Handle null safety properly
- Use const constructors where possible

#### Testing Strategy

**Unit Tests**:
```bash
flutter test test/unit/
```

**Widget Tests**:
```bash
flutter test test/widget/
```

**Integration Tests**:
```bash
flutter test test/integration/
```

**Coverage**:
```bash
flutter test --coverage
genhtml coverage/lcov.info -o coverage/html
```

## Architecture Guidelines

### Clean Architecture Rules

1. **Dependency Rule**: Dependencies point inward
2. **Entity Rules**: Business logic only, no framework dependencies
3. **Use Case Rules**: Application-specific business rules
4. **Interface Adapters**: Convert data formats between layers
5. **Frameworks & Drivers**: External interfaces

### Provider Pattern Usage

```dart
// Feature-specific provider
class FeatureProvider extends ChangeNotifier {
  final FeatureUseCase _useCase;
  
  FeatureProvider(this._useCase);
  
  Future<void> loadData() async {
    // Implementation
  }
}

// Main provider orchestrator
class MainProvider extends ChangeNotifier {
  final FeatureProvider _featureProvider;
  
  MainProvider(this._featureProvider);
  
  // Computed properties and coordination
}
```

### Database Operations

```dart
// Repository pattern
abstract class FeatureRepository {
  Future<List<FeatureEntity>> getFeatures();
  Future<void> createFeature(FeatureEntity feature);
}

// Implementation
class FeatureRepositoryImpl implements FeatureRepository {
  final FeatureLocalDataSource _dataSource;
  
  FeatureRepositoryImpl(this._dataSource);
  
  @override
  Future<List<FeatureEntity>> getFeatures() async {
    final models = await _dataSource.getFeatures();
    return models.map((m) => m.toEntity()).toList();
  }
}
```

## Debugging

### Common Issues

1. **Provider Not Found**:
   - Check provider registration in main.dart
   - Verify context access in widget tree

2. **Database Errors**:
   - Check table schemas in database_helper.dart
   - Verify migration scripts

3. **Navigation Issues**:
   - Check route definitions in main.dart
   - Verify screen imports

### Debug Tools

```bash
# Hot reload
flutter run --hot

# Debug mode
flutter run --debug

# Profile mode
flutter run --profile
```

### Logging

Add debug logging:
```dart
import 'package:logger/logger.dart';

final logger = Logger();

// In provider
logger.d('Loading data...');
logger.e('Error: $error');
```

## Performance Optimization

### Provider Optimization

- Use `select` to listen to specific properties
- Avoid unnecessary rebuilds
- Dispose resources properly

### Database Optimization

- Use transactions for bulk operations
- Add indexes for frequently queried columns
- Implement proper caching

### UI Performance

- Use `const` widgets where possible
- Implement lazy loading for large lists
- Optimize image loading

## Testing Best Practices

### Unit Tests

```dart
test('should create account successfully', () async {
  // Arrange
  final mockRepository = MockAccountRepository();
  final useCase = CreateAccountUseCase(mockRepository);
  final account = Account(name: 'Test', type: AccountType.CASH, ...);
  
  // Act
  final result = await useCase(account);
  
  // Assert
  expect(result, greaterThan(0));
  verify(mockRepository.createAccount(account)).called(1);
});
```

### Widget Tests

```dart
testWidgets('account form validates input', (tester) async {
  // Arrange
  await tester.pumpWidget(MaterialApp(home: AddAccountScreen()));
  
  // Act
  await tester.tap(find.byType(FloatingActionButton));
  await tester.enterText(find.byKey(Key('name_field')), '');
  await tester.tap(find.byType(ElevatedButton));
  
  // Assert
  expect(find.text('Please enter a name'), findsOneWidget);
});
```

## Deployment

### Build Commands

```bash
# Development APK
flutter build apk --debug

# Release APK
flutter build apk --release

# App Bundle
flutter build appbundle --release

# Web
flutter build web
```

### Release Checklist

- [ ] All tests pass
- [ ] Code coverage > 80%
- [ ] Performance benchmarks met
- [ ] Security audit completed
- [ ] Documentation updated
- [ ] Version number updated

## Contributing

### Pull Request Process

1. Create feature branch
2. Implement changes with tests
3. Update documentation
4. Submit pull request
5. Code review
6. Merge to main

### Code Review Checklist

- [ ] Architecture compliance
- [ ] Test coverage
- [ ] Code quality
- [ ] Documentation
- [ ] Performance impact

## Troubleshooting

### Common Build Issues

**Dependency Conflicts**:
```bash
flutter pub deps
flutter pub upgrade --major-versions
```

**Clean Build**:
```bash
flutter clean
flutter pub get
```

**Android Build Issues**:
```bash
cd android
./gradlew clean
cd ..
flutter build apk
```

### IDE Configuration

**VS Code Extensions**:
- Flutter
- Dart
- GitLens
- Better Comments

**Android Studio**:
- Flutter plugin
- Dart plugin
- Android SDK Manager

## Resources

### Documentation
- [Flutter Documentation](https://docs.flutter.dev/)
- [Provider Package](https://pub.dev/packages/provider)
- [Clean Architecture](https://blog.cleancoder.com/uncle-bob-2012-08-13/)

### Tools
- [Flutter Inspector](https://flutter.dev/docs/development/tools/flutter-inspector)
- [Dart DevTools](https://dart.dev/tools/dart-devtools)
- [Flutter Performance](https://flutter.dev/docs/perf)

### Community
- [Flutter Discord](https://discord.gg/flutter)
- [Stack Overflow](https://stackoverflow.com/questions/tagged/flutter)
- [Reddit r/FlutterDev](https://www.reddit.com/r/FlutterDev/)
