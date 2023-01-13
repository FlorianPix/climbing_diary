from typing import List, Optional, Union

from pydantic import AnyHttpUrl, BaseSettings, MongoDsn, validator


class Settings(BaseSettings):
    PROJECT_NAME: str
    BACKEND_CORS_ORIGINS: List[AnyHttpUrl] = []

    @validator("BACKEND_CORS_ORIGINS", pre=True)
    def assemble_cors_origins(cls, v: Union[str, List[str]]) -> Union[List[str], str]:
        if isinstance(v, str) and not v.startswith("["):
            return [i.strip() for i in v.split(",")]
        elif isinstance(v, (list, str)):
            return v
        raise ValueError(v)

    DATABASE_URI: MongoDsn

    AUTH0_DOMAIN: str
    AUTH0_API_AUDIENCE: str

    SERVER_IP: Optional[str] = "127.0.0.1"
    SERVER_PORT: Optional[int] = 8000

    class Config:
        case_sensitive = True
        env_file = ".env"


settings = Settings()
