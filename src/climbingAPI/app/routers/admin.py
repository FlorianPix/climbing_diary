import datetime

import bson
from fastapi import APIRouter, Depends, Security
from fastapi_auth0 import Auth0User

from app.core.db import get_db, get_db_client
from app.core.auth import auth

from motor.motor_asyncio import AsyncIOMotorGridFSBucket

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
            try:
                spot_ids = []
                for old_spot_id in thing['spot_ids']:
                    spot_ids.append(str(old_spot_id))
                thing['spot_ids'] = spot_ids
            except Exception:
                pass
            try:
                single_pitch_route_ids = []
                for old_single_pitch_route_id in thing['single_pitch_route_ids']:
                    single_pitch_route_ids.append(str(old_single_pitch_route_id))
                thing['single_pitch_route_ids'] = single_pitch_route_ids
            except Exception:
                pass
            try:
                multi_pitch_route_ids = []
                for old_multi_pitch_route_id in thing['multi_pitch_route_ids']:
                    multi_pitch_route_ids.append(str(old_multi_pitch_route_id))
                thing['multi_pitch_route_ids'] = multi_pitch_route_ids
            except Exception:
                pass
            try:
                pitch_ids = []
                for old_pitch_id in thing['pitch_ids']:
                    pitch_ids.append(str(old_pitch_id))
                thing['pitch_ids'] = pitch_ids
            except Exception:
                pass
            try:
                ascent_ids = []
                for old_ascent_id in thing['ascent_ids']:
                    ascent_ids.append(str(old_ascent_id))
                thing['ascent_ids'] = ascent_ids
            except Exception:
                pass
            try:
                media_ids = []
                for old_medium_id in thing['media_ids']:
                    media_ids.append(str(old_medium_id))
                thing['media_ids'] = media_ids
            except Exception:
                pass
            await db[collection_name].delete_one({"_id": oldId})
            await db[collection_name].insert_one(thing)


@router.delete('/migrate-add-updated', description="Add updated field to all entries", dependencies=[Depends(auth.implicit_scheme)])
async def migrate_add_updated(user: Auth0User = Security(auth.get_user, scopes=["write:diary"])):
    db = await get_db()
    for collection_name in collection_names:
        await db[collection_name].update_many({"user_id": user.id}, {"$set": {"updated": datetime.datetime.now()}})


@router.delete('/', description="Delete everything of this user", dependencies=[Depends(auth.implicit_scheme)])
async def delete_all(user: Auth0User = Security(auth.get_user, scopes=["write:diary"])):
    # delete all data
    db = await get_db()
    for collection_name in collection_names:
        await db[collection_name].delete_many({"user_id": user.id})
    # delete all media
    client = await get_db_client()  # AsyncIOMotorClient
    bucket = AsyncIOMotorGridFSBucket(client.get_database('fs'))  # AsyncIOMotorGridFSBucket
    meta_media = await bucket.find().to_list(None)
    for meta_medium in meta_media:
        gridOut = await bucket.open_download_stream(meta_medium['_id'])  # AsyncIOMotorGridOut
        medium = bson.decode(await gridOut.read())
        if medium['user_id'] == user.id: await bucket.delete(medium['_id'])


@router.delete('/trips', description="Delete all trips of this user", dependencies=[Depends(auth.implicit_scheme)])
async def delete_trips(user: Auth0User = Security(auth.get_user, scopes=["write:diary"])):
    db = await get_db()
    delete_result = await db["trip"].delete_many({"user_id": user.id})


@router.delete('/spots', description="Delete all spots of this user", dependencies=[Depends(auth.implicit_scheme)])
async def delete_spots(user: Auth0User = Security(auth.get_user, scopes=["write:diary"])):
    db = await get_db()
    delete_result = await db["spot"].delete_many({"user_id": user.id})


@router.delete('/routes', description="Delete all routes of this user", dependencies=[Depends(auth.implicit_scheme)])
async def delete_routes(user: Auth0User = Security(auth.get_user, scopes=["write:diary"])):
    db = await get_db()
    delete_result = await db["single_pitch_route"].delete_many({"user_id": user.id})
    delete_result = await db["multi_pitch_route"].delete_many({"user_id": user.id})


@router.delete('/pitches', description="Delete all pitches of this user", dependencies=[Depends(auth.implicit_scheme)])
async def delete_pitches(user: Auth0User = Security(auth.get_user, scopes=["write:diary"])):
    db = await get_db()
    delete_result = await db["pitch"].delete_many({"user_id": user.id})


@router.delete('/ascents', description="Delete all ascents of this user", dependencies=[Depends(auth.implicit_scheme)])
async def delete_ascents(user: Auth0User = Security(auth.get_user, scopes=["write:diary"])):
    db = await get_db()
    delete_result = await db["ascent"].delete_many({"user_id": user.id})


@router.delete('/media', description="Delete all media of this user", dependencies=[Depends(auth.implicit_scheme)])
async def delete_media(user: Auth0User = Security(auth.get_user, scopes=["write:diary"])):
    client = await get_db_client()  # AsyncIOMotorClient
    bucket = AsyncIOMotorGridFSBucket(client.get_database('fs'))  # AsyncIOMotorGridFSBucket
    media = await bucket.find({"user_id": user.id}).to_list(None)
    for medium in media:
        await bucket.delete(medium['_id'])
