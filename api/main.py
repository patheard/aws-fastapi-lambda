"""
Main API handler that defines all routes.
"""

from fastapi import FastAPI
from mangum import Mangum

app = FastAPI(
    title="AWS + FastAPI",
    description="AWS API Gateway, Lambdas and FastAPI (oh my)",
)


@app.get("/hello")
def hello():
    "Hello path request"
    return {"Hello": "World"}


# Mangum allows us to use Lambdas to process requests
handler = Mangum(app=app)
