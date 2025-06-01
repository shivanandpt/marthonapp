
# Software Requirements Document (SRD)

## Project Title: Marathon Training App

### 1. Overview
This application guides users through a structured marathon training program tailored to their goals, experience level, and availability. The app uses a multi-step onboarding form to generate custom training plans and supports real-time tracking, voice/vibration guidance, reminders, and subscription features.

---

### 2. Functional Requirements

#### 2.1 User Onboarding & Plan Creation
- User logs into the app.
- A multi-step form is presented to collect:
  - Metric system preference (metric/imperial)
  - Weight
  - Height
  - Any injuries
  - Training goal (e.g., 5K, 10K, half marathon, full marathon)
  - Number of training days per week (maximum of 3)
- If all necessary information is filled:
  - A custom training plan is generated (e.g., 3-day/week = 8-week plan).
- If optional but required data is skipped:
  - A common training plan is displayed based on selected goal.

#### 2.2 Training Plan & Dashboard
- Dashboard displays upcoming training days.
- Each training day consists of phases:
  - 3-5 minute warm-up
  - Interval-based running and walking sessions
  - 5-minute cool down
- Intensity increases week-over-week.

#### 2.3 Running Experience
- User starts a run, and the app:
  - Announces warm-up start via voice
  - Announces when to run or walk during intervals
  - Allows switching to vibration-only mode
  - Allows pausing/resuming/skipping a phase
  - Tracks:
    - GPS route
    - Distance
    - Speed
    - Elevation
- Post-run summary includes:
  - Route map
  - Time, distance, speed, and elevation
  - Share option (e.g., social media)

#### 2.4 Motivation & Achievements
- Users earn badges based on achievements:
  - First run
  - Completion of first week
  - Completion of milestone runs

#### 2.5 Reminders & Notifications
- Users receive configurable reminders for upcoming runs.
- Users can view run history.

#### 2.6 Subscription & Access Control
- First 2 weeks of training plan are free.
- Full access requires:
  - Monthly subscription
  - Yearly subscription

#### 2.7 Program Reset
- Users can reset their training program.
- On reset, the previous plan is archived and a new plan is generated.

---

### 3. Non-Functional Requirements
- **Platform**: Android and iOS
- **Performance**: Low-latency voice prompts and real-time tracking
- **Data Storage**: Firebase (Auth, Firestore, Storage)
- **Localization**: Support for multiple languages (starting with English and Marathi)
- **Privacy**: All user data is stored securely and can be deleted on request

---

### 4. Data Models (Logical Summary)
- `users`
- `training_plans`
- `training_days`
- `runs`
- `badges`
- `subscriptions`

---

### 5. Future Enhancements
- Community-based challenge system
- Integration with health platforms (e.g., Google Fit, Apple Health)
- Personalized coaching via AI
- Offline mode

---

### 6. Assumptions
- User is willing to provide basic personal and training-related information.
- Device supports GPS and audio/vibration.
- Firebase is the backend platform.

---

### 7. Constraints
- Limited to 3 training days per week.
- Only one active plan per user at a time.
- Only Android/iOS supported (no web version).