use this to call the escali:

call escali-validate.bat [source] [schema] [outfile]? [ask-for-user-entries]?

[source]				Source document of the Schematron validation. It must be a XML wellformed document.
[schema]				Schematron schema. Should be valid to the schema xml/schema/SQF/schematron-schema.xsd and respects the business rules of xml/schema/SQF/sqf.sch.
[outfile]				Result file for the fixed source document. If the outfile is not definde, the QuickFix option is not available.
[ask-for-user-entries]	If the value is "no" the user entry option is not available.

Configurations:

Use the configuration file META-INF/config.xml:

<es:tempFolder>../temp/</es:tempFolder>
Path to temporary folder. Into this folder the following files will be generated:
- temp.svrl             Schematron report as SVRL file
- report.html           Schematron report as HTML site
- manipulator.tmp       XSM sheet to manipulate the source document
- tempOutput.xml        manipulated source document as temporary output document.

<es:phase>#ALL</es:phase>
Set the used phase of the Schematron schema.

<es:xml-save-mode>true</es:xml-save-mode>
Activates the xml-save mode. If it is true, the process preserves all informations, which a XSLT transformation loses.

<es:xsm-processor>../../net.sqf.xsm/xsm/v0.1/</es:xsm-processor>
Path to the folder which contains the XSM processor. If xml-save mode is false, the XSM processor is not necessary.