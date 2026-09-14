---
title: "Markdown Edge Cases in surf: Structure, Code Blocks, and Backticks"
date: 2026-09-13 21:30:00 -0400
categories:
  - Tools
  - CLI
tags:
  - surf
  - context
  - agents
---
This article is part of a series on `surf`, a command line tool I wrote to help AI agents compose their own context more easily, keep it small and their attention focused on the task at hand.

This article deals with some edge cases in surfing markdown, gotchas that popped up over time. Knowing these will help you find what you're looking for, and structure your markdown docs so they're easier to `surf`.

---
## Follow along at home

Some people learn best by reading. If that's you, read on.

I learn best by doing. If you'd rather type the commands yourself and see the same output, I keep the code and data for this blog in my lessons repo, at [github.com/saintx/lessons](https://github.com/saintx/lessons). Each series is a branch and each post is a tag. This post is tag `surf/0003-markdown-edge-cases-in-surf`. If you already cloned for the last post, jump to the checkout. If not, you'll need `git` and `uv` or `pipx`:

```bash
git clone https://github.com/saintx/lessons
cd lessons
git switch surf
./fetch
uv tool install surf-cli==0.8.0
git checkout surf/0003-markdown-edge-cases-in-surf
```

`./fetch` downloads pstack into `corpus/pstack/` at the commit I used, [`889ec4b`](https://github.com/cursor/plugins/tree/889ec4b68fa5aab0e867dad71ec3fdf386ae48f3/pstack) (pstack 0.15.2). The commands below run from the repository root.

---
## Structure beats style

One of the first things I noticed when I first started using `surf` is how often LLM agents use style elements in a Markdown file when they should be using structure elements. For example:

```markdown
## Level Two

Markdown headers roughly translate to the `<h1>` through `<h6>` HTML elements. Because they're ATX headers, we can surf them. They're also called ATX headers. As far as I know, that's not an acronym.

**Level Three**

Pseudo-headers are not structural elements. We can't surf the text under them, because surf is based on document structure. LLMs use these all the time. It's annoying.
```

When I `surf --list` the text above, I only see this:

```
% surf --list example.md
- Level Two
```

The bold pseudo-header is nowhere to be found.

I dropped a bit of guidance into my `CLAUDE.md` file (and later moved it to a skill) to curb the model's bad habit of writing markdown this way:

```markdown
## Markdown Heading Structure

Use H1–H6 headings for every structural division. Never use bold text (`**Title:**`) as a substitute for a heading.

`surf` parses heading hierarchy to give agents visibility into document structure. Bold text is invisible to `surf` — sections headed with bold are unreachable by heading-based navigation.
```

Let's fix it:

```
## Level Two

Markdown headers roughly translate to the `<h1>` through `<h6>` HTML elements. Because they're ATX headers, we can surf them. They're also called ATX headers. As far as I know, that's not an acronym.

### Level Three

Pseudo-headers are not structural elements. We can't surf the text under them, because surf is based on document structure. LLMs use these all the time. It's annoying.
```

Now we can see it:

```bash
% surf --list example.md
- Level Two
  - Level Three
```

---
## Ignore headings in code blocks

If a code block contains markdown headings, `surf` correctly ignores them. For example:

````bash
% surf corpus/pstack/skills/interrogate/references/reviewer-prompt.md "Output"

## Output

Return your findings as a structured list. If you have zero findings, say so. An empty review is a valid outcome.

```
## Findings

### 1. [Severity] Short title
**Location**: file:line or function name
**Finding**: What's wrong
**Evidence**: Why this matters
**Suggestion**: (optional) What to do instead
...
```
````

`"Findings"` isn't part of the document structure, so doesn't show in lists:

```bash
% surf corpus/pstack/skills/interrogate/references/reviewer-prompt.md --list
- Reviewer Prompt Template
  - Intent
  - Code Under Review
  - Review Rubric
  - Code Quality Lens
  - Instructions
  - What Makes a Good Finding
  - What to Avoid
  - Output
```

Trying to look at the text inside of `"Findings"`fails. This is expected:

```bash
% surf corpus/pstack/skills/interrogate/references/reviewer-prompt.md "Findings"
Error: heading "Findings" not found in corpus/pstack/skills/interrogate/references/reviewer-prompt.md.
```

Text inside of a code fence won't be confused as part of the document's structure.

---
### Headers with backticks

Markdown headers can have backticks in them. For example, in `pstack` you'll see them all over the place:

```bash
% surf corpus/pstack/README.md --list
- pstack
  - install
  - get started
  - usage
    - just use [`/poteto-mode`](./skills/poteto-mode/SKILL.md)
  - skills
    - examples
  - the `poteto-agent` and Comment Sicko subagents
  - principles
  - not shipped here
  - why are there no planning skills?
  - make it yours
  - automations
  - license
```


If you try this with double quotes, it won't work:

```bash
% surf corpus/pstack/README.md "pstack#usage#just use [`/poteto-mode`](./skills/poteto-mode/SKILL.md)"
zsh: no such file or directory: /poteto-mode
Error: heading "pstack#usage#just use [](./skills/poteto-mode/SKILL.md)" not found in corpus/pstack/README.md.
```

Double quotes expand backticks. Use single quotes instead:

```bash
% surf corpus/pstack/README.md 'pstack#usage#just use [`/poteto-mode`](./skills/poteto-mode/SKILL.md)'
### just use [`/poteto-mode`](./skills/poteto-mode/SKILL.md)

this skill is the main shortcut. i use it whenever i need the agent to do rigorous engineering work. it comes with twenty-three playbooks:
...
```

