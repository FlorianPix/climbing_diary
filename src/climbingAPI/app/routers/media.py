from typing import List

from fastapi import APIRouter, Body, Depends, HTTPException, Security, status
from fastapi.encoders import jsonable_encoder
from fastapi.responses import JSONResponse
from fastapi_auth0 import Auth0User

from app.core.db import get_db, get_db_client
from app.core.auth import auth

from app.models.medium.medium_model import MediumModel
from app.models.medium.small_medium_model import SmallMediumModel

from motor.motor_asyncio import AsyncIOMotorGridFSBucket

import bson
import gridfs

router = APIRouter()


@router.post('test', description="test", dependencies=[Depends(auth.implicit_scheme)])
async def test():
    client = await get_db_client()  # AsyncIOMotorClient
    await client.drop_database('fs')  # MotorDatabase


@router.post('', description="Add a new medium", response_model=MediumModel, dependencies=[Depends(auth.implicit_scheme)])
async def create_medium(medium: MediumModel = Body(...), user: Auth0User = Security(auth.get_user, scopes=["write:diary"])):
    medium = jsonable_encoder(medium)
    medium["user_id"] = user.id
    client = await get_db_client()  # AsyncIOMotorClient
    bucket = AsyncIOMotorGridFSBucket(client.get_database('fs'))  # AsyncIOMotorGridFSBucket
    gridIn = bucket.open_upload_stream_with_id(file_id=medium['_id'], filename=medium['_id'])  # AsyncIOMotorGridIn
    try:
        await gridIn.write(bson.encode(medium))
        await gridIn.close()
    except gridfs.errors.FileExists:
        print(f"medium {medium['_id']} {medium['title']} already exists")
    gridOut = await bucket.open_download_stream(medium['_id'])  # AsyncIOMotorGridOut
    created_medium = bson.decode(await gridOut.read())
    return JSONResponse(status_code=status.HTTP_201_CREATED, content=jsonable_encoder(MediumModel(**created_medium)))


@router.get('/{medium_id}', description="Get a medium", response_model=MediumModel, dependencies=[Depends(auth.implicit_scheme)])
async def retrieve_medium_of_id(medium_id: str, user: Auth0User = Security(auth.get_user, scopes=["read:diary"])):
    client = await get_db_client()  # AsyncIOMotorClient
    bucket = AsyncIOMotorGridFSBucket(client.get_database('fs'))  # AsyncIOMotorGridFSBucket
    gridOut = await bucket.open_download_stream(medium_id)  # AsyncIOMotorGridOut
    return MediumModel(**bson.decode(await gridOut.read()))


@router.post('/ids', description="Get media of ids", response_model=List[MediumModel], dependencies=[Depends(auth.implicit_scheme)])
async def retrieve_media_of_ids(medium_ids: List[str] = Body(...), user: Auth0User = Security(auth.get_user, scopes=["read:diary"])):
    if not medium_ids:
        return []
    client = await get_db_client()  # AsyncIOMotorClient
    bucket = AsyncIOMotorGridFSBucket(client.get_database('fs'))  # AsyncIOMotorGridFSBucket
    media = []
    for medium_id in medium_ids:
        if (medium := await bucket.find({"_id": medium_id})) is not None:
            media.append(medium)
        else:
            raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail=f"Medium {medium_id} not found")
    if media:
        return media
    raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail=f"Media not found")


@router.get('-small', description="Retrieve all media without the actual image", response_model=List[SmallMediumModel], dependencies=[Depends(auth.implicit_scheme)])
async def retrieve_all_media_small(user: Auth0User = Security(auth.get_user, scopes=["read:diary"])):
    client = await get_db_client()  # AsyncIOMotorClient
    bucket = AsyncIOMotorGridFSBucket(client.get_database('fs'))  # AsyncIOMotorGridFSBucket
    meta_media = await bucket.find().to_list(None)
    media = []
    for meta_medium in meta_media:
        gridOut = await bucket.open_download_stream(meta_medium['_id'])  # AsyncIOMotorGridOut
        medium = SmallMediumModel(**bson.decode(await gridOut.read()))
        if medium.user_id == user.id: media.append(medium)
    return media


@router.get('', description="Retrieve all media", response_model=List[MediumModel], dependencies=[Depends(auth.implicit_scheme)])
async def retrieve_all_media(user: Auth0User = Security(auth.get_user, scopes=["read:diary"])):
    client = await get_db_client()  # AsyncIOMotorClient
    bucket = AsyncIOMotorGridFSBucket(client.get_database('fs'))  # AsyncIOMotorGridFSBucket
    meta_media = await bucket.find().to_list(None)
    media = []
    for meta_medium in meta_media:
        gridOut = await bucket.open_download_stream(meta_medium['_id'])  # AsyncIOMotorGridOut
        medium = MediumModel(**bson.decode(await gridOut.read()))
        if medium.user_id == user.id: media.append(medium)
    return media


@router.delete('/{medium_id}', description="Delete a medium", response_model=MediumModel, dependencies=[Depends(auth.implicit_scheme)])
async def delete_medium(medium_id: str, user: Auth0User = Security(auth.get_user, scopes=["write:diary"])):
    client = await get_db_client()  # AsyncIOMotorClient
    bucket = AsyncIOMotorGridFSBucket(client.get_database('fs'))  # AsyncIOMotorGridFSBucket
    await bucket.delete(medium_id)
