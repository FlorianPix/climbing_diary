from typing import List

from fastapi import APIRouter, Body, Depends, HTTPException, Security, status
from fastapi.encoders import jsonable_encoder
from fastapi.responses import Response, JSONResponse
from fastapi_auth0 import Auth0User
from bson import ObjectId

from app.core.db import get_db
from app.core.auth import auth

from app.models.spot.spot_model import SpotModel
from app.models.spot.create_spot_model import CreateSpotModel
from app.models.spot.update_spot_model import UpdateSpotModel
from app.models.route.route_model import RouteModel
from app.models.route.create_route_model import CreateRouteModel

router = APIRouter()


@router.post('', description="Add a new spot", response_model=SpotModel, dependencies=[Depends(auth.implicit_scheme)])
async def create_spot(spot: CreateSpotModel = Body(...), user: Auth0User = Security(auth.get_user, scopes=["write:diary"])):
    spot = jsonable_encoder(spot)
    spot["user_id"] = user.id
    spot["route_ids"] = []
    spot["media_ids"] = []

    db = await get_db()

    # check if spot already exists
    if (spots := await db["spot"].find({
        "name": spot["name"],
        "user_id": user.id,
        "coordinates.0": { "$gt": spot["coordinates"][0] - 0.001, "$lt": spot["coordinates"][0] + 0.001},
        "coordinates.1": { "$gt": spot["coordinates"][1] - 0.001, "$lt": spot["coordinates"][1] + 0.001},
    }).to_list(None)):
        raise HTTPException(status_code=status.HTTP_409_CONFLICT,
                            detail="Spot already exists")

    new_spot = await db["spot"].insert_one(spot)
    created_spot = await db["spot"].find_one({"_id": new_spot.inserted_id})
    return JSONResponse(status_code=status.HTTP_201_CREATED,
                        content=jsonable_encoder(SpotModel(**created_spot)))


@router.get('', description="Retrieve all spots", response_model=List[SpotModel], dependencies=[Depends(auth.implicit_scheme)])
async def retrieve_spots(user: Auth0User = Security(auth.get_user, scopes=["read:diary"])):
    db = await get_db()
    spots = await db["spot"].find({"user_id": user.id}).to_list(None)
    return spots


@router.get('/{spot_id}', description="Retrieve a spot", response_model=SpotModel, dependencies=[Depends(auth.implicit_scheme)])
async def retrieve_spot(spot_id: str, user: Auth0User = Security(auth.get_user, scopes=["read:diary"])):
    db = await get_db()
    if (spot := await db["spot"].find_one({"_id": ObjectId(spot_id), "user_id": user.id})) is not None:
        return spot
    raise HTTPException(status_code=status.HTTP_404_NOT_FOUND,
                        detail=f"Spot {spot_id} not found")


@router.put('/{spot_id}', description="Update a spot", response_model=SpotModel, dependencies=[Depends(auth.implicit_scheme)])
async def update_spot(spot_id: str, spot: UpdateSpotModel = Body(...), user: Auth0User = Security(auth.get_user, scopes=["write:diary"])):
    db = await get_db()
    spot = {k: v for k, v in spot.dict().items() if v is not None}

    if len(spot) >= 1:
        update_result = await db["spot"].update_one({"_id": ObjectId(spot_id)}, {"$set": spot})

        if update_result.modified_count == 1:
            if (
                updated_spot := await db["spot"].find_one({"_id": ObjectId(spot_id)})
            ) is not None:
                return updated_spot

    if (existing_spot := await db["spot"].find_one({"_id": ObjectId(spot_id)})) is not None:
        return existing_spot

    raise HTTPException(status_code=status.HTTP_404_NOT_FOUND,
                        detail=f"Spot {spot_id} not found")


@router.delete('/{spot_id}', description="Delete a spot", dependencies=[Depends(auth.implicit_scheme)])
async def delete_spot(spot_id: str, user: Auth0User = Security(auth.get_user, scopes=["write:diary"])):
    db = await get_db()
    spot = await db["spot"].find_one({"_id": ObjectId(spot_id), "user_id": user.id})
    if spot is None:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND,
                            detail=f"Spot {spot_id} not found")
    # spot was found
    routes = await db["route"].find({"_id": {"$in": spot.route_ids}})
    if routes is None:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND,
                            detail=f"Routes could not be found")
    # routes were found
    for route in routes:
        pitches = await db["pitch"].find({"_id": {"$in": route.pitch_ids}})
        if pitches is None:
            raise HTTPException(status_code=status.HTTP_404_NOT_FOUND,
                                detail=f"Pitches could not be found")
        # pitches were found
        for pitch in pitches:
            delete_result = await db["ascent"].delete_many({"_id": {"$in": pitch.ascent_ids}})
            if delete_result.deleted_count < 1:
                raise HTTPException(status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
                                    detail=f"Ascents could not be deleted")
            # all ascents of this pitch were deleted
        # all ascents of this route were deleted
        delete_result = await db["pitch"].delete_many({"_id": {"$in": route.pitch_ids}})
        if delete_result.deleted_count < 1:
            raise HTTPException(status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
                                detail=f"Pitches could not be deleted")
        # all pitches of this route were deleted
    # all pitches were deleted
    delete_result = await db["route"].delete_many({"_id": {"$in": spot.route_ids}})
    if delete_result.deleted_count < 1:
        raise HTTPException(status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
                            detail=f"Routes could not be deleted")
    # all routes were deleted
    delete_result = await db["spot"].delete_one({"_id": ObjectId(spot_id)})
    if delete_result.deleted_count != 1:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND,
                            detail=f"Spot {spot_id} not found")
    # spot was deleted
    return Response(status_code=status.HTTP_204_NO_CONTENT)


@router.post('/{spot_id}', description="Create a new route", response_model=RouteModel, dependencies=[Depends(auth.implicit_scheme)])
async def create_route(spot_id: str, route: CreateRouteModel = Body(...), user: Auth0User = Security(auth.get_user, scopes=["write:diary"])):
    route = jsonable_encoder(route)
    route["user_id"] = user.id
    route["pitch_ids"] = []
    route["media_ids"] = []
    db = await get_db()
    spot = await db["spot"].find_one({"_id": ObjectId(spot_id), "user_id": user.id})
    if spot is None:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND,
                            detail=f"Spot {spot_id} not found")
    # spot was found
    if (routes := await db["route"].find({"name": route["name"], "_id": {"$in": spot.route_ids}, "user_id": user.id})) is not None:
        raise HTTPException(status_code=status.HTTP_409_CONFLICT,
                            detail="Route already exists")
    # route does not already exist
    new_route = await db["route"].insert_one(route)
    # created route
    created_route = await db["route"].find_one({"_id": new_route.inserted_id})
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
                        content=jsonable_encoder(RouteModel(**created_route)))


@router.delete('/{spot_id}/route/{route_id}', response_model=SpotModel, description="Delete a route", dependencies=[Depends(auth.implicit_scheme)])
async def delete_route(spot_id: str, route_id: str, user: Auth0User = Security(auth.get_user, scopes=["write:diary"])):
    db = await get_db()
    spot = await db["spot"].find_one({"_id": ObjectId(spot_id), "user_id": user.id})
    if spot is None:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND,
                            detail=f"Spot {spot_id} not found")
    # spot was found
    route = await db["route"].find_one({"_id": ObjectId(route_id), "user_id": user.id})
    if route is None:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND,
                            detail=f"Route {route_id} not found")
    # route was found
    if await db["spot"].find_one({"_id": ObjectId(spot_id), "route_ids": {"$in": [route_id]}}) is None:
        raise HTTPException(status_code=status.HTTP_409_CONFLICT,
                            detail=f"Route {route_id} does not belong to spot {spot_id}")
    # route belongs to spot
    pitches = await db["pitch"].find({"_id": {"$in": route.pitch_ids}})
    if pitches is None:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND,
                            detail=f"Pitches could not be found")
    # pitches were found
    for pitch in pitches:
        delete_result = await db["ascent"].delete_many({"_id": {"$in": pitch.ascent_ids}})
        if delete_result.deleted_count < 1:
            raise HTTPException(status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
                                detail=f"Ascents could not be deleted")
    # all ascents were deleted
    delete_result = await db["pitch"].delete_many({"_id": {"$in": route.pitch_ids}})
    if delete_result.deleted_count < 1:
        raise HTTPException(status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
                            detail=f"Pitches could not be deleted")
    # all pitches were deleted
    delete_result = await db["route"].delete_one({"_id": ObjectId(route_id)})
    if delete_result.deleted_count != 1:
        raise HTTPException(status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
                            detail=f"Route {route_id} could not be deleted")
    # route was deleted
    update_result = await db["spot"].update_one({"_id": ObjectId(spot_id)}, {"$pull": {"route_ids": route_id}})
    if update_result.modified_count != 1:
        raise HTTPException(status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
                            detail=f"Removing route_id {route_id} from spot {spot_id} failed")
    # route_id was removed
    if (updated_spot := await db["spot"].find_one({"_id": ObjectId(spot_id)})) is not None:
        return updated_spot
    else:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND,
                            detail=f"Spot {spot_id} not found")
