# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What This Repo Is

This is a **PDS4 Local Data Dictionary (LDD)** repository for the `ops` namespace — a governed PDS namespace for operational and supplemental metadata (harvest info, file access, processing provenance, lifecycle tracking, validation assessments) that is attached to products in the PDS registry but does not belong in archival PDS4 labels.

**Current status:** The repo is based on the `ldd-template` template. Active data model design work lives in `docs/sandbox/`. The `src/` IngestLDD file and most other content have not yet been updated from the template.

The primary artifact will be `src/PDS4_OPS_IngestLDD.xml` (or whatever file ending in `IngestLDD.xml` exists in `src/`). All files under `build/` and `logs/` are CI-generated and should not be edited by hand.

## Build Commands

### Build the LDD locally

Requires [LDDTool](https://nasa-pds.github.io/pds4-information-model/model-lddtool/index.html) installed on your system:

```bash
lddtool -lpsnJ src/PDS4_OPS_IngestLDD.xml
```

The `-lpsnJ` flags generate: label schema (XSD), Schematron (SCH), namespace-specific files, and JSON output.

The CI build matrix runs against PDS4 IM versions listed in `pds4_versions.txt` (currently `1.21.0.0`).

### Build the documentation

```bash
pip install -r docs/requirements.txt

cd docs
make clean html         # HTML output → docs/build/html/
open build/html/index.html
```

For PDF (requires LaTeX):
```bash
# macOS: brew install texlive
# Linux: apt-get install texlive-latex-recommended texlive-latex-extra texlive-fonts-recommended latexmk
cd docs
make latexpdf           # PDF → docs/build/latex/
```

## CI/CD Pipeline

Three GitHub Actions workflows drive automation:

| Workflow | Trigger | What it does |
|---|---|---|
| `ldd-ci.yml` | Push to any branch except `main`/`gh-pages` when `src/`, `.github/`, or `pds4_versions.txt` change | Runs LDDTool + Validate against each PDS4 version in `pds4_versions.txt`; commits generated LDDs to `build/development/<sha>/<version>/` and logs to `logs/` |
| `build-docs.yml` | Push to `main` when `docs/` or `src/` change | Builds Sphinx HTML → deploys to GitHub Pages (`gh-pages` branch); builds PDF and commits it back to `main` |
| `release-ldd.yml` | Push to `main` when `build/release/**` changes | Tags the release and publishes using `pds.ldd-manager` (`ldd-release` CLI) |

The bot committing these auto-generated files is `pdsen-ci`. All workflows skip when `github.actor == 'pdsen-ci'` to prevent infinite loops.

## Repository Layout

```
docs/sandbox/           # ACTIVE WORK — ops_model_example.txt is the current data model draft
  ops_model_example.txt   Current class/attribute design in pseudo-schema notation
  ops_model_example.xml   Older example instance (class names are superseded — ignore)
docs/design/            # OPS_LDD_ops_concept.md — concept, boundary rules, governance
docs/source/            # Sphinx source (not yet updated from ldd-template)
src/                    # Will hold the IngestLDD XML once modeling is complete (template placeholder now)
build/
  development/<sha>/    # Auto-generated LDDs per commit (XSD, SCH, JSON, CSV, TXT, XML)
  release/              # Promoted release artifacts
logs/                   # LDDTool and Validate execution logs from CI
test/                   # Regression test labels used by Validate during CI
pds4_versions.txt       # One PDS4 IM version per line; CI iterates over all of them
```

## Active Data Model Design

**The working model draft is `docs/sandbox/ops_model_example.txt`.** This is the authoritative current state of the class/attribute design. The `.xml` file in the same directory (`ops_model_example.xml`) is an older example instance that predates the current model — class names there (`Harvest_Record`, `Tracking_Meta`, `Harvest_Provenance`) are superseded.

The current model uses a single top-level class `ops:Operation_Metadata` with these child classes:

| Class | Purpose |
|---|---|
| `Stewardship_Info` | Organizations responsible for producing and stewarding a product |
| `File_Info` | Deployed file characteristics (label or data); replaces separate `Label_File_Info`/`Data_File_Info` via a `file_role` attribute |
| `Access_Info` | Operational access endpoints, nested inside `File_Info` |
| `Product_Ancestry` | Parent bundle/collection identifiers and registry membership completeness |
| `Version_Status` | Whether the product version is current, superseded, or withdrawn |
| `Processing_Provenance` | Harvest and registry operational provenance |
| `Systems_Lifecycle_Status` | EN operational workflow state (preparation/ingest/review/release × pending/in_progress/blocked/complete/failed) |
| `Archive_Lifecycle_Status` | Archival review and release state |
| `Validation_Assessment` | Validation tool results; references `Validated_Against` for IM version info |

See `docs/design/OPS_LDD_ops_concept.md` for boundary rules and governance recommendations before adding new classes or attributes.

## LDD Authoring Rules

- The `src/` directory must contain **exactly one** file whose name ends in `IngestLDD.xml` — the CI script uses that naming convention to locate the source.
- Do not edit files under `build/` or `logs/` — they are fully managed by CI.
- The `gh-pages` branch is auto-generated. **Never commit directly to `gh-pages`.**
- Test labels in `test/` must be valid PDS4 XML; they are run through the PDS Validate Tool during CI and failures block the build.
- When bumping the target PDS4 IM version, update `pds4_versions.txt`.

## Regression Testing

Add test labels (`.xml` files) to `test/`. CI runs `validate` against them automatically. File naming convention from the template repo: `test1_VALID.xml` for labels that must pass, `test1_FAIL.xml` for labels that must fail validation. The `test/No.Data` directory is used as a placeholder.

## Branching

- `main` — merge final, reviewed changes here; triggers doc deployment and (if `build/release/` changed) release tagging
- Feature/draft branches — LDD CI runs on every push here (except `gh-pages`)
- `ops-ldd-draft` — current active development branch
