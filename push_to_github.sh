#!/bin/bash

# Script to push VHDL project to GitHub
# Usage: ./push_to_github.sh <github-repo-url>
# Example: ./push_to_github.sh https://github.com/username/vhdl_ghdl_demo.git

if [ -z "$1" ]; then
    echo "Usage: ./push_to_github.sh <github-repo-url>"
    echo "Example: ./push_to_github.sh https://github.com/username/vhdl_ghdl_demo.git"
    echo ""
    echo "Or if you want to create a new repo on GitHub:"
    echo "1. Go to https://github.com/new"
    echo "2. Create a new repository (don't initialize with README)"
    echo "3. Copy the repository URL"
    echo "4. Run this script with that URL"
    exit 1
fi

REPO_URL="$1"

echo "Adding GitHub remote..."
git remote add origin "$REPO_URL" 2>/dev/null || git remote set-url origin "$REPO_URL"

echo "Checking current branch..."
CURRENT_BRANCH=$(git branch --show-current)
echo "Current branch: $CURRENT_BRANCH"

echo ""
echo "Pushing to GitHub..."
echo "If this is your first push, you may need to use:"
echo "  git push -u origin $CURRENT_BRANCH"
echo ""
read -p "Press Enter to continue with push, or Ctrl+C to cancel..."

git push -u origin "$CURRENT_BRANCH"

if [ $? -eq 0 ]; then
    echo ""
    echo "✅ Successfully pushed to GitHub!"
    echo "Repository: $REPO_URL"
else
    echo ""
    echo "❌ Push failed. Common issues:"
    echo "1. Authentication required - you may need to set up GitHub credentials"
    echo "2. Repository doesn't exist - create it on GitHub first"
    echo "3. Network issues - check your connection"
fi

