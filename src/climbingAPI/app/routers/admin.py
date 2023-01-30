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

@router.get('', description="Get all spots", response_model=List[SpotModel], dependencies=[Depends(auth.implicit_scheme)])
async def get_all_spots(user: Auth0User = Security(auth.get_user, scopes=["read:diary"])):
    db = await get_db()
    spots = await db["spots"].find({}).to_list(None)
    return spots

@router.delete('', description="Delete all spots", dependencies=[Depends(auth.implicit_scheme)])
async def delete_spots(user: Auth0User = Security(auth.get_user, scopes=["write:diary"])):
    db = await get_db()
    delete_result = await db["spots"].delete_many({})