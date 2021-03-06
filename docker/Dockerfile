FROM ubuntu:18.04 as builder

ARG MAKE_NUM_THREADS=4
ARG OPENBLAS_NUM_THREADS=$MAKE_NUM_THREADS
ARG OPENBLAS_COMMIT=tags/v0.3.7
ENV MAKEFLAGS=" -j$MAKE_NUM_THREADS"

ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update && apt-get install -y \
    python \
    python3 \
    build-essential \
    zlib1g-dev \
    automake \
    autoconf \
    unzip \
    git \
    gfortran \
    sox \
    libtool \
    subversion \
    wget \
    g++

ADD gentle/ext /gentle/ext
WORKDIR /gentle/ext

# Compile Kaldi using OpenBLAS
RUN cd kaldi/tools && make 
RUN cd kaldi/tools && test -e OpenBLAS || git clone https://github.com/xianyi/OpenBLAS.git
RUN cd kaldi/tools/OpenBLAS && git checkout $OPENBLAS_COMMIT && cd .. && \
    ./extras/install_openblas.sh
RUN cd kaldi/src && \
    ./configure --static --static-math=yes --static-fst=yes --use-cuda=no --openblas-root=../tools/OpenBLAS/install && \
    make depend

# Build k3 and m3 binaries
RUN make depend && make && rm -rf *.o

# Download models
WORKDIR /gentle
ADD gentle/install_language_model.sh ./
ADD gentle/install_models.sh ./
RUN ./install_models.sh && ./install_language_model.sh

FROM ubuntu:18.04

# sox ffmpeg and gfortran are required by Kaldi for transcription
RUN apt-get update && apt-get install -y curl sox ffmpeg gfortran software-properties-common && \
    add-apt-repository -y ppa:deadsnakes/ppa && \
    apt-get install -y python3.7 && \
    apt-get clean && \
    rm /usr/bin/python3 && ln -s python3.7 /usr/bin/python3

RUN curl https://bootstrap.pypa.io/get-pip.py -o get-pip.py && python3 get-pip.py && rm -f get-pip.py

COPY --from=builder /gentle/ext/k3 /gentle/ext/k3
COPY --from=builder /gentle/ext/m3 /gentle/ext/m3
COPY --from=builder /gentle/ext/kaldi/src/featbin /gentle/ext/kaldi/src/featbin
COPY --from=builder /gentle/exp /gentle/exp
ADD gentle/gentle /gentle/gentle
ADD gentle/*.py /gentle/
ADD gentle/www /gentle/www

WORKDIR /gentle
RUN python3 setup.py develop && rm setup.py
ENV PYTHONPATH="$PYTHONPATH:/gentle"

EXPOSE 8765
VOLUME /gentle/webdata
CMD python3 serve.py

