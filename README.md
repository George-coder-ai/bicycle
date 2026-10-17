# Bicycle Maintenance Log

**Student Roll Number:** 24PA1A05I0  
**Project Name:** Bicycle Maintenance Log  
**SDG Alignment:** SDG 11 – Sustainable Cities and Communities  
**Course / Evaluation:** B.Tech Computer Science & Engineering Flutter Evaluation  

---

## 1. Project Objective

The **Bicycle Maintenance Log** is a colorful, clean, and fully functional Flutter mobile application designed to help bicycle owners, commuters, and enthusiasts easily maintain their bicycles. It empowers users to:
1. Register and manage multiple bicycles in their fleet.
2. Record maintenance activities (lubrication, brake adjustments, tyre changes, cleanings, and servicing).
3. Track and aggregate overall maintenance expenditure.
4. Keep track of upcoming, due today, and overdue service schedules via in-app reminders.
5. Support eco-friendly urban mobility under UN Sustainable Development Goal 11.

---

## 2. SDG Alignment (SDG 11 – Sustainable Cities and Communities)

> **"Regular bicycle maintenance encourages safe, sustainable, and eco-friendly transportation."**

* **Sustainable Urban Mobility:** Safe and properly serviced bicycles reduce reliance on fossil-fuel-powered motor vehicles, helping to ease urban traffic congestion and lower city air pollution.
* **Safety & Reliability:** Proper brake adjustment, chain lubrication, and timely tyre replacements prevent breakdowns and road accidents, encouraging cycling as a viable daily commute choice.
* **Affordability:** Preventive maintenance drastically lowers the long-term cost of bicycle ownership, fostering inclusive and resilient transport for community members.

*(Note: In accordance with academic guidelines, this project avoids exaggerated claims and does not simulate synthetic carbon emission formulas.)*

---

## 3. Key Features

- **Home Dashboard:**
  - Real-time statistics cards with pastel color-coding (Total Bicycles, Total Maintenance Records, Cumulative Maintenance Expenses).
  - Dedicated SDG 11 highlight card with eco-theming.
  - Quick-action buttons to instantly add bicycles and log servicing.
  - Upcoming service preview list.

- **My Bicycles (CRUD):**
  - View all registered bicycles with brand, model, and purchase date.
  - Add new bicycles with form validation and calendar date picker.
  - Edit existing bicycle details seamlessly.
  - Delete bicycles with safety confirmation dialog and **automatic cascade deletion** of related maintenance records to eliminate orphaned data.
  - Friendly empty state when no bicycles exist.

- **Maintenance History (CRUD):**
  - Displays all maintenance records sorted in **chronological order (latest records first)**.
  - Visual cards with color-coded service type icons, cost badges, and notes.
  - Add, edit, and delete maintenance activities.
  - Automatic validation preventing negative costs and requiring valid bicycle selection.

- **Service Reminders:**
  - Automatically identifies maintenance records with scheduled next service dates.
  - Dynamic in-app status categorization:
    - 🟢 **Upcoming:** Future scheduled dates.
    - 🟠 **Due Today:** Services scheduled for today.
    - 🔴 **Overdue:** Past service dates requiring immediate attention.
  - Sorted by date ascending to highlight urgent tasks.

- **Offline-First Persistence:**
  - 100% offline functionality using `SharedPreferences`.
  - Data serialized as JSON models (`toJson()` and `fromJson()`).
  - Automatically persists across app restarts and navigation.

---

## 4. Technologies Used

- **Framework:** Flutter 3.24.5 (Channel stable)
- **Language:** Dart 3.5.4 (Null Safety enabled)
- **Design System:** Material Design 3 (Material 3 widgets, color schemes, and iconography)
- **Local Storage:** `shared_preferences` (^2.5.3) for offline JSON persistence
- **State Management:** Beginner-friendly `StatefulWidget` and `setState()` (Zero boilerplate, no complex third-party state libraries)
- **Target Platform:** Android (also compatible with Windows desktop and Web)

### Curated Color Palette
- **Primary:** Teal (`#009688`)
- **Secondary:** Blue (`#42A5F5`)
- **Accent:** Orange (`#FFB74D`)
- **Additional Accent:** Purple (`#9575CD`)
- **Background:** Soft Slate (`#F8FAFC`)
- **Cards:** Pure White (`#FFFFFF`) with subtle elevation shadows
- **Pastel Stat Cards:** Pastel Teal, Pastel Blue, Pastel Orange, Pastel Purple, and Pastel Green

---

## 5. Folder & Project Structure

The project strictly adheres to modular separation of concerns:

```
lib/
├── main.dart                      # App entry point, Material 3 theme, BottomNavigationBar (4 tabs)
├── models/
│   ├── bicycle.dart               # Bicycle data model with JSON serialization & copyWith
│   └── maintenance.dart           # MaintenanceRecord model with service types & JSON serialization
├── screens/
│   ├── home_screen.dart           # Screen 1: Home Dashboard with stat cards & SDG 11 section
│   ├── bicycle_list_screen.dart   # Screen 2: My Bicycles list with CRUD actions
│   ├── add_bicycle_screen.dart    # Screen 3: Add & Edit bicycle form with validation & date picker
│   ├── history_screen.dart        # Screen 4: Chronological maintenance history with latest-first
│   ├── add_maintenance_screen.dart# Screen 5: Add & Edit maintenance form with bicycle dropdown
│   └── reminders_screen.dart      # Screen 6: In-app service reminders (Upcoming, Due Today, Overdue)
├── services/
│   └── storage_service.dart       # SharedPreferences persistence layer with cascade deletion
├── utils/
│   └── app_colors.dart            # Unified color palette tokens & status colors
└── widgets/
    ├── bicycle_card.dart          # Reusable bicycle card with icons, tags & edit/delete buttons
    ├── maintenance_card.dart      # Reusable maintenance card with category icons & cost badges
    └── stat_card.dart             # Reusable pastel statistics overview card

test/
└── widget_test.dart               # Unit tests for models, storage, cascade deletion, and widget smoke tests
```

---

## 6. How to Run the Application

### Prerequisites
1. [Flutter SDK](https://docs.flutter.dev/get-started/install) installed.
2. Android Studio or VS Code with Flutter & Dart extensions installed.
3. An Android device with USB debugging enabled OR an Android Emulator configured.

### Step-by-Step Instructions

1. **Clone or Open the Project:**
   Open the project folder in **Visual Studio Code** or **Android Studio**.

2. **Install Dependencies:**
   Open a terminal in the root folder and run:
   ```bash
   flutter pub get
   ```

3. **Verify Code Quality:**
   Run static analysis to verify zero errors or lints:
   ```bash
   flutter analyze
   ```

4. **Run Unit & Widget Tests:**
   Execute the automated test suite:
   ```bash
   flutter test
   ```

5. **Launch on Android:**
   Connect your Android phone or start an emulator, then run:
   ```bash
   flutter run
   ```

6. **Build Release / Debug APK (Optional):**
   To produce a standalone Android APK:
   ```bash
   flutter build apk --debug
   ```
   The APK will be located at:
   `build/app/outputs/flutter-apk/app-debug.apk`

---

## 7. College Evaluation Summary

| Requirement | Implementation Details | Status |
|---|---|---|
| **Student Roll Number** | `24PA1A05I0` in AppBar, tests, and documentation | Verified |
| **Material 3 Design** | `useMaterial3: true`, custom color scheme, rounded cards | Verified |
| **Color Specifications** | Teal (#009688), Blue (#42A5F5), Orange (#FFB74D), Purple (#9575CD) | Verified |
| **Offline Storage** | `SharedPreferences` storing JSON arrays with cascade delete | Verified |
| **Bicycles Management** | Add, Edit, Delete, Form validation, Date picker | Verified |
| **Maintenance Tracking** | 6 Required Service Types, Cost validation (non-negative), Notes | Verified |
| **Reminders** | Sorted by date, Green (Upcoming), Orange (Due Today), Red (Overdue) | Verified |
| **SDG 11 Integration** | Highlight card on Home dashboard with eco description | Verified |
| **Currency Display** | All maintenance expenses displayed in Indian Rupees (₹) | Verified |
| **Automated Tests** | 4/4 Test suites passing (`flutter test`) | Verified |
| **Static Analysis** | `flutter analyze` reports **No issues found!** | Verified |
