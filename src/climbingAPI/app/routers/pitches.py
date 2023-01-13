from typing import List

from fastapi import APIRouter, Body, Depends, HTTPException, Security, status
from fastapi.encoders import jsonable_encoder
from fastapi.responses import Response, JSONResponse
from fastapi_auth0 import Auth0User
from bson import ObjectId

from app.models.pitch_model import PitchModel
from app.models.update_pitch_model import UpdatePitchModel
from app.core.db import get_db
from app.core.auth import auth

router = APIRouter()


@router.post('/{route_id}', response_description="Add new pitch", response_model=PitchModel, dependencies=[Depends(auth.implicit_scheme)])
async def create_pitch(route_id: str, pitch: PitchModel = Body(...), user: Auth0User = Security(auth.get_user, scopes=["write:diary"])):
    db = await get_db()
    pitch = jsonable_encoder(pitch)
    new_pitch = await db["pitches"].insert_one(pitch)
    created_pitch = await db["pitches"].find_one({"_id": new_pitch.inserted_id})
    # add pitch to route
    update_result = await db["routes"].update_one({"_id": route_id}, {"$push": {"pitches": created_pitch["_id"]}})
    return JSONResponse(status_code=status.HTTP_201_CREATED, content=created_pitch)


@router.get('', response_description="List all pitches", response_model=List[PitchModel], dependencies=[Depends(auth.implicit_scheme)])
async def list_pitches(user: Auth0User = Security(auth.get_user, scopes=["read:diary"])):
    db = await get_db()
    pitches = await db["pitches"].find().to_list(1000)
    return pitches


@router.get('/{pitch_id}', response_description="Get a single pitch", response_model=PitchModel, dependencies=[Depends(auth.implicit_scheme)])
async def show_pitch(pitch_id: str, user: Auth0User = Security(auth.get_user, scopes=["read:diary"])):
    db = await get_db()
    if (pitch := await db["pitches"].find_one({"_id": pitch_id})) is not None:
        return pitch
    raise HTTPException(status_code=404, detail=f"Pitch {pitch_id} not found")


@router.put('/{pitch_id}', response_description="Update a pitch", response_model=PitchModel, dependencies=[Depends(auth.implicit_scheme)])
async def update_pitch(pitch_id: str, pitch: UpdatePitchModel = Body(...), user: Auth0User = Security(auth.get_user, scopes=["write:diary"])):
    db = await get_db()
    pitch = {k: v for k, v in pitch.dict().items() if v is not None}

    if len(pitch) >= 1:
        update_result = await db["pitches"].update_one({"_id": pitch_id}, {"$set": pitch})

        if update_result.modified_count == 1:
            if (
                updated_pitch := await db["pitches"].find_one({"_id": pitch_id})
            ) is not None:
                return updated_pitch

    if (existing_pitch := await db["pitches"].find_one({"_id": pitch_id})) is not None:
        return existing_pitch

    raise HTTPException(status_code=404, detail=f"Pitch {pitch_id} not found")


@router.delete('/{route_id}/{pitch-id}', response_description="Delete a pitch", dependencies=[Depends(auth.implicit_scheme)])
async def delete_pitch(route_id: str, pitch_id, user: Auth0User = Security(auth.get_user, scopes=["write:diary"])):
    # TODO check if remove from spot is necessary
    db = await get_db()
    delete_result = await db["pitches"].delete_one({"_id": pitch_id})
    update_result = await db["routes"].update_one({"_id": route_id}, {"$pull": {"pitches": pitch_id}})
    if delete_result.deleted_count == 1:
        return Response(status_code=status.HTTP_204_NO_CONTENT)

    raise HTTPException(status_code=404, detail=f"Pitch {pitch_id} not found")
