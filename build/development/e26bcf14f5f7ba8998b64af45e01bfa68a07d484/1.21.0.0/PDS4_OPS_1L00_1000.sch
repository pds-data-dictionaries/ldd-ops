<?xml version="1.0" encoding="UTF-8"?>
  <!-- PDS4 Schematron for Name Space Id:ops  Version:1.0.0.0 - Mon Sep 28 20:11:20 UTC 2026 -->
  <!-- Generated from the PDS4 Information Model Version 1.21.0.0 - System Build 14.0 -->
  <!-- *** This PDS4 schematron file is an operational deliverable. *** -->
<sch:schema xmlns:sch="http://purl.oclc.org/dsdl/schematron" queryBinding="xslt2">

  <sch:title>Schematron using XPath 2.0</sch:title>

  <sch:ns uri="http://www.w3.org/2001/XMLSchema-instance" prefix="xsi"/>
  <sch:ns uri="http://pds.nasa.gov/pds4/pds/v1" prefix="pds"/>
  <sch:ns uri="http://pds.nasa.gov/pds4/ops/v1" prefix="ops"/>

		   <!-- ================================================ -->
		   <!-- NOTE:  There are two types of schematron rules.  -->
		   <!--        One type includes rules written for       -->
		   <!--        specific situations. The other type are   -->
		   <!--        generated to validate enumerated value    -->
		   <!--        lists. These two types of rules have been -->
		   <!--        merged together in the rules below.       -->
		   <!-- ================================================ -->
  <sch:pattern>
    <sch:rule context="ops:Access_Info">
      <sch:assert test="if (ops:access_available) then ops:access_available = ('true', 'false') else true()">
        <title>ops:Access_Info/ops:access_available</title>
        The attribute ops:access_available must be equal to one of the following values 'true', 'false'.</sch:assert>
      <sch:assert test="if (ops:authorization_required) then ops:authorization_required = ('true', 'false') else true()">
        <title>ops:Access_Info/ops:authorization_required</title>
        The attribute ops:authorization_required must be equal to one of the following values 'true', 'false'.</sch:assert>
    </sch:rule>
  </sch:pattern>
  <sch:pattern>
    <sch:rule context="ops:Access_Info/ops:access_method">
      <sch:assert test=". = ('https', 'internal', 'native', 's3')">
        <title>ops:Access_Info/ops:access_method/ops:access_method</title>
        The attribute ops:Access_Info/ops:access_method must be equal to one of the following values 'https', 'internal', 'native', 's3'.</sch:assert>
    </sch:rule>
  </sch:pattern>
  <sch:pattern>
    <sch:rule context="ops:Access_Info/ops:representation_profile">
      <sch:assert test=". = ('cloud-native', 'delivery', 'preservation')">
        <title>ops:Access_Info/ops:representation_profile/ops:representation_profile</title>
        The attribute ops:Access_Info/ops:representation_profile must be equal to one of the following values 'cloud-native', 'delivery', 'preservation'.</sch:assert>
    </sch:rule>
  </sch:pattern>
  <sch:pattern>
    <sch:rule context="ops:Access_Info/ops:representation_role">
      <sch:assert test=". = ('alternate', 'browse', 'primary')">
        <title>ops:Access_Info/ops:representation_role/ops:representation_role</title>
        The attribute ops:Access_Info/ops:representation_role must be equal to one of the following values 'alternate', 'browse', 'primary'.</sch:assert>
    </sch:rule>
  </sch:pattern>
  <sch:pattern>
    <sch:rule context="ops:Archive_Lifecycle_Status">
      <sch:assert test="if (ops:accumulating_data_flag) then ops:accumulating_data_flag = ('true', 'false') else true()">
        <title>ops:Archive_Lifecycle_Status/ops:accumulating_data_flag</title>
        The attribute ops:accumulating_data_flag must be equal to one of the following values 'true', 'false'.</sch:assert>
    </sch:rule>
  </sch:pattern>
  <sch:pattern>
    <sch:rule context="ops:Archive_Lifecycle_Status/ops:archive_lifecycle_state">
      <sch:assert test=". = ('in_internal_review', 'in_lien_resolution', 'in_peer_review', 'not_reviewed', 'rejected', 'released')">
        <title>ops:Archive_Lifecycle_Status/ops:archive_lifecycle_state/ops:archive_lifecycle_state</title>
        The attribute ops:Archive_Lifecycle_Status/ops:archive_lifecycle_state must be equal to one of the following values 'in_internal_review', 'in_lien_resolution', 'in_peer_review', 'not_reviewed', 'rejected', 'released'.</sch:assert>
    </sch:rule>
  </sch:pattern>
  <sch:pattern>
    <sch:rule context="ops:Archive_Lifecycle_Status/ops:archive_quality">
      <sch:assert test=". = ('external', 'needs_improvement', 'satisfactory', 'undetermined')">
        <title>ops:Archive_Lifecycle_Status/ops:archive_quality/ops:archive_quality</title>
        The attribute ops:Archive_Lifecycle_Status/ops:archive_quality must be equal to one of the following values 'external', 'needs_improvement', 'satisfactory', 'undetermined'.</sch:assert>
    </sch:rule>
  </sch:pattern>
  <sch:pattern>
    <sch:rule context="ops:Data_File_Info/ops:file_role">
      <sch:assert test=". = ('data', 'label')">
        <title>ops:Data_File_Info/ops:file_role/ops:file_role</title>
        The attribute ops:Data_File_Info/ops:file_role must be equal to one of the following values 'data', 'label'.</sch:assert>
    </sch:rule>
  </sch:pattern>
  <sch:pattern>
    <sch:rule context="ops:File_Info/ops:file_role">
      <sch:assert test=". = ('data', 'label')">
        <title>ops:File_Info/ops:file_role/ops:file_role</title>
        The attribute ops:File_Info/ops:file_role must be equal to one of the following values 'data', 'label'.</sch:assert>
    </sch:rule>
  </sch:pattern>
  <sch:pattern>
    <sch:rule context="ops:Label_File_Info/ops:file_role">
      <sch:assert test=". = ('data', 'label')">
        <title>ops:Label_File_Info/ops:file_role/ops:file_role</title>
        The attribute ops:Label_File_Info/ops:file_role must be equal to one of the following values 'data', 'label'.</sch:assert>
    </sch:rule>
  </sch:pattern>
  <sch:pattern>
    <sch:rule context="ops:Systems_Lifecycle_Status/ops:systems_lifecycle_phase">
      <sch:assert test=". = ('available', 'ingest', 'offline', 'preparation', 'review', 'staging')">
        <title>ops:Systems_Lifecycle_Status/ops:systems_lifecycle_phase/ops:systems_lifecycle_phase</title>
        The attribute ops:Systems_Lifecycle_Status/ops:systems_lifecycle_phase must be equal to one of the following values 'available', 'ingest', 'offline', 'preparation', 'review', 'staging'.</sch:assert>
    </sch:rule>
  </sch:pattern>
  <sch:pattern>
    <sch:rule context="ops:Systems_Lifecycle_Status/ops:systems_lifecycle_state">
      <sch:assert test=". = ('blocked', 'complete', 'failed', 'in_progress', 'pending')">
        <title>ops:Systems_Lifecycle_Status/ops:systems_lifecycle_state/ops:systems_lifecycle_state</title>
        The attribute ops:Systems_Lifecycle_Status/ops:systems_lifecycle_state must be equal to one of the following values 'blocked', 'complete', 'failed', 'in_progress', 'pending'.</sch:assert>
    </sch:rule>
  </sch:pattern>
  <sch:pattern>
    <sch:rule context="ops:Validation_Assessment">
      <sch:assert test="if (ops:action_required) then ops:action_required = ('true', 'false') else true()">
        <title>ops:Validation_Assessment/ops:action_required</title>
        The attribute ops:action_required must be equal to one of the following values 'true', 'false'.</sch:assert>
    </sch:rule>
  </sch:pattern>
  <sch:pattern>
    <sch:rule context="ops:Validation_Assessment/ops:validation_state">
      <sch:assert test=". = ('failed', 'not_tested', 'passed', 'passed_with_warnings', 'unknown')">
        <title>ops:Validation_Assessment/ops:validation_state/ops:validation_state</title>
        The attribute ops:Validation_Assessment/ops:validation_state must be equal to one of the following values 'failed', 'not_tested', 'passed', 'passed_with_warnings', 'unknown'.</sch:assert>
    </sch:rule>
  </sch:pattern>
  <sch:pattern>
    <sch:rule context="ops:Version_Status/ops:version_status">
      <sch:assert test=". = ('superseded', 'withdrawn')">
        <title>ops:Version_Status/ops:version_status/ops:version_status</title>
        The attribute ops:Version_Status/ops:version_status must be equal to one of the following values 'superseded', 'withdrawn'.</sch:assert>
    </sch:rule>
  </sch:pattern>
</sch:schema>
