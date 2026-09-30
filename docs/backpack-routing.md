# How to use Backpack Engineering

Use Backpack inside your project folder in Super, Codex, Claude Code, or
OpenCode. Describe the work in your own words. You do not need to choose a
workflow step for every task.

## 1. Open the project

Open the project's folder in your AI tool and start a new chat. Point to the
brief, ticket, decisions, or existing work if they matter. Attach anything the
tool cannot read from the folder.

## 2. Choose how to start

| Your situation | Do this |
|---|---|
| New project or substantial feature | Share the idea or brief, then run **Kickoff**. |
| Project already underway | Share the current brief, decisions, and delivered work, then run **Kickoff**. Ask it to resume from the current state. |
| Small, clear task | Describe the change directly. Skip Kickoff. |

Kickoff is a guided conversation. Answer its next question in the same chat; it
asks one material question at a time. It does not start implementation.

| Tool | Kickoff | Validate |
|---|---|---|
| Super | **🧭 Kickoff** in the worktree action card or Command Palette | **⚖️ Validate** |
| Codex | Select `$backpack-kickoff` in the skill picker | Select `$backpack-validate` |
| Claude Code | `/backpack-kickoff` | `/backpack-validate` |
| OpenCode | `/backpack-kickoff` | `/backpack-validate` |

For a new project, send a short message before Kickoff:

> I'm starting a new project. Here is the idea and brief: … Show me the progress
> of the first slice and ask only the next question.

For work already in progress:

> Resume from the brief, decisions, and work already done. Show what is done,
> in progress, and pending for the current slice. Ask only the next question.

Backpack can show a checklist in the chat. It separates **Discovery** (problem
and users), **Definition** (requirements and UX), **Engineering** (technical
design and plan), and **Delivery** (Build and proof). A section is marked done
only when there is evidence for the current slice. Engineering can still be
pending while Discovery is in progress. Ask for a project-owned Markdown tracker
only if you want that checklist to persist across chats.

Example view for a slice still in Discovery:

```md
- [ ] Discovery - In progress (problem known; audience pending)
- [ ] Definition - Pending
- [ ] Engineering - Pending
- [ ] Delivery - Pending
```

## 3. Ask for the next slice to be built

When the next deliverable and how to check it are clear, say:

> Build the next slice we just defined.

For a substantial Build in Super, **👥 Team build** can coordinate independent
work in visible sessions. For ordinary work, the normal chat is enough.

## 4. Check the result

For a completed slice, run **Validate** using the table above. Backpack reports
Code Review and Product QA separately. If the app cannot run locally, it uses
the available requirements, diff, CI, preview, screenshots, or logs and names
any behavior that still needs proof.

If you want the changes committed or pushed after reviewing the result, say
`commit`, `push`, or `commit and push` explicitly. Validation alone does not
perform Git delivery.

**📚 Learn** is optional after a meaningful completed slice. Use
`$backpack-learn` in Codex, `/backpack-learn` in Claude Code or OpenCode, or
**📚 Learn** in Super when a reusable lesson is worth keeping.

## Refresh Backpack

Open a terminal in the Backpack checkout, update it, then launch the menu:

```sh
git pull --ff-only
./backpack
```

Choose **Install or refresh** → **Backpack Engineering** → the tool you use (or
**All supported tools**). Restart the app and open a new chat. The completion
screen shows what was installed and a short summary of committed changes since
the previous install. If Git reports local changes that prevent the pull, review
them before updating.

For installation options, see [Install](install.md). For the underlying rules,
models, and host boundaries, see the [AI workflow reference](ai-workflow.md).
