from typing import List

from fastapi import APIRouter, Body, Depends, HTTPException, Security, status
from fastapi.encoders import jsonable_encoder
from fastapi.responses import Response, JSONResponse
from fastapi_auth0 import Auth0User
from bson import ObjectId

from app.models.spot_model import SpotModel
from app.models.update_spot_model import UpdateSpotModel
from app.core.db import get_db
from app.core.auth import auth

router = APIRouter()


@router.post('', response_description="Add new spot", response_model=SpotModel, dependencies=[Depends(auth.implicit_scheme)])
async def create_spot(spot: SpotModel = Body(...), user: Auth0User = Security(auth.get_user, scopes=["write:diary"])):
    db = await get_db()
    spot = jsonable_encoder(spot)
    new_spot = await db["spots"].insert_one(spot)
    created_spot = await db["spots"].find_one({"_id": new_spot.inserted_id})
    return JSONResponse(status_code=status.HTTP_201_CREATED, content=created_spot)


@router.get('', response_description="List all spots", response_model=List[SpotModel], dependencies=[Depends(auth.implicit_scheme)])
async def list_spots(user: Auth0User = Security(auth.get_user, scopes=["read:diary"])):
    db = await get_db()
    spots = await db["spots"].find().to_list(1000)
    return spots


@router.get('/{spot_id}', response_description="Get a single spot", response_model=SpotModel, dependencies=[Depends(auth.implicit_scheme)])
async def show_spot(spot_id: str, user: Auth0User = Security(auth.get_user, scopes=["read:diary"])):
    db = await get_db()
    if (spot := await db["spots"].find_one({"_id": spot_id})) is not None:
        return spot
    raise HTTPException(status_code=404, detail=f"Spot {spot_id} not found")


@router.put('/{spot_id}', response_description="Update a spot", response_model=SpotModel, dependencies=[Depends(auth.implicit_scheme)])
async def update_spot(spot_id: str, spot: UpdateSpotModel = Body(...), user: Auth0User = Security(auth.get_user, scopes=["write:diary"])):
    db = await get_db()
    spot = {k: v for k, v in spot.dict().items() if v is not None}

    if len(spot) >= 1:
        update_result = await db["spots"].update_one({"_id": spot_id}, {"$set": spot})

        if update_result.modified_count == 1:
            if (
                updated_spot := await db["spots"].find_one({"_id": spot_id})
            ) is not None:
                return updated_spot

    if (existing_spot := await db["spots"].find_one({"_id": spot_id})) is not None:
        return existing_spot

    raise HTTPException(status_code=404, detail=f"Spot {spot_id} not found")


@router.delete('/{spot_id}', response_description="Delete a spot", dependencies=[Depends(auth.implicit_scheme)])
async def delete_spot(spot_id: str, user: Auth0User = Security(auth.get_user, scopes=["write:diary"])):
    db = await get_db()
    delete_result = await db["spots"].delete_one({"_id": spot_id})

    if delete_result.deleted_count == 1:
        return Response(status_code=status.HTTP_204_NO_CONTENT)

    raise HTTPException(status_code=404, detail=f"Spot {spot_id} not found")
