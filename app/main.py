import uvicorn
from fastapi import FastAPI

from routers import pitches, spots, routes

app = FastAPI()

app.include_router(spots.router)
app.include_router(routes.router)
app.include_router(pitches.router)

if __name__ == "__main__":
    uvicorn.run(app, host="127.0.0.1", port=8000)
