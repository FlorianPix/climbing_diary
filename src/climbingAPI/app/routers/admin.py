import datetime

from fastapi import APIRouter, Depends, Security
from fastapi_auth0 import Auth0User

from app.core.db import get_db
from app.core.auth import auth

router = APIRouter()
collection_names = ["trip", "spot", "single_pitch_route", "multi_pitch_route", "pitch", "ascent"]


@router.delete('/migrate', description="Migrate db from v0.0.4-alpha to v0.1.0-alpha", dependencies=[Depends(auth.implicit_scheme)])
async def migrate_all(user: Auth0User = Security(auth.get_user, scopes=["write:diary"])):
    db = await get_db()
    for collection_name in collection_names:
        await db[collection_name].update_many({"user_id": user.id}, {"$set": {"updated": datetime.datetime.now()}})


@router.delete('/', description="Delete everything from this user", dependencies=[Depends(auth.implicit_scheme)])
async def delete_all(user: Auth0User = Security(auth.get_user, scopes=["write:diary"])):
    db = await get_db()
    for collection_name in collection_names:
        await db[collection_name].delete_many({"user_id": user.id})


@router.delete('/trips', description="Delete all trips from all users", dependencies=[Depends(auth.implicit_scheme)])
async def delete_trips(user: Auth0User = Security(auth.get_user, scopes=["write:diary"])):
    db = await get_db()
    delete_result = await db["trip"].delete_many({"user_id": user.id})


@router.delete('/spots', description="Delete all spots from all users", dependencies=[Depends(auth.implicit_scheme)])
async def delete_spots(user: Auth0User = Security(auth.get_user, scopes=["write:diary"])):
    db = await get_db()
    delete_result = await db["spot"].delete_many({"user_id": user.id})


@router.delete('/routes', description="Delete all routes from all users", dependencies=[Depends(auth.implicit_scheme)])
async def delete_routes(user: Auth0User = Security(auth.get_user, scopes=["write:diary"])):
    db = await get_db()
    delete_result = await db["single_pitch_route"].delete_many({"user_id": user.id})
    delete_result = await db["multi_pitch_route"].delete_many({"user_id": user.id})


@router.delete('/pitches', description="Delete all pitches from all users", dependencies=[Depends(auth.implicit_scheme)])
async def delete_pitches(user: Auth0User = Security(auth.get_user, scopes=["write:diary"])):
    db = await get_db()
    delete_result = await db["pitch"].delete_many({"user_id": user.id})


@router.delete('/ascents', description="Delete all ascents from all users", dependencies=[Depends(auth.implicit_scheme)])
async def delete_ascents(user: Auth0User = Security(auth.get_user, scopes=["write:diary"])):
    db = await get_db()
    delete_result = await db["ascent"].delete_many({"user_id": user.id})
