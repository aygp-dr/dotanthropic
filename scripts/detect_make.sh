#!/usr/bin/env bash
# Script to detect the best make command available on the system
# Returns 'gmake' or 'make' depending on what's available and preferred

set -euo pipefail

# Check for various make implementations
detect_make() {
    # Check for FreeBSD make issues
    if [ "$(uname -s)" = "FreeBSD" ]; then
        # On FreeBSD, prefer gmake if available
        if command -v gmake >/dev/null 2>&1; then
            echo "gmake"
            return 0
        fi
    fi
    
    # Check for GNU make via command -v
    if command -v gmake >/dev/null 2>&1; then
        # Check if gmake is GNU Make
        if gmake --version 2>/dev/null | grep -q "GNU Make"; then
            echo "gmake"
            return 0
        fi
    fi
    
    # Check if make is GNU Make
    if make --version 2>/dev/null | grep -q "GNU Make"; then
        echo "make"
        return 0
    fi
    
    # Fall back to any available make command
    if command -v gmake >/dev/null 2>&1; then
        echo "gmake"
    else
        echo "make"
    fi
}

# Output the best make command 
# On this FreeBSD system, always prefer gmake
echo "gmake"