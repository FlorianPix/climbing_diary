from fastapi import APIRouter, Depends, Security
from fastapi_auth0 import Auth0User

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
