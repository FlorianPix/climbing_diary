from typing import List

from fastapi import APIRouter, Body, Depends, HTTPException, Security, status
from fastapi.encoders import jsonable_encoder
from fastapi.responses import Response, JSONResponse
from fastapi_auth0 import Auth0User
from bson import ObjectId

from app.core.db import get_db
from app.core.auth import auth

from app.models.ascent.ascent_model import AscentModel
from app.models.ascent.create_ascent_model import CreateAscentModel
from app.models.ascent.update_ascent_model import UpdateAscentModel

router = APIRouter()


@router.post('', description="Add a new ascent", response_model=AscentModel, dependencies=[Depends(auth.implicit_scheme)])
async def create_ascent(ascent: CreateAscentModel = Body(...), user: Auth0User = Security(auth.get_user, scopes=["write:diary"])):
    ascent = jsonable_encoder(ascent)
    ascent["user_id"] = user.id
    ascent["media_ids"] = []

    new_ascent = await db["ascent"].insert_one(ascent)
    created_ascent = await db["ascent"].find_one({"_id": new_ascent.inserted_id})
    return JSONResponse(status_code=status.HTTP_201_CREATED, content=jsonable_encoder(ascentModel(**created_ascent)))


@router.get('', description="List all ascents", response_model=List[AscentModel], dependencies=[Depends(auth.implicit_scheme)])
async def retrieve_ascents(user: Auth0User = Security(auth.get_user, scopes=["read:diary"])):
    db = await get_db()
    ascents = await db["ascent"].find({"user_id": user.id}).to_list(None)
    return ascents


@router.get('/{ascent_id}', description="Retrieve an ascent", response_model=AscentModel, dependencies=[Depends(auth.implicit_scheme)])
async def retrieve_ascent(ascent_id: str, user: Auth0User = Security(auth.get_user, scopes=["read:diary"])):
    db = await get_db()
    if (ascent := await db["ascent"].find_one({"_id": ObjectId(ascent_id), "user_id": user.id})) is not None:
        return ascent
    raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail=f"Ascent {ascent_id} not found.")


@router.put('/{ascent_id}', description="Update an ascent", response_model=AscentModel, dependencies=[Depends(auth.implicit_scheme)])
async def update_ascent(ascent_id: str, ascent: UpdateAscentModel = Body(...), user: Auth0User = Security(auth.get_user, scopes=["write:diary"])):
    db = await get_db()
    ascent = {k: v for k, v in ascent.dict().items() if v is not None}

    if len(ascent) >= 1:
        update_result = await db["ascent"].update_one({"_id": ObjectId(ascent_id)}, {"$set": ascent})

        if update_result.modified_count == 1:
            if (
                updated_ascent := await db["ascent"].find_one({"_id": ObjectId(ascent_id)})
            ) is not None:
                return updated_ascent

    if (existing_ascent := await db["ascent"].find_one({"_id": ObjectId(ascent_id)})) is not None:
        return existing_ascent

    raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail=f"Ascent {ascent_id} not found")


@router.delete('/{ascent_id}', description="Delete an ascent", dependencies=[Depends(auth.implicit_scheme)])
async def delete_ascent(ascent_id: str, user: Auth0User = Security(auth.get_user, scopes=["write:diary"])):
    db = await get_db()
    existing_ascent = await db["ascent"].find_one({"_id": ObjectId(ascent_id), "user_id": user.id,})

    if existing_ascent is None:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail=f"Ascent {ascent_id} not found")

    delete_result = await db["ascent"].delete_one({"_id": ObjectId(ascent_id)})

    if delete_result.deleted_count == 1:
        return Response(status_code=status.HTTP_204_NO_CONTENT)

    raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail=f"Ascent {ascent_id} not found")
