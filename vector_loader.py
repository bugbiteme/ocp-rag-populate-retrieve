from chromadb.api.client import Client
from chromadb.config import Settings

def load_to_chroma(chunks):
    client = Client(Settings(
        chroma_server_host="chroma.player1.svc.cluster.local",
        chroma_server_http_port=8080,
    ))

    collection = client.get_or_create_collection(name="quantumpulse_chunks")

    collection.add(
        documents=chunks,
        ids=[f"chunk-{i}" for i in range(len(chunks))]
    )
