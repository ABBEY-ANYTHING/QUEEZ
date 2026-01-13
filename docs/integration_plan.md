 # Integration Plan — Next Major Features

 Date: 2025-12-02

 Purpose
 - Propose two large, high-impact features that can be owned by two separate people on the team. Each feature contains scope, user stories, UI surface, backend/API & data requirements, dependencies, risk, testing, and suggested implementation milestones.

 Context / current state (short)
 - The project already has a working Create section (quizzes, flashcards, notes), AI generation for study sets, a library, profile/onboarding, and a near-complete live multiplayer system. The SRS (`SRS_DOCUMENT.md`) documents planned endpoints and data models (quizzes, quiz_attempts, study_sets, users, etc.).
 - Several high-level systems are still missing or partial (classrooms, messaging/announcements, collaborative editing, course marketplace, premium/payment flows).

 Feature 1 — Classroom & Classroom Management (Owner: Person A)
 -------------------------------------------------------------
 Goal / summary
 - Provide a robust Classroom experience enabling educators to create/manage classrooms, invite students, share content (quizzes, study sets, courses), post announcements, assign work, and view classroom analytics.

 Why this is high-impact
 - Enables teacher/learner workflows and unlocks core product-market fit for educators and institutions.
 - Provides the scaffolding required for course management, messaging, assignments, and analytics.

 Major user stories
 - As an educator, I can create a classroom with a name, subject, privacy, and invite code.
 - As an educator, I can invite/remove students and assign roles (owner, teacher, student, collaborator).
 - As a student, I can join a classroom using code or invite link and view classroom content.
 - As an educator, I can post announcements and pinned resources to the classroom.
 - As an educator, I can assign quizzes or study sets to classroom members and track completion.
 - As an educator, I can view aggregated analytics for the classroom (participation, average scores, activity).

 UI / screens (frontend)
 - Classroom list (owner/teacher memberships) — card list with quick stats.
 - Create/Classroom setup flow — modal or page with settings (name, subject, privacy, code).
 - Classroom detail page — tabs: Overview (announcements & resources), Members (manage/invite), Assignments (create & track), Content (shared quizzes/study sets), Analytics.
 - Invite UI — generate shareable link and code, show pending invites.
 - Assignment/grade UI for educators and a My Assignments view for students.

 Backend / API (suggested endpoints)
 - POST /api/classrooms — create classroom (name, subject, privacy)
 - GET /api/classrooms — list classrooms for a user
 - GET /api/classrooms/{id} — classroom detail
 - PUT /api/classrooms/{id} — update classroom
 - DELETE /api/classrooms/{id} — remove classroom
 - POST /api/classrooms/{id}/join — join by code or link
 - POST /api/classrooms/{id}/invite — create invite / send email
 - GET /api/classrooms/{id}/members — list members
 - PUT /api/classrooms/{id}/members/{user_id} — change role/remove
 - POST /api/classrooms/{id}/announcements — create announcement
 - GET /api/classrooms/{id}/announcements
 - POST /api/classrooms/{id}/assignments — assign quiz/study set
 - GET /api/classrooms/{id}/assignments
 - GET /api/classrooms/{id}/analytics — aggregated metrics

 Data model changes / collections
 - classrooms collection: { id, name, subject, ownerId, privacy, code, createdAt, settings }
 - classroom_members: { classroomId, userId, role, joinedAt }
 - classroom_announcements: { classroomId, authorId, title, content, attachments, pinned, createdAt }
 - classroom_assignments: { classroomId, assignmentId (quiz/studyset), dueDate, assignedBy, createdAt }
 - assignment_submissions / results may reuse existing quiz_attempts/results collections with an assignment reference.

 Integration points
 - Reuse `users` in Firestore for profile info.
 - Reuse `quizzes`, `study_sets`, and `flashcards` collections to link assigned content.
 - Use WebSockets for real-time classroom presence (optional v1) and notifications.
 - Notifications: in-app notifications for invites/assignments; push notifications can be planned later.

 MVP scope (target)
 - Classroom creation & join by code
 - Member invites & role assignment (owner/teacher/student)
 - Post announcements & view timeline
 - Assign a quiz/study-set and track simple completion (submitted / not submitted)
 - Basic classroom analytics: number of members, active members in last 7 days, average assignment completion

 Suggested milestones & timeline (approx)
 - Week 1: DB schema + API endpoints + basic classroom create/get/list
 - Week 2: Member management + invite flow + join by code
 - Week 3: Announcements + classroom UI (detail page) + simple notifications (in-app)
 - Week 4: Assignments & basic analytics + dashboard view

 Acceptance criteria
 - Educator can create a classroom and share a code/link.
 - Student can join with the code and appear in members list.
 - Educator can post announcements and create assignments linked to existing quizzes/study-sets.
 - Assignment progress shows accurate completion counts in classroom analytics.

 Risks & considerations
 - Large-scale membership management and permission checks must be implemented server-side to prevent privilege escalation.
 - Notifications scaling (push/email) should be designed but can be postponed to v2.

 Testing & QA
 - Unit tests for endpoints and permission checks
 - Integration tests: create classroom -> invite -> join -> assign -> submit attempt
 - UI tests for flows (create, invite, assignment creation)

 Feature 2 — Collaborative Content Creation & Review Workflow (Owner: Person B)
 ------------------------------------------------------------------------
 Goal / summary
 - Enable multiple collaborators to co-author quizzes, flashcards, or study sets with a lightweight collaboration workflow: invite collaborators, assign sections, comment & review, and version history. Offer a simple real-time collaboration experience where feasible, or a robust async workflow as MVP.

 Why this is high-impact
 - Makes the platform attractive for teams, educators, and content creators.
 - Lowers friction for building rich content collaboratively and increases platform stickiness.

 Major user stories
 - As an author, I can invite collaborators to a quiz/study set with specific permissions (edit, comment, view).
 - As a collaborator, I can edit assigned sections or propose changes and add comments on questions/items.
 - As an author, I can accept/reject collaborator changes, and the system keeps a version history.
 - As a team, we can see change history and recover previous versions.
 - Optional (stretch): Co-edit simultaneously with presence indicators and live cursors.

 UI / screens (frontend)
 - Content collaborative header: owners/collaborators avatars, Invite button, Roles dropdown.
 - Side panel: Comments & suggestions per question/item, with ability to resolve/accept.
 - Revision history modal: list versions with timestamp + author + diff preview + restore.
 - Assignment workflow: Assign a section or question to a collaborator with due date.

 Backend / API (suggested endpoints)
 - POST /api/content/{type}/{id}/collaborators — add/remove collaborator and set role
 - GET /api/content/{type}/{id}/collaborators — list collaborators
 - POST /api/content/{type}/{id}/comments — add comment on an item
 - GET /api/content/{type}/{id}/comments
 - POST /api/content/{type}/{id}/versions — snapshot current version (or implicit on publish)
 - GET /api/content/{type}/{id}/versions
 - POST /api/content/{type}/{id}/versions/{versionId}/restore

 Data model changes / collections
 - content_collaborators: { contentType, contentId, userId, role }
 - content_comments: { contentType, contentId, itemId, authorId, text, status, createdAt }
 - content_versions: { contentType, contentId, versionId, snapshot, createdAt, authorId }

 Implementation approach & MVP choices
 - Option A (recommended MVP): Async collaboration with explicit save/publish + comments + version snapshots.
   - Simpler to implement and avoids complex CRDT/OT systems.
   - Editors lock per-section or per-question when a user is editing to prevent overwrite.
 - Option B (stretch): Real-time co-edit (CRDT/OT), presence indicators, live cursors.
   - Requires significantly more engineering (operational transform/CRDT library or WebSocket orchestration).
   - Recommend after Option A is live.

 Integration points
 - Reuse existing `quizzes`, `study_sets`, `flashcards` collections for snapshots and link references.
 - Use Firestore for presence and comments (or Mongo + WS) depending on chosen architecture.
 - Leverage existing auth/permissions; ensure server-side checks for collaborator roles.

 MVP scope (target)
 - Invite collaborators with roles (owner/editor/commenter)
 - Commenting per question/item plus resolve workflow
 - Version snapshots with ability to restore previous version
 - Basic UI for assigning items to collaborators (simple task list)

 Suggested milestones & timeline (approx)
 - Week 1: DB models + collaborator endpoints + collaborator UI header
 - Week 2: Comment UI + endpoints + resolve workflow
 - Week 3: Version snapshots + restore API + revision UI
 - Week 4: Assignment tasks & basic notifications (in-app)

 Acceptance criteria
 - Owner can add/remove collaborators and enforce role-based access to edit/comment.
 - Collaborator can comment and see comments on assigned items.
 - System stores versions and owner can restore a previous version.

 Risks & considerations
 - Concurrent edits may lead to loss of work if section-locking is not in place—careful UX is needed.
 - Choosing between Firestore vs Mongo for real-time features affects complexity.

 Testing & QA
 - Permission tests: ensure only allowed users can edit/publish/restore
 - Comment lifecycle tests (create, reply, resolve)
 - Versioning tests: create snapshot, modify, restore and verify data integrity

 Cross-feature integration notes
 - Both features should reuse existing collections (`users`, `quizzes`, `study_sets`, `flashcards`, `quiz_attempts`) and respect current authorization model (Firebase auth + server-side checks).
 - Classroom assignments (Feature 1) should reuse Collaborative creation permissions for team-based content ownership.

 Proposed owners & rollout
 - Person A: Classroom & Classroom Management (priority: high) — recommended first because it unlocks educator workflows and many downstream features.
 - Person B: Collaborative Creation & Review Workflow (priority: high) — recommended second; can be developed in parallel but depends on shared content models.

 Minimal dev checklist per owner (quick)
 - Define DB schema + migration plan
 - Implement server-side endpoints with permission checks
 - Create frontend UI skeletons and wire to APIs
 - Add unit & integration tests for API flows
 - Do UX testing for mobile (keyboard/overlap) and edge cases

 Notes & next steps
 - If you want, I can split either feature into a 6–8 week sprint backlog with individual tickets (frontend, backend, tests, docs) and produce a per-ticket acceptance criteria list.
 - I did not include exact code or queries (per request). If you pick which feature each person will own, I can expand that owner's backlog into task-level tickets.

 ---

 End of integration plan.
