import json
import main
from unittest.mock import call, MagicMock, patch


def test_hello():
    assert main.hello() == {"Hello": "World"}


@patch("main.boto3")
@patch("main.datetime")
@patch("main.MESSAGE_QUEUE_NAME", "Muffins")
@patch("main.REGION", "us-east-1")
def test_produce(MockDateTime, MockBoto):
    response = MagicMock()
    response.get.return_value = "42"
    queue = MagicMock()
    queue.send_message.return_value = response
    sqs = MagicMock()
    sqs.get_queue_by_name.return_value = queue
    MockBoto.resource.return_value = sqs
    MockDateTime.now.return_value = "1970-01-01"

    assert main.produce() == {"message_id": "42"}

    MockBoto.resource.assert_called_with("sqs", region_name="us-east-1")
    sqs.get_queue_by_name.assert_called_with(QueueName="Muffins")
    queue.send_message.assert_called_with(
        MessageBody=json.dumps({"date": "1970-01-01", "flavour": "delicious"})
    )


def test_produce_no_queue():
    assert main.produce() == {"error": "Message queue name not set"}
