import re

def split_markdown_into_chunks(file_path, paragraphs_per_chunk=8):
    with open(file_path, 'r', encoding='utf-8') as file:
        content = file.read()

    # Split content into paragraphs using blank lines as separators
    paragraphs = re.split(r'\n\s*\n', content.strip())

    # Group paragraphs into chunks
    chunks = [
        paragraphs[i:i + paragraphs_per_chunk]
        for i in range(0, len(paragraphs), paragraphs_per_chunk)
    ]

    print(f"Total number of chunks: {len(chunks)}")
    return chunks

# Usage
if __name__ == "__main__":
    file_path = "quantumpulse-3000.md"  # Replace with your Markdown file path
    chunks = split_markdown_into_chunks(file_path)

