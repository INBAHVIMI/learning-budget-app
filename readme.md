# Learning Budget App

Local-first Learning and Budget app scaffold for a full year plan, with INR formatting and OneDrive encrypted sync hooks.

## Current Features

- Year dashboard with 12-month budget summaries
- Budget tab (income, expense, savings snapshots)
- Learning tab (monthly task completion tracking)
- Insights tab (auto-generated highlights)
- Settings tab with OneDrive encrypted sync action (service stub)

## Tech Stack

- Flutter (single codebase for Web + Android + iOS)
- Dart models/services (local-first architecture)
- INR formatting via intl package

## Quick Start (Windows)

1. Install Flutter SDK and add it to PATH.
2. In this repository root, run:

```bash
flutter create .
flutter pub get
flutter run -d chrome
```

For Android, run:

```bash
flutter run -d android
```

For iOS (from macOS only), run:

```bash
flutter run -d ios
```

## Project Structure

- lib/main.dart: app entrypoint
- lib/app.dart: navigation shell and app wiring
- lib/core/models.dart: year/month domain models + INR formatter
- lib/core/services/local_store_service.dart: local-first storage boundary
- lib/core/services/onedrive_sync_service.dart: OneDrive sync boundary
- lib/features/*: feature screens (Year, Budget, Learning, Insights, Settings)

## Next Steps to Complete

1. Implement persistent local database (SQLite/mobile + local storage/web).
2. Add Microsoft identity login and Graph API integration.
3. Encrypt/decrypt sync payload before upload/download.
4. Add conflict resolution for local-vs-cloud updates.
5. Add charts and transaction CRUD workflows.
