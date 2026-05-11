# 7- בסיס נתונים - database (قاعدة البيانات)

## شيطת השמירה הנבחרת (طريقة التخزين المختارة)

تم اختيار **Firebase Firestore** كقاعدة بيانات للمشروع، وهي قاعدة بيانات NoSQL سحابية (Cloud) من Google. تتميز بـ:
- **مزامنة فورية (Real-time sync):** يستقبل التطبيق التغييرات فور حدوثها.
- **مبنية على السحابة (Cloud-based):** لا حاجة لخادم خاص، تدار بالكامل من Google.
- **بنية مرنة (Document-Collection):** تخزن البيانات كـ Documents داخل Collections بدون جدول ثابت.

---

## ארגון הנתונים (تنظيم البيانات - الـ Collections)

### 1. 📁 مجموعة المستخدمين `users`

تُخزَّن بيانات كل مستخدم في وثيقة (Document) معرّفها هو `UID` الخاص بـ Firebase Authentication.

**مثال على وثيقة (Document Example):**
```
users/
  └── UID_abc123xyz/
        ├── name:        "Ahmad Mohammad"
        ├── email:       "ahmad@example.com"
        ├── role:        "employee"         ← (employee أو manager)
        └── created_at:  2024-01-15 10:30:00
```

**الحقول وأنواعها:**

| اسم الحقل | النوع (Type) | الوصف |
|-----------|-------------|-------|
| `name` | String | اسم المستخدم الكامل |
| `email` | String | البريد الإلكتروني للمستخدم |
| `role` | String | دور المستخدم: `employee` أو `manager` |
| `created_at` | Timestamp | تاريخ إنشاء الحساب |

**كود الكتابة لقاعدة البيانات (من LoginScreen.dart):**
```dart
// عند تسجيل الدخول لأول مرة، يُنشأ سجل جديد للمستخدم
await FirebaseFirestore.instance.collection('users').doc(userId).set({
  'name': user.displayName ?? 'User',
  'email': user.email ?? '',
  'created_at': FieldValue.serverTimestamp(),
});
```

---

### 2. 📁 مجموعة جداول الموظفين `work_schedules` (أو ما يُعادلها)

تُخزَّن طلبات جداول العمل التي يرسلها الموظفون إلى المدير.

**مثال على وثيقة (Document Example):**
```
work_schedules/
  └── REQUEST_001/
        ├── employeeName:   "فاطمة علي"
        ├── employeeId:     "EMP002"
        ├── notes:          "متاحة للعمل يوم السبت حسب الحاجة"
        ├── status:         "pending"       ← (pending / approved / rejected)
        ├── submittedAt:    2024-01-15 09:00:00
        └── workSchedule:
              ├── الأحد:    true
              ├── الإثنين:  true
              ├── الثلاثاء: true
              ├── الأربعاء: true
              ├── الخميس:   true
              ├── الجمعة:   false
              └── السبت:    true
```

**الحقول وأنواعها:**

| اسم الحقل | النوع (Type) | الوصف |
|-----------|-------------|-------|
| `employeeName` | String | اسم الموظف |
| `employeeId` | String | الرقم الوظيفي للموظف |
| `notes` | String | ملاحظات إضافية من الموظف |
| `status` | String | حالة الطلب: `pending` / `approved` / `rejected` |
| `submittedAt` | Timestamp | تاريخ ووقت إرسال الطلب |
| `workSchedule` | Map<String, Boolean> | خريطة بأيام الأسبوع (true=يوم عمل، false=إجازة) |

---

### 3. 📁 مجموعة تتبع الوقت `time_tracking`

تُسجَّل فيها ساعات حضور وانصراف كل موظف يومياً.

**مثال على وثيقة (Document Example):**
```
time_tracking/
  └── TRACK_2024_EMP001/
        ├── employeeId:   "EMP001"
        ├── date:         "2024-01-15"
        ├── checkIn:      "08:30:00"
        └── checkOut:     "17:00:00"
```

**الحقول وأنواعها:**

| اسم الحقل | النوع (Type) | الوصف |
|-----------|-------------|-------|
| `employeeId` | String | الرقم الوظيفي للموظف |
| `date` | String | تاريخ يوم العمل |
| `checkIn` | String | وقت الحضور |
| `checkOut` | String | وقت الانصراف |

---

## سكيمة قاعدة البيانات (Database Schema Overview)

```
Firebase Firestore
│
├── 📁 users
│   └── {uid}
│       ├── name: String
│       ├── email: String
│       ├── role: String
│       └── created_at: Timestamp
│
├── 📁 work_schedules
│   └── {requestId}
│       ├── employeeName: String
│       ├── employeeId: String
│       ├── status: String (pending/approved/rejected)
│       ├── notes: String
│       ├── submittedAt: Timestamp
│       └── workSchedule: Map<String, Boolean>
│
└── 📁 time_tracking
    └── {trackId}
        ├── employeeId: String
        ├── date: String
        ├── checkIn: String
        └── checkOut: String
```
