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
from firebase_admin import db as admin_db

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

#helper function for photo upload
def handle_photo_upload(uid,photos):
    photo_urls = []

    for idx, photo in enumerate(photos):
        if photo.size > 5 * 1024 * 1024:
            return JsonResponse({'error': f'File {photo.name} exceeds 5MB limit'}, status=400)

        file_extension = os.path.splitext(photo.name)[1]

        photo_blob = bucket.blob(f"listings/{uid}/images/{int(time.time())}_{idx}{file_extension}")
        photo_blob.upload_from_string(
            photo.read(),
            content_type=photo.content_type
        )
        photo_blob.make_public()
        photo_urls.append(photo_blob.public_url)
        logger.info(f"Uploaded image {idx} to {photo_blob.public_url}")

    return photo_urls


def handle_upload_voice(uid,voice_file):
    voice_extension = os.path.splitext(voice_file.name)[1]
    voice_blob = bucket.blob(f"listings/{uid}/voice/{int(time.time())}{voice_extension}")
    voice_blob.upload_from_string(
        voice_file.read(),
        content_type=voice_file.content_type
    )
    voice_blob.make_public()
    voice_url = voice_blob.public_url
    return voice_url


@csrf_exempt
def upload_photo(request):
    if request.method != "POST":
        return JsonResponse({"error": "Only POST allowed"}, status=405)
    try:
        uid = request.POST.get("uid")
        photos = request.FILES.getlist('photo')
        urls = handle_photo_upload(uid,photos)
        return JsonResponse({"success":True,"photo_url":urls})
    except Exception as e:
        return JsonResponse({'success': False, 'error': str(e)}, status=500)
    
@csrf_exempt
def upload_voice(request):
    if request.method != "POST":
        return JsonResponse({"error": "Only POST allowed"}, status=405)
    
    try:
        uid = request.POST.get("uid")
        voice_file = request.FILES.get('voice')
        url = handle_upload_voice(uid,voice_file)
        return JsonResponse({"success":True,"photo_url":url})
    except Exception as e:
        return JsonResponse({'success': False, 'error': str(e)}, status=500)

@csrf_exempt
def generate_listing(request):
    if request.method != "POST":
        return JsonResponse({'error': "Invalid Request "}, status=500)
    
    # uid = request.session.get('uid')
    auth_header = request.headers.get('Authorization','')
    uid = None

    if auth_header.startswith('Bearer '):
        id_token = auth_header.split('Bearer ')[1]
        try:
            decoded_token = admin_auth.verify_id_token(id_token)
            uid = decoded_token['uid']
        except Exception as e:
            logger.error(f"Verification failed",e)
            return JsonResponse({"error":"Invalid Token"}, status=401)
        
    if not uid: 
        return JsonResponse({"error":"Authentication required, UID missing"},status=401)
            
    try:
        photos = request.FILES.getlist('photo')
        voice_file = request.FILES.get('voice')
        
        if not photos or not voice_file:
            return JsonResponse({'error': 'Both photos and voice recording are required'}, status=400)

        photo_urls = handle_photo_upload(uid, photos)
        voice_urls = handle_upload_voice(uid,voice_file)

        listing_data = asyncio.run(
            generate_homestay_listing(
                uid=uid,
                voice_url=voice_urls,
                image_url=photo_urls
            )
        )

        ref = admin_db.reference(f"users/{uid}/listings")
        listing_ref = ref.push(listing_data)
        listing_id = listing_ref.key


        
        final_data = {
            **listing_data,
            'listing_id':listing_id,
            'created_at':int(time.time()),
            'voice_url': voice_urls,
            'photo_urls': photo_urls
        }
        
        admin_db.reference(f"users/{uid}/listings/{listing_id}").set(final_data)

        return JsonResponse({
            'success': True,
            'listing_id': listing_id,
            'listing': listing_data,
            'photo_urls':photo_urls
        }, status=201)


    except Exception as e:
        logger.exception(f"Error generating listing for {uid}")
        return JsonResponse({'Error': str(e)},status=500)
    

@csrf_exempt
def get_user_photos(request):
    if request.method != "POST":
        return JsonResponse({"error": "Only POST allowed"}, status=405)

    try:
        uid = request.POST.get("uid")
        if not uid:
            return JsonResponse({"error": "UID is required"}, status=400)

        prefix = f"listings/{uid}/images/"
        blobs = bucket.list_blobs(prefix=prefix)

        photo_urls = [blob.public_url for blob in blobs]

        return JsonResponse({
            "success": True,
            "photo_urls": photo_urls
        })

    except Exception as e:
        return JsonResponse({
            "success": False,
            "error": str(e)
        }, status=500)
    
@csrf_exempt
def get_user_listings(request):
    auth_header = request.headers.get('Authorization', '')
    uid = None

    if auth_header.startswith('Bearer '):
        id_token = auth_header.split('Bearer ')[1]
        try:
            decoded_token = admin_auth.verify_id_token(id_token)
            uid = decoded_token['uid']
        except Exception as e:
            return JsonResponse({"error": "Invalid token"}, status=401)

    if not uid:
        return JsonResponse({"error": "Authentication required"}, status=401)

    try:
        ref = admin_db.reference(f"users/{uid}/listings")
        listings = ref.get()
        return JsonResponse({"success": True, "listings": listings or {}}, status=200)
    except Exception as e:
        return JsonResponse({"error": str(e)}, status=500)