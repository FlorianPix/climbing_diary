from typing import List

from fastapi import APIRouter, Body, HTTPException, status
from fastapi.encoders import jsonable_encoder
from fastapi.responses import Response, JSONResponse

from .models.route_model import RouteModel
from .models.update_route_model import UpdateRouteModel

import os
import motor.motor_asyncio

router = APIRouter()
client = motor.motor_asyncio.AsyncIOMotorClient(os.environ["MONGODB_URL"])
db = client.climbing


@router.post("/route-{spot_id}", response_description="Add new route", response_model=RouteModel)
async def create_route(spot_id: str, route: RouteModel = Body(...)):
    route = jsonable_encoder(route)
    new_route = await db["routes"].insert_one(route)
    created_route = await db["routes"].find_one({"_id": new_route.inserted_id})
    # add route id to spot
    update_result = await db["spots"].update_one({"_id": spot_id}, {"$push": {"routes": created_route["_id"]}})
    return JSONResponse(status_code=status.HTTP_201_CREATED, content=created_route)


@router.get("/routes", response_description="List all routes", response_model=List[RouteModel])
async def list_routes():
    routes = await db["routes"].find().to_list(1000)
    return routes


@router.get("/route-{route_id}", response_description="Get a single route", response_model=RouteModel)
async def show_route(route_id: str):
    if (route := await db["routes"].find_one({"_id": route_id})) is not None:
        return route
    raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail=f"Route {route_id} not found")


@router.put("/route-{route_id}", response_description="Update a route", response_model=RouteModel)
async def update_route(route_id: str, route: UpdateRouteModel = Body(...)):
    route = {k: v for k, v in route.dict().items() if v is not None}

    if len(route) >= 1:
        update_result = await db["routes"].update_one({"_id": route_id}, {"$set": route})

        if update_result.modified_count == 1:
            if (
                updated_route := await db["routes"].find_one({"_id": route_id})
            ) is not None:
                return updated_route

    if (existing_route := await db["routes"].find_one({"_id": route_id})) is not None:
        return existing_route

    raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail=f"Route {route_id} not found")


@router.delete("/route-{spot_id}-{route_id}", response_description="Delete a route")
async def delete_route(spot_id: str, route_id: str):
    delete_result = await db["routes"].delete_one({"_id": route_id})

    # remove route id from spot
    update_result = await db["spots"].update_one({"_id": spot_id}, {"$pull": {"routes": route_id}})

    if delete_result.deleted_count == 1:
        return Response(status_code=status.HTTP_204_NO_CONTENT)

    raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail=f"Route {route_id} not found")
