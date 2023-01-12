## How to run the climbingAPI locally

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