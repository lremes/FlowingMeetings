#!/bin/bash
# Run this before making commit for a release  

echo "Precompiling assets..."
rm -rf tmp/cache
rm -rf public/assets/*
rm -rf public/packs/*
rm -rf tmp/cache
RAILS_ENV=production rake assets:precompile
git add public/assets/
echo "Done."
