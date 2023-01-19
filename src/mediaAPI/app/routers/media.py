from uuid import UUID
from fastapi import APIRouter, Depends, File, HTTPException, UploadFile, Response, Depends, Security
from tempfile import NamedTemporaryFile
from sqlalchemy.orm import Session
from fastapi_auth0 import Auth0User

from app.models.external_storage_media_model import ExternalStorageMedia
from app.models.external_storage_media_url_model import ExternalStorageMediaUrl
from app.core.db import get_db
from app.services import media as media_service
from app.core.auth import auth

router = APIRouter()

@router.get("", tags=["media"], response_model=list[ExternalStorageMedia], dependencies=[Depends(auth.implicit_scheme)])
def get_all_media(db: Session = Depends(get_db), user: Auth0User = Security(auth.get_user, scopes=["read:media"])):
    return media_service.get_all_user_media(db, user.id)

@router.get("/{id}/access-url", tags=["media"], response_model=ExternalStorageMediaUrl, dependencies=[Depends(auth.implicit_scheme)])
def get_media_link(id: UUID, db: Session = Depends(get_db), user: Auth0User = Security(auth.get_user, scopes=["read:media"])):
    url = media_service.get_media(db, id, user.id)
    return { "url": url, "id": id }

@router.post("", tags=["media"], response_model=ExternalStorageMedia, dependencies=[Depends(auth.implicit_scheme)])
def upload_media_file(file: UploadFile = File(...), db: Session = Depends(get_db), user: Auth0User = Security(auth.get_user, scopes=["write:media"])):
    temp = NamedTemporaryFile(delete=False)
    try:
        with temp as f:
            while contents := file.file.read(1024 * 1024):
                f.write(contents)
    except Exception:
        raise HTTPException(status_code=500, detail="Failed to upload media")
    finally:
        file.file.close()
    
    return media_service.create_media(db, temp.name, file.filename, user.id)

@router.delete("/{id}", tags=["media"], status_code=204, response_class=Response, dependencies=[Depends(auth.implicit_scheme)])
def delete_media(id: UUID, db: Session = Depends(get_db), user: Auth0User = Security(auth.get_user, scopes=["write:media"])):
    media_service.delete_media(db, id, user.id)
