import datetime
from typing import List

from fastapi import APIRouter, Body, Depends, HTTPException, Security, status
from fastapi.encoders import jsonable_encoder
from fastapi.responses import JSONResponse
from fastapi_auth0 import Auth0User

from app.core.db import get_db
from app.core.auth import auth

from app.models.ascent.ascent_model import AscentModel
from app.models.ascent.update_ascent_model import UpdateAscentModel

router = APIRouter()


@router.post('/pitch/{pitch_id}', description="Create a new ascent", response_model=AscentModel, dependencies=[Depends(auth.implicit_scheme)])
async def create_ascent_for_pitch(pitch_id: str, ascent: AscentModel = Body(...), user: Auth0User = Security(auth.get_user, scopes=["write:diary"])):
    ascent = jsonable_encoder(ascent)
    ascent["user_id"] = user.id
    if not ascent["media_ids"]: ascent["media_ids"] = []
    ascent["updated"] = datetime.datetime.now()
    db = await get_db()
    pitch = await db["pitch"].find_one({"_id": pitch_id, "user_id": user.id})
    if pitch is None:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail=f"Pitch {pitch_id} not found")
    # pitch exists
    if await db["ascent"].find({"user_id": user.id, "comment": ascent["comment"], "date": ascent["date"], "type": ascent["type"], "style": ascent["style"], "_id": {"$in": pitch["ascent_ids"]}}).to_list(None):
        raise HTTPException(status_code=status.HTTP_409_CONFLICT, detail="Ascent already exists")
    # ascent does not already exist
    new_ascent = await db["ascent"].insert_one(ascent)
    # created ascent
    created_ascent = await db["ascent"].find_one({"_id": new_ascent.inserted_id})
    if created_ascent is None:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND,
                            detail=f"Ascent {new_ascent.inserted_id} not found")
    # ascent was found
    update_result = await db["pitch"].update_one({"_id": pitch_id}, {"$set": {"updated": datetime.datetime.now()}, "$push": {"ascent_ids": new_ascent.inserted_id}})
    if update_result.modified_count != 1:
        raise HTTPException(status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
                            detail=f"Ascent {new_ascent.inserted_id} was not added to pitch {pitch_id}")
    # ascent_id was added to pitch
    return JSONResponse(status_code=status.HTTP_201_CREATED,
                        content=jsonable_encoder(AscentModel(**created_ascent)))


@router.post('/route/{route_id}', description="Create a new ascent", response_model=AscentModel, dependencies=[Depends(auth.implicit_scheme)])
async def create_ascent_for_single_pitch_route(route_id: str, ascent: AscentModel = Body(...), user: Auth0User = Security(auth.get_user, scopes=["write:diary"])):
    ascent = jsonable_encoder(ascent)
    ascent["user_id"] = user.id
    ascent["media_ids"] = []
    ascent["updated"] = datetime.datetime.now()
    db = await get_db()
    route = await db["single_pitch_route"].find_one({"_id": route_id, "user_id": user.id})
    if route is None:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail=f"Single pitch route {route_id} not found")
    # pitch exists
    if await db["ascent"].find({"user_id": user.id, "comment": ascent["comment"], "date": ascent["date"], "type": ascent["type"], "style": ascent["style"], "_id": {"$in": route["ascent_ids"]}}).to_list(None):
        raise HTTPException(status_code=status.HTTP_409_CONFLICT, detail="Ascent already exists")
    # ascent does not already exist
    new_ascent = await db["ascent"].insert_one(ascent)
    # created ascent
    created_ascent = await db["ascent"].find_one({"_id": new_ascent.inserted_id})
    if created_ascent is None:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND,
                            detail=f"Ascent {new_ascent.inserted_id} not found")
    # ascent was found
    update_result = await db["single_pitch_route"].update_one({"_id": route_id}, {"$set": {"updated": datetime.datetime.now()}, "$push": {"ascent_ids": new_ascent.inserted_id}})
    if update_result.modified_count != 1:
        raise HTTPException(status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
                            detail=f"Ascent {new_ascent.inserted_id} was not added to route {route_id}")
    # ascent_id was added to pitch
    return JSONResponse(status_code=status.HTTP_201_CREATED,
                        content=jsonable_encoder(AscentModel(**created_ascent)))


@router.get('/{ascent_id}', description="Retrieve an ascent", response_model=AscentModel, dependencies=[Depends(auth.implicit_scheme)])
async def retrieve_ascent_of_id(ascent_id: str, user: Auth0User = Security(auth.get_user, scopes=["read:diary"])):
    db = await get_db()
    if (ascent := await db["ascent"].find_one({"_id": ascent_id, "user_id": user.id})) is not None:
        return ascent
    raise HTTPException(status_code=status.HTTP_404_NOT_FOUND,
                        detail=f"Ascent {ascent_id} not found.")


@router.post('/ids', description="Get ascents of ids", response_model=List[AscentModel], dependencies=[Depends(auth.implicit_scheme)])
async def retrieve_ascents_of_ids(ascent_ids: List[str] = Body(...), user: Auth0User = Security(auth.get_user, scopes=["read:diary"])):
    if not ascent_ids:
        return []
    db = await get_db()
    ascents = []
    for ascent_id in ascent_ids:
        if (ascent := await db["ascent"].find_one({"_id": ascent_id, "user_id": user.id})) is not None:
            ascents.append(ascent)
        else:
            raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail=f"Ascent {ascent_id} not found")
    if ascents:
        return ascents
    raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail=f"Ascents not found")


@router.get('', description="Retrieve all ascents", response_model=List[AscentModel], dependencies=[Depends(auth.implicit_scheme)])
async def retrieve_all_ascents(user: Auth0User = Security(auth.get_user, scopes=["read:diary"])):
    db = await get_db()
    ascents = await db["ascent"].find({"user_id": user.id}).to_list(None)
    return ascents


@router.put('/{ascent_id}', description="Update an ascent", response_model=AscentModel, dependencies=[Depends(auth.implicit_scheme)])
async def update_ascent(ascent_id: str, ascent: UpdateAscentModel = Body(...), user: Auth0User = Security(auth.get_user, scopes=["write:diary"])):
    db = await get_db()
    ascent = {k: v for k, v in ascent.dict().items() if v is not None}
    ascent['updated'] = datetime.datetime.now()

    if len(ascent) >= 1:
        update_result = await db["ascent"].update_one({"_id": ascent_id}, {"$set": ascent})

        if update_result.modified_count == 1:
            if (
                updated_ascent := await db["ascent"].find_one({"_id": ascent_id})
            ) is not None:
                return updated_ascent

    if (existing_ascent := await db["ascent"].find_one({"_id": ascent_id})) is not None:
        return existing_ascent

    raise HTTPException(status_code=status.HTTP_404_NOT_FOUND,
                        detail=f"Ascent {ascent_id} not found")


@router.delete('/{ascent_id}/pitch/{pitch_id}', description="Delete an ascent", response_model=AscentModel, dependencies=[Depends(auth.implicit_scheme)])
async def delete_ascent_from_pitch(pitch_id: str, ascent_id: str, user: Auth0User = Security(auth.get_user, scopes=["write:diary"])):
    db = await get_db()
    pitch = await db["pitch"].find_one({"_id": pitch_id, "user_id": user.id})
    if pitch is None:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND,
                            detail=f"Pitch {pitch_id} not found")
    # pitch was found
    ascent = await db["ascent"].find_one({"_id": ascent_id, "user_id": user.id})
    if ascent is None:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND,
                            detail=f"Ascent {ascent_id} not found")
    # ascent was found
    if await db["pitch"].find_one({"_id": pitch_id, "ascent_ids": ascent_id}) is None:
        raise HTTPException(status_code=status.HTTP_409_CONFLICT,
                            detail=f"Ascent {ascent_id} does not belong to pitch {pitch_id}")
    # ascent belongs to pitch
    delete_result = await db["ascent"].delete_one({"_id": ascent_id})
    if delete_result.deleted_count != 1:
        raise HTTPException(status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
                            detail=f"Ascent {ascent_id} could not be deleted")
    # ascent was deleted
    update_result = await db["pitch"].update_one({"_id": pitch_id}, {"$set": {"updated": datetime.datetime.now()}, "$pull": {"ascent_ids": ascent_id}})
    if update_result.modified_count != 1:
        raise HTTPException(status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
                            detail=f"Removing ascent_id {ascent_id} from pitch {pitch_id} failed")
    # ascent_id was removed
    updated_pitch = await db["pitch"].find_one({"_id": pitch_id})
    for media_id in ascent["media_ids"]:
        await db["medium"].delete_one({"_id": media_id})
    # media deleted
    if updated_pitch is not None:
        return ascent
    else:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=f"Pitch {pitch_id} not found"
        )


@router.delete('/{ascent_id}/route/{route_id}', description="Delete an ascent", response_model=AscentModel, dependencies=[Depends(auth.implicit_scheme)])
async def delete_ascent_from_single_pitch_route(route_id: str, ascent_id: str, user: Auth0User = Security(auth.get_user, scopes=["write:diary"])):
    db = await get_db()
    pitch = await db["single_pitch_route"].find_one({"_id": route_id, "user_id": user.id})
    if pitch is None:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=f"Single pitch route {route_id} not found"
        )
    # pitch was found
    ascent = await db["ascent"].find_one({"_id": ascent_id, "user_id": user.id})
    if ascent is None:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=f"Ascent {ascent_id} not found"
        )
    # ascent was found
    if await db["single_pitch_route"].find_one({"_id": route_id, "ascent_ids": ascent_id}) is None:
        raise HTTPException(
            status_code=status.HTTP_409_CONFLICT,
            detail=f"Ascent {ascent_id} does not belong to pitch {route_id}"
        )
    # ascent belongs to pitch
    delete_result = await db["ascent"].delete_one({"_id": ascent_id})
    if delete_result.deleted_count != 1:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Ascent {ascent_id} could not be deleted"
        )
    # ascent was deleted
    update_result = await db["single_pitch_route"].update_one({"_id": route_id}, {"$set": {"updated": datetime.datetime.now()}, "$pull": {"ascent_ids": ascent_id}})
    if update_result.modified_count != 1:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Removing ascent_id {ascent_id} from pitch {route_id} failed"
        )
    # ascent_id was removed
    update_route = await db["single_pitch_route"].find_one({"_id": route_id})
    for media_id in ascent["media_ids"]:
        await db["medium"].delete_one({"_id": media_id})
    # media deleted
    if update_route is not None:
        return ascent
    else:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=f"Single pitch route {route_id} not found"
        )

