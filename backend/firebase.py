import os
import firebase_admin
from firebase_admin import credentials, storage, db
from django.conf import settings

if not firebase_admin._apps:
    cred = credentials.Certificate(settings.FIREBASE_CONFIG["FIREBASE_SERVICE_ACCOUNT"])
    firebase_admin.initialize_app(cred, {
        "databaseURL": settings.FIREBASE_CONFIG['databaseURL'],
        "storageBucket": settings.FIREBASE_CONFIG['storageBucket'],
    })

