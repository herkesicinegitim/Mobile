# Herkes İçin Eğitim

**Herkes İçin Eğitim** projesi, öğrencilerin gönüllü öğretmenlerden çevrimiçi ders randevusu alarak eğitim alabileceği ve derslerin çevrimiçi bir platform üzerinden yapılabileceği bir uygulamadır. Proje, Flutter ile geliştirildi ve Firebase Authentication, Firebase Realtime Database ve Google Meet API'ları kullanılarak desteklendi.

## Proje Hedefi

Bu projenin amacı, eğitime erişimde fırsat eşitliği sağlamak ve öğrencilerle gönüllü öğretmenleri bir araya getirerek kaliteli eğitimi ücretsiz olarak sunmaktır. Proje, gönüllü öğretmenlerin ders vermek için müsait oldukları saatlerde ders planlaması yapmalarına olanak tanırken, öğrencilerin de uygun zamanlarına göre randevu almasını sağlamaktadır.

## Özellikler

- Kullanıcı kaydı ve giriş işlemleri (Firebase Authentication kullanarak)
- Öğrencilerin gönüllü öğretmenlerden ders randevusu alması (Firebase Realtime Database kullanarak)
- Online dersler için Google Meet entegrasyonu
- Öğrenciler ve öğretmenler için kullanıcı profilleri
- Ders takvimi ve randevu yönetimi
- Gerçek zamanlı bildirimler ve ders hatırlatıcıları

## Teknolojiler

- **Flutter**: Uygulamanın arayüz ve iş mantığı geliştirilmesinde kullanılan framework.
- **Firebase Authentication**: Kullanıcı kimlik doğrulama işlemleri.
- **Firebase Realtime Database**: Ders randevuları ve kullanıcı verilerinin gerçek zamanlı olarak saklanması ve yönetilmesi.
- **Google Meet API**: Online derslerin gerçekleştirileceği toplantı bağlantılarının oluşturulması ve yönetimi.

## Kurulum

Projeyi kendi bilgisayarınızda çalıştırmak için aşağıdaki adımları izleyin:

### Gereksinimler

- [Flutter](https://flutter.dev/docs/get-started/install)
- Firebase projesi (Authentication ve Realtime Database ayarları)
- Google Meet API erişimi için Google Cloud Console üzerinden bir proje oluşturun ve API anahtarını alın.

### Adımlar

1. Projeyi klonlayın:

   ```bash
   git clone https://github.com/kullanici-adi/herkes-icin-egitim.git
   cd herkes-icin-egitim
