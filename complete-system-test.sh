#!/bin/bash

# Complete DevOps Project Test Script
# Tests all components and generates a report

set +e  # Don't exit on errors, we want to check everything

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Counters
PASSED=0
FAILED=0
WARNINGS=0

# Configuration - UPDATE THESE!
GITHUB_USERNAME="jyotikashyap1502"
GITHUB_REPO="e-comm"
DOCKERHUB_USERNAME="jyotikashyap1502"
IMAGE_NAME="ecomm-react-app"
JENKINS_IP="13.233.118.5"
APP_EC2_IP="13.233.118.5"  # Update this!a

# Functions
print_header() {
    echo -e "\n${CYAN}=========================================="
    echo -e "$1"
    echo -e "==========================================${NC}\n"
}

print_test() {
    echo -e "${BLUE}[TEST]${NC} $1"
}

print_pass() {
    echo -e "${GREEN}[✓ PASS]${NC} $1"
    ((PASSED++))
}

print_fail() {
    echo -e "${RED}[✗ FAIL]${NC} $1"
    ((FAILED++))
}

print_warn() {
    echo -e "${YELLOW}[⚠ WARN]${NC} $1"
    ((WARNINGS++))
}

print_info() {
    echo -e "${CYAN}[INFO]${NC} $1"
}

# Start testing
clear
print_header "🚀 DevOps Project - Complete System Test"
echo "Starting comprehensive system check..."
echo "Time: $(date)"
echo ""

# ===========================================
# Test 1: Local Git Repository
# ===========================================
print_header "📁 Test 1: Local Git Repository"

print_test "Checking if we're in a git repository..."
if git rev-parse --git-dir > /dev/null 2>&1; then
    print_pass "Git repository detected"
    
    # Check branches
    print_test "Checking branches..."
    CURRENT_BRANCH=$(git rev-parse --abbrev-ref HEAD)
    print_info "Current branch: $CURRENT_BRANCH"
    
    if git show-ref --verify --quiet refs/heads/dev; then
        print_pass "Dev branch exists"
    else
        print_fail "Dev branch not found"
    fi
    
    if git show-ref --verify --quiet refs/heads/main || git show-ref --verify --quiet refs/heads/master; then
        print_pass "Main/Master branch exists"
    else
        print_fail "Main/Master branch not found"
    fi
    
    # Check important files
    print_test "Checking required files..."
    for file in Dockerfile docker-compose.yml Jenkinsfile build.sh deploy.sh .dockerignore .gitignore; do
        if [ -f "$file" ]; then
            print_pass "$file exists"
        else
            print_fail "$file not found"
        fi
    done
else
    print_fail "Not a git repository"
fi

# ===========================================
# Test 2: GitHub Repository
# ===========================================
print_header "🌐 Test 2: GitHub Repository"

print_test "Checking GitHub repository accessibility..."
GITHUB_URL="https://github.com/${GITHUB_USERNAME}/${GITHUB_REPO}"
if curl -s -o /dev/null -w "%{http_code}" "$GITHUB_URL" | grep -q "200"; then
    print_pass "GitHub repository is accessible: $GITHUB_URL"
else
    print_warn "Cannot verify GitHub repository (might be private or wrong URL)"
    print_info "Expected URL: $GITHUB_URL"
fi

print_test "Checking git remote..."
if git remote -v | grep -q "github.com"; then
    REMOTE_URL=$(git remote get-url origin)
    print_pass "Git remote configured: $REMOTE_URL"
else
    print_fail "No GitHub remote found"
fi

# ===========================================
# Test 3: Docker Hub
# ===========================================
print_header "🐳 Test 3: Docker Hub Images"

print_test "Checking Docker Hub repository..."
DOCKERHUB_API="https://hub.docker.com/v2/repositories/${DOCKERHUB_USERNAME}/${IMAGE_NAME}/"
if curl -s "$DOCKERHUB_API" | grep -q "ecomm-react-app"; then
    print_pass "Docker Hub repository exists"
    
    # Check dev tag
    print_test "Checking dev tag..."
    if curl -s "${DOCKERHUB_API}tags/dev/" | grep -q "dev"; then
        print_pass "Dev tag exists (PUBLIC)"
    else
        print_fail "Dev tag not found"
    fi
    
    # Check prod tag
    print_test "Checking prod tag..."
    if curl -s "${DOCKERHUB_API}tags/prod/" | grep -q "prod"; then
        print_pass "Prod tag exists"
    else
        print_warn "Prod tag not found (might be private)"
    fi
else
    print_fail "Docker Hub repository not accessible"
fi

# ===========================================
# Test 4: Jenkins Server
# ===========================================
print_header "🔧 Test 4: Jenkins Server"

print_test "Checking Jenkins accessibility..."
JENKINS_URL="http://${JENKINS_IP}:8080"
JENKINS_CODE=$(curl -s -o /dev/null -w "%{http_code}" "${JENKINS_URL}" --max-time 10)

if [ "$JENKINS_CODE" = "403" ] || [ "$JENKINS_CODE" = "200" ]; then
    print_pass "Jenkins is accessible at $JENKINS_URL"
    print_info "HTTP Status: $JENKINS_CODE"
else
    print_fail "Jenkins is not accessible (HTTP $JENKINS_CODE)"
fi

print_test "Checking Jenkins webhook endpoint..."
WEBHOOK_CODE=$(curl -s -o /dev/null -w "%{http_code}" "${JENKINS_URL}/github-webhook/" --max-time 10)
if [ "$WEBHOOK_CODE" = "200" ] || [ "$WEBHOOK_CODE" = "403" ] || [ "$WEBHOOK_CODE" = "405" ]; then
    print_pass "Jenkins webhook endpoint responding (HTTP $WEBHOOK_CODE)"
else
    print_warn "Webhook endpoint status: HTTP $WEBHOOK_CODE"
fi

# ===========================================
# Test 5: Application Server
# ===========================================
print_header "🌍 Test 5: Application Server"

if [ "$APP_EC2_IP" = "YOUR_APP_EC2_IP" ]; then
    print_warn "APP_EC2_IP not configured in script. Update the script with your EC2 IP!"
else
    print_test "Checking application server..."
    APP_URL="http://${APP_EC2_IP}"
    APP_CODE=$(curl -s -o /dev/null -w "%{http_code}" "${APP_URL}" --max-time 10)
    
    if [ "$APP_CODE" = "200" ]; then
        print_pass "Application is UP and responding (HTTP 200)"
        
        # Check if it's returning HTML
        if curl -s "${APP_URL}" | grep -q "<!DOCTYPE html>"; then
            print_pass "Application serving HTML content"
        else
            print_warn "Response doesn't look like HTML"
        fi
        
        # Check response time
        RESPONSE_TIME=$(curl -s -o /dev/null -w "%{time_total}" "${APP_URL}")
        print_info "Response time: ${RESPONSE_TIME}s"
        
    else
        print_fail "Application is DOWN or not accessible (HTTP $APP_CODE)"
    fi
    
    # Check monitoring
    print_test "Checking Uptime Kuma monitoring..."
    KUMA_CODE=$(curl -s -o /dev/null -w "%{http_code}" "http://${APP_EC2_IP}:3001" --max-time 10)
  

    if [ "$KUMA_CODE" = "200" ] || [ "$KUMA_CODE" = "302" ]; then
    print_pass "Uptime Kuma is accessible (HTTP $KUMA_CODE)"
else
    print_warn "Uptime Kuma not accessible (HTTP $KUMA_CODE)"
fi

fi

# ===========================================
# Test 6: Docker Local
# ===========================================
print_header "🐋 Test 6: Docker (Local)"

print_test "Checking Docker installation..."
if command -v docker &> /dev/null; then
    print_pass "Docker is installed"
    DOCKER_VERSION=$(docker --version)
    print_info "$DOCKER_VERSION"
    
    print_test "Checking Docker daemon..."
    if docker info > /dev/null 2>&1; then
        print_pass "Docker daemon is running"
        
        # Check for local images
        print_test "Checking local Docker images..."
        if docker images | grep -q "${IMAGE_NAME}"; then
            print_pass "Local Docker images found"
            docker images | grep "${IMAGE_NAME}" | head -3
        else
            print_warn "No local images found (might not be built locally)"
        fi
    else
        print_warn "Docker daemon not running or not accessible"
    fi
else
    print_warn "Docker not installed locally (OK if using Jenkins to build)"
fi

# ===========================================
# Test 7: Network Connectivity
# ===========================================
print_header "🌐 Test 7: Network Connectivity"

print_test "Testing internet connectivity..."
if curl -s -o /dev/null -w "%{http_code}" "https://www.google.com" --max-time 5 | grep -q "200"; then
    print_pass "Internet connectivity OK"
else
    print_warn "Internet connectivity issue"
fi

print_test "Testing Docker Hub connectivity..."
if curl -s -o /dev/null -w "%{http_code}" "https://hub.docker.com" --max-time 5 | grep -q "200"; then
    print_pass "Docker Hub accessible"
else
    print_fail "Docker Hub not accessible"
fi

print_test "Testing GitHub connectivity..."
if curl -s -o /dev/null -w "%{http_code}" "https://github.com" --max-time 5 | grep -q "200"; then
    print_pass "GitHub accessible"
else
    print_fail "GitHub not accessible"
fi

# ===========================================
# Test 8: Project Structure
# ===========================================



print_test "Checking documentation files..."
for doc in README.md; do
    if [ -f "$doc" ]; then
        print_pass "$doc exists"
    else
        print_warn "$doc not found (should create for submission)"
    fi
done

# ===========================================
# Test 9: Scripts Permissions
# ===========================================
print_header "🔐 Test 9: Script Permissions"

print_test "Checking script executability..."
for script in build.sh deploy.sh push-images.sh; do
    if [ -f "$script" ]; then
        if [ -x "$script" ]; then
            print_pass "$script is executable"
        else
            print_warn "$script exists but not executable (run: chmod +x $script)"
        fi
    fi
done

# ===========================================
# Final Report
# ===========================================
print_header "📊 Test Summary"

TOTAL=$((PASSED + FAILED + WARNINGS))

echo -e "${GREEN}Passed:   $PASSED${NC}"
echo -e "${RED}Failed:   $FAILED${NC}"
echo -e "${YELLOW}Warnings: $WARNINGS${NC}"
echo -e "Total:    $TOTAL"
echo ""

# Calculate percentage
if [ $TOTAL -gt 0 ]; then
    PASS_PERCENT=$((PASSED * 100 / TOTAL))
    echo -e "Success Rate: ${PASS_PERCENT}%"
fi

echo ""
print_header "🎯 Submission Readiness"

if [ $FAILED -eq 0 ] && [ $PASSED -gt 15 ]; then
    echo -e "${GREEN}✓ System is ready for submission!${NC}"
    echo ""
    echo "Next steps:"
    echo "1. Update README.md with all URLs"
    echo "2. Final push to GitHub"
elif [ $FAILED -le 2 ] && [ $WARNINGS -le 5 ]; then
    echo -e "${YELLOW}⚠ System is mostly ready, but has some warnings${NC}"
    echo ""
    echo "Review the warnings above and fix critical issues before submission."
elif [ $FAILED -gt 0 ]; then
    echo -e "${RED}✗ System has failed tests${NC}"
    echo ""
    echo "Critical issues found! Fix failed tests before submission."
    echo "Run this script again after fixing issues."
else
    echo -e "${YELLOW}⚠ Incomplete configuration${NC}"
    echo ""
    echo "Update the script with your EC2 IP and GitHub details."
fi

echo ""
print_header "📝 Quick Reference URLs"

echo "GitHub Repository:  https://github.com/${GITHUB_USERNAME}/${GITHUB_REPO}"
echo "Jenkins Dashboard:  http://${JENKINS_IP}:8080"
echo "Application:        http://${APP_EC2_IP}"
echo "Monitoring:         http://${APP_EC2_IP}:3001"
echo "Docker Hub Dev:     https://hub.docker.com/r/${DOCKERHUB_USERNAME}/${IMAGE_NAME}"
echo "Docker Hub Prod:    https://hub.docker.com/r/${DOCKERHUB_USERNAME}/${IMAGE_NAME}"

echo ""
echo "Test completed at: $(date)"
echo ""

# Exit with appropriate code
if [ $FAILED -gt 0 ]; then
    exit 1
else
    exit 0
fi
