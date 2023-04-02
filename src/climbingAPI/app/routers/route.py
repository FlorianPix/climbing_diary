from typing import List

from fastapi import APIRouter, Body, Depends, HTTPException, Security, status
from fastapi.encoders import jsonable_encoder
from fastapi.responses import Response, JSONResponse
from fastapi_auth0 import Auth0User
from bson import ObjectId

from app.models.route.route_model import RouteModel
from app.models.route.create_route_model import CreateRouteModel
from app.models.route.update_route_model import UpdateRouteModel
from app.core.db import get_db
from app.core.auth import auth

router = APIRouter()


@router.post('', description="Add a new route", response_model=RouteModel, dependencies=[Depends(auth.implicit_scheme)])
async def create_route(route: CreateRouteModel = Body(...), user: Auth0User = Security(auth.get_user, scopes=["write:diary"])):
    route = jsonable_encoder(route)
    route["user_id"] = user.id
    route["pitch_ids"] = []
    route["media_ids"] = []
    db = await get_db()
    new_route = await db["route"].insert_one(route)
    created_route = await db["route"].find_one({"_id": new_route.inserted_id})
    return JSONResponse(status_code=status.HTTP_201_CREATED, content=jsonable_encoder(RouteModel(**created_route)))


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
    raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail=f"Route {route_id} not found")


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

    raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail=f"Route {route_id} not found")


@router.delete('/{route_id}', description="Delete a route", dependencies=[Depends(auth.implicit_scheme)])
async def delete_route(route_id: str, user: Auth0User = Security(auth.get_user, scopes=["write:diary"])):
    db = await get_db()
    existing_route = await db["route"].find_one({"_id": ObjectId(route_id), "user_id": user.id,})

    if existing_route is None:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail=f"Route {route_id} not found")

    delete_result = await db["route"].delete_one({"_id": ObjectId(route_id)})

    if delete_result.deleted_count == 1:
        return Response(status_code=status.HTTP_204_NO_CONTENT)

    raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail=f"Route {route_id} not found")
