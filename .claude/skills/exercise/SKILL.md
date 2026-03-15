---
name: exercise
description: Generate a coding exercise for practice in a specific language or topic
argument-hint: "[language] [topic/difficulty]"
disable-model-invocation: true
---

# Coding Exercise Generator

Generate a practical coding exercise for the user.

## Arguments

$ARGUMENTS

Parse the arguments for: language (e.g., python, rust, javascript), topic (e.g., data structures, async, error handling), and difficulty (beginner/intermediate/advanced). If not specified, ask.

## Exercise Format

1. **Problem statement** — clear, concise description of what to build
2. **Requirements** — specific inputs, outputs, constraints
3. **Example** — one input/output example to clarify expectations
4. **Hints** (collapsed) — give 2-3 hints the user can ask for if stuck
5. **Do NOT provide the solution.** Wait for the user to attempt it.

## After the user submits their solution

1. **Run it** if possible and verify correctness
2. **Review the code:**
   - Correctness: does it handle edge cases?
   - Style: does it follow language idioms?
   - Performance: is the approach efficient?
   - Readability: could someone else understand this?
3. **Score it** informally (e.g., "solid, 2 things to improve")
4. **Show the optimal solution** if theirs differs significantly, and explain why
5. **Offer a follow-up challenge** that builds on what they just learned
