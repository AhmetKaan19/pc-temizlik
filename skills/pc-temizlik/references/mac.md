# Mac referansı

## İçindekiler
1. Taşıma ve kalıcı silme
2. A grubu: güvenli kalemler
3. C grubu: kalıntı yerleri
4. Yönetici gerektirenler
5. Bilinen tuzaklar

## 1. Taşıma ve kalıcı silme
- Taşıma: tarihli bir çöp klasörü aç ve oraya `mv` ile taşı: `T=~/.Trash/Temizlik-YYYY-AA-GG; mkdir -p "$T"; mv "<yol>" "$T"/`
- Aynı adlı iki klasör (`Logs/Adobe` ve `Caches/Adobe` gibi) çakışır. Kaynak yolu çöp klasörünün içinde koru: `mkdir -p "$T$(dirname "$f")"; mv "$f" "$T$(dirname "$f")"/`
- Kalıcı silme yalnız aracın kendi komutuyla yapılır: `uv cache clean`, `brew cleanup -s --prune=all`, `npm cache clean --force`, `python3 -m pip cache purge`, `bun pm cache rm`. Gradle önbelleği (`~/.gradle/caches`) Gradle çalışmıyorken silinebilir.

## 2. A grubu: güvenli kalemler
| Kalem | Yol | Not |
|---|---|---|
| Eski iOS kurulum dosyası (IPSW) | `~/Library/iTunes/*Software Updates/*.ipsw` | Her zaman güvenli |
| Xcode derleme artıkları | `~/Library/Developer/Xcode/DerivedData` | Yeniden oluşur |
| Kapalı simülatörler | `xcrun simctl delete <UDID>`; `xcrun simctl delete unavailable` | Açık olanları sahibine sor |
| Uygulama önbellekleri | `~/Library/Caches/<uygulama>` | Önce uygulama açık mı bak |
| Güncelleyici artıkları | `~/Library/Caches/*-updater`, `*.ShipIt` | Güvenli |
| Chrome önbelleği | `~/Library/Caches/Google/Chrome` | Profil klasörüne (`Application Support/Google/Chrome`) dokunma |

## 3. C grubu: kalıntı yerleri
Silinen uygulamanın adını, şirketini ve paket kimliğini (`com.firma.uygulama`) şu yerlerde ara:
- `~/Library/`: `Application Support`, `Caches`, `Containers`, `Group Containers`, `Preferences`, `Saved Application State`, `HTTPStorages`, `WebKit`, `Logs`, `LaunchAgents`
- Sistem (yönetici gerekir): `/Library/LaunchAgents`, `/Library/LaunchDaemons`, `/Library/PrivilegedHelperTools`, `/Library/Application Support`, `/Library/Preferences`
- `/Users/Shared` (Riot gibi bazı başlatıcılar burada durur)
- `/Applications` içindeki kısayollar (symlink): hedefi silinmişse çalışmaz.
- Giriş öğeleri: `osascript -e 'tell application "System Events" to delete login item "<ad>"'`
- Kullanıcı servisini durdurmak: `launchctl bootout gui/$(id -u)/<etiket>`. Dosya silinmiş olsa da servis bellekte çalışmaya devam edebilir; `launchctl list` ile doğrula.

## 4. Yönetici gerektirenler
Sistem klasörlerindeki kalıntıları tek bir komutta topla ve sahibine ver:
```
sudo launchctl bootout system /Library/LaunchDaemons/<x>.plist 2>/dev/null; D=~/.Trash/Temizlik-YYYY-AA-GG/sistem; mkdir -p $D && sudo mv <yollar> $D/
```
Çalıştırdıktan sonra yolların gittiğini ve `launchctl list` çıktısında artık görünmediklerini doğrula.

## 5. Bilinen tuzaklar
- `~/Library/Containers` macOS tarafından korunur; terminal oraya dosya taşıyamaz ("Operation not permitted"). Sahibi Finder'da Git → Klasöre Git ile açıp kendisi sürükleyebilir. Bu klasörler genelde küçüktür.
- `kMDItemLastUsedDate` bazen boş (`null`) döner; bu "hiç açılmadı" demek değildir.
- Chrome açıkken kapatmak sekmeleri silebilir (`session.restore_on_startup` ayarı kapalıysa). Kapatmadan önbellek klasörünü taşımak çalışır.
- Claude masaüstü uygulamasının içinden çalışıyorsan onun önbelleğini (`Application Support/Claude/Cache`) taşıyabilirsin; uygulama bir sonraki açılışta yeniden oluşturur. `vm_bundles` klasörüne dokunma.
- `spctl` "rejected" diyebilir, ama ana uygulama geliştiricisinin imzasını taşıyabilir. `codesign -dv` ile imzalayanı kontrol et; içindeki imzasız tek bir veri dosyası tek başına zararlı yazılım işareti değildir.
- Çöpün boyutu terminalden ölçülemeyebilir; kendi açtığın tarihli klasörü ölç.
