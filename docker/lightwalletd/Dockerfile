# Multi-stage build for lightwalletd
FROM golang:1.24-bookworm as builder

# Install dependencies
RUN apt-get update && apt-get install -y \
    git \
    build-essential \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# Clone lightwalletd
WORKDIR /build
RUN git clone https://github.com/zcash/lightwalletd.git
WORKDIR /build/lightwalletd

# Check structure and build (main.go is in root now)
RUN ls -la && \
    go mod download && \
    go build -o lightwalletd .

# Build grpc-health-probe
WORKDIR /build
RUN git clone https://github.com/grpc-ecosystem/grpc-health-probe.git
WORKDIR /build/grpc-health-probe
RUN go build -o grpc_health_probe

# Runtime stage
FROM debian:bookworm-slim

# Install runtime dependencies
RUN apt-get update && apt-get install -y \
    ca-certificates \
    curl \
    && rm -rf /var/lib/apt/lists/*

# Copy binaries from builder
COPY --from=builder /build/lightwalletd/lightwalletd /usr/local/bin/lightwalletd
COPY --from=builder /build/grpc-health-probe/grpc_health_probe /usr/local/bin/grpc_health_probe
RUN chmod +x /usr/local/bin/lightwalletd /usr/local/bin/grpc_health_probe

# Copy entrypoint
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# Create data directory
RUN mkdir -p /var/lightwalletd

WORKDIR /var/lightwalletd

EXPOSE 9067

ENTRYPOINT ["/entrypoint.sh"]