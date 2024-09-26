from langchain_openai import ChatOpenAI
from langchain.prompts import ChatPromptTemplate, MessagesPlaceholder
from langchain.schema.runnable import RunnablePassthrough
from langchain.memory import ConversationBufferMemory
from langchain.output_parsers import PydanticOutputParser
from chat_responses import ChatResponse
from prompts import SYSTEM_PROMPT

class ChatWithHistory:
    def __init__(self, model_name="gpt-3.5-turbo", response_type=ChatResponse):
        raw_model = ChatOpenAI(model_name=model_name)
        self.model = raw_model.with_structured_output(response_type)
        self.memory = ConversationBufferMemory(return_messages=True)

        prompt = ChatPromptTemplate.from_messages([
            ("system", SYSTEM_PROMPT),
            MessagesPlaceholder(variable_name="history"),
            ("human", "{input}")
        ])
        
        self.chain = (
            RunnablePassthrough.assign(
                history=lambda x: self.memory.chat_memory.messages
            )
            | prompt
            | self.model
        )
    
    def chat(self, user_input):
        response = self.chain.invoke({"input": user_input})
        print(f"Response Internal: {response}")
        self.memory.chat_memory.add_user_message(user_input)
        self.memory.chat_memory.add_ai_message(str(response))
        return response


########################################################
# Example usage
########################################################

if __name__ == "__main__":
    import sys
    from pydantic import BaseModel

    class TextResponse(BaseModel):
        text: str

    model_name = sys.argv[1] if len(sys.argv) > 1 else "gpt-3.5-turbo"
    chat_bot = ChatWithHistory(model_name=model_name, response_type=TextResponse)
    
    print("Welcome to the chat! Type 'exit' or 'quit' to end the chat.")
    while True:
        user_input = input("You: ")
        if user_input.lower() in ["exit", "quit"]:
            break
        if user_input == '':
            print("Please enter a message.")
            continue
        response = chat_bot.chat(user_input)
        print(f"AI: {response.text}")