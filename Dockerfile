FROM python:3.10-slim

# Set working directory inside the container
WORKDIR /app

# Copy requirements and install dependencies
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy the app code
COPY app.py .

# Expose port 5000 and run the server
EXPOSE 5000
CMD ["python3", "app.py"]