# RumahGen — Rural Homestay Auto Listing Agent

Empowering Malaysian kampung homestay owners to go online , zero tech skills needed.

RumahGen is an AI-powered mobile web-app that helps rural homestay owners in Malaysia create professional property listings effortlessly. It bridges the digital divide by letting hosts upload photos, speak or type in English, and generate polished listings ready to share on Google Business Profile or Airbnb, all powered by Gemini AI.

---

## SDG Alignment

| Goal | How We Contribute |
|------|------------------|
| **SDG 8** — Decent Work & Economic Growth | Creates new income streams for rural communities through tourism |
| **SDG 9** — Industry, Innovation & Infrastructure | Brings digital infrastructure to underserved rural areas |
| **SDG 10** — Reduced Inequalities | Lowers the barrier to entry for non-tech-savvy homestay owners |
| **SDG 11** — Sustainable Cities & Communities | Promotes rural tourism as an alternative to urban overcrowding |

---

## Technical Architecture



### Frontend — Flutter (Dart)
The mobile web-app handles the full user journey: registration, login, photo upload, voice/text input, listing preview, and the Google Business Profile/Airbnb setup guide. The current prototype uses Flutter which a feature-first architecture, separating code by features. The frontend also separates fetching data logic from backend and UI to keep the frontend modular.

### Backend — Django (Python)
Django manages user sessions, authentication, and acts as the orchestration layer between the frontend, Firebase, and Gemini API. RESTful endpoints handle photo ingestion, trigger Gemini analysis, and store structured listing data.

### AI Layer — Gemini 2.5 Flash API
A single multimodal model handles four distinct jobs: analyzing homestay photos to extract visual attributes (architecture, amenities, surroundings), converting voice recordings to text, generating professional listing descriptions in both English and Bahasa Malaysia, and extracting structured fields (property name, room count, location, facilities) for backend storage.

### Auth & Storage — Firebase
Firebase Authentication handles user login, registration, and Google Sign-In. Firebase Realtime Database stores user profiles and listing metadata. Firebase Storage holds the uploaded homestay photos, referenced by UUID-based user sessions.

---

## Implementation Details



### Gemini Prompt Strategy
Images and text/voice input are submitted to Gemini 1.5 Flash in a single multimodal request. The system prompt instructs the model to act as a hospitality copywriter familiar with Malaysian rural tourism, and to output a structured JSON payload containing the listing title, short description, long description and detected amenities list. The Django view then parses this JSON and persists it to the database.

### Currently Working (v0.1)
- Google Sign-In via Firebase
- Session management using UUID-based user IDs
- Photo upload linked to authenticated user, stored in Firebase Storage
- Photo URLs saved in Firebase Realtime Database under the user's profile
- Gemini Listing generation
- Logout

---

## Challenges Faced

**Non-tech-savvy UX.** Designing for users who may have never created an online listing means every step must be self-explanatory, with minimal jargon. The Google Business Profile & Airbnb guide had to be broken into illustrated steps rather than a link dump.

**CORS-Policy Issues** Encountered multiple CORS issues throughout development with both Django and Firebase.

**Google Sign-In on Flutter Web** Flutter Web treats google sign in features differently than traditional mobile Flutter hence most of hte guides online did not work and we had to go through multiple documentations to find a solution. 

---

## Future Roadmap

- Complete Flutter app with both web and mobile version
- In-app historical listing previews with editable fields
- Shareable hosted listing page with unique URL (no external platform needed)
- One-tap copy for Google Business Profile pre-filled data
- Localisation for Bahasa Melayu language
- Direct Airbnb listing draft export (copy-paste optimised format)
- Voice input (Gemini speech-to-text) with support for Manglish and mixed BM/EN
- WhatsApp share integration — send listing link directly from the app
- Host dashboard: view, edit, and manage multiple listings
- Google Business Profile API integration for automated listing creation (pending GBP API access approval)
- Analytics dashboard: listing views, inquiry counts, seasonal trends
- Expansion beyond Malaysia — adaptable prompt templates for other rural tourism contexts in Southeast Asia

---

## Local Setup

### Prerequisites
- Python 3.11+
- Firebase project with Authentication, Realtime Database, and Storage enabled
- Gemini API key (Google AI Studio)
- Flutter installed

GO TO YOU FIREBASE CONSOLE -> CLICK ON THE GEAR ICON AND CLICK ON SERVICE ACCOUNT
->AT THE FIREBASE ADMIN SDK CHOOSE PYTHON AND GENERATE NEW PRIVATE KEY -> JSON FILE IS DOWNLOADED

COME BACK TO VSCODE 

COPY THE INFORMATION INSIDE THE JSON FILE AND CREATE .env FILE IN ROOT DIRECTORY AND

PASTE THIS BELOW:

FIREBASE_SERVICE_ACCOUNT='{}'

PUT ALL THE DATA U COPIED FROM THE JSON FILE INSIDE OF THE {} AND MAKE THE WHOLE THING ONLY 1 LINE

that's about it, everything else should be fine

WHAT WORKS NOW
1. LOG IN
2. LOG OUT
3. SIGN UP
4. SIGN IN/SIGN UP WITH GOOGLE
5. SUBMIT PHOTO BASED ON USER WHO IS LOGGED IN (USER ID GENERATED USING UUID AND SAVED IN SESSION, THIS IS HOW WE KNOW WHO IS LOGGED IN)

FIREBASE DATABASE (accessed from the Firebase UI -> left hand tab select "Build" to find the DBs)
REALTIME DATABASE: SHOWS THE USERS WHO HAVE SIGNED UP INCLUDING THE URL THAT IS LINKED TO THE PHOTOS THEY SUBMITTED
STORAGE: SHOWS THE PHOTOS THAT USERS HAVE SUBMITTEED
AUTHETICATION: ALL PROFILES OF THE PEOPLE WHO REGISTERED



TO EXECUTE THE CODE AND VIEW THE SITE: 
1. ensure the above .env file setup is completed first (create a new file named .env and insert the FIREBASE_SERVICE_ACCOUNT into it)
2. in terminal run -> pip install -r requirements.txt
3. in terminal run -> python manage.py runserver 
4. Make sure flutter is downloaded, and run the app on google chrome browser using command: `flutter run -d chrome --web-port 5000`



TO EXECUTE THE TEST OF GEMINI MODEL: 
1. create a .env file in the rural directory, put your own gemini api key GEMINI_API_KEY
2. run python -m backend.test_listing while in the rural directory 
3. if you want to test your own audio or images, upload them into rural\example, then adjust the audio_path and image_path in test_listing.py 
