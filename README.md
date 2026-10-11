# ♿ AccessPath v2 — Accessibility Feedback for Public Places
### 🎓 IIT (ISM) Dhanbad Edition — Map, GPS, Photos, Profiles & Smart Notifications

> **Flutter app jo public places ki accessibility discover, assess aur share karne me madad karti hai** — ab full version me: multiple pages, live map with satellite mode, real-time location, photo-proof feedback, saved profiles aur smart dwell-notifications! 🚀

---

## 📖 Problem Statement

Divyang (specially-abled) users, bujurg log, ya injury wale students — sabko kahin jaane se pehle yeh sawaal hota hai:

> *"Kya Main Building me lift chalti hai? Library me ramp hai? City Centre Mall me accessible washroom milega?"*

Is information ka koi reliable source nahi hota. **AccessPath** community-powered feedback se yeh gap bharta hai — IIT (ISM) Dhanbad campus aur Dhanbad city ke famous places se shuru karke.

---

## ✨ Features (Full List)

### 1. 📱 Multiple Pages (Bottom Navigation)
| Tab | Page | Kya karta hai |
|-----|------|---------------|
| 🧭 | **Explore** | Places list + search + needs-filter + distance sorting |
| 🗺️ | **Map** | Live map, satellite mode, colored pins, apni location |
| 🆕 | **Add** | Unknown location add karo (GPS ya map se) |
| 👤 | **Profile** | Saved profile + personal stats |

Plus **Detail Page** (har place ki) — score, AI summary, rating bars, photo-wale reviews.

### 2. 📊 Structured Ratings (5 Categories)
| Emoji | Category | Matlab |
|-------|----------|--------|
| 🛗 | Step-free Access | Ramp / bina seedhi ke entry |
| ⬆️ | Lift | Lift available & working |
| 🚻 | Washroom | Wheelchair-friendly washroom |
| 💺 | Seating | Baithne / rest ki jagah |
| 🧭 | Wayfinding | Signage, braille, navigation |

**Overall Score (0–100):** 5 averages ka mean × 20 → 🟢 70+ · 🟠 40–69 · 🔴 <40

### 3. 🗺️ Map with Satellite Mode (NO API KEY NEEDED!)
- **flutter_map + OpenStreetMap** — bilkul **FREE**, koi Google API key/billing nahi!
- 🛰️ **Satellite mode toggle** — Esri World Imagery tiles se
- Har place ka **color-coded pin** (score ke hisaab se) + score label
- 🔵 **Apni real-time location** blue dot me dikhti hai
- 📍 "My Location" button — map aapki position pe fly karta hai
- **Long-press on map** → usi coordinate pe naya place add!

### 4. 📍 Real-time Location Access
- `geolocator` package se GPS permission + live tracking (har 30 sec)
- Explore list me har place ki **doori (m/km)** dikhti hai
- List **distance se sorted** — nazdeeki places pehle

### 5. 🔔 Smart Dwell Notification (UNIQUE!)
> **"Agar user kisi location pe zyada der ruka hai, to feedback ka notification!"**

- App har 30 sec position check karti hai
- Agar user kisi listed place ke **150m ke andar 2+ minute** rukta hai → automatic dialog:
  > *📍 Feedback ka perfect time! Lagta hai aap "Central Library" pe kaafi der se hain...*
- Ek visit me ek place pe sirf **ek baar** poochta hai (spam nahi)
- Multiple users — har user ke apne phone pe uski location ke hisaab se trigger hota hai

### 6. 📷 Live Feedback with Photo Attach (UNIQUE!)
- 5 sliders + comment + **Camera ya Gallery se photo attach**
- Photo-proof wale reviews me thumbnail dikhta hai
- Place card pe 📷 count badge — kitne photo-proofs hain

### 7. 👤 Saved Profile (Gate System 🔒)
- Naam + Roll No/Email + emoji avatar — `shared_preferences` me **permanently saved**
- **Bina profile ke na review de sakte hain, na place add** — accountability!
- Personal stats: mere reviews, added places

### 8. 🆕 Unknown Location Add
- Koi jagah list me nahi? **Add tab** se ya **map par long-press** karke add karo
- Location 3 tarike se: GPS (current position), map long-press, ya manual
- Community-added places pe 🆕 badge dikhta hai

### 9. 🤖 Offline AI Summary
- Template-based NLG — reviews se best/worst category + mood + photo count detect karke **human-jaisa summary** — bina API key, bina internet!

### 10. 💾 Full Offline Persistence
- Saare places, reviews, profile — **app band karke kholo, sab wahi rahega** (`shared_preferences` JSON storage)

---

## 🎓 Pre-loaded Locations (Demo Data)

**IIT (ISM) Dhanbad Campus:** Main Building (Heritage), Central Library, Penman Auditorium, SAC, Oval Garden, Health Centre, Jasper Hostel, Nescafe Kiosk

**Dhanbad City Famous:** City Centre Mall, Sartaj Restaurant (Bank More), Dhanbad Junction, Birsa Munda Park

> ⚠️ Coordinates approximate hain (demo purpose). Reviews 5 alag demo users (Aman, Priya, Rahul, Sneha, Vikas) ke naam se hain — multi-user community feel ke liye.

---

## 🏗️ Architecture (Kam se Kam Code Philosophy)

```
accesspath/
├── lib/
│   ├── main.dart            ← entry + bottom-nav shell + dwell dialog wiring
│   ├── models.dart          ← Review, Place, Profile + score/AI logic + JSON
│   ├── data.dart            ← IIT ISM + Dhanbad seed places
│   ├── store.dart           ← 🧠 state + storage + GPS + dwell detection
│   └── pages/
│       ├── explore_page.dart   ← list + search + filter
│       ├── map_page.dart       ← map + satellite + pins
│       ├── detail_page.dart    ← score + AI + feedback sheet (photo)
│       ├── add_place_page.dart ← naya place add
│       └── profile_page.dart   ← profile save + stats
├── pubspec.yaml             ← sirf 5 chhote packages
└── README.md
```

**Code minimal kaise?**
- ✅ Sirf **5 packages** (map ke liye bhi API-key-free option chuna)
- ✅ State management: ek simple `ChangeNotifier` global store — koi BLoC/Riverpod overhead nahi
- ✅ **Dart 3 Records** categories ke liye — extra classes nahi
- ✅ Computed getters (`score`, `color`, `aiSummary`) — logic model me, UI clean
- ✅ `ListenableBuilder` — data badla to UI khud refresh

---

## 🚀 Setup & Run

```bash
# 1. Project folder me jao
cd accesspath

# 2. Platform scaffolding generate karo (pehli baar)
flutter create .

# 3. Packages install karo
flutter pub get
```

### 📱 Android Permissions (zaroori!)
`android/app/src/main/AndroidManifest.xml` me `<manifest>` tag ke andar add karein:
```xml
<uses-permission android:name="android.permission.INTERNET"/>
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION"/>
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION"/>
```

### 🍎 iOS Permissions
`ios/Runner/Info.plist` me add karein:
```xml
<key>NSLocationWhenInUseUsageDescription</key>
<string>Nazdeeki accessible places dikhane ke liye location chahiye</string>
<key>NSCameraUsageDescription</key>
<string>Feedback me photo attach karne ke liye camera chahiye</string>
<key>NSPhotoLibraryUsageDescription</key>
<string>Feedback me gallery se photo attach karne ke liye</string>
```

### ▶️ Run!
```bash
flutter run              # connected device/emulator pe
flutter run -d chrome    # browser me quick test (location browser se poochega)
```

---

## 🧪 Demo Flow (Judges/Testers ke liye)

1. **Profile tab** → naam + roll no daalo → Save (🔒 gate khul gaya)
2. **Explore tab** → "Lift" chip select karo → sirf lift-wale places dikhte hain
3. **Map tab** → 🛰️ button se satellite mode → pins tap karke details dekho
4. Kisi place pe **Live Feedback** → sliders + comment + 📷 photo → Submit
5. **Map par long-press** → naya "unknown" place add karo
6. Kisi listed place ke paas **2 min khade raho** → 🔔 dwell notification aayega!
7. App **restart** karo → sab data wahi ka wahi (persistence ✅)

---

## 🛠️ Tech Stack

| Chiz | Detail |
|------|--------|
| Framework | **Flutter** (Android, iOS, Web) — mandatory requirement ✅ |
| Map | `flutter_map` + OpenStreetMap + Esri satellite (FREE, no API key) |
| Location | `geolocator` — real-time GPS + dwell detection |
| Photos | `image_picker` — camera/gallery |
| Storage | `shared_preferences` — offline JSON persistence |
| State | Plain `ChangeNotifier` — minimal & fast |
| AI | Offline template-based NLG |

## 🔮 Future Scope
- ☁️ Firebase/Supabase backend — real multi-device sync
- 🔔 True push notifications (FCM) — background dwell alerts
- 🗣️ Screen-reader (TalkBack) polish + voice feedback
- 🌐 Real LLM API se richer summaries
- 🏆 Gamification — top contributors leaderboard

---

*Made with ❤️ & Flutter — "Accessibility sabka haq hai!"*
