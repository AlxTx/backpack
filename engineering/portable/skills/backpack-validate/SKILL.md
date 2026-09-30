---
name: backpack-validate
description: Run independent Code Review and Product QA on completed work. In GitHub Copilot, do not use this skill; follow the client-owned workflow instead.
---

# Backpack Validate

Preserve the active requirements, decisions, expected proof, and diff scope. Do
not reinterpret the delivery contract or widen the work.

Obtain independent read-only Code Review and Product QA reports. Code Review
checks whether the solution is correctly built; Product QA checks whether the
right product was built. Use the host's dedicated agents when available, or
separate general-purpose agents with the same bounded contracts. Let the host
choose session and handoff mechanics; use app-managed orchestration only when
the user requested it. Keep the two reports and verdicts separate. If
independent review is unavailable, report `DEPENDENCY PENDING`; a self-audit
can still provide diagnostic findings, but not `READY TO SHIP`.

Product QA audits every scoped criterion using available evidence: requirements,
the diff, existing behavior, contracts, CI results, a preview or staging build,
screenshots, logs, or safe browser access when relevant. Record what each source
actually proves. Lack of a local runtime alone does not make the whole QA fail
or pending. Do not infer rendered, interactive, or integration behavior from
source code alone. If a material criterion still lacks trustworthy proof,
mark that criterion unverified, name the owner and smallest safe way to obtain
proof, and return Product QA `DEPENDENCY PENDING`. Static criteria may pass on
sufficient static evidence.

Do not edit files or perform Git delivery actions. Missing requirements,
credentials, fixtures, or external access are dependencies only when they
prevent proof required for a scoped criterion.

Consolidate the result:

- `READY TO SHIP` only when Code Review is `APPROVE` and Product QA is `PASS`;
- `CHANGES REQUIRED` when either lens finds an in-scope defect;
- `DEPENDENCY PENDING` when required proof or external work is unavailable.

Return the status first, then the two verdicts with material evidence, residual
risk, manual-acceptance recommendation, diff scope, and Git state. End by stating
that no commit, push, merge, pull request, or deployment was performed.
