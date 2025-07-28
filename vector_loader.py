import os
os.environ["CHROMA_USE_EMBEDDING_DB"] = "false"

def load_to_chroma(chunks):
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
