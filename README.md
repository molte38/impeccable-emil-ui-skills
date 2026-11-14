# impeccable-emil-ui-skills

**Two of the best UI skills for Claude Code, installed together with one command:**
[Emil Kowalski's design-engineering skills](https://github.com/emilkowalski/skills) (how an interface *moves and feels*) and
[Impeccable](https://github.com/pbakaus/impeccable) by Paul Bakaus (what an interface *should be*, and a detector for AI-generated sameness).

```bash
curl -fsSL https://raw.githubusercontent.com/molte38/impeccable-emil-ui-skills/main/install.sh | sh -s -- --global
```

That copies 20 skills into `~/.claude/skills`. Restart Claude Code and ask it to build, review or polish a UI.

## Why the two together

An agent left alone tends to produce interfaces that are *plausible and generic*: default fonts and gradients, centred hero sections, a `transition: all 0.3s ease` on everything. The two skill sets attack different halves of that problem.

| | **Impeccable** (Paul Bakaus) | **Emil Kowalski's skills** |
|---|---|---|
| Question it answers | *What should this look like, and is it good?* | *How should this move, respond and feel under the finger?* |
| Strength | Design direction with a point of view; a vocabulary of commands to steer (`shape`, `bolder`, `quieter`, `polish`, `typeset`, `layout`, `colorize`, `delight`…) and to review (`critique`, `audit`); a detector that flags common "AI slop" patterns | Micro-interactions and motion craft: easing and duration choices, enter/exit and interruptible transitions, gestures and sheets, press and hover states, animation performance, mobile-native feel, worst-case data |
| Typical use | Design or redesign a page; critique and audit a UI; remove slop before it ships | Build an animation from scratch; review or audit the motion in a codebase; make a web app feel native on a phone |

Use Impeccable to get the layout, type, colour and tone right, then Emil's skills to make the details of motion and touch feel finished. Both are written as plain Markdown instructions, so they compose in a single conversation.

## What you get

**Impeccable** (`impeccable`, v4.9.1): one skill with sub-commands, e.g. `/impeccable critique`, `/impeccable audit`, `/impeccable polish`, `/impeccable shape`, `/impeccable bolder`, `/impeccable animate`, `/impeccable typeset`, `/impeccable init` (captures your product context in a `PRODUCT.md`) and `/impeccable document` (records an existing design in a `DESIGN.md`), plus reference playbooks for iOS, Android, layout, hooks and more.

**Emil Kowalski's 19 skills:**

| Area | Skills |
|---|---|
| Philosophy | `emil-design-eng` (the main one: motion, polish and the invisible details), `learn-taste`, `apple-design` |
| Animation | `animate`, `animate-expo` (React Native / Expo), `choreograph`, `animation-vocabulary`, `animation-performance` |
| Review and audit | `review-animations`, `improve-animations`, `find-animation-opportunities`, `remove-animations` |
| Interaction | `gestures`, `mobile-native` |
| Building and testing | `prototype`, `break-ui`, `pick-ui-library`, `ask-sonner`, `write-swift` |

Everything lives in [`.claude/skills/`](.claude/skills) as unmodified copies of the upstream skills (exact versions below).

## Install

**One command (recommended):**

```bash
# for every project on this machine
curl -fsSL https://raw.githubusercontent.com/molte38/impeccable-emil-ui-skills/main/install.sh | sh -s -- --global

# for the current project only
curl -fsSL https://raw.githubusercontent.com/molte38/impeccable-emil-ui-skills/main/install.sh | sh -s -- --local
```

**From a clone** (you can read the script first, it is short):

```bash
git clone https://github.com/molte38/impeccable-emil-ui-skills.git
cd impeccable-emil-ui-skills
./install.sh --global          # or --local, or --dir ~/my-app
```

Options: `--only emil` or `--only impeccable`, `--force` (replace skills that are already installed; otherwise they are skipped), `--dry-run` (show what would happen). The script only copies skill folders: it installs no hooks and does not touch `settings.json`.

**Or install each from its author** with the official tools:

```bash
npx skills@latest add emilkowalski/skills     # Emil Kowalski's skills
npx impeccable install                        # Impeccable (also offers its optional design hook)
```

Restart Claude Code afterwards so it picks the skills up.

## Example prompts

Skills trigger from what you ask, or you can call them by name. A few that use both:

```text
Build a pricing page for a developer tool. Run /impeccable shape first, then build it,
then use /emil-design-eng to review the hover, press and enter states.
```

```text
/impeccable critique the checkout flow, fix what it finds, and then
/review-animations the transitions between its steps.
```

```text
Redesign this settings dialog with /impeccable polish, and make the open/close feel right:
use the animate skill (origin-aware, interruptible, nothing slower than it needs to be).
```

```text
This landing page looks like every AI landing page. /impeccable bolder, then
/find-animation-opportunities, but tell me what NOT to animate.
```

```text
Make this web app feel native on an iPhone: /mobile-native, then /gestures for the bottom sheet,
and /break-ui to try it with worst-case data.
```

(`review-animations`, `learn-taste`, `prototype` and `pick-ui-library` are manual-only: invoke them with the slash command.)

## What the vendored code does (read before you install)

These are upstream projects, copied unmodified; this repo adds only `install.sh`, this README and the licence files. Worth knowing:

- **Emil Kowalski's skills are plain Markdown.** No scripts.
- **Impeccable ships a launcher and a small engine.** On first use `scripts/impeccable` runs an engine binary. If none is present it **downloads one from the project's own GitHub releases** (`pbakaus/impeccable`) and verifies it against the SHA-256 digests in `scripts/engine-checksums.txt` before running it. It refuses to run an unverified download. Its "live" mode talks to a token-protected local server on `localhost`.
- **Impeccable telemetry.** When a new design starts, the skill fetches visual directions from the `impeccable.style` catalog; an anonymous record of which direction was picked is sent unless you opt out (`npx impeccable telemetry off`, `DO_NOT_TRACK=1`, or `"telemetry": false` in `.impeccable/config.json`). Project files, code and `PRODUCT.md` are not sent. See [impeccable.style/privacy](https://impeccable.style/privacy).
- **Hooks are not installed by this repo.** Impeccable's optional design hook (installed by `npx impeccable install`, not by `install.sh`) runs after edits, outside the model's approval step. Review it before using it unattended.

## Versions

| Source | Version | Upstream commit |
|---|---|---|
| [emilkowalski/skills](https://github.com/emilkowalski/skills) (MIT) | 19 skills | `0f2e23b32bb1265e84cff8d3e75785fec953fb1b` (2026-11-13) |
| [pbakaus/impeccable](https://github.com/pbakaus/impeccable) (Apache-2.0) | skill 4.9.1, engine 0.1.24 | `1995764b4936f2bfbf4eb719cb37b384a45ceacb` (2026-11-14) |

To update, copy the new `skills/*` from Emil's repo and `.claude/skills/impeccable` from Impeccable's repo over the folders in `.claude/skills/`, and update the table above.

## Credits and licences

- **[Emil Kowalski](https://emilkowal.ski)** ([@emilkowalski](https://github.com/emilkowalski)) wrote the design-engineering skills: [github.com/emilkowalski/skills](https://github.com/emilkowalski/skills), site [aiforui.dev](https://aiforui.dev). MIT licence: [`licenses/LICENSE-emilkowalski-skills.txt`](licenses/LICENSE-emilkowalski-skills.txt).
- **[Paul Bakaus](https://github.com/pbakaus)** wrote Impeccable: [github.com/pbakaus/impeccable](https://github.com/pbakaus/impeccable), site [impeccable.style](https://impeccable.style). Apache License 2.0: [`licenses/LICENSE-impeccable-apache-2.0.txt`](licenses/LICENSE-impeccable-apache-2.0.txt); third-party notice: [`licenses/NOTICE-impeccable-third-party.md`](licenses/NOTICE-impeccable-third-party.md).
- The installer and this README are MIT-licensed ([`LICENSE`](LICENSE)).

This is an unofficial bundle, not affiliated with or endorsed by either author. All the credit for the skills is theirs: if they are useful to you, star and follow the originals.
