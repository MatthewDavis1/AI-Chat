from pydantic import BaseModel
from typing import List, Union

class BaseMessage(BaseModel):
    text: str

class TextMessage(BaseMessage):
    pass

class MultiSelectMessage(BaseMessage):
    options: List[str]

class PickerMessage(BaseMessage):
    options: List[str]

class RatingMessage(BaseMessage):
    range_low: int
    range_high: int

class YesNoMessage(BaseMessage):
    pass

class ChatResponse(BaseModel):
    message: Union[TextMessage, MultiSelectMessage, PickerMessage, RatingMessage, YesNoMessage]
