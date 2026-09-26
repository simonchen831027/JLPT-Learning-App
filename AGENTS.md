# Repository Guidelines

## Language

- 使用繁體中文回覆與撰寫說明文件。
- 程式碼識別字、API 名稱與必要的技術術語保留原文。

## Project Structure & Module Organization

The repository currently contains `JLPT_Learning_App_Technical_Spec_V2.3.md`, the project’s technical specification. It describes the planned Flutter/Dart client, ASP.NET Core backend and AI gateway, Python content pipeline, SQLite local storage, and later PostgreSQL support. When implementation begins, keep code organized by feature and layer as described in the spec (for example, `lib/features/` and `lib/core/`); keep backend, data-pipeline, and test files grouped with their respective components.

## Build, Test, and Development Commands

There is no build or test configuration in the current repository, so no project commands are available yet. Once the corresponding projects exist, use their standard tools: `dart format .` and `flutter analyze` for Flutter formatting and static analysis, `flutter test` for Dart tests, `dotnet test` for .NET tests, and `pytest` for Python tests. Run commands from the relevant project directory.

## Coding Style & Naming Conventions

Follow the technical spec’s feature-first, MVVM, use-case, repository, and service boundaries. Keep UI code independent of direct database, provider, or platform API calls. Use idiomatic conventions for each language: Dart files and identifiers in `lower_snake_case` / `UpperCamelCase` / `lowerCamelCase`; C# types and public members in `UpperCamelCase`; Python modules in `lower_snake_case`. Format with the language’s standard formatter.

## Testing Guidelines

The spec identifies `flutter test` and `integration_test/` for Flutter, xUnit for .NET, and pytest for Python. Cover use cases, migrations, errors, and offline behavior. No tests or coverage threshold are configured in this repository yet; run the relevant suite and formatter/analyzer before submitting implementation changes.

## Commit & Pull Request Guidelines

The only existing commit uses the subject `docs: add V2.3 technical specification`; the spec recommends Conventional Commit prefixes such as `feat:`, `fix:`, `refactor:`, `test:`, `docs:`, and `chore:`. Keep subjects concise and scoped. Pull requests should explain the change and verification, link issues, and include UI screenshots. Call out schema migrations, privacy or permission effects, and any deferred decisions.

## Security & Configuration

Never include API keys or provider secrets in the Flutter app or repository. Keep secrets in local environment configuration or an approved secret store, and route AI requests through the backend gateway as specified. Avoid committing user learning data or other sensitive content.

