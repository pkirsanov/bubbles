# IMP-037 - Evidence-Backed Experience Recall

**Status:** APPLIED 2026-08-07 - SCOPE-1 through SCOPE-7 are implemented, measured, and validated; all scope blocks are removed as delivered
**Surface:** framework-health (G125) - human-reviewed and approved for systematic implementation
**Motivation:** Source review found that Bubbles preserves structured execution history, lessons, decisions, findings, and outcomes. It has no relevance search or bounded restoration surface over those artifacts. The approved capability must retrieve only Bubbles-owned structured records. It must preserve source authority, repository scope, freshness, and lifecycle.
**Verified gaps addressed:** LRN-4 - structured experience has no relevance retrieval or drill-down surface. EV-7 - no recall-specific admission, authority, freshness, or lifecycle contract exists. REG-8 - the CLI and MCP catalogs expose no experience-recall operation.

## Problem (verified against source)

- **LRN-4 - structured experience is retained but cannot be searched by relevance.** `context-compactor.sh` emits compact RESULT-ENVELOPE records with source pointers. Orchestrators append them to `compactedHistory[]`. `trajectory-inspector.sh` summarizes session, lesson, and spec state. Neither surface accepts a relevance query or returns bounded, source-linked prior experience.
- **EV-7 - the existing artifacts do not share one admission or trust contract.** Compacted results carry evidence references and `rawPointer`. RESULT-ENVELOPE findings and outcomes have a JSON schema. Lesson entries are structured prose, but current `lessons add` entries have no stable id, source anchor, repository scope, review state, or freshness metadata. Owner decisions also live in several schema-backed surfaces rather than one universal record.
- **REG-8 - no CLI or MCP surface exposes experience recall.** The CLI has `lessons`, `skill-proposals`, and `trajectory`. The MCP catalog has bash-backed code, gate, spec, evidence, finding, observability, and graph tools. It has no experience search, experience read, or experience status tool.
- **Source correction - compaction does not append its own result.** `context-compactor.sh` emits a deterministic record and stamps matching `envelopesReceived[]` metadata. The orchestrator contract performs the `compactedHistory[]` append. IMP-037 must preserve that boundary.
- **Rejected predecessor - raw session-store mining is not this capability.** Historical IMP-034 SCOPE-4 proposed an optional host session-store adapter. The current index records that no adapter was registered. IMP-037 rejects raw host transcripts and automatic conversation warehousing. It does not revive LRN-3.

## Provenance

This proposal is based on direct source inspection and one historical Git object. It does not infer behavior from filenames.

| Source | Established fact |
|---|---|
| `improvements/TEMPLATE.md` and `improvements/INDEX.md` | G125 proposal shape, accepted status vocabulary, gap families, and IMP-037 allocation |
| `bubbles/scripts/context-compactor.sh` | Compact record fields, deterministic output, evidence truncation, repository packet preservation, and `rawPointer` drill-down |
| `agents/bubbles_shared/operating-baseline.md` | Orchestrators append compact records to `compactedHistory[]` and must re-read `rawPointer` for decision detail |
| `bubbles/schemas/result-envelope.schema.json` | Structured outcomes, findings, addressed findings, unresolved findings, evidence references, and repository binding |
| `agents/bubbles_shared/artifact-ownership.md` and `agents/bubbles_shared/execution-ops.md` | Lessons are append-only structured memory written at result close after a non-obvious fix |
| `bubbles/scripts/cli.sh` and `bubbles/scripts/skill-evolution.sh` | Current lesson write path, lesson clustering, trajectory command, and lack of a recall command |
| `bubbles/scripts/trajectory-inspector.sh` | Current session, lesson, and spec summaries are chronological and status-oriented, not relevance retrieval |
| `bubbles/scripts/codeindex-resolve.sh` and `bubbles/adapters/codeindex/none.sh` | Existing opt-in, provider-neutral, default-none adapter precedent |
| `bubbles/capability-ledger.yaml` `code-index-adapter` entry | Provider seams can remain partial until a real consumer exists and must report unsupported facts honestly |
| `bubbles/mcp/server.py` and `bubbles/mcp/tools/*.json` | MCP tools are thin bash twins and the current catalog contains no experience recall tool |
| `bubbles/tool-trust-registry.yaml` and `bubbles/action-risk-registry.yaml` | Read and mutation operations need explicit trust and risk classifications |
| `bubbles/scripts/framework-health-evidence-lint.sh` | G125 requires a status, source citations, and an index row |
| `bubbles/scripts/framework-dogfood-guard.sh` | G085 forbids a persistent `specs/` tree in the canonical source repository |
| Git object `e26fe15`, historical path `improvements/IMP-034-skill-evolution-loop-input-starvation.md` | IMP-034 SCOPE-4 described host session-store mining as optional and default-none rather than shipped behavior |

## Proposal

### Capability foundation

Create a provider-neutral capability named **Evidence-Backed Experience Recall**. The capability retrieves prior Bubbles experience without promoting it to current authority.

The foundation has these properties:

- `experienceRecall.adapter` is optional in project-owned Bubbles config.
- An absent block and `adapter: none` both resolve to the neutral provider.
- The foundation resolver and neutral provider add no external runtime dependency.
- The first real provider is local and deterministic.
- The local provider uses repository scripts and the Python standard library only. It adds no package, model, daemon, database, network, or hosted-service dependency.
- Search never reads a host transcript or editor conversation store.
- Search never sends corpus data outside the repository.
- Every search result remains advisory until the caller re-reads its current source anchor.

### Authority hierarchy

The implementation must enforce this closed authority order:

1. Current source and current-session executed evidence.
2. Active specs, scopes, scenarios, and state.
3. Reviewed lessons and approved skills.
4. Recalled experience.

A recall hit always starts at tier 4. A source anchor does not promote the hit. The caller must read and validate the source to use that source at its own tier.

Recall cannot:

- satisfy a DoD item or become execution evidence
- authorize a tool or weaken a tool-risk decision
- select, bind, or change a repository
- override current source, specs, scopes, scenarios, state, or owner decisions
- create or update a Skill
- dispatch an agent or alter workflow ownership

### Closed corpus

The primary corpus contains only these Bubbles-owned structured artifact families:

| Family | Admission rule | Source trust class |
|---|---|---|
| Compacted RESULT-ENVELOPE history | Admit a bound `compactedHistory[]` record only when its source anchor resolves and its evidence references retain their declared shape | `executed-result` or `historical-result` |
| Lessons | Admit only structured lesson entries with a stable id, repository scope, source anchor, capture time, and review state | `reviewed-lesson` or `anchored-lesson` |
| Owner decisions | Admit only known schema-backed approvals or accepted improvement decisions with a stable object key and source anchor | `owner-approved` |
| Findings and outcomes | Admit structured RESULT-ENVELOPE findings, addressed findings, unresolved findings, and outcomes with their source record and evidence references | `historical-finding` or `historical-outcome` |

Legacy lessons without valid source anchors remain valid skill-evolution input. They are ineligible for recall. Status output must report their exclusion count.

The corpus excludes raw host transcripts, chat logs, screenshots, terminal scrollback, arbitrary Markdown, source-code text, inferred preferences, and inferred personas.

### Record and query contract

Every admitted record must carry:

- a deterministic `recordId`
- a closed `kind`
- a bounded summary and searchable structured fields
- `repositoryAlias`, `specRef`, `scopeRef`, and scenario references when present
- a source anchor with repository-relative path, selector, content digest, and observed time
- a source trust class and the fixed `recallAuthority: advisory`
- freshness state and the source digest used to derive it
- lifecycle state and lifecycle timestamps
- provenance for the extractor and provider version

Lifecycle is a closed state machine:

`admitted -> superseded | expired | deleted`

An explicit operator action may admit a previously deleted anchor again. Search returns only `admitted` records by default. Read and status may expose other states for audit.

The lexical provider must apply repository, spec, kind, trust, lifecycle, and freshness filters before scoring. It then scores exact identifiers, exact phrases, field-weighted token overlap, and structured tags. It uses deterministic record-id ordering as the final tie break.

Search returns five results by default and rejects limits above twenty. Orchestrators may consume at most five hits and drill into at most two records per phase.

Search returns metadata and a bounded snippet. `read` validates the source digest before returning drill-down detail. A stale, missing, unknown, or out-of-root anchor produces a structured refusal rather than a result.

## Migration / rollout

1. Land SCOPE-1 with `adapter: none`. This changes no downstream behavior.
2. Land SCOPE-2 and keep `local-lexical` opt-in. Existing lessons remain valid for skill evolution. Unanchored legacy lessons remain outside recall.
3. Land SCOPE-3 for explicit operator use. Do not enable orchestrator consumption yet.
4. Land SCOPE-4 so lifecycle and deletion semantics exist before automation reads the index.
5. Land SCOPE-5 as read-only MCP parity over the CLI bash twins.
6. Land SCOPE-6 after evidence rejection and repository-isolation tests pass.
7. Land SCOPE-7 last. Run full framework validation and source release checks before the source push.
8. After the source commit is pushed, upgrade each downstream repository under its own actionable repository packet. Commit only the generated Bubbles upgrade changes in that repository.

The Bubbles source repository must not create `specs/` for this work. G085 source-repository evidence remains the IMP, focused selftests, framework validation, release checks, and release manifest.

## Scope deletion and execution rule

The accepted IMP is the live implementation queue.

- Keep a full SCOPE block in this file until that scope is implemented and validated.
- After a scope passes its focused validation, delete its full SCOPE block before committing that scope.
- Update the IMP-037 index row in the same change with the landed scope id and focused validation summary.
- Name the landed scope in the commit message. Git history carries the commit identity. Do not create a second bookkeeping commit.
- Leave every unvalidated scope unchanged in this file.
- Set the index row to `IN PROGRESS` after the first validated scope lands.
- After the final scope passes full framework validation and release checks, delete this proposal file. Keep the complete applied summary in `improvements/INDEX.md`.
- Commit each validated source scope separately. Push the Bubbles source only after the final source validation succeeds.
- Perform downstream upgrades only after the source push. Use a separate repository-bound invocation and commit for each downstream repository.

## Explicitly rejected designs

- **Raw host transcript or session-store mining:** rejected. It is outside the closed corpus and would revive the unshipped IMP-034 SCOPE-4 design.
- **Automatic conversation warehousing:** rejected. Bubbles stores only its owned structured artifacts.
- **Persona, preference, or operator-trait inference:** rejected. Recall retrieves records, not identities or behavioral profiles.
- **Recall as evidence or authority:** rejected. Recall remains tier 4 and advisory.
- **Automatic Skill creation or update:** rejected. `skill-evolution.sh` remains proposal-first and human-reviewed.
- **An embedding or semantic provider in IMP-037:** rejected from this accepted implementation. A later provider needs its own measured and owner-approved IMP.
- **Network search or hosted memory:** rejected. The accepted provider is local and deterministic.

## Risks & mitigations

- **R1 - false relevance changes a decision.** -> Return few results, expose lexical score components, require drill-down, and keep every hit advisory.
- **R2 - stale records look current.** -> Bind records to source digests. Refuse search on stale or unknown index state.
- **R3 - recall launders old output into evidence.** -> Reject recall ids and derived paths in evidence validation. Require callers to re-read the source anchor.
- **R4 - one repository recalls another repository's history.** -> Root every index to the active repository. Reject cross-root anchors before indexing and reading.
- **R5 - lessons leak secrets or unsupported claims.** -> Admit only structured, anchored fields. Never index raw transcripts or arbitrary text.
- **R6 - lifecycle delete removes authoritative history.** -> Delete only derived recall state. Preserve source artifacts and record recall-only tombstones.
- **R7 - lesson metadata breaks skill clustering.** -> Keep legacy lesson syntax valid. Test clustering against both legacy and anchored entries.
- **R8 - prompt context grows again.** -> Enforce five search hits, two drill-down reads, bounded snippets, and one consumption boundary per phase.
- **R9 - a new provider becomes a hidden dependency.** -> Keep the resolver and neutral provider dependency-free. Keep `local-lexical` opt-in and local.
- **R10 - scope deletion hides unfinished work.** -> Delete only validated scope blocks. Record each landed scope and its validation in the index row.

## Acceptance criteria (when implemented)

- The capability remains disabled when `experienceRecall` is absent or set to `none`.
- The local provider searches only the closed structured corpus and has no network path.
- Every result carries a valid source anchor, trust class, freshness state, lifecycle state, and advisory authority.
- Search order is deterministic and bounded. Read validates the source digest.
- CLI and MCP query surfaces share bash twins and return equivalent results.
- Orchestrator consumption cannot change repository binding, tool authority, DoD evidence, current source truth, or Skill state.
- Lifecycle operations preserve authoritative source artifacts and control recall-only state.
- Adversarial fixtures cover stale, deleted, cross-root, unanchored, transcript, authority, and prompt-injection failures.
- `bubbles/scripts/framework-health-evidence-lint.sh` reports no G125 findings while any IMP-037 scope remains.
- Full `framework-validate` and `release-check` run only after implementation reaches final source validation. They are not part of this planning invocation.

## Files to touch (owner-approved implementation)

Framework contract and runtime surfaces are owned by `bubbles.super`: `bubbles/schemas/experience-recall.schema.json`, `bubbles/adapters/experience-recall/`, `bubbles/scripts/experience-recall*`, `bubbles/scripts/cli.sh`, `bubbles/action-risk-registry.yaml`, `bubbles/tool-trust-registry.yaml`, `bubbles/capability-ledger.yaml`, and the four authorized orchestrator agents.

Evidence authority changes are reviewed by `bubbles.validate`: `bubbles/scripts/result-envelope-validate.sh` and its focused selftests.

Test and evaluation surfaces are owned by `bubbles.test`: focused `*selftest.sh` files and the labeled `bubbles/eval/` fixtures.

Managed documentation is owned by `bubbles.docs`: `docs/recipes/evidence-backed-experience-recall.md`, `docs/CATALOG.md`, `docs/guides/CONTROL_PLANE_SCHEMAS.md`, `docs/CHEATSHEET.md`, and `CHANGELOG.md`.

Packaging lands last through `bubbles/scripts/generate-release-manifest.sh`: `bubbles/release-manifest.json`. No implementation scope may create `specs/` in the source repository.
