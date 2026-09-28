# UC02 — Etkinliğin Oluşturulması ve Yönetilmesi — API Endpointleri

## 1. Amaç

Bu endpointler, kulüp yöneticilerinin kendi kulüplerine ait etkinlikleri oluşturmasını, yayınlamasını, etkinlik bilgilerini yönetmesini, kapasite ve başvuru kurallarını düzenlemesini ve etkinliği iptal etmesini kapsar.

Etkinlik oluşturma işlemi ile yayınlama işlemi ayrı değildir.

Başarılı bir oluşturma işlemi sonucunda `Event` doğrudan:

```text
PUBLISHED
```

durumunda oluşturulur.

Etkinlik başvurularının yönetilmesi UC-03, öğrencinin etkinliğe başvurması ve katılım süreci UC-01 kapsamında ele alınır.

---

# 2. Yetki

Etkinlik yönetimi gerektiren endpointlerde kullanıcının:

* sisteme giriş yapmış olması,
* ilgili kulübün aktif bir yöneticisi olması,
* `ClubMember` üzerinden ilgili kulüpte aşağıdaki rollerden birine sahip olması

gerekir:

```text
PRESIDENT
VICE_PRESIDENT
MANAGER
```

Kullanıcı yalnızca yöneticisi olduğu kulübün etkinliklerini yönetebilir.

Normal öğrenci veya yalnızca kulübü takip eden kullanıcı etkinlik yönetimi endpointlerini kullanamaz.

Global `ADMIN` normal kulüp etkinliklerini kulüp yöneticisi yerine yönetmez. Global admin işlemleri bu endpointlerin kapsamında değildir.

---

# 3. API Endpointleri

## 3.1. Etkinlik Oluşturma ve Yayınlama

### `POST /clubs/{clubId}/events`

Belirtilen kulüp adına yeni bir etkinlik oluşturur ve doğrudan yayınlar.

Etkinlik oluşturma ve yayınlama ayrı endpointler değildir.

Başarılı işlem sonucunda:

```text
Event.status = PUBLISHED
```

olur.

### Yetki

Yalnızca ilgili kulübün aktif:

* `PRESIDENT`
* `VICE_PRESIDENT`
* `MANAGER`

rollerinden birine sahip kullanıcıları kullanabilir.

### Oluşturma sırasında belirlenen bilgiler

Etkinlik oluşturulurken temel olarak:

* `name`
* `description`
* `image`
* `eventType`
* `startAt`
* `endAt`
* `location` veya `onlineLink`
* `applicationStartAt`
* `applicationEndAt`
* `applicationType`
* `capacity`

belirlenir.

`capacity` isteğe bağlıdır.

### Temel doğrulamalar

Oluşturma sırasında en azından:

```text
applicationStartAt < applicationEndAt < startAt < endAt
```

zaman ilişkisi korunmalıdır.

Etkinlik türüne göre ilgili alanların geçerli olması gerekir:

```text
PHYSICAL → location
ONLINE   → onlineLink
```

Başvuru tipi:

```text
PUBLIC
APPROVAL_REQUIRED
```

olmalıdır.

Kapasite belirtilmişse negatif veya geçersiz bir değer kabul edilmez.

### Sonuç

Başarılı oluşturma sonucunda yeni `Event` kaydı:

```text
PUBLISHED
```

durumunda oluşturulur.

Etkinliği oluşturan kullanıcı:

```text
createdBy = currentUser
```

şeklinde kaydedilir.

Kalıcı `DRAFT` veya `CREATED` event status'u oluşturulmaz.

---

# 3.2. Etkinlik Detayını Görüntüleme

### `GET /events/{eventId}`

Belirli bir etkinliğin detaylarını getirir.

Bu endpoint UC-01 ile ortak kullanılabilir.

Yanıtta etkinliğin temel bilgilerinin yanında, giriş yapmış kullanıcının kendi başvuru ve katılım özeti de bulunabilir.

Örneğin:

```text
applicationStatus:
null
PENDING
ACCEPTED
WAITLISTED
REJECTED
WITHDRAWN
```

ve:

```text
attendanceStatus:
null
ATTENDED
NOT_ATTENDED
```

şeklinde bilgiler döndürülebilir.

Böylece istemcinin etkinlik ekranını oluşturmak için ayrı ayrı:

```text
GET /events/{eventId}
GET /events/{eventId}/application
GET /...
```

çağrıları yapması zorunlu değildir.

> Bu endpointin öğrenciye ait başvuru/katılım özetini içerip içermeyeceği response contract aşamasında kesinleştirilecektir. Ancak ayrı endpoint sayısını azaltmak amacıyla tek response içinde sunulması tercih edilen tasarımdır.

---

# 3.3. Etkinlik Bilgilerini Düzenleme

### `PATCH /events/{eventId}`

Yayınlanmış bir etkinliğin değiştirilebilen alanlarını günceller.

`PATCH` kullanıldığı için yalnızca değiştirilmek istenen alanların gönderilmesi yeterlidir.

### Yetki

Yalnızca etkinliğin ait olduğu kulübün aktif:

* `PRESIDENT`
* `VICE_PRESIDENT`
* `MANAGER`

rollerinden birine sahip kullanıcıları kullanabilir.

Başka bir kulübün yöneticisi etkinliği değiştiremez.

### Alan kuralları

| Alan                 | Düzenleme kuralı                                                                              |
| -------------------- | --------------------------------------------------------------------------------------------- |
| `name`               | Yayınlandıktan sonra değiştirilemez                                                           |
| `description`        | Etkinlik başlamadan önce değiştirilebilir                                                     |
| `image`              | Etkinlik başlamadan önce değiştirilebilir                                                     |
| `eventType`          | Yayınlandıktan sonra değiştirilemez                                                           |
| `location`           | Etkinlik başlamadan önce değiştirilebilir                                                     |
| `onlineLink`         | Etkinlik başlamadan önce değiştirilebilir                                                     |
| `applicationType`    | Başvuru başlamadan önce değiştirilebilir                                                      |
| `capacity`           | Başvuru başlamadan önce artırılabilir/azaltılabilir; başladıktan sonra yalnızca artırılabilir |
| `applicationStartAt` | Başvuru başlamadan önce değiştirilebilir                                                      |
| `applicationEndAt`   | Etkinlik başlamadan önce değiştirilebilir                                                     |
| `startAt`            | Etkinlik başlamadan önce değiştirilebilir                                                     |
| `endAt`              | Etkinlik başlamadan önce değiştirilebilir                                                     |

### Genel zaman sınırı

Etkinlik başladıktan sonra etkinlik üzerinde yönetimsel düzenleme yapılamaz.

Dolayısıyla:

```text
now >= startAt
```

durumunda düzenlenebilir alanların tamamı kilitlenir.

### Tarih doğrulamaları

PATCH sonucunda:

```text
applicationStartAt < applicationEndAt < startAt < endAt
```

ilişkisi korunmalıdır.

Örneğin yalnızca `endAt` değiştiriliyorsa yeni `endAt` değeri mevcut `startAt` değerinden sonra olmalıdır.

Benzer şekilde `startAt` değiştirilirken mevcut başvuru tarihleriyle olan zaman ilişkileri bozulmamalıdır.

### Kapasite değişikliği

Başvuru başlamadan önce:

```text
capacity:
50 → 40   ✅
50 → 70   ✅
```

olabilir.

Ancak yeni kapasite mevcut `ACCEPTED` sayısından düşük olamaz.

Örneğin:

```text
capacity = 50
ACCEPTED = 45
```

ise:

```text
capacity = 40
```

reddedilir.

Başvuru başladıktan sonra:

```text
50 → 70   ✅
50 → 40   ❌
```

olur.

### Kapasite artırıldığında

Kapasite artırılması sonucunda boş kontenjan oluşursa sistem mevcut `WAITLISTED` başvuruları başvuru zamanına göre otomatik olarak işler.

Örneğin:

```text
capacity = 50
ACCEPTED = 50
WAITLISTED = 10
```

ve:

```text
capacity = 53
```

olursa:

```text
3 WAITLISTED → ACCEPTED
```

otomatik olarak gerçekleştirilir.

`PENDING` başvurular kapasite artışı nedeniyle otomatik olarak `ACCEPTED` yapılmaz.

Bu özellikle `APPROVAL_REQUIRED` etkinliklerde önemlidir.

### Sonuç

Başarılı `PATCH` sonucunda güncellenmiş `Event` bilgisi döndürülür.

Bu nedenle istemcinin güncel etkinliği almak için ayrıca:

```text
GET /events/{eventId}
```

çağrısı yapması zorunlu değildir.

---

# 3.4. Etkinliği İptal Etme

### `POST /events/{eventId}/cancel`

Yayınlanmış bir etkinliği iptal eder.

Geçerli durum geçişi:

```text
PUBLISHED → CANCELLED
```

### Yetki

Yalnızca ilgili kulübün aktif:

* `PRESIDENT`
* `VICE_PRESIDENT`
* `MANAGER`

rollerinden biri.

### İptal koşulları

Etkinlik:

```text
status = PUBLISHED
```

olmalı ve henüz başlamamış olmalıdır:

```text
now < startAt
```

Etkinlik başladıktan sonra iptal edilemez.

### İptal sonrası

İptal edilen etkinlik:

* yeni başvuru alamaz,
* başvuru yönetimine açık değildir,
* QR ile katılım süreci başlatamaz,
* yeniden `PUBLISHED` durumuna getirilemez.

Mevcut `Application` kayıtları silinmez.

`Application` için ayrıca:

```text
CANCELLED
```

status'u oluşturulmaz.

İptal edilen etkinliğin kendi durumu:

```text
CANCELLED
```

olarak tutulur.

Etkinlik başlamadan iptal edildiği için normal akışta yeni `Attendance` kayıtları oluşturulmaz.

### Sonuç

Başarılı işlem sonucunda güncel `Event` bilgisi döndürülebilir.

---

# 3.5. Etkinliği Tamamlanmış Duruma Geçirme

### `POST /events/{eventId}/complete`

Bu endpoint, etkinliğin `COMPLETED` durumuna geçirilmesini sağlar.

Geçerli durum geçişi:

```text
PUBLISHED → COMPLETED
```

### Koşul

Etkinliğin bitiş zamanı gelmiş olmalıdır:

```text
now >= endAt
```

Etkinlik henüz bitmemişse `COMPLETED` durumuna geçirilemez.

### Önemli tasarım notu

Güncel UC-02'de `COMPLETED` durumuna geçişin tam olarak hangi mekanizma ile yapılacağı henüz kesinleştirilmemiştir.

Bu nedenle bu endpoint şu aşamada **kesinleşmiş otomatik tamamlanma mekanizması olarak değerlendirilmemelidir**.

Teknik tasarım aşamasında şu seçeneklerden biri belirlenebilir:

```text
Zaman tabanlı otomatik geçiş
```

veya:

```text
Yetkili yönetici tarafından tetiklenen geçiş
```

veya uygun görülen başka bir sistem mekanizması.

Dolayısıyla endpoint sözleşmesi, bu karar kesinleştiğinde son haline getirilmelidir.

### Tamamlanmış etkinlik

`COMPLETED` durumundaki etkinlik:

* yeni başvuru alamaz,
* başvuru durumlarını değiştiremez,
* başvuru geri çekme işlemine izin vermez.

Attendance işlemleri ayrı model ve endpoint kuralları kapsamında yürütülür.

---

# 3.6. Etkinliği Silme

### `DELETE /events/{eventId}`

Etkinliğin fiziksel olarak silinmesini sağlar.

Bu endpoint yalnızca henüz kullanıcı etkileşiminin başlamadığı sınırlı durumda kullanılabilir.

### Silme koşulları

Aşağıdaki koşulların tamamı sağlanmalıdır:

```text
status = PUBLISHED
```

```text
now < applicationStartAt
```

ve etkinliğe ait hiçbir `Application` bulunmamalıdır.

Yani:

```text
Başvuru başlamadı
        +
Application = 0
        +
Event = PUBLISHED
        ↓
DELETE
```

### Silinemeyen durumlar

Başvuru süreci başlamışsa etkinlik fiziksel olarak silinemez.

Bu durumda hiç başvuru yapılmamış olsa dahi:

```text
PUBLISHED → CANCELLED
```

kullanılır.

Aynı şekilde herhangi bir `Application` kaydı bulunan etkinlik fiziksel olarak silinemez.

Bu durumda etkinlik iptal edilebilir.

### Silinen etkinlik

Fiziksel silme işlemi `Event` kaydını veritabanından kaldırır.

Bu işlem `CANCELLED` status'u oluşturmaz.

Dolayısıyla:

```text
PUBLISHED → DELETE
```

ile:

```text
PUBLISHED → CANCELLED
```

farklı işlemlerdir.

Silme işlemi yalnızca başvuru başlamadan ve hiç başvuru yokken kullanılabilir.

---

# 4. Event Status'leri

MVP kapsamında `Event` için:

```text
PUBLISHED
COMPLETED
CANCELLED
```

status'leri bulunur.

Temel geçişler:

```text
PUBLISHED
   │
   ├──→ COMPLETED
   │
   └──→ CANCELLED
```

Etkinlik oluşturulduğunda:

```text
PUBLISHED
```

olarak oluşturulur.

`DRAFT` veya `CREATED` kalıcı Event status'leri bulunmaz.

Fiziksel silme ise status geçişi değildir:

```text
PUBLISHED → DELETE
```

şeklinde Event kaydının kaldırılmasıdır.

---

# 5. Etkinlik Düzenleme Kuralları

Endpoint seviyesinde temel kurallar:

### Değiştirilemez

```text
name
eventType
```

`name` ve `eventType` yayınlandıktan sonra değiştirilemez.

### Etkinlik başlamadan değiştirilebilir

```text
description
image
location / onlineLink
startAt
endAt
applicationEndAt
```

### Başvuru başlamadan değiştirilebilir

```text
applicationType
applicationStartAt
```

### Kapasite

Başvuru başlamadan:

```text
artırılabilir
azaltılabilir
```

Başvuru başladıktan sonra:

```text
yalnızca artırılabilir
```

Etkinlik başladıktan sonra hiçbir etkinlik düzenleme işlemi yapılamaz.

---

# 6. Başvuru Kurallarının Endpointlere Etkisi

Etkinlik endpointleri doğrudan Application status yönetimi yapmaz; ancak etkinliğin `applicationType`, kapasite ve tarih bilgileri UC-01 ve UC-03'teki başvuru davranışını belirler.

## 6.1. PUBLIC

Başvuru oluşturulduğunda sistem:

```text
Kapasite yok / yer var
        ↓
ACCEPTED
```

veya:

```text
Kapasite dolu
        ↓
WAITLISTED
```

oluşturur.

`PENDING` oluşturulmaz.

## 6.2. APPROVAL_REQUIRED

Başvuru oluşturulduğunda:

```text
PENDING
```

oluşturulur.

Kapasitenin dolu olması `PENDING` oluşturulmasını engellemez.

Daha sonra UC-03 kapsamında yönetici:

```text
PENDING → ACCEPTED
PENDING → WAITLISTED
PENDING → REJECTED
```

geçişlerinden uygun olanını gerçekleştirebilir.

Bu davranışın ayrıntıları UC-01 ve UC-03 API endpointlerinde tanımlanır.

---

# 7. Kapasite Açılması ve Otomatik İşlemler

Etkinlik kapasitesinde boşluk oluştuğunda sistem uygun `WAITLISTED` başvuruları otomatik olarak işler.

Kapasite şu nedenlerle açılabilir:

```text
ACCEPTED → WITHDRAWN
```

```text
ACCEPTED → REJECTED
```

veya kapasitenin artırılması.

Örneğin:

```text
capacity = 50
ACCEPTED = 50
WAITLISTED = 10
```

durumunda bir kabul edilmiş başvuru geri çekilirse:

```text
ACCEPTED = 49
```

olur.

Sistem:

```text
ilk WAITLISTED
       ↓
ACCEPTED
```

geçişini otomatik gerçekleştirir.

Bu işlem Application endpointinden bağımsız bir domain kuralıdır.

---

# 8. Etkinlik Başlangıcı

Etkinlik başlangıç zamanı:

```text
now >= startAt
```

olduğunda etkinliğin başvuru ve yönetim açısından kritik sınırı oluşur.

Bu noktadan sonra:

* yeni başvuru alınmaz,
* Application status değiştirilemez,
* öğrenci başvurusunu geri çekemez,
* Event üzerinde yönetimsel düzenleme yapılamaz.

Application status geçişlerinin ayrıntıları UC-03'te tanımlanır.

Attendance süreci ise ayrı bir model olarak devam eder.

---

# 9. Tarih ve Zaman Kuralları

Event oluşturma ve düzenleme işlemlerinde aşağıdaki temel ilişki korunmalıdır:

```text
applicationStartAt
        <
applicationEndAt
        <
startAt
        <
endAt
```

Dolayısıyla:

```text
applicationStartAt < applicationEndAt < startAt < endAt
```

geçerli olmalıdır.

Ayrıca:

```text
applicationEndAt <= startAt
```

kuralı korunmalıdır.

### Minimum başvuru süresi

Başvuru başlangıcı ile etkinlik başlangıcı arasında zorunlu minimum süre konusunda henüz kesin karar verilmemiştir.

Bu nedenle API contract aşamasında şu anda:

```text
startAt - applicationStartAt >= 1 gün
```

gibi sabit bir kural tanımlanmamalıdır.

Bu karar daha sonra ayrıca belirlenebilir.

---

# 10. Etkinlik Türleri

Etkinlik:

```text
PHYSICAL
ONLINE
```

türlerinden biri olabilir.

### PHYSICAL

```text
location
```

bilgisi kullanılır.

### ONLINE

```text
onlineLink
```

bilgisi kullanılır.

Etkinlik türü yayınlandıktan sonra değiştirilemez.

Online platformun ayrıca enum olarak tutulması bu endpoint contractı için zorunlu değildir.

---

# 11. Yetki Kontrolü

Etkinlik yönetim endpointlerinde yetki kontrolü iki seviyede değerlendirilmelidir:

### 1. Kimlik doğrulama

Kullanıcı sisteme giriş yapmış olmalıdır.

### 2. Kulüp yöneticiliği

Kullanıcının:

```text
ClubMember.club = Event.club
```

ilişkisi üzerinden aktif yöneticilik rolü bulunmalıdır.

Geçerli roller:

```text
PRESIDENT
VICE_PRESIDENT
MANAGER
```

Başka bir kulübün yöneticisi aynı endpointi kullansa bile etkinliği yönetemez.

Yetki kontrolü endpoint path'inde verilen `clubId` veya `eventId` ile kullanıcının `ClubMember` ilişkisi üzerinden yapılmalıdır.

---

# 12. Endpoint Özeti

| İşlem                       | Endpoint                          | Yetki                                     |
| --------------------------- | --------------------------------- | ----------------------------------------- |
| Etkinlik oluştur ve yayınla | `POST /clubs/{clubId}/events`     | İlgili kulübün aktif yöneticisi           |
| Etkinlik detayını görüntüle | `GET /events/{eventId}`           | Giriş yapmış kullanıcı                    |
| Etkinliği düzenle           | `PATCH /events/{eventId}`         | İlgili kulübün aktif yöneticisi           |
| Etkinliği iptal et          | `POST /events/{eventId}/cancel`   | İlgili kulübün aktif yöneticisi           |
| Etkinliği tamamla           | `POST /events/{eventId}/complete` | Tamamlama mekanizmasına göre belirlenecek |
| Etkinliği sil               | `DELETE /events/{eventId}`        | İlgili kulübün aktif yöneticisi           |

`GET /events/{eventId}` UC-01 ile ortak endpoint olarak kullanılabilir.

---

# 13. Endpointlerin UC'lerle İlişkisi

### UC-01

Öğrencinin:

* etkinlikleri görüntülemesi,
* etkinlik detayını görüntülemesi,
* başvuru oluşturması,
* başvurusunu takip etmesi,
* başvurusunu geri çekmesi,
* katılım durumunu görüntülemesi

işlemlerini kapsar.

Bu nedenle:

```text
GET /events/{eventId}
```

UC-01 tarafından da kullanılabilir.

### UC-02

Kulüp yöneticisinin:

* etkinlik oluşturması,
* etkinliği yayınlaması,
* etkinliği düzenlemesi,
* kapasiteyi değiştirmesi,
* etkinliği iptal etmesi,
* uygun koşullarda etkinliği silmesi

işlemlerini kapsar.

### UC-03

Kulüp yöneticisinin:

* başvuruları görüntülemesi,
* `PENDING` başvuruları değerlendirmesi,
* kabul/ret/yedek kararları vermesi,
* mevcut kararları düzeltmesi,
* Attendance kayıtlarını yönetmesi

işlemlerini kapsar.

---

# 14. Açık API Kararları

Aşağıdaki konular endpointlerin ayrıntılı contract aşamasında kesinleştirilecektir:

1. Request body alanlarının tam JSON yapısı.
2. Response DTO yapısı.
3. Pagination ve filtreleme kuralları.
4. HTTP status kodları.
5. Validation error formatı.
6. Event bulunamadığında dönecek hata.
7. Yetkisiz kulüp yöneticisinin alacağı hata.
8. `PATCH` içinde değiştirilemez alan gönderildiğinde hata davranışı.
9. Kapasite artırıldığında otomatik `WAITLISTED → ACCEPTED` işleminin transaction sınırı.
10. `POST /events/{eventId}/complete` endpointinin gerçekten gerekli olup olmadığı.
11. `COMPLETED` durumuna geçişin otomatik mi, manuel mi olacağı.
12. Event tarihi değiştirildiğinde mevcut Application kayıtlarına etkiler.
13. `applicationType` başvuru başlamadan değiştirildiğinde mevcut kayıtların nasıl ele alınacağı.
14. Online etkinlik bağlantısının kimlere ve ne zaman gösterileceği.
15. İptal sonrası öğrencilere gönderilecek bildirimlerin endpoint davranışı.
16. Fiziksel olarak silinen Event için audit/log tutulup tutulmayacağı.

---

# 15. Kapsam Dışı

Bu endpoint dokümanı aşağıdaki konuları ayrıntılı olarak tanımlamaz:

* Öğrenci başvuru endpointleri → UC-01
* Başvuru yönetimi → UC-03
* Attendance geçiş kuralları → ilgili Attendance tasarımı
* Bildirimler → UC-04
* Kulüp oluşturma/doğrulama
* Kulüp üyeliği ve takip
* Global admin işlemleri
* Ban/engelleme sistemi
* Detaylı audit/history sistemi
* Ayrıntılı response/error contractları

Ban/engelleme sistemi MVP kapsamında değildir ve `BAN` bir Application status olarak modellenmez.
