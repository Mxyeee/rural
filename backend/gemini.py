import requests
import os
import logging
from django.conf import settings


#from my prev project, cleaned it up a little, maybe can reuse, as for the api key, go to settings.py and at the bottom add the api key
api_key = settings.GEMINI_API_KEY

GEMINI_URL = f"https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent?key={api_key}"

def get_gemini_recommendation(data):
    try:
        prompt = ""
    
        headers = {"Content-Type": "application/json"}
        data = {"contents": [{"parts": [{"text": prompt}]}]}

        response = requests.post(GEMINI_URL, headers=headers, json=data)
        response_json = response.json()

        if "candidates" in response_json:
            recommendation_text = response_json["candidates"][0]["content"]["parts"][0]["text"]
            logger.info(f"Generated Recommendation: {recommendation_text}")
            return recommendation_text.strip()

        return "Error generating recommendation."

    except Exception as e:
        logger.error(f"Error generating recommendation: {e}")
        return "Error generating recommendation."