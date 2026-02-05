from django.contrib import admin
from django.urls import path
from . import views

#this file is the url router for the backend django server, pretty much how the front end talks to the backed

urlpatterns = [
    # path('admin/', admin.site.urls),
    path('', views.signIn, name='signIn'),
    path('signIn/', views.signIn, name='signIn'),
    path('postsignIn/', views.postsignIn, name='postsignIn'),
    path('signUp/', views.signUp, name='signUp'),
    path('postsignUp/', views.postsignUp, name='postsignUp'),
    path("google-login/", views.google_login, name="google_login"),
    path('logout/', views.logout, name='logout'),
    
    path('home/', views.home, name='home'),
    path('upload_photo/', views.upload_photo, name='upload_photo'),


]


