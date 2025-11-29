# AI-Generated Study Set Feature - Planning Document

## Overview
This document outlines the complete plan for implementing an AI-powered Study Set creation feature using Gemini 2.5 Flash. The feature will allow users to upload documents and automatically generate comprehensive study materials including quizzes, flashcards, and notes.

---

## 1. User Flow Architecture

### 1.1 Study Set Creation Entry Point
When a user clicks the "Study Set" button on the Create page, instead of navigating directly to the manual creation dashboard, they will be taken to a new intermediate selection page.

### 1.2 Selection Page Design
This new page will present two distinct options:

**Option 1: Create Manually**
- Large, prominent button with icon (e.g., pencil/edit icon)
- Description: "Build your study set step by step"
- Visual indicator showing manual control

**Option 2: Create with AI**
- Large, prominent button with AI/sparkle icon
- Description: "Let AI generate study materials from your documents"
- Visual indicator showing AI automation
- Badge showing "Powered by Gemini 2.5 Flash"

The layout should be clean, centered, and make both options equally accessible. Each option should have a brief explanation of what it does to help users make an informed choice.

---

## 2. Manual Creation Flow (No Changes)

### 2.1 Existing Behavior Preservation
When the user selects "Create Manually," the app will navigate to the existing Study Set Dashboard that is already implemented. This flow requires zero modifications.

### 2.2 Navigation Pattern
The navigation should use the same slide-up animation (AnimationType.slideUp) that is currently used throughout the app for consistency.

---

## 3. AI-Powered Creation Flow

### 3.1 Document Upload Interface

**Upload Screen Layout:**
- Header: "Upload Study Materials"
- Subheader: "Upload up to 3 documents to generate your study set"
- Document slots: Three upload areas clearly numbered (1, 2, 3)
- Each slot shows:
  - Upload icon when empty
  - File name, size, and remove button when filled
  - Format requirements clearly visible

**Supported Formats:**
- PDF documents
- PowerPoint presentations (PPT, PPTX)
- Word documents (DOC, DOCX)
- Text files (TXT)

**File Size Validation:**
- Maximum 10 MB per document
- Show file size when selected
- Display clear error message if file exceeds limit
- Prevent upload button from being enabled until validation passes

**Upload Area Features:**
- Drag and drop support (if platform supports it)
- Click to browse file system
- Visual feedback when files are being selected
- Progress indicator during file selection
- Clear error states for invalid files

### 3.2 Study Set Configuration Form

After documents are uploaded, users must provide:

**Required Fields:**
- Study Set Name (text input, max 100 characters)
- Description (multiline text, max 500 characters)
- Category (dropdown matching existing categories)
- Language (dropdown matching existing languages)

**Optional Fields:**
- Cover Image (file upload, same as manual creation)

**Validation Rules:**
- All required fields must be filled
- At least one document must be uploaded
- Maximum three documents allowed
- Generate button only enabled when all validations pass

### 3.3 Generation Configuration

**AI Generation Settings:**
- Number of quizzes to generate (slider: 1-5, default: 2)
- Number of flashcard sets to generate (slider: 1-3, default: 2)
- Number of notes to generate (slider: 1-3, default: 1)
- Quiz difficulty level (dropdown: Easy, Medium, Hard, Mixed - default: Mixed)
- Questions per quiz (slider: 5-20, default: 10)
- Cards per flashcard set (slider: 10-50, default: 20)

Users should be able to customize how much content Gemini generates based on their needs.

---

## 4. Document Processing Strategy - Gemini File API

### 4.1 Architecture Overview

**Why Gemini File API:**
- Avoids massive base64-encoded payloads (which would bloat files by 33%)
- Prevents backend from handling large file transfers
- Eliminates request size limit issues on Render
- Uses Gemini's native file processing capabilities
- Files stored temporarily (48 hours) on Gemini's servers

**Security Model:**
- Master Gemini API key stored securely on backend (GEMINI_API_KEY environment variable)
- Backend generates temporary upload-only tokens for frontend
- Tokens are short-lived (5-10 minutes) and restricted to File API uploads only
- Frontend never has access to master API key

### 4.2 Frontend Upload Flow

**Step 1: Request Upload Token**
- Frontend calls backend endpoint: POST /get-upload-token
- Backend generates a temporary, restricted token using master API key
- Token is scoped to ONLY allow file uploads to Gemini File API
- Token expires after 5-10 minutes
- Backend returns: `{ uploadToken: "temp_token_xyz", expiresIn: 600 }`

**Step 2: File Selection and Validation**
- Use Flutter's file_picker package to select documents
- Validate file size (max 10MB per file)
- Validate file type (PDF, PPT, PPTX, DOC, DOCX, TXT)
- Maximum 3 files allowed
- Show validation errors immediately

**Step 3: Upload Files Directly to Gemini**
- Upload each file to Gemini File API using multipart/form-data
- Use the temporary upload token for authentication
- Gemini endpoint: `https://generativelanguage.googleapis.com/upload/v1beta/files`
- Include file metadata in request headers
- Track upload progress for each file

**Step 4: Receive File URIs**
- Gemini returns file URIs immediately: `gemini://file/abc123xyz`
- Store URIs in frontend state
- Files are now cached on Gemini's servers for 48 hours
- No file content stored locally or on backend

**Step 5: Send Generation Request**
- Frontend sends to backend: POST /generate-study-set
- Payload contains:
  - fileUris: Array of Gemini file URIs (lightweight, just strings)
  - studySetConfig: name, description, category, language, coverImagePath
  - generationSettings: quiz count, flashcard count, note count, difficulty, etc.
  - userId: Current user ID
- Total payload size: < 5KB (compared to 40MB+ with base64 approach)

### 4.3 Backend Processing Flow

**Endpoint 1: /get-upload-token**

**Purpose:** Generate temporary upload-only token for Gemini File API

**Process:**
1. Verify user authentication
2. Create restricted token using master GEMINI_API_KEY
3. Set token expiration (5-10 minutes)
4. Scope token to file upload operations only
5. Return token to frontend

**Security:**
- Token cannot be used for content generation
- Token expires quickly
- Token tied to authenticated user session
- Rate limit token requests per user

**Endpoint 2: /generate-study-set**

**Purpose:** Generate study set using uploaded file URIs

**Request Validation:**
1. Verify user authentication
2. Validate fileUris format (must be gemini://file/...)
3. Verify fileUris belong to current user's session
4. Validate study set configuration
5. Check rate limits

**Gemini API Call:**
1. Use master GEMINI_API_KEY
2. Call generateContent with model: gemini-2.5-flash
3. Include fileUris in request
4. Include structured prompt for output format
5. Set timeout (2 minutes maximum)

**No File Processing:**
- Backend NEVER downloads file contents
- Backend NEVER processes file bytes
- Backend only passes URIs to Gemini
- Gemini handles all file parsing internally

### 4.4 File Upload Implementation Details

**Multipart Upload to Gemini:**
```
POST https://generativelanguage.googleapis.com/upload/v1beta/files
Headers:
  Authorization: Bearer {temporary_upload_token}
  X-Goog-Upload-Protocol: multipart
  Content-Type: multipart/related; boundary=boundary
  
Body (multipart):
  Part 1 (metadata): { "file": { "displayName": "document.pdf" } }
  Part 2 (file data): Binary file content
```

**Response from Gemini:**
```
{
  "file": {
    "name": "files/abc123xyz",
    "displayName": "document.pdf",
    "mimeType": "application/pdf",
    "sizeBytes": "1048576",
    "createTime": "2025-11-29T12:00:00Z",
    "expirationTime": "2025-12-01T12:00:00Z",
    "sha256Hash": "...",
    "uri": "gemini://file/abc123xyz"
  }
}
```

**URI Extraction:**
Frontend extracts `file.uri` or `file.name` for use in generation request

### 4.5 Benefits of This Approach

**Performance:**
- Tiny payloads (URIs instead of file content)
- Fast API calls to backend
- No memory issues with large files
- Parallel file uploads possible

**Scalability:**
- Backend doesn't bottleneck on file uploads
- Render free tier limits not exceeded
- Can handle multiple concurrent users
- Gemini handles file processing load

**Security:**
- Master API key never exposed to frontend
- Temporary tokens are restricted and short-lived
- File access controlled by Gemini
- No file storage = no data breach risk

**Reliability:**
- Gemini's robust file processing
- Automatic file cleanup after 48 hours
- Native support for PDFs, PPTs, DOCs
- Built-in error handling

---

## 5. Gemini 2.5 Flash Integration

### 5.1 API Configuration

**Model Selection:**
- Use gemini-2.5-flash (or gemini-2.0-flash if 2.5 unavailable)
- Optimized for speed and efficiency with large documents
- Supports native file understanding via File API
- Handles multiple file formats natively (PDF, PPT, DOCX, TXT)

**File API Endpoint:**
- Upload: `https://generativelanguage.googleapis.com/upload/v1beta/files`
- Generate: `https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:generateContent`

**Authentication:**
- Master API key stored in backend: GEMINI_API_KEY
- Temporary upload tokens generated by backend for frontend uploads
- All generation requests use master key from backend

### 5.2 Prompt Engineering Strategy

**System Instructions:**
The backend constructs a comprehensive prompt that includes:

**Role Definition:**
```
You are an expert educational content creator specializing in study materials.
Your task is to analyze the provided documents and create comprehensive,
high-quality study materials including quizzes, flashcards, and notes.
```

**Task Description:**
```
Analyze the {number} uploaded document(s) and extract key concepts, facts,
definitions, and relationships. Create study materials that help students
understand and retain the information effectively.
```

**Output Format Specification:**
```
You MUST return ONLY a valid JSON object with this EXACT structure:
{
  "notes": [
    {
      "title": "string (max 100 chars)",
      "content": "string (rich formatted text in Quill Delta JSON format)",
      "category": "string",
      "tags": ["string"]
    }
  ],
  "quizzes": [
    {
      "title": "string (max 100 chars)",
      "description": "string",
      "questions": [
        {
          "question": "string",
          "options": ["option1", "option2", "option3", "option4"],
          "correctAnswer": "string (exact match to one option)",
          "explanation": "string (why this answer is correct)"
        }
      ]
    }
  ],
  "flashcards": [
    {
      "title": "string (flashcard set title)",
      "cards": [
        {
          "front": "string (question/term)",
          "back": "string (answer/definition)"
        }
      ]
    }
  ]
}

CRITICAL: Do not include any text outside the JSON object. No markdown, no explanations.
```

**Content Requirements:**

For Quizzes:
- Generate {quizCount} separate quizzes based on user settings
- Each quiz should have {questionsPerQuiz} questions (from user settings)
- Questions must be multiple-choice with exactly 4 options
- Difficulty level: {difficulty} (Easy/Medium/Hard/Mixed from user settings)
- Each question must have clear explanation for the correct answer
- Cover different topics/sections from the documents
- Avoid trivial or ambiguous questions
- Test understanding, not just memorization

For Flashcards:
- Generate {flashcardSetCount} flashcard sets based on user settings
- Each set should have {cardsPerSet} cards (from user settings)
- Front: Clear, concise question or term
- Back: Comprehensive but focused answer/definition
- Cover key terms, concepts, formulas, definitions
- Include examples where helpful
- Group related concepts in same set

For Notes:
- Generate {noteCount} structured notes based on user settings
- Use clear headings and subheadings
- Include key points, definitions, summaries
- Format using Quill Delta JSON structure for rich text
- Make notes comprehensive but scannable
- Organize information logically
- Highlight important concepts

**Document Context Instructions:**
```
The user has uploaded {fileCount} document(s):
{fileUris list}

Extract information from ALL documents and ensure comprehensive coverage.
Identify main themes, key concepts, and important details across all files.
Ensure generated content is diverse and covers the full scope of material.
```

**Quality Guidelines:**
```
- Ensure all content is educationally sound
- Use clear, accessible language
- Avoid errors or misleading information
- Make content appropriate for the stated difficulty level
- Ensure quiz options are plausible (no obviously wrong choices)
- Make flashcards self-contained and easy to review
- Structure notes for easy scanning and review
```

### 5.3 Generation Request Structure

**API Call from Backend:**
```
POST https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:generateContent

Headers:
  Authorization: Bearer {GEMINI_API_KEY from env}
  Content-Type: application/json

Body:
{
  "contents": [
    {
      "parts": [
        {
          "fileData": {
            "fileUri": "gemini://file/abc123",
            "mimeType": "application/pdf"
          }
        },
        {
          "fileData": {
            "fileUri": "gemini://file/xyz789",
            "mimeType": "application/pdf"
          }
        },
        {
          "text": "{comprehensive prompt with instructions and format}"
        }
      ]
    }
  ],
  "generationConfig": {
    "temperature": 0.7,
    "topK": 40,
    "topP": 0.95,
    "maxOutputTokens": 8192,
    "responseMimeType": "application/json"
  }
}
```

**Key Configuration:**
- `responseMimeType: "application/json"` ensures JSON output
- `maxOutputTokens: 8192` allows comprehensive responses
- `temperature: 0.7` balances creativity and accuracy
- Include all file URIs in fileData parts
- Prompt included as text part

### 5.4 Response Processing

**Expected Response from Gemini:**
```
{
  "candidates": [
    {
      "content": {
        "parts": [
          {
            "text": "{valid JSON with notes, quizzes, flashcards}"
          }
        ]
      },
      "finishReason": "STOP"
    }
  ]
}
```

**Backend Processing Steps:**

1. **Extract JSON from Response:**
   - Get `candidates[0].content.parts[0].text`
   - Parse as JSON object
   - Validate structure matches expected schema

2. **Validation:**
   - Verify all required fields present (notes, quizzes, flashcards)
   - Check data types match expected formats
   - Ensure arrays are not empty
   - Validate quiz questions have 4 options each
   - Verify correctAnswer matches one of the options

3. **Data Transformation:**
   - Convert Gemini's output to match app's data models
   - Transform note content to Quill Delta format if needed
   - Add metadata (IDs, timestamps, userId, etc.)
   - Format dates properly
   - Add default values for optional fields

4. **Create Study Set Structure:**
```
{
  "id": "generated_uuid",
  "name": "{user provided name}",
  "description": "{user provided description}",
  "category": "{user provided category}",
  "language": "{user provided language}",
  "coverImagePath": "{user provided or null}",
  "ownerId": "{userId}",
  "quizzes": [...transformed quiz objects],
  "flashcardSets": [...transformed flashcard objects],
  "notes": [...transformed note objects],
  "createdAt": "{formatted timestamp}",
  "updatedAt": "{formatted timestamp}",
  "generatedWithAI": true,
  "generationSettings": {
    "quizCount": 2,
    "flashcardCount": 2,
    "noteCount": 1,
    "difficulty": "Mixed",
    "questionsPerQuiz": 10,
    "cardsPerSet": 20
  }
}
```

5. **Save to Database:**
   - Insert complete study set into MongoDB
   - Return study set ID and data to frontend

### 5.5 Error Handling

**Gemini API Errors:**

**Rate Limit Exceeded:**
- Catch: `429 Too Many Requests`
- Response: `{ "error": "Rate limit exceeded. Please try again in a few minutes." }`
- Log occurrence for monitoring
- Consider implementing request queue

**Invalid File URI:**
- Catch: `400 Bad Request` or `404 Not Found`
- Response: `{ "error": "File not found. It may have expired. Please re-upload." }`
- Files expire after 48 hours

**Content Policy Violation:**
- Catch: `400 Bad Request` with policy error
- Response: `{ "error": "Content violates policy. Please upload appropriate educational materials." }`

**Token Limit Exceeded:**
- Catch: `400 Bad Request` with token error
- Response: `{ "error": "Documents too large. Please upload smaller files." }`
- Suggest splitting content

**Network Timeout:**
- Set 2-minute timeout on request
- Response: `{ "error": "Generation timed out. Please try again with smaller documents." }`

**Invalid JSON Response:**
- If Gemini returns malformed JSON
- Response: `{ "error": "Generation failed. Please try again." }`
- Log error for debugging
- Consider retry with adjusted prompt

**Backend Processing Errors:**
- Database save failures
- Transformation errors
- Validation failures
- Return specific error messages
- Log full error details
- Don't expose internal errors to user

---

## 6. Backend Implementation Plan

### 6.1 New API Endpoints

**Endpoint 1: POST /get-upload-token**

**Purpose:** Generate temporary, restricted token for Gemini File API uploads

**Authentication:** Requires valid user JWT token

**Request:**
```
Headers:
  Authorization: Bearer {user_jwt_token}
```

**Response:**
```
{
  "success": true,
  "uploadToken": "restricted_temp_token_xyz",
  "expiresIn": 600,
  "expiresAt": "2025-11-29T12:10:00Z",
  "maxUploads": 3
}
```

**Implementation Details:**
- Verify user authentication
- Check user's rate limits (max tokens per hour/day)
- Generate scoped token using Gemini API key
- Token scope: File upload operations ONLY
- Token lifetime: 5-10 minutes
- Store token metadata in Redis/cache (token ID, user ID, expiration)
- Return token to frontend

**Security Measures:**
- Rate limit: Max 10 token requests per user per hour
- Token cannot be used for content generation
- Token expires automatically
- Log all token generation for audit

**Endpoint 2: POST /generate-study-set**

**Purpose:** Generate AI study set using uploaded file URIs

**Authentication:** Requires valid user JWT token

**Request:**
```
Headers:
  Authorization: Bearer {user_jwt_token}
  Content-Type: application/json

Body:
{
  "fileUris": [
    "gemini://file/abc123",
    "gemini://file/xyz789"
  ],
  "studySetConfig": {
    "name": "Biology Chapter 5",
    "description": "Cell structure and functions",
    "category": "Biology",
    "language": "English",
    "coverImagePath": null
  },
  "generationSettings": {
    "quizCount": 2,
    "flashcardSetCount": 2,
    "noteCount": 1,
    "difficulty": "Mixed",
    "questionsPerQuiz": 10,
    "cardsPerSet": 20
  }
}
```

**Response (Success):**
```
{
  "success": true,
  "studySet": {
    "id": "674a8b2c1234567890abcdef",
    "name": "Biology Chapter 5",
    "description": "Cell structure and functions",
    "category": "Biology",
    "language": "English",
    "coverImagePath": null,
    "ownerId": "user123",
    "quizzes": [...],
    "flashcardSets": [...],
    "notes": [...],
    "createdAt": "November, 2025",
    "updatedAt": "2025-11-29T12:00:00Z",
    "generatedWithAI": true
  }
}
```

**Response (Error):**
```
{
  "success": false,
  "error": "Detailed error message",
  "errorCode": "RATE_LIMIT_EXCEEDED | FILE_EXPIRED | INVALID_FORMAT | etc."
}
```

**Implementation Details:**

1. **Validation:**
   - Verify user authentication
   - Validate fileUris format (must start with "gemini://file/")
   - Verify 1-3 file URIs provided
   - Validate study set configuration fields
   - Validate generation settings ranges

2. **Rate Limiting:**
   - Check user's generation quota
   - Max 10 generations per day per user (adjust as needed)
   - Log usage for monitoring

3. **Gemini API Call:**
   - Construct comprehensive prompt with user settings
   - Include all file URIs in request
   - Set timeout: 120 seconds
   - Use master GEMINI_API_KEY from environment

4. **Response Processing:**
   - Parse JSON from Gemini
   - Validate structure and content
   - Transform to app's data models
   - Add metadata (user ID, timestamps, IDs)

5. **Database Save:**
   - Save complete study set to MongoDB
   - Store generation metadata
   - Return study set to frontend

### 6.2 Environment Variables on Render

**Required Variables:**

1. **GEMINI_API_KEY**
   - Purpose: Master API key for Gemini operations
   - Source: Google AI Studio (see section 7 for setup)
   - Usage: File token generation, content generation
   - Security: Never expose to frontend

2. **JWT_SECRET** (existing)
   - Purpose: Sign user authentication tokens
   - Usage: Verify user identity in requests

3. **MONGODB_URI** (existing)
   - Purpose: Database connection
   - Usage: Store study sets

4. **REDIS_URL** (optional but recommended)
   - Purpose: Token metadata cache, rate limiting
   - Usage: Track upload tokens, user quotas
   - Alternative: Use MongoDB if Redis unavailable

**Setting Variables in Render:**
(Detailed steps in Section 7.2)

### 6.3 Dependencies

**Add to requirements.txt:**
```
google-generativeai>=0.3.0  # Official Gemini SDK
httpx>=0.25.0               # HTTP client for file uploads
redis>=5.0.0                # Token cache (optional)
```

**Python Package Installation:**
- Render will automatically install on deployment
- Update requirements.txt in repository
- Trigger redeploy

### 6.4 Upload Token Generation Logic

**Token Structure:**
The upload token should be a restricted Gemini API key that:
- Can only upload files to Gemini File API
- Cannot perform content generation
- Expires after 5-10 minutes
- Is tied to the user session

**Implementation Options:**

**Option A: Use Gemini API Key with Restrictions (Recommended)**
- Gemini API keys can be scoped to specific operations
- Generate short-lived key using master key
- Scope to file upload endpoint only
- Automatic expiration

**Option B: JWT Token with Backend Proxy**
- Backend generates JWT token
- Frontend sends file + JWT to backend proxy endpoint
- Backend uploads to Gemini using master key
- Returns file URI to frontend
- More secure but adds latency

**Recommended: Option A** - Gemini supports scoped keys, use native functionality

### 6.5 File URI Validation

**Security Checks Before Generation:**

1. **Format Validation:**
   - Must start with "gemini://file/" or "files/"
   - Match Gemini's URI pattern
   - No injection attempts

2. **Expiration Check:**
   - Files expire after 48 hours
   - Verify file still exists by checking with Gemini
   - Return clear error if expired

3. **Ownership Verification (Optional):**
   - If possible, track which user uploaded which URIs
   - Store mapping: uploadToken -> userId -> fileUris
   - Verify URIs belong to requesting user
   - Prevents one user using another's files

### 6.6 Error Handling Strategy

**Categorize Errors:**

1. **Client Errors (4xx):**
   - Invalid input: Return validation errors
   - Expired files: Request re-upload
   - Rate limit: Return retry-after time
   - Status: 400 Bad Request

2. **Server Errors (5xx):**
   - Gemini API down: Return service unavailable
   - Database errors: Return temporary failure
   - Timeout: Return timeout error
   - Status: 500/503

3. **Gemini-Specific Errors:**
   - Map Gemini errors to user-friendly messages
   - Log technical details
   - Return actionable guidance

**Error Response Format:**
```
{
  "success": false,
  "error": "User-friendly message",
  "errorCode": "ENUM_ERROR_CODE",
  "retryable": true/false,
  "retryAfter": 60 (seconds, if applicable)
}
```

### 6.7 Monitoring and Logging

**Log Events:**
- Token generation requests
- File upload completions
- Generation requests (with settings)
- Generation successes/failures
- API errors and timeouts
- Rate limit hits

**Metrics to Track:**
- Tokens generated per day
- Generations per day
- Success rate
- Average generation time
- Error types and frequencies
- User quotas consumed

**Alerts:**
- High error rate
- Gemini API failures
- Rate limit approaching
- Unusual usage patterns

---

## 7. Environment Variable Setup on Render

### 7.1 Obtaining Gemini API Key

**Step 1: Access Google AI Studio**
- Navigate to https://aistudio.google.com/
- Sign in with Google account
- Accept terms of service if prompted

**Step 2: Create API Key**
- Click on "Get API Key" button in the top right
- Click "Create API Key" 
- Choose existing Google Cloud project or create new one
- Copy the generated API key immediately
- Store it securely (you won't be able to see it again)

**Step 3: Verify API Access**
- Test the API key with a simple request
- Ensure Gemini 2.5 Flash model is accessible
- Check usage quotas and limits

### 7.2 Adding Environment Variable in Render

**Step 1: Access Render Dashboard**
- Go to https://dashboard.render.com/
- Log in to your account
- Navigate to your backend service (Queez-Backend)

**Step 2: Open Environment Settings**
- Click on the service name to open service details
- In the left sidebar, click "Environment"
- This shows all current environment variables

**Step 3: Add New Environment Variable**
- Click the "Add Environment Variable" button
- In the "Key" field, enter exactly: GEMINI_API_KEY
- In the "Value" field, paste your Gemini API key
- Ensure there are no extra spaces or characters
- Click "Save Changes"

**Step 4: Trigger Deployment**
- Render will automatically redeploy the service with the new environment variable
- Wait for deployment to complete (usually 2-5 minutes)
- Check deployment logs for any errors

**Step 5: Verify Environment Variable**
- After deployment, the environment variable is accessible in Python
- The backend code will access it using: os.getenv('GEMINI_API_KEY')
- Add a health check endpoint that verifies the key exists (without exposing it)

### 7.3 Security Best Practices

**DO:**
- Keep API key in environment variables only
- Never commit API keys to version control
- Rotate API keys periodically
- Monitor API usage for anomalies
- Set up billing alerts in Google Cloud

**DON'T:**
- Never hardcode API keys in source code
- Never expose API keys in responses
- Never log full API keys
- Never share API keys in documentation
- Never commit .env files with real keys

---

## 8. Frontend Implementation Plan

### 8.1 New Screens/Pages

**Study Set Mode Selection Page:**
- Widget name: StudySetModeSelection
- Location: lib/CreateSection/screens/study_set_mode_selection.dart
- Purpose: Let user choose between manual and AI creation
- Navigation: Reached from Create page Study Set button
- Contains two large option cards with navigation logic

**AI Study Set Configuration Page:**
- Widget name: AIStudySetConfiguration
- Location: lib/CreateSection/screens/ai_study_set_configuration.dart
- Purpose: Upload documents and configure AI generation
- Sub-components:
  - Document upload section (3 slots)
  - Study set info form (name, description, category, language)
  - Generation settings section (quiz count, difficulty, etc.)
  - Generate button (enabled only when valid)

**AI Generation Progress Page:**
- Widget name: AIGenerationProgress
- Location: lib/CreateSection/screens/ai_generation_progress.dart
- Purpose: Show progress while Gemini generates content
- Components:
  - Lottie animation (assets/animations/loading.json)
  - Progress bar with percentage
  - Status text describing current step
  - Cannot be dismissed during generation

### 8.2 File Upload Flow

**Step 1: Request Upload Token**

```
Service: AIStudySetService.getUploadToken()
Endpoint: POST /get-upload-token
Headers: { Authorization: Bearer {userToken} }
Response: { uploadToken, expiresIn, expiresAt }
Store token in state for subsequent uploads
```

**Step 2: Select Files**

- Use file_picker package
- Allow multiple file selection (max 3)
- Validate each file:
  - Check size <= 10MB
  - Check type: PDF, PPT, PPTX, DOC, DOCX, TXT
  - Show error immediately if invalid
- Display selected files with name, size, remove button

**Step 3: Upload to Gemini File API**

```
For each selected file:
  1. Show upload progress indicator
  2. Create multipart request:
     - Endpoint: https://generativelanguage.googleapis.com/upload/v1beta/files
     - Headers:
       * Authorization: Bearer {uploadToken}
       * X-Goog-Upload-Protocol: multipart
     - Body: Multipart with metadata + file bytes
  3. Track upload progress
  4. On success: Extract file.uri from response
  5. Store URI in state
  6. Show success checkmark
  7. On error: Show error, allow retry
```

**Step 4: Store File URIs**

- Keep array of uploaded file URIs
- Display URIs in UI (truncated for readability)
- Allow removing uploaded files (removes from array)
- Validate at least 1 file uploaded before allowing generation

### 8.3 State Management

**AI Study Set Provider:**
- Location: lib/CreateSection/providers/ai_study_set_provider.dart
- Uses ChangeNotifier pattern

**State Variables:**
```
class AIStudySetProvider extends ChangeNotifier {
  // Upload token
  String? _uploadToken;
  DateTime? _tokenExpiration;
  
  // Uploaded files
  List<UploadedFile> _uploadedFiles = [];
  
  // Study set configuration
  StudySetConfig _config;
  
  // Generation settings
  GenerationSettings _settings;
  
  // Generation state
  bool _isGenerating = false;
  double _progress = 0.0;
  String _currentStep = '';
  String? _error;
  
  // Generated content
  StudySet? _generatedStudySet;
}
```

**Methods:**
- `fetchUploadToken()`: Get token from backend
- `uploadFile(File file)`: Upload to Gemini, return URI
- `removeFile(int index)`: Remove uploaded file
- `updateConfig(...)`: Update study set info
- `updateSettings(...)`: Update generation settings
- `generateStudySet()`: Call backend generation endpoint
- `reset()`: Clear all state

**Benefits:**
- Reactive UI updates
- Centralized state
- Easy error handling
- Progress tracking

### 8.4 HTTP Requests Implementation

**Package:** Use http or dio package

**Upload Token Request:**
```
Future<String> getUploadToken() async {
  final response = await http.post(
    Uri.parse('$baseUrl/get-upload-token'),
    headers: {
      'Authorization': 'Bearer $userToken',
      'Content-Type': 'application/json',
    },
  );
  
  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    return data['uploadToken'];
  } else {
    throw Exception('Failed to get upload token');
  }
}
```

**File Upload to Gemini:**
```
Future<String> uploadFileToGemini(File file, String uploadToken) async {
  final request = http.MultipartRequest(
    'POST',
    Uri.parse('https://generativelanguage.googleapis.com/upload/v1beta/files'),
  );
  
  request.headers.addAll({
    'Authorization': 'Bearer $uploadToken',
    'X-Goog-Upload-Protocol': 'multipart',
  });
  
  // Add metadata
  final metadata = jsonEncode({
    'file': {
      'displayName': file.path.split('/').last,
    }
  });
  
  request.files.add(
    http.MultipartFile.fromString(
      'metadata',
      metadata,
      contentType: MediaType('application', 'json'),
    ),
  );
  
  // Add file
  request.files.add(
    await http.MultipartFile.fromPath('file', file.path),
  );
  
  final streamedResponse = await request.send();
  final response = await http.Response.fromStream(streamedResponse);
  
  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    return data['file']['uri']; // Returns gemini://file/...
  } else {
    throw Exception('File upload failed');
  }
}
```

**Generation Request:**
```
Future<StudySet> generateStudySet({
  required List<String> fileUris,
  required StudySetConfig config,
  required GenerationSettings settings,
}) async {
  final response = await http.post(
    Uri.parse('$baseUrl/generate-study-set'),
    headers: {
      'Authorization': 'Bearer $userToken',
      'Content-Type': 'application/json',
    },
    body: jsonEncode({
      'fileUris': fileUris,
      'studySetConfig': config.toJson(),
      'generationSettings': settings.toJson(),
    }),
  );
  
  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    return StudySet.fromJson(data['studySet']);
  } else {
    final error = jsonDecode(response.body);
    throw Exception(error['error'] ?? 'Generation failed');
  }
}
```

### 8.5 Progress Tracking UI

**Progress States:**

1. **Initializing (0-10%):**
   - "Preparing your documents..."
   - Validating files, requesting token

2. **Uploading (10-30%):**
   - "Uploading documents to Gemini..."
   - Track file upload progress
   - Show individual file completion

3. **Processing (30-50%):**
   - "Analyzing document content..."
   - Gemini is reading files

4. **Generating Quizzes (50-70%):**
   - "Creating quiz questions..."
   - Show quiz count in settings

5. **Generating Flashcards (70-85%):**
   - "Building flashcard sets..."
   - Show flashcard count

6. **Generating Notes (85-95%):**
   - "Compiling study notes..."
   - Show note count

7. **Finalizing (95-100%):**
   - "Saving your study set..."
   - Backend save in progress

**UI Components:**

```
LinearProgressIndicator:
  - value: _progress / 100
  - color: AppColors.primary
  - height: 6
  - rounded corners

Lottie Animation:
  - source: assets/animations/loading.json
  - size: 200x200
  - loop: true
  - centered

Status Text:
  - currentStep text
  - fontSize: 18
  - fontWeight: bold
  - color: AppColors.textPrimary

Progress Percentage:
  - "${_progress.toInt()}%"
  - fontSize: 16
  - color: AppColors.textSecondary
```

**Update Progress:**

Since backend doesn't support websockets/SSE, simulate progress:

```
Future<void> _generateWithProgress() async {
  setState(() {
    _progress = 0;
    _currentStep = 'Preparing your documents...';
  });
  
  // Simulate upload progress
  _updateProgress(10, 'Uploading documents to Gemini...');
  await Future.delayed(Duration(seconds: 1));
  
  _updateProgress(30, 'Analyzing document content...');
  
  // Start actual generation
  try {
    final studySet = await AIStudySetService.generateStudySet(...);
    
    // Simulate generation phases
    _updateProgress(50, 'Creating quiz questions...');
    await Future.delayed(Duration(seconds: 2));
    
    _updateProgress(70, 'Building flashcard sets...');
    await Future.delayed(Duration(seconds: 2));
    
    _updateProgress(85, 'Compiling study notes...');
    await Future.delayed(Duration(seconds: 1));
    
    _updateProgress(95, 'Saving your study set...');
    await Future.delayed(Duration(milliseconds: 500));
    
    _updateProgress(100, 'Complete!');
    
    // Show success dialog
    _showSuccessDialog(studySet);
    
  } catch (e) {
    _showError(e.toString());
  }
}
```

### 8.6 Error Handling

**Error Types:**

1. **File Selection Errors:**
   - File too large: "File exceeds 10MB limit"
   - Invalid type: "Unsupported file format"
   - Too many files: "Maximum 3 files allowed"

2. **Upload Errors:**
   - Token expired: "Session expired. Please try again"
   - Network error: "Upload failed. Check connection"
   - Gemini error: "File upload failed. Please retry"

3. **Generation Errors:**
   - File expired: "Files expired. Please re-upload"
   - Rate limit: "Daily limit reached. Try tomorrow"
   - Timeout: "Generation timed out. Try smaller files"
   - Invalid content: "Content policy violation"

**Error Display:**

```
Show error dialog:
  - Icon: Error icon (red)
  - Title: "Generation Failed"
  - Message: Specific error message
  - Actions:
    * "Retry" button (if retryable)
    * "Back" button (return to config)
    * "Cancel" button (go to home)
```

**Error Recovery:**

- Keep uploaded file URIs on error
- Don't force re-upload unless files expired
- Allow editing configuration
- Provide clear retry path
- Log errors for debugging

### 8.7 Form Validation

**Study Set Configuration Validation:**

Required fields:
- Name: 3-100 characters
- Description: 10-500 characters
- Category: Must select from dropdown
- Language: Must select from dropdown

Optional:
- Cover image: Max 5MB, image types only

**Generation Settings Validation:**

- Quiz count: 1-5 (default: 2)
- Flashcard set count: 1-3 (default: 2)
- Note count: 1-3 (default: 1)
- Difficulty: Easy/Medium/Hard/Mixed (default: Mixed)
- Questions per quiz: 5-20 (default: 10)
- Cards per set: 10-50 (default: 20)

**Generate Button Enable Logic:**

```
bool get canGenerate {
  return _uploadedFiles.isNotEmpty &&
         _uploadedFiles.length <= 3 &&
         _config.name.isNotEmpty &&
         _config.description.length >= 10 &&
         _config.category.isNotEmpty &&
         _config.language.isNotEmpty &&
         !_isGenerating;
}
```

Show validation errors inline as user types

---

## 9. Success Flow and Navigation

### 9.1 Generation Complete

**When Gemini Successfully Generates Content:**
1. Stop showing progress indicator
2. Parse the complete study set from backend response
3. Save to local cache (StudySetCacheManager)
4. Show the same quiz_saved_dialog.dart that manual creation uses
5. Navigate to Library tab

**Dialog Behavior:**
The quiz_saved_dialog should display:
- Success checkmark animation
- "Study Set Created Successfully!" message
- Brief summary showing what was generated
- Same "Go to Library" button as manual creation

### 9.2 Navigation Pattern

**Must Match Manual Creation:**
After showing the success dialog:
- Use Navigator.popUntil to clear the creation stack
- Navigate to Library tab (index 1)
- Library should refresh to show the new study set
- Study set should appear at the top with proper metadata

**Back Button Handling:**
- During document upload: can go back to mode selection
- During generation: show confirmation dialog before canceling
- After generation: standard back navigation

### 9.3 Cache Management

**AI-Generated Study Sets:**
- Save to StudySetCacheManager immediately after generation
- Include all quizzes, flashcards, and notes
- Mark as AI-generated in cache
- Clear cache after successful backend save

**Failure Recovery:**
If backend save fails after generation:
- Keep content in cache
- Allow user to retry save
- Don't force regeneration
- Show clear error about save failure

---

## 10. User Experience Considerations

### 10.1 Loading States

**Document Upload:**
- Show spinner while file is being read
- Display progress for large files
- Provide immediate feedback on validation

**AI Generation:**
- Show loading.json Lottie animation continuously
- Update progress bar with realistic estimates
- Display current generation step in text
- Never leave user wondering what's happening

**Error States:**
- Clear, friendly error messages
- Suggest specific actions to fix issues
- Don't use technical jargon
- Provide retry options

### 10.2 Performance Optimization

**File Processing:**
- Process files asynchronously
- Don't block UI thread
- Show cancellation option for long uploads
- Optimize base64 conversion

**API Calls:**
- Set reasonable timeouts (2 minutes max)
- Handle network interruptions gracefully
- Cache successful generations
- Implement retry logic with exponential backoff

### 10.3 Accessibility

**All Interactive Elements:**
- Proper semantic labels
- Keyboard navigation support
- Screen reader compatibility
- Color contrast compliance

**Progress Indicators:**
- Announce progress changes to screen readers
- Provide text alternatives to visual indicators
- Support reduced motion preferences

---

## 11. Testing Strategy

### 11.1 Frontend Testing

**Unit Tests:**
- File validation logic
- Base64 conversion
- Form validation
- State management logic

**Widget Tests:**
- Mode selection page
- Document upload interface
- Configuration form
- Progress screen
- Error states

**Integration Tests:**
- Full AI generation flow
- Navigation patterns
- Dialog behavior
- Cache management

### 11.2 Backend Testing

**API Tests:**
- Document processing
- Gemini API integration
- Response transformation
- Error handling

**Load Tests:**
- Multiple concurrent requests
- Large file handling
- Timeout scenarios
- Rate limit behavior

### 11.3 Manual Testing Checklist

**Happy Path:**
- Upload 1 document, generate study set
- Upload 3 documents, generate study set
- Try different file types
- Test various generation settings
- Verify saved content matches generated

**Error Scenarios:**
- Upload file larger than 10MB
- Upload unsupported file type
- Test network interruption
- Test Gemini API errors
- Test validation failures

**Edge Cases:**
- No documents uploaded
- All three document slots filled then removed
- Quick navigation away during generation
- App backgrounding during generation
- Low memory situations

---

## 12. Analytics and Monitoring

### 12.1 Metrics to Track

**Usage Metrics:**
- Number of AI generations vs manual creations
- Average number of documents uploaded
- Most common generation settings
- Success vs failure rate
- Average generation time

**Performance Metrics:**
- API response times
- File upload times
- Gemini processing duration
- Error rates by type
- User retry behavior

### 12.2 Error Logging

**Frontend Logs:**
- File upload errors
- Validation failures
- API communication errors
- Navigation issues

**Backend Logs:**
- Gemini API errors
- Rate limit hits
- Timeout occurrences
- Database save failures

### 12.3 User Feedback

**Post-Generation Survey (Optional):**
- Quality of generated content
- Helpfulness rating
- Suggestions for improvement
- What worked well

---

## 13. Future Enhancements

### 13.1 Potential Improvements

**Content Editing:**
- Allow editing AI-generated content before saving
- Preview quizzes, flashcards, notes
- Regenerate specific items
- Merge AI and manual content

**Advanced Settings:**
- Custom prompts for generation
- Topic focus areas
- Content style preferences
- Language-specific optimizations

**Multi-Modal Input:**
- Support image uploads
- URL/link input for articles
- YouTube video transcripts
- Audio file transcription

### 13.2 Scalability Considerations

**If Usage Grows:**
- Implement request queuing
- Consider premium tier with faster processing
- Add generation history
- Batch processing for efficiency
- Caching similar document sets

---

## 14. Implementation Timeline

### 14.1 Phase 1: Basic Infrastructure (Week 1)
- Create mode selection page
- Set up Gemini API in backend
- Configure environment variables on Render
- Implement basic file upload UI

### 14.2 Phase 2: Core Generation (Week 2)
- Build AI configuration page
- Implement document processing
- Create Gemini prompt engineering
- Build progress tracking UI

### 14.3 Phase 3: Integration (Week 3)
- Connect all flows
- Implement success dialog
- Test navigation patterns
- Add error handling

### 14.4 Phase 4: Polish & Testing (Week 4)
- Comprehensive testing
- UI/UX refinements
- Performance optimization
- Documentation updates

---

## 15. Success Criteria

The AI Study Set generation feature will be considered successful when:

1. **Functionality:**
   - Users can upload 1-3 documents under 10MB each
   - Gemini successfully generates quizzes, flashcards, and notes
   - Generated content is properly saved and displayed in Library
   - Success dialog and navigation match manual creation flow

2. **Performance:**
   - Generation completes within 2 minutes for typical documents
   - UI remains responsive during generation
   - No memory issues with large files
   - Error rate below 5%

3. **User Experience:**
   - Clear, intuitive interface
   - Helpful progress indicators
   - Meaningful error messages
   - Smooth navigation flow

4. **Technical Quality:**
   - No API key exposure
   - Proper error handling
   - Clean code organization
   - Comprehensive testing coverage

---

## Conclusion

This AI-powered Study Set generation feature will significantly enhance the app by allowing users to quickly create comprehensive study materials from their existing documents. By leveraging Gemini 2.5 Flash and maintaining a user-friendly interface that matches the existing manual creation flow, users will have a seamless experience whether they choose AI or manual creation.

The key to success is proper document handling (avoiding backend storage), robust error handling, clear progress indication, and ensuring the AI-generated content integrates perfectly with the existing study set system.
