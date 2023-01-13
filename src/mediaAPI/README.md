# media-api

## Run locally for development

1. Start database with docker-compose:

    ```bash
    docker compose -f docker-compose.db-only.yml up
    ```

2. Start the server:

    ```bash
    uvicorn app.main:app --reload
    ```

3. When you are done, stop the server by pressing `Ctrl+C` and the database by running:

    ```bash
    docker compose -f docker-compose.db-only.yml down
    ```

## Run Staging in docker

1. Build the image:

    ```bash
    docker build -t cd-media .
    ```

2. Run the containers:

    ```bash
    docker compose up
    ```
