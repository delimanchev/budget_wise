# 💸 BudgetWise – Pametno upravljanje vaših osebnih financ

BudgetWise je varna in prijazna Flutter aplikacija, ki omogoča uporabnikom popoln nadzor nad njihovimi prihodki, odhodki, ravnotežjem in finančnimi navadami. Z intuitivnim vmesnikom, šifrirano hrambno podatkov in Google prijavo je primerna za vsakodnevno uporabo tako doma kot na poti.

---

## 🧠 Namen projekta

- 📊 Spremljanje osebnih financ (prihodki, odhodki)
- 🔒 Varno in zasebno shranjevanje podatkov (šifrirano)
- 🖼️ Prikaz statistike porabe po kategorijah z grafi
- 🚀 Podpora več platformam (web, Android)

---

## ✅ Glavne funkcionalnosti

| Funkcionalnost              | Opis                                                                 |
|----------------------------|----------------------------------------------------------------------|
| 🔐 Firebase prijava        | Prijava z e-pošto in geslom ali Google računom                      |
| 🔒 AES enkripcija          | Šifrirani prihodki, odhodki in opisi transakcij v Firestore         |
| 💰 Beleženje transakcij    | Dodajanje prihodkov in odhodkov z izbiro kategorije                 |
| 📊 Vizualna analiza        | Interaktivni krožni diagram (Pie chart) za porabo po kategorijah    |
| 🧾 Povzetek računa         | Prikaz trenutnega stanja, vseh prihodkov in odhodkov                |
| 👤 Profil uporabnika       | Urejanje osebnih podatkov in izbris računa z reavtentikacijo        |
| 🎨 Temna tema              | Ročni vklop/izklop temne teme                                       |
| 🔄 Vztrajna seja           | Aplikacija si zapomni uporabnika med sejami                         |

---

## 🧰 Tehnološki sklad

| Tehnologija            | Namen                                                  |
|------------------------|---------------------------------------------------------|
| Flutter 3+             | Gradnja odzivne večplatformne mobilne/spletne aplikacije |
| Firebase Auth          | Avtentikacija z e-pošto in Google računom              |
| Firestore              | NoSQL baza za uporabniško-specifične podatke           |
| SharedPreferences      | Lokalne nastavitve (npr. tema, mesečni proračun)       |
| Lottie                 | Animacije za boljšo UX izkušnjo                        |
| fl_chart               | Vizualizacija podatkov (grafi)                         |
| encrypt + crypto       | AES enkripcija občutljivih vrednosti                   |

---

## 🧪 Namestitev aplikacije

```bash
Instaliraj .apk file ki se nahaja v Releases
```
## 🧪 Namestitev in zagon (lokalno)

```bash
# 1. Kloniraj projekt
git clone https://github.com/tvoj-uporabnik/budgetwise.git
cd budgetwise

# 2. Namesti vse pakete
flutter pub get

# 3. Nastavi Firebase (potrebna predhodna Firebase nastavitev)
flutterfire configure

# 4. Zaženi aplikacijo
flutter run -d chrome    # za splet
flutter run -d android   # za Android telefon ali emulator
