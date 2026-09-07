---
layout: post
title: "Traverse context without ingesting it."
---

I published my `surf` tool. Source is at [https://github.com/saintx/surf-cli](https://github.com/saintx/surf-cli)

### How it works

Instead of reading a markdown file into context, use `surf` to list its H1-H6 heading structure:

```bash
% surf README.md
- surf
  - When to use
  - Addressing
  - Agent skill
  - Install
    - Nix
  - Releasing
  - Development
  - Tests
```

Then, read only the part you're interested in:

```
% surf README.md "When to use"
## When to use

Invoke when skimming markdown, TeX, or PDF files, checking what a file contains,
listing structure, extracting a named address, or batch-scanning metadata across
a directory. See `surf --help` for CLI flags. Skip when the full body is already
needed. ...
```

