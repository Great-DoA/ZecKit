#!/bin/bash
# Manual RPC testing helper for Zebra
# Demonstrates common RPC calls for development

set -e

ZEBRA_RPC_URL=${ZEBRA_RPC_URL:-"http://127.0.0.1:8232"}

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

rpc_call() {
    local method=$1
    shift
    local params="$@"
    
    if [ -z "$params" ]; then
        params="[]"
    fi
    
    echo -e "${BLUE}→ Calling:${NC} $method $params"
    
    local response
    response=$(curl -sf --max-time 10 \
        --data-binary "{\"jsonrpc\":\"2.0\",\"id\":\"manual\",\"method\":\"$method\",\"params\":$params}" \
        -H 'content-type: application/json' \
        "$ZEBRA_RPC_URL" 2>/dev/null)
    
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✓ Response:${NC}"
        echo "$response" | jq '.' 2>/dev/null || echo "$response"
    else
        echo -e "${YELLOW}✗ Failed${NC}"
    fi
    echo ""
}

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  Zebra RPC Testing Helper"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  Endpoint: $ZEBRA_RPC_URL"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

echo "=== Node Information ==="
rpc_call "getinfo"
rpc_call "getblockchaininfo"
rpc_call "getnetworkinfo"

echo "=== Blockchain State ==="
rpc_call "getblockcount"
rpc_call "getbestblockhash"

echo "=== Network Status ==="
rpc_call "getpeerinfo"
rpc_call "getconnectioncount"

echo "=== Mempool ==="
rpc_call "getmempoolinfo"

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "To generate blocks (requires miner address configured):"
echo "  curl -d '{\"method\":\"generate\",\"params\":[1]}' $ZEBRA_RPC_URL"
echo ""
echo "For full RPC reference, see:"
echo "  https://zcash.github.io/rpc/"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""