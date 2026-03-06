# MEE App - Сборка APK

## 🚀 Быстрая сборка

### Вариант 1: Использование скрипта (Рекомендуется)

```bash
cd /mnt/okcomputer/output/mee_app
./build_apk.sh
```

### Вариант 2: Ручная сборка

```bash
cd /mnt/okcomputer/output/mee_app

# Очистка
flutter clean

# Установка зависимостей
flutter pub get

# Сборка APK
flutter build apk --release
```

APK будет находиться по пути:
```
build/app/outputs/flutter-apk/app-release.apk
```

---

## 📋 Требования

### Необходимое ПО

| Программа | Минимальная версия | Скачать |
|-----------|-------------------|---------|
| Flutter SDK | 3.0.0 | [flutter.dev](https://flutter.dev/docs/get-started/install) |
| Dart SDK | 3.0.0 | Входит в Flutter |
| Android Studio | 2022.1 | [developer.android.com](https://developer.android.com/studio) |
| Java JDK | 17 | [oracle.com](https://www.oracle.com/java/technologies/downloads/) |

### Проверка окружения

```bash
flutter doctor
```

Должно показать:
- ✅ Flutter (Channel stable, 3.x.x)
- ✅ Android toolchain
- ✅ Android Studio
- ✅ Connected device (или эмулятор)

---

## 🔧 Настройка окружения

### 1. Установка Flutter

**Windows:**
```powershell
# Скачайте с https://flutter.dev/docs/get-started/install/windows
# Распакуйте в C:\flutter
# Добавьте в PATH: C:\flutter\bin
```

**macOS:**
```bash
# Через Homebrew
brew install flutter

# Или скачайте вручную
export PATH="$PATH:/Users/USERNAME/flutter/bin"
```

**Linux:**
```bash
# Скачайте и распакуйте
sudo tar xf flutter_linux_3.x.x-stable.tar.xz -C /opt/
export PATH="$PATH:/opt/flutter/bin"
```

### 2. Установка Android SDK

Через Android Studio:
1. Откройте Android Studio
2. Tools → SDK Manager
3. Установите:
   - Android SDK Platform 33 (или выше)
   - Android SDK Build-Tools 33.0.0
   - Android Emulator (опционально)

### 3. Переменные окружения

**Windows:**
```powershell
[Environment]::SetEnvironmentVariable("ANDROID_HOME", "C:\Users\USERNAME\AppData\Local\Android\Sdk", "User")
```

**macOS/Linux:**
```bash
echo 'export ANDROID_HOME=$HOME/Android/Sdk' >> ~/.bashrc
echo 'export PATH=$PATH:$ANDROID_HOME/tools:$ANDROID_HOME/platform-tools' >> ~/.bashrc
source ~/.bashrc
```

---

## 📱 Установка APK

### На физическое устройство

```bash
# Через ADB
adb install build/app/outputs/flutter-apk/app-release.apk

# Или скопируйте APK на устройство и установите
```

### На эмулятор

1. Запустите Android Emulator
2. Перетащите APK файл в окно эмулятора
3. Или используйте: `adb install app-release.apk`

---

## 🏗 Типы сборок

### Debug APK (для разработки)
```bash
flutter build apk --debug
```
- Быстрая сборка
- Большой размер
- Включает отладочную информацию

### Release APK (для production)
```bash
flutter build apk --release
```
- Оптимизированная сборка
- Меньший размер
- Подписана debug ключом

### App Bundle (для Google Play)
```bash
flutter build appbundle --release
```
- Рекомендуется для публикации
- Оптимизирована для разных устройств

---

## 🔐 Подпись APK (для публикации)

### Создание keystore

```bash
keytool -genkey -v \
  -keystore ~/upload-keystore.jks \
  -keyalg RSA \
  -keysize 2048 \
  -validity 10000 \
  -alias upload
```

### Настройка подписи

Создайте файл `android/key.properties`:

```properties
storePassword=YOUR_STORE_PASSWORD
keyPassword=YOUR_KEY_PASSWORD
keyAlias=upload
storeFile=/home/USERNAME/upload-keystore.jks
```

### Сборка подписанного APK

```bash
flutter build apk --release
```

---

## ❌ Исправление ошибок

### Ошибка: "Flutter not found"

```bash
# Проверьте PATH
echo $PATH | grep flutter

# Добавьте в ~/.bashrc или ~/.zshrc
export PATH="$PATH:/path/to/flutter/bin"
```

### Ошибка: "Android SDK not found"

```bash
# Установите ANDROID_HOME
export ANDROID_HOME=/Users/USERNAME/Library/Android/sdk  # macOS
export ANDROID_HOME=/home/USERNAME/Android/Sdk            # Linux
export ANDROID_HOME=C:\Users\USERNAME\AppData\Local\Android\Sdk  # Windows
```

### Ошибка: "Gradle build failed"

```bash
# Очистка Gradle
cd android
./gradlew clean
cd ..
flutter clean
flutter pub get
flutter build apk
```

### Ошибка: "Out of memory"

```bash
# Увеличьте память для Gradle
# В android/gradle.properties:
org.gradle.jvmargs=-Xmx4096m
```

---

## 📊 Размер APK

| Сборка | Примерный размер |
|--------|-----------------|
| Debug | ~50-70 MB |
| Release (неподписанная) | ~25-35 MB |
| Release (сжатая) | ~15-25 MB |

### Оптимизация размера

```bash
# Включить code shrinking и obfuscation
flutter build apk --release --obfuscate --split-debug-info=symbols/
```

---

## 🎯 Следующие шаги

После успешной сборки:

1. **Тестирование** - Установите APK на устройство
2. **Firebase** - Настройте `google-services.json`
3. **API Keys** - Заполните `.env` файл
4. **Публикация** - Следуйте [DEPLOYMENT_GUIDE.md](DEPLOYMENT_GUIDE.md)

---

## 📞 Поддержка

При проблемах со сборкой:
1. Проверьте `flutter doctor`
2. Очистите кэш: `flutter clean`
3. Обновите зависимости: `flutter pub upgrade`
4. Создайте issue на GitHub

---

**Готово к сборке!** 🚀
