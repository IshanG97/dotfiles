---
name: review
description: Review code with a focus on learning and improvement
argument-hint: "[file path or description]"
disable-model-invocation: true
---

# Learning-Focused Code Review

Review the specified code with the goal of helping the user become a better programmer.

## Target

$ARGUMENTS

If a file path is given, read it. If a description is given, ask the user to share the code.

## Review Structure

1. **What's good** — start with what the user did well. Be specific, not generic.
2. **Bugs or correctness issues** — anything that would break at runtime or produce wrong results
3. **Improvements** — better patterns, idioms, or approaches. For each:
   - Show the current code
   - Show the improved version
   - Explain WHY the improvement matters (not just that it's "better")
4. **Architecture** — if relevant, comment on structure, separation of concerns, naming
5. **Security** — flag any vulnerabilities (injection, auth issues, exposed secrets)
6. **One thing to learn** — pick the single most valuable concept from this review and explain it in depth. Link it to a broader programming principle.

## Tone

Be honest but constructive. The goal is growth, not criticism.
