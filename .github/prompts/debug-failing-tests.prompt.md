---
description: "Debug and fix failing test assertions in Ruby or Rust projects"
name: "Debug Failing Tests"
argument-hint: "Paste failing test output or test file with failure"
agent: "agent"
---

# Debug Failing Test Assertion

Analyze the provided failing test and generate a code fix.

## Your Task:

1. **Identify the assertion failure**: What was expected vs. what actually occurred?
2. **Trace the root cause**: Walk through the code logic that led to the mismatch
3. **Provide a fix**: Suggest the minimal code change to make the test pass
4. **Explain**: Brief explanation of why this fix works

## Input Requirements:

- **Failing test output**: The complete test output showing the assertion failure
- **Test file or code snippet**: The test code that's failing
- **Implementation code**: The code being tested (if not obvious from test)

## Output Format:

```
### Assertion Failure Analysis
- Expected: [what the test expected]
- Actual: [what actually happened]
- Failure Type: [assertion type, e.g., equality, error, response code]

### Root Cause
[Brief explanation of why the assertion failed]

### Proposed Fix
\`\`\`[language]
[Fixed code with changes highlighted]
\`\`\`

### Why This Works
[1-2 sentence explanation of the fix]
```

## Tips:

- Include line numbers when referencing code in your analysis
- Consider edge cases: What if the input is empty, nil/null, or unexpected type?
- Check for off-by-one errors in loops or array indexing
- Verify mock/stub behavior matches the actual implementation
