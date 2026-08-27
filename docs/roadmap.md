# Roadmap

## Safe prompt refinement

First slice implemented as the portable `prompt-refinement` skill. Every host
consumes that single canonical capability through native skill discovery; no
host-specific alias is maintained.

Cockpit automatically preflights long, ambiguous, conflicting, or repetitive
prompts while letting clear actionable prompts pass unchanged. It improves
clarity and optionally reduces repetition through a hybrid flow.

Safety and UX requirements:

- preserve the original prompt as the authority;
- allow only meaning-preserving editorial changes to flow into execution;
- display the original prompt when a proposed change could alter meaning;
- never invent product decisions, constraints, or missing evidence;
- show the proposed prompt and a compact change summary before use;
- require explicit user validation before any meaning-changing refinement is
  executed;
- provide a safe default mode and an opt-in compact mode;
- bypass clear prompts because agent-level refinement cannot remove the original
  message from context and may otherwise cost more tokens than it saves;
- work through the portable Cockpit skill model rather than a provider-specific
  integration where possible.

The portable skill is the safety boundary. It either performs editorial-only
normalization and flows through, or returns a review surface and stops before a
meaning-changing rewrite is executed. OpenCode also gets a command because it
has an established command adapter; the other hosts do not need
provider-specific duplication.

Future slice — measured prompt optimization:

- collect representative prompt cases and expected outcomes;
- define success criteria, human annotations, or graders;
- compare the original and candidate prompts across the evaluation set;
- record quality, latency, and token/cost trade-offs before recommending a
  winner.

This eval-driven workflow is intentionally distinct from one-shot refinement.

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
