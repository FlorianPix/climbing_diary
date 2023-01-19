import boto3
from botocore.client import Config

from app.core.config import settings

class ExternalStorageClient:

    s3resource = None
    bucket_name = None

    def __init__(self, endpoint, key_id, secret, bucket_name, sig_version):
        self.s3resource = boto3.resource(
            's3',
            endpoint_url=endpoint,
            aws_access_key_id=key_id,
            aws_secret_access_key=secret,
            config=Config(signature_version=sig_version)
        )
        self.bucket_name = bucket_name
    
    def upload_file(self, filename, object_name):
        self.s3resource.meta.client.upload_file(filename, self.bucket_name, object_name)
    
    def delete_file(self, object_name):
        self.s3resource.Object(self.bucket_name, object_name).delete()
    
    def get_file_url(self, object_name) -> str:
        return self.s3resource.meta.client.generate_presigned_url('get_object', Params={'Bucket': self.bucket_name, 'Key': object_name}, ExpiresIn=3600)

externalStorageClient = ExternalStorageClient(settings.S3_ENDPOINT_URL, settings.S3_ACCESS_KEY_ID, settings.S3_SECRET_ACCESS_KEY, settings.S3_BUCKET_NAME, settings.S3_SIGNATURE_VERSION)
