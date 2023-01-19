from fastapi_auth0 import Auth0

from .config import settings

auth = Auth0(domain=settings.AUTH0_DOMAIN, api_audience=settings.AUTH0_API_AUDIENCE, scopes={
    'write:diary': 'write anything but media',
    'read:diary': 'read anything but media',
})
