#!/bin/bash

# API Testing Script
# This script demonstrates how to test all the API endpoints

set -e

API_BASE_URL="http://localhost:8080"
echo "Testing Go API at $API_BASE_URL"
echo "================================"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    if [ $1 -eq 0 ]; then
        echo -e "${GREEN}✓ $2${NC}"
    else
        echo -e "${RED}✗ $2${NC}"
        exit 1
    fi
}

print_info() {
    echo -e "${YELLOW}→ $1${NC}"
}

# Test 1: Health Check
print_info "Testing health check endpoint..."
response=$(curl -s -w "%{http_code}" -o /tmp/response.json "$API_BASE_URL/ping" || echo "000")
if [ "$response" = "200" ]; then
    print_status 0 "Health check passed"
    echo "Response: $(cat /tmp/response.json)"
else
    print_status 1 "Health check failed (HTTP $response)"
fi

echo ""

# Test 2: Get All Users (initially should be empty or return existing users)
print_info "Testing get all users endpoint..."
response=$(curl -s -w "%{http_code}" -o /tmp/response.json "$API_BASE_URL/users" || echo "000")
if [ "$response" = "200" ]; then
    print_status 0 "Get all users passed"
    echo "Response: $(cat /tmp/response.json)"
else
    print_status 1 "Get all users failed (HTTP $response)"
fi

echo ""

# Test 3: Create a new user
print_info "Testing create user endpoint..."
create_response=$(curl -s -w "%{http_code}" -o /tmp/create_response.json \
    -X POST "$API_BASE_URL/user" \
    -H "Content-Type: application/json" \
    -d '{
        "name": "Test User",
        "email": "test@example.com",
        "img_url": "https://example.com/avatar.jpg"
    }' || echo "000")

if [ "$create_response" = "201" ]; then
    print_status 0 "Create user passed"
    echo "Response: $(cat /tmp/create_response.json)"
    
    # Extract user ID for next test
    USER_ID=$(cat /tmp/create_response.json | grep -o '"user_id":[0-9]*' | grep -o '[0-9]*')
    echo "Created user with ID: $USER_ID"
else
    print_status 1 "Create user failed (HTTP $create_response)"
fi

echo ""

# Test 4: Get user by ID (using the ID from the created user)
if [ -n "$USER_ID" ]; then
    print_info "Testing get user by ID endpoint..."
    get_response=$(curl -s -w "%{http_code}" -o /tmp/get_response.json "$API_BASE_URL/user/$USER_ID" || echo "000")
    
    if [ "$get_response" = "200" ]; then
        print_status 0 "Get user by ID passed"
        echo "Response: $(cat /tmp/get_response.json)"
    else
        print_status 1 "Get user by ID failed (HTTP $get_response)"
    fi
else
    print_info "Skipping get user by ID test (no user ID available)"
fi

echo ""

# Test 5: Test error cases

# Test invalid user ID
print_info "Testing invalid user ID..."
invalid_response=$(curl -s -w "%{http_code}" -o /tmp/invalid_response.json "$API_BASE_URL/user/abc" || echo "000")
if [ "$invalid_response" = "400" ]; then
    print_status 0 "Invalid user ID handling passed"
    echo "Response: $(cat /tmp/invalid_response.json)"
else
    print_status 1 "Invalid user ID handling failed (HTTP $invalid_response)"
fi

echo ""

# Test non-existent user ID
print_info "Testing non-existent user ID..."
notfound_response=$(curl -s -w "%{http_code}" -o /tmp/notfound_response.json "$API_BASE_URL/user/999999" || echo "000")
if [ "$notfound_response" = "404" ]; then
    print_status 0 "Non-existent user handling passed"
    echo "Response: $(cat /tmp/notfound_response.json)"
else
    print_status 1 "Non-existent user handling failed (HTTP $notfound_response)"
fi

echo ""

# Test invalid JSON
print_info "Testing invalid JSON..."
invalid_json_response=$(curl -s -w "%{http_code}" -o /tmp/invalid_json_response.json \
    -X POST "$API_BASE_URL/user" \
    -H "Content-Type: application/json" \
    -d '{"name": "Invalid JSON"' || echo "000")
    
if [ "$invalid_json_response" = "400" ]; then
    print_status 0 "Invalid JSON handling passed"
    echo "Response: $(cat /tmp/invalid_json_response.json)"
else
    print_status 1 "Invalid JSON handling failed (HTTP $invalid_json_response)"
fi

echo ""

# Test 6: Get all users again to see the created user
print_info "Testing get all users endpoint again..."
final_response=$(curl -s -w "%{http_code}" -o /tmp/final_response.json "$API_BASE_URL/users" || echo "000")
if [ "$final_response" = "200" ]; then
    print_status 0 "Final get all users passed"
    echo "Response: $(cat /tmp/final_response.json)"
else
    print_status 1 "Final get all users failed (HTTP $final_response)"
fi

echo ""
echo -e "${GREEN}All API tests completed successfully!${NC}"

# Cleanup
rm -f /tmp/response.json /tmp/create_response.json /tmp/get_response.json /tmp/invalid_response.json /tmp/notfound_response.json /tmp/invalid_json_response.json /tmp/final_response.json

echo ""
echo "================================"
echo "API Testing Summary:"
echo "- Health check: ✓"
echo "- Get all users: ✓"
echo "- Create user: ✓"
echo "- Get user by ID: ✓"
echo "- Error handling: ✓"
echo "================================"