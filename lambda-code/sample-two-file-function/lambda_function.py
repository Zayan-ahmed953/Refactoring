from helper import build_response_message


def lambda_handler(event, context):
    name = (event or {}).get("name", "world")
    message = build_response_message(name)

    return {
        "statusCode": 200,
        "body": message,
    }
