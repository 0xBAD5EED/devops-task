# No need for a bloated base image
FROM python:3.12-slim

WORKDIR /helloapp
# Only copying what is needed to reduce the image size.
COPY requirements.txt .
COPY helloapp/ ./helloapp/ 

RUN pip install -r requirements.txt
# Let's run as non-root to minimize attack surface.
RUN useradd -m -u 1000 formlabs
USER formlabs
