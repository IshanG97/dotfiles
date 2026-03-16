---
name: git-filter-repo
description: Rewrite git history to remove secrets, update authors/emails, fix commit messages, or restructure repos using git-filter-repo
argument-hint: "[task description, e.g. 'remove secrets.txt from history']"
---

# Git History Management with git-filter-repo

Use `git-filter-repo` for all Git history rewriting tasks.

## Removing Sensitive Data
```bash
# Remove files containing secrets
git filter-repo --path secrets.txt --invert-paths

# Replace sensitive text across all files and commit messages
git filter-repo --replace-text <(echo 'password123==>xxxxxxxx')
```

## Author/Email Updates
```bash
# Update contributor information using mailmap
git filter-repo --mailmap .mailmap

# Direct email changes
git filter-repo --email-callback 'if email == b"old@example.com": email = b"new@example.com"'
```

## Commit Message Updates
```bash
# Standardize commit messages
git filter-repo --replace-message <(echo 'typo==>corrected')

# Add consistent prefixes
git filter-repo --message-callback 'message = b"[PROJECT] " + message'
```

## Repository Restructuring
```bash
# Extract subdirectory as new repository root
git filter-repo --subdirectory-filter frontend/

# Move files to new directory structure
git filter-repo --path-rename old-folder/:new-folder/
```
