#!/bin/bash
# Manual test script for faucet API
set -e

FAUCET_URL=${FAUCET_URL:-"http://127.0.0.1:8080"}

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  ZecKit Faucet - Manual API Test"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  Endpoint: $FAUCET_URL"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# Test 1: Root endpoint
echo -e "${BLUE}[TEST 1]${NC} GET /"
response=$(curl -s $FAUCET_URL)
echo "$response" | jq '.' 2>/dev/null || echo "$response"
echo ""

# Test 2: Health check
echo -e "${BLUE}[TEST 2]${NC} GET /health"
response=$(curl -s $FAUCET_URL/health)
echo "$response" | jq '.' 2>/dev/null || echo "$response"

# Check if healthy
if echo "$response" | jq -e '.status == "healthy"' >/dev/null 2>&1; then
    echo -e "${GREEN}✓ Faucet is healthy${NC}"
else
    echo -e "${YELLOW}⚠ Faucet status: $(echo "$response" | jq -r '.status')${NC}"
fi
echo ""

# Test 3: Readiness check
echo -e "${BLUE}[TEST 3]${NC} GET /ready"
response=$(curl -s $FAUCET_URL/ready)
echo "$response" | jq '.' 2>/dev/null || echo "$response"
echo ""

# Test 4: Liveness check
echo -e "${BLUE}[TEST 4]${NC} GET /live"
response=$(curl -s $FAUCET_URL/live)
echo "$response" | jq '.' 2>/dev/null || echo "$response"
echo ""

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo -e "${GREEN}✓ Manual tests complete${NC}"
echo ""
echo "Next: Test funding endpoint when implemented"
echo "  curl -X POST $FAUCET_URL/request \\"
echo "    -H 'Content-Type: application/json' \\"
echo "    -d '{\"address\": \"t1abc...\", \"amount\": 10}'"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""