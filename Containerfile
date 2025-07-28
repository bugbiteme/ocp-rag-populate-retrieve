# Build from Red Hat UBI with Python 3.11
FROM registry.access.redhat.com/ubi9/python-311

# Set working directory
WORKDIR /app

# Copy app files
COPY . /app

# Install dependencies
RUN pip install --upgrade pip && \
    pip install --no-cache-dir -r requirements.txt

# Expose FastAPI default port
EXPOSE 8000

# Command to run the app with uvicorn
CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000"]
