import datetime

from fastapi import APIRouter, Depends, Security
from fastapi_auth0 import Auth0User

from app.core.db import get_db
from app.core.auth import auth

router = APIRouter()
collection_names = ["trip", "spot", "single_pitch_route", "multi_pitch_route", "pitch", "ascent", "medium"]


@router.delete('/migrate-object-id-to-str', description="Convert all object ids to str", dependencies=[Depends(auth.implicit_scheme)])
async def migrate_objectId_to_str(user: Auth0User = Security(auth.get_user, scopes=["write:diary"])):
    db = await get_db()
    for collection_name in collection_names:
        things = await db[collection_name].find({"user_id": user.id}).to_list(None)
        for thing in things:
            oldId = thing['_id']
            thing['_id'] = str(oldId)
            await db[collection_name].delete_one({"_id": oldId})
            await db[collection_name].insert_one(thing)


@router.delete('/migrate-add-updated', description="Add updated field to all entries", dependencies=[Depends(auth.implicit_scheme)])
async def migrate_add_updated(user: Auth0User = Security(auth.get_user, scopes=["write:diary"])):
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


@router.delete('/media', description="Delete all media from all users", dependencies=[Depends(auth.implicit_scheme)])
async def delete_media(user: Auth0User = Security(auth.get_user, scopes=["write:diary"])):
    db = await get_db()
    delete_result = await db["medium"].delete_many({"user_id": user.id})
