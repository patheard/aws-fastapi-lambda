from fastapi import FastAPI
from mangum import Mangum

app = FastAPI(
    title="AWS + FastAPI",
    description="AWS API Gateway, Lambdas and FastAPI (oh my)",
)


@app.get("/")
def read_root():
    return {"Hello": "World"}


# Mangum allows us to use Lambdas to process requests
handler = Mangum(app=app)
