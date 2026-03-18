
import json
import logging
logger = logging.getLogger()
logger.setLevel(logging.INFO)
def lambda_handler(event, context):
    # TODO implement
    if event:
        logger.info("Received event: %s", json.dumps(event))
        return {
            'statusCode': 200,
            'body': json.dumps('Hello from DEEPDIVER Inside the Authorization Layer!')
        }
    else:
        return {
            'statusCode': 400,
            'body': json.dumps('No event received')
        }

