#!/usr/bin/env python3
from fastapi import FastAPI, HTTPException
from pydantic import BaseModel
from typing import List, Optional
import argparse
import uvicorn
from chat import ChatWithHistory
from chat_responses import TextResponse

app = FastAPI()
chat_bot = ChatWithHistory(response_type=TextResponse)

class UserMessage(BaseModel):
    id: int
    text: str
    isUser: bool = True

class GenericMessage(BaseModel):
    message_type: str
    json_content: str

@app.post("/chat", response_model=GenericMessage)
def chat(user_message: UserMessage):
    response = chat_bot.chat(user_message.text)
    return GenericMessage(message_type="text", json_content=response.json())

def parse_args():
    parser = argparse.ArgumentParser(description="Run the FastAPI server.")
    parser.add_argument("--host", type=str, default="127.0.0.1", help="Host IP address")
    parser.add_argument("--port", type=int, default=8000, help="Port number")
    return parser.parse_args()

if __name__ == "__main__":
    args = parse_args()
    uvicorn.run(app, host=args.host, port=args.port)
