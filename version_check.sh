#!/bin/bash

#########################################################################
# CyberPanel Version Check Script
# This script fetches the latest version from GitHub and compares it 
# with the current running server version.
#########################################################################

set -e

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Print colored output
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Function to get current local version
get_current_version() {
    local version_file="/usr/local/CyberCP/version.txt"
    local fallback_version_file="./version.txt"
    
    # Try the standard installation path first
    if [ -f "$version_file" ]; then
        local current_data=$(cat "$version_file" 2>/dev/null)
    # Fallback to local development version file
    elif [ -f "$fallback_version_file" ]; then
        local current_data=$(cat "$fallback_version_file" 2>/dev/null)
        print_status "Using development version file: $fallback_version_file"
    else
        print_error "Version file not found at $version_file or $fallback_version_file"
        return 1
    fi
    
    if [ -n "$current_data" ]; then
        # Parse JSON to extract version and build
        CURRENT_VERSION=$(echo "$current_data" | grep -o '"version":"[^"]*"' | cut -d'"' -f4)
        CURRENT_BUILD=$(echo "$current_data" | grep -o '"build":[0-9]*' | cut -d':' -f2)
    else
        print_error "Version file is empty"
        return 1
    fi
}

# Function to get current commit hash
get_current_commit() {
    local cyberpanel_path="/usr/local/CyberCP"
    local fallback_path="."
    
    # Try standard installation path first
    if [ -d "$cyberpanel_path/.git" ]; then
        CURRENT_COMMIT=$(git -C "$cyberpanel_path" rev-parse HEAD 2>/dev/null)
        if [ $? -ne 0 ]; then
            print_warning "Could not get current commit hash from $cyberpanel_path"
            CURRENT_COMMIT="unknown"
        fi
    # Fallback to current directory for development
    elif [ -d "$fallback_path/.git" ]; then
        CURRENT_COMMIT=$(git -C "$fallback_path" rev-parse HEAD 2>/dev/null)
        if [ $? -ne 0 ]; then
            print_warning "Could not get current commit hash from $fallback_path"
            CURRENT_COMMIT="unknown"
        else
            print_status "Using development git repository"
        fi
    else
        print_warning "No git repository found in $cyberpanel_path or $fallback_path"
        CURRENT_COMMIT="unknown"
    fi
}

# Function to fetch latest version from cyberpanel.net
fetch_latest_version() {
    print_status "Fetching latest version information from cyberpanel.net..."
    
    local version_url="https://cyberpanel.net/version.txt"
    
    # Check if we're in test mode (if CYBERPANEL_TEST_MODE is set)
    if [ -n "$CYBERPANEL_TEST_MODE" ]; then
        print_status "Running in test mode - using mock data"
        LATEST_VERSION="2.4"
        LATEST_BUILD="4"  # Simulate a newer build for testing
        print_success "Latest version: $LATEST_VERSION (Build $LATEST_BUILD)"
        return 0
    fi
    
    local temp_response=$(curl --silent --max-time 30 -4 "$version_url" 2>/dev/null)
    
    if [ $? -ne 0 ] || [ -z "$temp_response" ]; then
        print_error "Failed to fetch version information from $version_url"
        print_status "You can run this script in test mode by setting: CYBERPANEL_TEST_MODE=1"
        return 1
    fi
    
    # Parse JSON response
    LATEST_VERSION=$(echo "$temp_response" | grep -o '"version":"[^"]*"' | cut -d'"' -f4)
    LATEST_BUILD=$(echo "$temp_response" | grep -o '"build":[0-9]*' | cut -d':' -f2)
    
    if [ -z "$LATEST_VERSION" ] || [ -z "$LATEST_BUILD" ]; then
        print_error "Failed to parse version information from response"
        return 1
    fi
    
    print_success "Latest version: $LATEST_VERSION (Build $LATEST_BUILD)"
}

# Function to fetch latest commit from GitHub
fetch_latest_commit() {
    print_status "Fetching latest commit information from GitHub..."
    
    # Check if we're in test mode
    if [ -n "$CYBERPANEL_TEST_MODE" ]; then
        print_status "Running in test mode - using mock commit data"
        LATEST_COMMIT="abcd1234567890abcd1234567890abcd12345678"  # Mock commit
        return 0
    fi
    
    local github_url="https://api.github.com/repos/usmannasir/cyberpanel/commits?sha=v${LATEST_VERSION}.${LATEST_BUILD}"
    local commit_response=$(curl --silent --max-time 30 "$github_url" 2>/dev/null)
    
    if [ $? -ne 0 ] || [ -z "$commit_response" ]; then
        print_warning "Failed to fetch commit information from GitHub"
        LATEST_COMMIT="unknown"
        return 0
    fi
    
    # Parse JSON to get the first commit SHA
    LATEST_COMMIT=$(echo "$commit_response" | grep -o '"sha":"[^"]*"' | head -1 | cut -d'"' -f4)
    
    if [ -z "$LATEST_COMMIT" ]; then
        print_warning "Failed to parse commit information"
        LATEST_COMMIT="unknown"
    fi
}

# Function to compare versions
compare_versions() {
    print_status "Comparing versions..."
    echo
    echo "=========================================="
    echo "         VERSION COMPARISON"
    echo "=========================================="
    echo
    
    # Current version info
    echo "CURRENT VERSION:"
    echo "  Version: $CURRENT_VERSION"
    echo "  Build:   $CURRENT_BUILD"
    echo "  Commit:  ${CURRENT_COMMIT:0:8}..."
    echo
    
    # Latest version info
    echo "LATEST VERSION:"
    echo "  Version: $LATEST_VERSION"
    echo "  Build:   $LATEST_BUILD"
    echo "  Commit:  ${LATEST_COMMIT:0:8}..."
    echo
    
    # Version comparison
    echo "COMPARISON RESULT:"
    
    if [ "$CURRENT_VERSION" = "$LATEST_VERSION" ] && [ "$CURRENT_BUILD" = "$LATEST_BUILD" ]; then
        if [ "$CURRENT_COMMIT" = "$LATEST_COMMIT" ] && [ "$LATEST_COMMIT" != "unknown" ]; then
            print_success "✓ Your CyberPanel is up to date!"
            UP_TO_DATE=true
        else
            print_warning "⚠ Same version but different commits detected"
            print_warning "  You may have local modifications or unreleased changes"
            UP_TO_DATE=false
        fi
    else
        print_warning "⚠ A newer version is available!"
        print_warning "  Current: v${CURRENT_VERSION}.${CURRENT_BUILD}"
        print_warning "  Latest:  v${LATEST_VERSION}.${LATEST_BUILD}"
        UP_TO_DATE=false
    fi
    
    echo "=========================================="
}

# Function to show upgrade instructions
show_upgrade_info() {
    if [ "$UP_TO_DATE" = false ]; then
        echo
        print_status "To upgrade CyberPanel, you can use:"
        echo "  1. Web Interface: Go to Main > Version Management"
        echo "  2. Command Line: sh <(curl https://cyberpanel.net/install.sh || wget -O - https://cyberpanel.net/install.sh) upgrade"
        echo "  3. Manual: Use the cyberpanel_upgrade.sh script in your installation directory"
        echo
        print_warning "Important: Always backup your data before upgrading!"
    fi
}

# Main function
main() {
    echo "=========================================="
    echo "    CyberPanel Version Check Script"
    echo "=========================================="
    echo
    
    # Get current version information
    if ! get_current_version; then
        exit 1
    fi
    
    get_current_commit
    
    # Fetch latest version information
    if ! fetch_latest_version; then
        exit 1
    fi
    
    fetch_latest_commit
    
    # Compare versions
    compare_versions
    
    # Show upgrade information if needed
    show_upgrade_info
    
    echo
    print_status "Version check completed."
    
    # Exit with appropriate code
    if [ "$UP_TO_DATE" = true ]; then
        exit 0
    else
        exit 1
    fi
}

# Script execution starts here
main "$@"