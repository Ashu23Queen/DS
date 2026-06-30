import asyncio
from fastapi import FastAPI
import gcsfs

app = FastAPI(title="Async GCP Extractor")

# Instantiate with asynchronous=True
fs = gcsfs.GCSFileSystem(project="your-gcp-project-id", asynchronous=True)

@app.get("/extract-gcp")
async def extract_data_from_gcp():
    # In gcsfs async mode, you use open_async() instead of open()
    async with fs.open_async("your-bucket-name/your-file.csv", "r") as f:
        content = await f.read()

    await asyncio.sleep(1)

    return {
        "message": "File extracted successfully",
        "size": len(content)
    }