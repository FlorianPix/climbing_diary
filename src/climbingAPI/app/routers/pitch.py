from typing import List

from fastapi import APIRouter, Body, Depends, HTTPException, Security, status
from fastapi.encoders import jsonable_encoder
from fastapi.responses import Response, JSONResponse
from fastapi_auth0 import Auth0User
from bson import ObjectId

from app.core.db import get_db
from app.core.auth import auth

from app.models.pitch.pitch_model import PitchModel
from app.models.pitch.create_pitch_model import CreatePitchModel
from app.models.pitch.update_pitch_model import UpdatePitchModel

router = APIRouter()


@router.post('', description="Add a new pitch", response_model=PitchModel, dependencies=[Depends(auth.implicit_scheme)])
async def create_pitch(pitch: CreatePitchModel = Body(...), user: Auth0User = Security(auth.get_user, scopes=["write:diary"])):
    pitch = jsonable_encoder(pitch)
    pitch["user_id"] = user.id
    pitch["ascent_ids"] = []
    pitch["media_ids"] = []
    db = await get_db()
    new_pitch = await db["pitch"].insert_one(pitch)
    created_pitch = await db["pitch"].find_one({"_id": new_pitch.inserted_id})
    return JSONResponse(status_code=status.HTTP_201_CREATED, content=jsonable_encoder(PitchModel(**created_pitch)))


@router.get('', description="Retrieve all pitches", response_model=List[PitchModel], dependencies=[Depends(auth.implicit_scheme)])
async def retrieve_pitches(user: Auth0User = Security(auth.get_user, scopes=["read:diary"])):
    db = await get_db()
    pitches = await db["pitch"].find({"user_id": user.id}).to_list(None)
    return pitches


@router.get('/{pitch_id}', description="Retrieve a pitch", response_model=PitchModel, dependencies=[Depends(auth.implicit_scheme)])
async def retrieve_pitch(pitch_id: str, user: Auth0User = Security(auth.get_user, scopes=["read:diary"])):
    db = await get_db()
    if (pitch := await db["pitch"].find_one({"_id": ObjectId(pitch_id), "user_id": user.id})) is not None:
        return pitch
    raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail=f"Pitch {pitch_id} not found")


@router.put('/{pitch_id}', description="Update a pitch", response_model=PitchModel, dependencies=[Depends(auth.implicit_scheme)])
async def update_pitch(pitch_id: str, pitch: UpdatePitchModel = Body(...), user: Auth0User = Security(auth.get_user, scopes=["write:diary"])):
    db = await get_db()
    pitch = {k: v for k, v in pitch.dict().items() if v is not None}

    if len(pitch) >= 1:
        update_result = await db["pitch"].update_one({"_id": ObjectId(pitch_id)}, {"$set": pitch})

        if update_result.modified_count == 1:
            if (
                updated_pitch := await db["pitch"].find_one({"_id": ObjectId(pitch_id)})
            ) is not None:
                return updated_pitch

    if (existing_pitch := await db["pitch"].find_one({"_id": ObjectId(pitch_id)})) is not None:
        return existing_pitch

    raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail=f"Pitch {pitch_id} not found")


@router.delete('/{pitch_id}', description="Delete a pitch", dependencies=[Depends(auth.implicit_scheme)])
async def delete_pitch(pitch_id: str, user: Auth0User = Security(auth.get_user, scopes=["write:diary"])):
    db = await get_db()
    existing_pitch = await db["pitch"].find_one({"_id": ObjectId(pitch_id), "user_id": user.id,})

    if existing_pitch is None:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail=f"Pitch {pitch_id} not found")

    delete_result = await db["pitch"].delete_one({"_id": ObjectId(pitch_id)})

    if delete_result.deleted_count == 1:
        return Response(status_code=status.HTTP_204_NO_CONTENT)

    raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail=f"Pitch {pitch_id} not found")
