#!/bin/bash

# Script to generate CHANGELOG.org from git commits
# Uses conventional commits format to categorize changes

generate_header() {
    cat << 'EOL'
#+TITLE: Changelog
#+DATE: $(date +%Y-%m-%d)

* [Unreleased]
EOL
}

parse_conventional_commit() {
    local msg="$1"
    local type=$(echo "$msg" | sed -n 's/^\([a-z]*\)(\([^)]*\)): \(.*\)/\1/p')
    local scope=$(echo "$msg" | sed -n 's/^\([a-z]*\)(\([^)]*\)): \(.*\)/\2/p')
    local description=$(echo "$msg" | sed -n 's/^\([a-z]*\)(\([^)]*\)): \(.*\)/\3/p')
    
    case "$type" in
        feat)     echo "*** Features ($scope)"     ;;
        fix)      echo "*** Fixes ($scope)"        ;;
        docs)     echo "*** Documentation ($scope)" ;;
        style)    echo "*** Style ($scope)"        ;;
        refactor) echo "*** Refactor ($scope)"     ;;
        test)     echo "*** Tests ($scope)"        ;;
        chore)    echo "*** Chores ($scope)"       ;;
        *)        echo "*** Other ($scope)"        ;;
    esac
    
    echo "$description" | sed 's/^/- /'
    
    # Get the body of the commit if it exists
    git log -1 --format="%b" "$commit" | grep -v '^$' | sed 's/^/  /'
}

generate_changelog() {
    local last_tag=$(git describe --tags --abbrev=0 2>/dev/null || echo "")
    local current_date=$(date +%Y-%m-%d)
    
    # Generate header
    generate_header
    
    echo -e "\n** Changed\n"
    
    # Get all commits since last tag (or all if no tags)
    if [ -n "$last_tag" ]; then
        range="$last_tag..HEAD"
    else
        range="HEAD"
    fi
    
    # Group commits by type
    local commits=$(git log --format="%H" $range)
    declare -A grouped_commits
    
    for commit in $commits; do
        local msg=$(git log -1 --format="%s" "$commit")
        local group=$(echo "$msg" | sed -n 's/^\([a-z]*\)(\([^)]*\)): .*/\1/p')
        [ -n "$group" ] && grouped_commits["$group"]+="$commit "
    done
    
    # Output each group
    for type in feat fix docs style refactor test chore; do
        if [ -n "${grouped_commits[$type]}" ]; then
            echo "*** ${type^}"
            for commit in ${grouped_commits[$type]}; do
                local msg=$(git log -1 --format="%s" "$commit")
                parse_conventional_commit "$msg"
            done
            echo
        fi
    done
    
    # Previous releases
    if [ -n "$last_tag" ]; then
        echo -e "\n* Previous Releases\n"
        git tag -l --sort=-v:refname | while read -r tag; do
            local tag_date=$(git log -1 --format=%ai "$tag" | cut -d' ' -f1)
            echo "** [$tag] - $tag_date"
            if [ -n "$prev_tag" ]; then
                range="$tag..$prev_tag"
            else
                range="$tag"
            fi
            git log --format="- %s%n%b" "$range" | sed '/^$/d'
            echo
            prev_tag=$tag
        done
    fi
}

# Main execution
{
    generate_changelog > CHANGELOG.org
    echo "Changelog generated at CHANGELOG.org"
} || {
    echo "Error generating changelog"
    exit 1
}

# Add to git if requested
if [ "$1" = "--commit" ]; then
    git add CHANGELOG.org
    git commit -m "docs(changelog): update changelog [skip ci]

- Auto-generated from git history
- Categorized by conventional commits
- Updated unreleased changes"
fi
