---
name: cockpit-start-work
description: Create a new local work branch from an exact up-to-date remote base without changing product files. Use only when the user asks to prepare or start a branch and supplies or confirms the branch and base.
---

# Cockpit Start Work

This workflow authorizes only safe Git branch preparation. Require the work
branch and base branch; ask one focused question if either is missing.

1. Identify the repository root, current branch, remotes, and worktree state.
2. If tracked or untracked changes could make switching unsafe, stop and report
   them without stashing, discarding, or moving anything.
3. Treat the base as a branch on `origin` unless it starts with the name of a
   configured remote. Fetch the selected remote, then resolve the base to an
   exact remote commit. For example, `develop` selects `origin/develop`, while
   `upstream/main` fetches `upstream` and resolves `upstream/main`.
4. If the work branch already exists locally or on a remote, do not reset,
   recreate, switch to, merge, or rebase it. Report what exists and request one
   decision.
5. Create and switch to the work branch directly from the resolved remote base.
6. Verify the active branch, start SHA, and that the remote base is an ancestor
   of `HEAD`.

Do not edit product files, install dependencies, commit, push, merge, rebase,
stash, or delete branches. Report the branch name, base ref, and start SHA.
