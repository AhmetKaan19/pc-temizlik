# pc-temizlik

Claude Code için bir bilgisayar temizliği skill'i. Mac ya da Windows bir bilgisayarı **sahibiyle birlikte** tarar, bulguları gruplar ve yalnızca sahibinin onayladıklarını çöpe taşır.

**Türkçe** · [English](#english)

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

---

## English

A Claude Code skill for cleaning up a computer. It audits a Mac or Windows machine **together with its owner**, groups the findings and moves only the items the owner approves to the Trash or Recycle Bin.

> The skill's instructions and messages are written in Turkish. Claude reads them in any language, so it works for English speakers too: just ask in English and Claude will answer in English.

### What it does

1. **Scans (read-only):** disk usage, largest folders, caches, installed apps and their code signatures, startup items and background services.
2. **Finds orphaned services:** background services, scheduled tasks and startup items whose app has been uninstalled. These no longer receive updates, which makes them the most important security finding.
3. **Groups the findings:**

   | Group | Contents |
   |---|---|
   | A – Safe | Caches, build leftovers, old installer files |
   | B – Apps | Apps not opened in a long time, or with weak trust signals |
   | C – Leftovers | Services, folders and settings left behind by removed apps |
   | D – Personal | Videos, projects, game saves: reported only |

4. **Asks, then cleans:** applies only the groups the owner picks. Nothing is permanently deleted; files go to a dated folder in the Trash.
5. **Verifies:** runs a second sweep for leftovers of removed apps, then shows free space before and after.

### Safety principles

- The scan changes nothing and does not need admin rights.
- Personal files default to "keep".
- On an ambiguous answer, Claude asks instead of deleting.
- Claude never runs admin commands itself; it hands a ready-made command to the computer's owner.
- On Windows it never writes to the Registry.

### Installation

**As a Claude Code plugin:**

```
/plugin marketplace add AhmetKaan19/pc-temizlik
/plugin install pc-temizlik@pc-temizlik
```

**Manually:** copy the `skills/pc-temizlik` folder to:
- Mac: `~/.claude/skills/pc-temizlik`
- Windows: `C:\Users\<user>\.claude\skills\pc-temizlik`

Then tell Claude Code something like "check my computer" or "free up some disk space".

### Status

- **Mac:** written from the steps of a real cleanup; the scan script has been tested.
- **Windows:** the scan script has not yet been run on a real Windows machine. Expect rough edges at first.

Test scenarios (Turkish): [`skills/pc-temizlik/evals/senaryolar.md`](skills/pc-temizlik/evals/senaryolar.md)

### License

MIT
