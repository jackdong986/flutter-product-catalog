#!/usr/bin/env sh
set -eu
command -v flutter >/dev/null 2>&1 || { echo "Flutter is not available in PATH."; exit 1; }
flutter create . --project-name product_catalog --platforms=android,ios
flutter pub get
echo "Project is ready. Run: flutter analyze && flutter test && flutter run"
