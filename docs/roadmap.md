# Roadmap

## Safe prompt refinement

Future feature — not part of the current Cockpit workflow.

Add an explicitly invoked, host-agnostic `Refine` capability for long or
ambiguous prompts. It should improve clarity and optionally reduce repetition
without executing the request.

Safety and UX requirements:

- preserve and display the original prompt;
- never invent product decisions, constraints, or missing evidence;
- show the proposed prompt and a compact change summary before use;
- require explicit user validation before the refined prompt is executed;
- provide a safe default mode and an opt-in compact mode;
- remain optional because refining short prompts can cost more tokens than it
  saves;
- work through the portable Cockpit skill model rather than a provider-specific
  integration where possible.

Before implementation, validate how each host can separate refinement from
execution and choose whether `Refine` should be a skill, command, or both.

## Shareable Backpack with private profiles

Future feature — not part of the current installer.

Separate the distributable Backpack core from owner-specific configuration:

- public, generic Backpack: Cockpit workflow, adapters, reusable skills, and
  installer;
- private AlxTx profile: professional persona, model routing, dotfiles, memory,
  Git/SSH conventions, and personal paths;
- generic profile by default for another user;
- optional local or private-repository profile installation, for example
  `backpack install cockpit --profile alxtx`;
- no AlxTx profile content in the public repository;
- use a clean public repository history if the current personal repository ever
  contains information that should not become public.

Before implementation, define the profile contract, local storage location,
update mechanism, failure behavior when a private profile is unavailable, and
migration path for the current repository.
