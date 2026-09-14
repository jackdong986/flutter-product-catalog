@echo off
setlocal
where flutter >nul 2>nul
if errorlevel 1 (
  echo Flutter is not available in PATH.
  exit /b 1
)
flutter create . --project-name product_catalog --platforms=android,ios
if errorlevel 1 exit /b 1
flutter pub get
if errorlevel 1 exit /b 1
echo.
echo Project is ready. Run: flutter analyze ^&^& flutter test ^&^& flutter run
