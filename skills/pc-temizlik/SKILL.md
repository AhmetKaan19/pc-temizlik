---
name: pc-temizlik
description: Scans a Mac or Windows computer read-only for disk usage, unused apps, caches, leftover background services of uninstalled apps and app trustworthiness, groups the findings, then cleans only what the owner approves, moving files to Trash or Recycle Bin. Use when the user asks to check, audit, clean up, free disk space on, or remove leftovers from a computer ("bilgisayarımı kontrol et", "temizlik yapalım", "yer aç", "gereksiz uygulamalar").
---

# Bilgisayar temizliği (tara → grupla → sor → temizle → doğrula)

Bu skill bir bilgisayarı **sahibiyle birlikte** temizler. Hiçbir şey sahibinin onayı olmadan silinmez. Kişisel dosyaya ancak sahibi tek tek söylerse dokunulur.

## Temel kurallar (her adımda geçerli)

1. **Önce yalnızca okuma.** Tarama sırasında hiçbir şey değiştirilmez.
2. **Silmek yerine taşı.** Dosyalar Çöp Kutusu'na (Mac) ya da Geri Dönüşüm Kutusu'na (Windows) taşınır, tarihli bir alt klasörde toplanır. Kalıcı silme yalnızca saf önbellekte yapılır, o da aracın kendi temizleme komutuyla (`npm cache clean`, `pip cache purge` gibi). Çöpü boşaltmak sahibine kalır.
3. **Kişisel dosyalar ayrı gruptadır.** Video, fotoğraf, proje, oyun kaydı ve belgeler "temizlik" sayılmaz. Bunlar sadece raporlanır, sahibine sorulur, varsayılan cevap "kalsın"dır.
4. **Belirsiz cevapta dur ve sor.** Argo ya da iki anlama gelebilecek bir söz ("siktir et", "boşver", "hallet") silme onayı değildir. "Sileyim mi, dokunmayayım mı?" diye sor.
5. **Açık uygulamaya dokunma.** Önbelleği silinecek uygulama çalışıyorsa önce kontrol et. Kapatman gerekiyorsa sahibine sor; kapatınca açık sekmeler ya da kaydedilmemiş işler gidebilir.
6. **Yönetici yetkisi sahibindedir.** `sudo` ya da yönetici olarak PowerShell gerektiren komutları kendin çalıştırmazsın. Hazır, tek satırlık komutu sahibine verirsin; çalıştırdıktan sonra sonucu doğrularsın.
7. **Kayıt defterine (Windows Registry) yazma.** Sadece okunur.
8. **Kısaltmayı ilk kullandığın yerde aç.** Kullanıcı teknik olmayabilir.

## Akış

İlerlemeyi takip etmek için bu listeyi kopyala:

```
- [ ] 1. Hazırlık: sahibi yanında mı, işletim sistemi ne
- [ ] 2. Tarama (script, sadece okuma)
- [ ] 3. Rapor ve gruplama
- [ ] 4. Grup grup onay ve temizlik
- [ ] 5. İkinci tarama: silinen uygulamaların kalıntıları
- [ ] 6. Son ölçüm ve özet
```

### 1. Hazırlık
- İşletim sistemine göre referansı oku: Mac için [references/mac.md](references/mac.md), Windows için [references/windows.md](references/windows.md). İkisini birden okuma.
- Bilgisayar başka birinin bilgisayarıysa sahibinin yanında olduğunu ve taramayı onayladığını doğrula.

### 2. Tarama
Script'i **çalıştır**, içeriğini okumana gerek yok:
- Mac: `bash scripts/scan_mac.sh > <scratchpad>/tarama.txt`
- Windows: `powershell -NoProfile -ExecutionPolicy RemoteSigned -File scripts/scan_windows.ps1 > <scratchpad>\tarama.txt`

Script yönetici yetkisi istemez. Yetki gerektiren bir bölüm erişim hatası verirse onu "ölçülemedi" diye raporla, yetki isteme. Çıktı uzunsa önce `== ÖZET ==` bölümünü oku.

### 3. Rapor ve gruplama
Bulguları dört gruba ayır. Her kalem için boyutunu, ne olduğunu ve güvenilirliğini (imza veya yayıncı) ver:

| Grup | İçerik | Varsayılan |
|---|---|---|
| **A – Güvenli** | Önbellekler, derleme artıkları, eski kurulum dosyaları | Önerilir |
| **B – Uygulamalar** | Uzun süredir açılmamış ya da güvenilirliği zayıf uygulamalar | Sahibi seçer |
| **C – Kalıntılar** | Uygulaması silinmiş ama servisi, görevi, giriş öğesi ya da klasörü kalmış şeyler | Önerilir |
| **D – Kişisel** | Büyük videolar, projeler, indirilenler, oyun kayıtları | Sadece rapor, "kalsın" |

Raporun sonunda neyle başlamayı önerdiğini söyle ve **dur**, sahibinin seçimini bekle.

### 4. Grup grup temizlik
- Sadece seçilen grubu ya da kalemleri uygula.
- Başlamadan önceki boş alanı ölç ve not al.
- Her kalemi tek tek taşı ve sonucunu yaz. Taşınamayanlar için sebebini ve sahibinin ne yapabileceğini söyle (örneğin korumalı klasörü kendisi sürükleyebilir).
- Uygulamaları (B grubu) sahibi kendisi kaldırmak isteyebilir; bunu sor.
- Yönetici gereken kalemleri tek bir komutta topla, sahibine ver. Komut da dosyaları çöpe taşısın.

### 5. İkinci tarama
Silinen her uygulama için kalıntıları ara: destek klasörü, önbellek, ayar, kayıt (log), servis ve görev. Referanstaki "kalıntı yerleri" listesini kullan. Uygulaması kalmamış servis ve görevler en önemli bulgudur, çünkü artık güncelleme almazlar.

### 6. Son ölçüm ve özet
- Başta ve sonda boş alanı ve doluluk oranını bir tabloda göster.
- Arkada kalan yabancı servisleri listele.
- Güvenlik faydasını **abartmadan** anlat. Önbellek silmek güvenliği neredeyse hiç artırmaz. Asıl kazanç sahipsiz, yetkili servislerin gitmesidir.
- Çöpte ne kadar yer olduğunu ve boşaltmanın sahibine kaldığını söyle.

## Test senaryoları
Skill'i değiştirdikten sonra [evals/senaryolar.md](evals/senaryolar.md) içindeki senaryolarla dene.
