FROM pytorch/pytorch:1.12.1-cuda11.3-cudnn8-runtime

COPY requirements.txt /tmp/requirements.txt

RUN python -m pip install -U pip && pip install -r /tmp/requirements.txt --no-cache-dir

ENV DATA_DIR=/app/data

COPY src /app/src

WORKDIR /app
