# Software Requirements Specification (SRS)

## Queez - Interactive Learning & Assessment Platform

**Version:** 2.1  
**Last Updated:** November 30, 2025  
**Project Repository:** Queez

---

## 📋 Table of Contents

1. [Introduction](#1-introduction)
2. [System Overview](#2-system-overview)
3. [Current Implementation Status](#3-current-implementation-status)
4. [User Types & Roles](#4-user-types--roles)
5. [Functional Requirements](#5-functional-requirements)
6. [Feature Roadmap](#6-feature-roadmap)
7. [Technical Architecture](#7-technical-architecture)
8. [Database Schema](#8-database-schema)
9. [API Endpoints](#9-api-endpoints)
10. [Premium Features](#10-premium-features)

---

## 1. Introduction

### 1.1 Purpose

Queez is a comprehensive interactive learning and assessment platform designed to empower both educators and individuals to create, share, and participate in various educational activities including quizzes, flashcards, polls, surveys, and collaborative learning experiences.

### 1.2 Scope

The platform supports two primary user types:

- **Individuals/Personal Users**: Create personal learning materials, share quizzes, explore courses, and collaborate with peers
- **Educators**: Manage courses, provide feedback, interact with students, and access advanced analytics

### 1.3 Vision

To create an engaging, gamified learning ecosystem that makes education accessible, interactive, and fun while providing educators with powerful tools to track and enhance student learning.

---

## 2. System Overview

### 2.1 Platform Components

- **Mobile Application**: Flutter-based cross-platform app (iOS & Android)
- **Backend API**: FastAPI Python server with MongoDB database and Redis for real-time sessions
- **Authentication**: Firebase Authentication
- **Cloud Storage**: Firebase Cloud Storage (for images/media)
- **Database**: MongoDB Atlas (quiz data) + Firestore (user profiles) + Redis (live sessions)
- **AI Integration**: Google Gemini for content generation

### 2.2 Core Technologies

- **Frontend**: Flutter/Dart, Material Design, Riverpod 3.x state management
- **Backend**: FastAPI, Python 3.x, Motor (async MongoDB driver), Redis
- **Database**: MongoDB Atlas, Cloud Firestore, Redis
- **Authentication**: Firebase Auth
- **Real-time Communication**: WebSockets (FastAPI + Flutter)
- **AI**: Google Gemini API
- **Hosting**: Render (Backend), Firebase (Frontend assets)

---

## 3. Current Implementation Status

### 3.1 ✅ Completed Features (Implementation Progress: ~55%)

#### Authentication & User Management (70% Complete)

- [x] Firebase email/password authentication
- [x] User login/signup with validation
- [x] Profile setup flow (4-step onboarding)
  - Welcome screen
  - Role selection (Student/Educator/Professional)
  - Basic info (name, username, age, DOB)
  - Preferences (subject area, experience level, interests)
- [x] User profile storage in Firestore
- [x] Profile page with user details display
- [x] Edit profile page (full implementation)
- [x] Profile picture management
- [x] Session persistence with SharedPreferences + Firebase
- [x] Auto-navigation based on auth state
- [x] Sign out with confirmation dialog
- [ ] Social login (Google, Apple, Facebook)
- [ ] Two-factor authentication (2FA)
- [ ] Password reset functionality
- [ ] Email verification
- [ ] Account deletion

#### Quiz Creation & Management (85% Complete)

- [x] Create quizzes with multiple question types:
  - Single choice MCQ
  - Multiple choice MCQ
  - True/False
  - Drag and Drop
- [x] Quiz metadata (title, description, category, language)
- [x] Cover image selection by category (default images)
- [x] Question navigation with visual indicators
- [x] Quiz validation (prevent empty fields - HTTP 400)
- [x] Save quizzes to MongoDB
- [x] Edit existing quizzes
- [x] Delete quizzes (with confirmation)
- [x] Quiz library view with search functionality
- [x] Filter by category/language/type
- [x] Quiz cache management (offline draft saving via QuizCacheManager)
- [x] Quiz play/attempt interface (PlayQuizScreen)
- [x] Answer selection and submission
- [x] Score calculation and results display
- [x] Progress indicators
- [x] Timer display (per-question timer bar)
- [x] Auto-submit on timeout
- [x] Retry quiz functionality
- [x] Backend quiz attempts tracking
- [x] Original owner tracking for shared quizzes
- [x] Image picker service
- [ ] Custom cover image upload (file upload)
- [ ] Question image/video/audio attachments
- [ ] Explanation/hints for questions
- [ ] Points customization per question
- [ ] Time limits per question
- [ ] Quiz templates
- [ ] Import quiz from file (CSV, JSON)
- [ ] Duplicate/clone quiz
- [ ] Archive quiz
- [ ] Public/private visibility settings
- [ ] Export quiz to PDF/DOCX

#### Live Multiplayer System (95% Complete) ⭐⭐⭐

- [x] Live quiz mode (Kahoot-style) - **FULLY IMPLEMENTED**
  - Session creation with unique codes (6-char alphanumeric)
  - QR code display for easy joining
  - Host controls and dashboard (LiveHostView)
  - Real-time participant tracking
  - Live lobby with participant list
  - Synchronized question delivery
  - Configurable question timer
  - Real-time answer collection
  - Live leaderboard updates
  - Results broadcast
  - WebSocket integration (frontend + backend)
  - Reconnection handling with overlay UI
  - Active session recovery on app restart
  - Answer feedback overlay with points
  - Podium display for top 3
  - Answer distribution chart
  - Self-paced mode option
  - 200 max participants supported
  - Redis-based session management
  - Anti-duplicate submission
  - Concurrent user handling (50+ tested)
- [x] Multiple sharing modes:
  - Share (add to library)
  - Live multiplayer
  - Self-paced
  - Timed individual
- [ ] Power-ups and special abilities
- [ ] In-game chat
- [ ] Tournament brackets

#### Content Creation Tools (90% Complete)

**Flashcards (90% Complete):**
- [x] Create flashcard decks with metadata (title, description, category, language)
- [x] Add cards (term/definition - front/back)
- [x] Edit flashcard set and individual cards
- [x] Delete cards and sets
- [x] Reorder cards
- [x] Study mode interface (FlashcardStudyScreen)
- [x] Flip animation (3D perspective transform)
- [x] Swipe gestures for navigation
- [x] Progress tracking (card count indicator)
- [x] Save to library
- [x] AI-powered flashcard generation (Gemini)
- [x] Background loading with status indicators
- [x] Backend API integration (CRUD endpoints)
- [ ] Image attachments on cards
- [ ] Audio pronunciation
- [ ] Advanced study modes (spaced repetition, matching)
- [ ] Import/export flashcards

**Notes (90% Complete):**
- [x] Create notes with rich text editor (Flutter Quill)
- [x] Toolbar with formatting options:
  - Bold, italic, underline
  - Text color, highlight
  - Lists (bullet, numbered)
  - Headers (H1-H6)
  - Alignment
  - Links
  - Code blocks
  - Block quotes
- [x] View notes (QuillViewer)
- [x] Edit notes
- [x] Delete notes
- [x] Save note content as JSON (Delta format)
- [x] Backend API integration (CRUD endpoints)
- [x] AI-powered notes generation (Gemini)
- [ ] Note templates (Cornell, outline, etc.)
- [ ] Image embedding
- [ ] Voice notes
- [ ] Sharing and collaboration

**Study Sets (85% Complete):**
- [x] Create study set with metadata (title, description, category, language)
- [x] Study set links to quiz, flashcard, and note
- [x] Backend CRUD operations (study_sets.py)
- [x] AI-powered generation of complete study sets (Gemini) - **FULLY WORKING**
  - Generate quiz with multiple questions
  - Generate flashcard deck
  - Generate notes (rich text)
  - All from a single topic/prompt
- [x] View study set in library
- [x] Delete study set
- [x] Status tracking during AI generation
- [ ] Study set analytics
- [ ] Collaborative study sets
- [ ] Share study sets
- [ ] Study planner integration

**Polls & Surveys (0% Complete):**
- [ ] Create polls - Placeholder only
- [ ] Create surveys - Placeholder only

#### Library System (60% Complete)

- [x] View created quizzes, flashcards, notes, and study sets
- [x] Unified library with all item types
- [x] Search functionality
- [x] Filter by type (quiz/flashcard/note/study_set)
- [x] Filter by category/language
- [x] Delete items
- [x] Pull-to-refresh
- [x] Add quiz modal
- [ ] Sort options (newest, popular, top-rated)
- [ ] Grid/list view toggle
- [ ] Favorites/bookmarks
- [ ] Recently viewed
- [ ] Download for offline access
- [ ] Organize into folders/collections
- [ ] Public library/marketplace

#### AI Features (75% Complete) ⭐⭐

- [x] AI quiz generation (ai_generation.py)
  - Generate from topic
  - Configure difficulty level
  - Configure number of questions
  - Select question types
  - Backend processing with Gemini
  - Status tracking during generation
- [x] AI flashcard generation
  - Generate from topic
  - Extract key concepts
  - Generate term/definition pairs
  - Auto-categorization
- [x] AI notes generation
  - Generate from topic
  - Rich text output (Delta JSON format)
  - Structured content with headings
- [x] AI study set generation - **FULLY WORKING**
  - Generate comprehensive sets from single prompt
  - Includes quiz + flashcards + notes
  - Configuration options (language, category, difficulty)
  - Progress tracking
  - Review and edit generated content
- [ ] RAG (Retrieval Augmented Generation) chat
- [ ] Document upload for context parsing
- [ ] Smart recommendations

#### Analytics & Statistics (20% Complete)

- [x] Leaderboard system (live multiplayer - real-time)
- [x] Session statistics in host view
- [x] User's rank display
- [x] Top scores display
- [ ] Personal analytics dashboard
- [ ] Learning hours tracking
- [ ] Study streaks
- [ ] Quiz performance analytics
- [ ] Classroom analytics
- [ ] Global leaderboards
- [ ] Export reports

#### Backend API (15 Route Modules - 50+ Endpoints)

- [x] Quiz CRUD operations (quizzes.py)
- [x] User management endpoints (users.py)
- [x] Search & filtering (by category, language, query)
- [x] Quiz statistics & analytics (analytics.py)
- [x] Quiz attempts tracking
- [x] Reviews & ratings system (reviews.py)
- [x] Leaderboard functionality (leaderboard.py)
- [x] Categories management (categories.py)
- [x] Dashboard statistics
- [x] Flashcard CRUD (flashcards.py)
- [x] Notes CRUD (notes.py)
- [x] Study sets CRUD (study_sets.py)
- [x] AI generation endpoints (ai_generation.py)
- [x] Live multiplayer endpoints (live_multiplayer.py)
- [x] WebSocket handling (websocket.py)
- [x] Results management (results.py)
- [x] Library endpoints (library.py)
- [x] Session management with Redis

#### UI/UX Components

- [x] Custom bottom navigation with animated FAB
- [x] Page transitions (fade, slide animations)
- [x] Custom form components (dropdowns, text fields)
- [x] Color-coded UI with brand identity
- [x] Responsive layouts
- [x] Loading states & error handling
- [x] Search interface with filters
- [x] Material Design implementation
- [x] Riverpod 3.x state management
- [x] Pull-to-refresh patterns
- [x] Overlay UIs (reconnection, answer feedback)

### 3.2 ❌ Not Implemented (Critical Gaps)

#### High Priority Missing Features:
- [ ] Classroom management system (0% complete)
- [ ] Communication features (messaging, announcements) (0% complete)
- [ ] Gamification (badges, achievements, challenges) (15% complete)
- [ ] Course platform (0% complete)
- [ ] Premium features & payment integration (0% complete)
- [ ] Admin panel & moderation tools (0% complete)
- [ ] Social features (follow, friends) (0% complete)
- [ ] Notifications system (0% complete)
- [ ] Advanced settings (themes, accessibility) (0% complete)

### 3.3 🚧 In Progress / Partially Implemented

- [~] Polls & Surveys (UI placeholders only, no backend)
- [~] Learning games (planned, not started)
- [~] Analytics dashboard (live multiplayer leaderboard only)
- [~] Sharing features (live multiplayer ✓, async mode partial)
- [~] Document upload for AI (file picker exists, parsing not implemented)

---

## 4. User Types & Roles

### 4.1 Individual/Personal User

**Primary Use Cases:**

- Self-directed learning
- Quiz creation for personal study
- Sharing quizzes with peers
- Joining study groups/classrooms
- Exploring and purchasing courses
- Collaborative content creation

**User Permissions:**

- Create, edit, delete own quizzes
- Share quizzes (live/async modes)
- Join classrooms as student or collaborator
- Access purchased courses
- Participate in duels and challenges (Premium)
- Use AI assistance for content creation

### 4.2 Educator

**Primary Use Cases:**

- Course creation and management
- Student performance tracking
- Providing feedback and assessments
- Broadcasting announcements
- Moderating classrooms
- Analyzing learning metrics

**User Permissions:**

- All Individual permissions
- Create and manage classrooms
- Assign teacher/student roles
- Access admin panel features
- View detailed analytics
- Direct messaging with students
- Course monetization options
- Bulk operations on content

---

## 5. Functional Requirements

### 5.1 Authentication & Authorization

#### FR-AUTH-001: User Registration

- **Description**: Users can create accounts using email/password
- **Inputs**: Email, password, confirm password
- **Validation**:
  - Valid email format
  - Password minimum 6 characters
  - Passwords must match
- **Output**: User account created in Firebase Auth

#### FR-AUTH-002: User Login

- **Description**: Users can log in with credentials
- **Inputs**: Email, password
- **Output**: Authentication token, redirect to dashboard

#### FR-AUTH-003: Profile Setup

- **Description**: New users complete 4-step onboarding
- **Steps**:
  1. Welcome introduction
  2. Role selection (Student/Educator/Professional)
  3. Basic information (name, age, DOB)
  4. Preferences (subject, experience, interests)
- **Output**: Complete user profile saved to Firestore

#### FR-AUTH-004: Session Management

- **Description**: Maintain user session across app restarts
- **Implementation**: SharedPreferences stores login state and last route
- **Output**: Auto-redirect to last location on app launch

### 5.2 Quiz Management

#### FR-QUIZ-001: Create Quiz

- **Description**: Users can create quizzes with metadata and questions
- **Required Fields**:
  - Title (non-empty)
  - Description (non-empty)
  - Category (dropdown selection)
  - Language (dropdown selection)
  - Cover image (auto-assigned or custom)
  - At least 1 question
- **Question Types Supported**:
  - Single Choice MCQ
  - Multiple Choice MCQ
  - True/False
  - Drag and Drop
- **Validation**: Backend validates all fields are non-empty (400 error if invalid)
- **Output**: Quiz saved to MongoDB with unique ID

#### FR-QUIZ-002: Edit Quiz

- **Description**: Users can modify existing quizzes
- **Capabilities**:
  - Update metadata (title, description, category, language)
  - Add/remove/modify questions
  - Change cover image
- **Output**: Updated quiz saved to database

#### FR-QUIZ-003: Delete Quiz

- **Description**: Users can delete their own quizzes
- **Confirmation**: Require confirmation dialog
- **Output**: Quiz permanently removed from database

#### FR-QUIZ-004: View Quiz Library

- **Description**: Display all quizzes created by user
- **Features**:
  - Grid/list view of quiz cards
  - Show title, description, category, question count
  - Search functionality
  - Filter by category/language
- **Performance**: Cache loaded quizzes, lazy loading

#### FR-QUIZ-005: Search & Filter Quizzes

- **Description**: Users can find quizzes by various criteria
- **Search Options**:
  - Text search (title/description)
  - Filter by category
  - Filter by language
  - Sort by: newest, most popular, top-rated
- **Output**: Filtered list of quizzes

#### FR-QUIZ-006: Quiz Validation

- **Description**: Prevent invalid quiz submission
- **Rules**:
  - Title cannot be empty or whitespace
  - Description cannot be empty or whitespace
  - Language must be selected
  - Category must be selected
  - At least 1 complete question required
- **Output**: Display specific error messages (HTTP 400)

### 5.3 Question Management

#### FR-QUES-001: Single Choice MCQ

- **Description**: Multiple choice with one correct answer
- **Requirements**:
  - Question text (required)
  - 2-10 options (default 4)
  - Exactly one correct answer selected
- **Output**: Question data with correctAnswerIndex

#### FR-QUES-002: Multiple Choice MCQ

- **Description**: Multiple choice with multiple correct answers
- **Requirements**:
  - Question text (required)
  - 2-10 options
  - At least one correct answer selected
- **Output**: Question data with correctAnswerIndices array

#### FR-QUES-003: True/False Question

- **Description**: Binary choice question
- **Requirements**:
  - Question text (required)
  - Options fixed to ["True", "False"]
  - One correct answer (index 0 or 1)
- **Output**: Question data with correctAnswerIndex

#### FR-QUES-004: Drag and Drop Question

- **Description**: Match items to targets
- **Requirements**:
  - Question text (required)
  - Drag items list (2-10 items)
  - Drop targets list (matching count)
  - Correct matches map
- **Output**: Question data with dragItems, dropTargets, correctMatches

### 5.4 Classroom Management

#### FR-CLASS-001: Create Classroom

- **Description**: Users can create virtual classrooms
- **Required Fields**:
  - Classroom name
  - Subject/topic
  - Description
  - Privacy setting (public/private/invite-only)
- **Output**: Classroom created with unique code

#### FR-CLASS-002: Join Classroom

- **Description**: Users can join existing classrooms
- **Methods**:
  - Classroom code entry
  - Invitation link
  - Search and request to join (public classrooms)
- **Output**: User added to classroom roster

#### FR-CLASS-003: Classroom Roles

- **Description**: Assign and manage user roles within classroom
- **Roles**:
  - **Owner**: Creator with full permissions
  - **Teacher**: Can create content, grade, manage students
  - **Student**: Can participate, submit assignments
  - **Collaborator**: Can create content, limited admin access
- **Permissions Matrix**: Define what each role can do

#### FR-CLASS-004: Invite Members

- **Description**: Classroom owners/teachers can invite others
- **Methods**:
  - Email invitation
  - Share classroom code
  - Generate invitation link
  - Add from contacts/friends list
- **Output**: Invitation sent to user

### 5.5 Content Sharing & Distribution

#### FR-SHARE-001: Share Quiz (Live Mode)

- **Description**: Host live quiz sessions (Kahoot-style)
- **Features**:
  - Generate session code
  - Real-time participant tracking
  - Synchronized question display
  - Live leaderboard updates
  - Timer per question
- **Output**: Live quiz session with real-time results

#### FR-SHARE-002: Share Quiz (Async Mode)

- **Description**: Share quiz as form (Google Forms-style)
- **Features**:
  - Generate shareable link
  - No time limit
  - Submit at own pace
  - View results after submission
- **Output**: Shareable quiz link

#### FR-SHARE-003: Quiz Access Control

- **Description**: Control who can access shared quizzes
- **Options**:
  - Public (anyone with link)
  - Classroom only
  - Specific users/groups
  - Password protected
- **Output**: Access permissions saved

### 5.6 Course Management

#### FR-COURSE-001: Browse Courses

- **Description**: Users can explore available courses
- **Features**:
  - Category filtering
  - Search by keyword
  - Sort by: rating, price, popularity, newest
  - Preview course content (free chapters)
- **Output**: List of courses with metadata

#### FR-COURSE-002: Purchase Course

- **Description**: Users can buy paid courses
- **Payment Integration**: Razorpay/Stripe integration (TBD)
- **Process**:
  1. Add to cart
  2. Proceed to checkout
  3. Payment processing
  4. Course enrollment confirmation
- **Output**: Course added to user's library

#### FR-COURSE-003: Access Course Content

- **Description**: Enrolled users can view course materials
- **Content Types**:
  - Video lessons
  - Reading materials (PDF, articles)
  - Quizzes/assessments
  - Assignments
  - Discussion forums
- **Progress Tracking**: Save user progress through course

#### FR-COURSE-004: Course Feedback

- **Description**: Students can rate and review courses
- **Components**:
  - Star rating (1-5)
  - Written review
  - Timestamp
- **Moderation**: Educators can respond to reviews

### 5.7 Collaboration Features

#### FR-COLLAB-001: Collaborative Quiz Creation

- **Description**: Multiple users co-create quizzes
- **Features**:
  - Invite collaborators
  - Real-time or async editing
  - Assign sections to different users
  - Version history/change tracking
  - Comment/suggestion system
- **Output**: Collaboratively created quiz

#### FR-COLLAB-002: Peer Review

- **Description**: Users can review each other's content
- **Process**:
  1. Request review from peers
  2. Reviewers provide feedback
  3. Creator makes revisions
  4. Approve final version
- **Output**: Improved content quality

### 5.8 Analytics & Statistics

#### FR-STATS-001: User Learning Hours

- **Description**: Track time spent learning
- **Metrics**:
  - Total learning hours
  - Hours per week/month
  - Time by subject/category
  - Study streak tracking
- **Output**: Visual charts and statistics

#### FR-STATS-002: Quiz Performance Analytics

- **Description**: Detailed quiz attempt statistics
- **Metrics**:
  - Total attempts
  - Average score
  - Pass/fail rate
  - Time spent per question
  - Most missed questions
- **Output**: Performance dashboard

#### FR-STATS-003: Classroom Analytics

- **Description**: Track classroom membership and activity
- **Metrics**:
  - Number of classrooms joined
  - Active vs inactive classrooms
  - Participation rates
  - Contribution to classroom content
- **Output**: Classroom insights

#### FR-STATS-004: Leaderboard

- **Description**: Competitive rankings for quizzes
- **Rankings**:
  - Quiz-specific leaderboard (top scores)
  - Classroom leaderboard (top students)
  - Global leaderboard (platform-wide)
- **Features**:
  - Filter by time period
  - Display rank, score, time taken
  - Profile picture and username

### 5.9 AI Features

#### FR-AI-001: AI Quiz Generation

- **Description**: Generate quiz questions using AI
- **Inputs**:
  - Topic/subject
  - Difficulty level
  - Number of questions
  - Question types
- **AI Model**: Integration with OpenAI/Google Gemini/local LLM
- **Output**: Auto-generated quiz questions

#### FR-AI-002: AI Flashcard Generation

- **Description**: Create flashcards from study materials
- **Inputs**:
  - Text/PDF document
  - Key concepts to focus on
  - Number of cards
- **Output**: Flashcard deck with Q&A pairs

#### FR-AI-003: RAG (Retrieval Augmented Generation)

- **Description**: AI assistant with context awareness
- **Features**:
  - Upload reference materials
  - Ask questions about content
  - Generate summaries
  - Create practice questions
- **Output**: Contextually relevant AI responses

### 5.10 Gamification

#### FR-GAME-001: Points & Badges

- **Description**: Reward system for activities
- **Points Earned For**:
  - Creating quizzes
  - Completing quizzes
  - Achieving high scores
  - Helping others
  - Daily login streak
- **Badges**:
  - Achievement milestones
  - Special accomplishments
  - Role-specific badges
- **Output**: User points and badge collection

#### FR-GAME-002: Streaks

- **Description**: Encourage consistent learning
- **Types**:
  - Login streak
  - Study streak
  - Quiz completion streak
- **Rewards**: Bonus points for maintaining streaks
- **Output**: Streak counter and rewards

#### FR-GAME-003: Challenges

- **Description**: Time-limited competitive events
- **Challenge Types**:
  - Daily quiz challenge
  - Weekly topic challenge
  - Community challenges
- **Rewards**: Special badges, points, recognition
- **Output**: Challenge leaderboard and rewards

### 5.11 Communication Features

#### FR-COMM-001: In-App Messaging

- **Description**: Direct messaging between users
- **Features**:
  - One-on-one chat
  - Group messaging (classroom groups)
  - File sharing
  - Notification system
- **Output**: Real-time message delivery

#### FR-COMM-002: Educator-Student Chat

- **Description**: Educators can communicate with students
- **Features**:
  - Individual student messaging
  - Broadcast to all students in classroom
  - Office hours scheduling
  - Read receipts
- **Output**: Enhanced communication channel

#### FR-COMM-003: Announcements

- **Description**: Classroom-wide announcements
- **Who Can Post**: Classroom owners and teachers
- **Features**:
  - Rich text formatting
  - Attach files/links
  - Pin important announcements
  - Push notifications
- **Output**: Announcement posted to classroom feed

### 5.12 Premium Features (See Section 10)

#### FR-PREM-001: Quiz Duels

- **Description**: Head-to-head competitive quizzes
- **Participants**: 2-4 users simultaneously
- **Features**:
  - Real-time gameplay
  - Live scoring
  - Winner announcement
  - Rewards for winners
- **Subscription**: Premium feature only

---

## 6. Feature Roadmap

### Phase 1: Foundation (Current - Completed)

- ✅ User authentication & profile setup
- ✅ Basic quiz creation (4 question types)
- ✅ Quiz library with search
- ✅ Backend API with 31 endpoints
- ✅ UI/UX framework with animations

### Phase 2: Content Expansion

**Priority: High**

#### 2.1 Quiz Taking/Attempt System

- [ ] Quiz attempt interface
- [ ] Answer submission
- [ ] Score calculation
- [ ] Results display
- [ ] Retry functionality
- [ ] Time tracking per question
- [ ] Save progress (resume later)

#### 2.2 Additional Content Types

- [ ] Poll creation interface
  - Single/multiple choice polls
  - Anonymous/named voting
  - Real-time results visualization
  - Export poll results
- [ ] Survey creation
  - Multi-page surveys
  - Various question types (text, scale, matrix)
  - Response validation
  - Results analytics
- [ ] Flashcard system
  - Create flashcard decks
  - Spaced repetition algorithm
  - Study modes (flip cards, match game, test)
  - Progress tracking

#### 2.3 Learning Tools

- [ ] Study games
  - Matching game
  - Fill in the blanks
  - Word scramble
  - Crossword puzzles
- [ ] Interactive diagrams
  - Label the diagram
  - Drag and drop matching
- [ ] Note-taking integration

### Phase 3: Social & Collaboration

**Priority: High**

#### 3.1 Classroom Features

- [ ] Create classroom functionality
- [ ] Join classroom with code/link
- [ ] Classroom dashboard
  - Member list
  - Activity feed
  - Upcoming assignments
  - Recent announcements
- [ ] Role management (Owner/Teacher/Student/Collaborator)
- [ ] Invite system
  - Email invites
  - Share codes
  - Link generation
- [ ] Classroom settings and privacy controls

#### 3.2 Content Sharing

- [ ] Live quiz mode (Kahoot-style)
  - Session creation with code
  - Real-time synchronization
  - Live leaderboard
  - Question timer
  - Host controls (pause, skip, end)
- [ ] Async quiz sharing (Google Forms-style)
  - Generate shareable links
  - Embed code for websites
  - Response collection
  - Results viewing
- [ ] Access control
  - Public/Private toggles
  - Password protection
  - Specific user access
  - Expiry dates

#### 3.3 Collaborative Creation

- [ ] Multi-user quiz creation
  - Invite collaborators to quiz
  - Assign questions to different users
  - Real-time collaboration indicators
  - Comment system on questions
  - Change history/version control
- [ ] Peer review system
  - Request review workflow
  - Feedback collection
  - Revision suggestions
  - Approval process

### Phase 4: Course Platform

**Priority: Medium**

#### 4.1 Course Discovery

- [ ] Course catalog/marketplace
  - Browse interface with filters
  - Search functionality
  - Category organization
  - Featured courses section
- [ ] Course preview
  - Free trial chapters
  - Course overview video
  - Instructor profile
  - Student reviews
- [ ] Wishlist functionality

#### 4.2 Course Creation (Educators)

- [ ] Course builder interface
  - Create course structure (modules/chapters)
  - Add content (videos, documents, quizzes)
  - Set pricing (free/paid)
  - Upload cover image and promotional materials
- [ ] Content management
  - Drag-and-drop organization
  - Bulk upload tools
  - Preview mode
  - Draft/publish states
- [ ] Course analytics
  - Enrollment numbers
  - Completion rates
  - Student performance
  - Revenue tracking (for paid courses)

#### 4.3 Course Consumption

- [ ] My courses library
  - Enrolled courses display
  - Continue learning quick access
  - Progress indicators
  - Completion certificates
- [ ] Course player
  - Video player with controls
  - Document viewer
  - Quiz integration
  - Note-taking during lessons
- [ ] Progress tracking
  - Chapter completion checkmarks
  - Overall course progress bar
  - Time spent per module
  - Bookmarking feature

#### 4.4 Payment Integration

- [ ] Payment gateway setup (Razorpay/Stripe)
- [ ] Shopping cart
- [ ] Checkout process
- [ ] Payment confirmation
- [ ] Invoice generation
- [ ] Refund handling

#### 4.5 Course Reviews & Ratings

- [ ] Rating system (1-5 stars)
- [ ] Written reviews
- [ ] Educator responses to reviews
- [ ] Review moderation
- [ ] Helpful/unhelpful voting on reviews

### Phase 5: Analytics & Insights

**Priority: Medium**

#### 5.1 User Analytics

- [ ] Learning hours dashboard
  - Total hours tracked
  - Daily/weekly/monthly breakdown
  - Hours by subject/category
  - Comparison charts (this week vs last week)
- [ ] Study streak tracking
  - Current streak counter
  - Longest streak record
  - Streak recovery grace period
  - Streak notifications
- [ ] Activity timeline
  - Daily activity log
  - Quiz attempts history
  - Courses progress
  - Achievements unlocked

#### 5.2 Performance Analytics

- [ ] Quiz performance metrics
  - Average scores by category
  - Improvement over time graphs
  - Strengths and weaknesses analysis
  - Recommended focus areas
- [ ] Question-level insights
  - Most difficult questions
  - Most commonly missed
  - Time spent per question type
- [ ] Comparative analytics
  - Compare with class average
  - Percentile ranking
  - Peer comparison (opt-in)

#### 5.3 Classroom Analytics (Educators)

- [ ] Student performance dashboard
  - Individual student progress
  - Class average scores
  - At-risk student identification
  - Top performers recognition
- [ ] Engagement metrics
  - Active vs inactive students
  - Assignment submission rates
  - Participation in discussions
  - Login frequency
- [ ] Content analytics
  - Most popular quizzes
  - Average completion time
  - Content difficulty analysis
  - Student feedback on content

#### 5.4 Leaderboard System

- [ ] Quiz-specific leaderboards
  - Top 10/50/100 scores
  - User's rank display
  - Time-based filtering (all-time, monthly, weekly)
- [ ] Classroom leaderboards
  - Student rankings within classroom
  - Points-based or score-based
  - Teacher's choice of criteria
- [ ] Global leaderboards
  - Platform-wide rankings
  - Category-specific leaders
  - Weekly/monthly champions

### Phase 6: AI Integration

**Priority: Medium-Low**

#### 6.1 AI Quiz Generation

- [ ] AI model integration (OpenAI/Gemini)
- [ ] Quiz generation interface
  - Topic input
  - Difficulty selection
  - Number of questions
  - Question type preferences
- [ ] Generated quiz review/editing
- [ ] Bulk generation for educators
- [ ] Context-aware question generation (from uploaded content)

#### 6.2 AI Flashcard Generation

- [ ] Document upload (PDF, DOCX, TXT)
- [ ] AI processing to extract key concepts
- [ ] Flashcard generation with Q&A pairs
- [ ] User review and customization
- [ ] Auto-categorization

#### 6.3 RAG (Retrieval Augmented Generation)

- [ ] Document/content upload for RAG database
- [ ] Chat interface with AI assistant
- [ ] Context-aware responses
- [ ] Generate practice questions from uploaded content
- [ ] Summarization feature
- [ ] Explain complex concepts
- [ ] Quiz yourself on uploaded materials

#### 6.4 Smart Recommendations

- [ ] AI-powered quiz recommendations
  - Based on learning history
  - Difficulty matching
  - Knowledge gaps identification
- [ ] Course recommendations
  - Personalized learning paths
  - Skill-based suggestions
- [ ] Study schedule optimization
  - Best times to study
  - Content spacing for retention

### Phase 7: Gamification

**Priority: Medium-Low**

#### 7.1 Points System

- [ ] Points awarded for:
  - Completing quizzes
  - Creating content
  - Daily login
  - Helping others (peer review)
  - Achieving milestones
- [ ] Points leaderboard
- [ ] Redeem points (for premium features, badges, profile customization)

#### 7.2 Badges & Achievements

- [ ] Achievement system
  - First quiz completed
  - 10/50/100 quizzes completed
  - Perfect score badge
  - Quiz creator (1/10/50 quizzes created)
  - Helping hand (peer reviews)
  - Subject mastery badges
- [ ] Badge display on profile
- [ ] Rare/limited edition badges
- [ ] Seasonal/event badges

#### 7.3 Streaks

- [ ] Login streak tracking
- [ ] Study streak (complete at least 1 quiz daily)
- [ ] Streak recovery (1 grace day per week)
- [ ] Streak milestones (7 days, 30 days, 100 days)
- [ ] Streak leaderboard
- [ ] Streak freeze (Premium feature - save streak for 1 day)

#### 7.4 Challenges

- [ ] Daily challenge quiz
- [ ] Weekly topic challenge
- [ ] Community-created challenges
- [ ] Challenge rewards (badges, points)
- [ ] Challenge leaderboards
- [ ] Challenge notifications

### Phase 8: Communication

**Priority: Low-Medium**

#### 8.1 Messaging System

- [ ] Direct messaging (DM) between users
  - Text messages
  - Emoji support
  - File/image sharing
  - Message search
  - Read receipts
  - Typing indicators
- [ ] Group chats
  - Classroom group chats
  - Study group chats
  - Group admins
  - Mute notifications option

#### 8.2 Educator-Student Communication

- [ ] Educator can message individual students
- [ ] Broadcast messages to all students in classroom
- [ ] Office hours scheduling
  - Set availability
  - Book appointment slots
  - Calendar integration
- [ ] Feedback on assignments
  - Private comments
  - Grading with notes

#### 8.3 Announcements

- [ ] Create classroom announcements
  - Rich text editor
  - Attach files/links
  - Schedule announcements
- [ ] Pin important announcements
- [ ] Announcement notifications
  - Push notifications
  - Email notifications (opt-in)
- [ ] Comment on announcements (optional)

#### 8.4 Discussion Forums

- [ ] Classroom discussion boards
- [ ] Topic/thread creation
- [ ] Upvote/downvote posts
- [ ] Mark answer as correct (educator)
- [ ] Moderation tools
- [ ] Notifications for replies

### Phase 9: Premium Features

**Priority: Low** (See Section 10 for details)

#### 9.1 Quiz Duels

- [ ] Create duel (2-4 players)
- [ ] Invite friends to duel
- [ ] Matchmaking system (find random opponents)
- [ ] Real-time gameplay
- [ ] Live scoring and leaderboard
- [ ] Winner announcement
- [ ] Rewards system

#### 9.2 Premium Perks

- [ ] Ad-free experience
- [ ] Advanced analytics
- [ ] Unlimited storage for courses
- [ ] Priority support
- [ ] Exclusive badges
- [ ] Streak freeze capability
- [ ] Early access to new features

### Phase 10: Admin & Moderation

**Priority: Low**

#### 10.1 Admin Panel (Educators)

- [ ] Dashboard overview
  - Active courses
  - Total students
  - Recent activity
  - Revenue (if applicable)
- [ ] Classroom management
  - View all classrooms
  - Edit settings
  - Bulk actions (archive, delete)
- [ ] User management
  - View classroom members
  - Remove/ban users
  - Change user roles
- [ ] Content moderation
  - Review flagged content
  - Approve/reject user-generated content
  - Delete inappropriate content

#### 10.2 Reporting System

- [ ] Report inappropriate content
- [ ] Report users
- [ ] Admin review queue
- [ ] Automated content filtering (profanity)
- [ ] User warning system
- [ ] Ban/suspend users

### Phase 11: Additional Enhancements

**Priority: Low**

#### 11.1 Accessibility

- [ ] Screen reader support
- [ ] High contrast mode
- [ ] Font size adjustments
- [ ] Keyboard navigation
- [ ] Closed captions for videos

#### 11.2 Internationalization

- [ ] Multi-language support for UI
- [ ] Language-specific content
- [ ] RTL (right-to-left) language support

#### 11.3 Offline Mode

- [ ] Download quizzes for offline use
- [ ] Offline quiz taking
- [ ] Sync when back online
- [ ] Download course content

#### 11.4 Export/Import

- [ ] Export quiz to PDF/DOCX
- [ ] Import quiz from CSV/JSON
- [ ] Bulk quiz upload
- [ ] Export results to Excel

#### 11.5 Integrations

- [ ] Google Classroom integration
- [ ] Microsoft Teams integration
- [ ] Zoom integration for live sessions
- [ ] Calendar apps (Google Calendar, Outlook)
- [ ] Learning Management Systems (Canvas, Moodle)

---

## 7. Technical Architecture

### 7.1 Frontend Architecture (Flutter)

#### Project Structure

```
quiz_app/
├── lib/
│   ├── main.dart                     # Entry point
│   ├── CreateSection/                # Quiz creation features
│   │   ├── models/                   # Quiz & Question models
│   │   ├── screens/                  # Quiz creation UI
│   │   ├── services/                 # Quiz API & cache
│   │   ├── widgets/                  # Reusable components
│   ├── LibrarySection/               # Quiz library features
│   │   ├── screens/                  # Library UI
│   │   ├── services/                 # Library API
│   │   ├── widgets/                  # Library components
│   ├── ProfilePage/                  # User profile
│   ├── ProfileSetup/                 # Onboarding flow
│   │   ├── screens/                  # Setup screens
│   │   ├── widgets/                  # Setup components
│   ├── models/                       # Shared models
│   │   └── user_model.dart
│   ├── screens/                      # Main screens
│   │   ├── dashboard.dart
│   │   ├── login_page.dart
│   ├── utils/                        # Utilities
│   │   ├── animations/               # Page transitions
│   │   ├── color.dart                # Color constants
│   │   ├── routes.dart               # Route definitions
│   ├── widgets/                      # Global widgets
│   │   ├── navbar/                   # Bottom navigation
│   │   ├── appbar/                   # Custom app bar
├── assets/                           # Images, icons
├── android/                          # Android config
├── ios/                             # iOS config
└── pubspec.yaml                      # Dependencies
```

#### Key Dependencies

- `firebase_core`: Firebase initialization
- `firebase_auth`: User authentication
- `cloud_firestore`: User profile storage
- `shared_preferences`: Local data persistence
- `http`: HTTP client for API calls

#### State Management

- Currently using `StatefulWidget` with `setState`
- **Recommended for scaling**: Provider, Riverpod, or Bloc pattern

### 7.2 Backend Architecture (FastAPI)

#### Project Structure

```
backend/
├── main.py                           # FastAPI app with 31 endpoints
├── requirements.txt                  # Python dependencies
├── .env                             # Environment variables (MongoDB URL)
├── .env.example                     # Template for env vars
├── test_api_automated.py            # Automated API tests
├── QuizApp_Automated_Tests.postman_collection.json
└── run_tests.bat                    # Test runner script
```

#### Core Dependencies

- `fastapi`: Web framework
- `uvicorn`: ASGI server
- `motor`: Async MongoDB driver
- `pydantic`: Data validation
- `python-dotenv`: Environment variable management

#### API Architecture

- RESTful design (Level 2 Richardson Maturity Model)
- Async/await for non-blocking I/O
- JSON request/response format
- CORS enabled for all origins
- Error handling with HTTP status codes

### 7.3 Database Architecture

#### MongoDB Collections

**quizzes** (MongoDB Atlas)

```javascript
{
  _id: ObjectId,
  title: String,
  description: String,
  language: String,
  category: String,
  coverImagePath: String,
  createdAt: String,           // "Month, Year" format
  questions: [
    {
      id: String,
      questionText: String,
      type: String,              // "singleMcq", "multiMcq", "trueFalse", "dragAndDrop"
      options: [String],
      correctAnswerIndex: Number,
      correctAnswerIndices: [Number],
      dragItems: [String],
      dropTargets: [String],
      correctMatches: Object
    }
  ]
}
```

**quiz_attempts** (MongoDB Atlas)

```javascript
{
  _id: ObjectId,
  quizId: ObjectId,
  userId: String,
  score: Number,
  totalQuestions: Number,
  percentage: Number,
  timeSpent: Number,            // seconds
  attemptedAt: ISODate,
  answers: [
    {
      questionId: String,
      selectedAnswer: Mixed,
      isCorrect: Boolean,
      timeSpent: Number
    }
  ]
}
```

**quiz_reviews** (MongoDB Atlas)

```javascript
{
  _id: ObjectId,
  quizId: ObjectId,
  userId: String,
  userName: String,
  rating: Number,               // 1-5 stars
  review: String,
  createdAt: ISODate
}
```

**quiz_results** (MongoDB Atlas)

```javascript
{
  _id: ObjectId,
  quizId: ObjectId,
  userId: String,
  score: Number,
  percentage: Number,
  submittedAt: ISODate
}
```

**users** (Cloud Firestore)

```javascript
{
  uid: String,                  // Firebase UID
  name: String,
  role: String,                 // "Student", "Educator", "Professional"
  age: Number,
  dateOfBirth: String,
  subjectArea: String,
  experienceLevel: String,
  interests: [String],
  photoUrl: String,
  createdAt: Timestamp,
  profileSetupCompleted: Boolean
}
```

**Future Collections** (To be implemented)

- `classrooms`: Classroom data
- `classroom_members`: User-classroom relationships
- `courses`: Course catalog
- `course_enrollments`: User course access
- `flashcards`: Flashcard decks
- `polls`: Poll data
- `surveys`: Survey data
- `messages`: Chat messages
- `announcements`: Classroom announcements
- `achievements`: User badges and achievements
- `learning_analytics`: Detailed learning statistics

---

## 8. Database Schema

### 8.1 Existing Collections (Detailed)

#### quizzes Collection

```javascript
{
  _id: ObjectId("507f1f77bcf86cd799439011"),
  title: "JavaScript Fundamentals",
  description: "Test your knowledge of JavaScript basics",
  language: "English",
  category: "Programming",
  coverImagePath: "https://example.com/cover.jpg",
  createdAt: "October, 2025",
  createdBy: "user123",                // Future: link to user UID
  questions: [
    {
      id: "q1",
      questionText: "What is a closure?",
      type: "singleMcq",
      options: [
        "A function inside another function",
        "A loop",
        "A variable",
        "An object"
      ],
      correctAnswerIndex: 0
    },
    {
      id: "q2",
      questionText: "Which are valid data types?",
      type: "multiMcq",
      options: ["String", "Number", "Boolean", "Character"],
      correctAnswerIndices: [0, 1, 2]
    }
  ],
  stats: {                             // Future: aggregated stats
    totalAttempts: 150,
    averageScore: 78.5,
    averageRating: 4.2
  }
}
```

#### quiz_attempts Collection

```javascript
{
  _id: ObjectId("507f1f77bcf86cd799439012"),
  quizId: ObjectId("507f1f77bcf86cd799439011"),
  userId: "firebase_uid_123",
  userName: "John Doe",
  score: 8,
  totalQuestions: 10,
  percentage: 80.0,
  timeSpent: 180,                      // 3 minutes
  attemptedAt: ISODate("2025-10-16T10:30:00Z"),
  answers: [
    {
      questionId: "q1",
      selectedAnswer: 0,
      isCorrect: true,
      timeSpent: 15
    },
    {
      questionId: "q2",
      selectedAnswer: [0, 1],
      isCorrect: false,
      timeSpent: 25
    }
  ]
}
```

### 8.2 Planned Collections

#### classrooms Collection

```javascript
{
  _id: ObjectId,
  name: String,
  description: String,
  subject: String,
  ownerId: String,                     // Firebase UID
  code: String,                        // Unique 6-digit code
  privacy: String,                     // "public", "private", "invite-only"
  createdAt: ISODate,
  settings: {
    allowStudentPosts: Boolean,
    requireApproval: Boolean,
    enableChat: Boolean
  },
  stats: {
    memberCount: Number,
    contentCount: Number
  }
}
```

#### classroom_members Collection

```javascript
{
  _id: ObjectId,
  classroomId: ObjectId,
  userId: String,                      // Firebase UID
  role: String,                        // "owner", "teacher", "student", "collaborator"
  joinedAt: ISODate,
  isActive: Boolean
}
```

#### courses Collection

```javascript
{
  _id: ObjectId,
  title: String,
  description: String,
  instructorId: String,
  category: String,
  difficulty: String,                  // "Beginner", "Intermediate", "Advanced"
  price: Number,
  coverImage: String,
  previewVideo: String,
  modules: [
    {
      id: String,
      title: String,
      order: Number,
      chapters: [
        {
          id: String,
          title: String,
          type: String,                // "video", "document", "quiz"
          contentUrl: String,
          duration: Number,            // minutes
          isFree: Boolean
        }
      ]
    }
  ],
  createdAt: ISODate,
  updatedAt: ISODate,
  stats: {
    enrollments: Number,
    rating: Number,
    reviews: Number,
    completionRate: Number
  }
}
```

#### course_enrollments Collection

```javascript
{
  _id: ObjectId,
  courseId: ObjectId,
  userId: String,
  enrolledAt: ISODate,
  progress: {
    completedChapters: [String],       // Array of chapter IDs
    currentChapter: String,
    percentComplete: Number,
    lastAccessedAt: ISODate
  },
  certificate: {
    issued: Boolean,
    issuedAt: ISODate,
    certificateUrl: String
  }
}
```

#### flashcards Collection

```javascript
{
  _id: ObjectId,
  deckName: String,
  description: String,
  category: String,
  createdBy: String,
  cards: [
    {
      id: String,
      front: String,
      back: String,
      imageUrl: String                 // Optional
    }
  ],
  createdAt: ISODate,
  stats: {
    totalCards: Number,
    timesStudied: Number
  }
}
```

#### user_progress Collection

```javascript
{
  _id: ObjectId,
  userId: String,
  learningHours: {
    total: Number,
    byWeek: [
      { week: String, hours: Number }
    ],
    byCategory: {
      "Math": 10.5,
      "Science": 8.2
    }
  },
  streaks: {
    current: Number,
    longest: Number,
    lastActivity: ISODate
  },
  achievements: [
    {
      badgeId: String,
      earnedAt: ISODate
    }
  ],
  points: Number
}
```

#### messages Collection

```javascript
{
  _id: ObjectId,
  conversationId: String,              // Hash of sorted user IDs
  senderId: String,
  receiverId: String,                  // For DMs, null for group
  groupId: ObjectId,                   // For group chats
  content: String,
  attachments: [
    {
      type: String,                    // "image", "file"
      url: String,
      name: String
    }
  ],
  sentAt: ISODate,
  readAt: ISODate,
  isEdited: Boolean,
  isDeleted: Boolean
}
```

#### announcements Collection

```javascript
{
  _id: ObjectId,
  classroomId: ObjectId,
  authorId: String,
  title: String,
  content: String,
  attachments: [String],               // URLs
  isPinned: Boolean,
  createdAt: ISODate,
  updatedAt: ISODate,
  comments: [
    {
      userId: String,
      userName: String,
      comment: String,
      createdAt: ISODate
    }
  ]
}
```

---

## 9. API Endpoints

### 9.1 Existing Endpoints (31 Total)

#### Health & Info

- `GET /` - API health check

#### Quiz CRUD

- `POST /quizzes` - Create new quiz (validates non-empty fields)
- `GET /quizzes/library` - Get all quizzes
- `GET /quizzes/{quiz_id}` - Get specific quiz
- `PUT /quizzes/{quiz_id}` - Update entire quiz
- `PATCH /quizzes/{quiz_id}` - Partial quiz update
- `DELETE /quizzes/{quiz_id}` - Delete quiz

#### Search & Filter

- `GET /quizzes/search?q=` - Text search
- `GET /quizzes/category/{category}` - Filter by category
- `GET /quizzes/language/{language}` - Filter by language

#### Statistics & Attempts

- `GET /quizzes/{quiz_id}/stats` - Quiz statistics
- `POST /quizzes/{quiz_id}/attempt` - Submit quiz attempt
- `GET /quizzes/top-rated` - Get highest-rated quizzes

#### User Management

- `POST /users` - Create user
- `GET /users/{user_id}` - Get user details
- `PUT /users/{user_id}` - Update user
- `DELETE /users/{user_id}` - Delete user
- `GET /users/{user_id}/quizzes` - Get user's quizzes

#### Reviews & Ratings

- `POST /quizzes/{quiz_id}/reviews` - Add review
- `GET /quizzes/{quiz_id}/reviews` - Get reviews

#### Results & Leaderboard

- `POST /results` - Submit quiz result
- `GET /results/{quiz_id}` - Get quiz results
- `GET /leaderboard/{quiz_id}` - Get leaderboard (top 10)

#### Metadata

- `GET /categories` - Get all categories with counts
- `GET /languages` - Get all languages with counts
- `GET /tags` - Get all tags
- `POST /tags` - Create new tag

#### Dashboard

- `GET /dashboard/stats` - Overall platform statistics

### 9.2 Planned Endpoints

#### Authentication (Firebase handles auth, but for backend sync)

- `POST /api/auth/sync` - Sync Firebase user to backend
- `POST /api/auth/logout` - Clean up sessions

#### Classroom Management

- `POST /api/classrooms` - Create classroom
- `GET /api/classrooms` - Get user's classrooms
- `GET /api/classrooms/{id}` - Get classroom details
- `PUT /api/classrooms/{id}` - Update classroom
- `DELETE /api/classrooms/{id}` - Delete classroom
- `POST /api/classrooms/{id}/join` - Join classroom with code
- `POST /api/classrooms/{id}/leave` - Leave classroom
- `GET /api/classrooms/{id}/members` - Get members list
- `POST /api/classrooms/{id}/invite` - Send invitation
- `PUT /api/classrooms/{id}/members/{user_id}` - Update member role
- `DELETE /api/classrooms/{id}/members/{user_id}` - Remove member

#### Course Management

- `POST /api/courses` - Create course
- `GET /api/courses` - Browse courses (with filters)
- `GET /api/courses/{id}` - Get course details
- `PUT /api/courses/{id}` - Update course
- `DELETE /api/courses/{id}` - Delete course
- `POST /api/courses/{id}/enroll` - Enroll in course
- `GET /api/courses/{id}/modules` - Get course structure
- `POST /api/courses/{id}/modules` - Add module
- `PUT /api/courses/{id}/modules/{module_id}` - Update module
- `POST /api/courses/{id}/reviews` - Add course review
- `GET /api/users/me/courses` - Get enrolled courses
- `PUT /api/enrollments/{id}/progress` - Update course progress

#### Flashcards

- `POST /api/flashcards` - Create flashcard deck
- `GET /api/flashcards` - Get user's decks
- `GET /api/flashcards/{id}` - Get specific deck
- `PUT /api/flashcards/{id}` - Update deck
- `DELETE /api/flashcards/{id}` - Delete deck
- `POST /api/flashcards/{id}/study` - Record study session

#### Polls & Surveys

- `POST /api/polls` - Create poll
- `GET /api/polls/{id}` - Get poll
- `POST /api/polls/{id}/vote` - Submit vote
- `GET /api/polls/{id}/results` - Get poll results
- `POST /api/surveys` - Create survey
- `GET /api/surveys/{id}` - Get survey
- `POST /api/surveys/{id}/submit` - Submit survey response
- `GET /api/surveys/{id}/responses` - Get survey responses

#### Analytics

- `GET /api/users/me/analytics` - Get user's learning analytics
- `GET /api/users/me/streaks` - Get streak data
- `GET /api/classrooms/{id}/analytics` - Get classroom analytics
- `GET /api/courses/{id}/analytics` - Get course analytics (educator)

#### Messaging

- `POST /api/messages` - Send message
- `GET /api/messages/conversations` - Get user's conversations
- `GET /api/messages/{conversation_id}` - Get messages in conversation
- `PUT /api/messages/{id}/read` - Mark as read
- `DELETE /api/messages/{id}` - Delete message

#### Announcements

- `POST /api/classrooms/{id}/announcements` - Create announcement
- `GET /api/classrooms/{id}/announcements` - Get announcements
- `PUT /api/announcements/{id}` - Update announcement
- `DELETE /api/announcements/{id}` - Delete announcement
- `POST /api/announcements/{id}/comments` - Add comment

#### Gamification

- `GET /api/users/me/achievements` - Get user achievements
- `GET /api/users/me/points` - Get points balance
- `POST /api/achievements/{id}/claim` - Claim achievement reward

#### AI Features

- `POST /api/ai/generate-quiz` - Generate quiz with AI
- `POST /api/ai/generate-flashcards` - Generate flashcards
- `POST /api/ai/ask` - Ask AI assistant (RAG)
- `POST /api/ai/upload-context` - Upload document for RAG

#### Premium (Quiz Duels)

- `POST /api/duels` - Create duel
- `GET /api/duels/{id}` - Get duel details
- `POST /api/duels/{id}/join` - Join duel
- `POST /api/duels/{id}/submit` - Submit duel answers
- `GET /api/duels/{id}/results` - Get duel results

#### Admin/Moderation

- `GET /api/admin/reports` - Get reported content
- `POST /api/reports` - Report content/user
- `PUT /api/admin/reports/{id}` - Resolve report
- `POST /api/admin/users/{id}/ban` - Ban user
- `DELETE /api/admin/content/{id}` - Delete content

---

## 10. Premium Features

### 10.1 Quiz Duels (Flagship Premium Feature)

#### Description

Real-time competitive quiz battles between 2-4 players simultaneously. Think "quiz showdown" where players compete head-to-head answering the same questions at the same time.

#### Features

- **Player Count**: 2-4 simultaneous players
- **Game Modes**:
  - Quick Match (find random opponents)
  - Private Duel (invite friends)
  - Tournament Mode (bracket-style, future)
- **Gameplay**:
  - All players see same question at same time
  - Timed responses (10-30 seconds per question)
  - Points awarded for correct answers + speed bonus
  - Live leaderboard updates after each question
  - Power-ups (future): Skip, 50-50, Extra time
- **Results**:
  - Winner announcement with animation
  - Detailed score breakdown
  - XP and points rewards
  - Win/loss record tracking
- **Matchmaking**:
  - Skill-based matching (ELO rating system)
  - Topic/category preferences
  - Friend challenges
- **Social Features**:
  - Chat during game (optional)
  - Rematch option
  - Share results
  - Friend leaderboards

### 10.2 Other Premium Perks

#### Ad-Free Experience

- Remove all advertisements from the app
- Cleaner, distraction-free interface

#### Advanced Analytics

- Deeper insights into learning patterns
- Detailed performance breakdowns by topic
- Comparative analytics (vs peers)
- Exportable reports (PDF)
- Custom date range filtering

#### Storage Benefits

- Unlimited quiz creation
- Unlimited flashcard decks
- Unlimited course enrollments
- Larger file upload limits (images, documents)

#### Priority Features

- Priority customer support (24-hour response)
- Early access to new features (beta testing)
- Priority in matchmaking queues
- Featured profile badge

#### Exclusive Content

- Access to premium quiz library
- Premium course discounts
- Exclusive badges and profile themes
- Custom profile customization options

#### Streak Protection

- Streak Freeze: Save your streak for 1 day per week
- Automatic streak recovery once per month

#### Collaboration Benefits

- Unlimited collaborators per quiz/course
- Advanced collaboration tools (version control, comments)
- Team workspaces

### 10.3 Pricing Model (Proposed)

#### Free Tier

- Basic quiz creation (up to 50 quizzes)
- Join unlimited classrooms
- Access free courses
- Basic analytics
- Ads supported

#### Premium Individual ($4.99/month or $49.99/year)

- All free features
- Unlimited quiz creation
- Quiz Duels access
- Ad-free experience
- Advanced analytics
- Priority support
- Exclusive badges
- Streak protection

#### Premium Educator ($9.99/month or $99.99/year)

- All Premium Individual features
- Create unlimited courses
- Advanced classroom analytics
- Bulk operations
- Course monetization (70% revenue share)
- Educator-only community access
- Dedicated account manager (annual plan)

#### Enterprise (Custom Pricing)

- All Premium Educator features
- White-label option
- Custom integrations
- SSO (Single Sign-On)
- SLA guarantees
- Dedicated infrastructure
- Custom feature development

---

## 11. Non-Functional Requirements

### 11.1 Performance

- App launch time: < 2 seconds
- API response time: < 500ms for 95% of requests
- Quiz loading: < 1 second
- Support 1000+ concurrent users
- Image loading: Progressive loading with placeholders

### 11.2 Security

- ✅ Firebase Authentication with email verification
- ✅ HTTPS for all API communications
- ✅ Environment variables for secrets (.env files)
- ✅ MongoDB credentials stored securely
- Input validation and sanitization
- Rate limiting on API endpoints
- Password hashing (handled by Firebase)
- Session token expiration
- CORS configuration
- XSS and SQL injection protection

### 11.3 Scalability

- Horizontal scaling capability for backend
- Database indexing for fast queries
- CDN for static assets
- Caching strategy (Redis for future)
- Load balancing for high traffic

### 11.4 Reliability

- 99.9% uptime target
- Automated backups (MongoDB Atlas)
- Error logging and monitoring
- Graceful degradation
- Offline functionality (cache quizzes)

### 11.5 Usability

- Intuitive UI/UX
- Consistent design language
- Accessibility compliance (WCAG 2.1 Level AA)
- Multi-language support (future)
- Responsive design (mobile-first)
- Onboarding tutorial for new users

### 11.6 Maintainability

- ✅ Modular code structure
- ✅ Comprehensive API documentation
- ✅ Automated testing (backend API tests)
- Version control (Git)
- Code comments and documentation
- CI/CD pipeline (future)

---

## 12. Constraints & Assumptions

### 12.1 Technical Constraints

- Flutter framework for mobile development
- FastAPI for backend (Python 3.8+)
- MongoDB for primary data storage
- Firebase for authentication and user profiles
- Internet connection required for most features

### 12.2 Business Constraints

- Free tier with ads to support development
- Premium features for monetization
- Course marketplace with revenue sharing model

### 12.3 Assumptions

- Users have smartphones (Android/iOS)
- Stable internet connection (4G/WiFi)
- Users willing to create accounts
- Educators interested in digital tools
- Market demand for quiz-based learning

---

## 13. Success Metrics (KPIs)

### 13.1 User Engagement

- Daily Active Users (DAU)
- Monthly Active Users (MAU)
- Average session duration
- Quiz completion rate
- User retention (7-day, 30-day)

### 13.2 Content Metrics

- Total quizzes created
- Total quiz attempts
- Average quizzes per user
- Content sharing rate
- Collaboration rate

### 13.3 Educational Impact

- Average quiz scores over time
- Learning hours tracked
- Course completion rates
- Student satisfaction ratings

### 13.4 Business Metrics

- Free to Premium conversion rate
- Monthly Recurring Revenue (MRR)
- Customer Acquisition Cost (CAC)
- Lifetime Value (LTV)
- Churn rate

---

## 14. Future Considerations

### 14.1 Advanced Features (Beyond Roadmap)

- AR/VR learning experiences
- Live video lectures integration
- Blockchain-based certificates
- AI-powered adaptive learning paths
- Voice-based quizzes
- Multiplayer learning games

### 14.2 Platform Expansion

- Web application (React/Next.js)
- Desktop applications (Windows, macOS)
- Smart TV app
- Browser extensions
- API for third-party integrations

### 14.3 Content Partnerships

- Partner with educational institutions
- Certified course programs
- Corporate training partnerships
- Government education initiatives

---

## 15. Appendices

### Appendix A: Glossary

- **Quiz**: Set of questions with correct answers
- **Flashcard**: Card with question on front, answer on back
- **Classroom**: Virtual space for group learning
- **Duel**: Competitive quiz between 2-4 players
- **RAG**: Retrieval Augmented Generation (AI with context)
- **MCQ**: Multiple Choice Question
- **Streak**: Consecutive days of activity
- **Badge**: Achievement reward icon

### Appendix B: References

- Firebase Documentation: https://firebase.google.com/docs
- FastAPI Documentation: https://fastapi.tiangolo.com
- MongoDB Documentation: https://docs.mongodb.com
- Flutter Documentation: https://flutter.dev/docs

### Appendix C: Change Log

| Version | Date | Changes |
|---------|------|---------|
| 1.0 | October 16, 2025 | Initial SRS document created |
| 2.0 | November 29, 2025 | Major update with implementation status, feature roadmap, and technical architecture |
| 2.1 | November 30, 2025 | Updated implementation status: Authentication 70%, Quiz System 85%, Content Tools 90%, AI Features 75%, Library 60%. Added session recovery, WebSocket reconnection handling, Riverpod 3.x state management, Redis session storage, and comprehensive live multiplayer features. Updated backend from 31 to 50+ endpoints across 15 route modules. |

---

**Document End**

_This SRS is a living document and will be updated as the project evolves._
