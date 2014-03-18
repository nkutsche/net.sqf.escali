<?xml version="1.0" encoding="UTF-8"?>
<!--  
    Copyright (c) 2014 Nico Kutscherauer
        
    This file is part of Escali Schematron.
    
    Escali Schematron is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.
    
    Escali Schematron is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.
    
    You should have received a copy of the GNU General Public License
    along with Escali Schematron.  If not, see http://www.gnu.org/licenses/gpl-3.0.

-->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:es="http://www.escali.schematron-quickfix.com/" xmlns:axsl="http://www.w3.org/1999/XSL/TransformAlias" xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl" exclude-result-prefixes="xs xd sch svrl" xmlns:sch="http://purl.oclc.org/dsdl/schematron" version="2.0">
    <xsl:include href="escali_compiler_3_sqf-main.xsl"/>


    <xd:doc scope="stylesheet">
        <xd:desc>
            <xd:p><xd:b>Created on:</xd:b> Nov 19, 2013</xd:p>
            <xd:p><xd:b>Author:</xd:b> Nico Kutscherauer</xd:p>
        </xd:desc>
    </xd:doc>
    
    <xd:doc scope="version">
        <xd:desc>
            <xd:p>Version information</xd:p>
            <xd:ul>
                <xd:li>
                    <xd:p>2014-03-14</xd:p>
                    <xd:ul>
                        <xd:li>
                            <xd:p>publishing version</xd:p>
                        </xd:li>
                    </xd:ul>
                </xd:li>
            </xd:ul>
        </xd:desc>
    </xd:doc>
    
    
    <!--
        Escali Schematron main process
        
        process:
            expect a valid Schematron schema (../../schema/SQF/schematron-schema.xsd)
            creates the validator
            uses escali_compiler_3_sqf-main.xsl for SQF extensions
        
        uses axsl as the prefix for xslt elements to create for the validator
        
    -->

    <!--
    Parameter phase:
    use sch:schema/@defaultPhase as default
    #ALL -> every pattern is active
    
    sx extension:
    it could be more than one phase active.
    -->
    <xsl:param name="phase" select=" if (/sch:schema/@defaultPhase) then (/sch:schema/@defaultPhase) else ('#ALL')" as="xs:string+"/>

    <xsl:key name="elementBysxid" match="*[@es:id]" use="@es:id"/>

    <xsl:namespace-alias stylesheet-prefix="axsl" result-prefix="xsl"/>

    <xsl:output method="xml" indent="yes"/>

    <xsl:include href="escali_compiler_0_functions.xsl"/>

    <xsl:variable name="processingNamespaces" select="(
        'http://www.w3.org/XML/1998/namespace',
        'http://purl.oclc.org/dsdl/schematron',
        'http://www.schematron-quickfix.com/validator/process',
        'http://www.schematron-quickfix.com/svrl/extension',
        'http://www.escali.schematron-quickfix.com/',
        'http://www.w3.org/1999/XSL/Transform',
        'http://www.w3.org/2001/XMLSchema-instance')"/>

    <xsl:variable name="uri" select="/sch:schema/@es:uri"/>

    <xsl:variable name="namespace">
        <xsl:for-each select="/sch:schema/sch:ns">
            <es:ns pre="{@prefix}" uri="{@uri}"/>
        </xsl:for-each>
    </xsl:variable>

    <xsl:template match="sch:schema">
        <axsl:stylesheet version="2.0">
            <xsl:apply-templates select="/sch:schema/es:default-namespace"/>
            <xsl:namespace name="xs" select="'http://www.w3.org/2001/XMLSchema'"/>
            <xsl:call-template name="namespace"/>
            <axsl:output method="xml" indent="yes"/>
            <axsl:include href="{resolve-uri('escali_compiler_0_functions.xsl')}"/>
            <xsl:call-template name="topLevelValidatorExtension"/>
            <axsl:template match="/">
                <svrl:schematron-output xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:sch="http://purl.oclc.org/dsdl/schematron" xmlns:svrl="http://purl.oclc.org/dsdl/svrl">
                    <xsl:if test="//sch:title">
                        <xsl:attribute name="title" select="(//sch:title)[1]//text()"/>
                    </xsl:if>
                    <xsl:attribute name="phase" select="$phase"/>
                    <xsl:copy-of select="@schemaVersion | @es:link | @es:icon"/>
                    <xsl:call-template name="topLevelManipulatorExtension"/>
                    <xsl:variable name="rootNamespaces">
                        <xsl:for-each select="/*/namespace::*[not(.=$processingNamespaces)]">
                            <sch:ns prefix="{name()}" uri="{.}"/>
                        </xsl:for-each>
                    </xsl:variable>
                    <xsl:for-each-group select="/sch:schema/sch:ns | $rootNamespaces/sch:ns" group-by="@uri">
                        <svrl:ns-prefix-in-attribute-values uri="{current-grouping-key()}">
                            <xsl:attribute name="prefix" select="distinct-values(current-group()/@prefix)" separator=" "/>
                        </svrl:ns-prefix-in-attribute-values>
                    </xsl:for-each-group>
                    <xsl:for-each select="sch:p | sch:pattern/sch:p">
                        <xsl:variable name="refElement" select="key('elementBysxid', @es:ref)"/>
                        <xsl:choose>
                            <xsl:when test="$refElement/self::sch:pattern and not(es:isActive($refElement, $phase))"/>
                            <xsl:otherwise>
                                <svrl:text>
                                    <xsl:copy-of select="@id | @es:icon | @es:link | @es:ref | @es:class"/>
                                    <xsl:apply-templates select="node()"/>
                                </svrl:text>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:for-each>
                    <xsl:for-each select="sch:pattern">
                        <xsl:if test="es:isActive(., $phase)">
                            <svrl:active-pattern>
                                <xsl:copy-of select="@id | @role | @es:icon | @es:link | @es:is-a | @es:id"/>
                                <xsl:attribute name="es:patternId" select="@es:id"/>
                            </svrl:active-pattern>
                        </xsl:if>
                    </xsl:for-each>
                    <axsl:apply-templates/>
                </svrl:schematron-output>
            </axsl:template>
            <xsl:apply-templates select="node() except es:default-namespace"/>
            <!-- 
        copies all nodes in the validator
    -->
            <axsl:template match="node() | @*" priority="-1">
                <axsl:param name="precId" select="()" as="xs:string*"/>
                <axsl:apply-templates select="node() | @*" mode="#current">
                    <axsl:with-param name="precId" select="()"/>
                </axsl:apply-templates>
            </axsl:template>
            <axsl:template match="text()"/>
        </axsl:stylesheet>
    </xsl:template>

    <xsl:template match="sch:title"/>



    <xsl:template match="es:default-namespace">
        <xsl:namespace name="" select="@uri"/>
        <xsl:attribute name="xpath-default-namespace" select="@uri"/>
    </xsl:template>

    <xsl:key name="rulesByPriorityOrNot" match="sch:rule" use=" if (parent::sch:pattern/@es:matchType = 'priority') then ('priorities') else ('non-priorities')"/>



    <xsl:function name="es:getPriority" as="xs:double">
        <xsl:param name="rule" as="element(sch:rule)"/>
        <xsl:variable name="non-priorities" select="key('rulesByPriorityOrNot', 'non-priorities', root($rule))"/>
        <xsl:choose>
            <xsl:when test="$rule[parent::sch:pattern[@es:matchType = 'priority']]">
                <xsl:variable name="priorities" select="key('rulesByPriorityOrNot', 'priorities', root($rule))"/>
                <xsl:variable name="sortedRules">
                    <xsl:for-each select="$priorities">
                        <xsl:sort select="@es:priority" data-type="number"/>
                        <sch:rule>
                            <xsl:copy-of select="@es:id"/>
                        </sch:rule>
                    </xsl:for-each>
                </xsl:variable>
                <xsl:variable name="precRules" select="$sortedRules/sch:rule[@es:id=$rule/@es:id]/preceding-sibling::sch:rule"/>
                <xsl:value-of select="count($precRules) + count($non-priorities)"/>
                
            </xsl:when>
            <xsl:otherwise>
                <xsl:variable name="followingRules" select="$non-priorities[. >> $rule]"/>
                <xsl:variable name="countFollowingRules" select="count($followingRules)"/>
                <xsl:value-of select="$countFollowingRules"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>

    <xsl:template match="sch:rule">
        <xsl:variable name="matchType" select="parent::sch:pattern/@es:matchType"/>
        <axsl:template match="{@context}">
            <xsl:attribute name="priority" select="es:getPriority(.)+10"/>
            <xsl:call-template name="namespace"/>
            <axsl:param name="precId" select="()" as="xs:string*"/>
            <xsl:variable name="patternId" select="parent::sch:pattern/@es:id"/>
            <axsl:choose>
                <axsl:when test="'{$matchType}'=('', 'first', 'priority') and '{$patternId}'=$precId"/>
                <axsl:otherwise>
                    <svrl:fired-rule context="{if (@subject) 
                                             then (@subject) 
                                             else (@context)}" es:patternId="{$patternId}" es:id="{@es:id}">
                        <xsl:copy-of select="@flag | @id | @es:icon | @es:link"/>
                        <xsl:call-template name="getRoleFlag"/>
                    </svrl:fired-rule>
                    <xsl:apply-templates/>
                </axsl:otherwise>
            </axsl:choose>
            <axsl:next-match>
                <axsl:with-param name="precId" select="('{$patternId}', $precId)"/>
            </axsl:next-match>
        </axsl:template>
    </xsl:template>
    <xsl:template match="sch:assert">
        <axsl:choose>
            <xsl:call-template name="namespace"/>
            <axsl:when test="{@test}"/>
            <axsl:otherwise>
                <svrl:failed-assert>
                    <xsl:call-template name="reportAssertBody"/>
                </svrl:failed-assert>
            </axsl:otherwise>
        </axsl:choose>
    </xsl:template>
    <xsl:template match="sch:report">
        <axsl:if test="{@test}">
            <xsl:call-template name="namespace"/>
            <svrl:successful-report>
                <xsl:call-template name="reportAssertBody"/>
            </svrl:successful-report>
        </axsl:if>
    </xsl:template>

    <xsl:template name="reportAssertBody">
        <xsl:variable name="messageId" select="@es:id"/>
        <xsl:copy-of select="@es:icon | @es:link"/>
        <xsl:variable name="subject" select="(@subject , ../@subject)[1]"/>
        <xsl:variable name="contextPath" select=" if (not($subject)) 
            then ('.') 
            else if (starts-with($subject,'/')) 
            then ($subject) 
            else (concat('./',$subject))"/>
        <xsl:attribute name="location">
            <xsl:text>{es:getNodePath(</xsl:text>
            <xsl:value-of select="$contextPath"/>
            <xsl:text>)}</xsl:text>
        </xsl:attribute>
        <xsl:attribute name="es:id">
            <xsl:text>{generate-id(self::node())}_</xsl:text>
            <xsl:value-of select="$messageId"/>
        </xsl:attribute>
        <xsl:attribute name="es:patternId" select="parent::*/parent::sch:pattern/@es:id"/>
        <xsl:call-template name="getRoleFlag"/>

        <axsl:attribute name="test">
            <xsl:value-of select="@test"/>
        </axsl:attribute>
        <xsl:variable name="diagnostics" select="tokenize(@diagnostics, '\s')"/>
        <xsl:apply-templates select="//sch:diagnostic[@id=$diagnostics]"/>
        <svrl:text>
            <xsl:apply-templates/>
        </svrl:text>
        <xsl:call-template name="extension">
            <xsl:with-param name="messageId" select="$messageId"/>
        </xsl:call-template>
    </xsl:template>

    <xsl:template name="getRoleFlag">
        <xsl:copy-of select="(ancestor-or-self::*/@role)[last()]"/>
        <xsl:copy-of select="(ancestor-or-self::*/@flag)[last()]"/>
    </xsl:template>

    <xsl:template match="sch:let">
        <axsl:variable name="{@name}" select="{@value}">
            <xsl:call-template name="namespace"/>
        </axsl:variable>
    </xsl:template>
    <xsl:template match="sch:value-of" mode="#all">
        <axsl:value-of select="{@select}">
            <xsl:call-template name="namespace"/>
        </axsl:value-of>
    </xsl:template>
    <xsl:template match="sch:name">
        <xsl:variable name="select" select=" if (@path) 
                                           then (concat(@path, '/name()')) 
                                           else ('name()')"/>
        <axsl:value-of select="{$select}">
            <xsl:call-template name="namespace"/>
        </axsl:value-of>
    </xsl:template>
    <xsl:template match="sch:ns"/>
    <xsl:template match="sch:pattern">
        <xsl:if test="es:isActive(., $phase)">
            <xsl:apply-templates/>
        </xsl:if>
    </xsl:template>
    <xsl:template match="sch:p|sch:diagnostics"/>
    <xsl:template match="sch:diagnostic">
        <svrl:diagnostic-reference diagnostic="{@id}">
            <xsl:copy-of select="@es:icon | @es:link"/>
            <svrl:text>
                <xsl:apply-templates/>
            </svrl:text>
        </svrl:diagnostic-reference>
    </xsl:template>

    <xsl:template match="sch:span|sch:dir|sch:emph">
        <xsl:element name="qvrl:{local-name(.)}">
            <xsl:apply-templates select="@*"/>
            <xsl:apply-templates select="node()"/>
        </xsl:element>
    </xsl:template>
    <xsl:template match="sch:span/@class | sch:dir/@value">
        <xsl:copy/>
    </xsl:template>

    <xsl:template match="*[namespace-uri()='http://www.w3.org/1999/XSL/Transform']" priority="-5">
        <xsl:copy>
            <xsl:copy-of select="@*"/>
            <xsl:call-template name="namespace"/>
            <xsl:apply-templates/>
        </xsl:copy>
    </xsl:template>
    <xsl:template match="*" priority="-10">
        <xsl:copy>
            <xsl:copy-of select="@*"/>
            <xsl:call-template name="namespace"/>
            <xsl:apply-templates/>
        </xsl:copy>
    </xsl:template>
    <xsl:template name="namespace">
        <xsl:variable name="ns">
            <xsl:for-each select="ancestor-or-self::*/namespace::*">
                <es:ns pre="{name()}" uri="{.}"/>
            </xsl:for-each>
            <xsl:copy-of select="$namespace/es:ns"/>
        </xsl:variable>
        <xsl:for-each-group select="$ns/es:ns" group-by="@pre">
            <xsl:if test="not(current-grouping-key()='')">
                <xsl:namespace name="{current-grouping-key()}" select="current-group()[last()]/@uri"/>
            </xsl:if>
        </xsl:for-each-group>
        <!--	<xsl:copy-of select="$ns/*"/>-->
    </xsl:template>
</xsl:stylesheet>
