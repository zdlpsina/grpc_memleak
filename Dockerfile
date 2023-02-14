FROM nvidia/cuda:10.2-base-ubuntu18.04

RUN apt-get update \
    && DEBIAN_FRONTEND=noninteractive apt-get install -y \
    build-essential git pkg-config autoconf libtool libssl-dev wget \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

RUN wget https://cmake.org/files/v3.22/cmake-3.22.2-linux-x86_64.tar.gz \
    && install -d /cmake \
    && tar --strip-components 1 -C /cmake -xf cmake-3.22.2-linux-x86_64.tar.gz \
    && rm cmake-3.22.2-linux-x86_64.tar.gz

RUN cd / \
    && git clone --recurse-submodules https://github.com/grpc/grpc

RUN cd /grpc \
    && git checkout v1.43.2 \
    && git submodule update --recursive

RUN mkdir -p /grpc/cmake/build \
    && cd /grpc/cmake/build \
    && /cmake/bin/cmake \
        -DCMAKE_BUILD_TYPE=Release \
        -DCMAKE_INSTALL_PREFIX=/grpc/cmake/install \
        -DgRPC_INSTALL=ON \
        -DgRPC_BUILD_TESTS=OFF \
        -DgRPC_BUILD_CSHARP_EXT=OFF \
        -DgRPC_BUILD_GRPC_CSHARP_PLUGIN=OFF \
        -DgRPC_BUILD_GRPC_NODE_PLUGIN=OFF \
        -DgRPC_BUILD_GRPC_OBJECTIVE_C_PLUGIN=OFF \
        -DgRPC_BUILD_GRPC_PHP_PLUGIN=OFF \
        -DgRPC_BUILD_GRPC_PYTHON_PLUGIN=OFF \
        -DgRPC_BUILD_GRPC_RUBY_PLUGIN=OFF \
        -DgRPC_SSL_PROVIDER=package \
        ../.. \
    && make -j4 \
    && make install

COPY CMakeLists.txt ./
COPY example_service.proto ./
COPY server.cc ./

RUN mkdir build \
    && cd build \
    && /cmake/bin/cmake .. \
    && make

EXPOSE 50015

ENTRYPOINT ["/app/build/server"]