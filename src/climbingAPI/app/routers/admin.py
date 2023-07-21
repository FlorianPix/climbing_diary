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


@router.delete('/', description="Delete everything from this user", dependencies=[Depends(auth.implicit_scheme)])
async def delete_all(user: Auth0User = Security(auth.get_user, scopes=["write:diary"])):
    db = await get_db()
    await db["trip"].delete_many({"user_id": user.id})
    await db["spot"].delete_many({"user_id": user.id})
    await db["single_pitch_route"].delete_many({"user_id": user.id})
    await db["multi_pitch_route"].delete_many({"user_id": user.id})
    await db["pitch"].delete_many({"user_id": user.id})
    await db["ascent"].delete_many({"user_id": user.id})


@router.get('/spots', description="Retrieve all spots from all users", response_model=List[SpotModel], dependencies=[Depends(auth.implicit_scheme)])
async def get_all_spots(user: Auth0User = Security(auth.get_user, scopes=["read:diary"])):
    db = await get_db()
    spots = await db["spot"].find({}).to_list(None)
    return spots


@router.delete('/trips', description="Delete all trips from all users", dependencies=[Depends(auth.implicit_scheme)])
async def delete_trips(user: Auth0User = Security(auth.get_user, scopes=["write:diary"])):
    db = await get_db()
    delete_result = await db["trip"].delete_many({})


@router.delete('/spots', description="Delete all spots from all users", dependencies=[Depends(auth.implicit_scheme)])
async def delete_spots(user: Auth0User = Security(auth.get_user, scopes=["write:diary"])):
    db = await get_db()
    delete_result = await db["spot"].delete_many({})


@router.delete('/routes', description="Delete all routes from all users", dependencies=[Depends(auth.implicit_scheme)])
async def delete_routes(user: Auth0User = Security(auth.get_user, scopes=["write:diary"])):
    db = await get_db()
    delete_result = await db["single_pitch_route"].delete_many({})
    delete_result = await db["multi_pitch_route"].delete_many({})


@router.delete('/pitches', description="Delete all pitches from all users", dependencies=[Depends(auth.implicit_scheme)])
async def delete_pitches(user: Auth0User = Security(auth.get_user, scopes=["write:diary"])):
    db = await get_db()
    delete_result = await db["pitch"].delete_many({})


@router.delete('/ascents', description="Delete all ascents from all users", dependencies=[Depends(auth.implicit_scheme)])
async def delete_ascents(user: Auth0User = Security(auth.get_user, scopes=["write:diary"])):
    db = await get_db()
    delete_result = await db["ascent"].delete_many({})
