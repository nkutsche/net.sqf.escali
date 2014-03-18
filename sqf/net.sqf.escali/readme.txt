Copyright (c) 2014 Nico Kutscherauer
    
This file is part of Escali Schematron (commandline tool).

Escali Schematron is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

Escali Schematron is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with Escali Schematron (xsl/gpl-3.0.txt).  If not, see http://www.gnu.org/licenses/gpl-3.0.

--- R E Q U I R E M E N T S ---
 
- You have to install Java 1.7 or later.
- This tool uses the following Java programs:
	- Calabash v1.0.10-94 (see the Requirements of Calabash on http://xmlcalabash.com/docs/)
	- XSM-Processor v0.1


--- D O C U M E N T A T I O N ---
	
use this to call the escali:

Windows:
%ESCALI%\escali-validate.bat %source% %schema% %outfile%? %ask-for-user-entries%?

Linux:
$escali\escali-validate.sh $source $schema $outfile? $ask-for-user-entries?

%source% | $source								Source document of the Schematron validation. 
												It must be a XML wellformed document.
%schema% | $schema								Schematron schema. Should be valid to the schema 
												xml/schema/SQF/schematron-schema.xsd and respects 
												the business rules of xml/schema/SQF/sqf.sch.
%outfile% | $outfile							Result file for the fixed source document. If the 
												outfile is not definde, the QuickFix option is not 
												available.
%ask-for-user-entries% | $ask-for-user-entries	If the value is "no" the user entry option is not 
												available.

												
-- CONFIGURATIONS --

Use the configuration file META-INF/config.xml:

<es:tempFolder>../temp/</es:tempFolder>
Path to temporary folder. Into this folder the following files will be generated:
- temp.svrl             Schematron report as SVRL file
- report.html           Schematron report as HTML site
- manipulator.tmp       XSM sheet to manipulate the source document
- tempOutput.xml        manipulated source document as temporary output document.

<es:phase>#ALL</es:phase>
Set the used phase of the Schematron schema.

+ - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - +
|																|
|	NOTE: 														|
|	The XSM processor works only on Windows systems  			|
|	correctly at the moment! Therefore the XML-save mode is 	|
|	not available and the Escali will ignore the config on 		|
|	this part.													|
|																|
+ - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - +

<es:xml-save-mode>true</es:xml-save-mode>
Activates the xml-save mode. If it is true, the process preserves all informations, which a 
XSLT transformation loses.

<es:xsm-processor>../../net.sqf.xsm/xsm/v0.1/</es:xsm-processor>
Path to the folder which contains the XSM processor. If xml-save mode is false, the 
XSM processor is not necessary.