from typing import List

import boto3
from fastapi import APIRouter, Body, HTTPException, status
from fastapi.encoders import jsonable_encoder
from fastapi.responses import Response, JSONResponse

from .models.spot_model import SpotModel
from .models.update_spot_model import UpdateSpotModel

import os

router = APIRouter()
# we use Cloudflare R2 with the S3 API
s3 = boto3.resource('s3')


@router.post("/media", response_description="Add new media")
async def upload_media():
    for bucket in s3.buckets.all():
        print(bucket.name)
