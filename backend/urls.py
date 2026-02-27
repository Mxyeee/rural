from django.contrib import admin
from django.urls import path
from . import views

#this file is the url router for the backend django server, pretty much how the front end talks to the backed

urlpatterns = [
    # path('admin/', admin.site.urls),
    path('postsignIn/', views.postsignIn, name='postsignIn'),
    path('postsignUp/', views.postsignUp, name='postsignUp'),
    path("google-login/", views.google_login, name="google_login"),
    path('upload_photo/', views.upload_photo, name='upload_photo'),  # ADD THIS
    path('upload_voice/', views.upload_voice, name='upload_voice'),  # ADD THIS
    path('generate_listing/', views.generate_listing, name='generate_listing'),
    path('get_user_photos/', views.get_user_photos, name='get_user_photos'),
    path('listings/', views.get_user_listings, name='get_user_listings'),
]


