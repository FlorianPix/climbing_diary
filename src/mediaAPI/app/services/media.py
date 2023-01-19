import os
from uuid import UUID
from sqlalchemy import func
from fastapi import HTTPException
from sqlalchemy.orm import Session

from app.core.objectStorage import externalStorageClient
from app.models.db_schema import DbExternalStorageMedia


def get_all_user_media(db: Session, user_id: str) -> list[DbExternalStorageMedia]:
    return db.query(DbExternalStorageMedia).filter(DbExternalStorageMedia.user_id == user_id).all()

def get_media(db: Session, media_id: UUID, user_id: str) -> str:
    result = db.query(DbExternalStorageMedia).filter(DbExternalStorageMedia.id == media_id).first()
    if not result:
        raise HTTPException(status_code=404, detail="Item not found")
    if result.user_id != user_id:
        raise HTTPException(status_code=403, detail="You are not allowed to access this item")
    url = externalStorageClient.get_file_url(_get_object_name(user_id, media_id))
    return url

def delete_media(db: Session, media_id: UUID, user_id: str):
    result = db.query(DbExternalStorageMedia).filter(DbExternalStorageMedia.id == media_id).first()
    if not result:
        raise HTTPException(status_code=404, detail="Item not found")
    if result.user_id != user_id:
        raise HTTPException(status_code=403, detail="You are not allowed to access this item")
    try:
        externalStorageClient.delete_file(_get_object_name(user_id, media_id))
    except Exception:
        raise HTTPException(status_code=500, detail="Failed to delete media")
    db.delete(result)
    db.commit()

def create_media(db: Session, filename, original_filename, user_id: str):
    media_object = DbExternalStorageMedia(
        user_id=user_id,
        title=original_filename,
        created_at = func.now()
    )
    db.add(media_object)
    db.commit()
    db.refresh(media_object)
    try:
        externalStorageClient.upload_file(filename, _get_object_name(user_id, media_object.id))
    except Exception:
        db.delete(media_object)
        db.commit()
        raise HTTPException(status_code=500, detail="Failed to upload media")
    finally:
        os.remove(filename)
    return media_object

def _get_object_name(user_id: int, media_id: int):
    # replace disallowed characters in user_id
    user_id = user_id.replace("/", "_").replace("\\", "_").replace(" ", "_").replace(":", "_").replace("|", "_")
    return f"u-{user_id}/{media_id}"

