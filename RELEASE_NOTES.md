# Bicycle Maintenance Log — Release Notes (v1.0.1)

**Release Version:** `v1.0.1`  
**Version Code:** `2` (`1.0.1+2`)  
**Release Tag:** `v1.0.1`  
**Student Roll Number:** `24PA1A05I0`  
**SDG Alignment:** SDG 11 – Sustainable Cities and Communities  
**Package Binary:** `Bicycle_Maintenance_Log_24PA1A05I0.apk`  

---

## 🚲 What's New in Version 1.0.1

We are pleased to release **Bicycle Maintenance Log v1.0.1**, a colorful, offline-first mobile application built with Flutter and Material Design 3. This release introduces our custom brand identity, polished dashboard layout, improved service reminder scheduling, and full Indian Rupee (`₹`) currency integration.

---

### 🎨 1. Custom Brand Identity & Professional UI
- **Custom Application Logo:** Integrated a high-resolution, eco-themed custom logo featuring bicycle and tool motifs.
- **Android App Launcher Icons:** Generated adaptive launcher icons across all density tiers (`mdpi`, `hdpi`, `xhdpi`, `xxhdpi`, `xxxhdpi`).
- **Clean Dashboard Header:** Redesigned top navigation header:
  ```
  [App Logo] Bicycle Maintenance Log
             Ride Smart. Maintain Better.
  ```
- **Professional Academic Interface:** Cleaned student roll number (`24PA1A05I0`) from the visible runtime interface for an authentic, production-grade look, while keeping evaluation references preserved in project documentation.

---

### 🔔 2. Smart Service Reminders & Calendar-Date Scheduling
- **Accurate Calendar Matching:** Status calculations compare pure calendar dates (`DateTime(year, month, day)`), eliminating timestamp hour/minute discrepancy issues.
- **Dynamic Status Categorization:**
  - 🟢 **Upcoming (Green):** Scheduled service dates in the future.
  - 🟠 **Due Today (Orange):** Services scheduled for the current date.
  - 🔴 **Overdue (Red):** Past-due services requiring immediate inspection.
- **Nearest First:** Reminders are sorted ascending by next service date to highlight urgent maintenance tasks.
- **Safe Date Deserialization:** Robust JSON deserialization ensures missing or blank service dates default to `null` without crashing.

---

### 💰 3. Financial Tracking in Indian Rupees (₹)
- **Local Currency Integration:** Replaced generic currency with Indian Rupee (`₹`) across all dashboard metrics, stat cards, and maintenance history entries.
- **Real-Time Cumulative Expenses:** Overview card tracks total maintenance expenditures automatically.
- **Input Validation:** Enforces positive values with two decimal precision and allows `₹0.00` for routine self-service.

---

### 🚲 4. Fleet Management & Maintenance History
- **Bicycle Fleet CRUD:** Register, view, edit, and delete multiple bicycles with brand, model, and purchase date.
- **Automatic Cascade Deletion:** Removing a bicycle automatically purges associated service records to prevent orphaned data.
- **Chronological History:** All maintenance logs displayed in reverse-chronological order (newest first) with categorized service type badges (Chain Lubrication, Brake Adjustment, Tyre Replacement, Cleaning, General Servicing).

---

### ⚡ 5. 100% Offline-First Architecture
- **Local Persistence:** Uses `SharedPreferences` storing serialized JSON models.
- **Zero Server Dependencies:** Operates completely offline without requiring Firebase, external APIs, or user authentication.
- **Instant Data Synchronization:** Tab switching and CRUD updates trigger state refreshes across all screens seamlessly.

---

### 🌍 6. SDG 11 Alignment (Sustainable Cities and Communities)
- Dedicated SDG 11 card highlighting how preventive bicycle maintenance encourages safe, dependable cycling and lowers urban carbon emissions.

---

## 📦 APK Installation Instructions

1. Download **`Bicycle_Maintenance_Log_24PA1A05I0.apk`** from the Assets section below.
2. Open the APK on your Android device (Android 5.0+ / API 21+ supported).
3. If updating an existing installation, tap **Update** (your saved bicycles and service logs will be preserved).
4. If installing for the first time, allow installation from your browser/file manager when prompted.

---

## 🧪 Verification & Quality Assurance

- **Static Analysis:** `flutter analyze` completed with **0 issues found**.
- **Automated Tests:** 6/6 test suites passed cleanly (`flutter test`).
- **Target Platforms:** Android, Windows Desktop, Web.
