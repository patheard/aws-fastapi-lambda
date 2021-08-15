"""
Main API handler that defines all routes.
"""

import json
import os
from datetime import datetime

import boto3
from fastapi import FastAPI
from mangum import Mangum

MESSAGE_QUEUE_NAME = os.environ.get("MESSAGE_QUEUE_NAME", None)
REGION = os.environ.get("AWS_REGION", "ca-central-1")

app = FastAPI(
    title="AWS + FastAPI",
    description="AWS API Gateway, Lambdas and FastAPI (oh my)",
)


@app.get("/hello")
def hello():
    "Hello path request"
    return {"Hello": "World"}


@app.get("/produce")
def produce():
    "Produce an SQS message"

    if MESSAGE_QUEUE_NAME is None:
        return {"error": "Message queue name not set"}

    message = {"date": datetime.now().isoformat(), "flavour": "delicious"}

    sqs = boto3.resource("sqs", region_name=REGION)
    queue = sqs.get_queue_by_name(QueueName=MESSAGE_QUEUE_NAME)
    response = queue.send_message(MessageBody=json.dumps(message))

    return {"message_id": response.get("MessageId")}


# Mangum allows us to use Lambdas to process requests
handler = Mangum(app=app)
