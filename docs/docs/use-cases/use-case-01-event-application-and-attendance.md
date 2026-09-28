# Use Case 01 — Öğrencinin Etkinliğe Başvurması ve Katılması

## 1. Amaç

Bu use case, öğrencinin bir etkinliği görüntülemesi, etkinliğe başvurması, başvuru sonucunu takip etmesi, başvurusunu geri çekebilmesi ve etkinliğe katılımının sisteme kaydedilmesini tanımlar.

Bu akış kapsamında:

* Etkinliğe başvurma
* Başvuru durumunun belirlenmesi
* Kontenjan ve bekleme listesi
* Başvurunun geri çekilmesi (`WITHDRAWN`)
* Geri çekilen başvuru sonrası tekrar başvurma
* Etkinliğe katılım
* QR kod ile katılım (fiziksel etkinliklerde)
* Katılım kaydının yönetici tarafından düzeltilmesi

ele alınır.

---

## 2. Aktörler

### Ana Aktör

* Öğrenci

### İlgili Aktörler

* Kulüp yöneticisi
* Sistem

---

## 3. Ön Koşullar

Öğrencinin etkinliğe başvurabilmesi için:

* Sisteme giriş yapmış olması gerekir.
* Etkinliğin `PUBLISHED` durumunda olması gerekir.
* Etkinliğin iptal edilmemiş olması gerekir.
* Başvuru başlangıç tarihinin gelmiş olması gerekir.
* Başvuru bitiş tarihinin geçmemiş olması gerekir.
* Öğrencinin aynı etkinlikte aktif bir başvurusunun bulunmaması gerekir.

> **Not:** Öğrencinin daha önceki başvurusu `WITHDRAWN` durumundaysa ve başvuru süreci hâlâ açıksa yeni bir başvuru oluşturabilir. Detaylar için bkz. Bölüm 7.2.

---

# 4. Etkinliğe Başvurma

Öğrenci etkinlik detaylarını görüntüler ve başvuru koşullarını karşılıyorsa etkinliğe başvurabilir.

Başvurunun sonucu, etkinliğin başvuru türüne ve kapasite durumuna göre belirlenir.

Başvuru türleri:

* `PUBLIC`
* `APPROVAL_REQUIRED`

---

## 4.1. Herkese Açık Etkinlik

Etkinlik `PUBLIC` ise yönetici onayı gerekmez.

### Kapasite belirtilmemişse

Etkinlikte kapasite sınırı bulunmadığından başvuru doğrudan kabul edilir.

```text
Başvuru
   ↓
ACCEPTED
```

### Kapasite belirtilmiş ve kontenjan uygunsa

Kapasitede yer bulunuyorsa başvuru doğrudan kabul edilir.

```text
Başvuru
   ↓
ACCEPTED
```

### Kapasite dolmuşsa

Yeni başvuru bekleme listesine alınır.

```text
Başvuru
   ↓
WAITLISTED
```

Bekleme listesine alınan kullanıcıların sırası başvuru zamanına göre belirlenir.

Yönetici onayı gerekmez.

> `PUBLIC` etkinliklerde `PENDING`, kalıcı bir Application status olarak kullanılmaz. Başvuru sonucu kapasiteye göre doğrudan `ACCEPTED` veya `WAITLISTED` olur.

---

## 4.2. Onay Gerektiren Etkinlik

Etkinlik `APPROVAL_REQUIRED` ise başvurular kulüp yöneticisi tarafından değerlendirilir.

Başvuru süresi devam ederken yeni başvuru:

```text
Başvuru
   ↓
PENDING
```

durumunda oluşturulur.

Kapasitenin dolmuş olması, başvuru süresi devam ederken yeni başvurunun oluşturulmasını engellemez.

Başvuru süresi sona erdikten sonra yönetici başvuruları değerlendirir:

```text
PENDING
   ├──→ ACCEPTED
   ├──→ WAITLISTED
   └──→ REJECTED
```

`WAITLISTED`, yalnızca kapasitesi bulunan `APPROVAL_REQUIRED` etkinliklerde yedek adaylar için kullanılabilir.

Kapasitesi bulunmayan `APPROVAL_REQUIRED` etkinliklerde yönetici başvuruyu:

```text
PENDING
   ├──→ ACCEPTED
   └──→ REJECTED
```

şeklinde sonuçlandırır.

Bu işlemler **Use Case 03 — Kulübün Etkinlik Başvurularını Yönetmesi** kapsamında ele alınır.

---

# 5. Kontenjan

Etkinlik oluşturulurken kapasite belirtilmesi isteğe bağlıdır.

## 5.1. Kapasite Belirtilmemişse

Etkinlikte kapasite sınırı bulunmaz.

Başvurular kapasite nedeniyle bekleme listesine alınmaz.

`PUBLIC` etkinliklerde başvurular doğrudan `ACCEPTED` olur.

`APPROVAL_REQUIRED` etkinliklerde başvurular `PENDING` durumunda tutulur ve yönetici tarafından `ACCEPTED` veya `REJECTED` olarak sonuçlandırılır.

---

## 5.2. Kapasite Dolmuşsa

Kapasitenin dolmuş olması, her etkinlik türünde yeni başvurunun aynı şekilde sonuçlanacağı anlamına gelmez.

### PUBLIC etkinliklerde

Kapasite dolduktan sonra yeni başvurular:

```text
WAITLISTED
```

durumuna otomatik olarak geçer.

### APPROVAL_REQUIRED etkinliklerde

Başvuru süresi devam ettiği sürece kapasitenin dolmuş olması yeni başvuruyu engellemez.

Yeni başvuru:

```text
PENDING
```

durumunda oluşturulur.

Başvuru süresi sona erdikten sonra yönetici başvuruları değerlendirerek:

* uygun kişileri `ACCEPTED`,
* yedek olarak belirlediği kişileri `WAITLISTED`,
* diğer kişileri `REJECTED`

durumuna getirir.

---

# 6. Bekleme Listesi

Bekleme listesi, mevcut kapasite nedeniyle doğrudan kabul edilemeyen veya `APPROVAL_REQUIRED` etkinliklerde yönetici tarafından yedek aday olarak belirlenen öğrencilerin tutulduğu yedek listedir.

Bekleme listesinde öncelik başvuru zamanına göre belirlenir.

Daha önce başvuran kullanıcı daha önceliklidir.

Bekleme listesi:

* `PUBLIC` etkinliklerde sistem tarafından otomatik olarak oluşturulur.
* `APPROVAL_REQUIRED` ve kapasitesi bulunan etkinliklerde yönetici tarafından değerlendirme sırasında oluşturulur.

Kapasite açıldığında bekleme listesindeki ilk uygun aday işleme alınır.

---

## 6.1. PUBLIC Etkinlik

`PUBLIC` etkinliklerde kapasite açıldığında bekleme listesindeki ilk aday otomatik olarak kabul edilir.

```text
WAITLISTED
     ↓
ACCEPTED
```

Örneğin:

```text
Kapasite: 50

ACCEPTED: 50

WAITLISTED:
#1
#2
#3
```

Bir `ACCEPTED` öğrenci ayrılırsa:

```text
1 kişilik kontenjan açılır
        ↓
WAITLIST #1
        ↓
ACCEPTED
```

olur.

Yönetici bekleme listesinden manuel olarak kişi seçmek zorunda değildir.

---

## 6.2. APPROVAL_REQUIRED Etkinlik

`APPROVAL_REQUIRED` ve kapasitesi bulunan etkinliklerde bekleme listesi, yönetici tarafından başvurular değerlendirilirken oluşturulur.

Örneğin:

```text
Kapasite: 50
Toplam başvuru: 100

ACCEPTED: 50
WAITLISTED: 20
REJECTED: 30
```

Buradaki 20 öğrenci, kabul edilen öğrencilerden birinin ayrılması veya kabul durumunun sonradan değişmesi halinde kullanılabilecek yedek adaylardır.

Kapasite açıldığında bekleme listesindeki ilk aday:

```text
WAITLISTED
     ↓
ACCEPTED
```

durumuna geçirilir.

Bekleme listesindeki sıra başvuru zamanına göre korunur.

Yönetici bekleme listesindeki adayları manuel olarak yeniden sıralayamaz.

---

## 6.3. Kontenjan Açılması

Kontenjan aşağıdaki durumlarda açılabilir:

* Yönetici kapasiteyi artırabilir.
* Daha önce kabul edilmiş bir başvuru yönetici tarafından reddedilebilir.
* Daha önce kabul edilmiş bir başvuru öğrenci tarafından geri çekilebilir (`ACCEPTED → WITHDRAWN`).

Açılan kontenjan, bekleme listesindeki sıraya göre değerlendirilir.

Örneğin:

```text
Kapasite: 50

ACCEPTED: 50
WAITLISTED: 10
```

5 `ACCEPTED` başvurudan biri geri çekilirse:

```text
1 kişilik kontenjan açılır
        ↓
Bekleme listesindeki ilk aday
        ↓
ACCEPTED
```

olur.

Sonuç:

```text
ACCEPTED: 50
WAITLISTED: 9
```

olur.

Bu işlem:

* `PUBLIC` etkinliklerde sistem tarafından otomatik gerçekleştirilir.
* `APPROVAL_REQUIRED` ve kapasitesi bulunan etkinliklerde, yöneticinin oluşturduğu bekleme listesindeki ilk uygun aday için sistem tarafından gerçekleştirilir.

---

# 7. Başvuru Geri Çekme

Öğrenci başvurusunu etkinlik başlamadan önce geri çekebilir.

Geri çekilen başvuru `WITHDRAWN` durumuna geçer.

Geçerli geçişler:

```text
PENDING    → WITHDRAWN
WAITLISTED → WITHDRAWN
ACCEPTED   → WITHDRAWN
```

`REJECTED` durumundaki başvurunun geri çekilmesine gerek yoktur.

Etkinlik başladıktan sonra başvuru geri çekilemez.

---

## 7.1. ACCEPTED → WITHDRAWN ve Kapasite

Kabul edilmiş bir başvuru geri çekildiğinde kapasite boşalır.

```text
ACCEPTED → WITHDRAWN
        ↓
Kapasite açıldı
        ↓
WAITLISTED sıradaki aday işlenir
```

Bekleme listesindeki ilk aday `ACCEPTED` durumuna geçirilir.

Hem `PUBLIC` hem de `APPROVAL_REQUIRED` etkinliklerde bekleme listesinin sırası başvuru zamanına göre korunur.

---

## 7.2. Geri Çekilen Öğrencinin Tekrar Başvurması

`WITHDRAWN` durumuna geçen öğrenci, başvuru süreci hâlâ açıksa aynı etkinliğe tekrar başvurabilir.

Bu yeni başvuru, eski başvurunun devamı değildir; yeni bir `Application` kaydı olarak oluşturulur.

Örneğin:

```text
Eski başvuru:

ACCEPTED → WITHDRAWN


Yeni başvuru:

PUBLIC:
ACCEPTED / WAITLISTED

APPROVAL_REQUIRED:
PENDING
```

Yeni başvurunun sonucu etkinliğin başvuru türüne ve kapasite durumuna göre belirlenir.

Öğrencinin aynı anda aynı etkinlik için birden fazla aktif başvurusu bulunamaz.

Eski `WITHDRAWN` başvuru kaydı silinmez; başvuru geçmişi korunur.

---

# 8. Aynı Etkinliğe Başvurma Kuralları

Öğrencinin aynı etkinlikte aynı anda yalnızca bir aktif başvurusu olabilir.

Öğrenci aşağıdaki durumlardayken yeni bir başvuru oluşturamaz:

* `PENDING`
* `ACCEPTED`
* `WAITLISTED`

`REJECTED` durumundaki bir başvurudan sonra öğrenci yeni başvuru oluşturamaz.

Ancak yönetici daha önce reddedilmiş başvuruyu tekrar kabul edebilir:

```text
REJECTED → ACCEPTED
```

Bu işlem kapasite kurallarına tabidir.

Kapasite doluysa `REJECTED → ACCEPTED` işlemi yapılamaz.

Bu durumda öğrencinin yeniden başvuru yapmasına gerek yoktur.

`WITHDRAWN` sonrası tekrar başvuru kuralları için bkz. Bölüm 7.2.

---

# 9. Başvuru Süresi

Yeni başvurular yalnızca belirlenen başvuru tarihleri arasında oluşturulabilir.

Başvuru başlangıç tarihi gelmeden başvuru yapılamaz.

Başvuru bitiş tarihi geçtikten sonra yeni başvuru oluşturulamaz.

Ancak başvuru süresinin bitmiş olması mevcut başvuruların yönetilmesine engel değildir.

Özellikle `APPROVAL_REQUIRED` etkinliklerde başvuru süresi sona erdikten sonra mevcut `PENDING` başvurular yönetici tarafından değerlendirilebilir.

Başvuru sürecinin sonunda ilgili başvuruların `PENDING` durumunda belirsiz şekilde bırakılmaması gerekir.

Mevcut:

* `PENDING`
* `WAITLISTED`

başvurular ilgili kurallara göre işlem görmeye devam edebilir.

> `PENDING` başvuruların başvuru süresi sonunda otomatik olarak `REJECTED` edilip edilmeyeceği henüz kesinleştirilmemiştir.

---

# 10. Başvuru Durumları

Temel başvuru durumları:

| Durum        | Açıklama                                                    |
| ------------ | ----------------------------------------------------------- |
| `PENDING`    | Başvuru yapılmış ancak henüz nihai sonucu belirlenmemiştir. |
| `ACCEPTED`   | Başvuru kabul edilmiştir.                                   |
| `REJECTED`   | Başvuru reddedilmiştir.                                     |
| `WAITLISTED` | Öğrenci yedek listesinde beklemektedir.                     |
| `WITHDRAWN`  | Öğrenci başvurusunu geri çekmiştir.                         |

`PENDING`, özellikle `APPROVAL_REQUIRED` etkinliklerde yönetici değerlendirmesini bekleyen başvuruları ifade eder.

`PUBLIC` etkinliklerde başvuru kapasiteye göre doğrudan `ACCEPTED` veya `WAITLISTED` olur.

`BAN` bir Application status değildir.

`NOT_ATTENDED` bir Application status değildir; attendance ayrı bir kavramdır.

---

# 11. Başvuru Durum Geçişleri

Geçerli temel geçişler:

```text
PENDING
 ├──→ ACCEPTED
 ├──→ REJECTED
 ├──→ WAITLISTED
 └──→ WITHDRAWN


WAITLISTED
 ├──→ ACCEPTED
 └──→ WITHDRAWN


ACCEPTED
 ├──→ REJECTED
 └──→ WITHDRAWN


REJECTED
 └──→ ACCEPTED
```

`WAITLISTED → ACCEPTED` geçişi kapasite açıldığında sistem tarafından otomatik gerçekleştirilebilir.

### Geçersiz Geçişler

```text
ACCEPTED  → PENDING      ❌
ACCEPTED  → WAITLISTED   ❌

REJECTED  → PENDING      ❌
REJECTED  → WAITLISTED   ❌

WITHDRAWN → ACCEPTED     ❌
WITHDRAWN → PENDING      ❌
WITHDRAWN → WAITLISTED   ❌
```

`WITHDRAWN` sonrası yeniden başvuru yapılması durumunda mevcut Application değiştirilmez; yeni bir Application oluşturulur.

---

# 12. Etkinliğe Katılım

Kabul edilmiş öğrenciler etkinliğe katılabilir.

Katılım, başvuru durumundan ayrı bir bilgi olarak değerlendirilir.

Örneğin:

```text
Başvuru:
ACCEPTED

Katılım:
ATTENDED
```

Bu nedenle `ATTENDED`, doğrudan bir Application status değildir.

Attendance ayrı bir kayıt/model üzerinden takip edilir.

---

# 13. QR Kod ile Katılım

Fiziksel etkinliklerde QR kod kullanılarak katılım kaydı oluşturulabilir.

Öğrenci QR kodu tarattığında sistem gerekli kontrolleri yaparak katılım kaydı oluşturur.

Başarılı katılım:

```text
Application:
ACCEPTED

        ↓

Attendance:
ATTENDED
```

şeklinde kaydedilir.

QR ile katılım için öğrencinin etkinliğe kabul edilmiş olması gerekir.

> Online etkinliklerde QR kodun nasıl kullanılacağı henüz kesinleştirilmemiştir. Bkz. Bölüm 17.2.

---

# 14. Katılmama

Öğrenci `ACCEPTED` durumunda olmasına rağmen etkinliğe katılmadıysa Application statusü değiştirilmez.

Katılmama durumu Attendance üzerinden takip edilir.

```text
Application:
ACCEPTED

Attendance:
NOT_ATTENDED
```

şeklinde tutulabilir.

`NOT_ATTENDED`, Application status değildir.

Bu sayede:

* öğrencinin etkinliğe kabul edilmesi,
* öğrencinin gerçekten etkinliğe katılması

birbirinden bağımsız olarak takip edilir.

---

# 15. Manuel Katılım Düzeltmesi

İlk sürümde yetkili kulüp yöneticileri katılım kayıtlarını manuel olarak düzeltebilir.

Örneğin:

* QR okutulmamış ancak öğrenci etkinliğe katılmışsa katılım eklenebilir.
* Hatalı oluşturulmuş katılım kaydı düzeltilebilir.
* Yanlış oluşturulmuş bir katılım kaydı kaldırılabilir.

Bu yetki:

* Başkan (`PRESIDENT`)
* Başkan Yardımcısı (`VICE_PRESIDENT`)
* Yönetici (`MANAGER`)

rollerine verilir.

Manuel attendance işlemleri Application statusünü değiştirmez.

> Attendance durumları arasındaki tüm manuel geçişlerin kesin sınırları henüz ayrıca belirlenmemiştir.

---

# 16. Ön Koşullar — Özet

| Koşul                           | Açıklama                                    |
| ------------------------------- | ------------------------------------------- |
| Sisteme giriş yapılmış olmalı   | Kimliği doğrulanmış kullanıcı gerektirir    |
| Etkinlik yayınlanmış olmalı     | `PUBLISHED` durumunda olmalı                |
| Etkinlik iptal edilmemiş olmalı | `CANCELLED` etkinliğe başvurulamaz          |
| Başvuru süresi açık olmalı      | Başvuru başlangıcı ≤ şimdi < başvuru bitişi |
| Aktif başvuru bulunmamalı       | Aynı anda tek aktif başvuruya izin verilir  |

`WITHDRAWN` durumundaki eski başvurular aktif başvuru olarak değerlendirilmez.

---

# 17. Karar Verilmemiş Konular

Bu use case kapsamında aşağıdaki konular henüz kesinleştirilmemiştir:

### 17.1. Normal Ret Gerekçesi

`PENDING → REJECTED` işleminde yöneticinin ret gerekçesi girmesinin zorunlu olup olmadığı henüz kararlaştırılmamıştır.

Ancak:

```text
ACCEPTED → REJECTED
```

işleminde gerekçe zorunludur.

### 17.2. Online Etkinliklerde QR Kullanımı

Online etkinliklerde QR kod ile katılım doğrulamasının nasıl gerçekleştirileceği henüz kesinleştirilmemiştir.

Fiziksel etkinliklerde QR ile katılım doğrulaması planlanmaktadır.

Online etkinliklerdeki katılım doğrulama yöntemi ayrıca değerlendirilecektir.

### 17.3. Ret Nedeni Yapısı

Ret bilgisinin nasıl tutulacağı:

* serbest metin,
* önceden tanımlı kategoriler,
* veya her ikisi

şeklinde olabilir.

Veri modeli detayları domain model aşamasında belirlenecektir.

### 17.4. Başvuru Süresi Sonunda PENDING Başvurular

`APPROVAL_REQUIRED` etkinliklerde başvuru süresi sona erdiğinde hâlâ `PENDING` olan başvuruların:

* otomatik olarak `REJECTED` edilmesi,
* veya yönetici tarafından tamamının manuel olarak sonuçlandırılması

konusu henüz kesinleştirilmemiştir.

### 17.5. Bildirimler

Başvuru durumlarının değişmesi sonucunda öğrenciye veya yöneticilere gönderilecek bildirimler henüz bu use case kapsamında tanımlanmamıştır.

Bildirim sistemi ayrı bir use case olarak ele alınacaktır.

---

# 18. İlgili Use Case'ler

Bu use case aşağıdaki use case'lerle doğrudan ilişkilidir:

* **Use Case 02 — Kulübün Etkinlik Oluşturması ve Yayınlaması**
* **Use Case 03 — Kulübün Etkinlik Başvurularını Yönetmesi**
