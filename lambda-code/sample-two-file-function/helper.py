def build_response_message(name: str) -> str:
    if not name:
        name = "world"
    return f"Hello, {name}! This response came from helper.py"
