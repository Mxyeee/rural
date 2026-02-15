import asyncio
import os
import sys
import django
import json
from backend.gemini import generate_homestay_listing
from django.core.files.uploadedfile import SimpleUploadedFile

os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'backend.settings')
django.setup()

BASE_DIR = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
async def test():

    audio_path = os.path.join(BASE_DIR, "example", "test_audio.mp4")
    image_path = os.path.join(BASE_DIR, "example", "test_image.jpeg")

    with open(audio_path,"rb") as f:
        voice_file = SimpleUploadedFile(
            name="sample.mp4",
            content=f.read(),
            content_type="audio/mpeg"
        )


    with open(image_path, "rb") as f:
        image_file = SimpleUploadedFile(
            name="sample.jpg",
            content=f.read(),
            content_type="image/jpeg"
        )

    result = await generate_homestay_listing(
        uid="user_1",
        voice_file=voice_file,
        images=[image_file]
    )

    print(json.dumps(result,indent=2))

if __name__ == "__main__":
    asyncio.run(test())