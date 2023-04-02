from typing import List

from fastapi import APIRouter, Body, Depends, HTTPException, Security, status
from fastapi.encoders import jsonable_encoder
from fastapi.responses import Response, JSONResponse
from fastapi_auth0 import Auth0User
from bson import ObjectId

from app.core.db import get_db
from app.core.auth import auth

router = APIRouter()


@router.post('', description="Add a new ascend", response_model=AscendModel, dependencies=[Depends(auth.implicit_scheme)])
async def create_ascend(ascend: CreateAscendModel = Body(...), user: Auth0User = Security(auth.get_user, scopes=["write:diary"])):
    ascend = jsonable_encoder(ascend)
    ascend["user_id"] = user.id
    ascend["media_ids"] = []

    new_ascend = await db["ascend"].insert_one(ascend)
    created_ascend = await db["ascend"].find_one({"_id": new_ascend.inserted_id})
    return JSONResponse(status_code=status.HTTP_201_CREATED, content=jsonable_encoder(ascendModel(**created_ascend)))


@router.get('', description="List all ascends", response_model=List[AscendModel], dependencies=[Depends(auth.implicit_scheme)])
async def retrieve_ascends(user: Auth0User = Security(auth.get_user, scopes=["read:diary"])):
    db = await get_db()
    ascends = await db["ascend"].find({"user_id": user.id}).to_list(None)
    return ascends


@router.get('/{ascend_id}', description="Retrieve an ascend", response_model=ascendModel, dependencies=[Depends(auth.implicit_scheme)])
async def retrieve_ascend(ascend_id: str, user: Auth0User = Security(auth.get_user, scopes=["read:diary"])):
    db = await get_db()
    if (ascend := await db["ascend"].find_one({"_id": ObjectId(ascend_id), "user_id": user.id})) is not None:
        return ascend
    raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail=f"Ascend {ascend_id} not found.")


@router.put('/{ascend_id}', description="Update an ascend", response_model=AscendModel, dependencies=[Depends(auth.implicit_scheme)])
async def update_ascend(ascend_id: str, ascend: UpdateAscendModel = Body(...), user: Auth0User = Security(auth.get_user, scopes=["write:diary"])):
    db = await get_db()
    ascend = {k: v for k, v in ascend.dict().items() if v is not None}

    if len(ascend) >= 1:
        update_result = await db["ascend"].update_one({"_id": ObjectId(ascend_id)}, {"$set": ascend})

        if update_result.modified_count == 1:
            if (
                updated_ascend := await db["ascend"].find_one({"_id": ObjectId(ascend_id)})
            ) is not None:
                return updated_ascend

    if (existing_ascend := await db["ascend"].find_one({"_id": ObjectId(ascend_id)})) is not None:
        return existing_ascend

    raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail=f"Ascend {ascend_id} not found")


@router.delete('/{ascend_id}', description="Delete an ascend", dependencies=[Depends(auth.implicit_scheme)])
async def delete_ascend(ascend_id: str, user: Auth0User = Security(auth.get_user, scopes=["write:diary"])):
    db = await get_db()
    existing_ascend = await db["ascend"].find_one({"_id": ObjectId(ascend_id), "user_id": user.id,})

    if existing_ascend is None:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail=f"Ascend {ascend_id} not found")

    delete_result = await db["ascend"].delete_one({"_id": ObjectId(ascend_id)})

    if delete_result.deleted_count == 1:
        return Response(status_code=status.HTTP_204_NO_CONTENT)

    raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail=f"Ascend {ascend_id} not found")
