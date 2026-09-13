---
title: Surfing YAML Frontmatter
date: 2026-09-13 00:28:00 -0400
categories:
  - Tools
  - CLI
tags:
  - surf
  - context
  - agents
---

In my first article, I showed the simplest, most basic things you can do with `surf`:

1. List a Markdown file's headings
2. Show the text for a specific section by name

Most of what I initially needed to do with `surf` was solved with these two steps. But it wouldn't last. 

This combo move is necessary, but only _sufficient_ if you already know the file you want to surf up front. What if you don't?

I wrote `surf` to help me write agent skills. By convention, skills have YAML frontmatter containing a `name` and `description`, but they also allow `metadata` where you can add any key/value pair you want. I immediately saw potential for skill families, skill dependencies, tags and categories, and more.

Given all these things, I couldn't _not_ add YAML frontmatter support, and thus `surf -f` was born.

## Skill Improvement

To really demonstrate `surf`, I need a skill library to use as a starting point. And it should be one that's already great.

One of my favorite Applied AI devs is Lauren Tan ([@poteto](https://x.com/poteto)) who currently works on the Cursor team at SpaceXAI. She built the [pstack](https://github.com/cursor/plugins/tree/main/pstack) plugin, which is big and awesome. After reading through it, I knew `surf` could help make it even better.

So, we're going to clone `pstack` and hack on it and see what we can learn.

### Follow along at home

Some people learn best by reading. If that's you, read on.

I learn best by doing. If you'd rather type the commands yourself and see the same output, I keep the code and data for this blog in my lessons repo, at [github.com/saintx/lessons](https://github.com/saintx/lessons). Each series is a branch and each post is a tag, so you can check out exactly the state a post was written against. This post is tag `surf/0002-surf-yaml-frontmatter`. To get there you'll need `git` and `uv` or `pipx`:

```bash
git clone https://github.com/saintx/lessons
cd lessons
git switch surf
./fetch
uv tool install surf-cli==0.8.0
git checkout surf/0002-surf-yaml-frontmatter
```

`./fetch` downloads pstack into `corpus/pstack/` at the commit I used, [`889ec4b`](https://github.com/cursor/plugins/tree/889ec4b68fa5aab0e867dad71ec3fdf386ae48f3/pstack) (pstack 0.15.2)

If you do not have `uv`, `pipx install surf-cli==0.8.0` works too. The commands below run from the repository root, and the README at the tag repeats them, along with the tag for the next post.

### Digging into pstack

The `pstack` skills directory is pretty large. It holds 23 `principle-` skills, each a `SKILL.md`, each with a heading tree of its own.

Curious, let's see what's in those:

```bash
% surf -l corpus/pstack/skills/principle-*/SKILL.md

==> principle-attack-the-premise/SKILL.md <==
- Attack the Premise

==> principle-boundary-discipline/SKILL.md <==
- Boundary Discipline

==> principle-build-the-lever/SKILL.md <==
- Build the Lever

==> principle-encode-lessons-in-structure/SKILL.md <==
- Encode Lessons in Structure

==> principle-exhaust-the-design-space/SKILL.md <==
- Exhaust the Design Space

==> principle-experience-first/SKILL.md <==
- Experience First

==> principle-fix-root-causes/SKILL.md <==
- Fix Root Causes

==> principle-foundational-thinking/SKILL.md <==
- Foundational Thinking

==> principle-guard-the-context-window/SKILL.md <==
- Guard the Context Window
  
...
```

Not what I was hoping for. The headers re-state the file names, so we need a different tool.

Every `SKILL.md` file starts the same way: a block of YAML between two `---` lines, holding a `name`, a `description`, and a flag or two. That block exists so a harness can decide whether to load the skill without reading it. It is the file describing itself, in a sentence. 

That's what we need here.

### First things first

Instead of asking for a file's structure, we can ask for the frontmatter using `surf -f`:

```bash
surf -f corpus/pstack/skills/principle-guard-the-context-window/SKILL.md

==> principle-guard-the-context-window/SKILL.md <==
---
name: principle-guard-the-context-window
description: "Apply when context is filling up: large outputs, long files, repeated reads, fan-out planning. Route bulk to subagents; keep summaries in the main thread, not raw payloads."
disable-model-invocation: true
---
```

The `description` says "Apply when context is filling up: large outputs, long files, repeated reads." That is my situation, described by the file that solves it. I wonder how they handle that. Let's read that section from the skill file:

```bash
surf corpus/pstack/skills/principle-guard-the-context-window/SKILL.md "Guard the Context Window"

# Guard the Context Window

The context window is finite and non-renewable within a session. Every token should be worth its cost.

**Why:** Context overflow degrades reasoning quality, creates compression artifacts, and halts progress.

**Pattern:**
- **Isolate large payloads.** Route verbose outputs, screenshots, and large documents to subagents. The main context gets summaries, not raw data.
- **Don't read what you won't use.** Read selectively based on relevance. If a file isn't needed for the current task, skip it.
- **Keep frequently used content inline.** Templates and references used on every invocation belong in the skill file, not in separate files that cost a read each time.
- **Size phases and cap scope.** Limit files per phase, set turn budgets, account for mechanism costs.
```

There is a pleasing bit of irony here. The rule I went looking for is "don't read what you won't use," and I found it by not reading what I would not use. It seems we're in violent agreement.

### Multiple files

Reading the frontmatter for one file at a time would require twenty-three invocations, so `surf` lets you take the whole glob and labels each block with the path it came from:

```bash
surf -f corpus/pstack/skills/principle-*/SKILL.md

==> corpus/pstack/skills/principle-foundational-thinking/SKILL.md <==
---
name: principle-foundational-thinking
description: "Apply before writing logic: choosing core types and data structures, sequencing scaffold-vs-feature work, asking what concurrent actors share. Get the data structures right so downstream code becomes obvious."
disable-model-invocation: true
---

==> corpus/pstack/skills/principle-guard-the-context-window/SKILL.md <==
---
name: principle-guard-the-context-window
description: "Apply when context is filling up: large outputs, long files, repeated reads, fan-out planning. Route bulk to subagents; keep summaries in the main thread, not raw payloads."
disable-model-invocation: true
---

==> corpus/pstack/skills/principle-laziness-protocol/SKILL.md <==
---
name: principle-laziness-protocol
description: "Apply when refactoring, evaluating diff size, or tempted to add abstractions, layers, or signal threading. Bias toward deletion and the smallest change that solves the problem."
disable-model-invocation: true
---
...
```

### Why don't you just...

Why not _just_ `head -n 7 corpus/pstack/skills/principle-*/SKILL.md` ?

Sure, we _could_ do that. But the reason we _don't_ goes back to my earlier intro to YAML frontmatter for skills. I mentioned that `name` and `description` were required for skills. I also mentioned an optional `metadata` field.

What if we wanted to classify our skills into families?

I included a `tag-pstack-skills.py` script in the `lessons` repo that does this:

```bash
% python tag-pstack-skills.py
skipped architect (no category)
tagged arena -> fan-out
tagged automate-me -> write
tagged blast-radius -> prove
tagged bro -> constrain
tagged create-verification-skill -> write, prove
tagged figure-it-out -> trail
tagged how -> explain
tagged interrogate -> fan-out
tagged maintain-verification-skill -> write, prove
tagged make-bot-ui -> setup
tagged no-comments -> constrain
tagged poteto-mode -> constrain
tagged principle-attack-the-premise -> constrain
tagged principle-boundary-discipline -> constrain
tagged principle-build-the-lever -> constrain
tagged principle-encode-lessons-in-structure -> constrain
tagged principle-exhaust-the-design-space -> constrain
tagged principle-experience-first -> constrain
tagged principle-fix-root-causes -> constrain
tagged principle-foundational-thinking -> constrain
tagged principle-guard-the-context-window -> constrain
tagged principle-laziness-protocol -> constrain
tagged principle-make-operations-idempotent -> constrain
tagged principle-migrate-callers-then-delete-legacy-apis -> constrain
tagged principle-minimize-reader-load -> constrain
tagged principle-model-the-domain -> constrain
tagged principle-never-block-on-the-human -> constrain
tagged principle-outcome-oriented-execution -> constrain
tagged principle-prove-it-works -> constrain, prove
tagged principle-redesign-from-first-principles -> constrain
tagged principle-separate-before-serializing-shared-state -> constrain
tagged principle-sequence-verifiable-units -> constrain, prove
tagged principle-subtract-before-you-add -> constrain
tagged principle-test-behavior-not-implementation -> constrain, prove
tagged principle-type-system-discipline -> constrain
tagged recall -> explain
tagged reflect -> write, fan-out
tagged setup-pstack -> setup
tagged show-me-your-work -> trail
tagged swarm -> fan-out
tagged tdd -> prove
tagged teach -> explain
tagged technical-writing -> constrain
tagged typescript-best-practices -> constrain
tagged unslop -> constrain
tagged why -> fan-out, explain
46 tagged, 0 unchanged, 1 skipped
```

The categories are mine, not from `pstack` and the script writes them into the sandbox copy. If you want to clean the tags out later, you can `rm -rf corpus/pstack` and re-run the `fetch`.

Now we can see that most skills have `metadata.category` tags:

```bash
% surf -f corpus/pstack/skills/why/SKILL.md
---
name: why
metadata:
  category:
    - fan-out
    - explain
description: "Use for 'why does X work this way', 'why we picked Y', design rationale, regressions, postmortems, or data-backed thresholds. Discovers available MCPs and queries each evidence category (source control, issue tracker, long-form docs, real-time chat, infrastructure observability, error tracking, product analytics warehouse) in parallel, then returns a cited read on decisions and tradeoffs. Use how for runtime behavior."
disable-model-invocation: true
---
```

This one has an `explain` tag. Which other ones do?

```bash
% surf --list corpus/pstack/skills/*/SKILL.md --where metadata.category="explain" --level 1
==> corpus/pstack/skills/how/SKILL.md <==
- How

==> corpus/pstack/skills/recall/SKILL.md <==
- Recall

==> corpus/pstack/skills/teach/SKILL.md <==
- Teach

==> corpus/pstack/skills/why/SKILL.md <==
- Why
```

This opens up some interesting possibilities.

More to come.