#!/usr/bin/env bash

# Use Git’s colored diff when available
if command -v git &> /dev/null; then
  alias diff='git diff --no-index --color-words'
fi
