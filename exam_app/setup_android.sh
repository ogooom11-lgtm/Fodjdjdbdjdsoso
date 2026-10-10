#!/usr/bin/env bash
# يضع أيقونة التطبيق واسمه في مجلد android بعد إنشاء مجلدات المنصات.
set -e
cd "$(dirname "$0")"

if [ ! -d android ]; then
  echo "مجلد android غير موجود. نفّذ أولاً داخل exam_app:"
  echo "  flutter create . --platforms=android"
  exit 1
fi

ICON=assets/icon/ic_launcher.png
for d in mdpi hdpi xhdpi xxhdpi xxxhdpi; do
  mkdir -p "android/app/src/main/res/mipmap-$d"
  cp "$ICON" "android/app/src/main/res/mipmap-$d/ic_launcher.png"
done

sed -i 's/android:label="[^"]*"/android:label="امتحان الدروس الهجائية"/' \
  android/app/src/main/AndroidManifest.xml

echo "تم: نُسخَت الأيقونة وضُبِط اسم التطبيق."
