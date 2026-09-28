# Use Case 03 — Kulübün Etkinlik Başvurularını Yönetmesi

## 1. Amaç

Bu use case, kulüp yöneticilerinin kendi kulüplerine ait etkinliklere yapılan öğrenci başvurularını görüntülemesini ve başvuruların durumlarını yönetmesini tanımlar.

Başvuruların kabul edilmesi, reddedilmesi, gerekli durumlarda öğrencilerin yedek listeye alınması, yedek listenin otomatik olarak işlenmesi ve gerekli durumlarda daha önce verilmiş kararların düzeltilmesi bu use case kapsamındadır.

Bu use case özellikle `APPROVAL_REQUIRED` etkinliklerde yöneticinin `PENDING` başvuruları değerlendirmesini kapsar.

`PUBLIC` etkinliklerde ise başvurular yönetici tarafından tek tek değerlendirilmez. Sistem, başvuru ve kapasite kurallarına göre başvuruyu doğrudan `ACCEPTED` veya `WAITLISTED` durumuna getirir.

Bildirimlerin gönderilmesi bu use case'in kapsamında değildir. Bildirim davranışları ayrı bir use case'te ele alınacaktır.

---

# 2. Aktörler

## Birincil Aktörler

* Kulüp Başkanı (`PRESIDENT`)
* Başkan Yardımcısı (`VICE_PRESIDENT`)
* Kulüp Yöneticisi (`MANAGER`)

Bu üç rol de kulübün etkinlik başvurularını yönetebilir.

## İkincil Aktörler

* Öğrenci
* Sistem

Öğrenci başvurunun sonucundan etkilenir ancak `PENDING` başvuruları yönetmez.

Sistem ise:

* Başvuru tipi
* Kapasite
* Bekleme listesi
* Başvuru sırası
* Otomatik kabul
* Otomatik bekleme listesi işlemleri

gibi kuralları otomatik olarak uygular.

---

# 3. Ön Koşullar

Başvuru yönetimi gerçekleştirebilmek için:

* Kullanıcının sisteme giriş yapmış olması gerekir.
* Kullanıcının ilgili kulüpte aktif bir yönetici rolüne sahip olması gerekir.
* Yönetici tarafından işlem yapılacak etkinliğin ilgili kulübe ait olması gerekir.
* Etkinliğin `CANCELLED` durumunda olmaması gerekir.
* Başvuru üzerinde durum değişikliği yapılacaksa etkinliğin henüz başlamamış olması gerekir.

Etkinlik başladıktan sonra başvuru yönetimi sona erer.

Etkinlik başladıktan sonraki katılım süreci `Attendance` üzerinden yürütülür.

---

# 4. Başvuru Durumları

Bir etkinlik başvurusu aşağıdaki durumlardan birinde bulunabilir:

```text
PENDING

ACCEPTED

REJECTED

WAITLISTED

WITHDRAWN
```

## 4.1. PENDING

Başvuru yapılmış ancak henüz kesin bir kabul veya ret kararı verilmemiştir.

`APPROVAL_REQUIRED` etkinliklerde başvurular yönetici tarafından değerlendirilmek üzere `PENDING` durumunda tutulur.

Örneğin:

```text
Başvuru
   ↓
PENDING
```

`PUBLIC` etkinliklerde ise başvuru `PENDING` durumunda tutulmaz.

Başvuru koşulları uygunsa sistem tarafından doğrudan:

```text
Başvuru
   ↓
ACCEPTED
```

durumuna geçirilir.

Kapasite doluysa:

```text
Başvuru
   ↓
WAITLISTED
```

durumuna geçirilir.

Dolayısıyla `PUBLIC` başvurularında `PENDING`, sistemde kalıcı bir ara durum değildir.

---

## 4.2. ACCEPTED

Öğrencinin etkinliğe katılımı kabul edilmiştir.

`PUBLIC` etkinliklerde uygun başvurular sistem tarafından otomatik olarak bu duruma geçirilir.

`APPROVAL_REQUIRED` etkinliklerde ise yönetici tarafından verilen kabul kararı sonucunda bu duruma geçilir.

`ACCEPTED` durumundaki öğrenci etkinliğe katılabilir ancak bu durum öğrencinin gerçekten etkinliğe katıldığı anlamına gelmez.

Gerçek katılım `Attendance` üzerinden takip edilir.

---

## 4.3. REJECTED

Başvuru reddedilmiştir.

Reddedilmiş bir öğrenci aynı etkinliğe yeni bir başvuru oluşturamaz.

Ancak kulüp yöneticisi önceki ret kararının hatalı olduğunu düşünürse mevcut başvuruyu:

```text
REJECTED → ACCEPTED
```

şeklinde düzeltebilir.

Bu yeni bir başvuru oluşturulması anlamına gelmez.

---

## 4.4. WAITLISTED

Öğrenci etkinliğe katılmak için yedek listede bulunmaktadır.

Yedek liste:

* Kapasitesi bulunan etkinliklerde kullanılabilir.
* Öğrencilerin başvuru zamanına göre sıralanır.
* Yönetici tarafından manuel olarak yeniden sıralanamaz.
* Kapasite açıldığında sistem tarafından otomatik olarak işlenir.

`PUBLIC` etkinliklerde kapasite dolduğunda sistem başvuruyu doğrudan `WAITLISTED` durumuna getirir.

`APPROVAL_REQUIRED` etkinliklerde ise yönetici değerlendirmesi sırasında uygun gördüğü başvuruları `WAITLISTED` durumuna alabilir.

Kapasite açıldığında bekleme listesindeki ilk öğrenci sistem tarafından:

```text
WAITLISTED → ACCEPTED
```

şeklinde otomatik olarak kabul edilir.

---

## 4.5. WITHDRAWN

Öğrenci başvurusunu etkinlik başlamadan önce geri çekmiştir.

Geçerli geri çekme durumları:

```text
PENDING → WITHDRAWN

WAITLISTED → WITHDRAWN

ACCEPTED → WITHDRAWN
```

`WITHDRAWN` durumundaki başvurunun yönetici tarafından ayrıca işleme alınması gerekmez.

Eski `WITHDRAWN` başvuru kaydı silinmez.

Başvuru süresi hâlâ açıksa öğrenci aynı etkinliğe yeni bir başvuru oluşturabilir.

`BAN` bir Application status değildir.

`NOT_ATTENDED` de bir Application status değildir; Attendance ayrı bir kavramdır.

---

# 5. Başvuruların Görüntülenmesi

Kulüp yöneticisi kendi etkinliklerinden birini seçerek o etkinliğe ait başvuruları görüntüleyebilir.

Başvurular durumlarına göre filtrelenebilir:

* Bekleyenler (`PENDING`)
* Kabul edilenler (`ACCEPTED`)
* Reddedilenler (`REJECTED`)
* Yedek listedekiler (`WAITLISTED`)
* Geri çekilenler (`WITHDRAWN`)

Başvuru listesinde en azından aşağıdaki bilgiler bulunmalıdır:

* Öğrenci
* Başvuru tarihi
* Başvuru durumu
* Başvuru durumunun değişme tarihi
* Varsa ret nedeni

Yönetici özellikle `APPROVAL_REQUIRED` etkinliklerde `PENDING` başvuruları değerlendirerek öğrencileri:

* Kabul edebilir.
* Reddedebilir.
* Gerekli görürse yedek listeye alabilir.

`PUBLIC` etkinliklerde ise başvuruların kabul veya yedek liste durumları sistem tarafından otomatik belirlendiği için yöneticinin normal başvuru akışında tek tek kabul/ret kararı vermesine gerek yoktur.

---

# 6. PENDING Başvurunun Yönetilmesi

Bir başvuru `PENDING` durumundaysa kulüp yöneticisi, etkinliğin başvuru tipine göre işlem yapar.

`PENDING` yalnızca `APPROVAL_REQUIRED` etkinliklerin normal başvuru akışında kullanılır.

Yönetici:

```text
PENDING → ACCEPTED

PENDING → REJECTED

PENDING → WAITLISTED
```

geçişlerinden uygun olanını gerçekleştirebilir.

---

## 6.1. Kabul

Yönetici başvuruyu kabul ettiğinde:

```text
PENDING → ACCEPTED
```

durumu oluşur.

Kabul işlemi etkinliğin kapasite kurallarına tabidir.

Örneğin kapasite:

```text
Kapasite: 50
ACCEPTED: 49
```

ise bir öğrencinin kabul edilmesi mümkündür.

Kapasite:

```text
Kapasite: 50
ACCEPTED: 50
```

ise yeni bir öğrencinin `ACCEPTED` yapılması mümkün değildir.

Bu durumda yönetici öğrenciyi:

```text
WAITLISTED
```

durumuna alabilir veya başvuruyu reddedebilir.

---

## 6.2. Ret

Yönetici başvuruyu reddettiğinde:

```text
PENDING → REJECTED
```

durumu oluşur.

Normal `PENDING → REJECTED` işleminde ret nedeninin zorunlu olup olmayacağı henüz kesinleştirilmemiştir.

> **Açık karar:** Normal bir ret işleminde yöneticinin ret nedeni girmesinin zorunlu olup olmayacağı daha sonra belirlenecektir.

Ret nedeni zorunlu olmasa bile sistemde ret nedeni tutulması ileride ayrıca değerlendirilebilir.

---

## 6.3. Yedek Listeye Alma

Yönetici kapasitesi bulunan bir `APPROVAL_REQUIRED` etkinlikte uygun gördüğü bazı `PENDING` başvuruları yedek listeye alabilir:

```text
PENDING → WAITLISTED
```

Yedek listeye alınan öğrenciler etkinlik için uygun görülen ancak mevcut kapasite içerisinde doğrudan kabul edilmeyen öğrencilerdir.

Yönetici birden fazla öğrenciyi yedek listeye alabilir.

Yedek liste sırası öğrencilerin başvuru zamanına göre belirlenir.

Örneğin:

```text
09:01 → Ahmet
09:05 → Mehmet
09:12 → Ayşe
```

şeklinde başvuran öğrenciler yedek listeye alındığında sıra bu başvuru zamanına göre korunur.

Yönetici bu sırayı manuel olarak değiştiremez.

---

# 7. ACCEPTED Başvurunun Yönetilmesi

Kabul edilmiş bir başvuru, etkinlik başlamadan önce yönetici tarafından reddedilebilir.

```text
ACCEPTED → REJECTED
```

Bu işlem yalnızca etkinlik başlamadan önce yapılabilir.

Bu durumda ret nedeni zorunludur.

Ret nedeni öğrenci tarafından görüntülenebilir.

### Örnek

```text
Öğrenci: Ahmet

Durum: ACCEPTED

Yönetici:
"Etkinlik kontenjanı değişti."

Sonuç:

ACCEPTED → REJECTED

Ret nedeni:
"Etkinlik kontenjanı değişti."
```

---

## 7.1. ACCEPTED → REJECTED Sonrası Kapasite

`ACCEPTED → REJECTED` geçişi kabul edilmiş bir kontenjanı boşaltır.

Boşalan kapasite varsa bekleme listesindeki ilk öğrenci sistem tarafından otomatik olarak kabul edilir.

```text
ACCEPTED → REJECTED
        ↓
Kapasite açıldı
        ↓
WAITLISTED sıradaki aday
        ↓
ACCEPTED
```

Yedek listedeki öğrencilerin sırası başvuru zamanına göre korunur.

Yönetici kapasite açıldıktan sonra bekleme listesinden istediği öğrenciyi seçemez.

---

## 7.2. ACCEPTED → PENDING Yasaktır

Kabul edilmiş bir başvuru tekrar `PENDING` durumuna getirilemez.

```text
ACCEPTED → PENDING ❌
```

Yönetici kabul kararını değiştirmek istiyorsa ilgili geçerli durum geçişlerinden birini kullanmalıdır.

---

# 8. REJECTED Başvurunun Yönetilmesi

Reddedilmiş bir başvuru için öğrenci yeniden başvuru yapamaz.

Ancak kulüp yöneticisi önceki ret kararını düzeltebilir:

```text
REJECTED → ACCEPTED
```

Bu işlem yeni bir başvuru oluşturmaz.

Mevcut Application kaydının durumu değiştirilir.

---

## 8.1. Kapasite Kontrolü

`REJECTED → ACCEPTED` işlemi kapasite kurallarına tabidir.

Etkinlik kapasitesi doluysa bu işleme izin verilmez.

```text
Kapasite: 50
ACCEPTED: 50

REJECTED → ACCEPTED ❌
```

Yönetici önce kapasiteyi artırmalıdır veya mevcut kapasitede yer açılmalıdır.

Örneğin:

```text
Kapasite: 50 → 51
        ↓
REJECTED → ACCEPTED ✅
```

Kapasite aşımına izin verilmez.

---

## 8.2. REJECTED → PENDING Yasaktır

```text
REJECTED → PENDING ❌
```

Yönetici öğrenciyi tekrar değerlendirmek istiyorsa başvuruyu `PENDING` durumuna geri döndürmez.

Kapasite uygunsa doğrudan:

```text
REJECTED → ACCEPTED
```

geçişini kullanır.

---

## 8.3. REJECTED → WAITLISTED Yasaktır

Reddedilmiş bir başvuru doğrudan yedek listeye alınamaz.

```text
REJECTED → WAITLISTED ❌
```

Yönetici ret kararını düzeltmek istiyorsa kapasite uygunsa doğrudan `ACCEPTED` durumuna geçiş yapar.

---

# 9. WAITLISTED Başvurular

Yedek liste bir **yedek katılımcı listesidir**.

Yedek listedeki öğrenciler:

* `APPROVAL_REQUIRED` etkinliklerde yönetici tarafından belirlenir.
* `PUBLIC` etkinliklerde sistem tarafından otomatik olarak oluşturulur.
* Başvuru zamanına göre sıralanır.
* Yönetici tarafından manuel olarak yeniden sıralanamaz.
* Kapasite açıldığında sistem tarafından otomatik olarak işlenir.

Öncelik:

```text
Daha erken başvuru
        ↓
Daha yüksek öncelik
```

Yedek listeye alınmış bir öğrencinin etkinliğe uygun görülmesi, öğrencinin doğrudan kabul edildiği anlamına gelmez.

Öğrenci ancak kapasite açıldığında kabul edilir.

---

# 10. Kapasite Açıldığında Otomatik İşlem

Kapasitede yer açıldığında sistem yedek listesini başvuru zamanına göre işler.

Yedek listedeki ilk öğrenci:

```text
WAITLISTED → ACCEPTED
```

durumuna geçirilir.

Bu işlemde yönetici tarafından ayrıca öğrenci seçilmesine gerek yoktur.

## Örnek

Etkinlik kapasitesi:

```text
50 kişi
```

Mevcut durum:

```text
50 ACCEPTED
20 WAITLISTED
```

Kabul edilmiş bir öğrenci etkinliğe katılamayacağını bildirir ve başvurusunu geri çeker:

```text
ACCEPTED → WITHDRAWN
```

Sonrasında:

```text
49 ACCEPTED
20 WAITLISTED
```

durumu oluşur.

Sistem yedek listedeki ilk öğrenciyi kabul eder:

```text
1. WAITLISTED → ACCEPTED
```

Sonuç:

```text
50 ACCEPTED
19 WAITLISTED
```

Aynı kural yöneticinin:

```text
ACCEPTED → REJECTED
```

geçişi sonucunda açılan kapasite için de geçerlidir.

---

# 11. Yedek Listenin Oluşturulması

`APPROVAL_REQUIRED` ve kapasite sınırı bulunan etkinliklerde öğrencilerin tamamı başvuru süresi boyunca `PENDING` durumunda bulunabilir.

Örneğin:

```text
Kapasite: 50
Başvuru sayısı: 100

PENDING: 100
```

Başvuru süresi sona erdikten sonra yönetici başvuruları değerlendirir.

Örneğin yönetici:

```text
50 → ACCEPTED
20 → WAITLISTED
30 → REJECTED
```

şeklinde sonuçlandırabilir.

Bu durumda:

```text
ACCEPTED: 50
WAITLISTED: 20
REJECTED: 30
PENDING: 0
```

olur.

Yönetici yedek listeye aldığı 20 öğrenciyi başvuru zamanına göre sıralar.

Örneğin:

```text
09:01 → Ahmet
09:05 → Mehmet
09:12 → Ayşe
...
```

şeklinde bir sıra oluşur.

Daha sonra bir kişilik kapasite açıldığında:

```text
Ahmet → ACCEPTED
```

olur.

Yedek liste:

```text
19 kişi
```

olarak devam eder.

---

## 11.1. PENDING Başvuruların Tamamlanması

Başvuru süresi sona erdikten sonra yöneticinin tüm `PENDING` başvuruları sonuçlandırması gerekir.

Örneğin:

```text
Kapasite: 50

100 PENDING
```

başvurudan:

```text
50 ACCEPTED
20 WAITLISTED
15 REJECTED
```

belirlendikten sonra:

```text
15 PENDING
```

başvuru kalmış olabilir.

Bu kalan başvuruların `REJECTED` durumuna otomatik geçirilip geçirilmeyeceği henüz kesinleştirilmemiştir.

Dolayısıyla:

```text
PENDING → REJECTED
```

işleminin sistem tarafından otomatik yapılması **açık karar konusudur**.

Kesin olan kural, başvuru değerlendirmesi tamamlandığında etkinliğin normal başvuru yönetimi açısından `PENDING` durumda başvuru bırakılmamasının hedeflenmesidir.

---

# 12. Kapasitenin Artırılması

Etkinliğin kapasitesi artırıldığında mevcut yedek liste sistem tarafından başvuru zamanına göre işlenir.

Örneğin:

```text
Kapasite: 50 → 70

20 kişilik yeni kapasite oluştu.
```

Yedek listede öğrenciler varsa ilk sıradaki öğrenciler otomatik olarak kabul edilir.

```text
WAITLISTED → ACCEPTED
```

Örneğin:

```text
WAITLISTED: 20

Kapasite +20
        ↓

20 WAITLISTED → ACCEPTED
```

Sonuç:

```text
ACCEPTED: 70
WAITLISTED: 0
```

olur.

---

## 12.1. Değerlendirme Henüz Tamamlanmadıysa

`APPROVAL_REQUIRED` etkinlikte kapasite artırıldığı sırada başvurular hâlâ `PENDING` durumundaysa, kapasite artışı bu başvuruları otomatik olarak kabul etmez.

Örneğin:

```text
Kapasite: 50 → 70

PENDING: 100
```

durumunda kalan 20 kişilik kapasite:

```text
PENDING → ACCEPTED
```

işlemini sistemin otomatik olarak yapacağı anlamına gelmez.

Başvurular yine yönetici tarafından değerlendirilir.

Kapasite artışı yalnızca yöneticinin daha fazla başvuruyu kabul edebilmesine olanak sağlar.

---

# 13. Başvuru Tarihi Sıralaması

Yedek listedeki öncelik başvurunun oluşturulma zamanına göre belirlenir.

Örneğin:

```text
09:01 → Ahmet

09:05 → Mehmet

09:12 → Ayşe

09:20 → Zeynep
```

Kapasite 2 kişi açarsa:

```text
Ahmet
Mehmet
```

öncelikli olarak kabul edilir.

Yönetici bu sırayı manuel olarak değiştiremez.

Bu zaman sıralaması, öğrencilerin yedek listeye alınması sırasında da esas alınır.

Yedek listeye sonradan yeni bir öğrenci eklendiğinde öğrencinin mevcut başvuru zamanı dikkate alınır.

---

# 14. Başvuru Geri Çekme (`WITHDRAWN`)

Öğrenci başvurusunu etkinlik başlamadan önce geri çekebilir.

Geçerli geri çekme geçişleri:

```text
PENDING    → WITHDRAWN

WAITLISTED → WITHDRAWN

ACCEPTED   → WITHDRAWN
```

`REJECTED` durumundaki başvurunun geri çekilmesine gerek yoktur.

Etkinlik başladıktan sonra başvuru geri çekilemez.

---

## 14.1. ACCEPTED → WITHDRAWN Sonrası Kapasite

`ACCEPTED → WITHDRAWN` geçişi kapasiteyi boşaltır.

Boşalan kapasite varsa sistem bekleme listesini otomatik olarak işler.

```text
ACCEPTED → WITHDRAWN
        ↓
Kapasite açıldı
        ↓
WAITLISTED sıradaki aday
        ↓
ACCEPTED
```

Yedek liste başvuru zamanına göre normal kurallara göre işlenir.

---

## 14.2. Geri Çekilen Öğrencinin Tekrar Başvurması

`WITHDRAWN` durumuna geçen öğrenci, başvuru süreci hâlâ açıksa aynı etkinliğe tekrar başvurabilir.

Bu yeni başvuru, eski başvurunun devamı değildir.

Yeni bir Application kaydı oluşturulur.

Örneğin:

```text
Application #1
ACCEPTED → WITHDRAWN

        ↓

Yeni başvuru

Application #2
```

şeklinde iki ayrı kayıt bulunabilir.

Eski `WITHDRAWN` başvuru kaydı silinmez.

Yeni başvurunun sonucu etkinliğin başvuru tipine ve mevcut kapasite durumuna göre belirlenir.

`PUBLIC` etkinlikte:

```text
ACCEPTED veya WAITLISTED
```

oluşabilir.

`APPROVAL_REQUIRED` etkinlikte:

```text
PENDING
```

oluşur.

Aynı anda birden fazla aktif başvuru bulunmasına izin verilmez.

---

# 15. Başvuru Son Başvuru Tarihinden Sonra

Başvuru süresi sona erdiğinde yeni öğrenci başvuruları alınmaz.

Ancak bu durum mevcut başvuruların yönetilmesini engellemez.

`APPROVAL_REQUIRED` etkinliklerde yönetici:

* `PENDING` başvuruları kabul edebilir.
* `PENDING` başvuruları reddedebilir.
* Uygun gördüğü öğrencileri yedek listeye alabilir.
* Kapasiteyi artırabilir.
* Açılan kapasite sonucunda mevcut yedek listenin otomatik olarak işlenmesini sağlayabilir.

Örneğin:

```text
Başvuru süresi bitti
        ↓
Yeni başvuru ❌
        ↓
Mevcut başvuruları yönetme ✅
```

Başvuru süresi bittikten sonra mevcut `PENDING` başvuruların yönetici tarafından sonuçlandırılması mümkündür.

`PENDING` başvuruların otomatik olarak reddedilip reddedilmeyeceği ise ayrıca belirlenmelidir.

---

# 16. Etkinlik Başladıktan Sonra

Etkinlik başladıktan sonra başvuru yönetimi sona erer.

Aşağıdaki işlemler yapılamaz:

```text
ACCEPTED → REJECTED ❌

ACCEPTED → WITHDRAWN ❌

PENDING → ACCEPTED ❌

PENDING → REJECTED ❌

PENDING → WAITLISTED ❌

WAITLISTED → ACCEPTED ❌

WAITLISTED → WITHDRAWN ❌

REJECTED → ACCEPTED ❌
```

Başvuru yönetiminin sona ermesinden sonra öğrencinin etkinliğe gerçekten katılıp katılmadığı `Attendance` sistemi üzerinden takip edilir.

---

# 17. Katılım ile Başvurunun Ayrılması

Başvurunun `ACCEPTED` olması öğrencinin etkinliğe katıldığı anlamına gelmez.

Örneğin:

```text
Application:
ACCEPTED

Attendance:
NOT_ATTENDED
```

veya:

```text
Application:
ACCEPTED

Attendance:
ATTENDED
```

olabilir.

Bu nedenle:

```text
Application Status
```

ile:

```text
Attendance
```

ayrı tutulur.

Etkinlik sonrasında kullanıcı arayüzünde kabul edilmiş bir başvuru:

* Katıldı
* Katılmadı

şeklinde gösterilebilir.

Ancak `NOT_ATTENDED` ayrı bir Application status değildir.

---

# 18. Katılım Kayıtlarının Yönetilmesi

Kulüp yöneticileri gerektiğinde katılım kayıtlarını manuel olarak düzeltebilir.

Yetkili roller:

* Başkan
* Başkan Yardımcısı
* Yönetici

Yönetici:

* Katılım kaydı ekleyebilir.
* Hatalı katılım kaydını kaldırabilir.
* Katılım durumunu düzeltebilir.

Bu işlem:

* QR ile otomatik oluşturulan katılım kaydının hatalı olması
* Öğrencinin QR okutamaması
* Sistemin yanlış katılım durumu oluşturması
* Yetkili yöneticinin gerçek katılım bilgisini düzeltmesi

gibi durumlarda kullanılabilir.

Attendance durumları ile ilgili kesin geçiş kuralları ayrı olarak belirlenebilir.

---

# 19. Başvuru Geçişleri

## 19.1. Geçerli Geçişler

```text
PENDING → ACCEPTED
PENDING → REJECTED
PENDING → WAITLISTED    (APPROVAL_REQUIRED, yönetici tarafından)
PENDING → WITHDRAWN     (öğrenci tarafından)

WAITLISTED → ACCEPTED   (kapasite açıldığında, sistem tarafından)
WAITLISTED → WITHDRAWN  (öğrenci tarafından)

ACCEPTED → REJECTED     (yönetici tarafından, etkinlik başlamadan önce)
ACCEPTED → WITHDRAWN    (öğrenci tarafından, etkinlik başlamadan önce)

REJECTED → ACCEPTED     (yönetici tarafından, kapasite uygunsa)
```

`PUBLIC` etkinliklerde başvurunun sonucu doğrudan belirlenir:

```text
Başvuru
   ├── Kapasite uygunsa → ACCEPTED
   └── Kapasite doluysa → WAITLISTED
```

Burada `PENDING` kalıcı bir durum değildir.

---

## 19.2. Geçersiz Geçişler

```text
ACCEPTED  → PENDING       ❌

REJECTED  → PENDING       ❌

REJECTED  → WAITLISTED    ❌

WAITLISTED → REJECTED     ❌

WITHDRAWN → ACCEPTED      ❌

WITHDRAWN → PENDING       ❌

WITHDRAWN → WAITLISTED    ❌

REJECTED  → yeni başvuru  ❌
```

`WITHDRAWN` sonrası yeniden başvuru yapılacaksa eski Application kaydı değiştirilmez; yeni Application kaydı oluşturulur.

---

# 20. Öğrencinin Aynı Etkinliğe Başvurması

Bir öğrenci aynı etkinlik için aynı anda yalnızca bir aktif başvuru kaydına sahip olabilir.

Aktif başvuru durumları:

```text
PENDING

ACCEPTED

WAITLISTED
```

`REJECTED` durumundaki bir başvurudan sonra öğrenci yeni başvuru oluşturamaz.

Yönetici kararını değiştirmek isterse:

```text
REJECTED → ACCEPTED
```

geçişini kullanır.

Yeni bir başvuru oluşturulmaz.

`WITHDRAWN` durumundaki başvurudan sonra öğrenci, başvuru süresi açıksa yeni başvuru oluşturabilir.

Bu yeni başvuru eski kaydın devamı değildir.

Eski kayıt silinmez.

---

# 21. Yetki Özeti

| İşlem                                    | Başkan | Başkan Yardımcısı | Yönetici |
| ---------------------------------------- | :----: | :---------------: | :------: |
| Başvuruları görüntüleme                  |    ✅   |         ✅         |     ✅    |
| `PENDING → ACCEPTED`                     |    ✅   |         ✅         |     ✅    |
| `PENDING → REJECTED`                     |    ✅   |         ✅         |     ✅    |
| `PENDING → WAITLISTED`                   |    ✅   |         ✅         |     ✅    |
| `ACCEPTED → REJECTED`                    |    ✅   |         ✅         |     ✅    |
| `REJECTED → ACCEPTED` (kapasite uygunsa) |    ✅   |         ✅         |     ✅    |
| Bekleme listesini oluşturma              |    ✅   |         ✅         |     ✅    |
| Bekleme listesini manuel sıralama        |    ❌   |         ❌         |     ❌    |
| Katılım kaydı ekleme                     |    ✅   |         ✅         |     ✅    |
| Katılım kaydı silme/düzeltme             |    ✅   |         ✅         |     ✅    |

Yedek listedeki öğrencilerin sırası başvuru zamanına göre belirlendiği için yöneticilerin bu sırayı manuel olarak değiştirmesine izin verilmez.

Başvuru geri çekme (`WITHDRAWN`) öğrenci tarafından gerçekleştirilir, yönetici tarafından değil.

---

# 22. Sistem Tarafından Otomatik Gerçekleştirilen İşlemler

Sistem aşağıdaki işlemleri otomatik olarak gerçekleştirir.

## 22.1. PUBLIC Başvurularının Sonuçlandırılması

`PUBLIC` etkinliklerde başvuru oluşturulduğunda sistem kapasiteyi kontrol eder.

Kapasite uygunsa:

```text
Başvuru
   ↓
ACCEPTED
```

Kapasite doluysa:

```text
Başvuru
   ↓
WAITLISTED
```

`PENDING` bu süreçte kalıcı olarak oluşturulmaz.

---

## 22.2. Kapasite Açılması

Kapasite açıldığında sistem bekleme listesini başvuru zamanına göre işler.

```text
Kapasite açıldı
      ↓
WAITLISTED öğrenciler başvuru zamanına göre sıralı
      ↓
İlk uygun öğrenci
      ↓
ACCEPTED
```

Kapasite birden fazla kişi açtıysa aynı sayıda öğrenci sırayla kabul edilir.

---

## 22.3. ACCEPTED Başvurunun Geri Çekilmesi

Bir öğrenci:

```text
ACCEPTED → WITHDRAWN
```

yaptığında bir kişilik kapasite açılır.

Sistem mevcut bekleme listesini kontrol eder.

Bekleme listesi varsa ilk öğrenci:

```text
WAITLISTED → ACCEPTED
```

olur.

---

## 22.4. ACCEPTED Başvurunun Yönetici Tarafından Reddedilmesi

Yönetici:

```text
ACCEPTED → REJECTED
```

yaptığında kapasite açılır.

Sistem bekleme listesini kontrol eder ve ilk öğrenciyi otomatik olarak kabul eder.

---

## 22.5. Kapasite Artırılması

Kapasite artırıldığında sistem mevcut `WAITLISTED` başvuruları otomatik olarak işler.

Örneğin:

```text
Kapasite: 50 → 55

WAITLISTED: 10
```

ise:

```text
5 WAITLISTED → ACCEPTED
```

olur.

Sonuç:

```text
ACCEPTED: +5
WAITLISTED: -5
```

şeklinde olur.

Henüz değerlendirilmemiş `PENDING` başvurular varsa kapasite artışı onları otomatik olarak kabul etmez.

Bu başvurular yönetici tarafından ayrıca değerlendirilir.

---

## 22.6. APPROVAL_REQUIRED Başvurularının Yönetilmesi

`APPROVAL_REQUIRED` etkinliklerde sistem başvuruyu:

```text
PENDING
```

durumunda tutar.

Yönetici değerlendirmesi sonucunda:

```text
PENDING
   ├──→ ACCEPTED
   ├──→ REJECTED
   └──→ WAITLISTED
```

geçişlerinden biri gerçekleşebilir.

`PENDING → WAITLISTED` yalnızca kapasitesi bulunan `APPROVAL_REQUIRED` etkinliklerde kullanılabilir.

---

## 22.7. Başvuru Değerlendirmesinin Tamamlanması

Başvuru süresi sona erdiğinde yeni başvuru alınmaz.

Mevcut `PENDING` başvuruların değerlendirilmesi devam edebilir.

Yönetici yeterli sayıda:

* `ACCEPTED`
* `WAITLISTED`
* `REJECTED`

kararı verdikten sonra başvuru değerlendirme süreci tamamlanır.

Kalan `PENDING` başvuruların sistem tarafından otomatik olarak `REJECTED` durumuna geçirilip geçirilmeyeceği henüz kesinleştirilmemiştir.

---

## 22.8. Etkinlik Başlangıcı

Etkinlik başladığında:

```text
Etkinlik başladı
      ↓
Başvuru kararları artık değiştirilemez
      ↓
Attendance süreci devam eder
```

Bu noktadan sonra `Application` durumları değiştirilmez.

---

# 23. Use Case Akışı

## 23.1. Genel Akış

```text
Kulüp yöneticisi
      ↓
Etkinliği seçer
      ↓
Başvuruları görüntüler
      ↓
Başvuru durumunu inceler
      ↓
Başvuru tipini kontrol eder
      ↓
APPROVAL_REQUIRED ise PENDING başvuruları değerlendirir
      ↓
Kabul / Ret / Yedek
      ↓
Kapasite açılırsa
      ↓
Sistem WAITLISTED listesini işler
      ↓
İlk sıradaki öğrenci ACCEPTED
```

---

## 23.2. PUBLIC Etkinlik Akışı

`PUBLIC` etkinliklerde yönetici tarafından tek tek başvuru değerlendirmesi yapılmaz.

```text
Öğrenci başvurur
      ↓
Kapasite kontrolü
      │
      ├── Kapasite uygunsa
      │        ↓
      │     ACCEPTED
      │
      └── Kapasite doluysa
               ↓
          WAITLISTED
```

Kapasite açıldığında:

```text
WAITLISTED
      ↓
Başvuru zamanına göre sıradaki öğrenci
      ↓
ACCEPTED
```

---

## 23.3. APPROVAL_REQUIRED Etkinlik Akışı

```text
Öğrenci başvurur
      ↓
PENDING
      ↓
Başvuru süresi sona erer
      ↓
Yönetici değerlendirir
      │
      ├──→ ACCEPTED
      │
      ├──→ REJECTED
      │
      └──→ WAITLISTED
```

Yedek liste oluşturulduktan sonra kapasite açılırsa:

```text
WAITLISTED
      ↓
Başvuru zamanına göre sıradaki öğrenci
      ↓
ACCEPTED
```

---

# 24. Karar Verilmemiş Konular

Aşağıdaki konular bu use case kapsamında henüz kesinleştirilmemiştir:

## 24.1. Normal PENDING → REJECTED Ret Nedeni

Normal bir:

```text
PENDING → REJECTED
```

işleminde ret nedeninin zorunlu olup olmayacağı.

`ACCEPTED → REJECTED` işleminde ret nedeni zorunludur.

---

## 24.2. Ret Nedeni Yapısı

Ret nedenlerinin:

* Serbest metin
* Önceden belirlenmiş seçenekler
* Kategori + açıklama

şeklinde tutulup tutulmayacağı.

---

## 24.3. Başvuru Listesinde Gösterilecek Öğrenci Bilgileri

Yöneticinin başvuru listesinde hangi öğrenci bilgilerinin gösterileceği henüz kesinleştirilmemiştir.

Örneğin:

* Ad
* Soyad
* Öğrenci numarası
* Fakülte
* Bölüm
* Profil bilgileri

gibi alanların hangilerinin gösterileceği ayrıca belirlenebilir.

---

## 24.4. PENDING Başvuruların Son Başvuru Tarihinden Sonra Sonuçlandırılması

Başvuru süresi sona erdiğinde mevcut `PENDING` başvuruların:

* Yöneticinin manuel kararıyla mı
* Sistem tarafından belirli bir koşulda otomatik olarak mı

`REJECTED` durumuna geçirileceği henüz kesinleştirilmemiştir.

---

## 24.5. Başvuru Geçmişinin Ayrıntı Seviyesi

Başvurunun yalnızca son durumu mu, yoksa tüm durum değişikliklerinin:

```text
PENDING
↓
ACCEPTED
↓
WITHDRAWN
```

gibi geçmişinin de tutulacağı henüz kesinleştirilmemiştir.

Mevcut Application kaydının korunması kesin olmakla birlikte, ayrıntılı status history yapısının ayrıca oluşturulup oluşturulmayacağı daha sonra belirlenebilir.

---

## 24.6. ACCEPTED → WITHDRAWN Zaman Sınırı

Öğrencinin `ACCEPTED → WITHDRAWN` işlemini etkinlik başlamadan ne kadar süre öncesine kadar gerçekleştirebileceği henüz ayrıca belirlenmemiştir.

Mevcut temel kural:

```text
Etkinlik başlamadı → WITHDRAWN mümkün

Etkinlik başladı → WITHDRAWN mümkün değil
```

şeklindedir.

---

## 24.7. Attendance Düzeltme Geçmişi

Yöneticinin Attendance üzerinde yaptığı manuel düzeltmelerin:

* Kim tarafından yapıldığı
* Ne zaman yapıldığı
* Eski değer
* Yeni değer

gibi bilgilerin kullanıcıya gösterilip gösterilmeyeceği henüz kesinleştirilmemiştir.

---

## 24.8. Attendance Geçiş Kuralları

Attendance durumlarının:

```text
NULL
ATTENDED
NOT_ATTENDED
```

arasındaki kesin geçiş kuralları henüz ayrıca belirlenmemiştir.

Bu nedenle UC-03 yalnızca yetkili yöneticinin Attendance kaydını düzeltebileceğini tanımlar.

---

# 25. Gelecekte Planlanmış Özellikler

Ban/engelleme sistemi bu aşamada MVP kapsamında değildir.

Gelecekte bir kulüp bir kullanıcıyı engellerse bu durumun başvuru akışına etkisi ayrıca tasarlanacaktır.

Örneğin:

* Başvuru yapabilme
* Başvurunun otomatik reddedilmesi
* Mevcut `ACCEPTED` başvurunun etkilenmesi
* Bekleme listesindeki durum
* Ban süresinin etkinlik tarihine göre değerlendirilmesi

gibi kurallar ayrı bir tasarım konusu olacaktır.

Bu nedenle `BAN`, Application status olarak kullanılmaz.

---

# 26. Kapsam Dışı Konular

Bu use case aşağıdaki konuları kapsamaz:

* Öğrencinin etkinlik keşfetmesi
* Öğrencinin etkinliğe ilk kez başvurması
* Etkinlik oluşturma ve yayınlama
* Kulüp oluşturma ve kulüp doğrulama
* Bildirimlerin gönderilmesi
* Etkinlik puanlama/değerlendirme
* Kulüp takip etme
* Global admin işlemleri
* Gelecekteki ban/engelleme sistemi

Bu işlemler ilgili use case'lerde ele alınacaktır.

---

# 27. İlgili Use Case'ler

* **UC01 — Öğrencinin Etkinliğe Başvurması ve Katılması**
* **UC02 — Kulübün Etkinlik Oluşturması ve Yayınlaması**
* **UC04 — Bildirimlerin Yönetilmesi** *(planlandı)*
