FROM python:3.12-slim
 
WORKDIR /app
 
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY etl.py .

CMD ["python", "etl.py"]

'''
In windows powershell, 
run below code to run a data extraction script inside an isolated Docker container which will store data in data folder in the form of json.

docker run --rm `
  -e DATABASE_URL="" `
  -v "${PWD}/data:/data" `
  quake-etl python -c "import etl; etl.extract()"
'''
