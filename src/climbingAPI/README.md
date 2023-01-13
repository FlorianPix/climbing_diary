# How to run the climbingAPI locally

## with docker

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
    docker build -t cd-diary .
    ```

2. Run the containers:

    ```bash
    docker compose up
    ```


## without docker

```bash
# Install the requirements:
pip install -r requirements.txt

# Configure the location of your MongoDB database:
# Replace <username> and <password> !
export MONGODB_URL="mongodb+srv://<username>:<password>@<url>/<db>?retryWrites=true&w=majority"

# Start the service:
uvicorn main:app --reload
```

Now you can load http://localhost:8000/docs in your browser.