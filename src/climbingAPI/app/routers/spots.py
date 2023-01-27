from typing import List

from fastapi import APIRouter, Body, Depends, HTTPException, Security, status
from fastapi.encoders import jsonable_encoder
from fastapi.responses import Response, JSONResponse
from fastapi_auth0 import Auth0User
from bson import ObjectId

from app.models.spot.spot_model import SpotModel
from app.models.spot.create_spot_model import CreateSpotModel
from app.models.spot.update_spot_model import UpdateSpotModel
from app.core.db import get_db
from app.core.auth import auth

router = APIRouter()


@router.post('', response_description="Add new spot", response_model=SpotModel, dependencies=[Depends(auth.implicit_scheme)])
async def create_spot(spot: CreateSpotModel = Body(...), user: Auth0User = Security(auth.get_user, scopes=["write:diary"])):
    spot = jsonable_encoder(spot)
    spot["user_id"] = user.id
    spot["routes"] = []
    spot["media_ids"] = []

    db = await get_db()

    # check if spot already exists
    if (spots := await db["spots"].find({
        "name": spot["name"],
        "user_id": user.id,
        "coordinates.0": { "$gt": spot["coordinates"][0] - 0.001, "$lt": spot["coordinates"][0] + 0.001},
        "coordinates.1": { "$gt": spot["coordinates"][1] - 0.001, "$lt": spot["coordinates"][1] + 0.001},
    }).to_list(None)):
        raise HTTPException(status_code=status.HTTP_409_CONFLICT, detail="spot already exists")

    new_spot = await db["spots"].insert_one(spot)
    created_spot = await db["spots"].find_one({"_id": new_spot.inserted_id})
    return JSONResponse(status_code=status.HTTP_201_CREATED, content=jsonable_encoder(SpotModel(**created_spot)))


@router.get('', response_description="List all spots", response_model=List[SpotModel], dependencies=[Depends(auth.implicit_scheme)])
async def list_spots(user: Auth0User = Security(auth.get_user, scopes=["read:diary"])):
    db = await get_db()
    spots = await db["spots"].find({}).to_list(None)
    return spots


@router.get('/{spot_id}', response_description="Get a single spot", response_model=SpotModel, dependencies=[Depends(auth.implicit_scheme)])
async def show_spot(spot_id: str, user: Auth0User = Security(auth.get_user, scopes=["read:diary"])):
    db = await get_db()
    if (spot := await db["spots"].find_one({"_id": ObjectId(spot_id)})) is not None:
        if spot["user_id"] == user.id:
            return spot
        else:
            raise HTTPException(status_code=status.HTTP_403_FORBIDDEN, detail="You do not have access to this spot")
    raise HTTPException(status_code=404, detail=f"Spot {spot_id} not found")


@router.put('/{spot_id}', response_description="Update a spot", response_model=SpotModel, dependencies=[Depends(auth.implicit_scheme)])
async def update_spot(spot_id: str, spot: UpdateSpotModel = Body(...), user: Auth0User = Security(auth.get_user, scopes=["write:diary"])):
    db = await get_db()
    spot = {k: v for k, v in spot.dict().items() if v is not None}

    if len(spot) >= 1:
        update_result = await db["spots"].update_one({"_id": ObjectId(spot_id)}, {"$set": spot})

        if update_result.modified_count == 1:
            if (
                updated_spot := await db["spots"].find_one({"_id": ObjectId(spot_id)})
            ) is not None:
                return updated_spot

    if (existing_spot := await db["spots"].find_one({"_id": ObjectId(spot_id)})) is not None:
        return existing_spot

    raise HTTPException(status_code=404, detail=f"Spot {spot_id} not found")


@router.delete('/{spot_id}', response_description="Delete a spot", dependencies=[Depends(auth.implicit_scheme)])
async def delete_spot(spot_id: str, user: Auth0User = Security(auth.get_user, scopes=["write:diary"])):
    db = await get_db()
    existing_spot = await db["spots"].find_one({"_id": ObjectId(spot_id)})

    if existing_spot is None:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail=f"Spot {spot_id} not found")

    if existing_spot["user_id"] != user.id:
        raise HTTPException(status_code=status.HTTP_403_FORBIDDEN, detail="You do not have access to this spot")

    delete_result = await db["spots"].delete_one({"_id": ObjectId(spot_id)})

    if delete_result.deleted_count == 1:
        return Response(status_code=status.HTTP_204_NO_CONTENT)

    raise HTTPException(status_code=404, detail=f"Spot {spot_id} not found")


@router.delete('', response_description="Delete all spots", dependencies=[Depends(auth.implicit_scheme)])
async def delete_spots(user: Auth0User = Security(auth.get_user, scopes=["write:diary"])):
    db = await get_db()
    delete_result = await db["spots"].delete_many({})
