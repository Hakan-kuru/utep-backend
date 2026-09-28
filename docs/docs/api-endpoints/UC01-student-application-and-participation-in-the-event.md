# UC01 — Öğrencinin Etkinliğe Başvurması ve Katılması

Bu doküman, UC01 kapsamında öğrencinin gerçekleştirebildiği işlemler için gerekli API endpointlerini tanımlar.

> **Not:** Bu aşamada endpointlerin amacı, sorumluluğu ve temel kullanım şekli belirlenmektedir. Ayrıntılı request/response modelleri, query parameter isimleri, pagination, HTTP status code'ları, hata response yapısı, QR veri formatı ve backend teknolojisine özgü uygulama detayları daha sonraki API contract aşamalarında belirlenecektir.

---

## 1. Etkinlikleri Listeleme

### `GET /events`

Öğrencinin erişebileceği etkinlikleri listeler.

Kullanım alanları:

* Etkinliklerin genel olarak listelenmesi
* Yaklaşan etkinliklerin görüntülenmesi
* Geçmiş etkinliklerin filtrelenmesi
* İleride eklenecek etkinlik filtrelerinin uygulanması

Etkinlik listesi, giriş yapmış kullanıcı için gerekli olduğunda kullanıcının ilgili etkinlikteki başvuru ve katılım durumlarını da gösterebilecek bilgileri içerebilir.

Örneğin:

```text
Android Workshop
Başvuru: ACCEPTED
Katılım: ATTENDED
```

Bu bilgilerin gösterilmesi için her etkinlik adına ayrı bir `GET /events/{eventId}/application` isteği yapılması zorunlu değildir. Backend uygun gördüğü durumda etkinlik listesindeki kayıtlarla kullanıcının ilişkili `Application` ve `Attendance` bilgilerini birleştirerek döndürebilir.

### Geçmiş etkinlikler

Geçmiş etkinlikler için ayrı bir:

```text
GET /events/history
```

veya:

```text
GET /my-events
```

endpointi şu aşamada planlanmamaktadır.

Geçmiş etkinlikler, `GET /events` endpointinin uygun filtreleri kullanılarak elde edilmesi planlanmaktadır.

Örneğin ileride:

```text
GET /events?status=COMPLETED
```

benzeri bir kullanım değerlendirilebilir.

Kesin filtre isimleri ve filtreleme yapısı API contract aşamasında belirlenecektir.

Etkinliğin `CANCELLED` veya `COMPLETED` olması gibi durumlar da etkinlik listeleme davranışının bir parçasıdır. Kullanıcıya hangi durumdaki etkinliklerin varsayılan listede gösterileceği daha sonra kesinleştirilecektir.

---

## 2. Etkinlik Detayını Görüntüleme

### `GET /events/{eventId}`

Belirli bir etkinliğin detaylarını getirir.

Etkinlik bilgileri yanında, giriş yapmış öğrenci açısından bu etkinlikle ilgili kişisel durum bilgileri de response içerisinde sunulabilir.

Örneğin:

```text
Etkinlik bilgileri

Başvuru durumu: ACCEPTED
Katılım durumu: ATTENDED
```

Bu bilgiler backend tarafından ilgili:

* `Event`
* `Application`
* `Attendance`

verilerinden oluşturulabilir.

Öğrencinin etkinlik detayını görüntülemesi sırasında bu üç veri için ayrı ayrı HTTP isteği yapılması zorunlu değildir.

Örneğin backend tek response içerisinde:

```text
event
application
attendance
```

bilgilerini birleştirebilir.

Öğrencinin etkinlikle ilişkili bir `Application` kaydı bulunmuyorsa bunun response içerisindeki nasıl ifade edileceği daha sonra belirlenecektir.

Aynı şekilde etkinlik henüz başlamamışsa `Attendance` kaydının bulunmaması ile etkinlik başladıktan sonra `Attendance.status = NULL` olması arasındaki API gösterim şekli daha sonraki contract aşamasında netleştirilecektir.

---

## 3. Etkinliğe Başvurma

### `POST /events/{eventId}/applications`

Giriş yapmış öğrencinin belirli bir etkinliğe başvurmasını sağlar.

Öğrencinin kimliği request body içerisinde gönderilmez. Backend, kimliği doğrulanmış kullanıcı üzerinden öğrenciyi belirler.

Başvuru oluşturulmadan önce backend aşağıdaki gibi temel kuralları kontrol eder:

* Etkinlik mevcut olmalıdır.
* Etkinlik başvuru kabul ediyor olmalıdır.
* Başvuru dönemi başlamış olmalıdır.
* Başvuru dönemi sona ermemiş olmalıdır.
* Etkinlik başlamamış olmalıdır.
* Öğrencinin aynı etkinlikte aktif bir başvurusu bulunmamalıdır.
* Öğrencinin daha önce `REJECTED` olmuş bir başvurusu varsa yeniden başvuru yapmasına izin verilmez.

Başlangıç durumu

Başvurunun başlangıç durumu etkinliğin applicationType, kapasite ve varsa öğrenciye uygulanan etkinlik/kulüp bazlı kısıtlamalara göre belirlenir.

PUBLIC

PUBLIC etkinliklerde normal koşullarda başvuru için yönetici onayı gerekmez.

Kapasite sınırsızsa:

PUBLIC
  ↓
ACCEPTED

Kapasite varsa ve yer mevcutsa:

PUBLIC
  ↓
ACCEPTED

Kapasite tamamen doluysa:

PUBLIC
  ↓
WAITLISTED

Eğer ileride kulüp/etkinlik bazlı ban (engelleme) sistemi uygulanırsa, banlı bir öğrencinin başvurusu normal kapasite kurallarına göre ACCEPTED veya WAITLISTED olmak yerine sistem tarafından reddedilebilir:

PUBLIC
  ↓
REJECTED

Bu durumda REJECTED sonucunun nedeni öğrencinin banlı olması olabilir.

Burada PENDING oluşturulmaz.

Yani PUBLIC başvuru için normal akışta:

PUBLIC
  ↓
ACCEPTED / WAITLISTED

şeklinde doğrudan sonuç oluşur.

Not: Ban/engelleme mekanizması mevcut MVP kapsamında henüz uygulanmamaktadır. Bu örnek, ileride ban özelliği eklendiğinde endpointin olası davranışını göstermek amacıyla verilmiştir. Banın veri modeli, süresi ve hangi aşamada kontrol edileceği ilgili UC/API contract aşamasında ayrıca belirlenecektir.

#### `APPROVAL_REQUIRED`

`APPROVAL_REQUIRED` etkinliklerde her yeni başvuru:

```text
APPROVAL_REQUIRED
  ↓
PENDING
```

olarak oluşturulur.

Etkinliğin kapasitesinin dolu olması `PENDING` oluşturulmasına engel değildir.

Örneğin etkinlik kapasitesi 50 ve 50 kişi kabul edilmiş olsa bile yeni öğrencinin başvurusu:

```text
PENDING
```

olabilir.

Bu başvurunun daha sonra:

```text
PENDING → ACCEPTED
PENDING → WAITLISTED
PENDING → REJECTED
```

sonuçlarından hangisine dönüşeceğine kulüp yöneticisi karar verir.

Dolayısıyla endpoint oluşturma sırasında `APPROVAL_REQUIRED` için kapasite dolu olduğunda doğrudan `WAITLISTED` oluşturulmaz.

### Başvuru oluşturulduğunda

Başarılı bir başvuru sonucunda yeni bir `Application` kaydı oluşturulur.

Örneğin:

```text
POST /events/42/applications

        ↓

Application
student = currentUser
event = 42
status = ACCEPTED / PENDING / WAITLISTED
```

Kesin request body yapısı daha sonra belirlenecektir.

---

## 4. Kendi Başvurusunu Görüntüleme

### `GET /events/{eventId}/application`

Giriş yapmış öğrencinin belirli bir etkinlikteki kendi başvurusunu ve başvuru durumunu getirir.

Öğrencinin kimliği endpoint içerisinde ayrıca belirtilmez. Backend giriş yapmış kullanıcı üzerinden ilgili `Application` kaydını bulur.

Geçerli başvuru durumları:

* `PENDING`
* `ACCEPTED`
* `REJECTED`
* `WAITLISTED`
* `WITHDRAWN`

Bu endpoint özellikle öğrencinin kendi başvurusunun ayrıntılı durumunu görüntülemesi için kullanılır.

Örneğin:

```text
Başvuru durumu: WAITLISTED
```

veya:

```text
Başvuru durumu: REJECTED
Red nedeni: ...
```

gibi bilgiler bu endpoint üzerinden sağlanabilir.

`REJECTED` ve `WITHDRAWN` kayıtlarının tutulmaya devam etmesi nedeniyle endpoint yalnızca aktif başvuruları değil, ilgili etkinlikteki mevcut/son başvuru kaydını da gösterebilir.

> Etkinlik listesi veya etkinlik detayında özet başvuru durumu gösterilebildiği için bu endpoint her listeleme veya detay görüntüleme işleminde ayrı olarak çağrılmak zorunda değildir.

---

## 5. Başvuruyu Geri Çekme

### `POST /events/{eventId}/application/withdraw`

Giriş yapmış öğrencinin kendi başvurusunu geri çekmesini sağlar.

Başvuru kaydı silinmez. Mevcut `Application` kaydının durumu:

```text
WITHDRAWN
```

olarak değiştirilir.

Öğrencinin geri çekebileceği durumlar:

```text
PENDING    → WITHDRAWN
WAITLISTED → WITHDRAWN
ACCEPTED   → WITHDRAWN
```

`REJECTED` durumundaki bir başvurunun geri çekilmesine gerek yoktur.

`WITHDRAWN` durumundaki bir başvuru tekrar `ACCEPTED`, `PENDING` veya `WAITLISTED` durumuna döndürülmez.

### ACCEPTED başvurunun geri çekilmesi

Öğrenci `ACCEPTED` durumundaki başvurusunu geri çekerse kapasitede yer açılabilir.

Örneğin:

```text
Kapasite: 50
ACCEPTED: 50
WAITLISTED: 5
```

Bir kabul edilmiş öğrenci başvurusunu geri çektiğinde:

```text
ACCEPTED
    ↓
WITHDRAWN
```

olur.

Boşalan kapasite için sistem bekleme listesindeki ilk öğrenciyi otomatik olarak:

```text
WAITLISTED
    ↓
ACCEPTED
```

yapar.

Öğrencinin hangi bekleme listesi kaydının kabul edileceğini bu endpoint kullanan öğrenci belirlemez.

### Yeniden başvuru

`WITHDRAWN` durumundaki eski `Application` kaydı korunur.

Başvuru dönemi hâlâ açıksa öğrenci yeniden başvurabilir.

Bu durumda eski kayıt tekrar kullanılmaz; yeni bir `Application` oluşturulur.

Örneğin:

```text
Application #15
ACCEPTED → WITHDRAWN

        ↓ yeniden başvuru

Application #21
PENDING
```

Böylece geçmiş başvuru hareketleri korunur.

Aynı anda öğrencinin aynı etkinlik için yalnızca bir aktif başvurusu bulunabilir.

---

## 6. Geçmiş Etkinlikleri Görüntüleme

Öğrenci geçmişte ilişkili olduğu etkinlikleri ve bu etkinliklerdeki katılım durumunu görüntüleyebilir.

Örneğin:

```text
Android Workshop      → ATTENDED
Yapay Zeka Semineri   → NOT_ATTENDED
Kariyer Söyleşisi     → ATTENDED
```

Bu işlem için şu aşamada ayrı bir:

```text
GET /history
```

veya:

```text
GET /my-events
```

endpointi oluşturulmamaktadır.

Mevcut:

```text
GET /events
```

endpointinin uygun filtrelerle kullanılması planlanmaktadır.

Kesin filtre isimleri API contract aşamasında belirlenecektir.

Geçmiş etkinliklerde öğrencinin katılım durumu `Attendance` verisinden elde edilir.

Önemli olarak:

```text
Application = ACCEPTED
```

olması öğrencinin etkinliğe katıldığını göstermez.

Katılım bilgisi ayrı `Attendance` kaydından belirlenir.

---

## 7. QR ile Katılım İşaretleme

### `POST /attendance/scan`

Öğrencinin etkinlik sırasında etkinliğe ait QR kodunu kendi telefonundaki QR okuyucu ile okutmasını sağlar.

QR kodunun kendisinin request içerisinde nasıl taşınacağı ve doğrulama mekanizması henüz kesinleştirilmemiştir.

Temel işlem şu şekildedir:

```text
Öğrenci QR kodunu okutur
        ↓
POST /attendance/scan
        ↓
Backend giriş yapan öğrenciyi belirler
        ↓
QR/event doğrulanır
        ↓
Öğrencinin Attendance kaydı bulunur
        ↓
Attendance.status = ATTENDED
```

Öğrencinin kimliği request içerisinde manuel olarak gönderilmez.

Backend kimliği doğrulanmış kullanıcı üzerinden öğrenciyi belirler.

Attendance kayıtları etkinlik başladığında sistem tarafından oluşturulduğu için QR endpointinin temel görevi yeni bir katılım kaydı oluşturmak yerine mevcut kaydı:

```text
NULL → ATTENDED
```

olarak güncellemektir.

QR'ın:

* İçeriğinin nasıl oluşturulacağı
* Geçerlilik süresi
* Tek kullanımlık olup olmayacağı
* Yeniden oynatma/replay kontrolü
* Etkinliğe özel doğrulama yöntemi
* Fiziksel ve çevrim içi etkinliklerde nasıl kullanılacağı

daha sonraki aşamalarda belirlenecektir.

> Özellikle **ONLINE etkinliklerde QR ile katılımın nasıl uygulanacağı** henüz kesinleşmiş bir domain kararı değildir.

---

## 8. Attendance'ın Otomatik İşlemleri

Aşağıdaki işlemler kullanıcı tarafından çağrılan API endpointleri değildir.

Bunlar sistemin etkinlik yaşam döngüsüne bağlı olarak gerçekleştirdiği otomatik işlemlerdir.

### 8.1 Etkinlik başladığında

Etkinlik başladığında `ACCEPTED` durumundaki başvurular belirlenir.

Bu öğrenciler için `Attendance` kayıtları oluşturulur:

```text
ACCEPTED Application
        ↓
Attendance
status = NULL
```

`NULL`, öğrencinin henüz katılım durumunun belirlenmediğini ifade eder.

Örneğin:

```text
Application.status = ACCEPTED
Attendance.status = NULL
```

Bu iki durum birbirinden bağımsızdır.

Öğrenci QR kodunu okuttuğunda:

```text
Attendance.NULL
       ↓
Attendance.ATTENDED
```

olur.

Bu işlem için öğrencinin başvuru kaydının tekrar oluşturulması veya başvuru durumunun değiştirilmesi gerekmez.

### 8.2 Etkinlik bittikten sonra

Etkinlik sonunda hâlâ:

```text
Attendance.status = NULL
```

olan öğrencilerin katılım durumu sistem tarafından:

```text
NULL
 ↓
NOT_ATTENDED
```

olarak güncellenebilir.

Bu işlem de kullanıcı tarafından çağrılan bir endpoint değildir.

Bu otomatik işlemin tam olarak hangi anda çalıştırılacağı ve `event.start` / `event.end` ile nasıl ilişkilendirileceği daha sonraki teknik tasarım aşamasında kesinleştirilecektir.

---

## 9. Başvuru ve Kapasite Otomasyonları

UC01 kapsamında bazı işlemler öğrencinin doğrudan çağırdığı endpointler değildir; ancak başvuru endpointlerinin sonucunu doğrudan etkiledikleri için burada belirtilir.

### 9.1 Waitlist'ten otomatik kabul

Kapasitesi bulunan bir etkinlikte kabul edilmiş bir başvuru kapasiteyi boşaltırsa sistem bekleme listesindeki ilk öğrenciyi otomatik olarak kabul eder.

Örneğin:

```text
Kapasite: 50
ACCEPTED: 50
WAITLISTED: 3
```

Bir `ACCEPTED` başvuru `WITHDRAWN` olduğunda:

```text
ACCEPTED: 49
WAITLISTED: 3
```

olur ve sistem:

```text
WAITLISTED #1
      ↓
ACCEPTED
```

yapar.

Aynı otomasyon, kulüp yöneticisinin:

```text
ACCEPTED → REJECTED
```

şeklinde bir düzeltme yapması sonucunda kapasite açıldığında da uygulanır.

### 9.2 Kapasitenin artırılması

Etkinlik kapasitesi artırıldığında mevcut waitlist varsa sistem boşalan kapasite kadar öğrenciyi bekleme sırasına göre otomatik kabul eder.

Örneğin:

```text
Kapasite: 50 → 70
WAITLISTED: 20
```

ise ilk 20 öğrenci:

```text
WAITLISTED → ACCEPTED
```

olur.

Ancak `APPROVAL_REQUIRED` etkinlikte henüz yöneticinin değerlendirmediği `PENDING` başvurular varsa ve henüz waitlist oluşturulmamışsa kapasite artışı bu başvuruları otomatik olarak `ACCEPTED` yapmaz.

Bu öğrencilerin değerlendirilmesi kulüp yöneticisinin başvuru yönetimi işlemleri kapsamında yapılır.

---

## 10. Başvuru Dönemi ve Endpoint Davranışı

Başvuru endpointlerinin kullanılabilirliği etkinliğin başvuru tarihleriyle sınırlıdır.

Başvuru genel olarak:

```text
applicationStart ≤ currentTime < applicationEnd
```

aralığında yapılabilir.

Başvuru dönemi başlamadan önce:

```text
POST /events/{eventId}/applications
```

kullanılamaz.

Başvuru dönemi sona erdikten sonra yeni `Application` oluşturulamaz.

Etkinlik başladıktan sonra da yeni başvuru oluşturulamaz.

Dolayısıyla:

```text
Başvuru dönemi açık
        ↓
Yeni başvuru yapılabilir
```

ancak:

```text
Başvuru dönemi kapandı
        ↓
Yeni başvuru yapılamaz
```

ve:

```text
Etkinlik başladı
        ↓
Yeni başvuru yapılamaz
```

şeklinde davranır.

### Başvuru dönemi kapandıktan sonra mevcut başvurular

Başvuru dönemi kapandıktan sonra yeni başvuru alınmaz; ancak `APPROVAL_REQUIRED` etkinliklerde mevcut `PENDING` başvuruların kulüp yöneticisi tarafından değerlendirilmesi devam edebilir.

Bu nedenle:

```text
applicationEnd
      ↓
Yeni Application ❌
      ↓
Mevcut PENDING başvuruların yönetimi ✅
```

şeklinde bir ayrım bulunur.

`PENDING` başvuruların başvuru dönemi kapandıktan sonra sistem tarafından otomatik olarak mı `REJECTED` yapılacağı, yoksa yöneticinin tamamını manuel olarak mı sonuçlandıracağı henüz kesinleştirilmemiştir. Bu karar UC03/API contract aşamasında netleştirilecektir.

`PUBLIC` etkinliklerde ise yeni başvurular zaten doğrudan `ACCEPTED` veya `WAITLISTED` olduğundan normal koşullarda değerlendirilecek bir `PENDING` başvuru bulunmaz.

---

## 11. Etkinlik Başladıktan Sonra

Etkinlik başladıktan sonra `Application` üzerinde yeni başvuru işlemleri ve başvuru durumu değişiklikleri yapılamaz.

Bu nedenle:

```text
PENDING → ACCEPTED        ❌
PENDING → REJECTED        ❌
PENDING → WAITLISTED      ❌
REJECTED → ACCEPTED       ❌
ACCEPTED → REJECTED       ❌
ACCEPTED → WITHDRAWN      ❌
PENDING → WITHDRAWN       ❌
WAITLISTED → WITHDRAWN    ❌
```

olur.

Etkinlik başladıktan sonra süreç `Attendance` üzerinden devam eder.

Örneğin:

```text
Event başladı
     ↓
ACCEPTED öğrenciler
     ↓
Attendance oluşturulur
     ↓
QR ile ATTENDED
```

Bu nedenle Application yaşam döngüsü ile Attendance yaşam döngüsü birbirinden ayrı tutulur.

---

## 12. UC01 Endpoint Özeti

| İşlem                           | HTTP Method | Endpoint                                 |
| ------------------------------- | ----------- | ---------------------------------------- |
| Etkinlikleri listeleme          | `GET`       | `/events`                                |
| Etkinlik detayını görüntüleme   | `GET`       | `/events/{eventId}`                      |
| Etkinliğe başvurma              | `POST`      | `/events/{eventId}/applications`         |
| Kendi başvurusunu görüntüleme   | `GET`       | `/events/{eventId}/application`          |
| Başvuruyu geri çekme            | `POST`      | `/events/{eventId}/application/withdraw` |
| Geçmiş etkinlikleri görüntüleme | `GET`       | `/events` + filtre                       |
| QR ile katılım işaretleme       | `POST`      | `/attendance/scan`                       |

### UC01 kapsamında endpoint olmayan otomatik işlemler

* Etkinlik başlangıcında `ACCEPTED Application → Attendance(NULL)`
* QR okutulduğunda `Attendance NULL → ATTENDED` işleminin backend tarafından gerçekleştirilmesi
* Etkinlik sonunda `Attendance NULL → NOT_ATTENDED`
* Kapasite açıldığında ilk `WAITLISTED → ACCEPTED`
* Kapasite artırıldığında mevcut waitlist'in otomatik işlenmesi

---

## 13. UC01 ile İlgili Açık API Kararları

Aşağıdaki konular endpointlerin temel amacını değiştirmediği için bu aşamada açık bırakılmıştır:

* `GET /events` için kesin filtre parametreleri
* Listeleme ve detay response'larında `Application` / `Attendance` bilgilerinin tam olarak hangi formatta gösterileceği
* Pagination yapısı
* Başvuru oluşturma/withdraw işlemlerinin kesin HTTP status code'ları
* Hata response formatı
* `POST /attendance/scan` request body ve QR veri formatı
* QR kodunun geçerlilik süresi ve güvenlik mekanizması
* ONLINE etkinliklerde QR katılımının uygulanıp uygulanmayacağı
* Etkinlik sonunda `NULL → NOT_ATTENDED` işleminin tam olarak ne zaman çalıştırılacağı
* Başvuru sonrasında kalan `PENDING` kayıtlarının deadline sonrası otomatik mi yoksa manuel mi sonuçlandırılacağı
* `REJECTED` durumunda gösterilecek rejection reason'ın response modeli
* Öğrencinin başvuru geçmişinin API'de ne kadar ayrıntılı gösterileceği

Bu kararlar netleştiğinde endpointlerin path yapısının değiştirilmesi gerekmeyebilir; çoğunlukla request/response contract ve iş kuralı detayları üzerinde etkili olacaktır.
