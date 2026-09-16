---
title: "Duplicate Headings in surf: Path Notation"
date: 2026-09-15 22:17:00 -0400
categories:
  - Tools
  - CLI
tags:
  - surf
  - context
  - agents
---

Sometimes, a markdown document will repeat a header multiple times throughout the document. In Obsidian links, you can get around this by writing a path to the section you want to link to, like `"Foo#Bar#Baz"`. I'm pleased to share that `surf` works the exact same way.

`pstack`, the great Cursor skill library built by Lauren Tan, has a `reproduce-and-fix` skill that ships a feature-map example. Every feature has a `"Gotchas"` section. The file has five of them in total.

## Follow along at home

Some people learn best by reading. If that's you, read on.

I learn best by doing. If you'd rather type the commands yourself and see the same output, I keep the code and data for this blog in my lessons repo, at [github.com/saintx/lessons](https://github.com/saintx/lessons). Each series is a branch and each post is a tag. This post uses tag `surf/0003-markdown-edge-cases-in-surf`. If you already cloned for the last post, jump to the checkout. If not, you'll need `git` and `uv` or `pipx`:

```bash
git clone https://github.com/saintx/lessons
cd lessons
git switch surf
./fetch
uv tool install surf-cli==0.8.0
git checkout surf/0003-markdown-edge-cases-in-surf
```

`./fetch` downloads pstack into `corpus/pstack/` at the commit I used, [`889ec4b`](https://github.com/cursor/plugins/tree/889ec4b68fa5aab0e867dad71ec3fdf386ae48f3/pstack) (pstack 0.15.2). The commands below run from the repository root.

## Which `"Gotchas"`?

```bash
% surf corpus/pstack/automations/benny/skills/reproduce-and-fix-issues/references/feature-map.example.md --list
- Feature-map example
  - Per-feature template
    - `<feature name>`
      - How a user gets there
      - How the control adapter drives it
      - Stable selectors
      - States to exercise
      - Preconditions and setup
      - Evidence and cross-check
      - Gotchas
  - Fictional example
    - Sign in
      - How a user gets there
      - How the control adapter drives it
      - Stable selectors
      - States to exercise
      - Preconditions and setup
      - Evidence and cross-check
      - Gotchas
    - Item list and detail
      - ...
      - Gotchas
    - Item editor
      - ...
      - Gotchas
    - Settings
      - ...
      - Gotchas
  - Completeness checklist
```

A bare `"Gotchas"` sent to `surf` returns the first matching section on the tree, from the top:

```bash
% surf corpus/pstack/automations/benny/skills/reproduce-and-fix-issues/references/feature-map.example.md "Gotchas"
#### Gotchas

- `<known dead end or wrong surface>`
- `<safe environment translation>`
```

To navigate to any of the matching sections other than the first, you can enter a path. They work just like Obsidian links, joined by a path separator character: `#`:

```bash
% surf corpus/pstack/automations/benny/skills/reproduce-and-fix-issues/references/feature-map.example.md "Sign in#Gotchas"
#### Gotchas

- A marketing page is the wrong surface. A missing auth service is a block.
```

It also works on the `"Settings#Gotchas"`, and every other path to a section called `"Gotchas"` in the file:

```bash
% surf corpus/pstack/automations/benny/skills/reproduce-and-fix-issues/references/feature-map.example.md "Settings#Gotchas"
#### Gotchas

- Operating-system settings are a different surface.
```

There you have it. Now you can home in on specific sections, no matter what they're named.
