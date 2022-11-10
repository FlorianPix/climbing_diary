from typing import List

from fastapi import APIRouter, Body, HTTPException, status
from fastapi.encoders import jsonable_encoder
from fastapi.responses import Response, JSONResponse

from .models.spot_model import SpotModel
from .models.update_spot_model import UpdateSpotModel

import os
import motor.motor_asyncio

router = APIRouter()
client = motor.motor_asyncio.AsyncIOMotorClient(os.environ["MONGODB_URL"])
db = client.climbing


@router.post("/spot", response_description="Add new spot", response_model=SpotModel)
async def create_spot(spot: SpotModel = Body(...)):
    spot = jsonable_encoder(spot)
    new_spot = await db["spots"].insert_one(spot)
    created_spot = await db["spots"].find_one({"_id": new_spot.inserted_id})
    return JSONResponse(status_code=status.HTTP_201_CREATED, content=created_spot)


@router.get("/spots", response_description="List all spots", response_model=List[SpotModel])
async def list_spots():
    spots = await db["spots"].find().to_list(1000)
    return spots


@router.get("/spot-{id}", response_description="Get a single spot", response_model=SpotModel)
async def show_spot(id: str):
    if (spot := await db["spots"].find_one({"_id": id})) is not None:
        return spot
    raise HTTPException(status_code=404, detail=f"Spot {id} not found")


@router.put("/spot-{id}", response_description="Update a spot", response_model=SpotModel)
async def update_spot(id: str, spot: UpdateSpotModel = Body(...)):
    spot = {k: v for k, v in spot.dict().items() if v is not None}

    if len(spot) >= 1:
        update_result = await db["spots"].update_one({"_id": id}, {"$set": spot})

        if update_result.modified_count == 1:
            if (
                updated_spot := await db["spots"].find_one({"_id": id})
            ) is not None:
                return updated_spot

    if (existing_spot := await db["spots"].find_one({"_id": id})) is not None:
        return existing_spot

    raise HTTPException(status_code=404, detail=f"Spot {id} not found")


@router.delete("/spot-{id}", response_description="Delete a spot")
async def delete_spot(id: str):
    delete_result = await db["spots"].delete_one({"_id": id})

    if delete_result.deleted_count == 1:
        return Response(status_code=status.HTTP_204_NO_CONTENT)

    raise HTTPException(status_code=404, detail=f"Spot {id} not found")
