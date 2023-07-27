import datetime
from typing import List, Tuple

from fastapi import APIRouter, Body, Depends, HTTPException, Security, status
from fastapi.encoders import jsonable_encoder
from fastapi.responses import Response, JSONResponse
from fastapi_auth0 import Auth0User
from bson import ObjectId

from app.core.db import get_db
from app.core.auth import auth
from app.models.trip.trip_model import TripModel
from app.models.trip.create_trip_model import CreateTripModel
from app.models.trip.update_trip_model import UpdateTripModel
from app.models.id_with_datetime import IdWithDatetime

router = APIRouter()


@router.post('', description="Add a new trip", response_model=TripModel, dependencies=[Depends(auth.implicit_scheme)])
async def create_trip(trip: CreateTripModel = Body(...), user: Auth0User = Security(auth.get_user, scopes=["write:diary"])):
    trip = jsonable_encoder(trip)
    trip["user_id"] = user.id
    trip["spot_ids"] = []
    trip["media_ids"] = []
    trip["updated"] = datetime.datetime.now()
    db = await get_db()
    # check if trip already exists
    if (trips := await db["trip"].find({
        "name": trip["name"],
        "user_id": user.id
    }).to_list(None)):
        raise HTTPException(status_code=status.HTTP_409_CONFLICT, detail="Trip already exists")
    new_trip = await db["trip"].insert_one(trip)
    created_trip = await db["trip"].find_one({"_id": new_trip.inserted_id})
    return JSONResponse(status_code=status.HTTP_201_CREATED, content=jsonable_encoder(TripModel(**created_trip)))


@router.get('/{trip_id}', description="Get a trip", response_model=TripModel, dependencies=[Depends(auth.implicit_scheme)])
async def retrieve_trip_of_id(trip_id: str, user: Auth0User = Security(auth.get_user, scopes=["read:diary"])):
    db = await get_db()
    if (trip := await db["trip"].find_one({"_id": ObjectId(trip_id), "user_id": user.id})) is not None:
        return trip
    raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail=f"Trip {trip_id} not found")


@router.post('/ids', description="Get trips of ids", response_model=List[TripModel], dependencies=[Depends(auth.implicit_scheme)])
async def retrieve_trips_of_ids(trip_ids: List[str] = Body(...), user: Auth0User = Security(auth.get_user, scopes=["read:diary"])):
    if not trip_ids:
        return []
    db = await get_db()
    trips = []
    for trip_id in trip_ids:
        if (trip := await db["trip"].find_one({"_id": ObjectId(trip_id), "user_id": user.id})) is not None:
            trips.append(trip)
        else:
            raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail=f"Trip {trip_id} not found")
    if trips:
        return trips
    raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail=f"Trips not found")


@router.get('', description="Retrieve all trips", response_model=List[TripModel], dependencies=[Depends(auth.implicit_scheme)])
async def retrieve_all_trips(user: Auth0User = Security(auth.get_user, scopes=["read:diary"])):
    db = await get_db()
    trips = await db["trip"].find({"user_id": user.id}).to_list(None)
    return trips


@router.get('Updated/{trip_id}', description="Get a trip id and when it was updated", response_model=IdWithDatetime, dependencies=[Depends(auth.implicit_scheme)])
async def retrieve_trip_id_updated(trip_id: str, user: Auth0User = Security(auth.get_user, scopes=["read:diary"])):
    db = await get_db()
    if (idWithDatetime := await db["trip"].find_one({"_id": ObjectId(trip_id), "user_id": user.id}, {"_id": 1, "updated": 1})) is not None:
        return idWithDatetime
    raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail=f"Trip {trip_id} not found")


@router.post('Updated/ids', description="Get trip ids and when they were updated", response_model=List[IdWithDatetime], dependencies=[Depends(auth.implicit_scheme)])
async def retrieve_trip_ids_updated(trip_ids: List[str] = Body(...), user: Auth0User = Security(auth.get_user, scopes=["read:diary"])):
    if not trip_ids:
        return []
    db = await get_db()
    idsWithDatetime = []
    for trip_id in trip_ids:
        if (trip := await db["trip"].find_one({"_id": ObjectId(trip_id), "user_id": user.id}, {"_id": 1, "updated": 1})) is not None:
            idsWithDatetime.append(trip)
        else:
            raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail=f"Trip {trip_id} not found")
    if idsWithDatetime:
        return idsWithDatetime
    raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail=f"Trips not found")


@router.get('Updated', description="Retrieve all trip ids and when they were updated", response_model=List[IdWithDatetime], dependencies=[Depends(auth.implicit_scheme)])
async def retrieve_all_trip_ids_updated(user: Auth0User = Security(auth.get_user, scopes=["read:diary"])):
    db = await get_db()
    trip_ids = await db["trip"].find({"user_id": user.id}, {"_id": 1, "updated": 1}).to_list(None)
    return trip_ids


@router.put('/{trip_id}', description="Update a trip", response_model=TripModel, dependencies=[Depends(auth.implicit_scheme)])
async def update_trip(trip_id: str, trip: UpdateTripModel = Body(...), user: Auth0User = Security(auth.get_user, scopes=["write:diary"])):
    db = await get_db()
    trip = {k: v for k, v in trip.dict().items() if v is not None}
    trip['updated'] = datetime.datetime.now()
    if len(trip) >= 1:
        update_result = await db["trip"].update_one({"_id": ObjectId(trip_id)}, {"$set": trip})
        if update_result.modified_count == 1:
            if (
                updated_trip := await db["trip"].find_one({"_id": ObjectId(trip_id)})
            ) is not None:
                return updated_trip
    if (existing_trip := await db["trip"].find_one({"_id": ObjectId(trip_id)})) is not None:
        return existing_trip
    raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail=f"Trip {trip_id} not found")


@router.delete('/{trip_id}', description="Delete a trip", response_model=TripModel, dependencies=[Depends(auth.implicit_scheme)])
async def delete_trip(trip_id: str, user: Auth0User = Security(auth.get_user, scopes=["write:diary"])):
    db = await get_db()
    trip = await db["trip"].find_one({"_id": ObjectId(trip_id), "user_id": user.id})
    if trip is None:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail=f"Trip {trip_id} not found")
    delete_result = await db["trip"].delete_one({"_id": ObjectId(trip_id)})
    if delete_result.deleted_count == 1:
        return trip
    raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail=f"Trip {trip_id} not found")
