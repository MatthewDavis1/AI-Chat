#!/usr/bin/env python3
from fastapi import FastAPI, HTTPException
from pydantic import BaseModel
from typing import List, Optional
import argparse
import uvicorn
from langchain_openai import OpenAI
from langchain.prompts import PromptTemplate
from langchain_core.runnables.base import RunnableSequence
from langchain.memory import ConversationBufferMemory

app = FastAPI()

class UserMessage(BaseModel):
    id: int
    text: str
    isUser: bool = True

class BaseMessage(BaseModel):
    id: int
    text: str
    isUser: bool

class TextMessage(BaseMessage):
    pass

class MultiSelectMessage(BaseMessage):
    options: List[str]

class PickerMessage(BaseMessage):
    options: List[str]

class RatingMessage(BaseMessage):
    range: List[float]
    step: float
    scaleType: str
    isInteger: bool

class YesNoMessage(BaseMessage):
    pass

# Initialize conversation memory
conversation_memory = ConversationBufferMemory()

@app.get("/")
def read_root():
    return {"Hello": "World"}

@app.post("/chat", response_model=BaseMessage)
def chat(user_message: UserMessage):
    try:
        llm = OpenAI()
        
        prompt = PromptTemplate(
            input_variables=["message", "history"],
            template="""
            You are an intelligent assistant. Based on the user message below and the conversation history, decide the type of response to send.
            The response should be a JSON object with the following structure:

            {
                "type": "text" | "multi-select" | "picker" | "rating" | "yes-no",
                "content": {
                    "text": "Your response text here",
                    "options": ["Option1", "Option2", ...], // for multi-select and picker
                    "range": [min, max], // for rating
                    "step": step_value, // for rating
                    "scaleType": "oneToTen" | "zeroToHundred", // for rating
                    "isInteger": true | false // for rating
                }
            }

            Conversation history:
            {history}

            User message: "{message}"
            """,
        )

        # Append user message to conversation memory
        conversation_memory.append({"role": "user", "content": user_message.text})

        # Use RunnableSequence instead of LLMChain
        chain = prompt | llm
        response = chain.invoke({"message": user_message.text, "history": conversation_memory.get()})
        
        # Parse the JSON response
        import json
        response_data = json.loads(response)
        
        response_type = response_data.get("type")
        content = response_data.get("content", {})

        message_id = user_message.id + 1  # Simple ID increment

        # Append assistant response to conversation memory
        conversation_memory.append({"role": "assistant", "content": content.get("text", "")})

        if response_type == "text":
            return TextMessage(id=message_id, text=content.get("text", ""), isUser=False)
        elif response_type == "multi-select":
            return MultiSelectMessage(
                id=message_id,
                text=content.get("text", ""),
                isUser=False,
                options=content.get("options", [])
            )
        elif response_type == "picker":
            return PickerMessage(
                id=message_id,
                text=content.get("text", ""),
                isUser=False,
                options=content.get("options", [])
            )
        elif response_type == "rating":
            return RatingMessage(
                id=message_id,
                text=content.get("text", ""),
                isUser=False,
                range=content.get("range", [1.0, 10.0]),
                step=content.get("step", 1.0),
                scaleType=content.get("scaleType", "oneToTen"),
                isInteger=content.get("isInteger", True)
            )
        elif response_type == "yes-no":
            return YesNoMessage(
                id=message_id,
                text=content.get("text", ""),
                isUser=False
            )
        else:
            raise HTTPException(status_code=400, detail="Invalid response type from LLM")
    
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

def parse_args():
    parser = argparse.ArgumentParser(description="Run the FastAPI server.")
    parser.add_argument("--host", type=str, default="127.0.0.1", help="Host IP address")
    parser.add_argument("--port", type=int, default=8000, help="Port number")
    return parser.parse_args()

if __name__ == "__main__":
    args = parse_args()
    uvicorn.run(app, host=args.host, port=args.port)
