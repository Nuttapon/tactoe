#!/bin/bash
# Local dev script — reads keys from .env.local (gitignored)
# Usage: ./dev.sh

if [ ! -f .env.local ]; then
  echo "❌ .env.local not found. Create it with SUPA_URL= and SUPA_KEY="
  exit 1
fi

source .env.local

cp index.html index.dev.html
# macOS sed requires empty string after -i
sed -i '' "s|SUPA_URL_PLACEHOLDER|$SUPA_URL|g" index.dev.html
sed -i '' "s|SUPA_KEY_PLACEHOLDER|$SUPA_KEY|g" index.dev.html

echo "✅ index.dev.html ready — opening in browser..."
open index.dev.html
