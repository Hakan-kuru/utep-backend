# System Requirements

## 1. Proje Tanımı

Bu proje, üniversite öğrencileri ile üniversite öğrenci kulüplerini/topluluklarını tek bir platform üzerinde buluşturmayı amaçlayan bir sistemdir.

Platformun temel amacı; üniversite içerisindeki etkinliklerin keşfedilmesini, etkinliklere başvurulmasını, başvuruların kulüpler tarafından yönetilmesini ve katılımın kayıt altına alınmasını tek bir sistem üzerinden gerçekleştirmektir.

Sistem, mevcut durumda farklı kanallara dağılmış olan WhatsApp grupları, Instagram hesapları, Google Forms, e-posta ve benzeri araçların oluşturduğu parçalı yapıyı azaltmayı hedefler.

---

# 2. Temel Problemler

Sistemin çözmeye çalıştığı temel problemler:

### 2.1. Etkinliklerin Dağınık Olması

Öğrenciler üniversitede gerçekleşen etkinlikleri farklı kaynaklardan takip etmek zorunda kalmaktadır.

Örneğin:

* WhatsApp grupları
* Instagram hesapları
* Fakülte/bölüm grupları
* Afişler
* Arkadaşlar aracılığıyla duyurular

Bu nedenle öğrencinin "Bu hafta üniversitede hangi etkinlikler var?" sorusuna tek bir yerden cevap alması zorlaşmaktadır.

### 2.2. Etkinlik Başvuru Sürecinin Manuel Olması

Kulüplerin etkinlik başvurularında Google Forms gibi araçları kullanması, başvuruların daha sonra manuel olarak işlenmesine neden olabilmektedir.

Başvuru sonrasında:

* Katılımcıların incelenmesi
* Kabul/reddetme
* E-posta gönderme
* WhatsApp gruplarına ekleme
* Katılımcı listesinin tutulması

gibi işlemler ayrı araçlar üzerinden yürütülebilmektedir.

### 2.3. Öğrenci Geçmişinin Merkezi Olmaması

Öğrencinin:

* Hangi kulüpleri takip ettiği
* Hangi etkinliklere başvurduğu
* Hangi etkinliklere kabul edildiği
* Hangi etkinliklere gerçekten katıldığı

gibi bilgiler tek bir sistem içerisinde merkezi olarak tutulmamaktadır.

### 2.4. Kulüp Yönetiminin Dağınık Olması

Kulüplerin etkinlik ve katılımcı yönetimi farklı araçlarla gerçekleştirilebilmektedir.

Platform, kulüplere etkinlik ve başvuru yönetimi için merkezi bir çalışma alanı sağlamayı amaçlar.

---

# 3. Sistem Kullanıcıları

Sistem üç temel aktör üzerinden ele alınır:

1. Öğrenci / Kullanıcı
2. Kulüp yöneticisi
3. Global sistem yöneticisi

## 3.1. Kullanıcı

Sistemde temel hesap türü `User` olacaktır.

Kulüp yöneticileri için ayrı bir kullanıcı hesabı oluşturulmayacaktır.

Bir kullanıcı normal bir öğrenci olarak sistemi kullanırken aynı zamanda bir veya birden fazla kulüpte yönetici rolüne sahip olabilir.

Örneğin:

```text
User
├── Etkinlikleri görüntüler
├── Kulüpleri takip eder
├── Etkinliklere başvurur
├── Etkinliklere katılır
└── Bir veya daha fazla kulüpte yönetici olabilir
```

Bu nedenle kulüp yöneticiliği kullanıcı hesabının kendisinden ziyade kullanıcının ilgili kulüp ile olan ilişkisi üzerinden tanımlanacaktır.

---

# 4. Kulüp Sistemi

## 4.1. Kulüp Oluşturma

Herhangi bir kullanıcı doğrudan aktif bir kulüp oluşturup yönetmeye başlayamaz.

Kulüp oluşturmak isteyen kişi bir kulüp başvurusu gerçekleştirir.

Başvuru global sistem yöneticisi tarafından incelenir.

Kulüp başvurusu aşağıdaki durumlardan birinde bulunabilir:

* Pending
* Approved
* Rejected
* Suspended

Kulüp yalnızca onaylandıktan sonra platform üzerinde aktif hale gelir.

> Bu doğrulama, üniversitenin resmi kulüp/topluluk onay sürecinin yerine geçmez. Platform içerisindeki yetkilendirme ve doğrulama mekanizmasıdır.

## 4.2. Kulüp Temsilcisi

Kulüp başvurusu sırasında kulübü temsil eden bir kullanıcı belirtilir.

Başvuru onaylandığında bu kullanıcı ilgili kulüpte yönetici rolüne sahip olur.

Kullanıcının sistemdeki hesabı ayrıca oluşturulmaz veya değiştirilmez.

---

# 5. Kulüp Yönetici Rolleri

Kulüp içerisinde üç temel yönetici rolü bulunacaktır:

* President
* Vice President
* Manager

Türkçe karşılıkları:

* Başkan
* Başkan Yardımcısı
* Yönetici

Bir kullanıcı aynı zamanda normal öğrenci özelliklerini kullanmaya devam eder.

## 5.1. Başkan

Başkan kulübün en yüksek kulüp içi yetkiye sahip yöneticisidir.

Başkan:

* Etkinlik oluşturabilir ve yayınlayabilir.
* Etkinlik başvurularını yönetebilir.
* Katılım bilgilerini yönetebilir.
* Başkan yardımcısı/yönetici ekleyebilir veya çıkarabilir.
* Başkanlık devri sürecini başlatabilir.

## 5.2. Başkan Yardımcısı

Başkan yardımcısı:

* Etkinlik oluşturabilir ve yayınlayabilir.
* Etkinlik başvurularını yönetebilir.
* Katılım bilgilerini yönetebilir.
* Diğer yöneticileri ekleyebilir veya çıkarabilir.

Başkan yardımcısı doğrudan başkan olamaz. Başkanlık değişimi için ayrıca belirlenen devir süreci uygulanır.

## 5.3. Yönetici

Yönetici:

* Etkinlik oluşturabilir ve yayınlayabilir.
* Etkinlik başvurularını yönetebilir.
* Katılım bilgilerini yönetebilir.

Yönetici başka yöneticileri ekleyemez veya çıkaramaz.

---

# 6. Yetki Matrisi

| İşlem                    | Başkan | Başkan Yardımcısı | Yönetici |
| ------------------------ | -----: | ----------------: | -------: |
| Etkinlik oluşturma       |      ✅ |                 ✅ |        ✅ |
| Etkinlik yayınlama       |      ✅ |                 ✅ |        ✅ |
| Başvuruları yönetme      |      ✅ |                 ✅ |        ✅ |
| Katılım yönetme          |      ✅ |                 ✅ |        ✅ |
| Yönetici ekleme          |      ✅ |                 ✅ |        ❌ |
| Yönetici çıkarma         |      ✅ |                 ✅ |        ❌ |
| Başkanlık devri başlatma |      ✅ |                 ❌ |        ❌ |

Kulüp bilgilerinin düzenlenmesi gibi bazı yetkiler henüz kesinleştirilmemiştir ve ilerleyen gereksinim analizinde belirlenecektir.

---

# 7. Başkanlık Devri

Başkanlık değişimi diğer yönetici değişikliklerinden farklıdır.

Mevcut başkan başka bir kullanıcıya başkanlığı devretmek istediğinde:

1. Mevcut başkan yeni başkan adayını belirler.
2. Başkanlık devri talebi oluşturulur.
3. Global sistem yöneticisi talebi inceler.
4. Talep onaylanırsa yeni kullanıcı başkan olur.
5. Eski başkanın başkanlık rolü sona erer ve ilgili kulüpteki yeni rolü belirlenir.

Başkanlık devri sırasında kullanıcı hesabı kapatılmaz veya yeni bir hesap oluşturulmaz.

Rol değişikliği kullanıcının kulüp ile olan ilişkisi üzerinden gerçekleştirilir.

---

# 8. Kulüp Yönetim Geçmişi

Kulüp içerisindeki yönetici değişiklikleri geçmişe dönük olarak kayıt altına alınacaktır.

Sistemin ileride aşağıdaki bilgileri tutabilmesi hedeflenmektedir:

* Kullanıcı
* Kulüp
* Rol
* Rolün başlangıç tarihi
* Rolün bitiş tarihi

Bu kayıtların başlangıçta kullanıcı arayüzünde gösterilmesi zorunlu değildir.

Ancak sistem, kulübün geçmişte kim tarafından ve hangi tarihler arasında yönetildiğini kaybedemeyecek şekilde tasarlanmalıdır.

---

# 9. Kulüp Takip Sistemi

Öğrenciler kulüpleri takip edebilir.

Takip sistemi resmi üniversite kulüp üyeliği anlamına gelmez.

Bir öğrenci:

```text
Kulübü takip eder
        ↓
Kulübün etkinliklerini keşfeder
        ↓
İlgilendiği etkinliklere başvurur
```

Kulüp takibi için kulüp yöneticisinin onayı gerekmemektedir.

Bu sistemde "takip" ile "resmi kulüp üyeliği" birbirinden ayrı kavramlardır.

---

# 10. Gelecekte Engelleme Sistemi

Engelleme özelliği MVP kapsamında zorunlu değildir.

Ancak veri modeli gelecekte aşağıdaki gibi bir yapının eklenmesine engel olmamalıdır:

```text
Club → User
      ↓
    Blocked
```

Örneğin ileride bir kulüp bir kullanıcıyı engellerse:

* Kullanıcı kulübü takip edemeyebilir.
* Kulübün etkinliklerine başvuramayabilir.
* Kulübün etkinliklerine katılamayabilir.

Bu davranışların ayrıntıları daha sonra belirlenecektir.

---

# 11. Etkinlik Sistemi

## 11.1. Etkinlik Oluşturma

Onaylanmış bir kulübün yetkili yöneticileri etkinlik oluşturabilir.

Etkinlik oluşturma ve yayınlama iki ayrı işlem olmayacaktır.

Yetkili yönetici etkinliği oluşturduğunda etkinlik platform üzerinde yayınlanır.

Etkinliklerin yayınlanması için her etkinlikte global sistem yöneticisinin önceden onayı gerekmeyecektir.

Bu yaklaşım, sistem yöneticisinin her etkinliği manuel olarak incelemek zorunda kalmasını önlemeyi amaçlar.

Global yönetici gerektiğinde yayınlanmış içeriklere sonradan müdahale edebilir.

## 11.2. Etkinlik Bilgileri

Etkinlik için temel olarak aşağıdaki bilgilerin tutulması planlanmaktadır:

* Etkinlik adı
* Açıklama
* Tarih
* Saat
* Konum
* Düzenleyen kulüp
* Başvuru durumu
* Katılımcı bilgileri
* Kapasite bilgisi (henüz kesinleşmedi)

Etkinlik alanlarının tamamı MVP gereksinimleri kesinleşirken tekrar değerlendirilecektir.

---

# 12. Etkinlik Keşfi

Öğrenciler platform üzerinden üniversitedeki etkinlikleri keşfedebilmelidir.

Temel hedef:

> Öğrencinin üniversitede gerçekleşen etkinlikleri farklı WhatsApp gruplarını veya sosyal medya hesaplarını tek tek takip etmek zorunda kalmadan keşfedebilmesi.

Etkinlikler ilerleyen aşamalarda:

* Tarihe
* Kulübe
* Kategoriye
* Etkinlik türüne

gibi kriterlere göre filtrelenebilir.

Detaylı filtreleme MVP kapsamı kesinleşirken belirlenecektir.

---

# 13. Etkinlik Başvurusu

Öğrenciler uygun etkinliklere platform üzerinden başvurabilir.

Temel akış:

```text
Etkinlik keşfedilir
      ↓
Etkinlik detayları görüntülenir
      ↓
Başvuru yapılır
      ↓
Kulüp başvuruyu inceler
      ↓
Kabul / Ret
```

Kulüp yöneticileri etkinlik başvurularını sistem üzerinden görüntüleyebilir ve yönetebilir.

Başvuruların ayrıntılı yaşam döngüsü henüz tamamen kesinleştirilmemiştir.

Özellikle:

* Başvurunun iptal edilmesi
* Bekleme listesi
* Etkinlik kapasitesi
* Etkinlik iptal edildiğinde başvuruların durumu

gibi konular daha sonra belirlenecektir.

---

# 14. Katılım Sistemi

Başvuru yapmak ile etkinliğe gerçekten katılmak farklı kavramlardır.

Bu nedenle başvuru durumu ile katılım durumu birbirinden ayrı değerlendirilmelidir.

Temel akış:

```text
Başvuru
   ↓
Kabul
   ↓
Etkinliğe katılım
   ↓
Katılım doğrulama
```

Katılımın QR kod kullanılarak doğrulanması planlanmaktadır.

---

# 15. QR Kod ile Katılım

MVP kapsamında etkinlik katılımının QR kod ile doğrulanması hedeflenmektedir.

Temel senaryo:

```text
Öğrenci etkinliğe kabul edilir
        ↓
Etkinliğe fiziksel olarak katılır
        ↓
QR kodu tarar
        ↓
Katılım kaydı oluşturulur
```

QR kodun:

* Kim tarafından oluşturulacağı
* Kim tarafından gösterileceği
* Ne kadar süre geçerli olacağı
* Aynı kişinin birden fazla kez okutmasının nasıl engelleneceği
* QR kodun kötüye kullanımının nasıl önleneceği

henüz tasarlanmamıştır.

Bu konular teknik tasarım aşamasında ayrıca ele alınacaktır.

---

# 16. Etkinlik Değerlendirmesi

Etkinlik değerlendirme sistemi gelecekte kullanılmak üzere planlanmaktadır.

Temel kural:

> Bir etkinliği yalnızca gerçekten katılmış olan kullanıcı değerlendirebilir.

Planlanan yapı:

* 1–5 yıldız değerlendirmesi
* Kullanıcı başına etkinlik başına tek değerlendirme

Kulübün veya kulüp yöneticilerinin kullanıcı değerlendirmesini değiştirmemesi hedeflenmektedir.

Etkinlik değerlendirmeleri ileride kulüp puanı oluşturmak için kullanılabilir.

Ancak kulüp puanının nasıl hesaplanacağı henüz belirlenmemiştir.

---

# 17. Yorum Sistemi

Yorum sistemi MVP kapsamında zorunlu değildir.

İleride yorum özelliği eklenirse temel kuralın:

> Yalnızca etkinliğe gerçekten katılmış kullanıcıların yorum yapabilmesi

olması planlanmaktadır.

---

# 18. Global Sistem Yöneticisi

Global sistem yöneticisi, platformun tamamı üzerinde yönetim yetkisine sahip olacaktır.

Temel sorumluluklar:

* Kulüp başvurularını incelemek
* Kulüpleri onaylamak veya reddetmek
* Kulüpleri gerektiğinde askıya almak
* Kulüp yetkilendirmelerini yönetmek
* Başkanlık devir taleplerini onaylamak
* Platform kurallarının ihlal edilmesi durumunda müdahale etmek

Global yönetici normal kulüp etkinliği oluşturma veya etkinlik başvurusu süreçlerinin bir parçası değildir.

---

# 19. Kullanıcı Hesabı ve Roller

Sistemde kullanıcı hesabı ile kulüp rolü birbirinden ayrıdır.

Örneğin:

```text
User: Hakan
│
├── Öğrenci özellikleri
│
├── Club A → PRESIDENT
│
└── Club B → MANAGER
```

Bu yapı sayesinde aynı kullanıcı farklı kulüplerde farklı rollere sahip olabilir.

Bir kullanıcının yalnızca tek bir kulüpte yönetici olacağına dair şu aşamada bir kısıtlama getirilmeyecektir.

Gerekli görülürse bu kural ileride değiştirilebilir.

---

# 20. MVP İçin Planlanan Temel Özellikler

İlk sürümün temel amacı sistemi uçtan uca çalıştırmaktır.

### Öğrenci

* Hesap oluşturma / giriş
* Etkinlikleri görüntüleme
* Etkinlik detaylarını görüntüleme
* Etkinliğe başvurma
* Başvuru durumunu görüntüleme
* Başvuru geçmişini görüntüleme
* Kulüpleri keşfetme
* Kulüp takip etme
* Kabul edildiği etkinliklere katılma
* QR kod ile katılım doğrulama
* Katılım geçmişini görüntüleme

### Kulüp

* Kulüp başvurusu
* Global yönetici tarafından kulüp onayı
* Yetkili yöneticilerin etkinlik oluşturması
* Etkinlik yayınlama
* Etkinlik başvurularını görüntüleme
* Başvuruları kabul/reddetme
* Katılım bilgilerini yönetme
* QR tabanlı katılım sürecini kullanma

### Global Yönetici

* Kulüp başvurularını görüntüleme
* Kulüp onaylama/reddetme
* Kulüp askıya alma
* Kulüp yöneticilerini/yetkilerini yönetme
* Başkanlık devri taleplerini onaylama
* Gerektiğinde içerik veya kulüp üzerinde müdahale

---

# 21. MVP Dışında Planlanan Özellikler

Aşağıdaki özellikler proje kapsamında değerlendirilebilir ancak ilk MVP'nin zorunlu parçaları değildir:

* Etkinlik puanlama
* Etkinlik yorumları
* Kulüp puanlama sistemi
* Bildirimler
* Kulüp takip bildirimleri
* Etkinlik hatırlatmaları
* Sertifika sistemi
* Etkinlik fotoğraf/video paylaşımı
* Gelişmiş filtreleme
* Kulüp ve etkinlik istatistikleri
* Sosyal özellikler
* Kariyer/proje/yarışma fırsatları
* Üniversite sistemleriyle entegrasyon

---

# 22. Henüz Kesinleştirilmeyen Konular

Aşağıdaki konular gereksinim analizinin sonraki aşamalarında kararlaştırılacaktır:

### Kullanıcı

* Öğrenci doğrulama yöntemi
* Üniversite e-posta zorunluluğu
* Kullanıcı profilinde tutulacak bilgiler

### Kulüp

* Kulüp bilgilerinin kim tarafından düzenlenebileceği
* Başkan ve başkan yardımcısının tüm yetki farkları
* Bir kullanıcının aynı anda yönetebileceği kulüp sayısı için herhangi bir sınır olup olmayacağı
* Kulüp askıya alma sonrası mevcut etkinliklerin durumu

### Etkinlik

* Etkinlik kapasitesi
* Başvuru son tarihi
* Etkinlik iptali
* Başvuru iptali
* Bekleme listesi
* Etkinlik düzenleme kuralları
* Geçmiş etkinliklerin durumu

### QR Katılım

* QR oluşturma yöntemi
* QR geçerlilik süresi
* QR güvenliği
* Tekrarlı okutmaların engellenmesi
* Katılımın manuel olarak düzeltilip düzeltilemeyeceği

### Değerlendirme

* Puanlama sisteminin MVP'ye dahil edilip edilmeyeceği
* Yorum sistemi
* Kulüp puanının hesaplama yöntemi

---

# 23. Temel Sistem İlkeleri

Projenin ilerleyen teknik tasarım aşamalarında aşağıdaki prensipler korunmalıdır:

1. **Kullanıcı hesabı ile kulüp rolü birbirinden ayrı tutulmalıdır.**
2. **Takip, resmi kulüp üyeliği olarak değerlendirilmemelidir.**
3. **Başvuru ve gerçek katılım birbirinden ayrı kavramlardır.**
4. **Kulüp yöneticilerinin normal öğrenci özellikleri kaybolmamalıdır.**
5. **Başkanlık değişiklikleri geçmişe dönük izlenebilir olmalıdır.**
6. **Her etkinliğin önceden global yönetici tarafından onaylanması gerekmemelidir.**
7. **Global yönetici platformun genel kontrol ve moderasyon mekanizmasıdır.**
8. **MVP'de olmayan özellikler temel domain yapısını gereksiz şekilde karmaşıklaştırmamalıdır.**
9. **Henüz kararlaştırılmamış konular teknik tasarım aşamasında varsayım olarak kabul edilmemelidir.**

---

# 24. Gereksinim Analizinin Sonraki Aşaması

Bu dokümanın tamamlanmasından sonra teknik geliştirmeye doğrudan başlanmayacaktır.

Önerilen sıra:

```text
Requirements
     ↓
User Scenarios / Use Cases
     ↓
Domain Model
     ↓
Permission & State Rules
     ↓
Architecture
     ↓
Database Model
     ↓
API Contract
     ↓
UI / UX
     ↓
Implementation
```

Bu aşamada özellikle **User Scenarios / Use Cases** oluşturularak sistemdeki gerçek kullanıcı akışları ayrıntılı şekilde tanımlanacaktır.

Daha sonra bu senaryolardan hareketle domain modeli çıkarılacaktır.
