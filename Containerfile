# Use Red Hat UBI with Python 3.11
FROM registry.access.redhat.com/ubi9/python-311

# Switch to root to install dependencies
USER root

# Set working directory
WORKDIR /app

# Install system-level build dependencies and compile SQLite 3.50.3
RUN dnf install -y gcc make wget tar sqlite-devel python3-devel \
    && wget https://www.sqlite.org/2025/sqlite-autoconf-3500300.tar.gz \
    && tar -xzf sqlite-autoconf-3500300.tar.gz \
    && cd sqlite-autoconf-3500300 \
    && ./configure --prefix=/usr/local CFLAGS="-DSQLITE_ENABLE_FTS5" \
    && make && make install \
    && ln -sf /usr/local/lib/libsqlite3.so.0 /usr/lib64/libsqlite3.so.0 \
    && cd .. && rm -rf sqlite-autoconf-3500300*

# Ensure Python loads the newer SQLite
ENV LD_LIBRARY_PATH=/usr/local/lib

# Copy application code
COPY . /app

RUN pip uninstall -y chromadb chroma-hnswlib || true && \
    pip install --no-cache-dir chromadb==0.6.3

# Install Python packages (ensure build dependencies for chromadb)
RUN pip install --upgrade pip setuptools wheel build && \
    pip install --no-cache-dir -r requirements.txt

# (Optional) Debug: Confirm chromadb was installed
RUN python3 -c "import chromadb; print('ChromaDB version:', chromadb.__version__)"

# Switch back to non-root user for OpenShift
USER 1001

# Expose FastAPI's port
EXPOSE 8000

# Start FastAPI app
CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000"]
