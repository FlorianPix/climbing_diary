import datetime
from typing import List

from fastapi import APIRouter, Body, Depends, HTTPException, Security, status
from fastapi.encoders import jsonable_encoder
from fastapi.responses import JSONResponse
from fastapi_auth0 import Auth0User

from app.core.db import get_db
from app.core.auth import auth

from app.models.spot.spot_model import SpotModel
from app.models.spot.update_spot_model import UpdateSpotModel

router = APIRouter()


@router.post('', description="Add a new spot", response_model=SpotModel, dependencies=[Depends(auth.implicit_scheme)])
async def create_spot(spot: SpotModel = Body(...), user: Auth0User = Security(auth.get_user, scopes=["write:diary"])):
    spot = jsonable_encoder(spot)
    spot["user_id"] = user.id
    spot["single_pitch_route_ids"] = []
    spot["multi_pitch_route_ids"] = []
    spot["media_ids"] = []
    spot["updated"] = datetime.datetime.now()
    db = await get_db()

    # check if spot already exists
    if (spots := await db["spot"].find({
        "name": spot["name"],
        "user_id": user.id,
        "coordinates.0": {"$gt": spot["coordinates"][0] - 0.001, "$lt": spot["coordinates"][0] + 0.001},
        "coordinates.1": {"$gt": spot["coordinates"][1] - 0.001, "$lt": spot["coordinates"][1] + 0.001},
    }).to_list(None)):
        raise HTTPException(status_code=status.HTTP_409_CONFLICT,
                            detail="Spot already exists")

    new_spot = await db["spot"].insert_one(spot)
    created_spot = await db["spot"].find_one({"_id": new_spot.inserted_id})
    return JSONResponse(status_code=status.HTTP_201_CREATED,
                        content=jsonable_encoder(SpotModel(**created_spot)))


@router.get('/{spot_id}', description="Retrieve a spot", response_model=SpotModel, dependencies=[Depends(auth.implicit_scheme)])
async def retrieve_spot(spot_id: str, user: Auth0User = Security(auth.get_user, scopes=["read:diary"])):
    db = await get_db()
    if (spot := await db["spot"].find_one({"_id": spot_id, "user_id": user.id})) is not None:
        return spot
    raise HTTPException(status_code=status.HTTP_404_NOT_FOUND,
                        detail=f"Spot {spot_id} not found")


@router.post('/ids', description="Get spots of ids", response_model=List[SpotModel], dependencies=[Depends(auth.implicit_scheme)])
async def retrieve_spots_of_ids(spot_ids: List[str] = Body(...), user: Auth0User = Security(auth.get_user, scopes=["read:diary"])):
    if not spot_ids:
        return []
    db = await get_db()
    spots = []
    for spot_id in spot_ids:
        if (spot := await db["spot"].find_one({"_id": spot_id, "user_id": user.id})) is not None:
            spots.append(spot)
        else:
            raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail=f"Spot {spot_id} not found")
    if spots:
        return spots
    raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail=f"Spots not found")


@router.get('', description="Retrieve all spots", response_model=List[SpotModel], dependencies=[Depends(auth.implicit_scheme)])
async def retrieve_spots(user: Auth0User = Security(auth.get_user, scopes=["read:diary"])):
    db = await get_db()
    spots = await db["spot"].find({"user_id": user.id}).to_list(None)
    return spots


@router.put('/{spot_id}', description="Update a spot", response_model=SpotModel, dependencies=[Depends(auth.implicit_scheme)])
async def update_spot(spot_id: str, spot: UpdateSpotModel = Body(...), user: Auth0User = Security(auth.get_user, scopes=["write:diary"])):
    db = await get_db()
    spot = {k: v for k, v in spot.dict().items() if v is not None}
    spot['updated'] = datetime.datetime.now()
    if len(spot) >= 1:
        update_result = await db["spot"].update_one({"_id": spot_id}, {"$set": spot})
        if update_result.modified_count == 1:
            if (updated_spot := await db["spot"].find_one({"_id": spot_id})) is not None:
                return updated_spot
    if (existing_spot := await db["spot"].find_one({"_id": spot_id})) is not None:
        return existing_spot
    raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail=f"Spot {spot_id} not found")


@router.delete('/{spot_id}', description="Delete a spot", response_model=SpotModel, dependencies=[Depends(auth.implicit_scheme)])
async def delete_spot(spot_id: str, user: Auth0User = Security(auth.get_user, scopes=["write:diary"])):
    db = await get_db()
    spot = await db["spot"].find_one({"_id": spot_id, "user_id": user.id})
    if spot is None:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail=f"Spot {spot_id} not found")
    # spot was found
    routes = await db["multi_pitch_route"].find({"_id": {"$in": spot["multi_pitch_route_ids"]}}).to_list(None)
    if routes is None:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail=f"Routes could not be found")
    if routes:
        # routes were found
        for route in routes:
            pitches = await db["pitch"].find({"_id": {"$in": route["pitch_ids"]}}).to_list(None)
            if pitches is None:
                raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail=f"Pitches could not be found")
            if not pitches:
                continue
            # pitches were found
            for pitch in pitches:
                if not pitch["ascent_ids"]: continue
                delete_result = await db["ascent"].delete_many({"_id": {"$in": pitch["ascent_ids"]}})
                if delete_result.deleted_count < 1:
                    raise HTTPException(
                        status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
                        detail=f"Ascents could not be deleted"
                    )
                # all ascents of this pitch were deleted
            # all ascents of this route were deleted
            delete_result = await db["pitch"].delete_many({"_id": {"$in": route["pitch_ids"]}})
            if delete_result.deleted_count < 1:
                raise HTTPException(
                    status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
                    detail=f"Pitches could not be deleted"
                )
            # all pitches of this route were deleted
        # all pitches were deleted
        delete_result = await db["multi_pitch_route"].delete_many({"_id": {"$in": spot["multi_pitch_route_ids"]}})
        if delete_result.deleted_count < 1:
            raise HTTPException(
                status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
                detail=f"Multi pitch routes could not be deleted"
            )
    # all multi pitch routes were deleted
    routes = await db["single_pitch_route"].find({"_id": {"$in": spot["single_pitch_route_ids"]}}).to_list(None)
    if routes is None:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail=f"Single pitch routes could not be found")
    if routes:
        # routes were found
        for route in routes:
            if not route["ascent_ids"]: continue
            delete_result = await db["ascent"].delete_many({"_id": {"$in": route["ascent_ids"]}})
            if delete_result.deleted_count < 1:
                raise HTTPException(
                    status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
                    detail=f"Ascents could not be deleted"
                )
            # all ascents of this route were deleted
        delete_result = await db["single_pitch_route"].delete_many({"_id": {"$in": spot["single_pitch_route_ids"]}})
        if delete_result.deleted_count < 1:
            raise HTTPException(
                status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
                detail=f"Single pitch routes could not be deleted"
            )
    # all single pitch routes were deleted
    delete_result = await db["spot"].delete_one({"_id": spot_id})
    if delete_result.deleted_count != 1:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail=f"Spot {spot_id} not found")
    # spot was deleted
    trips = await db["trip"].find({"user_id": user.id}).to_list(None)
    if trips:
        for trip in trips:
            await db["trip"].update_one({"_id": trip['_id'], "user_id": user.id}, {"$pull": {"spot_ids": spot_id}})
    # spot_id was removed from trips
    for media_id in spot["media_ids"]:
        await db["medium"].delete_one({"_id": media_id})
    # media deleted
    return spot
