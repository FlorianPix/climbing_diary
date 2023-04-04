from typing import List

from fastapi import APIRouter, Body, Depends, HTTPException, Security, status
from fastapi.encoders import jsonable_encoder
from fastapi.responses import Response, JSONResponse
from fastapi_auth0 import Auth0User
from bson import ObjectId

from app.core.db import get_db
from app.core.auth import auth

from app.models.route.route_model import RouteModel
from app.models.route.update_route_model import UpdateRouteModel
from app.models.pitch.pitch_model import PitchModel
from app.models.pitch.create_pitch_model import CreatePitchModel

router = APIRouter()


@router.get('', description="Retrieve all routes", response_model=List[RouteModel], dependencies=[Depends(auth.implicit_scheme)])
async def retrieve_routes(user: Auth0User = Security(auth.get_user, scopes=["read:diary"])):
    db = await get_db()
    routes = await db["route"].find({"user_id": user.id}).to_list(None)
    return routes


@router.get('/{route_id}', description="Retrieve a route", response_model=RouteModel, dependencies=[Depends(auth.implicit_scheme)])
async def retrieve_route(route_id: str, user: Auth0User = Security(auth.get_user, scopes=["read:diary"])):
    db = await get_db()
    if (route := await db["route"].find_one({"_id": ObjectId(route_id), "user_id": user.id})) is not None:
        return route
    raise HTTPException(status_code=status.HTTP_404_NOT_FOUND,
                        detail=f"Route {route_id} not found")


@router.put('/{route_id}', description="Update a route", response_model=RouteModel, dependencies=[Depends(auth.implicit_scheme)])
async def update_route(route_id: str, route: UpdateRouteModel = Body(...), user: Auth0User = Security(auth.get_user, scopes=["write:diary"])):
    db = await get_db()
    route = {k: v for k, v in route.dict().items() if v is not None}

    if len(route) >= 1:
        update_result = await db["route"].update_one({"_id": ObjectId(route_id)}, {"$set": route})

        if update_result.modified_count == 1:
            if (
                updated_route := await db["route"].find_one({"_id": ObjectId(route_id)})
            ) is not None:
                return updated_route

    if (existing_route := await db["route"].find_one({"_id": ObjectId(route_id)})) is not None:
        return existing_route

    raise HTTPException(status_code=status.HTTP_404_NOT_FOUND,
                        detail=f"Route {route_id} not found")


@router.post('/{route_id}', description="Create a new pitch", response_model=PitchModel, dependencies=[Depends(auth.implicit_scheme)])
async def create_pitch(route_id: str, pitch: CreatePitchModel = Body(...), user: Auth0User = Security(auth.get_user, scopes=["write:diary"])):
    pitch = jsonable_encoder(pitch)
    pitch["user_id"] = user.id
    pitch["ascent_ids"] = []
    pitch["media_ids"] = []
    db = await get_db()
    new_pitch = await db["pitch"].insert_one(pitch)
    # created pitch
    created_pitch = await db["pitch"].find_one({"_id": new_pitch.inserted_id})
    if created_pitch is None:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND,
                            detail=f"Pitch {new_pitch.inserted_id} not found")
    # pitch was found
    update_result = await db["route"].update_one({"_id": ObjectId(route_id)}, {"$push": {"pitch_ids": new_pitch.inserted_id}})
    if update_result.modified_count != 1:
        raise HTTPException(status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
                            detail=f"Pitch {new_pitch.inserted_id} was not added to route {route_id}")
    # pitch_id was added to route
    return JSONResponse(status_code=status.HTTP_201_CREATED,
                        content=jsonable_encoder(PitchModel(**created_pitch)))


@router.delete('/{route_id}/pitch/{pitch_id}', description="Delete a pitch", response_model=RouteModel, dependencies=[Depends(auth.implicit_scheme)])
async def delete_pitch(route_id: str, pitch_id: str, user: Auth0User = Security(auth.get_user, scopes=["write:diary"])):
    db = await get_db()
    route = await db["route"].find_one({"_id": ObjectId(route_id), "user_id": user.id})
    if route is None:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND,
                            detail=f"Route {route_id} not found")
    # route was found
    pitch = await db["pitch"].find_one({"_id": ObjectId(pitch_id), "user_id": user.id})
    if pitch is None:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND,
                            detail=f"Pitch {pitch_id} not found")
    # pitch was found
    if await db["route"].find_one({"_id": ObjectId(route_id), "pitch_ids": {"$in": [pitch_id]}}) is None:
        raise HTTPException(status_code=status.HTTP_409_CONFLICT,
                            detail=f"Pitch {pitch_id} does not belong to route {route_id}")
    # pitch belongs to route
    delete_result = await db["ascent"].delete_many({"_id": {"$in": pitch.ascent_ids}})
    if delete_result.deleted_count < 1:
        raise HTTPException(status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
                            detail=f"Ascents could not be deleted")
    # all ascents were deleted
    delete_result = await db["pitch"].delete_one({"_id": ObjectId(pitch_id)})
    if delete_result.deleted_count != 1:
        raise HTTPException(status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
                            detail=f"Pitch {pitch_id} could not be deleted")
    # pitch was deleted
    update_result = await db["route"].update_one({"_id": ObjectId(route_id)}, {"$pull": {"pitch_ids": pitch_id}})
    if update_result.modified_count != 1:
        raise HTTPException(status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
                            detail=f"Removing pitch_id {pitch_id} from route {route_id} failed")
    # pitch_id was removed
    if (updated_route := await db["route"].find_one({"_id": ObjectId(route_id)})) is not None:
        return updated_route
    else:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND,
                            detail=f"Route {route_id} not found")
