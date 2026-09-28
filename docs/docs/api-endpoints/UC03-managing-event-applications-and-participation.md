# UC03 — Etkinlik Başvurularının ve Katılımın Yönetilmesi

## 1. Amaç

Kulüp yöneticilerinin kendi kulüplerine ait etkinliklerin başvurularını yönetmesini ve etkinliğe katılım durumlarını görüntüleyip gerektiğinde düzeltmesini kapsar.

Bu işlemler yalnızca ilgili kulübün yöneticileri tarafından gerçekleştirilebilir.

Kulüp yöneticisi olmak ayrı bir kullanıcı tipi değildir. Kullanıcı, `ClubMember` üzerinden ilgili kulüpte `PRESIDENT`, `VICE_PRESIDENT` veya `MANAGER` rolüne sahipse o kulübün başvurularını ve katılım kayıtlarını yönetebilir.

---

# 2. Yetki

Başvuru ve katılım yönetimi için kullanıcının:

* giriş yapmış olması,
* ilgili kulübün aktif üyesi olması,
* kulüpte `PRESIDENT`, `VICE_PRESIDENT` veya `MANAGER` rolüne sahip olması

gerekir.

Kullanıcı başka kulüplerin etkinliklerine ait başvuru ve katılım kayıtlarını yönetemez.

Global `ADMIN`, UC03 kapsamında kulüp yöneticisinin yerine normal etkinlik başvuru ve katılım yönetimi yapan bir aktör olarak tanımlanmaz. Global yönetici işlemleri ayrı bir yönetim kapsamındadır.

---

# 3. API Endpointleri

## 3.1 Etkinlik Başvurularını Listeleme

### `GET /events/{eventId}/applications`

Belirtilen etkinliğe yapılmış başvuruları getirir.

Yanıtta başvuru ile ilgili temel bilgiler bulunabilir:

* başvuru ID'si
* başvuran kullanıcı bilgileri
* başvuru durumu
* başvuru tarihi
* gerekli görülen diğer başvuru bilgileri

Başvurular `appliedAt` değerine göre sıralanabilir.

Bu sıralama özellikle bekleme listesi önceliğinin belirlenmesinde kullanılabilir.

### Yetki

Yalnızca ilgili kulübün:

* `PRESIDENT`
* `VICE_PRESIDENT`
* `MANAGER`

rollerinden birine sahip kullanıcıları işlemi gerçekleştirebilir.

---

## 3.2 Başvuruyu Kabul Etme

### `POST /applications/{applicationId}/accept`

Bir başvuruyu kabul eder.

Yönetici tarafından gerçekleştirilebilecek geçerli durum geçişleri:

* `PENDING → ACCEPTED`
* `REJECTED → ACCEPTED`

`REJECTED → ACCEPTED` geçişi, yöneticinin daha önce verdiği bir kararı etkinlik başlamadan önce düzeltmesi amacıyla kullanılabilir.

`WAITLISTED → ACCEPTED` normal yönetici kabul işlemi olarak kullanılmaz. Bekleme listesindeki başvurular, kapasite açılması veya kapasite artırılması durumunda sistem tarafından öncelik sırasına göre otomatik olarak `ACCEPTED` durumuna geçirilebilir.

### Kapasite kontrolü

Etkinliğin kapasitesi belirlenmişse kabul işlemi sırasında mevcut `ACCEPTED` başvuru sayısı kontrol edilir.

Kapasite doluysa:

* `PENDING → ACCEPTED`
* `REJECTED → ACCEPTED`

geçişleri gerçekleştirilemez.

Kapasite açıldığında veya artırıldığında uygun `WAITLISTED` kayıtları sistem tarafından otomatik olarak işlenir.

---

## 3.3 Başvuruyu Reddetme

### `POST /applications/{applicationId}/reject`

Bir başvuruyu reddeder.

Geçerli durum geçişleri:

* `PENDING → REJECTED`
* `ACCEPTED → REJECTED`

`ACCEPTED → REJECTED` geçişi, etkinlik başlamadan önce yöneticinin daha önce verdiği kabul kararını düzeltmesi amacıyla kullanılabilir.

Başvuru reddedildiğinde `Application` kaydı silinmez ve durumu `REJECTED` olarak korunur.

`ACCEPTED → REJECTED` sonucunda bir kapasite açılırsa uygun bekleme listesi kaydı sistem tarafından otomatik olarak `ACCEPTED` durumuna geçirilebilir.

### Reddetme sebebi

`rejectionReason` şu an için `nullable` olarak tutulabilir.

Reddetme sebebinin hangi durumlarda zorunlu olacağı ve request body içerisinde zorunlu hale getirilip getirilmeyeceği ayrıca kesinleştirilecektir.

---

## 3.4 Başvuruyu Bekleme Listesine Alma

### `POST /applications/{applicationId}/waitlist`

Bir başvuruyu bekleme listesine alır.

Geçerli yönetici durum geçişi:

`PENDING → WAITLISTED`

Bu işlem yalnızca bekleme listesinin kullanılabileceği, kapasitesi belirlenmiş etkinliklerde uygulanabilir.

### `PUBLIC`

`PUBLIC` etkinliklerde kapasite dolduğunda yeni başvuru sistem tarafından otomatik olarak:

`WAITLISTED`

durumuna alınabilir.

Yönetici tarafından ayrıca bekleme listesine alma işlemi yapılmaz.

### `APPROVAL_REQUIRED`

`APPROVAL_REQUIRED` etkinliklerde yeni başvurular `PENDING` durumunda oluşturulur.

Yönetici başvuruyu:

* kabul edebilir,
* reddedebilir,
* bekleme listesine alabilir.

Kapasitenin dolu olması başvurunun otomatik olarak `WAITLISTED` yapılmasını zorunlu kılmaz.

---

# 4. Başvuru Durumları

`Application` için aşağıdaki durumlar kullanılır:

| Durum        | Anlamı                                      |
| ------------ | ------------------------------------------- |
| `PENDING`    | Başvuru yönetici değerlendirmesini bekliyor |
| `ACCEPTED`   | Başvuru kabul edildi                        |
| `REJECTED`   | Başvuru reddedildi                          |
| `WAITLISTED` | Başvuru bekleme listesinde                  |
| `WITHDRAWN`  | Öğrenci başvurusunu geri çekti              |

### Temel durum geçişleri

| Mevcut Durum | Yeni Durum   | İşlemi Yapan |
| ------------ | ------------ | ------------ |
| `PENDING`    | `ACCEPTED`   | Yönetici     |
| `PENDING`    | `REJECTED`   | Yönetici     |
| `PENDING`    | `WAITLISTED` | Yönetici     |
| `WAITLISTED` | `ACCEPTED`   | Sistem       |
| `ACCEPTED`   | `REJECTED`   | Yönetici     |
| `REJECTED`   | `ACCEPTED`   | Yönetici     |
| `PENDING`    | `WITHDRAWN`  | Öğrenci      |
| `WAITLISTED` | `WITHDRAWN`  | Öğrenci      |
| `ACCEPTED`   | `WITHDRAWN`  | Öğrenci      |

`WAITLISTED → ACCEPTED` geçişi normalde sistem tarafından gerçekleştirilir.

`WITHDRAWN` durumundaki eski kayıt yeniden `ACCEPTED`, `PENDING` veya başka bir aktif duruma geçirilmez.

Öğrenci tekrar başvurursa yeni bir `Application` kaydı oluşturulur.

---

# 5. Başvuru Yönetimi Kuralları

## Başvuru süresi devam ederken

Yeni başvurular alınabilir.

Başvurular etkinliğin `applicationType` değerine göre otomatik veya yönetici değerlendirmesiyle işlenir.

## Başvuru süresi bittikten sonra

Yeni başvuru alınamaz.

Ancak daha önce oluşturulmuş `PENDING` başvurular yönetici tarafından değerlendirilmeye devam edebilir.

Örneğin:

`PENDING → ACCEPTED`

veya

`PENDING → REJECTED`

işlemleri gerçekleştirilebilir.

Başvuru süresinin sona ermesi, mevcut başvuruların otomatik olarak reddedildiği anlamına gelmez.

## Etkinlik başladıktan sonra

Başvuru kararları değiştirilemez.

Aşağıdaki yönetici işlemleri etkinlik başladıktan sonra gerçekleştirilemez:

* `PENDING → ACCEPTED`
* `PENDING → REJECTED`
* `PENDING → WAITLISTED`
* `WAITLISTED → ACCEPTED`
* `ACCEPTED → REJECTED`
* `REJECTED → ACCEPTED`

Öğrencinin başvurusunu geri çekmesiyle ilgili kurallar UC01 kapsamında uygulanır.

---

# 6. PUBLIC Başvuru Davranışı

Etkinliğin `applicationType` değeri `PUBLIC` ise başvurular sistem tarafından otomatik olarak değerlendirilir.

## Kapasite belirtilmemişse

Yeni başvuru doğrudan:

`ACCEPTED`

durumunda oluşturulur.

## Kapasite belirtilmişse

Kapasitede yer varsa:

`ACCEPTED`

Kapasite doluysa:

`WAITLISTED`

durumunda oluşturulur.

## Bekleme listesi

Bekleme listesi `appliedAt` değerine göre önceliklendirilir.

Bir `ACCEPTED` başvuru:

* öğrenci tarafından `WITHDRAWN` olduğunda,
* yönetici tarafından `REJECTED` olduğunda

veya etkinlik kapasitesi artırıldığında boşalan kontenjan için sistem bekleme listesini değerlendirir.

Uygun durumdaki ilk bekleme listesi başvuruları sırasıyla `ACCEPTED` durumuna geçirilir.

---

# 7. APPROVAL_REQUIRED Başvuru Davranışı

Etkinliğin `applicationType` değeri `APPROVAL_REQUIRED` ise yeni başvurular:

`PENDING`

durumunda oluşturulur.

Kulüp yöneticisi başvuruyu:

* kabul edebilir,
* reddedebilir,
* bekleme listesine alabilir.

Kapasitenin dolu olması başvurunun otomatik olarak `WAITLISTED` yapılmasını zorunlu kılmaz.

Yönetici kararını başvurunun mevcut durumuna ve etkinliğin kapasite kurallarına göre verir.

---

# 8. Kapasite ve Bekleme Listesi Kuralları

Kapasitesi belirlenmiş etkinliklerde kabul işlemleri mevcut `ACCEPTED` başvuru sayısı dikkate alınarak gerçekleştirilir.

`PENDING` ve `WAITLISTED` başvurular kabul edilmiş kontenjan hesabına dahil edilmez.

Bir kullanıcı:

`ACCEPTED → WITHDRAWN`

geçişi yaptığında ilgili kontenjan boşalır.

Benzer şekilde:

`ACCEPTED → REJECTED`

geçişi de kontenjan açar.

Boşalan kontenjan için bekleme listesi varsa sistem, `appliedAt` sırasına göre uygun başvuruları otomatik olarak `ACCEPTED` durumuna geçirir.

Etkinlik kapasitesi artırıldığında da aynı otomatik bekleme listesi işlemi uygulanır.

Kapasitesi olmayan etkinliklerde kapasite sınırı bulunmadığından `WAITLISTED` durumu kullanılmaz.

Kapasite değişiklikleri UC02'de tanımlanan kurallara göre yönetilir:

* başvuru başlamadan önce kapasite artırılabilir veya azaltılabilir,
* kapasite mevcut `ACCEPTED` sayısının altına düşürülemez,
* başvurular başladıktan sonra kapasite azaltılamaz,
* başvurular başladıktan sonra kapasite artırılabilir.

---

# 9. Katılım Kayıtlarını Görüntüleme

### `GET /events/{eventId}/attendance`

Belirtilen etkinliğin katılım kayıtlarını getirir.

Katılım kayıtları etkinliğe ait `Application` kayıtları üzerinden ilgili kullanıcıya bağlanır.

Yanıtta örneğin:

* kullanıcı bilgisi
* başvuru durumu
* katılım durumu
* katılım kaydı

bulunabilir.

Katılım listesi etkinliğin `ACCEPTED` katılımcıları üzerinden oluşturulur.

### Yetki

Yalnızca ilgili kulübün:

* `PRESIDENT`
* `VICE_PRESIDENT`
* `MANAGER`

rollerinden birine sahip kullanıcıları işlemi gerçekleştirebilir.

---

# 10. Katılım Durumları

`Attendance` için üç durum bulunur:

| Durum          | Anlamı                        |
| -------------- | ----------------------------- |
| `NULL`         | Katılım henüz kesinleşmedi    |
| `ATTENDED`     | Kullanıcı etkinliğe katıldı   |
| `NOT_ATTENDED` | Kullanıcı etkinliğe katılmadı |

## Katılım kaydının oluşturulması

Etkinlik başladığında `ACCEPTED` durumundaki başvurular için `Attendance` kaydı oluşturulur.

Başlangıç durumu:

`NULL`

olur.

Öğrenci etkinliğin QR kodunu başarıyla tarattığında:

`NULL → ATTENDED`

geçişi gerçekleşir.

Etkinlik tamamlandığında `NULL` olarak kalan kayıtlar sistem tarafından:

`NULL → NOT_ATTENDED`

durumuna geçirilebilir.

---

# 11. Katılım Durumunu Düzeltme

### `PATCH /attendance/{attendanceId}`

Yetkili kulüp yöneticisinin mevcut katılım durumunu düzeltmesini sağlar.

Örneğin:

```json
{
  "status": "NOT_ATTENDED"
}
```

### Yönetici tarafından izin verilen geçişler

* `ATTENDED → NOT_ATTENDED`
* `NOT_ATTENDED → ATTENDED`

Yönetici tarafından:

* `NULL → ATTENDED`
* `NULL → NOT_ATTENDED`

geçişleri yapılamaz.

`NULL` durumu sistem tarafından katılım sürecinin ilgili aşamalarında yönetilir.

### Etkinlik tamamlandıktan sonra

Katılım düzeltmesi etkinlik `COMPLETED` durumuna geldikten sonra da yapılabilir.

Örneğin daha sonra fark edilen bir hata için:

`ATTENDED ↔ NOT_ATTENDED`

düzeltmesi gerçekleştirilebilir.

Bu nedenle etkinliğin `COMPLETED` olması katılım kayıtlarının tamamen değiştirilemez hale gelmesi anlamına gelmez.

MVP kapsamında kullanılan endpoint:

`PATCH /attendance/{attendanceId}`

olacaktır.

---

# 12. İptal Edilen Etkinliklerde Başvuru ve Katılım

Etkinlik `CANCELLED` durumuna geçtiğinde:

* yeni başvuru alınamaz,
* mevcut başvuruların etkinliğe katılım sağlaması mümkün değildir,
* mevcut `Application` kayıtları silinmez,
* `Application` durumlarına `CANCELLED` eklenmez,
* etkinlik başlamadan iptal edildiği için yeni `Attendance` kayıtları oluşturulmaz,
* QR ile katılım işlemi gerçekleştirilemez.

Etkinlik geçmişte `CANCELLED` olarak görüntülenmeye devam eder.

---

# 13. Etkinlik Başladıktan Sonraki Kurallar

Etkinlik başladıktan sonra başvuru süreci kapanır.

### Başvuru

Aşağıdaki `Application` durumları arasında yönetici tarafından yeni karar verilemez:

`PENDING / ACCEPTED / REJECTED / WAITLISTED`

Öğrencinin başvurusunu geri çekmesi de etkinlik başladıktan sonra yapılamaz.

### Katılım

Etkinlik başladıktan sonra katılım süreci devam eder.

Kabul edilmiş katılımcı için:

`NULL → ATTENDED`

QR taraması ile gerçekleşebilir.

Etkinlik tamamlandığında `NULL` kalan katılım kayıtları:

`NULL → NOT_ATTENDED`

olarak sonuçlandırılır.

Etkinlik `COMPLETED` olduktan sonra yönetici yalnızca:

`ATTENDED ↔ NOT_ATTENDED`

düzeltmesi yapabilir.

---

# 14. Endpoint Özeti

| İşlem                          | Endpoint                                      | Yetki                   |
| ------------------------------ | --------------------------------------------- | ----------------------- |
| Etkinlik başvurularını listele | `GET /events/{eventId}/applications`          | İlgili kulüp yöneticisi |
| Başvuruyu kabul et             | `POST /applications/{applicationId}/accept`   | İlgili kulüp yöneticisi |
| Başvuruyu reddet               | `POST /applications/{applicationId}/reject`   | İlgili kulüp yöneticisi |
| Başvuruyu bekleme listesine al | `POST /applications/{applicationId}/waitlist` | İlgili kulüp yöneticisi |
| Katılım listesini görüntüle    | `GET /events/{eventId}/attendance`            | İlgili kulüp yöneticisi |
| Katılım durumunu düzelt        | `PATCH /attendance/{attendanceId}`            | İlgili kulüp yöneticisi |

Sistem tarafından otomatik gerçekleştirilen işlemler ayrı bir kullanıcı endpoint'i olarak tanımlanmaz:

* `WAITLISTED → ACCEPTED`
* `NULL → NOT_ATTENDED`
* `PUBLIC` başvurularının otomatik `ACCEPTED` / `WAITLISTED` belirlenmesi

---

# 15. UC03 Kapsamı

UC03 aşağıdaki işlemleri kapsar:

1. Kulüp yöneticisinin etkinlik başvurularını görüntülemesi
2. Başvuruların `PENDING`, `ACCEPTED`, `REJECTED`, `WAITLISTED` durumlarının yönetilmesi
3. `WITHDRAWN` başvurularının geçmiş kayıt olarak korunması
4. `PUBLIC` etkinliklerde otomatik kabul ve bekleme listesi davranışının uygulanması
5. `APPROVAL_REQUIRED` etkinliklerde yönetici değerlendirmesinin yapılması
6. Kapasite ve bekleme listesi kurallarının uygulanması
7. Kabul edilen başvuruların geri çekilmesi veya reddedilmesi sonucunda kontenjanın yeniden değerlendirilmesi
8. Kapasite artışı sonucunda bekleme listesinin otomatik işlenmesi
9. Etkinlik başladıktan sonra başvuru kararlarının değiştirilememesi
10. Etkinlik katılım kayıtlarının görüntülenmesi
11. QR ile gerçekleşen katılım sonuçlarının görüntülenmesi
12. `ATTENDED` ve `NOT_ATTENDED` durumlarının yönetici tarafından düzeltilmesi
13. Etkinlik tamamlandıktan sonra katılım düzeltmelerinin yapılabilmesi
14. İptal edilen etkinliklerde başvuru ve katılım kurallarının uygulanması

Öğrencinin etkinliğe başvurması, başvurusunu geri çekmesi ve QR ile katılım sağlaması UC01'de; etkinliğin oluşturulması, düzenlenmesi, tamamlanması ve iptal edilmesi UC02'de; bildirim işlemleri ise UC04'te ele alınır.
