# Ayawe - Clean Architecture Documentation

## Overview

Ayawe is a personal finance management application built with Flutter and Clean Architecture principles. The application helps users manage their money, track expenses, and achieve savings goals in the Burundian context.

## Architecture

### Clean Architecture Layers

```
lib/
├── core/                           # Core utilities and shared components
│   ├── database/                   # Database helper
│   ├── di/                         # Dependency injection
│   └── ...
├── features/                       # Feature-based modules
│   ├── accounts/                   # Account management
│   │   ├── domain/
│   │   │   ├── entities/          # Account entity
│   │   │   ├── repositories/      # Repository interface
│   │   │   └── usecases/          # Business logic
│   │   ├── data/
│   │   │   ├── models/             # Data models
│   │   │   ├── datasources/        # Data sources
│   │   │   └── repositories/      # Repository implementations
│   │   └── presentation/
│   │       ├── providers/         # State management
│   │       └── screens/           # UI screens
│   ├── transactions/              # Transaction management
│   ├── categories/                # Category management
│   ├── goals/                     # Savings goals
│   └── home/                      # Dashboard
└── presentation/                   # Shared presentation components
    └── providers/                  # Main provider orchestrator
```

### Data Flow

1. **Presentation Layer** → **Use Cases** → **Repository Interface** → **Data Layer**
2. **Entities** contain business rules and are independent of frameworks
3. **Use Cases** orchestrate data flow between entities and repositories
4. **Repositories** abstract data sources (database, API, etc.)
5. **Data Sources** handle concrete data implementations

## Features

### Accounts Management
- **Account Types**: Cash, Mobile Money (Lumicash/Econet), Bank
- **Currencies**: BIF, USD
- **Operations**: Create, Read, Update, Delete accounts
- **Balance Tracking**: Real-time balance updates

### Transaction Management
- **Transaction Types**: Income, Expenses
- **Categories**: Predefined categories for Burundian context
- **Operations**: Add, view, delete transactions
- **Date Tracking**: Transaction dates and descriptions

### Goals Management
- **Savings Goals**: Set and track financial goals
- **Progress Tracking**: Visual progress indicators
- **Deadline Management**: Goal deadlines and reminders
- **Status Tracking**: Achieved, in-progress, overdue goals

### Dashboard
- **Total Balance**: Combined balance across all accounts
- **Financial Summary**: Income vs expenses overview
- **Recent Activity**: Latest transactions and goal progress
- **Quick Actions**: Fast access to common operations

### Statistics (`features/stats`)
- **Cash flow**: Last six calendar months of income vs expenses; **transfers are excluded** from totals to avoid double counting.
- **Category report**: Year selector and expense-category selector; total for the year and per-month bar chart (12 months).
- **Trends**: Month-over-month comparison for expense categories (current vs previous calendar month), with French insight copy and noise thresholds in `StatsAggregator`.
- **Presentation**: `StatsScreen` uses `fl_chart`, `StatsFuturisticCard`, and `StatsProvider` for tab index, selected year, and selected category.
- **Domain**: Pure aggregation in `stats_aggregator.dart` and DTOs in `stats_models.dart` (unit-tested).

## State Management

The application uses Provider pattern with feature-specific providers:

- **AccountProvider**: Manages account state and operations
- **TransactionProvider**: Manages transaction state and operations  
- **GoalProvider**: Manages goals state and operations
- **CategoryProvider**: Manages category state and operations
- **MainProvider**: Orchestrates all providers and provides computed properties
- **StatsProvider**: Statistics UI state (tab, year, category) for the Stats screen

## Database

- **Technology**: SQLite via sqflite package
- **Tables**: accounts, categories, transactions, goals
- **Relationships**: Foreign key constraints maintain data integrity
- **Migrations**: Version-controlled schema updates

## Dependency Injection

Uses GetIt for dependency injection:

```dart
// Core services
sl.registerSingleton<DatabaseHelper>(() => DatabaseHelper());

// Feature providers
sl.registerLazySingleton<AccountProvider>(() => AccountProvider(...));
sl.registerLazySingleton<TransactionProvider>(() => TransactionProvider(...));

// Use cases
sl.registerLazySingleton<GetAccountsUseCase>(() => GetAccountsUseCase(...));
sl.registerLazySingleton<CreateAccountUseCase>(() => CreateAccountUseCase(...));
```

## Testing Strategy

- **Unit Tests**: Test use cases and business logic
- **Widget Tests**: Test UI components in isolation
- **Integration Tests**: Test feature interactions
- **Repository Tests**: Test data layer implementations

## Localization

The application is designed for the Burundian context:
- **Language**: English (nomenclature)
- **Currency**: BIF (Burundian Franc) and USD support
- **Categories**: Context-specific expense categories
- **Payment Methods**: Cash, Mobile Money integration

## Development Guidelines

### Adding New Features

1. **Create Feature Structure**:
   ```
   features/new_feature/
   ├── domain/
   │   ├── entities/
   │   ├── repositories/
   │   └── usecases/
   ├── data/
   │   ├── models/
   │   ├── datasources/
   │   └── repositories/
   └── presentation/
       ├── providers/
       └── screens/
   ```

2. **Implement Layers**:
   - Define entities with business rules
   - Create repository interfaces
   - Implement use cases
   - Build data layer
   - Create UI and state management

3. **Register Dependencies**:
   - Add to dependency injection container
   - Update main.dart providers

### Code Standards

- **Naming**: Use English for all public APIs
- **Architecture**: Follow Clean Architecture principles
- **State Management**: Use Provider pattern
- **Error Handling**: Proper error propagation and user feedback
- **Testing**: Write tests for business logic

## Future Enhancements

- **Charts and Analytics**: Financial visualizations
- **Export Features**: PDF/CSV data export
- **Notifications**: Goal reminders and alerts
- **Cloud Sync**: Data synchronization
- **Budget Planning**: Monthly budget management
- **Reports**: Detailed financial reports

## Contributing

1. Follow the established architecture patterns
2. Write tests for new functionality
3. Update documentation for API changes
4. Ensure code passes all linting rules
5. Test on multiple screen sizes

## License

This project is proprietary software for personal finance management.
