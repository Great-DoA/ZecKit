# docker/zaino/Dockerfile
FROM rust:1.85-slim-bookworm

RUN apt-get update && apt-get install -y \
    build-essential \
    git \
    curl \
    netcat-openbsd \
    libclang-dev \
    clang \
    llvm \
    cmake \
    protobuf-compiler \
    && rm -rf /var/lib/apt/lists/*

# Clone and build Zaino indexer FROM THE FIX BRANCH
WORKDIR /build
RUN git clone https://github.com/Timi16/zaino.git && \
    cd zaino && \
    git checkout fix/regtest-insecure-grpc && \
    CARGO_BUILD_JOBS=1 cargo build --release --bin zainod && \
    mv target/release/zainod /usr/local/bin/ && \
    chmod +x /usr/local/bin/zainod && \
    rm -rf /build

RUN mkdir -p /var/zaino && chmod 777 /var/zaino

WORKDIR /var/zaino

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]