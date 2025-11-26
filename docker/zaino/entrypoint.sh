#!/bin/bash
set -e

echo "🔧 Initializing Zaino Indexer..."

# Configuration
ZEBRA_RPC_HOST=${ZEBRA_RPC_HOST:-zebra}
ZEBRA_RPC_PORT=${ZEBRA_RPC_PORT:-8232}
ZEBRA_RPC_USER=${ZEBRA_RPC_USER:-zcashrpc}
ZEBRA_RPC_PASS=${ZEBRA_RPC_PASS:-notsecure}
ZAINO_GRPC_BIND=${ZAINO_GRPC_BIND:-0.0.0.0:9067}
ZAINO_DATA_DIR=${ZAINO_DATA_DIR:-/var/zaino}
NETWORK=${NETWORK:-regtest}

echo "Configuration:"
echo "  Zebra RPC:  ${ZEBRA_RPC_HOST}:${ZEBRA_RPC_PORT}"
echo "  gRPC Bind:  ${ZAINO_GRPC_BIND}"
echo "  Data Dir:   ${ZAINO_DATA_DIR}"
echo "  Network:    ${NETWORK}"

# Wait for Zebra
echo "⏳ Waiting for Zebra RPC..."
MAX_ATTEMPTS=60
ATTEMPT=0

while [ $ATTEMPT -lt $MAX_ATTEMPTS ]; do
    if curl -s -u "${ZEBRA_RPC_USER}:${ZEBRA_RPC_PASS}" \
        -X POST \
        -H "Content-Type: application/json" \
        -d '{"jsonrpc":"2.0","id":"health","method":"getblockcount","params":[]}' \
        "http://${ZEBRA_RPC_HOST}:${ZEBRA_RPC_PORT}" > /dev/null 2>&1; then
        echo "✅ Zebra RPC is ready!"
        break
    fi
    ATTEMPT=$((ATTEMPT + 1))
    echo "Attempt $ATTEMPT/$MAX_ATTEMPTS - Zebra not ready yet..."
    sleep 5
done

if [ $ATTEMPT -eq $MAX_ATTEMPTS ]; then
    echo "❌ Zebra did not become ready in time"
    exit 1
fi

# Get block count
BLOCK_COUNT=$(curl -s -u "${ZEBRA_RPC_USER}:${ZEBRA_RPC_PASS}" \
    -X POST \
    -H "Content-Type: application/json" \
    -d '{"jsonrpc":"2.0","id":"info","method":"getblockcount","params":[]}' \
    "http://${ZEBRA_RPC_HOST}:${ZEBRA_RPC_PORT}" | grep -o '"result":[0-9]*' | cut -d: -f2 || echo "0")

echo "📊 Current block height: ${BLOCK_COUNT}"

# Start Zaino - FIXED: Use 'zainod' binary
echo "🚀 Starting Zaino indexer (zainod)..."
exec zainod \
  --listen-addr="${ZAINO_GRPC_BIND}" \
  --zcash-conf-path="/dev/null" \
  --zebrad-rpc-uri="http://${ZEBRA_RPC_HOST}:${ZEBRA_RPC_PORT}" \
  --zebrad-rpc-user="${ZEBRA_RPC_USER}" \
  --zebrad-rpc-password="${ZEBRA_RPC_PASS}" \
  "$@"