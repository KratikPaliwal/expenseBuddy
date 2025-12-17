# 📱 ExpenseBuddy 

ExpenseBuddy is a **Flutter-based offline-first expense tracking application** with **Firebase authentication**, **SQLite local storage**, and **real-time currency conversion**.

The app is designed to work smoothly **even without internet**, while securely syncing data once the user is online.

---

## 🚀 Features

- 🔐 **Firebase Authentication**
  - Email & Password login
  - Email verification on signup
- 💾 **Offline-First Architecture**
  - SQLite as the single source of truth
  - Full offline support
- ☁️ **Cloud Sync**
  - Firestore → SQLite sync on login
- 💱 **Multi-Currency Support**
  - INR, USD, EUR, JPY
  - Instant updates using Provider
- 📊 **Expense Summary**
  - Monthly animated bar charts
  - Date range & last-month filters
- 🔃 **Sorting Options**
  - Newest / Oldest
  - Amount High → Low
- 🧹 **Expense Management**
  - Add, Edit, Delete expenses
  - Long-press delete with animation
- 🎨 **Clean UI**
  - Material Design
  - Smooth transitions & animations

---

## 🏗️ Application Architecture

```plaintext
+-------------+
| User Action |
+-------------+
        ↓
+-------------+
| Flutter UI  |
+-------------+
        ↓
+--------------------------+
| Provider (State Manager) |
+--------------------------+
        ↓
+--------------------+
| SQLite (Local DB)  |
+--------------------+
        ↓
+---------------------------+
| Firebase Firestore (Cloud)|
+---------------------------+

```
## 🖼️ Screenshots
<img width="300" height="600" alt="image" src="https://github.com/user-attachments/assets/9cd4dc9a-6c4a-4c92-b624-ef5280b57dad" />
<img width="300" height="600" alt="image" src="https://github.com/user-attachments/assets/1e147a53-454b-45d1-96f9-0e2329a9fcb6" />
<img width="300" height="600" alt="image" src="https://github.com/user-attachments/assets/d2a8fd58-41ae-4422-a0eb-76dd34045c80" />
<img width="300" height="600" alt="image" src="https://github.com/user-attachments/assets/2657a602-7251-4d97-8a51-bd8203284a7b" />
<img width="300" height="600" alt="image" src="https://github.com/user-attachments/assets/a3ce10a8-66f8-473e-bce9-a4f668605b66" />
<img width="300" height="600" alt="image" src="https://github.com/user-attachments/assets/44718e88-7b22-4cea-9b24-24f6ec6d1b93" />
<img width="300" height="600" alt="image" src="https://github.com/user-attachments/assets/64e47b89-741a-4913-b526-5b3b2608abbb" />
<img width="300" height="600" alt="image" src="https://github.com/user-attachments/assets/b64e0094-804a-4ca9-87f0-caaf8fb5bd88" />

---
## 📂 Folder Structure

```plaintext
lib/
├── auth/
│   ├── login_screen.dart
│   ├── signup_screen.dart
│   └── auth_wrapper.dart
│
├── home/
│   └── home_screen.dart
│
├── expense/
│   ├── expense_model.dart
│   ├── add_expense_screen.dart
│   └── edit_expense_screen.dart
│
├── summary/
│   ├── summary_screen.dart
│   ├── monthly_bar_chart.dart
│   └── summary_utils.dart
│
├── currency/
│   ├── currency.dart
│   └── currency_provider.dart
│
├── db/
│   └── db_helper.dart
│
├── sync/
│   └── sync_service.dart
│
├── main.dart
└── firebase_options.dart
```
## ⚙️ Setup Instructions

### 1️⃣ Clone the repository
```bash
git clone
```
### 2️⃣ Install dependencies
```
flutter pub get
```
### 3️⃣ Run App
```
flutter run 
```








