<?xml version="1.0" encoding="UTF-8"?>

<!--
    Copyright (c) 2014 Nico Kutscherauer
    
    This file is part of Escali Schematron (XProc implementation).
    
    Escali Schematron is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.
    
    Escali Schematron is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.
    
    You should have received a copy of the GNU General Public License
    along with Escali Schematron (../xsl/gpl-3.0.txt).  If not, see http://www.gnu.org/licenses/gpl-3.0.
    
-->

<p:library xmlns:p="http://www.w3.org/ns/xproc" xmlns:es="http://www.escali.schematron-quickfix.com/" xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:sch="http://purl.oclc.org/dsdl/schematron" xmlns:sqf="http://www.schematron-quickfix.com/validator/process" xmlns:cx="http://xmlcalabash.com/ns/extensions" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:c="http://www.w3.org/ns/xproc-step" version="1.0">

    <p:declare-step type="es:validateAndFix" name="es_validateAndFix">
        <p:input port="source" primary="true"/>
        <p:input port="schema"/>
        <p:input port="params"/>
        <p:output port="result" primary="true"/>
        <p:option name="msgPos"/>
        <p:option name="fixName"/>
        <p:option name="phase"/>
        <p:option name="xml-save-mode" select="'false'"/>
        <es:schematron name="validate">
            <p:input port="schema">
                <p:pipe port="schema" step="es_validateAndFix"/>
            </p:input>
            <p:input port="source">
                <p:pipe port="source" step="es_validateAndFix"/>
            </p:input>
            <p:with-option name="phase" select="$phase"/>
            <p:input port="params">
                <p:pipe port="params" step="es_validateAndFix"/>
            </p:input>
        </es:schematron>
        <p:for-each name="parameters">
            <p:iteration-source select="/svrl:schematron-output/svrl:*[local-name() = 'failed-assert' or local-name() = 'successful-report'][xs:integer($msgPos)]/sqf:fix[@fixId=$fixName]/sqf:user-entry/sqf:param">
                <p:pipe port="result" step="validate"/>
            </p:iteration-source>
            <p:output port="result" primary="true" sequence="true"/>
            <p:variable name="id" select="sqf:param/@param-id"/>
            <p:variable name="name" select="sqf:param/@name"/>
            <p:variable name="value" select="/c:param-set/c:param[@name=$name]/@value">
                <p:pipe port="params" step="es_validateAndFix"/>
            </p:variable>
            <es:parameter>
                <p:with-option name="param-name" select="$id"/>
                <p:with-option name="param-value" select="$value"/>
            </es:parameter>
        </p:for-each>
        <p:wrap-sequence wrapper="c:param-set" name="paramset"/>
        <es:quickFix>
            <p:input port="svrl">
                <p:pipe port="result" step="validate"/>
            </p:input>
            <p:input port="source">
                <p:pipe port="source" step="es_validateAndFix"/>
            </p:input>
            <p:input port="params">
                <p:pipe port="result" step="paramset"/>
            </p:input>
            <p:with-option name="fixId" select="/svrl:schematron-output/svrl:*[local-name() = 'failed-assert' or local-name() = 'successful-report'][xs:integer($msgPos)]/sqf:fix[@fixId=$fixName]/@id">
                <p:pipe port="result" step="validate"/>
            </p:with-option>
            <p:with-option name="xml-save-mode" select="$xml-save-mode"/>
        </es:quickFix>
        <p:choose>
            <p:when test="$xml-save-mode='true'">
                <p:variable name="sourceFolder" select="resolve-uri('.', document-uri(/))">
                    <p:pipe port="source" step="es_validateAndFix"/>
                </p:variable>
                <es:xsm name="xsm">
                    <p:with-option name="tempFolder" select="$sourceFolder"/>
                    <p:with-option name="xsmFolder" select="resolve-uri('../../../net.sqf.xsm/xsm/v0.1/')"/>
                </es:xsm>
<!--                <p:sink name="xsm"/>-->
                <p:load href="../../temp/tempOutput.xml" cx:depends-on="xsm"/>
            </p:when>
            <p:otherwise>
                <p:identity/>
            </p:otherwise>
        </p:choose>
    </p:declare-step>
    <p:declare-step type="es:parameter" name="es_parameter">
        <p:option name="param-name" select="''"/>
        <p:option name="param-value" select="''"/>
        <p:option name="commandline" select="''"/>
        <p:output port="result" primary="true"/>
        <p:xslt template-name="createParam">
            <p:input port="source">
                <p:inline>
                    <dummy/>
                </p:inline>
            </p:input>
            <p:input port="stylesheet">
                <p:inline>
                    <xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:c="http://www.w3.org/ns/xproc-step" xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl" exclude-result-prefixes="xs xd" version="2.0">
                        <xsl:param name="name" select="''"/>
                        <xsl:param name="value" select="''"/>
                        <xsl:param name="commandline" select="''"/>
                        <xsl:template name="createParam">
                            <xsl:choose>
                                <xsl:when test="$commandline != ''">
                                    <xsl:variable name="pairs" select="tokenize($commandline, ';')"/>
                                    <c:param-set>
                                        <xsl:for-each select="$pairs">
                                            <xsl:variable name="name" select="substring-before(., '=')"/>
                                            <xsl:variable name="value" select="substring-after(., '=')"/>
                                            <xsl:if test="$name=''">
                                                <xsl:message terminate="yes">$name is empty! cmd: (<xsl:value-of select="$commandline"/>)</xsl:message>
                                            </xsl:if>
                                            <c:param name="{$name}" value="{$value}" xmlns:sqf="http://www.schematron-quickfix.com/validator/process"/>
                                        </xsl:for-each>
                                    </c:param-set>
                                </xsl:when>
                                <xsl:when test="$value != ''">
                                    <c:param name="{concat('sqf:',$name)}" value="{$value}" xmlns:sqf="http://www.schematron-quickfix.com/validator/process"/>
                                </xsl:when>
                                <xsl:otherwise>
                                    <c:param-set/>
                                </xsl:otherwise>
                            </xsl:choose>
                        </xsl:template>
                    </xsl:stylesheet>
                </p:inline>
            </p:input>
            <p:with-param name="name" select="$param-name"/>
            <p:with-param name="value" select="$param-value"/>
            <p:with-param name="commandline" select="$commandline"/>
        </p:xslt>
    </p:declare-step>

    <p:declare-step type="es:getSvrlParam" name="es_getSvrlParam">
        <p:input port="svrl" primary="true"/>
        <p:option name="commandline" select="''"/>
        <p:option name="fixId"/>
        <p:output port="result" primary="true"/>
        <p:xslt template-name="createParam">
            <p:input port="stylesheet">
                <p:inline>
                    <xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:c="http://www.w3.org/ns/xproc-step" xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl" exclude-result-prefixes="xs xd" version="2.0">
                        <xsl:param name="commandline" select="''"/>
                        <xsl:param name="fixId" select="''"/>
                        <xsl:template name="createParam">
                            <xsl:variable name="fix" select="/svrl:schematron-output/svrl:*/sqf:fix[@id=$fixId]"/>
                            <xsl:variable name="pairs" select="tokenize($commandline, ';')"/>
                            <c:param-set>
                                <xsl:for-each select="$pairs[.!='']">
                                    <xsl:variable name="name" select="substring-before(., '=')"/>
                                    <xsl:variable name="value" select="substring-after(., '=')"/>
                                    <xsl:variable name="name" select="$fix/sqf:user-entry/sqf:param[@name=$name]/@param-id"/>
                                    <xsl:if test="$name">
                                        <c:param name="sqf:{$name}" value="{$value}" xmlns:sqf="http://www.schematron-quickfix.com/validator/process"/>
                                    </xsl:if>
                                </xsl:for-each>
                            </c:param-set>
                        </xsl:template>
                    </xsl:stylesheet>
                </p:inline>
            </p:input>
            <p:with-param name="commandline" select="$commandline"/>
            <p:with-param name="fixId" select="$fixId"/>
        </p:xslt>
    </p:declare-step>

    <p:declare-step type="es:compile" name="es_compile">
        <p:input port="schema" primary="true"/>
        <p:output port="validator" primary="true"/>

        <p:option name="phase" select="'#ALL'"/>
        <p:option name="lang" select="'#NULL'"/>

        <p:validate-with-xml-schema>
            <p:input port="schema">
                <p:document href="../schema/SQF/schematron-schema.xsd"/>
            </p:input>
        </p:validate-with-xml-schema>

        <p:xslt name="excali1">
            <p:input port="stylesheet">
                <p:document href="../xsl/01_compiler/escali_compiler_1_include.xsl"/>
            </p:input>
            <p:with-param name="es:lang" select="if ($lang = '#NULL' and /sch:schema/@xml:lang) 
                                               then (/sch:schema/@xml:lang) 
                                               else ($lang)"/>
            <p:with-param name="es:type-available" select="'false'"/>
        </p:xslt>
        <p:xslt name="excali2">
            <p:input port="stylesheet">
                <p:document href="../xsl/01_compiler/escali_compiler_2_abstract-patterns.xsl"/>
            </p:input>
            <p:with-param name="dummy" select="''"/>
        </p:xslt>
        <p:xslt name="excali3">
            <p:input port="stylesheet">
                <p:document href="../xsl/01_compiler/escali_compiler_3_main.xsl"/>
            </p:input>
            <p:with-param name="phase" select="$phase"/>
        </p:xslt>
    </p:declare-step>

    <p:declare-step type="es:schematron" name="es_schematron">
        <p:input port="schema"/>
        <p:input port="source" primary="true"/>
        <p:input port="params" kind="parameter">
            <p:empty/>
        </p:input>
        <p:output port="result" primary="true"/>
        <p:output port="secundaries" sequence="true">
            <p:pipe port="source" step="es_schematron"/>
            <p:pipe port="result" step="xincluded"/>
            <p:pipe port="validator" step="compiled"/>
            <p:pipe port="result" step="svrl_raw"/>
            <p:pipe port="result" step="svrl"/>
        </p:output>
        <p:option name="phase" select="'#ALL'"/>
        <p:option name="lang" select="'#NULL'"/>
        <p:option name="outputFormat" select="'svrl'"/>
        <p:option name="xinclude" select="'false'"/>

        <es:compile name="compiled">
            <p:with-option name="phase" select="$phase"/>
            <p:with-option name="lang" select="$lang"/>
            <p:input port="schema">
                <p:pipe port="schema" step="es_schematron"/>
            </p:input>
        </es:compile>
        <p:choose>
            <p:when test="$xinclude = 'true'">
                <p:xinclude>
                    <p:input port="source">
                        <p:pipe port="source" step="es_schematron"/>
                    </p:input>
                </p:xinclude>
                <!--                <p:add-xml-base/>-->
            </p:when>
            <p:otherwise>
                <p:identity>
                    <p:input port="source">
                        <p:pipe port="source" step="es_schematron"/>
                    </p:input>
                </p:identity>
            </p:otherwise>
        </p:choose>
        <p:identity name="xincluded"/>
        <p:xslt name="svrl_raw">
            <p:input port="stylesheet">
                <p:pipe port="validator" step="compiled"/>
            </p:input>
            <p:input port="parameters">
                <p:pipe port="params" step="es_schematron"/>
            </p:input>
        </p:xslt>
        <p:xslt name="svrl">
            <p:input port="stylesheet">
                <p:document href="../xsl/02_validator/escali_validator_2_postprocess.xsl"/>
            </p:input>
            <p:with-param name="dummy" select="''"/>
        </p:xslt>
        <p:validate-with-xml-schema>
            <p:input port="schema">
                <p:document href="../schema/SVRL/svrl.xsd"/>
            </p:input>
        </p:validate-with-xml-schema>
        <p:choose>
            <p:when test="$outputFormat = 'html' or $outputFormat = 'escali'">
                <p:load name="outputPrinter">
                    <p:with-option name="href" select="concat('../xsl/02_validator/escali_validator_3_', $outputFormat, '-report.xsl')"/>
                </p:load>
                <p:xslt>
                    <p:input port="source">
                        <p:pipe port="result" step="svrl"/>
                    </p:input>
                    <p:input port="stylesheet">
                        <p:pipe port="result" step="outputPrinter"/>
                    </p:input>
                    <p:with-param name="dummy" select="''"/>
                </p:xslt>
            </p:when>
            <p:otherwise>
                <p:identity/>
            </p:otherwise>
        </p:choose>
    </p:declare-step>

    <p:declare-step type="es:quickFix" name="es_quickFix">
        <p:input port="svrl" primary="true"/>
        <p:input port="source"/>
        <p:input port="params" kind="parameter" sequence="true"/>
        <p:output port="result" primary="true"/>
        <p:option name="fixId"/>
        <p:option name="xml-save-mode" select="'false'"/>
        <p:xslt name="extractor">
            <p:input port="stylesheet">
                <p:document href="../xsl/03_extractor/escali_extractor_1_main.xsl"/>
            </p:input>
            <p:with-param name="id" select="$fixId"/>
        </p:xslt>
        <p:xslt>
            <p:input port="source">
                <p:pipe port="source" step="es_quickFix"/>
            </p:input>
            <p:input port="stylesheet">
                <p:pipe port="result" step="extractor"/>
            </p:input>
            <p:input port="parameters">
                <p:pipe port="params" step="es_quickFix"/>
            </p:input>
            <p:with-param name="xsm:xml-save-mode" select="$xml-save-mode='true'" xmlns:xsm="http://www.schematron-quickfix.com/manipulator/process"/>
        </p:xslt>
        <p:xslt>
            <p:input port="stylesheet">
                <p:document href="../xsl/04_manipulator/escali_manipulator_2_postprocess.xsl"/>
            </p:input>
            <p:with-param name="dummy" select="''"/>
        </p:xslt>
    </p:declare-step>

    <p:declare-step type="es:xsm" name="es_xsm">
        <p:input port="source" primary="true"/>
        <p:option name="xsmFolder"/>
        <p:option name="tempFolder"/>
        <p:option name="system" select="'bat'"/>

        <p:variable name="cwd" select="es:get-file-path($xsmFolder)"/>
        <p:variable name="xsmScript" select=" es:get-file-path(concat($xsmFolder,'xsm.', $system))"/>
        <p:variable name="command" select="   if ($system='bat') 
                                            then ($xsmScript) 
                                            else ($system)"/>
        <p:variable name="manipulator" select="replace(concat($tempFolder, '/manipulator.tmp'), '^file:', '')"/>
        <p:variable name="manipulatorFile" select="es:get-file-path(concat($tempFolder, '/manipulator.tmp'))"/>
        
        <p:variable name="quote" select="if ($system='bat') 
                                            then ('&quot;') 
                                            else ('')"/>
        <p:variable name="outFile" select="es:get-file-path(resolve-uri('../../temp/tempOutput.xml'))"/>

        <p:variable name="args" select="concat( if ($system='bat') 
                                              then ('') 
                                              else ($xsmScript), ' ', $quote, $manipulatorFile, $quote, ' -o ', $quote, $outFile, $quote)"/>
        <p:load name="xsm-schema">
            <p:with-option name="href" select="resolve-uri('xml/schema/XSM/xpath-based-string-manipulator.xsd', $xsmFolder)"/>
        </p:load>
        <p:validate-with-xml-schema>
            <p:input port="source">
                <p:pipe port="source" step="es_xsm"/>
            </p:input>
            <p:input port="schema">
                <p:pipe port="result" step="xsm-schema"/>
            </p:input>
        </p:validate-with-xml-schema>
        <p:store name="storeManSheet">
            <p:with-option name="href" select="$manipulator"/>
        </p:store>
        <p:exec result-is-xml="false" cx:depends-on="storeManSheet" name="exec">
            <p:input port="source">
                <p:empty/>
            </p:input>
            <p:with-option name="command" select="$command"/>
            <p:with-option name="cwd" select="$cwd"/>
            <p:with-option name="args" select="$args"/>
        </p:exec>
        <p:add-attribute match="c:result" attribute-name="cwd" xmlns:c="http://www.w3.org/ns/xproc-step">
            <p:with-option name="attribute-value" select="$cwd"/>
        </p:add-attribute>
        <p:add-attribute match="c:result" attribute-name="args" xmlns:c="http://www.w3.org/ns/xproc-step">
            <p:with-option name="attribute-value" select="$args"/>
        </p:add-attribute>
        <p:store href="../../temp/xsm-out.xml"/>
        <p:store href="../../temp/xsm-err.xml">
            <p:input port="source">
                <p:pipe port="errors" step="exec"/>
            </p:input>
        </p:store>
    </p:declare-step>
</p:library>
