# Project Blueprint: Driving School Management Suite

## Overview

This project aims to build a comprehensive, multi-platform solution for managing a driving school. It consists of three distinct but interconnected applications:

1.  **Admin Panel:** A web-based application for school administrators to manage instructors, learners, enquiries, finances, and overall operations.
2.  **Instructor App:** A mobile application for instructors to manage their schedules, lessons, student progress, and communication.
3.  **Learner App:** A mobile application for learners to book lessons, track their progress, make payments, and access learning materials.

The project will be developed in two main phases, with Phase 1 focusing on core functionalities for a minimum viable product (MVP) launch, and Phase 2 introducing advanced features and enhancements.

---

## Current Development Plan

**Objective:** Begin development of the **Learner App (Phase 1)**.

This initial phase will focus on building the foundational UI and features for the learner-facing application.

**High-Level Steps:**

1.  **Project Scaffolding:**
    *   Organize the project using a feature-first, layered architecture.
    *   Create dedicated directories for each of the three applications to ensure scalability.
2.  **Dependency Management:**
    *   Add `go_router` for declarative navigation.
    *   Add `provider` for state management.
    *   Add `google_fonts` for custom typography.
3.  **Core Application Setup (Learner App):**
    *   Implement a robust Material 3 theme with light and dark modes.
    *   Set up the main application entry point and routing using `go_router`.
    *   Create a `ThemeProvider` to manage theme state.
4.  **Implement Learner App UI (Phase 1 Features):**
    *   **Dashboard:** Create the home screen with a dashboard showing an overview of upcoming lessons, payment status, a progress bar, and a test countdown timer.
    *   **Document Upload:** Build the UI for uploading documents (licence, ID).
    *   **Lesson Management:** Design screens for booking, canceling, and rescheduling lessons. Include options for different lesson durations.
    *   **Payments:** Create UI for viewing payment history, making payments (Card, Apple/Google Pay), saving cards, and buying block bookings.
    *   **Progress Tracking:** Develop UI for viewing reflective logs, instructor feedback, and the DVSA syllabus tracker.
    *   **Theory Test:** Design a placeholder screen for the theory test practice feature.
5.  **Initial Backend/Service Stubs:**
    *   Create model classes for `User`, `Lesson`, `Payment`, etc.
    *   Create dummy data and service classes to simulate backend interactions for UI development.

---

## Detailed Feature Outline

### App No. 1 – Admin Panel

#### PHASE 1
*   Manage instructors and learners (add/edit/remove)
*   Allocate new enquiries to instructors
*   Live view of lesson diaries and performance stats
*   Record income and expenses
*   Auto-generate invoices and franchise reports
*   GDPR-compliant and secure data storage
*   Instructor availability setup (working hours, days off)
*   Instructor holiday / sick leave management
*   Track instructor pass rates & performance dashboard
*   Enquiry pipeline: New → Contacted → Trial Lesson → Active
*   Auto-assign enquiries by postcode + availability
*   Pre-written SMS/Email templates
*   Enquiry conversion tracking
*   Multi-area Zone (1–4) assignment

### App No. 2 – Instructor App

#### PHASE 1
*   Add, edit, cancel lessons instantly
*   Colour-coded calendar
*   Choose lesson duration (1h / 1.5h / 2h)
*   Digital lesson reports
*   Digital reflective logs
*   Lesson reminders for pupils
*   Record payments (received/pending)
*   View learner details & progress charts

#### PHASE 2
*   Route sheets for each test centre
*   Upload photos/videos of student progress
*   Digital DL25 marking sheet
*   Track expenses & fuel logs
*   In-app messaging with pupils & admin
*   Voice notes messaging
*   PDI hours completed tracker
*   Offline mode
*   Group messages from admin

### App No. 3 – Learner App

#### PHASE 1
*   Dashboard with lessons, payments, progress bar
*   Upload documents (licence, ID)
*   Test countdown timer
*   Book, cancel, reschedule lessons
*   Choose lesson duration options
*   Auto late-cancellation charge
*   48-hour / 24-hour reminders
*   Pay via Card, Apple Pay, Google Pay, Cash, Bank Transfer
*   Save card for auto-pay
*   Buy block bookings
*   View payment history & receipts
*   View reflective logs & instructor feedback
*   DVSA syllabus progress tracker
*   Theory test practice

#### PHASE 2
*   Video tutorials
*   Message instructor/admin
*   Voice notes
*   Referral system with credits
*   Achievement badges & progress rewards
