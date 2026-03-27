# run.ps1 — Use this instead of `flutter run`
# Place this in your retailhub project root and run: .\run.ps1

$APK_PATH = "android\app\build\outputs\flutter-apk\app-debug.apk"

Write-Host "Building..." -ForegroundColor Cyan
flutter build apk --debug

if (Test-Path $APK_PATH) {
    Write-Host "APK found. Launching on emulator..." -ForegroundColor Green
    flutter run --use-application-binary="$APK_PATH"
} else {
    Write-Host "APK not found at expected path." -ForegroundColor Red
}
