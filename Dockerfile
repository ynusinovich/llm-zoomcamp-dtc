# CUDA 12.1   |   Ubuntu 22.04   |   Python 3.10   |   Poetry   |   Jupyter

FROM nvidia/cuda:12.1.1-cudnn8-runtime-ubuntu22.04

ENV DEBIAN_FRONTEND=noninteractive \
    LANG=C.UTF-8 \
    LC_ALL=C.UTF-8

# 1. Base OS utilities
RUN apt-get update && apt-get install -y --no-install-recommends \
        software-properties-common curl git build-essential \
    && rm -rf /var/lib/apt/lists/*

# 2. CPython 3.10 + pip
# Deadsnakes provides 3.10.13 for Ubuntu 22.04
RUN add-apt-repository ppa:deadsnakes/ppa && \
    apt-get update && apt-get install -y \
        python3.10 python3.10-dev python3.10-distutils && \
    curl -sS https://bootstrap.pypa.io/get-pip.py | python3.10

# Provide “python” and “python3” → 3.10
RUN update-alternatives --install /usr/bin/python  python  /usr/bin/python3.10 1 && \
    update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.10 1

# 3. Poetry
RUN pip install --no-cache-dir "poetry==1.8.2"

# 4. Project deps
WORKDIR /app
COPY pyproject.toml poetry.lock* ./
RUN poetry config virtualenvs.create false && \
    poetry install --no-interaction --no-root

# 5. Jupyter entrypoint
EXPOSE 8888
ENTRYPOINT ["poetry", "run"]
CMD ["jupyter", "notebook", \
     "--ip=0.0.0.0", "--allow-root", \
     "--NotebookApp.token=", "--NotebookApp.password="]
