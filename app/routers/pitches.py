from typing import List

from fastapi import APIRouter, Body, HTTPException, status
from fastapi.encoders import jsonable_encoder
from fastapi.responses import Response, JSONResponse

from .models.pitch_model import PitchModel
from .models.update_pitch_model import UpdatePitchModel

import os
import motor.motor_asyncio

router = APIRouter()
client = motor.motor_asyncio.AsyncIOMotorClient(os.environ["MONGODB_URL"])
db = client.climbing


@router.post("/pitch", response_description="Add new pitch", response_model=PitchModel)
async def create_pitch(pitch: PitchModel = Body(...)):
    pitch = jsonable_encoder(pitch)
    new_pitch = await db["pitches"].insert_one(pitch)
    created_pitch = await db["pitches"].find_one({"_id": new_pitch.inserted_id})
    # add pitch to route
    update_result = await db["routes"].update_one({"_id": created_pitch["route_id"]}, {"$push": {"pitches": pitch}})
    return JSONResponse(status_code=status.HTTP_201_CREATED, content=created_pitch)


@router.get("/pitches", response_description="List all pitches", response_model=List[PitchModel])
async def list_pitches():
    pitches = await db["pitches"].find().to_list(1000)
    return pitches


@router.get("/pitch-{id}", response_description="Get a single pitch", response_model=PitchModel)
async def show_pitch(id: str):
    if (pitch := await db["pitches"].find_one({"_id": id})) is not None:
        return pitch
    raise HTTPException(status_code=404, detail=f"Pitch {id} not found")


@router.put("/pitch-{id}", response_description="Update a pitch", response_model=PitchModel)
async def update_pitch(id: str, pitch: UpdatePitchModel = Body(...)):
    pitch = {k: v for k, v in pitch.dict().items() if v is not None}

    if len(pitch) >= 1:
        update_result = await db["pitches"].update_one({"_id": id}, {"$set": pitch})

        if update_result.modified_count == 1:
            if (
                updated_pitch := await db["pitches"].find_one({"_id": id})
            ) is not None:
                return updated_pitch

    if (existing_pitch := await db["pitches"].find_one({"_id": id})) is not None:
        return existing_pitch

    raise HTTPException(status_code=404, detail=f"Pitch {id} not found")


@router.delete("/pitch-{id}", response_description="Delete a pitch")
async def delete_pitch(id: str):
    delete_result = await db["pitches"].delete_one({"_id": id})

    if delete_result.deleted_count == 1:
        return Response(status_code=status.HTTP_204_NO_CONTENT)

    raise HTTPException(status_code=404, detail=f"Pitch {id} not found")
