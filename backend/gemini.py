import logging
from django.conf import settings
import logging 
from google import genai
from google.genai import types
import json
from backend.schemas import ListingSchema
import requests

logger = logging.getLogger(__name__)

system_prompt = """
Role: You are an expert property copywriter specializing in rural tourism and homestays.
Task: Analyze the provided audio description and images of a property to create a professional, inviting homestay listing.
    You are not to assume any details that is not provided from the audio or images. 
    The user's inputs are always right, and do not try to provide inaccurate information.
JSON Schema:
{
    "title": "A catchy, market-friendly property name",
    "description": "2-3 paragraphs highlighting the unique charm and comfort of the stay.",
    "amenities": ["List all identified or logically assumed features like Wi-Fi, AC, etc."],
    "bedroom_count": Integer,
    "bathroom_count": Integer,
    "max_guests": Integer,
    "price_per_night": "Suggested range in local currency based on property size",
    "property_type": "Specific type (e.g., Traditional Cottage, Modern Farmhouse)",
    "highlights": ["3-5 key selling points"],
    "rules": ["Standard homestay rules plus any specific to rural settings"],
    "check_in": "Standard instructions (default to 2:00 PM if unspecified)",
    "check_out": "Standard instructions (default to 12:00 PM if unspecified)"
}

Tone: Ensure tone is always professional yet warm and welcoming
Output Format: Return ONLY a raw JSON object. Do not include markdown formatting like ```json
"""

async def generate_homestay_listing(uid,voice_url,image_url):
    try:
        client = genai.Client(api_key=settings.GEMINI_API_KEY)
        content = [system_prompt]
        #prepare image 
        for image in image_url:
            response = requests.get(image)
            image_data = response.content
            content.append(
                types.Part.from_bytes(
                    data=image_data,
                    mime_type="image/jpeg"
                )
            )   
        #prepare voice files
        voice_response = requests.get(voice_url)
        voice_data = voice_response.content
        content.append(
            types.Part.from_bytes(
                data=voice_data,
                mime_type="audio/mpeg"
            )
        )
        
        response = await client.aio.models.generate_content(
            model="gemini-2.5-flash",
            contents=content
            )

        if not response.text:
            logger.error(f"Empty response from Gemini for user {uid}")
            return {"error":"Failed to generate listing"}
        
        logger.info(f"Generated listing for user {uid}")

        listing = json.loads(response.text)
        validated_listing = ListingSchema(**listing) 

        return validated_listing.model_dump()

    except Exception as e:
        logger.error(f"Error in generate_homestay_listing: {e}")
        raise
        




