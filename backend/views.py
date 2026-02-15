import time
from django.shortcuts import render, redirect
from django.conf import settings
import pyrebase
import logging
from django.contrib.auth import logout
from backend.firebase import storage, db
from django.http import JsonResponse
from django.views.decorators.csrf import csrf_exempt
import os
from django.contrib.auth import login
from django.contrib.auth.models import User
import json
from firebase_admin import auth
from .firebase import firebase_admin  # make sure this initializes Firebase
from firebase_admin import auth as admin_auth
from backend.gemini import generate_homestay_listing
import asyncio

#this is the brain of the backend where log in, logout, signup, photo upload this that all sort of logic lives

bucket = storage.bucket()
ref = db.reference("users")
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)


_firebase_app = None
_auth = None
_database = None


def _get_firebase():
    """Initialize and return firebase auth and database clients."""
    global _firebase_app, _auth, _database
    if _firebase_app is None:
        config = getattr(settings, "FIREBASE_CONFIG", None)
        if not config:
            raise RuntimeError("FIREBASE_CONFIG is not set in Django settings")
        _firebase_app = pyrebase.initialize_app(config)
        _auth = _firebase_app.auth()
        _database = _firebase_app.database()
        logger.info("Firebase initialized")
    return _auth, _database


# def home(request):
#     return render(request, "home.html")


# def signIn(request):
#     return render(request, "login.html", {
#         "firebase_config": settings.FIREBASE_CONFIG
#     })

@csrf_exempt
def postsignIn(request):
    if request.method != 'POST':
        return JsonResponse({"error": "Invalid request method"}, status=405)
    
    data = json.loads(request.body)
    email = data.get('email', '').strip()
    password = data.get('password', '').strip()

    logger.info('postsignIn called with email: %s', email)

    if not email or not password:
        return JsonResponse({"error": "Email and password are error"}, status=400)
    auth, db = _get_firebase()

    try:
        user = auth.sign_in_with_email_and_password(email, password)

        uid = user.get('localId')
        idToken = user.get('idToken')
        logger.info('User %s signed in successfully', uid)

        if not uid or not idToken:
            return render(request, "login.html", {"message": "Login failed. Please try again."})
        
        request.session.flush()
        request.session['uid'] = uid
        logger.info('User %s signed in successfully', uid)
        request.session['email'] = email
        request.session['idToken'] = idToken

        return JsonResponse({"success": True, "uid": uid, "email": email, "idToken": idToken})

    except Exception:
        return JsonResponse({"success": False, "error": "Invalid credentials"}, status=401)

@csrf_exempt
def google_login(request):
    if request.method != "POST":
        return JsonResponse({"error": "Invalid request"}, status=400)

    try:
        body = json.loads(request.body)
        id_token = body.get("token")

        decoded_token = auth.verify_id_token(id_token)
        uid = decoded_token["uid"]
        email = decoded_token.get("email")

        request.session.flush() #clear session so there is no issue with the uid of the person logged in
        request.session['uid'] = uid
        request.session['email'] = email
        request.session['idToken'] = id_token

        logger.info('User %s signed in rararara', uid)

        user, created = User.objects.get_or_create(
            username=uid,
            defaults={
                "email": email,
            }
        )

        login(request, user)

        return JsonResponse({
            "status": "success",
            "uid": uid,
            "email": email,
            "created": created
        })

    except Exception as e:
        return JsonResponse({"error": str(e)}, status=400)

# @csrf_exempt
# def logout(request):
#     request.session.flush()
#     return redirect("/")

# def signUp(request):
#     return render(request, "registration.html")

@csrf_exempt
def postsignUp(request):
    if request.method != "POST":
        return JsonResponse({"success": False, "error": "Invalid request"}, status=405)

    try:
        data = json.loads(request.body)
        email = data.get("email", "").strip()
        password = data.get("password", "")
        pass_repeat = data.get("password_repeat", "")
        name = data.get("name", "").strip()
    except Exception:
        return JsonResponse({"success": False, "error": "Invalid JSON"}, status=400) 

    if not email or not password:
        return JsonResponse({"success": False, "error": "Email and password are required"}, status=400)

    if password != pass_repeat:
        return JsonResponse({"success": False,"error": "Passwords do not match"}, status=400)

    try:
        auth, db = _get_firebase()

        user = auth.create_user_with_email_and_password(email, password)
        uid = user.get("localId")
        idToken = user.get("idToken")

        #save profile in Realtime DB
        profile = {"name": name,"email": email,"uid": uid}

        db.child("users").child(uid).set(profile)

        request.session.flush()
        request.session["uid"] = uid
        request.session["idToken"] = idToken
        request.session["email"] = email

        return JsonResponse({"success": True, "message": "Account created successfully"})

    except Exception as e:
        return JsonResponse({"success": False,"error": "Account creation failed"}, status=400)
    
def upload_photo(request,uid):
    logger.info(f"upload_photo called by user: {uid}")
    if not uid:
        return JsonResponse({'error': 'User not authenticated'}, status=401)

    try:
        if not request.FILES.getlist('photo'):
            return JsonResponse({'error': 'No images uploaded'}, status=400)

        photo = request.FILES.getlist('photo')

        if photo.size > 5 * 1024 * 1024:
            return JsonResponse({'error': 'File size exceeds 5MB limit'}, status=400)
        
        photo_url = []

        for idx,photo in enumerate(photo):
            file_extension = os.path.splitext(photo.name)[1]

            photo_blob = bucket.blob(f"listings/{uid}/images/{int(time.time())}{file_extension}")
            photo_blob.upload_from_string(
                photo.read(),
                content_type=photo.content_type
            )
            photo_blob.make_public()
            photo_url.append(photo_blob.public_url)
            logger.info(f"Image {idx} uploaded to {photo_blob.public_url}")

            return {'success':True,'photo_url':photo_url}

    except Exception as e:
        logger.exception(f"Error uploading photo for user {uid}")
        return {'error': str(e), 'photo_url': None}


def upload_voice(request,uid):
    logger.info(f"upload_photo called by user: {uid}")

    try:
        if 'voice' not in request.FILES:
            return JsonResponse({'error': 'No file uploaded'}, status=400)

        voice_file = request.FILES['voice']

        voice_extension = os.path.splitext(voice_file.name)[1]

        voice_blob = bucket.blob(f"listings/{uid}/voice/{int(time.time())}{voice_extension}")
        voice_blob.upload_from_string(
            voice_file.read(),
            content_type=voice_file.content_type
        )
        voice_blob.make_public()
        voice_url = voice_blob.public_url
        logger.info(f"Voice uploaded to: {voice_url}")

        return {'success':True,'voice_url':voice_url}

    except Exception as e:
        logger.exception(f"Error uploading voice file for user {uid}")
        return {'error': str(e), 'voice_url': None}


@csrf_exempt
def generate_listing(request):
    if request.method != "POST":
        return JsonResponse({'error': "Invalid Request "}, status=500)
    
    uid = request.session.get('uid')

    if not uid:
        auth_header = request.header.get('Authorization','')
        if auth_header.startswith('Bearer '):
            id_token = auth_header.split('Bearer ')[1]
            try:
                decoded_token = admin_auth.verify_id_token(id_token)
                uid = decoded_token['uid']
            except Exception as e:
                logger.error(f"Verification failed",e)
                return JsonResponse({f"Error Invalid Token"}, status=401)
            

    try:
        photo_result = upload_photo(request,uid)
        if 'error' in photo_result and not photo_result.get('photo_url'):
            return JsonResponse({'error': photo_result['error']}, status=400)
        
        photo_urls = photo_result.get('photo_url',[])


        voice_result = upload_voice(request,uid)
        if 'error' in voice_result and not voice_result.get('voice_url'):
            return JsonResponse({'error': voice_result['error']}, status=400)
        voice_urls = voice_result.get('voice_url')

        listing_data = asyncio.run(
            generate_homestay_listing(
                uid=uid,
                voice_file=voice_urls,
                images=photo_urls
            )
        )

        ref = db.reference()
        listing_ref = ref.child(uid).child("listings").push(listing_data)
        listing_id = listing_ref.key()
        
        listing_data['listing_id'] = listing_id
        listing_data['created_at'] = int(time.time())
        listing_data['voice_url'] = voice_urls
        listing_data['image_urls'] = photo_urls

        ref.child(uid).child("listings").child(listing_id).update(listing_data)

        return JsonResponse({
            'success': True,
            'listing_id': listing_id,
            'listing': listing_data
        }, status=201)


    except Exception as e:
        logger.exception(f"Error generating listing for {uid}")
        return JsonResponse({'Error': str(e)},status=500)

