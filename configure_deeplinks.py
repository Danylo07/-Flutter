#!/usr/bin/env python3
"""Додає схему deep link `library://app/...` в AndroidManifest.xml та Info.plist.

Запускати з кореня проєкту ПІСЛЯ `flutter create .` (скрипт ідемпотентний):

    python3 tools/configure_deeplinks.py

Що робить:
  * Android: intent-filter VIEW/BROWSABLE зі схемою `library` і хостом `app`
    + meta-data flutter_deeplinking_enabled.
  * iOS: CFBundleURLTypes зі схемою `library` + FlutterDeepLinkingEnabled.
"""
from __future__ import annotations

import sys
from pathlib import Path

SCHEME = "library"
HOST = "app"
ANDROID_MANIFEST = Path("android/app/src/main/AndroidManifest.xml")
INFO_PLIST = Path("ios/Runner/Info.plist")

ANDROID_BLOCK = f"""
            <!-- deep link: {SCHEME}://{HOST}/... -->
            <meta-data android:name="flutter_deeplinking_enabled" android:value="true" />
            <intent-filter>
                <action android:name="android.intent.action.VIEW" />
                <category android:name="android.intent.category.DEFAULT" />
                <category android:name="android.intent.category.BROWSABLE" />
                <data android:scheme="{SCHEME}" android:host="{HOST}" />
            </intent-filter>
"""

IOS_BLOCK = f"""	<key>CFBundleURLTypes</key>
	<array>
		<dict>
			<key>CFBundleTypeRole</key>
			<string>Editor</string>
			<key>CFBundleURLName</key>
			<string>com.example.college_library</string>
			<key>CFBundleURLSchemes</key>
			<array>
				<string>{SCHEME}</string>
			</array>
		</dict>
	</array>
	<key>FlutterDeepLinkingEnabled</key>
	<true/>
"""


def patch_android(root: Path) -> str:
    path = root / ANDROID_MANIFEST
    if not path.exists():
        return f"пропущено: {path} не знайдено (спершу виконайте flutter create .)"
    text = path.read_text(encoding="utf-8")
    if f'android:scheme="{SCHEME}"' in text:
        return "Android: уже налаштовано"
    marker = "</activity>"
    index = text.find(marker)
    if index == -1:
        return "Android: не знайдено </activity> — додайте intent-filter вручну (див. README)"
    path.write_text(text[:index] + ANDROID_BLOCK + "        " + text[index:], encoding="utf-8")
    return "Android: intent-filter додано"


def patch_ios(root: Path) -> str:
    path = root / INFO_PLIST
    if not path.exists():
        return f"пропущено: {path} не знайдено (спершу виконайте flutter create .)"
    text = path.read_text(encoding="utf-8")
    if f"<string>{SCHEME}</string>" in text and "CFBundleURLSchemes" in text:
        return "iOS: уже налаштовано"
    if "CFBundleURLTypes" in text:
        return "iOS: CFBundleURLTypes уже існує — додайте схему вручну (див. README)"
    marker = "</dict>\n</plist>"
    index = text.rfind(marker)
    if index == -1:
        return "iOS: не знайдено кінець plist — додайте CFBundleURLTypes вручну (див. README)"
    path.write_text(text[:index] + IOS_BLOCK + text[index:], encoding="utf-8")
    return "iOS: CFBundleURLTypes додано"


def main() -> int:
    root = Path(sys.argv[1]) if len(sys.argv) > 1 else Path(".")
    print(patch_android(root))
    print(patch_ios(root))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
