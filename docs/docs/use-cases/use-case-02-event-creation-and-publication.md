# Use Case 02 — Kulübün Etkinlik Oluşturması ve Yayınlaması

## 1. Amaç

Bu use case, yetkili bir kulüp yöneticisinin yeni bir etkinlik oluşturmasını, etkinliği doğrudan yayınlamasını ve etkinlik başlamadan önce belirli etkinlik bilgilerini düzenleyebilmesini tanımlar.

Bu akış kapsamında:

* Etkinlik oluşturma
* Etkinliğin doğrudan yayınlanması
* Etkinlik türü
* Başvuru tarihleri
* Başvuru tipi
* Kapasite
* Etkinlik düzenleme
* Etkinlik iptali
* Etkinliğin belirli koşullarda silinebilmesi
* İptal edilen etkinliklerin geçmişte korunması
* Etkinliği oluşturan yöneticinin kaydedilmesi

kuralları ele alınır.

---

# 2. Aktörler

## Ana Aktör

Kulüp yöneticisi.

Etkinlik oluşturma ve yönetme yetkisi bulunan kulüp rolleri:

* Başkan
* Başkan Yardımcısı
* Yönetici

## Yetkisiz Aktörler

Aşağıdaki kullanıcılar etkinlik oluşturamaz:

* Normal öğrenci
* Yalnızca kulübü takip eden öğrenci
* Kulüpte eski yönetici olan kullanıcı

Global admin normal kulüp etkinliklerini oluşturmaz.

Global admin'in kulüp yönetimi üzerindeki yetkileri bu use case'in kapsamı dışındadır.

---

# 3. Ön Koşullar

Etkinlik oluşturabilmek için:

* Kulüp sistem tarafından onaylanmış olmalıdır.
* Kulüp aktif durumda olmalıdır.
* İşlemi yapan kullanıcı ilgili kulübün yetkili yöneticisi olmalıdır.
* Kullanıcının etkinlik oluşturma ve yönetme yetkisi bulunmalıdır.

Etkinlik oluşturma işlemi sırasında ilgili kulübün aktif yöneticilik ilişkisi sistem tarafından kontrol edilir.

---

# 4. Etkinlik Oluşturma ve Yayınlama

Etkinlik oluşturma ve yayınlama iki ayrı işlem değildir.

Yönetici gerekli bilgileri doldurup etkinliği oluşturduğunda etkinlik doğrudan yayınlanır.

```text
Etkinlik bilgileri girilir
        ↓
Etkinlik oluşturulur
        ↓
Event kaydı PUBLISHED durumunda oluşturulur
```

Etkinlik oluşturulduktan sonra ayrıca global admin onayı beklenmez.

Etkinlik oluşturulduğu anda sistemde `PUBLISHED` durumunda bir Event kaydı oluşur.

Bu nedenle sistemde kalıcı bir:

```text
DRAFT
```

veya

```text
CREATED
```

Event status'u bulunmaz.

`CREATED` ifadesi yalnızca oluşturma işleminin bir aşaması olarak düşünülebilir; veritabanında kalıcı Event status olarak tutulmaz.

Yönetici etkinliği oluşturduktan sonra gerekli düzenlemeleri etkinlik başlamadan önce yapabilir.

---

# 5. Etkinlik Bilgileri

Etkinlik oluşturulurken aşağıdaki bilgiler belirlenir:

* Etkinlik adı
* Açıklama
* Görsel
* Etkinlik türü
* Başlangıç tarihi ve saati
* Bitiş tarihi ve saati
* Fiziksel konum veya online bağlantı
* Başvuru başlangıç tarihi
* Başvuru bitiş tarihi
* Başvuru tipi
* İsteğe bağlı kapasite

Sistem ayrıca etkinliği oluşturan yöneticiyi kaydeder.

Örneğin:

```text
createdBy = User
```

Bu bilgi öğrencilere gösterilmek zorunda değildir.

Sistem içerisinde:

* Denetim
* Geçmiş
* Yönetim kayıtları
* İleride oluşturulabilecek raporlar

amacıyla tutulabilir.

---

# 6. Etkinlik Türü

Etkinlik iki türden biri olabilir:

```text
PHYSICAL
ONLINE
```

## 6.1. Fiziksel Etkinlik

Fiziksel etkinliklerde etkinliğin gerçekleştirileceği konum belirtilir.

Örneğin:

* Fakülte
* Salon
* Derslik
* Kampüs alanı

gibi bilgiler kullanılabilir.

## 6.2. Online Etkinlik

Online etkinliklerde etkinliğe katılım için bağlantı bilgisi bulunur.

Online etkinlik türü ayrıca platformlara bölünmez.

Örneğin:

* Google Meet
* Zoom
* YouTube
* Diğer online platformlar

aynı `ONLINE` etkinlik türü içerisinde değerlendirilebilir.

Online platformun ayrıca bir enum olarak tutulması bu use case kapsamında zorunlu değildir.

---

# 7. Etkinlik Türünün Değiştirilmesi

Etkinlik yayınlandıktan sonra etkinlik türü değiştirilemez.

```text
PHYSICAL → ONLINE     ❌

ONLINE → PHYSICAL     ❌
```

Bu kural etkinlik başlamadan önce de geçerlidir.

Ancak etkinliğin türüne ait erişim bilgileri değiştirilebilir.

### Fiziksel etkinlik

```text
Konum → değiştirilebilir
```

### Online etkinlik

```text
Online bağlantı → değiştirilebilir
```

Dolayısıyla yöneticinin fiziksel etkinliği farklı bir salona taşıması mümkündür; ancak etkinliği fizikselden online'a dönüştürmesi mümkün değildir.

Aynı şekilde online etkinliğin bağlantısı değiştirilebilir ancak etkinlik türü fiziksel olarak değiştirilemez.

---

# 8. Başvuru Tipi

Etkinlik oluşturulurken başvuru tipi belirlenir.

İki temel başvuru tipi vardır:

```text
PUBLIC
APPROVAL_REQUIRED
```

## 8.1. PUBLIC

`PUBLIC` etkinliklerde öğrencinin başvurusu yönetici onayı gerektirmez.

Kapasite belirtilmemişse veya kapasite henüz dolmamışsa başvuru doğrudan `ACCEPTED` olur.

```text
Başvuru
   ↓
ACCEPTED
```

Kapasite dolduğunda yeni başvurular doğrudan `WAITLISTED` durumuna alınır.

```text
Başvuru
   ↓
WAITLISTED
```

PUBLIC başvurularında `PENDING` kalıcı bir Application status olarak kullanılmaz.

Dolayısıyla aşağıdaki akış sistemde gerçek bir status geçişi olarak bulunmaz:

```text
Başvuru
   ↓
PENDING
   ↓
ACCEPTED
```

veya:

```text
Başvuru
   ↓
PENDING
   ↓
WAITLISTED
```

Sistem uygun durumda doğrudan `ACCEPTED` veya `WAITLISTED` kaydı oluşturur.

Bekleme listesindeki öğrenciler başvuru zamanına göre sıralanır.

Kapasite açıldığında bekleme listesindeki ilk uygun öğrenci sistem tarafından otomatik olarak `ACCEPTED` durumuna geçirilir.

Yönetici bu otomatik sıralamayı manuel olarak değiştirmez.

## 8.2. APPROVAL_REQUIRED

`APPROVAL_REQUIRED` etkinliklerde öğrencinin başvurusu yönetici tarafından değerlendirilir.

Kapasite bulunup bulunmamasından bağımsız olarak, başvuru süresi devam ederken yeni başvuru:

```text
Başvuru
   ↓
PENDING
```

durumuna geçer.

Kapasitenin dolmuş olması yeni `PENDING` başvuruların alınmasını engellemez.

Başvuru süresi sona erdikten sonra mevcut `PENDING` başvurular yönetici tarafından değerlendirilir.

Kapasitesi bulunmayan `APPROVAL_REQUIRED` etkinliklerde yönetici başvuruları:

```text
PENDING
   ├──→ ACCEPTED
   └──→ REJECTED
```

şeklinde sonuçlandırabilir.

Kapasitesi bulunan `APPROVAL_REQUIRED` etkinliklerde ise değerlendirme sonucunda:

```text
PENDING
   ├──→ ACCEPTED
   ├──→ WAITLISTED
   └──→ REJECTED
```

durumları kullanılabilir.

`WAITLISTED`, kapasite nedeniyle o anda kabul edilemeyen ancak yedek olarak tutulmak istenen başvuruları ifade eder.

`WAITLISTED` öğrenciler başvuru zamanına göre sıralanır.

Kapasite açıldığında ilk sıradaki bekleme listesi adayı sistem tarafından otomatik olarak `ACCEPTED` durumuna geçirilir.

Bu noktada yöneticinin ayrıca "bekleme listesinden kimi kabul edeceğim" şeklinde manuel seçim yapması gerekmez.

---

# 9. Başvuru Tipinin Değiştirilmesi

Başvuru tipi, başvuru süreci başlamadan önce değiştirilebilir.

```text
Başvuru başlamadı → değiştirilebilir

Başvuru başladı   → değiştirilemez
```

Örneğin:

```text
PUBLIC → APPROVAL_REQUIRED     ✅ Başvuru başlamadıysa

APPROVAL_REQUIRED → PUBLIC     ✅ Başvuru başlamadıysa
```

Başvuru başlangıç tarihi geçtikten sonra başvuru tipi değiştirilemez.

```text
PUBLIC → APPROVAL_REQUIRED     ❌

APPROVAL_REQUIRED → PUBLIC     ❌
```

Bu kuralın amacı, başvuru süreci başladıktan sonra öğrencilerin karşılaştığı başvuru davranışının değiştirilmemesidir.

Örneğin PUBLIC olarak başvurusu alınmaya başlanmış bir etkinliğin başvuru süreci başladıktan sonra `APPROVAL_REQUIRED` yapılması, daha önce otomatik kabul edilen ve yeni başvuran öğrenciler açısından farklı kurallar oluşturacağından izin verilmez.

---

# 10. Kapasite

Etkinlik oluşturulurken kapasite belirtilmesi isteğe bağlıdır.

Kapasite belirtilmezse etkinliğin kapasite sınırı bulunmaz.

```text
capacity = null
```

durumu sınırsız kapasite olarak değerlendirilir.

Kapasite belirtilmişse başvurular etkinliğin başvuru tipine göre kapasiteyle birlikte değerlendirilir.

### PUBLIC etkinliklerde

Kapasite dolana kadar başvurular otomatik olarak kabul edilir.

Kapasite dolduktan sonra yeni başvurular:

```text
WAITLISTED
```

durumuna alınır.

### APPROVAL_REQUIRED etkinliklerde

Kapasitenin dolmuş olması başvuru süresi devam ederken yeni başvuruları engellemez.

Başvurular:

```text
PENDING
```

durumunda kalır.

Başvuru süresi sona erdikten sonra yönetici kapasiteyi dikkate alarak:

* `ACCEPTED`
* `WAITLISTED`
* `REJECTED`

durumlarını belirler.

Kapasitesi bulunmayan `APPROVAL_REQUIRED` etkinliklerde `WAITLISTED` kullanılmaz.

Bu kurallar öğrencinin başvurması ve katılması ile ilgili ayrıntılar açısından Use Case 01'de, yöneticinin başvuruları sonuçlandırması açısından ise Use Case 03'te ayrıca ele alınır.

---

# 11. Kapasitenin Değiştirilmesi

Kapasite değişikliği başvuru başlangıç tarihine göre farklı kurallara tabidir.

## 11.1. Başvuru Başlangıç Tarihinden Önce

Başvuru süreci henüz başlamamışsa kapasite hem artırılabilir hem azaltılabilir.

```text
50 → 40     ✅

50 → 70     ✅
```

Kapasite azaltılırken mevcut `ACCEPTED` sayısının altına inilmemelidir.

Örneğin:

```text
Kapasite: 50
ACCEPTED: 45
```

durumunda kapasitenin:

```text
50 → 45
```

şeklinde azaltılması mümkündür.

Ancak:

```text
50 → 40
```

şeklinde azaltılması mevcut kabul edilmiş başvuruların kapasitenin üzerinde kalmasına neden olacağından mümkün değildir.

## 11.2. Başvuru Süreci Başladıktan Sonra

Başvuru başlangıç tarihi geçtikten sonra kapasite yalnızca artırılabilir.

```text
50 → 70     ✅

50 → 40     ❌
```

Bu kural doğrudan **başvuru başlangıç tarihine** bağlıdır.

Etkinliğe herhangi bir başvuru yapılmış olup olmaması bu kuralı değiştirmez.

Kapasite artırıldığında mevcut bekleme listesi ilgili kurallara göre otomatik olarak işlenir.

Örneğin:

```text
Kapasite: 50

ACCEPTED: 50
WAITLISTED: 10

Kapasite → 55
```

olduğunda açılan 5 kontenjan, bekleme listesindeki ilk 5 adayın `ACCEPTED` durumuna geçirilmesi için kullanılır.

Bu işlem sistem tarafından otomatik gerçekleştirilir.

---

# 12. Başvuru Başlangıç Tarihi

Etkinlik oluşturulurken başvuruların başlayacağı tarih ve saat belirlenir.

Başvuru başlangıç tarihi henüz gelmemişse yönetici bu tarihi değiştirebilir.

Örneğin:

```text
Başvuru başlangıcı: 01 Ekim
Bugün: 25 Eylül
```

ise başlangıç tarihi değiştirilebilir.

Başvuru başladıktan sonra başlangıç tarihi değiştirilemez.

```text
Başvuru başlamadı → değiştirilebilir

Başvuru başladı   → değiştirilemez
```

Bu kural başvuru sürecinin başlangıcından sonra öğrencilerin karşılaştığı zaman aralığının geriye dönük olarak değiştirilmesini önler.

---

# 13. Başvuru Bitiş Tarihi

Başvuru bitiş tarihi etkinlik başlamadan önce değiştirilebilir.

Bu özellikle başvuru süresinin uzatılabilmesini sağlar.

Örneğin:

```text
10 Ekim → 12 Ekim
```

şeklinde başvuru süresi uzatılabilir.

Başvuru süresi sona erdikten sonra mevcut başvurular yönetilmeye devam edebilir.

Özellikle `APPROVAL_REQUIRED` etkinliklerde başvuru süresinin sona ermesinden sonra `PENDING` başvuruların yönetici tarafından sonuçlandırılması mümkündür.

Başvuru bitiş tarihi etkinlik başlangıcından sonra olamaz.

Başvuru bitişinin etkinlik başlangıcına bağlanması nedeniyle etkinlik başladıktan sonra başvuru sürecine ilişkin herhangi bir düzenleme yapılamaz.

---

# 14. Etkinlik Tarihleri

Etkinliğin başlangıç ve bitiş tarihi/saatleri etkinlik başlamadan önce değiştirilebilir.

```text
Başlangıç tarihi/saati → değiştirilebilir

Bitiş tarihi/saati     → değiştirilebilir
```

Etkinlik başladıktan sonra bu alanların değiştirilmesi mümkün değildir.

Etkinlik tarihleri değiştirilirken başvuru tarihleriyle olan zaman ilişkilerinin de korunması gerekir.

Örneğin:

```text
Başvuru başlangıcı < Başvuru bitişi ≤ Etkinlik başlangıcı
```

mantığı bozulacak bir tarih değişikliğine izin verilmemelidir.

Başlangıç tarihi değiştirildiğinde mevcut başvuru kurallarının geçerliliği ayrıca sistem tarafından korunmalıdır.

---

# 15. Etkinlik Adı

Etkinlik adı yayınlandıktan sonra değiştirilemez.

```text
Etkinlik adı → ❌
```

Bu kural etkinlik yayınlandıktan sonra öğrencilerin gördüğü etkinliğin temel kimliğinin değiştirilmemesini sağlar.

Yönetici isimde hata fark ederse, yayınlandıktan sonra mevcut etkinliğin adını değiştirmek yerine yeni etkinlik oluşturma veya uygun yönetim sürecini kullanmalıdır.

---

# 16. Açıklama

Etkinlik başlamamışsa açıklama düzenlenebilir.

```text
Açıklama → ✅
```

Yönetici:

* Etkinlik hakkında ek bilgi verebilir.
* Mevcut açıklamayı güncelleyebilir.
* Öğrencilere açıklayıcı yeni bilgiler ekleyebilir.

Etkinlik başladıktan sonra açıklama düzenlenemez.

---

# 17. Görsel

Etkinlik başlamamışsa etkinliğin görseli değiştirilebilir.

```text
Görsel → ✅
```

Bu sayede yönetici etkinliğin görselini güncelleyebilir veya yanlış yüklenen görseli düzeltebilir.

Etkinlik başladıktan sonra görsel değiştirilemez.

---

# 18. Konum / Online Bağlantı

Etkinlik başlamamışsa etkinliğin erişim bilgileri değiştirilebilir.

### Fiziksel etkinlik

```text
Konum → değiştirilebilir
```

Örneğin etkinliğin salonu veya dersliği değiştirilebilir.

### Online etkinlik

```text
Online bağlantı → değiştirilebilir
```

Örneğin etkinliğin Meet veya başka bir platformdaki bağlantısı güncellenebilir.

Ancak etkinliğin türü değiştirilemez.

```text
PHYSICAL → ONLINE     ❌

ONLINE → PHYSICAL     ❌
```

---

# 19. Etkinlik Düzenleme Özeti

Etkinlik henüz başlamamışsa temel düzenleme kuralları aşağıdaki gibidir:

| Alan                     | Düzenlenebilir                                                                                            |
| ------------------------ | --------------------------------------------------------------------------------------------------------- |
| Etkinlik adı             | ❌                                                                                                         |
| Açıklama                 | ✅                                                                                                         |
| Görsel                   | ✅                                                                                                         |
| Etkinlik türü            | ❌                                                                                                         |
| Başlangıç tarihi/saati   | ✅                                                                                                         |
| Bitiş tarihi/saati       | ✅                                                                                                         |
| Fiziksel konum           | ✅                                                                                                         |
| Online bağlantı          | ✅                                                                                                         |
| Başvuru tipi             | ✅ Başvuru başlamadıysa                                                                                    |
| Kapasite                 | ✅ Başvuru başlamadıysa artırılabilir veya azaltılabilir; başvuru başladıktan sonra yalnızca artırılabilir |
| Başvuru başlangıç tarihi | ✅ Başvuru başlamadıysa                                                                                    |
| Başvuru bitiş tarihi     | ✅ Etkinlik başlamadıysa                                                                                   |

Etkinlik başladıktan sonra etkinliğin düzenlenmesine ilişkin bu değişiklikler yapılamaz.

Başvuru süreci başladıktan sonra ayrıca aşağıdaki kurallar geçerlidir:

* Başvuru tipi değiştirilemez.
* Kapasite azaltılamaz.
* Başvuru başlangıç tarihi değiştirilemez.
* Başvuru bitiş tarihi, etkinlik başlamamış olmak koşuluyla değiştirilebilir.
* Etkinlik türü hiçbir zaman değiştirilemez.
* Etkinlik adı hiçbir zaman değiştirilemez.

---

# 20. Etkinliğin İptal Edilmesi

Yayınlanmış bir etkinlik, etkinlik başlamadan önce iptal edilebilir.

İptal edilen etkinlik:

```text
CANCELLED
```

durumuna geçer.

İptal işlemi, başvuru sürecinin başlayıp başlamadığına bakılmaksızın etkinlik başlamadan önce gerçekleştirilebilir.

```text
PUBLISHED → CANCELLED
```

Etkinlik başladıktan sonra etkinlik iptal edilemez; bu durumda etkinlik yaşam döngüsü farklı bir duruma geçer ve tamamlanmış etkinlik olarak değerlendirilir.

Başvuru süreci başladıktan sonra etkinliğin fiziksel olarak silinmesine izin verilmez.

Bu durumda etkinlik iptal edilecekse:

```text
PUBLISHED → CANCELLED
```

durumu kullanılır.

---

# 20.1. İptal Edilen Etkinlikte Yeni Başvurular

İptal edilen etkinliğe yeni başvuru alınmaz.

Mevcut başvuru kayıtları korunur.

Örneğin etkinlik iptal edilmeden önce:

```text
ACCEPTED
WAITLISTED
REJECTED
WITHDRAWN
```

durumlarında bulunan Application kayıtları silinmez.

Etkinlik `CANCELLED` olduğu için öğrenciler artık bu etkinlik için yeni başvuru oluşturamaz.

---

# 20.2. İptal Edilen Etkinlikte QR

İptal edilen etkinliğin QR kodu ile katılım alınamaz.

Etkinlik iptal edildiği için:

```text
QR → Attendance
```

işlemi gerçekleştirilemez.

Etkinlik başlamadan önce iptal edildiğinden normal akışta henüz Attendance kayıtları oluşturulmamış olur.

---

# 20.3. İptal Edilen Etkinlikte Kayıtlar

Etkinlik iptal edildiğinde mevcut `Application` kayıtları silinmez.

Örneğin:

* Başvurular
* Kabul kayıtları
* Ret kayıtları
* Bekleme listeleri
* Geri çekilmiş başvurular

korunur.

`Application` için ayrıca:

```text
CANCELLED
```

durumu oluşturulmaz.

Etkinlik `CANCELLED` durumunda olduğu için kullanıcı arayüzünde etkinliğin iptal edildiği açıkça gösterilebilir.

Etkinlik başlamadan önce iptal edildiğinden henüz normal katılım süreci başlamamış olur.

Etkinlik geçmişte görüntülenebilir ve iptal edildiği açıkça belirtilir.

---

# 21. Etkinliğin Silinmesi

Yayınlanmış bir etkinliğin fiziksel olarak silinmesine yalnızca sınırlı bir durumda izin verilir.

Etkinlik:

* Başvuru başlangıç tarihinden önce olmalı
* Henüz hiçbir başvuru almamış olmalı

durumundaysa fiziksel olarak silinebilir.

Örneğin:

```text
Event: PUBLISHED

Başvuru başlangıcı: Yarın

Application: 0
```

durumunda yönetici etkinliği silebilir.

Bu durum özellikle:

* Yanlış oluşturulan
* Önemli bir bilgi hatası bulunan
* Henüz kullanıcıların başvurmadığı
* Başvuru süreci başlamadan vazgeçilen

etkinliklerin sistemden kaldırılabilmesini sağlar.

Ancak başvuru başlangıç tarihi geldikten sonra etkinlik fiziksel olarak silinemez.

Başvuru süreci başlamışsa, hiç başvuru yapılmamış olsa dahi etkinliğin silinmesi yerine:

```text
PUBLISHED → CANCELLED
```

durumu kullanılır.

Herhangi bir başvuru alınmış etkinlik ise hiçbir şekilde fiziksel olarak silinemez.

Bu sayede başvuru sürecine girmiş veya kullanıcılarla etkileşime geçmiş etkinliklerin geçmişi korunur.

---

# 22. Etkinliği Oluşturan Yönetici

Sistem etkinliği oluşturan yöneticiyi kaydeder.

Örneğin:

```text
createdBy = User
```

Bu bilgi:

* Denetim
* Geçmiş
* Yönetim kayıtları
* İleride oluşturulabilecek raporlar

için kullanılabilir.

Etkinliği oluşturan yöneticinin daha sonra kulüp yöneticiliğinden ayrılması, `createdBy` bilgisinin değiştirilmesini gerektirmez.

Bu alan etkinliğin oluşturulduğu andaki yönetici bilgisini temsil eder.

Öğrencinin etkinlik ekranında gösterilmesi zorunlu değildir.

---

# 23. Yetki Özeti

| İşlem               |                 Başkan                |           Başkan Yardımcısı           |                Yönetici               | Normal Öğrenci |
| ------------------- | :-----------------------------------: | :-----------------------------------: | :-----------------------------------: | :------------: |
| Etkinlik oluşturma  |                   ✅                   |                   ✅                   |                   ✅                   |        ❌       |
| Etkinliği yayınlama |                   ✅                   |                   ✅                   |                   ✅                   |        ❌       |
| Etkinlik düzenleme  |                   ✅                   |                   ✅                   |                   ✅                   |        ❌       |
| Kapasite artırma    |                   ✅                   |                   ✅                   |                   ✅                   |        ❌       |
| Kapasite azaltma    |       ✅ Başvuru başlamadan önce       |       ✅ Başvuru başlamadan önce       |       ✅ Başvuru başlamadan önce       |        ❌       |
| Etkinlik iptali     |                   ✅                   |                   ✅                   |                   ✅                   |        ❌       |
| Etkinlik silme      | ✅ Başvuru başlamadan ve başvuru yoksa | ✅ Başvuru başlamadan ve başvuru yoksa | ✅ Başvuru başlamadan ve başvuru yoksa |        ❌       |

Bu yetkiler yalnızca ilgili kulüp üzerindeki yöneticilik ilişkisi devam ettiği sürece geçerlidir.

---

# 24. Etkinlik Yaşam Döngüsü

Etkinlik oluşturulduğunda doğrudan yayınlanır.

Kalıcı Event status yaşam döngüsü:

```text
PUBLISHED
   │
   ├────────────→ CANCELLED
   │
   ↓
COMPLETED
```

`DRAFT` durumu bulunmaz.

`CREATED` durumu da kalıcı Event status olarak bulunmaz.

Etkinlik oluşturma işlemi başarılı olduğunda Event doğrudan:

```text
PUBLISHED
```

durumunda oluşturulur.

### Silme durumu

Başvuru başlangıç tarihi henüz gelmemişse ve hiç başvuru alınmamışsa:

```text
PUBLISHED
   ↓
DELETE
```

işlemi gerçekleştirilebilir.

Bu durumda Event kaydı fiziksel olarak kaldırılır ve `CANCELLED` durumuna geçirilmez.

Başvuru başlangıç tarihi geldikten sonra veya herhangi bir başvuru alındıktan sonra fiziksel silme kullanılamaz.

Bu durumda etkinlikten vazgeçilmesi gerekiyorsa:

```text
PUBLISHED
   ↓
CANCELLED
```

kullanılır.

Etkinliğin zamanı geldiğinde normal akış sonunda:

```text
PUBLISHED
   ↓
COMPLETED
```

durumuna geçmesi beklenir.

`COMPLETED` durumuna geçişin tam olarak sistem tarafından hangi anda yapılacağı ayrıca teknik tasarım aşamasında belirlenebilir.

---

# 25. Karar Verilmemiş Konular

Bu use case kapsamında şu anda bilinçli olarak açık bırakılan konular:

## 25.1. Başvuru başlangıç tarihinin sınırları

Başvuru başlangıç tarihinin etkinlik başlangıç tarihine ne kadar yakın olabileceği henüz ayrıca belirlenmemiştir.

Örneğin:

```text
Başvuru başlangıcı
        ↓
Etkinlik başlangıcı
```

arasında minimum bir süre zorunlu olup olmayacağı daha sonra belirlenebilir.

---

## 25.2. Etkinlik tarihi değiştirildiğinde başvuru tarihleri

Etkinlik tarihi değiştirildiğinde mevcut:

* Başvuru başlangıç tarihi
* Başvuru bitiş tarihi

ile yeni etkinlik tarihi arasındaki ilişkinin sistem tarafından nasıl ele alınacağı ayrıca netleştirilebilir.

Temel kural olarak başvuru bitişi etkinlik başlangıcından sonra olamaz.

---

## 25.3. İptal sonrası bildirimler

Etkinlik iptal edildiğinde öğrencilere gönderilecek bildirimler henüz belirlenmemiştir.

Örneğin:

* ACCEPTED öğrenciler
* WAITLISTED öğrenciler
* PENDING öğrenciler

için bildirim gönderilip gönderilmeyeceği bildirim use case'i kapsamında ele alınacaktır.

---

## 25.4. Silinen etkinliklerin denetim kaydı

Başvuru başlamadan ve hiç başvuru almadan silinen etkinliklerin sistemsel audit/log kaydının tutulup tutulmayacağı henüz ayrıca belirlenmemiştir.

Event kaydı fiziksel olarak silinse bile teknik loglarda işlem geçmişinin tutulup tutulmayacağı ayrıca değerlendirilebilir.

---

## 25.5. Etkinlik tamamlanma zamanı

Etkinliğin `COMPLETED` durumuna tam olarak ne zaman geçirileceği henüz kesinleştirilmemiştir.

Örneğin:

```text
Etkinlik bitiş zamanı geldi
        ↓
COMPLETED
```

şeklinde otomatik geçiş yapılması değerlendirilebilir.

---

## 25.6. Etkinlik zamanı değiştirildiğinde mevcut başvurular

Etkinlik başlangıç veya bitiş zamanının değiştirilmesinin:

* Mevcut `ACCEPTED` başvurulara
* `WAITLISTED` başvurulara
* `PENDING` başvurulara
* Attendance sürecine

etkisinin ne olacağı ayrıca netleştirilebilir.

Bu değişikliklerin kullanıcıya bildirilmesi de bildirim use case'i kapsamında değerlendirilebilir.

---

# 26. İlgili Use Case'ler

Bu use case aşağıdaki use case'lerle doğrudan ilişkilidir:

* **Use Case 01 — Öğrencinin Etkinliğe Başvurması ve Katılması**
* **Use Case 03 — Kulübün Etkinlik Başvurularını Yönetmesi**

Use Case 01 özellikle:

* Başvuru oluşturma
* `PUBLIC` / `APPROVAL_REQUIRED` davranışları
* `PENDING`
* `ACCEPTED`
* `REJECTED`
* `WAITLISTED`
* `WITHDRAWN`
* Kapasite
* Bekleme listesi
* Başvuru geri çekme
* Yeniden başvurma
* Attendance

kurallarını ele alır.

Use Case 03 ise özellikle kulüp yöneticisinin mevcut başvuruları değerlendirmesi ve başvuru durumlarını yönetmesiyle ilgilidir.
