# pc-temizlik

Claude Code için bir bilgisayar temizliği skill'i. Mac ya da Windows bir bilgisayarı **sahibiyle birlikte** tarar, bulguları gruplar ve yalnızca sahibinin onayladıklarını çöpe taşır.

*A Claude Code skill that audits a Mac or Windows computer together with its owner, groups the findings and only moves approved items to the Trash / Recycle Bin. Instructions are in Turkish.*

## Ne yapar

1. **Tarar (sadece okur):** disk kullanımı, en büyük klasörler, önbellekler, uygulamalar ve imzaları, açılışta başlayanlar, arka plan servisleri.
2. **Sahipsiz servisleri bulur:** uygulaması silinmiş ama arka planda kalmış servis, görev ve başlangıç öğelerini işaretler. Bunlar artık güncelleme almadıkları için en önemli güvenlik bulgusudur.
3. **Gruplar:**

   | Grup | İçerik |
   |---|---|
   | A – Güvenli | Önbellekler, derleme artıkları, eski kurulum dosyaları |
   | B – Uygulamalar | Uzun süredir açılmamış ya da güvenilirliği zayıf uygulamalar |
   | C – Kalıntılar | Silinmiş uygulamalardan kalan servis, klasör ve ayarlar |
   | D – Kişisel | Videolar, projeler, oyun kayıtları: sadece raporlanır |

4. **Sorar ve temizler:** sadece seçilen grupları uygular. Dosyalar kalıcı silinmez, tarihli bir çöp klasörüne taşınır.
5. **Doğrular:** silinen uygulamaların kalıntılarını ikinci kez tarar, sonunda boş alanı önce/sonra tablosuyla gösterir.

## Güvenlik ilkeleri

- Tarama hiçbir şeyi değiştirmez ve yönetici yetkisi istemez.
- Kişisel dosyalar varsayılan olarak "kalsın"dır.
- Belirsiz bir cevapta Claude silmez, sorar.
- Yönetici gerektiren komutları Claude çalıştırmaz; hazır komutu bilgisayarın sahibine verir.
- Windows'ta kayıt defterine (Registry) yazmaz.

## Kurulum

**Claude Code eklentisi olarak:**

```
/plugin marketplace add AhmetKaan19/pc-temizlik
/plugin install pc-temizlik@pc-temizlik
```

**Elle:** `skills/pc-temizlik` klasörünü kopyala:
- Mac: `~/.claude/skills/pc-temizlik`
- Windows: `C:\Users\<kullanıcı>\.claude\skills\pc-temizlik`

Sonra Claude Code'a "bilgisayarımı kontrol et" ya da "yer açalım" demen yeterli.

## Durum

- **Mac:** gerçek bir temizlikte kullanılan adımlardan yazıldı; tarama script'i denendi.
- **Windows:** tarama script'i henüz gerçek bir Windows bilgisayarında çalıştırılmadı. İlk kullanımlarda hata çıkabilir.

Test senaryoları: [`skills/pc-temizlik/evals/senaryolar.md`](skills/pc-temizlik/evals/senaryolar.md)

## Lisans

MIT
