import datetime
from typing import List

from fastapi import APIRouter, Body, Depends, HTTPException, Security, status
from fastapi.encoders import jsonable_encoder
from fastapi.responses import JSONResponse
from fastapi_auth0 import Auth0User

from app.core.db import get_db
from app.core.auth import auth

from app.models.spot.spot_model import SpotModel
from app.models.multi_pitch_route.multi_pitch_route_model import MultiPitchRouteModel
from app.models.multi_pitch_route.update_multi_pitch_route_model import UpdateMultiPitchRouteModel

router = APIRouter()


@router.post('/spot/{spot_id}', description="Create a new multi pitch route", response_model=MultiPitchRouteModel, dependencies=[Depends(auth.implicit_scheme)])
async def create_route(spot_id: str, route: MultiPitchRouteModel = Body(...), user: Auth0User = Security(auth.get_user, scopes=["write:diary"])):
    route = jsonable_encoder(route)
    route["user_id"] = user.id
    if not route["pitch_ids"]: route["pitch_ids"] = []
    if not route["media_ids"]: route["media_ids"] = []
    route["updated"] = datetime.datetime.now()
    db = await get_db()
    spot = await db["spot"].find_one({"_id": spot_id, "user_id": user.id})
    if spot is None:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail=f"Spot {spot_id} not found")
    # spot was found
    existing_routes = []
    for route_id in spot['multi_pitch_route_ids']:
        if (existing_route := await db["multi_pitch_route"].find_one({"_id": route_id, "user_id": user.id})) is not None:
            existing_routes.append(existing_route)
    for existing_route in existing_routes:
        if existing_route['name'] == route['name']:
            raise HTTPException(status_code=status.HTTP_409_CONFLICT, detail="Route already exists")
    # route does not already exist
    new_route = await db["multi_pitch_route"].insert_one(route)
    # created route
    created_route = await db["multi_pitch_route"].find_one({"_id": new_route.inserted_id})
    if created_route is None:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail=f"Route {new_route.inserted_id} not found")
    # route was found
    update_result = await db["spot"].update_one(
        {"_id": spot_id},
        {
            "$set": {"updated": datetime.datetime.now()},
            "$push": {"multi_pitch_route_ids": new_route.inserted_id}
        }
    )
    if update_result.modified_count != 1:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Route {new_route.inserted_id} was not added to spot {spot_id}"
        )
    # route_id was added to spot
    return JSONResponse(
        status_code=status.HTTP_201_CREATED,
        content=jsonable_encoder(MultiPitchRouteModel(**created_route))
    )


@router.get('/{route_id}', description="Retrieve a multi pitch route", response_model=MultiPitchRouteModel, dependencies=[Depends(auth.implicit_scheme)])
async def retrieve_route_of_id(route_id: str, user: Auth0User = Security(auth.get_user, scopes=["read:diary"])):
    db = await get_db()
    if (route := await db["multi_pitch_route"].find_one({"_id": route_id, "user_id": user.id})) is not None:
        return route
    raise HTTPException(
        status_code=status.HTTP_404_NOT_FOUND,
        detail=f"Route {route_id} not found"
    )


@router.post('/ids', description="Get routes of ids", response_model=List[MultiPitchRouteModel], dependencies=[Depends(auth.implicit_scheme)])
async def retrieve_routes_of_ids(route_ids: List[str] = Body(...), user: Auth0User = Security(auth.get_user, scopes=["read:diary"])):
    if not route_ids: return []
    db = await get_db()
    routes = []
    for route_id in route_ids:
        if (route := await db["multi_pitch_route"].find_one({"_id": route_id, "user_id": user.id})) is not None:
            routes.append(route)
        else:
            raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail=f"Route {route_id} not found")
    if routes: return routes
    raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail=f"Routes not found")


@router.get('', description="Retrieve all multi pitch routes", response_model=List[MultiPitchRouteModel], dependencies=[Depends(auth.implicit_scheme)])
async def retrieve_all_routes(user: Auth0User = Security(auth.get_user, scopes=["read:diary"])):
    db = await get_db()
    routes = await db["multi_pitch_route"].find({"user_id": user.id}).to_list(None)
    return routes


@router.put('/{route_id}', description="Update a multi pitch route", response_model=MultiPitchRouteModel, dependencies=[Depends(auth.implicit_scheme)])
async def update_route(route_id: str, route: UpdateMultiPitchRouteModel = Body(...), user: Auth0User = Security(auth.get_user, scopes=["write:diary"])):
    db = await get_db()
    route = {k: v for k, v in route.dict().items() if v is not None}
    route['updated'] = datetime.datetime.now()
    if len(route) >= 1:
        update_result = await db["multi_pitch_route"].update_one({"_id": route_id}, {"$set": route})
        if update_result.modified_count == 1:
            if (updated_route := await db["multi_pitch_route"].find_one({"_id": route_id})) is not None:
                return updated_route
    if (existing_route := await db["multi_pitch_route"].find_one({"_id": route_id})) is not None:
        return existing_route
    raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail=f"Route {route_id} not found")


@router.delete('/{route_id}/spot/{spot_id}', response_model=SpotModel, description="Delete a multi pitch route", dependencies=[Depends(auth.implicit_scheme)])
async def delete_route(spot_id: str, route_id: str, user: Auth0User = Security(auth.get_user, scopes=["write:diary"])):
    db = await get_db()
    spot = await db["spot"].find_one({"_id": spot_id, "user_id": user.id})
    if spot is None:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail=f"Spot {spot_id} not found")
    # spot was found
    route = await db["multi_pitch_route"].find_one({"_id": route_id, "user_id": user.id})
    if route is None:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND,
                            detail=f"Route {route_id} not found")
    # route was found
    if await db["spot"].find_one({"_id": spot_id, "multi_pitch_route_ids": route_id}) is None:
        raise HTTPException(
            status_code=status.HTTP_409_CONFLICT,
            detail=f"Route {route_id} does not belong to spot {spot_id}"
        )
    # route belongs to spot
    pitches = await db["pitch"].find({"_id": {"$in": route["pitch_ids"]}}).to_list(None)
    if pitches is None:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail=f"Pitches could not be found")
    # pitches were found
    for pitch in pitches:
        if not pitch["ascent_ids"]: continue
        delete_result = await db["ascent"].delete_many({"_id": {"$in": pitch["ascent_ids"]}})
        if delete_result.deleted_count < 1:
            raise HTTPException(
                status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
                detail=f"Ascents could not be deleted"
            )
    # all ascents were deleted
    delete_result = await db["pitch"].delete_many({"_id": {"$in": route["pitch_ids"]}})
    if not delete_result.acknowledged:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Pitches could not be deleted"
        )
    # all pitches were deleted
    delete_result = await db["multi_pitch_route"].delete_one({"_id": route_id})
    if not delete_result.acknowledged:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Route {route_id} could not be deleted"
        )
    # route was deleted
    update_result = await db["spot"].update_one({"_id": spot_id}, {"$set": {"updated": datetime.datetime.now()}, "$pull": {"multi_pitch_route_ids": route_id}})
    if update_result.modified_count != 1:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Removing route_id {route_id} from spot {spot_id} failed"
        )
    # route_id was removed
    updated_spot = await db["spot"].find_one({"_id": spot_id})
    for media_id in route["media_ids"]:
        await db["medium"].delete_one({"_id": media_id})
    # media deleted
    if updated_spot is not None:
        return updated_spot
    else:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail=f"Spot {spot_id} not found")
