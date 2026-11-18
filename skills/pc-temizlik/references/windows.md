# Windows referansı

> Bu dosya henüz gerçek bir Windows bilgisayarında denenmedi. İlk kullanımda çıkan farkları buraya ekle.

## İçindekiler
1. Kabuk ve yetki
2. Geri Dönüşüm Kutusu'na taşıma
3. A grubu: güvenli kalemler
4. B grubu: uygulama kaldırma
5. C grubu: kalıntı yerleri
6. Asla dokunma listesi
7. Bilinen tuzaklar

## 1. Kabuk ve yetki
- Claude Code Windows'ta komutları Git Bash ya da PowerShell'de çalıştırır. Yollarda ters bölü (`\`) kullan, ama skill içindeki dosyalara giderken düz bölü (`scripts/scan_windows.ps1`) de çalışır.
- Script'i `-ExecutionPolicy RemoteSigned` ile çalıştır. `Bypass` kullanma: bu Windows'un betik güvenlik kilidini tamamen kapatır.
- Yönetici gereken komutları (Hizmetler, `C:\Windows`, `ProgramData`, `HKLM`) kendin çalıştırma. Sahibine "Başlat → PowerShell'e sağ tıkla → Yönetici olarak çalıştır" dedirt ve tek satırlık komutu ver.

## 2. Geri Dönüşüm Kutusu'na taşıma
`Remove-Item` dosyayı Geri Dönüşüm Kutusu'na **göndermez**, doğrudan siler. Taşımak için şunu kullan:
```powershell
Add-Type -AssemblyName Microsoft.VisualBasic
function To-Recycle($p) {
  if (Test-Path -LiteralPath $p -PathType Container) {
    [Microsoft.VisualBasic.FileIO.FileSystem]::DeleteDirectory($p, 'OnlyErrorDialogs', 'SendToRecycleBin')
  } else {
    [Microsoft.VisualBasic.FileIO.FileSystem]::DeleteFile($p, 'OnlyErrorDialogs', 'SendToRecycleBin')
  }
}
To-Recycle "C:\Users\<kullanıcı>\AppData\Local\<klasör>"
```
Çok büyük klasörler Geri Dönüşüm Kutusu'nun sınırını aşarsa Windows kalıcı silmeyi teklif eder; o durumda dur ve sahibine sor.

## 3. A grubu: güvenli kalemler
| Kalem | Yol / komut | Not |
|---|---|---|
| Geçici dosyalar | `%TEMP%` (`AppData\Local\Temp`) | Kilitli dosyalar atlanır, normaldir |
| Çökme dökümleri | `AppData\Local\CrashDumps` | Güvenli |
| Ekran kartı gölgelendirici önbelleği | `AppData\Local\NVIDIA\DXCache`, `AMD\DxCache`, `D3DSCache` | Oyunlar ilk açılışta biraz yavaşlar |
| Tarayıcı önbelleği | `...\User Data\Default\Cache` ve `Code Cache` | Tarayıcı açıksa önce sor. Profil klasörüne dokunma |
| Geliştirici önbellekleri | `npm cache clean --force`, `pip cache purge`, `uv cache clean`, `.gradle\caches` | Aracın kendi komutu |
| Windows Update indirmeleri | `C:\Windows\SoftwareDistribution\Download` | Yönetici gerekir. Tercihen Ayarlar → Sistem → Depolama → Geçici dosyalar |
| Windows'un kendi temizliği | Ayarlar → Sistem → Depolama → Depolama Algısı / Geçici dosyalar | En güvenli yol; sahibine göster |

## 4. B grubu: uygulama kaldırma
- Uygulamayı sahibi kendisi kaldırsın: Ayarlar → Uygulamalar → Yüklü uygulamalar. Ya da tarama çıktısındaki `UninstallString` komutunu ver.
- `winget list` ve `winget uninstall --id <kimlik>` da çalışır; kaldırma öncesi sor.
- Son kullanım tarihi Windows'ta güvenilir değildir. Prefetch (`C:\Windows\Prefetch`) yönetici ister. Kesin değilse "son kullanım bilinmiyor" de ve sahibine sor.

## 5. C grubu: kalıntı yerleri
Silinen uygulamanın adını ve şirketini şu yerlerde ara:
- `AppData\Local`, `AppData\LocalLow`, `AppData\Roaming`
- `C:\ProgramData` (yönetici gerekebilir), `C:\Program Files`, `C:\Program Files (x86)` içinde boş kalmış klasörler
- Başlangıç: `shell:startup` klasörü ve tarama çıktısındaki `ORPHAN` başlangıç öğeleri
- Hizmetler: tarama çıktısındaki `ORPHAN` hizmetler. Durdurma ve silme yönetici ister: `sc.exe stop <ad>; sc.exe delete <ad>`. Silmeden önce `sc.exe qc <ad>` çıktısını not al (geri kurmak için).
- Zamanlanmış görevler: `ORPHAN` görevler. Önce devre dışı bırak (`Disable-ScheduledTask`), bir süre sonra silinebilir. Bu geri alınabilir.
- Kayıt defteri artıkları: sadece raporla, silme.

## 6. Asla dokunma listesi
`C:\Windows` (SoftwareDistribution\Download hariç), `C:\Windows\WinSxS`, `C:\Windows\Installer`, `pagefile.sys`, `hiberfil.sys`, `System Volume Information`, `$Recycle.Bin` (boşaltmak sahibine kalır), `AppData\Local\Microsoft\Windows`, sürücü (driver) klasörleri, antivirüs klasörleri. Microsoft ya da donanım üreticisine (Intel, AMD, NVIDIA, Realtek) ait hizmetleri "sahipsiz" görünse bile kaldırma; sahibine raporla.

## 7. Bilinen tuzaklar
- PowerShell 5.1, UTF-8 dosyaları BOM olmadan okursa Türkçe karakterleri bozar. Bu yüzden `scan_windows.ps1` metinleri İngilizce harfle yazılmıştır.
- `Get-SizeGB` büyük klasörlerde yavaştır (dakikalar sürebilir); kullanıcıya bekleteceğini söyle.
- Tarayıcı eklenti adları bazen `__MSG_appName__` gibi çıkar; bu eklentinin kendi dil dosyasındaki bir anahtardır, şüpheli değildir.
- OneDrive "Masaüstü/Belgeler yedekleme" açıksa bu klasörler buluttadır; içindekileri silmek buluttan da siler. Önce OneDrive açık mı kontrol et.
- İmza durumu `NotSigned` olan program kesin zararlı demek değildir (birçok küçük açık kaynak araç imzasızdır), ama raporda belirt.
