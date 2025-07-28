# Use Red Hat UBI with Python 3.11
FROM registry.access.redhat.com/ubi9/python-311

# Switch to root to install build dependencies
USER root

# Set working directory
WORKDIR /app

# Install build tools and compile SQLite 3.50.3
RUN dnf install -y gcc make wget tar sqlite-devel \
    && wget https://www.sqlite.org/2025/sqlite-autoconf-3500300.tar.gz \
    && tar -xzf sqlite-autoconf-3500300.tar.gz \
    && cd sqlite-autoconf-3500300 \
    && ./configure --prefix=/usr/local \
    && make && make install \
    && ln -sf /usr/local/lib/libsqlite3.so.0 /usr/lib64/libsqlite3.so.0 \
    && cd .. && rm -rf sqlite-autoconf-3500300*

# Ensure Python picks up the new SQLite
ENV LD_LIBRARY_PATH=/usr/local/lib

# Copy application code
COPY . /app

# Install Python packages
RUN pip install --upgrade pip && \
    pip install --no-cache-dir -r requirements.txt

# Switch back to non-root user (required by OpenShift for runtime security)
USER 1001

# Expose the FastAPI port
EXPOSE 8000

# Start the FastAPI app with uvicorn
CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000"]
