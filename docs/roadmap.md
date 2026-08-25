# Roadmap

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
