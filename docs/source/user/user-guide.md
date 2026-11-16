# Operations Local Data Dictionary User Guide

Operations namespace (`ops`), version 1.0.0.0, for PDS4 Information Model 1.21.0.0.

## Purpose and audience

The Operations Local Data Dictionary defines supplemental metadata associated with PDS4 products. It supports registry, API, search, and delivery services. This guide is for PDS Engineering Node and Discipline Node staff and developers who produce, validate, or use operational metadata. Maintain Ops records in the operational workflow outside archival product labels.

## Dictionary identification

| Item | Value |
| --- | --- |
| Namespace URI | http://pds.nasa.gov/pds4/ops/v1 |
| Global element | ops:Operation_Metadata |
| Operations schema | PDS4_OPS_1L00_1000.xsd |
| PDS4 core dependency | PDS4_PDS_1L00.xsd • Information Model 1.21.0.0 |

## Using the Operations Namespace

Use `ops:Operation_Metadata` as the root of a standalone operational XML document. Declare the Ops namespace and pair its URI with the location of the matching XSD in `xsi:schemaLocation`. The example assumes the XSD is available next to the XML file under its canonical filename. Configure the validator to resolve the PDS4 core schema imported by the Ops XSD.

Write child elements in the order shown in each reference table. Occurrences apply within one instance of the parent class. A value of `1` means required, `0–1` means optional, and `0–*` means optional and repeatable. Include at least one child element in `ops:Operation_Metadata`, as required by the Ops Schematron.

### Top level class

| Child class | Occurs | Purpose |
| --- | --- | --- |
| `Stewardship_Info` | `0–1` | Product producers and stewards. |
| `Label_File_Info` | `0–1` | Operational details for the label file. |
| `Data_File_Info` | `0–*` | Operational details for each data file. |
| `Product_Ancestry` | `0–1` | Parent products and registry membership. |
| `Version_Status` | `0–1` | Superseded or withdrawn product versions. |
| `Processing_Provenance` | `0–1` | Harvest and registry processing details. |
| `Systems_Lifecycle_Status` | `0–*` | Phase and state of the Engineering Node workflow. |
| `Archive_Lifecycle_Status` | `0–*` | Archival review status, quality, and accumulating designation. |
| `Validation_Assessment` | `0–*` | Validation outcomes and dictionary versions used. |

### Validation rules

Validate the record with the matching Ops XSD and Schematron. The XSD checks structure, cardinality, and data types and imports the matching PDS4 core schema. The Ops Schematron checks the listed controlled values, requires the literal values `true` and `false` for the access flags, accumulating data flag, and action-required flag when present, and requires at least one child element in `ops:Operation_Metadata`.

## XML Examples

The first example records a data file and one access location. The URI is illustrative.

```xml
<?xml version="1.0" encoding="UTF-8"?>
<ops:Operation_Metadata
  xmlns:ops="http://pds.nasa.gov/pds4/ops/v1"
  xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
  xsi:schemaLocation="http://pds.nasa.gov/pds4/ops/v1
                      PDS4_OPS_1L00_1000.xsd">
  <ops:Data_File_Info>
    <ops:file_name>example.img</ops:file_name>
    <ops:file_role>data</ops:file_role>
    <ops:Access_Info>
      <ops:access_uri>https://example.org/data/example.img</ops:access_uri>
      <ops:access_available>true</ops:access_available>
      <ops:authorization_required>false</ops:authorization_required>
      <ops:access_method>https</ops:access_method>
      <ops:representation_role>primary</ops:representation_role>
      <ops:representation_profile>delivery</ops:representation_profile>
    </ops:Access_Info>
  </ops:Data_File_Info>
</ops:Operation_Metadata>
```

### Systems lifecycle status example

Add the `ops:Systems_Lifecycle_Status` element inside `ops:Operation_Metadata`, after `ops:Processing_Provenance` if present. The `available` phase paired with the `complete` state indicates that the product is publicly available online.

```xml
<ops:Systems_Lifecycle_Status>
  <ops:systems_lifecycle_phase>available</ops:systems_lifecycle_phase>
  <ops:systems_lifecycle_state>complete</ops:systems_lifecycle_state>
</ops:Systems_Lifecycle_Status>
```

## Stewardship and File Metadata

### Stewardship Info

Use `Stewardship_Info` to record the product producer and the organizations responsible for curation or long-term management.

| Element | Occurs | Type | Definition |
| --- | --- | --- | --- |
| `producer` | `0–*` | Short string | The organization or entity that produced the product. |
| `steward_organization` | `0–*` | Short string | The top-level organization responsible for stewardship, curation, or long-term management. |
| `steward_sub_organization` | `0–*` | Short string | The organizational unit within the steward organization responsible for stewardship, curation, or long-term management. |
| `comment` | `0–1` | Text | Remarks about the enclosing metadata class. |

### File Info and its specializations

`Label_File_Info` and `Data_File_Info` specialize `File_Info` and share the sequence below. Use `file_role` label in `Label_File_Info` and `file_role` data in `Data_File_Info`. Each instance describes one file. Repeat `Data_File_Info` across data files.

| Element | Occurs | Type | Definition |
| --- | --- | --- | --- |
| `creation_date_time` | `0–1` | Date and time | The date and time at which the described label or data file was created. |
| `file_name` | `1` | Short string | The name of the described label or data file. |
| `file_role` | `1` | Short string | Identifies the file as label or data. Values: data, label. |
| `file_size` | `0–1` | Integer + unit | Size of the described file. Use an integer from 0 through 18446744073709551615 and supply the required unit attribute from pds:Units_of_Storage. |
| `md5_checksum` | `0–1` | MD5 | The 32-character hexadecimal MD5 checksum computed over the complete byte content of the described file. |
| `mime_type` | `0–1` | Short string | The media type of the described file, expressed as a type and subtype, such as application/xml or image/jpeg. |
| `Access_Info` | `0–*` | Class | The class Access_Info describes a URI and its access characteristics for a file. Each instance represents one URI at which the file can be accessed. |

Ops field names are namespace-qualified. The unit on `ops:file_size` is an unprefixed XML attribute.

## File Access and Product Ancestry

### Access Info

Use one `Access_Info` within the associated file class for each access URI.

| Element | Occurs | Type | Definition |
| --- | --- | --- | --- |
| `access_uri` | `1` | URI | URI where the file representation can be accessed. |
| `access_available` | `0–1` | Boolean | Indicates whether the resource at this URI is currently available. |
| `authorization_required` | `0–1` | Boolean | Indicates whether authorization is required to access the resource at this URI. |
| `access_method` | `0–1` | Short string | Protocol or access mechanism for the URI. Internal identifies an operational location. Values: https, internal, native, s3. |
| `representation_role` | `0–1` | Short string | Role of this representation in relation to the product. Values: alternate, browse, primary. |
| `representation_profile` | `0–1` | Short string | Deployment purpose or optimization of this representation. Values: cloud-native, delivery, preservation. |
| `compression_algorithm` | `0–1` | Short string | The compression algorithm applied to the file representation available at access_uri, such as gzip or zip. |
| `comment` | `0–1` | Text | Remarks about the enclosing metadata class. |

### Product Ancestry

Use parent bundle and collection LIDs for containment or aggregation.

| Element | Occurs | Type | Definition |
| --- | --- | --- | --- |
| `parent_bundle_identifier` | `0–1` | LID | The logical identifier of the parent bundle that contains or aggregates the product. |
| `parent_collection_identifier` | `0–1` | LID | The logical identifier of the parent collection that contains or aggregates the product. |
| `registry_membership_complete` | `0–1` | Boolean | True when all expected members are present in the registry. False when one or more are missing or unlinked. |
| `registry_membership_evaluation_date_time` | `0–1` | Date and time | When registry membership completeness was last evaluated. |
| `comment` | `0–1` | Text | Remarks about the enclosing metadata class. |

## Processing Provenance and Version Status

### Processing Provenance

Use this class for Engineering Node harvest and registry provenance. Record source products here and parent bundle or collection membership in `Product_Ancestry`.

| Element | Occurs | Type | Definition |
| --- | --- | --- | --- |
| `harvest_id` | `0–1` | Short string | Identifier of the harvest activity. |
| `harvest_date_time` | `0–1` | Date and time | When the product was harvested. |
| `harvest_version` | `0–1` | Short string | Version of the harvesting software. |
| `harvest_source` | `0–1` | Short string | Source from which the product was harvested, such as the supplying node. |
| `harvest_job_identifier` | `0–1` | Short string | Identifier of the harvest job that processed the product. |
| `harvest_profile_identifier` | `0–1` | Short string | Identifier of the harvest configuration profile used. |
| `registry_id` | `0–1` | URI | URI identifying the registry record. |
| `registry_version` | `0–1` | Short string | Version of the registry record. |
| `registry_sweepers_ancestry_version` | `0–1` | Short string | Version of the Registry Sweepers ancestry process applied. |
| `registry_sweepers_repairkit_version` | `0–1` | Short string | Version of the Registry Sweepers repair kit applied. |
| `derived_from_identifier` | `0–*` | Short string | Identifier of an input product. For external inputs, follow the conventions of PDS Source_Product_External. |
| `comment` | `0–1` | Text | Remarks about the enclosing metadata class. |

### Version Status

Use this class for superseded or withdrawn versions. Omit it for current versions.

| Element | Occurs | Type | Definition |
| --- | --- | --- | --- |
| `version_status` | `1` | Short string | Operational standing of a superseded or withdrawn product version. Values: superseded, withdrawn. |
| `version_status_date_time` | `0–1` | Date and time | The date and time at which the version status was assigned or last updated. |
| `comment` | `0–1` | Text | Remarks about the enclosing metadata class. |

## Systems and Archive Lifecycle

### Systems Lifecycle Status

The phase identifies where the product is in the Engineering Node workflow. The state records progress within that phase. For public online availability, the schema describes the combination available and complete.

| Element | Occurs | Type | Definition |
| --- | --- | --- | --- |
| `systems_lifecycle_phase` | `1` | Short string | Phase of the Engineering Node workflow to which the state applies. Values: available, ingest, offline, preparation, review, staging. |
| `systems_lifecycle_state` | `1` | Short string | State of activity within the accompanying phase. Values: blocked, complete, failed, in_progress, pending. |
| `status_date_time` | `0–1` | Date and time | The date and time at which the accompanying systems lifecycle phase and state were assigned or last updated. |
| `status_message` | `0–1` | Text | Notes on progress, issues, dependencies, or the reason for the assigned phase and state. |

### Archive Lifecycle Status

Use this class to record archival evaluation, quality, release, and accumulating designation for a product, collection, or bundle. The optional timestamp records when archive status was assigned or updated.

| Element | Occurs | Type | Definition |
| --- | --- | --- | --- |
| `archive_lifecycle_state` | `1` | Short string | Stage in the PDS archival review and release process. Values: in_internal_review, in_lien_resolution, in_peer_review, not_reviewed, rejected, released. |
| `archive_quality` | `0–1` | Short string | Assessment against PDS archive quality requirements. External applies to products intended for availability outside the formal archive. Values: external, needs_improvement, satisfactory, undetermined. |
| `accumulating_data_flag` | `0–1` | Boolean | True while incremental delivery is underway by agreement with the PDS node. False after the final increment has been ingested. Omit when the product has no accumulating designation. |
| `archive_status_date_time` | `0–1` | Date and time | The date and time at which the archive status was assigned or updated. |
| `archive_status_message` | `0–1` | Text | Free-text notes about archive status. |

## Validation Assessments

### Validation Assessment

Use one assessment for each validation result you need to report. Include one `Validated_Against_Core` for every assessment.

| Element | Occurs | Type | Definition |
| --- | --- | --- | --- |
| `validation_state` | `0–1` | Short string | Outcome or availability of the validation assessment. Values: failed, not_tested, passed, passed_with_warnings, unknown. |
| `validator_name` | `0–1` | Short string | The name of the validation tool, service, or application used to perform the validation assessment. |
| `validator_version` | `0–1` | Short string | The version of the validation tool, service, or application used to perform the validation assessment. |
| `validation_date_time` | `0–1` | Date and time | The date and time at which the validation assessment was performed. |
| `validation_message_text` | `0–*` | Text | A human-readable description of a validation result, warning, or error generated during validation. |
| `action_required` | `0–1` | Boolean | Indicates whether the validation assessment identified issues requiring corrective action. |
| `Validated_Against_Core` | `1` | Class | Core namespace and information model version used during the assessment. |
| `Validated_Against_LDD` | `0–*` | Class | Namespace and version of a local data dictionary used during the assessment. |

### Validated Against class and specializations

`Validated_Against_Core` and `Validated_Against_LDD` share these fields. Use pds for the core namespace and the relevant namespace abbreviation for each LDD.

| Element | Occurs | Type | Definition |
| --- | --- | --- | --- |
| `namespace_id` | `1` | Short string | The abbreviation identifying the PDS4 namespace used in the validation assessment, such as pds or ops. |
| `pds4_version_id` | `1` | Short string | The PDS4 version identifier associated with the namespace. |

### Conventions for field types

Short strings collapse XML whitespace and have a length of 1–255 characters. Status and validation message fields preserve whitespace and have a length of 1–255 characters. The comment field preserves whitespace and has a local minimum of one character. Date and time fields use the PDS4 year-month-day type. LID means PDS4 logical identifier.

