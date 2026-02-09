from pydantic import BaseModel
from typing import List


class ListingSchema(BaseModel):
    title: str
    description: str
    amenities: List[str]
    bedroom_count: int 
    bathroom_count: int 
    max_guests: int
    price_per_night: str
    property_type: str
    highlights: List[str]
    rules: List[str]
    check_in: str
    check_out: str