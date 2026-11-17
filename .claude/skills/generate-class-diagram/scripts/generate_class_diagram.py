"""Generate docs/source/user/class-diagram.md from the Ops IngestLDD XML.

Usage: generate_class_diagram.py [--src IngestLDD.xml] [--dst class-diagram.md]

Defaults: the single src/*IngestLDD.xml of the repository, and
docs/source/user/class-diagram.md. Uses the Python standard library only.
"""
import argparse
import sys
import xml.etree.ElementTree as ET
from pathlib import Path

NS = {"p": "http://pds.nasa.gov/pds4/pds/v1"}

# .claude/skills/generate-class-diagram/scripts/<this file> -> repository root
REPO = Path(__file__).resolve().parents[4]

parser = argparse.ArgumentParser(description=__doc__.splitlines()[0])
parser.add_argument("--src", type=Path, help="IngestLDD XML (default: the one in src/)")
parser.add_argument("--dst", type=Path, default=REPO / "docs/source/user/class-diagram.md")
args = parser.parse_args()

if args.src:
    src = args.src
else:
    found = sorted((REPO / "src").glob("*IngestLDD.xml"))
    if len(found) != 1:
        sys.exit(f"expected exactly one src/*IngestLDD.xml, found {len(found)}")
    src = found[0]
dst = args.dst

TYPES = {
    "ASCII_Text_Preserved": "Text",
    "ASCII_Date_Time_YMD": "DateTime",
    "ASCII_Short_String_Collapsed": "ShortString",
    "ASCII_NonNegative_Integer": "Integer",
    "ASCII_MD5_Checksum": "MD5",
    "ASCII_AnyURI": "URI",
    "ASCII_Boolean": "Boolean",
    "ASCII_LID": "LID",
}


def text(el, path):
    return el.find(path, NS).text.strip()


def card(lo, hi):
    return "1" if (lo, hi) == ("1", "1") else f"{lo}..{hi}"


root = ET.parse(src).getroot()

attrs = {}
for a in root.findall("p:DD_Attribute", NS):
    dom = a.find("p:DD_Value_Domain", NS)
    values = [
        (text(v, "p:value"), text(v, "p:value_meaning"))
        for v in dom.findall("p:DD_Permissible_Value", NS)
    ]
    attrs[text(a, "p:local_identifier")] = {
        "type": "Enum" if values else TYPES.get(text(dom, "p:value_data_type")),
        "values": values,
        "definition": text(a, "p:definition"),
    }

classes = {}  # insertion order follows the XML
for c in root.findall("p:DD_Class", NS):
    name = text(c, "p:name")
    entry = {"attrs": [], "components": [], "parent": None, "element": text(c, "p:element_flag") == "true"}
    for assoc in c.findall("p:DD_Association", NS):
        ref = text(assoc, "p:identifier_reference")
        kind = text(assoc, "p:reference_type")
        mult = card(text(assoc, "p:minimum_occurrences"), text(assoc, "p:maximum_occurrences"))
        if kind == "attribute_of":
            entry["attrs"].append((ref, mult))
        elif kind == "component_of":
            entry["components"].append((ref, mult))
        elif kind == "parent_of":
            entry["parent"] = ref
        else:
            raise SystemExit(f"unhandled reference_type {kind} in {name}")
    classes[name] = entry

# --- relationships shared by both diagrams ---------------------------------
relations = []
for name, c in classes.items():
    for ref, mult in c["components"]:
        relations.append(f'    {name} "1" *-- "{mult}" {ref}')
for name, c in classes.items():
    if c["parent"]:
        relations.append(f"    {c['parent']} <|-- {name}")

# Classes drawn together in labelled packages, for readability.
GROUPS = {
    "File_Information": ["File_Info", "Label_File_Info", "Data_File_Info", "Access_Info"],
    "Validation": ["Validation_Assessment", "Validated_Against", "Validated_Against_Core", "Validated_Against_LDD"],
}
GROUPED = {n for members in GROUPS.values() for n in members}

# Fail loudly when the XML has drifted from this script, rather than emit a wrong page.
_unknown = sorted(n for n in GROUPED if n not in classes)
if _unknown:
    sys.exit(f"GROUPS refers to classes missing from the XML: {', '.join(_unknown)}. Update GROUPS.")
_untyped = sorted(
    ref for c in classes.values() for ref, _ in c["attrs"] if attrs[ref]["type"] is None
)
if _untyped:
    sys.exit(f"No diagram type for the data type of: {', '.join(_untyped)}. Extend TYPES.")


def class_block(name, c, indent, with_attrs):
    """Lines declaring one class; members only when requested and present."""
    body = []
    if c["element"]:
        body.append("<<element>>")
    if with_attrs:
        body += [f"+{attrs[ref]['type']} {ref} [{mult}]" for ref, mult in c["attrs"]]
    if not body:
        return [f"{indent}class {name}"]
    return [f"{indent}class {name} {{"] + [f"{indent}    {b}" for b in body] + [f"{indent}}}"]


def anchor(field):
    return f"controlled-values-{field.replace('_', '-')}"


def enum_fields(name):
    return [ref for ref, _ in classes[name]["attrs"] if attrs[ref]["values"]]


def enum_stub(field, indent):
    return [f"{indent}class {field}_values {{", f"{indent}    <<enumeration>>", f"{indent}}}"]


def build(with_attrs):
    lines = ["classDiagram", "    direction LR"]
    for name, c in classes.items():
        if name not in GROUPED and (c["element"] or with_attrs):
            lines += class_block(name, c, "    ", with_attrs)
            if with_attrs:
                for field in enum_fields(name):
                    lines += enum_stub(field, "    ")
    for group, members in GROUPS.items():
        lines.append(f"    namespace {group} {{")
        for name in members:
            lines += class_block(name, classes[name], "        ", with_attrs)
            if with_attrs:
                for field in enum_fields(name):
                    lines += enum_stub(field, "        ")
        lines.append("    }")
    lines += relations
    if with_attrs:
        for name in classes:
            for field in enum_fields(name):
                lines.append(f"    {name} ..> {field}_values : {field}")
        for name in classes:
            for field in enum_fields(name):
                lines.append(f'    click {field}_values href "#{anchor(field)}" "Controlled values of {field}"')
    return lines


structure = build(with_attrs=False)  # diagram 1: structure only
detail = build(with_attrs=True)  # diagram 2: attributes + structure

# --- controlled values: one section per field -------------------------------
sections = []
for field, info in attrs.items():
    if not info["values"]:
        continue
    owners = [n for n, c in classes.items() if any(r == field for r, _ in c["attrs"])]
    used_in = ", ".join(f"`{n}`" for n in owners)
    rows = "\n".join(f"| `{v}` | {m} |" for v, m in info["values"])
    sections.append(
        f"({anchor(field)})=\n### `{field}`\n\n{info['definition']}\n\n"
        f"Used in {used_in}.\n\n| Value | Meaning |\n| --- | --- |\n{rows}\n"
    )
n_values = sum(len(i["values"]) for i in attrs.values())


def block(lines):
    return "```{mermaid}\n" + "\n".join(lines) + "\n```"


page = f"""% Generated by .claude/skills/generate-class-diagram from {src.name}. Do not edit by hand.
# Class Diagram

Class diagrams for the Operations namespace (`ops`). They are derived from the Operations IngestLDD source, `src/PDS4_OPS_IngestLDD.xml`. The XML remains authoritative. Update these diagrams when the XML changes.

## Class structure

`ops:Operation_Metadata` is the global element. Every other class is a component of it, a component of another class, or a specialization.

- A filled diamond (composition) marks a component class. The label on the child end gives its occurrences within one instance of the parent.
- A hollow triangle (inheritance) marks a specialization. The specialized class adds no fields of its own.

{block(structure)}

## Classes and fields

Each field shows its type and occurrences: `[1]` is required, `[0..1]` is optional, and `[0..*]` is optional and repeatable. Fields appear in the order they must be written in XML. See {{ref}}`Conventions for field types` for the type definitions. `Enum` marks a field restricted to a list of controlled values. A dashed arrow labelled with the field name leads from its class to an `<<enumeration>>` node. Click the node to jump to the permitted values in {{ref}}`Controlled values`.

{block(detail)}

## Controlled values

Permitted values of each `Enum` field, in the order defined in the XML.

{chr(10).join(sections)}"""

with open(dst, "w") as f:
    f.write(page)
print(f"wrote {dst}: {len(classes)} classes, {len(sections)} controlled fields, {n_values} values")
