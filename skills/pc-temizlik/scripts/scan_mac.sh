#!/bin/bash
# pc-temizlik: Mac taraması. SADECE OKUR, hiçbir şeyi değiştirmez.
# Kullanım: bash scan_mac.sh > tarama.txt
# Yönetici yetkisi istemez; okunamayan yerler sessizce atlanır.

H="$HOME"; L="$H/Library"
top() { du -sh "$@" 2>/dev/null | sort -rh | head -"${N:-12}"; }

echo "== ÖZET =="
df -g /System/Volumes/Data 2>/dev/null | tail -1 | awk '{print "Disk: " $2 " GB, kullanılan " $3 " GB, boş " $4 " GB, doluluk " $5}'
echo "macOS: $(sw_vers -productVersion 2>/dev/null)"
t=$(du -sh "$H/.Trash" 2>/dev/null | cut -f1); echo "Çöp: ${t:-ölçülemedi, macOS izni yok, Finder ile bak}"

echo; echo "== EV KLASÖRÜ (en büyükler) =="
top "$H"/* "$H"/.[!.]*
echo; echo "== LIBRARY =="
top "$L"/*
echo; echo "== APPLICATION SUPPORT =="
top "$L/Application Support"/*
echo; echo "== CACHES =="
top "$L/Caches"/*
echo; echo "== CONTAINERS / GROUP CONTAINERS =="
top "$L/Containers"/* "$L/Group Containers"/*
echo; echo "== MASAÜSTÜ / BELGELER / FİLMLER / İNDİRİLENLER (kişisel, D grubu) =="
N=8 top "$H/Desktop"/* "$H/Documents"/* "$H/Movies"/* "$H/Downloads"/*

echo; echo "== GELİŞTİRİCİ ARTIKLARI =="
top "$L/Developer/Xcode/DerivedData" "$L/Developer/CoreSimulator/Devices" "$L/Developer/Xcode/Archives" \
    "$L/Developer/Xcode/iOS DeviceSupport" "$L/Android/sdk" "$H/.gradle/caches" "$H/.npm" "$H/.cache"/* \
    "$L/Caches/Homebrew" "$L/Caches/pip" "$H/.bun/install/cache" "$L/iTunes/iPad Software Updates" \
    "$L/iTunes/iPhone Software Updates"
if command -v xcrun >/dev/null 2>&1; then
  echo "Simülatörler:"; xcrun simctl list devices 2>/dev/null | grep -E "\((Booted|Shutdown)\)" | sed 's/^ */  /'
fi

echo; echo "== UYGULAMALAR (ad | boyut | son kullanım | kaynak | imza) =="
for a in /Applications/*.app "$H/Applications"/*.app; do
  [ -e "$a" ] || continue
  n=$(basename "$a" .app)
  if [ -L "$a" ]; then echo "$n | kısayol -> $(readlink "$a") | | |"; continue; fi
  s=$(du -sh "$a" 2>/dev/null | cut -f1)
  u=$(mdls -raw -name kMDItemLastUsedDate "$a" 2>/dev/null | cut -c1-10)
  src=$([ -d "$a/Contents/_MASReceipt" ] && echo "App Store" || echo "Web")
  sig=$(spctl -a -vv "$a" 2>&1 | grep -E "^(source|origin)=" | sed 's/source=//;s/origin=Developer ID Application: //;s/origin=//' | tr '\n' ' ' | cut -c1-70)
  echo "$n | $s | ${u:-bilinmiyor} | $src | ${sig:-imza yok}"
done

echo; echo "== ARKA PLAN SERVİSLERİ (Apple dışı) =="
echo "Durum: TAMAM = programı var, SAHİPSİZ = programı silinmiş (C grubu adayı)"
for f in "$L/LaunchAgents"/*.plist /Library/LaunchAgents/*.plist /Library/LaunchDaemons/*.plist; do
  [ -e "$f" ] || continue
  prog=$(/usr/libexec/PlistBuddy -c "Print :ProgramArguments:0" "$f" 2>/dev/null || /usr/libexec/PlistBuddy -c "Print :Program" "$f" 2>/dev/null)
  if [ -n "$prog" ] && [ ! -e "$prog" ]; then st="SAHİPSİZ"; else st="TAMAM"; fi
  echo "$st | $f | ${prog:-?}"
done
echo "Yetkili yardımcılar (root):"; ls /Library/PrivilegedHelperTools 2>/dev/null | sed 's/^/  /'
echo "Hata veren yüklü servisler (çıkış kodu sıfır değil):"
launchctl list 2>/dev/null | awk 'NR>1 && $2!="0" && $2!="-" && $3!~/^com\.apple\./ {print "  " $3 " (kod " $2 ")"}'

echo; echo "== AÇILIŞTA BAŞLAYANLAR =="
osascript -e 'tell application "System Events" to get the name of every login item' 2>/dev/null | tr ',' '\n' | sed 's/^ */  /'

echo; echo "== ÇALIŞAN UYGULAMALAR (önbellek silmeden önce bak) =="
osascript -e 'tell application "System Events" to get the name of every process whose background only is false' 2>/dev/null | tr ',' '\n' | sed 's/^ */  /'

echo; echo "== YEREL ANLIK GÖRÜNTÜLER (Time Machine / güncelleme) =="
tmutil listlocalsnapshots / 2>/dev/null | tail -n +2 | sed 's/^/  /'
echo; echo "Tarama bitti. Hiçbir şey değiştirilmedi."
