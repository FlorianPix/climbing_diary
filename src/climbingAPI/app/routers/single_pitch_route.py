from typing import List

from fastapi import APIRouter, Body, Depends, HTTPException, Security, status
from fastapi.encoders import jsonable_encoder
from fastapi.responses import Response, JSONResponse
from fastapi_auth0 import Auth0User
from bson import ObjectId

from app.core.db import get_db
from app.core.auth import auth

from app.models.single_pitch_route.single_pitch_route_model import SinglePitchRouteModel
from app.models.single_pitch_route.update_single_pitch_route_model import UpdateSinglePitchRouteModel
from app.models.spot.spot_model import SpotModel
from app.models.single_pitch_route.create_single_pitch_route_model import CreateSinglePitchRouteModel

router = APIRouter()


@router.post('/spot/{spot_id}', description="Create a new single pitch route", response_model=SinglePitchRouteModel, dependencies=[Depends(auth.implicit_scheme)])
async def create_route(spot_id: str, route: CreateSinglePitchRouteModel = Body(...), user: Auth0User = Security(auth.get_user, scopes=["write:diary"])):
    route = jsonable_encoder(route)
    route["user_id"] = user.id
    route["ascent_ids"] = []
    route["media_ids"] = []
    db = await get_db()
    spot = await db["spot"].find_one({"_id": ObjectId(spot_id), "user_id": user.id})
    if spot is None:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND,
                            detail=f"Spot {spot_id} not found")
    # spot was found
    if await db["single_pitch_route"].find({"user_id": user.id, "name": route["name"], "route_id": {"$in": spot["route_ids"]}}).to_list(None):
        raise HTTPException(status_code=status.HTTP_409_CONFLICT,
                            detail="Route already exists")
    # route does not already exist
    new_route = await db["single_pitch_route"].insert_one(route)
    # created route
    created_route = await db["single_pitch_route"].find_one({"_id": new_route.inserted_id})
    if created_route is None:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND,
                            detail=f"Route {new_route.inserted_id} not found")
    # route was found
    update_result = await db["spot"].update_one({"_id": ObjectId(spot_id)}, {"$push": {"route_ids": new_route.inserted_id}})
    if update_result.modified_count != 1:
        raise HTTPException(status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
                            detail=f"Route {new_route.inserted_id} was not added to spot {spot_id}")
    # route_id was added to spot
    return JSONResponse(status_code=status.HTTP_201_CREATED,
                        content=jsonable_encoder(SinglePitchRouteModel(**created_route)))


@router.get('', description="Retrieve all single pitch routes", response_model=List[SinglePitchRouteModel], dependencies=[Depends(auth.implicit_scheme)])
async def retrieve_routes(user: Auth0User = Security(auth.get_user, scopes=["read:diary"])):
    db = await get_db()
    routes = await db["single_pitch_route"].find({"user_id": user.id}).to_list(None)
    return routes


@router.get('/{route_id}', description="Retrieve a single pitch route", response_model=SinglePitchRouteModel, dependencies=[Depends(auth.implicit_scheme)])
async def retrieve_route(route_id: str, user: Auth0User = Security(auth.get_user, scopes=["read:diary"])):
    db = await get_db()
    if (route := await db["single_pitch_route"].find_one({"_id": ObjectId(route_id), "user_id": user.id})) is not None:
        return route
    raise HTTPException(status_code=status.HTTP_404_NOT_FOUND,
                        detail=f"Route {route_id} not found")


@router.put('/{route_id}', description="Update a single pitch route", response_model=SinglePitchRouteModel, dependencies=[Depends(auth.implicit_scheme)])
async def update_route(route_id: str, route: UpdateSinglePitchRouteModel = Body(...), user: Auth0User = Security(auth.get_user, scopes=["write:diary"])):
    db = await get_db()
    route = {k: v for k, v in route.dict().items() if v is not None}

    if len(route) >= 1:
        update_result = await db["single_pitch_route"].update_one({"_id": ObjectId(route_id)}, {"$set": route})

        if update_result.modified_count == 1:
            if (
                updated_route := await db["single_pitch_route"].find_one({"_id": ObjectId(route_id)})
            ) is not None:
                return updated_route

    if (existing_route := await db["single_pitch_route"].find_one({"_id": ObjectId(route_id)})) is not None:
        return existing_route

    raise HTTPException(status_code=status.HTTP_404_NOT_FOUND,
                        detail=f"Route {route_id} not found")


@router.delete('/{route_id}/spot/{spot_id}', response_model=SpotModel, description="Delete a single pitch route", dependencies=[Depends(auth.implicit_scheme)])
async def delete_route(spot_id: str, route_id: str, user: Auth0User = Security(auth.get_user, scopes=["write:diary"])):
    db = await get_db()
    spot = await db["spot"].find_one({"_id": ObjectId(spot_id), "user_id": user.id})
    if spot is None:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND,
                            detail=f"Spot {spot_id} not found")
    # spot was found
    route = await db["single_pitch_route"].find_one({"_id": ObjectId(route_id), "user_id": user.id})
    if route is None:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND,
                            detail=f"Route {route_id} not found")
    # route was found
    if await db["spot"].find_one({"_id": ObjectId(spot_id), "route_ids": ObjectId(route_id)}) is None:
        raise HTTPException(status_code=status.HTTP_409_CONFLICT,
                            detail=f"Route {route_id} does not belong to spot {spot_id}")
    # route belongs to spot
    delete_result = await db["ascent"].delete_many({"_id": {"$in": route["ascent_ids"]}})
    if delete_result.deleted_count != len(route["ascent_ids"]):
        raise HTTPException(status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
                            detail=f"Ascents could not be deleted")
    # all ascents were deleted
    delete_result = await db["single_pitch_route"].delete_one({"_id": ObjectId(route_id)})
    if not delete_result.acknowledged:
        raise HTTPException(status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
                            detail=f"Route {route_id} could not be deleted")
    # route was deleted
    update_result = await db["spot"].update_one({"_id": ObjectId(spot_id)}, {"$pull": {"route_ids": ObjectId(route_id)}})
    if update_result.modified_count != 1:
        raise HTTPException(status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
                            detail=f"Removing route_id {route_id} from spot {spot_id} failed")
    # route_id was removed
    if (updated_spot := await db["spot"].find_one({"_id": ObjectId(spot_id)})) is not None:
        return updated_spot
    else:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND,
                            detail=f"Spot {spot_id} not found")
