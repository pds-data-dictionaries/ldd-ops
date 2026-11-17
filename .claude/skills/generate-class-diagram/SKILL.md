---
name: generate-class-diagram
description: Regenerate the Sphinx "Class Diagram" page (docs/source/user/class-diagram.md) from src/PDS4_OPS_IngestLDD.xml. Use whenever the IngestLDD XML changes (classes, attributes, cardinalities, permissible values) so the Mermaid class diagrams and controlled-values sections stay in sync.
---

# Generate the class diagram page

`docs/source/user/class-diagram.md` is a **generated file**. Never edit it by hand: the next run overwrites it. Change the XML, or the generator, and regenerate.

## Steps

1. Run the generator from the repository root. It needs only Python 3 and reads the single `src/*IngestLDD.xml`:

   ```bash
   python3 -I .claude/skills/generate-class-diagram/scripts/generate_class_diagram.py
   ```

   Optional: `--src <IngestLDD.xml>` and `--dst <page.md>` override the defaults.

2. Review `git diff docs/source/user/class-diagram.md`. Every change must trace back to a change in the XML. If a diff line has no matching XML change, the generator is at fault: fix the script, not the page.

3. If the script exits with an error, fix the cause and rerun. Do not hand-patch the output:
   - `GROUPS refers to classes missing from the XML`: a class was renamed or removed. Update `GROUPS` in the script.
   - `No diagram type for the data type of ...`: the XML uses a new `value_data_type`. Add it to `TYPES` in the script.

4. Build the docs and check the page renders, when Sphinx is installed (`pip install -r docs/requirements.txt`):

   ```bash
   cd docs && make clean html && open build/html/user/class-diagram.html
   ```

   Look at both diagrams and click an `<<enumeration>>` node to confirm it jumps to its section.

## What the generator produces

- **Class structure**: classes only, with composition (`component_of`) and inheritance (`parent_of`) links and their occurrences.
- **Classes and fields**: every field with its type and `[min..max]` occurrences, in XML order. A field with permissible values is typed `Enum`, with a dashed arrow to a clickable `<<enumeration>>` node that links to its section.
- **Controlled values**: one section per `Enum` field, with its definition, the classes using it, and a Value/Meaning table.

## Adjusting the layout

Constants at the top of the script control the layout. They are the only things to edit for presentation changes:

- `GROUPS`: Mermaid packages (`namespace` blocks) that draw related classes together. Classes not listed stay outside any package. A new class needs no change here unless you want it grouped.
- `TYPES`: maps PDS4 `value_data_type` names to the short type names shown in the diagram.

## Dependencies on the Sphinx setup

The page relies on `sphinxcontrib.mermaid` (registered in `docs/source/conf.py`, pinned in `docs/requirements.txt`) and on a Mermaid version that supports `namespace` blocks (`mermaid_version` in `conf.py`). Click links on enumeration nodes only work when Mermaid runs with `securityLevel: 'loose'`; check `conf.py` before concluding the links are broken.
