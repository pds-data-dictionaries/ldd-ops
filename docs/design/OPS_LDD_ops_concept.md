# PDS `ops` Local Data Dictionary (LDD)
## Concept and Design Proposal

### Status
Draft for information architecture and data model design

### Purpose
This document proposes the concept, scope, structure, and initial content for a PDS4 `ops` Local Data Dictionary (LDD). The intent is to define a governed, extensible place for operational, supplemental, and usability-oriented metadata that should be returned by PDS registry and API services but does not belong in archival PDS4 product labels.

---

## 1. Problem Statement

PDS4 archival labels are designed to describe the archival product itself and the scientific/archive metadata required for long-term preservation and interpretation. They are intentionally not the place for environment-specific, deployment-specific, processing-state, or service-specific metadata that may change over time.

However, PDS operational systems need additional metadata in order to:

- locate files and products in deployed environments
- track harvest, ingest, validation, release, and repair history
- support registry operations, search, delivery, and metrics
- expose alternate access paths such as HTTP and cloud URIs
- support user navigation and usability across heterogeneous mission metadata
- expose quality/validity information that helps users and client developers interpret returned results

Examples already identified include:
- `ops:...ops:file_ref` for online path resolution
- checksums, MIME type, file size, compression metadata
- harvest metadata such as node, time, and processing provenance
- archive processing / publication state
- validation status and associated user-visible messages
- aliasing or normalization support for client-facing search and navigation

This proposal is intended to give the information architect a concrete concept and design baseline for building the data model.

---

## 2. Core Recommendation

### Recommendation
Create **one `ops` LDD** as the canonical namespace for **PDS operational and supplemental metadata**, but design it as a **modular, internally partitioned model** with clear governance boundaries.

### Why this is the right split
Use one LDD because:

1. **The metadata is cross-cutting**
   These fields are not just “registry metadata” or “search metadata.” Many of them support multiple system functions at once: harvest, registry, API, search, access, cloud, validation, analytics, and future tooling.

2. **The consumer should not care which subsystem produced it**
   A client should not need to know whether a field came from registry loading, a sweeper, validation, search normalization, or a cloud pipeline. If the meaning is operational/supplemental metadata about the product, it belongs in one operational namespace.

3. **Avoid namespace sprawl and semantic duplication**
   Separate namespaces such as `registry`, `search`, `validation`, `atlas`, etc. would likely create overlapping concepts:
   - multiple location fields
   - multiple status fields
   - multiple quality flags
   - multiple alias/normalization constructs

4. **Operational metadata will evolve together**
   The issue and registry materials already frame supplemental metadata as part of the broader registry/API foundation for tracking, auditing, locating, and usability. A unified namespace aligns better with that architectural role.

5. **Governance is simpler**
   One LDD with sections/modules is easier to review, version, document, and explain than several small LDDs with fuzzy boundaries.

### Important caveat
This should be **one LDD, not one undifferentiated bucket**. The model should be structured so that different categories of metadata are clearly separated and future additions do not turn `ops` into a junk drawer.

---

## 3. Design Principle

The `ops` LDD should contain metadata that is:

- **non-archival**
- **environment-dependent, process-dependent, or service-dependent**
- **helpful for system operation, delivery, discovery, navigation, or quality signaling**
- **safe to evolve without changing the archival meaning of the underlying PDS4 product**

The `ops` LDD should **not** contain:

- mission/science semantics that belong in the Common dictionary or discipline LDDs
- long-term preservation metadata that belongs in the archival label itself
- ad hoc application internals with no reusable semantic meaning
- fields whose meaning is only “for one implementation detail” and not stable enough to govern

---

## 4. Proposed Conceptual Scope

The `ops` LDD should be the home for five major categories of metadata.

### 4.1 Access and Location Metadata
Metadata describing where or how the product or associated files can be accessed in current operational environments.

Examples:
- HTTP URL
- S3 URI
- alternate URLs
- compressed representation URL
- cloud-local path or URI
- access-availability flag
- exposure/authorization characteristics

### 4.2 File Technical Metadata
Operationally useful file-level technical details that may be harvested or computed.

Examples:
- file name
- file size
- checksum(s)
- MIME type
- compression algorithm
- creation/modification timestamps
- data/label file info containers

### 4.3 Processing and Provenance Metadata
Metadata capturing how the operational system encountered, loaded, transformed, repaired, or related the product.

Examples:
- harvest timestamp
- node/source system
- registry loader version
- sweeper version
- repair toolkit version
- parent/child identifiers computed during ingest
- derived relationship provenance

### 4.4 Lifecycle / Tracking Metadata
Metadata describing the product’s current operational state in the archive workflow.

Examples:
- submission status
- review status
- staged / archived / released state
- embargo/publication state
- synchronization state across services
- delivery readiness or cloud migration status

### 4.5 Quality / Validation / Usability Metadata
Metadata that helps systems and users judge confidence, validity, and usability of a record or file.

Examples:
- validation status
- severity
- user-visible message
- warning/error presence
- quality annotations
- normalization/alias metadata for unified search or usability

---

## 5. Proposed Structural Approach

## 5.1 Namespace
Use a single namespace:
- `ops`

## 5.2 Top-level organizing class
Use a single top-level container class such as:
- `ops:Operation_Metadata`

This aligns well with the spreadsheet’s current direction and gives a single predictable anchor for supplemental metadata.

## 5.3 Internal modular sections
Under `ops:Operation_Metadata`, organize the model into modular classes rather than subsystem-specific namespaces.

Suggested modules:

- `ops:Label_File_Info`
- `ops:Data_File_Info`
- `ops:Access_Info`
- `ops:Harvest_Info`
- `ops:Processing_Provenance`
- `ops:Lifecycle_Status`
- `ops:Validation_Assessment`
- `ops:Search_Augmentation`

These names are intentionally semantically oriented, not implementation oriented.

---

## 6. Recommended Initial Model

## 6.1 File and access metadata
These appear mature enough to include now based on the spreadsheet.

### `ops:Label_File_Info`
Purpose: describe the deployed/operational characteristics of the label file.

Candidate attributes:
- `ops:file_name`
- `ops:file_ref`
- `ops:file_size`
- `ops:creation_date_time`
- `ops:md5_checksum`
- `ops:mime_type`
- `ops:compression_algorithm`
- `ops:file_ref_available`

### `ops:Data_File_Info`
Purpose: describe the deployed/operational characteristics of a referenced data file.

Candidate attributes:
- `ops:file_name`
- `ops:file_ref`
- `ops:file_size`
- `ops:creation_date_time`
- `ops:md5_checksum`
- `ops:mime_type`
- `ops:compression_algorithm`
- `ops:file_ref_available`

### Notes
- `Label_File_Info` and `Data_File_Info` are good separate classes because their roles are distinct and they may differ in cardinality.
- Consider defining a shared abstract reusable component if the IM tooling makes that worthwhile, but keep the published semantics easy to read.

## 6.2 Harvest and processing provenance
These also appear mature enough to include now.

### `ops:Harvest_Info`
Purpose: capture metadata about the harvest/load event that produced or refreshed the operational metadata.

Candidate attributes:
- `ops:node_name`
- `ops:harvest_date_time`
- `ops:harvest_source`
- `ops:harvest_job_identifier`
- `ops:harvest_profile_identifier`

### `ops:Processing_Provenance`
Purpose: capture operational provenance for enrichment and relationship computation.

Candidate attributes:
- `ops:registry_version`
- `ops:registry_app_version`
- `ops:registry_sweeper_version`
- `ops:repairkit_version`
- `ops:ancestry_version`
- `ops:parent_collection_identifier`
- `ops:parent_bundle_identifier`
- `ops:derived_from_identifier`
- `ops:provenance_note`

### Notes
Avoid encoding tool names too deeply into field names where possible. Prefer stable semantic names over today’s implementation names. For example:
- better: `ops:relationship_derivation_version`
- worse: `ops:registry_sweepers_ancestry_version`

You can preserve source implementation details in descriptions or controlled values if needed.

## 6.3 Access alternatives
The `file_refs` sheet suggests multiple path families and exposure rules.

### `ops:Access_Info`
Purpose: model one or more access endpoints for the product or associated file.

Candidate attributes:
- `ops:access_url`
- `ops:access_uri`
- `ops:access_method`
- `ops:access_representation_type`
- `ops:is_primary_access_path`
- `ops:is_user_visible`
- `ops:authorization_required`
- `ops:availability_status`

Candidate controlled values:
- access method: `http`, `https`, `s3`, `native`, `internal`
- representation type: `primary`, `compressed`, `cloud-native`, `download`, `browse`, `alternate`

### Notes
This is better than overloading every path concept into `file_ref`.
Use `file_ref` only where you truly mean “the resolved deployed location of this file.”
Use `Access_Info[]` when you need multiple routable/downloadable/access endpoints.

---

## 7. Recommended “Phase 2” Model Areas

These concepts make sense, but the names and semantics need tightening before they are modeled.

## 7.1 Lifecycle / tracking
The idea behind `Tracking_Meta` is strong, but the name is weak.

### Recommended rename
Use:
- `ops:Lifecycle_Status`
or
- `ops:Operational_Lifecycle`

This better describes what the metadata means.

### Candidate attributes
- `ops:archive_status`
- `ops:review_status`
- `ops:release_status`
- `ops:publication_status`
- `ops:embargo_status`
- `ops:migration_status`
- `ops:last_status_update_date_time`
- `ops:status_message`

### Candidate controlled values
Keep these orthogonal where possible. Do not collapse everything into one overloaded status field.

Example:
- archive status: `staged`, `submitted`, `archived`, `superseded`
- release status: `internal`, `embargoed`, `public`
- migration status: `not_applicable`, `planned`, `in_progress`, `complete`

## 7.2 Validation / quality signaling
The idea behind `Validation_Status` is also strong, but it should be modeled more explicitly.

### Recommended rename
Use:
- `ops:Validation_Assessment`
or
- `ops:Quality_Assessment`

`Validation_Assessment` is better if it is specifically tied to validation outcomes.
`Quality_Assessment` is broader if you want to include non-validator signals later.

### Candidate attributes
- `ops:validation_state`
- `ops:validation_severity`
- `ops:validator_name`
- `ops:validator_version`
- `ops:validation_date_time`
- `ops:message_code`
- `ops:message_text`
- `ops:is_user_actionable`

### Notes
This should support both:
- coarse status for faceting/filtering
- detailed user-visible explanation

You may eventually want a repeatable message class such as `ops:Validation_Message[]`.

## 7.3 Search and usability augmentation
This area is real, but it is the easiest place for the LDD to become too implementation-specific.

### Recommended rename
Use:
- `ops:Search_Augmentation`
or
- `ops:Discovery_Augmentation`

### Intended purpose
Provide client- and user-facing normalization metadata that improves cross-archive usability without changing archival semantics.

Examples:
- normalized mission phase
- canonical field alias group
- precomputed search rollups
- display labels
- synonym groups
- browse-friendly composite fields

### Important constraint
Do **not** model implementation artifacts from a search engine directly.
Model the **semantic augmentation**, not the current index trick.

For example:
- good: `ops:normalized_phase_name`
- bad: `ops:facet_rollup_field_17`

---

## 8. Boundary Rules

These rules are critical.

### Rule 1: organize by meaning, not by producer
Do not create classes like:
- `Registry_Metadata`
- `API_Metadata`
- `Atlas_Metadata`

unless the semantics are truly unique and stable. Prefer:
- `Access_Info`
- `Lifecycle_Status`
- `Validation_Assessment`

### Rule 2: one fact, one concept, one place
Do not define:
- one “status” for archive lifecycle
- another “status” for publication
- another “status” for validity
all as vague strings.
Separate them.

### Rule 3: distinguish intrinsic vs environment-specific
If the metadata would remain true regardless of where/how the product is deployed, it probably belongs in archival metadata.
If it changes with deployment, harvesting, system state, or service configuration, it likely belongs in `ops`.

### Rule 4: separate user-visible access from internal-only paths
Native filesystem paths and internal-only URIs should not be modeled the same way as public URLs.
The model should allow both, but their exposure characteristics must be explicit.

### Rule 5: support repeatable access and messages
Many products will have:
- multiple access URLs
- multiple file representations
- multiple validation messages

Use repeatable classes where multiplicity is expected.

---

## 9. Proposed Initial Deliverable Scope

## Phase 1: include now
These seem concrete enough to model immediately:

1. `ops:Operation_Metadata`
2. `ops:Label_File_Info`
3. `ops:Data_File_Info`
4. `ops:Harvest_Info`
5. `ops:Processing_Provenance`
6. `ops:Access_Info` (initial/basic form)
7. initial controlled values for access method, availability, and a few lifecycle states if needed

## Phase 2: define next
These need concept and naming refinement before full modeling:

1. `ops:Lifecycle_Status`
2. `ops:Validation_Assessment`
3. `ops:Search_Augmentation`

## Phase 3: future extensions
Possible future extension areas:
- tool-specific augmentation classes where semantics are durable
- cloud residency / storage tier metadata
- synchronization metadata across registry/API/indexes
- user experience/display metadata
- policy/security annotations

---

## 10. Example of how to think about field placement

### Good `ops` metadata
- “What is the current public URL for this label?”
- “What S3 URI is available for in-region cloud analysis?”
- “When was this file harvested?”
- “What validator warning should the user see?”
- “What is the current release state?”
- “What normalized field should clients use to search mission phase across missions?”

### Not good `ops` metadata
- “What instrument acquired this observation?”
- “What target is being observed?”
- “What is the scientific processing level?”
- “What is the mission-specific semantic meaning of phase X?”
These belong in archival/common/discipline semantics, not `ops`.

---

## 11. Governance Recommendations

To keep `ops` healthy over time:

### 11.1 Establish acceptance criteria for new `ops` fields
A new field should answer:
- Is the concept non-archival?
- Is it stable enough to govern?
- Is it reusable across more than one tool/service or likely to become so?
- Is it semantically meaningful to downstream clients or operators?
- Can it be described without tying it to a temporary implementation detail?

### 11.2 Require proposed additions to declare:
- purpose
- producer
- consumer(s)
- cardinality
- expected volatility
- whether it is user-visible
- whether it is safe for public API exposure
- whether it is environment-specific or portable

### 11.3 Separate public API exposure from data model inclusion
Not everything in `ops` must be returned by every API response by default.
The LDD defines semantics; API profiles define exposure.

---

## 12. Open Design Questions for the Information Architect

1. Should `Operation_Metadata` be attached at product level only, or also support nested file-level repeating objects cleanly?
2. Should `file_ref` be a simple string, or should access endpoints be normalized through `Access_Info[]` as the preferred long-term pattern?
3. How much tool provenance should be encoded in field names vs values/descriptions?
4. Do validation results need both summary and repeatable detailed message structures in the initial release?
5. For normalized search/usability fields, should the model represent:
   - canonical semantic groups, or
   - precomputed convenience fields, or
   - both?
6. Which `ops` classes are intended for public API output versus internal registry-only use?
7. How should internal-only paths be represented so they are useful operationally without implying public exposure?

---

## 13. Specific Recommendation on Your Main Question

### Final answer
Do **not** split this into separate LDDs like `ops`, `search`, `registry`, `atlas`, etc. right now.

Instead:
- create **one `ops` LDD**
- make it the home for **operational/supplemental metadata**
- partition it internally into **clear semantic modules**
- keep future tool-specific additions inside `ops` unless they become broad, durable concepts that truly merit their own namespace later

### Exception case
A separate LDD would make sense later only if a future metadata family:
- becomes broadly reusable beyond operations,
- develops its own substantial conceptual model,
- has a distinct governance path,
- and is no longer primarily “operational supplemental metadata.”

That does **not** appear to be the case for the current scope.

---

## 14. Proposed Immediate Next Steps

1. Confirm the top-level naming:
   - `ops:Operation_Metadata`
2. Confirm the phase-1 classes:
   - `Label_File_Info`
   - `Data_File_Info`
   - `Harvest_Info`
   - `Processing_Provenance`
   - `Access_Info`
3. Rename:
   - `Tracking_Meta` → `Lifecycle_Status`
   - `Validation_Status` → `Validation_Assessment`
4. Identify which candidate fields are:
   - public API
   - internal registry only
   - future / not yet modeled
5. Draft controlled vocabularies for:
   - access method
   - availability
   - lifecycle states
   - validation state/severity
6. Build the formal data model from this concept baseline

---

## 15. Short answer for leadership use

We should define a single `ops` LDD for operational and supplemental PDS metadata, not multiple smaller LDDs by subsystem. The metadata under discussion is cross-cutting and serves registry, API, search, access, validation, and future cloud/tooling use cases simultaneously. Splitting it by implementation area would create duplicate concepts and confuse clients. The right approach is one governed `ops` namespace with internally modular classes for access/location, file technical metadata, processing provenance, lifecycle tracking, validation/quality, and search/usability augmentation.
