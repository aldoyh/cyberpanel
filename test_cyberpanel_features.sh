#!/bin/bash

#########################################################################
# Test script for CyberPanel version check and dark theme
#########################################################################

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

print_test() {
    echo -e "${BLUE}[TEST]${NC} $1"
}

print_pass() {
    echo -e "${GREEN}[PASS]${NC} $1"
}

print_fail() {
    echo -e "${RED}[FAIL]${NC} $1"
}

echo "========================================"
echo "    CyberPanel Tests"
echo "========================================"
echo

# Test version check script
print_test "Testing version check script..."
if [ -f "version_check.sh" ] && [ -x "version_check.sh" ]; then
    print_pass "Version check script exists and is executable"
    
    # Test in test mode (should exit with status 1 for available update)
    if CYBERPANEL_TEST_MODE=1 bash version_check.sh >/dev/null 2>&1; then
        print_fail "Version check test failed - should exit 1 for available update"
    else
        print_pass "Version check script logic works correctly"
    fi
else
    print_fail "Version check script not found or not executable"
fi

echo

# Test dark theme CSS
print_test "Testing dark theme CSS..."
if [ -f "cyberpanel_dark_theme.css" ]; then
    print_pass "Dark theme CSS file exists"
    
    # Check essential properties
    if grep -q "bg-primary.*#0d1117" cyberpanel_dark_theme.css; then
        print_pass "Dark background colors defined"
    else
        print_fail "Dark background colors not found"
    fi
    
    if grep -q "text-primary.*#f0f6fc" cyberpanel_dark_theme.css; then
        print_pass "Light text colors defined"
    else
        print_fail "Light text colors not found"
    fi
    
    if grep -q "prefers-contrast: high" cyberpanel_dark_theme.css; then
        print_pass "Accessibility features included"
    else
        print_fail "Accessibility features not found"
    fi
    
    # Check CSS syntax
    open_braces=$(grep -o '{' cyberpanel_dark_theme.css | wc -l)
    close_braces=$(grep -o '}' cyberpanel_dark_theme.css | wc -l)
    
    if [ "$open_braces" -eq "$close_braces" ]; then
        print_pass "CSS syntax is valid (braces balanced)"
    else
        print_fail "CSS syntax error (braces not balanced)"
    fi
else
    print_fail "Dark theme CSS file not found"
fi

echo
echo "========================================"
echo "Tests completed!"
echo "========================================"