#!/usr/bin/env python3

from fastapi import FastAPI, HTTPException, Request
from fastapi.responses import JSONResponse
from fastapi.exceptions import RequestValidationError
from starlette.exceptions import HTTPException as StarletteHTTPException
from pydantic import BaseModel
from typing import List, Optional
import argparse
import uvicorn

from chat import ChatWithHistory
from chat_responses import (
    ChatResponse,
    TextMessage,
    MultiSelectMessage,
    PickerMessage,
    RatingMessage,
    YesNoMessage,
)

app = FastAPI()
chat_bot = ChatWithHistory() # Default response type is ChatResponse

class UserMessage(BaseModel):
    text: str

class GenericMessage(BaseModel):
    message_type: str
    json_content: str

@app.post("/chat", response_model=GenericMessage)
def chat(user_message: UserMessage):
    try:
        response = chat_bot.chat(user_message.text).message
        if isinstance(response, TextMessage):
            return GenericMessage(message_type="TextMessage", json_content=response.json())
        elif isinstance(response, MultiSelectMessage):
            return GenericMessage(message_type="MultiSelectMessage", json_content=response.json())
        elif isinstance(response, PickerMessage):
            return GenericMessage(message_type="PickerMessage", json_content=response.json())
        elif isinstance(response, RatingMessage):
            return GenericMessage(message_type="RatingMessage", json_content=response.json())
        elif isinstance(response, YesNoMessage):
            return GenericMessage(message_type="YesNoMessage", json_content=response.json())
        else:
            raise HTTPException(status_code=500, detail="Unknown response type")
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@app.exception_handler(StarletteHTTPException)
async def custom_http_exception_handler(request: Request, exc: StarletteHTTPException):
    print(f"HTTP error occurred: {repr(exc)}")
    print(f"Request: {request.method} {request.url}")
    return JSONResponse(
        status_code=exc.status_code,
        content={"detail": exc.detail},
    )

@app.exception_handler(RequestValidationError)
async def validation_exception_handler(request: Request, exc: RequestValidationError):
    print(f"Validation error occurred: {exc}")
    print(f"Request: {request.method} {request.url}")
    return JSONResponse(
        status_code=422,
        content={"detail": exc.errors(), "body": exc.body},
    )

def parse_args():
    parser = argparse.ArgumentParser(description="Run the FastAPI server.")
    parser.add_argument("--host", type=str, default="127.0.0.1", help="Host IP address")
    parser.add_argument("--port", type=int, default=8000, help="Port number")
    return parser.parse_args()

if __name__ == "__main__":
    args = parse_args()
    uvicorn.run(app, host=args.host, port=args.port)
