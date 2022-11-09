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


@router.post("/routes", response_description="Add new route", response_model=RouteModel)
async def create_route(route: RouteModel = Body(...)):
    route = jsonable_encoder(route)
    new_route = await db["routes"].insert_one(route)
    created_route = await db["routes"].find_one({"_id": new_route.inserted_id})
    return JSONResponse(status_code=status.HTTP_201_CREATED, content=created_route)


@router.get("/routes", response_description="List all routes", response_model=List[RouteModel])
async def list_routes():
    routes = await db["routes"].find().to_list(1000)
    return routes


@router.get("/routes-{id}", response_description="Get a single route", response_model=RouteModel)
async def show_route(id: str):
    if (route := await db["routes"].find_one({"_id": id})) is not None:
        return route
    raise HTTPException(status_code=404, detail=f"Route {id} not found")


@router.put("/routes-{id}", response_description="Update a route", response_model=RouteModel)
async def update_route(id: str, route: UpdateRouteModel = Body(...)):
    route = {k: v for k, v in route.dict().items() if v is not None}

    if len(route) >= 1:
        update_result = await db["routes"].update_one({"_id": id}, {"$set": route})

        if update_result.modified_count == 1:
            if (
                updated_route := await db["routes"].find_one({"_id": id})
            ) is not None:
                return updated_route

    if (existing_route := await db["routes"].find_one({"_id": id})) is not None:
        return existing_route

    raise HTTPException(status_code=404, detail=f"Route {id} not found")


@router.delete("/routes-{id}", response_description="Delete a route")
async def delete_route(id: str):
    delete_result = await db["routes"].delete_one({"_id": id})

    if delete_result.deleted_count == 1:
        return Response(status_code=status.HTTP_204_NO_CONTENT)

    raise HTTPException(status_code=404, detail=f"Route {id} not found")
