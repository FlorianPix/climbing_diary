import datetime
from typing import List, Tuple

from fastapi import APIRouter, Body, Depends, HTTPException, Security, status
from fastapi.encoders import jsonable_encoder
from fastapi.responses import JSONResponse
from fastapi_auth0 import Auth0User

from app.core.db import get_db
from app.core.auth import auth

from app.models.medium.medium_model import MediumModel
from app.models.medium.small_medium_model import SmallMediumModel

router = APIRouter()


@router.post('', description="Add a new medium", response_model=MediumModel, dependencies=[Depends(auth.implicit_scheme)])
async def create_medium(medium: MediumModel = Body(...), user: Auth0User = Security(auth.get_user, scopes=["write:diary"])):
    medium = jsonable_encoder(medium)
    medium["user_id"] = user.id
    db = await get_db()
    # check if medium already exists
    if (media := await db["medium"].find({
        "title": medium["title"],
        "user_id": user.id
    }).to_list(None)):
        raise HTTPException(status_code=status.HTTP_409_CONFLICT, detail="Medium already exists")
    new_medium = await db["medium"].insert_one(medium)
    created_medium = await db["medium"].find_one({"_id": new_medium.inserted_id})
    return JSONResponse(status_code=status.HTTP_201_CREATED, content=jsonable_encoder(MediumModel(**created_medium)))


@router.get('/{medium_id}', description="Get a medium", response_model=MediumModel, dependencies=[Depends(auth.implicit_scheme)])
async def retrieve_medium_of_id(medium_id: str, user: Auth0User = Security(auth.get_user, scopes=["read:diary"])):
    db = await get_db()
    if (medium := await db["medium"].find_one({"_id": medium_id, "user_id": user.id})) is not None:
        return medium
    raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail=f"Medium {medium_id} not found")


@router.post('/ids', description="Get media of ids", response_model=List[MediumModel], dependencies=[Depends(auth.implicit_scheme)])
async def retrieve_media_of_ids(medium_ids: List[str] = Body(...), user: Auth0User = Security(auth.get_user, scopes=["read:diary"])):
    if not medium_ids:
        return []
    db = await get_db()
    media = []
    for medium_id in medium_ids:
        if (medium := await db["medium"].find_one({"_id": medium_id, "user_id": user.id})) is not None:
            media.append(medium)
        else:
            raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail=f"Medium {medium_id} not found")
    if media:
        return media
    raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail=f"Media not found")


@router.get('-small', description="Retrieve all media without the actual image", response_model=List[SmallMediumModel], dependencies=[Depends(auth.implicit_scheme)])
async def retrieve_all_media_small(user: Auth0User = Security(auth.get_user, scopes=["read:diary"])):
    db = await get_db()
    media = await db["medium"].find({"user_id": user.id}, {"image": 0}).to_list(None)
    return media


@router.get('', description="Retrieve all media", response_model=List[MediumModel], dependencies=[Depends(auth.implicit_scheme)])
async def retrieve_all_media(user: Auth0User = Security(auth.get_user, scopes=["read:diary"])):
    db = await get_db()
    media = await db["medium"].find({"user_id": user.id}).to_list(None)
    return media


@router.delete('/{medium_id}', description="Delete a medium", response_model=MediumModel, dependencies=[Depends(auth.implicit_scheme)])
async def delete_medium(medium_id: str, user: Auth0User = Security(auth.get_user, scopes=["write:diary"])):
    db = await get_db()
    medium = await db["medium"].find_one({"_id": medium_id, "user_id": user.id})
    if medium is None:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail=f"Medium {medium_id} not found")
    delete_result = await db["medium"].delete_one({"_id": medium_id})
    if delete_result.deleted_count == 1:
        return medium
    raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail=f"Medium {medium_id} not found")
