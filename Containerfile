FROM registry.access.redhat.com/ubi9/python-311

WORKDIR /app

# --- Install build tools and compile SQLite 3.44 ---
RUN dnf install -y gcc make wget tar sqlite-devel \
    && wget https://www.sqlite.org/2024/sqlite-autoconf-3440000.tar.gz \
    && tar -xzf sqlite-autoconf-3440000.tar.gz \
    && cd sqlite-autoconf-3440000 \
    && ./configure --prefix=/usr/local \
    && make && make install \
    && ln -sf /usr/local/lib/libsqlite3.so.0 /usr/lib64/libsqlite3.so.0 \
    && cd .. && rm -rf sqlite-autoconf-3440000*

# Ensure Python loads the new SQLite
ENV LD_LIBRARY_PATH=/usr/local/lib

# Copy your application code
COPY . /app

# Install Python dependencies
RUN pip install --upgrade pip && \
    pip install --no-cache-dir -r requirements.txt

EXPOSE 8000

CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000"]
