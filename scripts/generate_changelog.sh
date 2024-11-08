#!/bin/bash
# Script to generate CHANGELOG.org from git commits

set -euo pipefail

generate_header() {
    cat << EOF
#+TITLE: Changelog
#+DATE: $(date +%Y-%m-%d)
* [Unreleased]
EOF
}

parse_commit() {
    local msg="$1"
    local type scope description
    
    # Extract parts using sed
    type=$(echo "$msg" | sed -n 's/^\([a-z]*\)(\([^)]*\)): .*/\1/p')
    scope=$(echo "$msg" | sed -n 's/^\([a-z]*\)(\([^)]*\)): .*/\2/p')
    description=$(echo "$msg" | sed -n 's/^\([a-z]*\)(\([^)]*\)): \(.*\)/\3/p')
    
    # Default values if parsing fails
    type=${type:-other}
    scope=${scope:-general}
    description=${description:-$msg}
    
    case "$type" in
        feat)     echo "*** Features ($scope)" ;;
        fix)      echo "*** Fixes ($scope)" ;;
        docs)     echo "*** Documentation ($scope)" ;;
        style)    echo "*** Style ($scope)" ;;
        refactor) echo "*** Refactor ($scope)" ;;
        test)     echo "*** Tests ($scope)" ;;
        chore)    echo "*** Chores ($scope)" ;;
        *)        echo "*** Other ($scope)" ;;
    esac
    
    echo "- $description"
}

generate_changelog() {
    local last_tag current_date range
    
    last_tag=$(git describe --tags --abbrev=0 2>/dev/null || echo "")
    current_date=$(date +%Y-%m-%d)
    
    # Generate header
    generate_header
    
    echo -e "\n** Changed\n"
    
    # Get range of commits
    if [ -n "$last_tag" ]; then
        range="$last_tag..HEAD"
    else
        range="HEAD"
    fi
    
    # Process commits
    git log --format="%s" $range | while read -r commit_msg; do
        parse_commit "$commit_msg"
    done
    
    # Add previous releases if they exist
    if [ -n "$last_tag" ]; then
        echo -e "\n* Previous Releases\n"
        git tag -l --sort=-v:refname | while read -r tag; do
            local tag_date
            tag_date=$(git log -1 --format=%ai "$tag" | cut -d' ' -f1)
            echo "** [$tag] - $tag_date"
            git log --format="- %s" "$tag" -n 1
            echo
        done
    fi
}

main() {
    if ! generate_changelog > CHANGELOG.org; then
        echo "Error generating changelog"
        exit 1
    fi
    
    echo "Changelog generated at CHANGELOG.org"
    
    # Commit if requested
    if [ "${1:-}" = "--commit-message" ]; then
        shift
        message=${1:-"docs(changelog): update changelog [skip ci]"}
        git add CHANGELOG.org
        git commit -m "$message"
        echo "Changelog committed with message: $message"
    fi
}

main "$@"
