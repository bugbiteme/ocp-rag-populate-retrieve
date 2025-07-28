from fastapi import FastAPI
from fastapi.responses import JSONResponse
import re
import os
from chromadb.client import HttpClient
from chromadb.config import Settings

app = FastAPI()

def split_markdown_into_chunks(file_path, paragraphs_per_chunk=8):
    if not os.path.exists(file_path):
        return []
    
    with open(file_path, 'r', encoding='utf-8') as file:
        content = file.read()

    paragraphs = re.split(r'\n\s*\n', content.strip())

    chunks = [
        "\n\n".join(paragraphs[i:i + paragraphs_per_chunk])
        for i in range(0, len(paragraphs), paragraphs_per_chunk)
    ]

    return chunks

@app.get("/api/v1/chunks")
def get_chunks_count():
    file_path = "quantumpulse-3000.md"
    chunks = split_markdown_into_chunks(file_path)
    return JSONResponse(content={"chunks": len(chunks)})

@app.get("/api/v1/load")
def load_chunks_to_vector_db():
    file_path = "quantumpulse-3000.md"
    chunks = split_markdown_into_chunks(file_path)

    if not chunks:
        return JSONResponse(status_code=404, content={"error": "Markdown file not found or empty"})

    try:
        # Defer chromadb import to avoid SQLite check on startup
        from chromadb.client import HttpClient
        from chromadb.config import Settings

        client = HttpClient(Settings(
            chroma_api_impl="rest",
            chroma_server_host="chroma.player1.svc.cluster.local",
            chroma_server_http_port=8080,
        ))

        collection = client.get_or_create_collection(name="quantumpulse_chunks")

        collection.add(
            documents=chunks,
            ids=[f"chunk-{i}" for i in range(len(chunks))]
        )

        return JSONResponse(content={"status": "success", "chunks_loaded": len(chunks)})

    except Exception as e:
        return JSONResponse(status_code=500, content={"status": "error", "details": str(e)})
