# AIChat Documentation

## Overview
AIChat is a SwiftUI-based chat application that allows users to interact with and AI that can respond with various types of messages, including single-choice, multi-select, yes/no questions, ratings, and normal text.

The server is built using FastAPI with langchain and openai.

## AI Message Types
1. **TextMessage**: A simple text message.
2. **MultiSelectMessage**: A message that allows users to select multiple options.
3. **PickerMessage**: A message that allows users to select a single option from a list.
4. **RatingMessage**: A message that allows users to provide a rating within a specified range.
5. **YesNoMessage**: A message that prompts the user for a yes or no response.

## TODO
- [ ] Fix 'Type A Message' coloring (visible in previews, but not simulator).
- [ ] Ensure the AI gives more consistently varied response types.
