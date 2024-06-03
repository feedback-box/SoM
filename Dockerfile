FROM alpine:latest as ckpt

WORKDIR /app

# Download pretrained models
COPY download_ckpt.sh .

RUN sh download_ckpt.sh

FROM nvidia/cuda:12.3.1-devel-ubuntu22.04

# Install system dependencies
RUN apt-get update && \
  apt-get install -y \
  python3-pip python3-dev git ninja-build wget \
  ffmpeg libsm6 libxext6 \
  openmpi-bin libopenmpi-dev && \
  ln -sf /usr/bin/python3 /usr/bin/python && \
  ln -sf /usr/bin/pip3 /usr/bin/pip

# Set the working directory in the container
WORKDIR /app

# Copy the current directory contents into the container at /app
COPY . .

ENV FORCE_CUDA=0
ENV OUTPUT_DIR='/outputs'
ENV INPUT_DIR='/inputs'


RUN mkdir -p ${INPUT_DIR}
RUN mkdir -p ${OUTPUT_DIR}

# Upgrade pip
RUN python -m pip install --upgrade pip

# Install Python dependencies
RUN pip install torch torchvision torchaudio --extra-index-url https://download.pytorch.org/whl/cu123 \
  && pip install git+https://github.com/UX-Decoder/Segment-Everything-Everywhere-All-At-Once.git@33f2c898fdc8d7c95dda014a4b9ebe4e413dbb2b \
  && pip install git+https://github.com/facebookresearch/segment-anything.git \
  && pip install git+https://github.com/UX-Decoder/Semantic-SAM.git@package \
  && cd ops && bash make.sh && cd .. \
  && pip install mpi4py \
  && pip install openai \
  && pip install gradio==4.17.0 \
  && pip install fire \
  && pip install dask distributed


# borrow downloaded ckpt
COPY --from=ckpt /app .


# Make port 6092 available to the world outside this container
EXPOSE 6092

# Make Gradio server accessible outside 127.0.0.1
ENV GRADIO_SERVER_NAME="0.0.0.0"

# RUN chmod +x /app/entrypoint.sh
# CMD ["/app/entrypoint.sh"]

# sample run to cache the swin large patch4 pynode
# RUN python app.py 
RUN python setup-docker.py


ENV HF_DATASETS_OFFLINE=1 
ENV TRANSFORMERS_OFFLINE=1 


ENTRYPOINT [ "python", "app.py" ]
# CMD [""]

LABEL maintainer="Hiro <laciferin@gmail.com>"