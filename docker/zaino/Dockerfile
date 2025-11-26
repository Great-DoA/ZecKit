# Zaino Indexer Dockerfile
# Builds from source for ZecKit regtest support

FROM rust:1.85-slim-bookworm as builder

# Install build dependencies
RUN apt-get update && apt-get install -y \
    git \
    pkg-config \
    libssl-dev \
    protobuf-compiler \
    build-essential \
    cmake \
    clang \
    && rm -rf /var/lib/apt/lists/*

# Clone Zaino
WORKDIR /build
RUN git clone https://github.com/zingolabs/zaino.git

# Build Zaino - FIXED: Binary is called 'zainod' not 'zaino-serve'
WORKDIR /build/zaino
RUN cargo build --release --bin zainod

# Runtime stage
FROM debian:bookworm-slim

# Install runtime dependencies
RUN apt-get update && apt-get install -y \
    ca-certificates \
    libssl3 \
    curl \
    netcat-openbsd \
    && rm -rf /var/lib/apt/lists/*

# Create zaino user
RUN useradd -m -u 2002 -s /bin/bash zaino

# Copy binary - FIXED: Copy zainod, not zaino-serve
COPY --from=builder /build/zaino/target/release/zainod /usr/local/bin/zainod
RUN chmod +x /usr/local/bin/zainod

# Copy entrypoint
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# Create data directory
RUN mkdir -p /var/zaino && chown -R zaino:zaino /var/zaino

USER zaino
WORKDIR /var/zaino

EXPOSE 9067

HEALTHCHECK --interval=30s --timeout=10s --start-period=90s --retries=3 \
    CMD nc -z localhost 9067 || exit 1

ENTRYPOINT ["/entrypoint.sh"]