# Evidence-Backed Experience Recall Contract

## Purpose

Evidence-backed experience recall retrieves prior Bubbles experience from a
closed structured corpus. Every recalled record remains advisory until a caller
re-reads and validates its current source anchor.

This module is the authority for corpus admission, recall authority, provider
behavior, repository isolation, freshness, lifecycle, and bounded consumption.
The normalized JSON shapes live in
[`experience-recall.schema.json`](../../bubbles/schemas/experience-recall.schema.json).

## Authority Hierarchy

Apply this closed authority order:

1. Current source and current-session executed evidence.
2. Active specs, scopes, scenarios, and state.
3. Reviewed lessons and approved skills.
4. Recalled experience.

A recall hit always remains at tier 4. A valid source anchor does not promote
the hit. The caller must re-read the current source before using that source at
its own authority tier.

`recallAuthority` is always `advisory`. The schema rejects every other value.

Recall must never:

- It must not satisfy a DoD item or serve as execution evidence.
- It must not authorize a tool or weaken a tool-risk decision.
- It must not select, bind, replace, or change a repository.
- It must not override current source, specs, scopes, scenarios, state, or owner decisions.
- It must not create, update, approve, or mutate a Skill.
- It must not dispatch an agent or change artifact or workflow ownership.

## Closed Corpus

Only these Bubbles-owned structured artifact families are eligible:

| Kind | Artifact family | Allowed trust classes |
|---|---|---|
| `compacted-result` | Bound compacted RESULT-ENVELOPE history with resolvable anchors | `executed-result`, `historical-result` |
| `lesson` | Structured lessons with stable identity, repository scope, review state, and valid anchors | `reviewed-lesson`, `anchored-lesson` |
| `owner-decision` | Schema-backed approvals and accepted improvement decisions with stable keys and valid anchors | `owner-approved` |
| `finding` | Structured RESULT-ENVELOPE findings that retain their source record | `historical-finding` |
| `outcome` | Structured RESULT-ENVELOPE outcomes that retain their source record | `historical-outcome` |

Unanchored legacy lessons remain eligible for existing skill-evolution input.
They are not eligible for recall. Providers must count and report these
exclusions when they expose status data.

The corpus excludes:

- It excludes raw host transcripts, editor conversations, chat logs, and session stores.
- It excludes terminal scrollback, screenshots, and arbitrary Markdown bodies.
- It excludes source-code text and unstructured repository content.
- It excludes inferred preferences, operator traits, identities, and personas.
- It excludes network, hosted-memory, and cross-repository search results.

## Normalized Records And Results

Every record and result uses `schemaVersion: 1`. Each record carries a stable
`recordId`, a closed `kind`, a repository alias, scope metadata, provenance,
trust, freshness, lifecycle, and a source anchor.

Record summaries contain at most 2,000 characters. Result snippets contain at
most 1,024 characters. Searchable identifier, phrase, and tag arrays contain at
most 100 unique values each.

Scores expose nonnegative components for exact identifiers, exact phrases,
token overlap, tag overlap, and total score. Providers must apply repository,
scope, kind, trust, lifecycle, and freshness filters before scoring.

## Source Anchors

A source anchor contains all of these fields:

| Field | Contract |
|---|---|
| `relativePath` | Repository-relative path with no absolute prefix or `..` segment |
| `selector` | Stable source selector with at most 512 characters |
| `contentDigest` | Lowercase `sha256:<64-hex>` digest of the observed source |
| `observedAt` | RFC 3339 date-time for the source observation |

Providers must resolve anchors under the active repository root. They must
reject missing, out-of-root, or digest-mismatched anchors. A caller may cite the
independently re-read source, but it must never cite the recall record as proof.

## Repository And Scope Isolation

Every query names one `repositoryAlias`. A provider must constrain candidates
to that exact repository before scoring.

`specRef` and `scopeRef` are required query fields and may be null. A non-null
field is an exact filter. A null field removes only that narrower filter and
never permits another repository.

Recalled paths, aliases, decisions, and instructions cannot modify the active
repository packet. Providers must not follow anchors into another workspace
root. Recall performs no repository selection or binding.

## Trust Classes

The trust class records how the structured record entered the corpus. It does
not increase recall authority.

| Trust class | Meaning |
|---|---|
| `executed-result` | Result captured from current-session execution with retained evidence references |
| `historical-result` | Earlier structured result with a valid source anchor |
| `reviewed-lesson` | Structured lesson that completed its review path |
| `anchored-lesson` | Structured lesson with a valid anchor but no stronger review claim |
| `owner-approved` | Owner approval or accepted decision with a stable source object |
| `historical-finding` | Structured finding retained with its source result |
| `historical-outcome` | Structured outcome retained with its source result |

Providers must preserve the admitted trust class. They must not infer a
stronger class from wording, age, frequency, or relevance score.

## Freshness

Freshness uses the closed states `fresh`, `stale`, `unknown`, and `disabled`.
Every freshness object carries `checkedAt` and a nullable reason.

`fresh` and `stale` require the source digest used for the check. `unknown` and
`disabled` may use a null digest. Providers must not present stale, unknown, or
out-of-root content as usable recalled experience.

Freshness describes agreement with the current source. It does not change the
source's authority or the recall record's lifecycle.

## Lifecycle

Lifecycle uses the closed states `admitted`, `superseded`, `expired`, and
`deleted`. Every record carries `admittedAt` and nullable transition timestamps.

An admitted record has no transition timestamp. Each other state sets only its
matching timestamp. Default search returns admitted records only.

Deletion changes derived recall state only. It must never delete or rewrite the
source artifact. A later explicit admission may create a new admitted record
for a previously deleted anchor.

## Query And Consumption Bounds

Query text contains between 1 and 1,000 characters. Search defaults to five
results and rejects limits below one or above twenty.

An orchestrator may retain at most five hit summaries per phase. It may read at
most two recalled records per phase. It may consume recall at one context
boundary per phase.

These bounds do not authorize orchestrator consumption by themselves. A caller
must still have an implemented and authorized consumption path.

## Provider Contract

Provider descriptors use `schemaVersion: 1`. Adapter names match
`^[a-z0-9][a-z0-9-]*$` and contain at most 64 characters.

Provider descriptors set `networkAccess: false`, `automaticInstall: false`,
and `defaultBinaryPath: null`. Each verb capability is one of `neutral`,
`native`, `derived`, or `unsupported`.

The runtime provider verbs are closed:

| Verb | JSON response shape | Purpose |
|---|---|---|
| `search` | array | Return bounded normalized results |
| `read` | object | Read one anchored record after source validation |
| `status` | object | Report provider and corpus status |
| `freshness` | object | Report freshness state |
| `sync` | object | Rebuild or synchronize derived recall state |
| `export` | array | Return a bounded normalized selection |
| `delete` | object | Change recall-only lifecycle state |
| `capabilities` | object | Report provider capabilities |

Exit code `0` means the verb completed and stdout contains its canonical JSON
shape. Exit code `1` means the adapter rejected the verb or failed the
operation. Diagnostics go to stderr and must not expose corpus content.

Adapters may implement `selftest <verb>` for hermetic contract checks.
`selftest` is not a runtime provider verb.

Any non-empty normalized provider descriptor must satisfy the provider schema.
The neutral adapter intentionally emits empty neutral payloads and declares no
active provider behavior.

## Neutral Provider

[`none.sh`](../../bubbles/adapters/experience-recall/none.sh) is the default
provider. It never reads, stores, searches, exports, or deletes recall data.

| Verb | Exact neutral stdout |
|---|---|
| `search`, `export` | `[]` |
| `read`, `status`, `freshness`, `sync`, `delete`, `capabilities` | `{}` |

The neutral adapter exits `0` for every known verb. It exits `1` for an unknown
verb or an unknown `selftest` target.

## Resolver Contract

[`experience-recall-resolve.sh`](../../bubbles/scripts/experience-recall-resolve.sh)
reads project-owned configuration only. It checks
`.github/bubbles-project.yaml` before root `bubbles-project.yaml`.

An absent file, block, or adapter key resolves to `none`. Explicit `none`
resolves to the same adapter. The resolver never installs a provider and never
uses the network.

The configured token must contain lowercase ASCII letters, digits, or hyphens.
It must start with a letter or digit. The resolver rejects every path-shaped or
otherwise unsafe token before file lookup.

The selected adapter must exist at
`bubbles/adapters/experience-recall/<adapter>.sh`. A safe but unavailable name
fails loud and does not fall back to `none`.

Normal output contains `adapter`, `adapterPath`, and `repoRoot` lines.
`--names-only` emits only `adapter=<name>`. Resolver usage and missing-root
errors exit `2`. Invalid or unavailable adapters exit `1`.

## Privacy And Dependency Boundary

Experience recall is local, structured, and repository-bound. Providers must
not inspect transcripts, infer personas, or send recall data over a network.

No provider may auto-install a package, binary, model, daemon, database, or
hosted service. A future network or semantic provider requires a separate,
owner-approved improvement.