from fastapi import FastAPI
from fastapi.responses import JSONResponse
import re
import os

app = FastAPI()

def split_markdown_into_chunks(file_path, paragraphs_per_chunk=8):
    if not os.path.exists(file_path):
        return 0  # Return 0 if file doesn't exist

    with open(file_path, 'r', encoding='utf-8') as file:
        content = file.read()

    paragraphs = re.split(r'\n\s*\n', content.strip())

    chunks = [
        paragraphs[i:i + paragraphs_per_chunk]
        for i in range(0, len(paragraphs), paragraphs_per_chunk)
    ]

    return len(chunks)

@app.get("/api/v1/chunks")
def get_chunks_count():
    file_path = "quantumpulse-3000.md"  # Replace or make configurable if needed
    num_chunks = split_markdown_into_chunks(file_path)
    return JSONResponse(content={"chunks": num_chunks})
