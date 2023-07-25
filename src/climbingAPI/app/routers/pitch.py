import datetime
from typing import List

from fastapi import APIRouter, Body, Depends, HTTPException, Security, status
from fastapi.encoders import jsonable_encoder
from fastapi.responses import Response, JSONResponse
from fastapi_auth0 import Auth0User
from bson import ObjectId

from app.core.db import get_db
from app.core.auth import auth

from app.models.pitch.pitch_model import PitchModel
from app.models.pitch.update_pitch_model import UpdatePitchModel
from app.models.route.route_model import RouteModel
from app.models.pitch.create_pitch_model import CreatePitchModel

router = APIRouter()


@router.post('/route/{route_id}', description="Create a new pitch", response_model=PitchModel, dependencies=[Depends(auth.implicit_scheme)])
async def create_pitch(route_id: str, pitch: CreatePitchModel = Body(...), user: Auth0User = Security(auth.get_user, scopes=["write:diary"])):
    pitch = jsonable_encoder(pitch)
    pitch["user_id"] = user.id
    pitch["ascent_ids"] = []
    pitch["media_ids"] = []
    pitch["updated"] = datetime.datetime.now()
    db = await get_db()
    route = await db["multi_pitch_route"].find_one({"_id": ObjectId(route_id), "user_id": user.id})
    if route is None:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail=f"Route {route_id} not found")
    # route exists
    if await db["pitch"].find({"user_id": user.id, "name": pitch["name"]}).to_list(None):
        raise HTTPException(status_code=status.HTTP_409_CONFLICT, detail="Pitch already exists")
    # pitch does not already exist
    new_pitch = await db["pitch"].insert_one(pitch)
    # created pitch
    created_pitch = await db["pitch"].find_one({"_id": new_pitch.inserted_id})
    if created_pitch is None:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND,
                            detail=f"Pitch {new_pitch.inserted_id} not found")
    # pitch was found
    update_result = await db["multi_pitch_route"].update_one({"_id": ObjectId(route_id)}, {"$push": {"pitch_ids": new_pitch.inserted_id}})
    if update_result.modified_count != 1:
        raise HTTPException(status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
                            detail=f"Pitch {new_pitch.inserted_id} was not added to route {route_id}")
    # pitch_id was added to route
    return JSONResponse(status_code=status.HTTP_201_CREATED,
                        content=jsonable_encoder(PitchModel(**created_pitch)))


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
    raise HTTPException(status_code=status.HTTP_404_NOT_FOUND,
                        detail=f"Pitch {pitch_id} not found")


@router.put('/{pitch_id}', description="Update a pitch", response_model=PitchModel, dependencies=[Depends(auth.implicit_scheme)])
async def update_pitch(pitch_id: str, pitch: UpdatePitchModel = Body(...), user: Auth0User = Security(auth.get_user, scopes=["write:diary"])):
    db = await get_db()
    pitch = {k: v for k, v in pitch.dict().items() if v is not None}
    if 'grade' in pitch.keys():
        if 'system' in pitch['grade'].keys():
            pitch['grade']['system'] = pitch['grade']['system'].value

    if len(pitch) >= 1:
        update_result = await db["pitch"].update_one({"_id": ObjectId(pitch_id)}, {"$set": pitch})

        if update_result.modified_count == 1:
            if (
                updated_pitch := await db["pitch"].find_one({"_id": ObjectId(pitch_id)})
            ) is not None:
                return updated_pitch

    if (existing_pitch := await db["pitch"].find_one({"_id": ObjectId(pitch_id)})) is not None:
        return existing_pitch

    raise HTTPException(status_code=status.HTTP_404_NOT_FOUND,
                        detail=f"Pitch {pitch_id} not found")


@router.delete('/{pitch_id}/route/{route_id}', description="Delete a pitch", response_model=PitchModel, dependencies=[Depends(auth.implicit_scheme)])
async def delete_pitch(route_id: str, pitch_id: str, user: Auth0User = Security(auth.get_user, scopes=["write:diary"])):
    db = await get_db()
    route = await db["multi_pitch_route"].find_one({"_id": ObjectId(route_id), "user_id": user.id})
    if route is None:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND,
                            detail=f"Route {route_id} not found")
    # route was found
    pitch = await db["pitch"].find_one({"_id": ObjectId(pitch_id), "user_id": user.id})
    if pitch is None:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND,
                            detail=f"Pitch {pitch_id} not found")
    # pitch was found
    if await db["multi_pitch_route"].find_one({"_id": ObjectId(route_id), "pitch_ids": ObjectId(pitch_id)}) is None:
        raise HTTPException(status_code=status.HTTP_409_CONFLICT,
                            detail=f"Pitch {pitch_id} does not belong to route {route_id}")
    # pitch belongs to route
    delete_result = await db["ascent"].delete_many({"_id": {"$in": pitch["ascent_ids"]}})
    if not delete_result.acknowledged:
        raise HTTPException(status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
                            detail=f"Ascents could not be deleted")
    # all ascents were deleted
    delete_result = await db["pitch"].delete_one({"_id": ObjectId(pitch_id)})
    if delete_result.deleted_count != 1:
        raise HTTPException(status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
                            detail=f"Pitch {pitch_id} could not be deleted")
    # pitch was deleted
    update_result = await db["multi_pitch_route"].update_one({"_id": ObjectId(route_id)}, {"$pull": {"pitch_ids": ObjectId(pitch_id)}})
    if update_result.modified_count != 1:
        raise HTTPException(status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
                            detail=f"Removing pitch_id {pitch_id} from route {route_id} failed")
    # pitch_id was removed
    if (updated_route := await db["multi_pitch_route"].find_one({"_id": ObjectId(route_id)})) is not None:
        return pitch
    else:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND,
                            detail=f"Route {route_id} not found")
