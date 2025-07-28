FROM registry.access.redhat.com/ubi9/python-311

# Switch to root to install build dependencies
USER root

WORKDIR /app

# Install SQLite 3.44 and other tools
RUN dnf install -y gcc make wget tar sqlite-devel \
    && wget https://www.sqlite.org/2024/sqlite-autoconf-3440000.tar.gz \
    && tar -xzf sqlite-autoconf-3440000.tar.gz \
    && cd sqlite-autoconf-3440000 \
    && ./configure --prefix=/usr/local \
    && make && make install \
    && ln -sf /usr/local/lib/libsqlite3.so.0 /usr/lib64/libsqlite3.so.0 \
    && cd .. && rm -rf sqlite-autoconf-3440000*

# Set dynamic linker path so Python picks up the new SQLite
ENV LD_LIBRARY_PATH=/usr/local/lib

# Copy app code
COPY . /app

# Install Python packages as root (still safe at build time)
RUN pip install --upgrade pip && \
    pip install --no-cache-dir -r requirements.txt

# Switch back to default non-root user for runtime
USER 1001

EXPOSE 8000

CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000"]
