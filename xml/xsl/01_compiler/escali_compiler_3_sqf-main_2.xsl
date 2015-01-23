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
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:sch="http://purl.oclc.org/dsdl/schematron" xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:es="http://www.escali.schematron-quickfix.com/" xmlns:axsl="http://www.w3.org/1999/XSL/TransformAlias" xmlns:bxsl="http://www.w3.org/1999/XSL/TransformAliasAlias" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl" xmlns:sqf="http://www.schematron-quickfix.com/validator/process" xmlns:xsm="http://www.schematron-quickfix.com/manipulator/process" exclude-result-prefixes="xs xd" version="2.0">

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

    <xsl:param name="sqf:changePrefix" select="'sqfc'" as="xs:string"/>
    <xsl:param name="sqf:useSQF" select="exists(key('elementsByNamespace', 'http://www.schematron-quickfix.com/validator/process'))" as="xs:boolean"/>

    <xsl:variable name="es:type-available" select="/sch:schema/@es:type-available = 'true'" as="xs:boolean"/>

    <xsl:key name="elementsByNamespace" match="*" use="namespace-uri()"/>
    <xsl:namespace-alias stylesheet-prefix="bxsl" result-prefix="axsl"/>

    <xsl:variable name="activityElements" select="('add','delete','replace','stringReplace')"/>

    <!--
    fix top level elements in validator
-->
    <xsl:template name="topLevelValidatorExtension">
        <xsl:if test="$sqf:useSQF">
            <axsl:namespace-alias stylesheet-prefix="axsl" result-prefix="xsl"/>
            <axsl:template match="processing-instruction()[matches(name(),'{$sqf:changePrefix}-(end|start)')]" priority="1000" sqf:changeMarker="true"/>
        </xsl:if>
    </xsl:template>
    <!--
    Extension template
    called for used sqf:fix elements
-->
    <xsl:variable name="globalFixes" select="/*/sqf:fixes/sqf:fix"/>
    <xsl:variable name="globalGroups" select="/*/sqf:fixes/sqf:group"/>

    <xsl:function name="es:getActiveFixes" as="element(sqf:fix)*">
        <xsl:param name="fixIds" as="xs:string*"/>
        <xsl:param name="availableFixes" as="element(sqf:fix)*"/>
        <xsl:param name="availableGroups" as="element(sqf:group)*"/>
        <xsl:for-each select="$fixIds">
            <xsl:variable name="id" select="."/>
            <xsl:choose>
                <xsl:when test="contains($id, '#')">
                    <xsl:variable name="groupId" select="substring-before($id, '#')"/>
                    <xsl:variable name="fixId" select="substring-after($id, '#')"/>
                    <xsl:sequence select="$availableGroups[@id = $groupId]/sqf:fix[@id = $fixId]"/>
                </xsl:when>
                <xsl:when test="$availableFixes/@id = $id">
                    <xsl:sequence select="$availableFixes[@id = $id]"/>
                </xsl:when>
                <xsl:when test="$availableGroups/@id = $id">
                    <xsl:sequence select="$availableGroups[@id = $id]/sqf:fix"/>
                </xsl:when>
                <xsl:otherwise/>
            </xsl:choose>
        </xsl:for-each>
    </xsl:function>

    <xsl:template name="extension">
        <xsl:param name="messageId" as="xs:string"/>
        <xsl:param name="defaultFix" select="@sqf:default-fix" as="xs:string?"/>
        <xsl:if test="$sqf:useSQF">
            <xsl:variable name="fix" select="tokenize(current()/@sqf:fix, '\s+')"/>
            <xsl:variable name="localFixes" select="../sqf:fix"/>
            <xsl:variable name="localGroups" select="../sqf:group"/>

            <xsl:variable name="availableFixes" select="$localFixes | $globalFixes[not(@id = ($localFixes/@id, $localGroups/@id))]"/>
            <xsl:variable name="availableGroups" select="$localGroups | $globalGroups[not(@id = ($localGroups/@id, $localFixes/@id))]"/>



            <xsl:for-each select="es:getActiveFixes($fix, $availableFixes, $availableGroups)">
                <xsl:variable name="isDefault" select="$defaultFix = @id"/>
                <xsl:variable name="fix" select="."/>

                <axsl:if test="{if (parent::sqf:group/@use-when) then (parent::sqf:group/@use-when) else ('true()')}">
                    <axsl:if test="{if(@use-when) then(@use-when) else('true()')}">
                        <xsl:variable name="groupId" select=" if (parent::sqf:group) then (concat(parent::sqf:group/@id, '#')) else ('')"/>
                        <sqf:fix fixId="{$groupId}{@id}" messageId="{$messageId}">
                            <xsl:attribute name="contextId">
                                <xsl:text>{generate-id(self::node())}</xsl:text>
                            </xsl:attribute>
                            <xsl:attribute name="id">
                                <xsl:value-of select="@id"/>
                                <xsl:text>-</xsl:text>
                                <xsl:value-of select="$messageId"/>
                                <xsl:text>-</xsl:text>
                                <xsl:text>{generate-id(self::node())}</xsl:text>
                            </xsl:attribute>
                            <xsl:attribute name="role">

                                <xsl:variable name="singleMode" select="$activityElements[every $el in $fix/sqf:*[local-name()=$activityElements] satisfies local-name($el) = .]" as="xs:string?"/>
                                <xsl:variable name="mode" select=" if ($singleMode) 
                                                         then ($singleMode) 
                                                         else ('mix')"/>
                                <xsl:value-of select="if(@role) then(@role) else($mode)"/>
                            </xsl:attribute>
                            <xsl:if test="$isDefault">
                                <xsl:attribute name="default" select="$isDefault"/>
                            </xsl:if>
                            <xsl:call-template name="namespace"/>
                            <sqf:description>
                                <xsl:apply-templates select="sqf:description/sqf:p | sqf:description/sqf:title"/>
                            </sqf:description>
                            <xsl:apply-templates select="sqf:user-entry" mode="copy">
                                <xsl:with-param name="messageId" select="$messageId"/>
                            </xsl:apply-templates>
                            <sqf:sheet>
                                <xsl:apply-templates select="sqf:*">
                                    <xsl:with-param name="messageId" select="$messageId"/>
                                </xsl:apply-templates>
                            </sqf:sheet>
                        </sqf:fix>
                    </axsl:if>
                </axsl:if>
            </xsl:for-each>
        </xsl:if>
    </xsl:template>
    <!--
		top level elements in manipulator
		(functions, variables, keys, output element, copy templates)
	-->
    <xsl:template name="topLevelManipulatorExtension">
        <xsl:if test="$sqf:useSQF">
            <sqf:topLevel>
                <xsl:attribute name="schema" select="/sch:schema/@es:uri"/>
                <axsl:attribute name="instance" select="document-uri(/)"/>
                <bxsl:stylesheet version="2.0">
                    <xsl:apply-templates select="/sch:schema/es:default-namespace"/>
                    <bxsl:include href="{resolve-uri('escali_compiler_0_functions.xsl')}"/>
                    <xsl:choose>
                        <xsl:when test="$es:type-available">
                            <bxsl:param name="xsm:xml-save-mode" select="true()" as="xs:boolean"/>
                            <bxsl:variable name="xsm:xml-save-mode-bool" select="$xsm:xml-save-mode" as="xs:boolean"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <bxsl:param name="xsm:xml-save-mode" select="'true'"/>
                            <bxsl:variable name="xsm:xml-save-mode-bool" select="$xsm:xml-save-mode = 'true'" as="xs:boolean"/>
                        </xsl:otherwise>
                    </xsl:choose>
                    <bxsl:template match="/">
                        <bxsl:choose>
                            <bxsl:when test="$xsm:xml-save-mode-bool">
                                <xsm:manipulator>
                                    <axsl:attribute name="document" select="document-uri(/)"/>
                                    <bxsl:apply-templates select="node()">
                                        <bxsl:with-param name="xsm:xml-save-mode" select="true()" as="xs:boolean" tunnel="yes"/>
                                    </bxsl:apply-templates>
                                </xsm:manipulator>
                            </bxsl:when>
                            <bxsl:otherwise>
                                <bxsl:apply-templates select="node()">
                                    <bxsl:with-param name="xsm:xml-save-mode" select="false()" as="xs:boolean" tunnel="yes"/>
                                </bxsl:apply-templates>
                            </bxsl:otherwise>
                        </bxsl:choose>
                    </bxsl:template>
                    <xsl:apply-templates select="sch:let|*[namespace-uri()='http://www.w3.org/1999/XSL/Transform']" mode="topLevelResult"/>
                    <bxsl:output method="xml"/>
                    <bxsl:key name="sqf:nodesById" match="node()" use="generate-id()"/>
                    <bxsl:template match="node()|@*" priority="-2" mode="addAtt addChild addLastChild"/>
                    <bxsl:template match="node() | @*" priority="-3" mode="#all">
                        <bxsl:param name="xsm:xml-save-mode" tunnel="yes" select="false()" as="xs:boolean"/>
                        <bxsl:choose>
                            <bxsl:when test="$xsm:xml-save-mode">
                                <bxsl:apply-templates select="node() | @*"/>
                            </bxsl:when>
                            <bxsl:otherwise>
                                <bxsl:copy>
                                    <bxsl:apply-templates select="node() | @*"/>
                                </bxsl:copy>
                            </bxsl:otherwise>
                        </bxsl:choose>
                    </bxsl:template>
                </bxsl:stylesheet>
            </sqf:topLevel>
        </xsl:if>
    </xsl:template>
    <xsl:template match="sch:let" mode="topLevelResult">
        <bxsl:variable name="{@name}" select="{@value}">
            <xsl:call-template name="namespace"/>
            <xsl:apply-templates mode="#current"/>
        </bxsl:variable>
    </xsl:template>
    <xsl:template match="*[namespace-uri()='http://www.w3.org/1999/XSL/Transform']" mode="topLevelResult">
        <xsl:element name="axsl:{local-name()}">
            <xsl:call-template name="namespace"/>
            <xsl:copy-of select="@*"/>
            <xsl:apply-templates mode="#current"/>
        </xsl:element>
    </xsl:template>
    <xsl:template match="*" mode="topLevelResult">
        <xsl:copy>
            <xsl:call-template name="namespace"/>
            <xsl:copy-of select="@*"/>
            <xsl:apply-templates mode="#current"/>
        </xsl:copy>
    </xsl:template>





    <!--
	A C T I V I T Y   E L E M E N T S
-->

    <xsl:template match="sqf:delete|sqf:replace|sqf:stringReplace" priority="10">
        <xsl:param name="messageId"/>
        <xsl:variable name="match" select="if (@match) then (@match) else ('self::node()')"/>
        <bxsl:template>
            <axsl:attribute name="match">
                <xsl:call-template name="nodeMatching">
                    <xsl:with-param name="nodes" select="$match"/>
                </xsl:call-template>
            </axsl:attribute>
            <axsl:attribute name="priority">
                <xsl:value-of select="count(following-sibling::node())+10"/>
            </axsl:attribute>
            <bxsl:param name="xsm:xml-save-mode" select="false()" as="xs:boolean" tunnel="yes"/>

            <xsl:call-template name="setVarContext">
                <xsl:with-param name="messageId" select="$messageId"/>
                <xsl:with-param name="templateBody">
                    <bxsl:choose>
                        <bxsl:when test="$xsm:xml-save-mode">
                            <xsl:apply-templates select="." mode="xsm:save-mode"/>
                        </bxsl:when>
                        <bxsl:otherwise>
                            <xsl:apply-templates select="." mode="xsm:no-xsm"/>
                        </bxsl:otherwise>
                    </bxsl:choose>
                </xsl:with-param>
            </xsl:call-template>

        </bxsl:template>
    </xsl:template>

    <xsl:template match="sqf:add">
        <xsl:param name="messageId"/>
        <bxsl:template>
            <axsl:attribute name="match">
                <xsl:call-template name="nodeMatching">
                    <xsl:with-param name="nodes" select=" if (@match) then (@match) else ('self::node()')"/>
                </xsl:call-template>
            </axsl:attribute>
            <axsl:attribute name="priority">
                <xsl:value-of select="count(following-sibling::node())+10"/>
            </axsl:attribute>
            <xsl:choose>
                <xsl:when test="@node-type='attribute'">
                    <axsl:attribute name="mode">addAtt</axsl:attribute>
                </xsl:when>
                <xsl:when test="@node-type='keep' or not(@node-type)">
                    <xsl:variable name="match" select=" if (@match) then (@match) else ('self::node()')"/>
                    <axsl:choose>
                        <axsl:when test="({$match})[1] instance of attribute()">
                            <axsl:attribute name="mode">addAtt</axsl:attribute>
                        </axsl:when>
                        <axsl:otherwise>
                            <axsl:attribute name="mode">addChild</axsl:attribute>
                        </axsl:otherwise>
                    </axsl:choose>
                </xsl:when>
                <xsl:when test="@position=('first-child') or not(@position)">
                    <axsl:attribute name="mode">addChild</axsl:attribute>
                </xsl:when>
                <xsl:when test="@position = ('last-child')">
                    <axsl:attribute name="mode">addLastChild</axsl:attribute>
                </xsl:when>
            </xsl:choose>
            <bxsl:param name="xsm:xml-save-mode" select="false()" as="xs:boolean" tunnel="yes"/>
            <xsl:choose>
                <xsl:when test="@position=('after')">
                    <bxsl:next-match/>
                    <xsl:call-template name="setVarContext">
                        <xsl:with-param name="messageId" select="$messageId"/>
                        <xsl:with-param name="templateBody">
                            <bxsl:choose>
                                <bxsl:when test="$xsm:xml-save-mode">
                                    <xsl:apply-templates select="." mode="xsm:save-mode"/>
                                </bxsl:when>
                                <bxsl:otherwise>
                                    <xsl:apply-templates select="." mode="xsm:no-xsm"/>
                                </bxsl:otherwise>
                            </bxsl:choose>
                        </xsl:with-param>
                    </xsl:call-template>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:call-template name="setVarContext">
                        <xsl:with-param name="messageId" select="$messageId"/>
                        <xsl:with-param name="templateBody">
                            <bxsl:choose>
                                <bxsl:when test="$xsm:xml-save-mode">
                                    <xsl:apply-templates select="." mode="xsm:save-mode"/>
                                </bxsl:when>
                                <bxsl:otherwise>
                                    <xsl:apply-templates select="." mode="xsm:no-xsm"/>
                                </bxsl:otherwise>
                            </bxsl:choose>
                        </xsl:with-param>
                    </xsl:call-template>
                    <bxsl:next-match/>
                </xsl:otherwise>
            </xsl:choose>
        </bxsl:template>
        <xsl:if test="@position=('first-child','last-child') or not(@position)">
            <bxsl:template>
                <axsl:variable name="match">
                    <xsl:call-template name="nodeMatching">
                        <xsl:with-param name="nodes" select=" if (@match) then (@match) else ('self::node()')"/>
                    </xsl:call-template>
                </axsl:variable>
                <axsl:attribute name="match" select="$match"/>
                <axsl:attribute name="priority">
                    <xsl:value-of select="10 - count(preceding-sibling::*)"/>
                </axsl:attribute>
                <bxsl:param name="xsm:xml-save-mode" select="false()" as="xs:boolean" tunnel="yes"/>

                <bxsl:variable name="attributes">
                    <sqf:transmitter>
                        <bxsl:apply-templates select="self::*" mode="addAtt"/>
                    </sqf:transmitter>
                </bxsl:variable>

                <bxsl:choose>
                    <bxsl:when test="$xsm:xml-save-mode">
                        <bxsl:if test="$attributes/sqf:transmitter/xsm:*">
                            <xsm:add position="before">
                                <bxsl:attribute name="node" select="es:getNodePath(.)"/>
                                <xsm:content>
                                    <bxsl:processing-instruction name="{$sqf:changePrefix}-start" sqf:changeMarker="true">
                                        <bxsl:text>attribute-change-</bxsl:text>
                                        <bxsl:value-of select="generate-id()"/>
                                    </bxsl:processing-instruction>
                                </xsm:content>
                            </xsm:add>
                            <bxsl:copy-of select="$attributes/sqf:transmitter/xsm:*"/>
                            <xsm:add position="first-child">
                                <bxsl:attribute name="node" select="es:getNodePath(.)"/>
                                <xsm:content>
                                    <bxsl:processing-instruction name="{$sqf:changePrefix}-end" sqf:changeMarker="true">
                                        <bxsl:text>attribute-change-</bxsl:text>
                                        <bxsl:value-of select="generate-id()"/>
                                    </bxsl:processing-instruction>
                                </xsm:content>
                            </xsm:add>
                        </bxsl:if>
                        <bxsl:apply-templates select="self::*" mode="addChild"/>
                        <bxsl:apply-templates select="self::*" mode="addLastChild"/>
                        <bxsl:apply-templates select="node()"/>
                    </bxsl:when>
                    <bxsl:otherwise>
                        <bxsl:variable name="newAttributes" select="$attributes/sqf:transmitter/@*"/>
                        <bxsl:if test="$newAttributes">
                            <bxsl:processing-instruction name="{$sqf:changePrefix}-start" sqf:changeMarker="true">
                                <bxsl:text>attribute-change-</bxsl:text>
                                <bxsl:value-of select="generate-id()"/>
                            </bxsl:processing-instruction>
                        </bxsl:if>
                        <bxsl:copy>
                            <bxsl:apply-templates select="@*"/>
                            <!--                    <bxsl:apply-templates select="self::*" mode="addAtt"/>-->
                            <bxsl:copy-of select="$newAttributes"/>
                            <bxsl:if test="$newAttributes">
                                <bxsl:processing-instruction name="{$sqf:changePrefix}-end" sqf:changeMarker="true">
                                    <bxsl:text>attribute-change-</bxsl:text>
                                    <bxsl:value-of select="generate-id()"/>
                                </bxsl:processing-instruction>
                            </bxsl:if>
                            <bxsl:apply-templates select="self::*" mode="addChild"/>
                            <bxsl:apply-templates select="node()"/>
                            <bxsl:apply-templates select="self::*" mode="addLastChild"/>
                        </bxsl:copy>
                    </bxsl:otherwise>
                </bxsl:choose>

            </bxsl:template>
        </xsl:if>
    </xsl:template>

    <!--
    Implementation of sqf:DELETE
-->
    <xsl:template match="sqf:delete" mode="xsm:save-mode">
        <bxsl:variable name="node" select="es:getNodePath(.)"/>
        <bxsl:choose>
            <bxsl:when test=". instance of attribute()">
                <bxsl:variable name="parent" select="es:getNodePath(..)"/>
                <xsm:add position="before">
                    <bxsl:attribute name="node" select="$parent"/>
                    <xsm:content>
                        <bxsl:processing-instruction name="{$sqf:changePrefix}-start" sqf:changeMarker="true">
                            <bxsl:text>delete-</bxsl:text>
                            <bxsl:value-of select="generate-id()"/>
                        </bxsl:processing-instruction>
                    </xsm:content>
                </xsm:add>
                <xsm:add position="first-child">
                    <bxsl:attribute name="node" select="$parent"/>
                    <xsm:content>
                        <bxsl:processing-instruction name="{$sqf:changePrefix}-end" sqf:changeMarker="true">
                            <bxsl:text>delete-</bxsl:text>
                            <bxsl:value-of select="generate-id()"/>
                        </bxsl:processing-instruction>
                    </xsm:content>
                </xsm:add>
                <xsm:delete>
                    <bxsl:attribute name="node" select="$node"/>
                </xsm:delete>
            </bxsl:when>
            <bxsl:otherwise>
                <xsm:replace>
                    <bxsl:attribute name="node" select="$node"/>
                    <xsm:content>
                        <bxsl:processing-instruction name="{$sqf:changePrefix}-start" sqf:changeMarker="true">
                            <bxsl:text>delete-</bxsl:text>
                            <bxsl:value-of select="generate-id()"/>
                        </bxsl:processing-instruction>
                        <bxsl:processing-instruction name="{$sqf:changePrefix}-end" sqf:changeMarker="true">
                            <bxsl:text>delete-</bxsl:text>
                            <bxsl:value-of select="generate-id()"/>
                        </bxsl:processing-instruction>
                    </xsm:content>
                </xsm:replace>
            </bxsl:otherwise>
        </bxsl:choose>
    </xsl:template>

    <xsl:template match="sqf:delete" mode="xsm:no-xsm">
        <bxsl:processing-instruction name="{$sqf:changePrefix}-start" sqf:changeMarker="true">
            <bxsl:text>delete-</bxsl:text>
            <bxsl:value-of select="generate-id()"/>
        </bxsl:processing-instruction>
        <bxsl:processing-instruction name="{$sqf:changePrefix}-end" sqf:changeMarker="true">
            <bxsl:text>delete-</bxsl:text>
            <bxsl:value-of select="generate-id()"/>
        </bxsl:processing-instruction>
    </xsl:template>

    <!--
        Implementation of sqf:REPLACE
    -->
    <xsl:template match="sqf:replace" mode="xsm:save-mode">
        <axsl:variable name="match">
            <xsl:call-template name="nodeMatching">
                <xsl:with-param name="nodes" select=" if (@match) then (@match) else ('self::node()')"/>
            </xsl:call-template>
        </axsl:variable>
        <axsl:variable name="nodeFac">
            <xsl:call-template name="nodeFac"/>
        </axsl:variable>
        <axsl:if test="$nodeFac/xsl:attribute">
            <bxsl:variable name="parent" select="es:getNodePath(..)"/>
            <xsm:add position="before">
                <bxsl:attribute name="node" select="$parent"/>
                <xsm:content>
                    <bxsl:processing-instruction name="{$sqf:changePrefix}-start" sqf:changeMarker="true">
                        <bxsl:text>attribute-change-</bxsl:text>
                        <bxsl:value-of select="generate-id()"/>
                    </bxsl:processing-instruction>
                </xsm:content>
            </xsm:add>
            <xsm:add position="first-child">
                <bxsl:attribute name="node" select="$parent"/>
                <xsm:content>
                    <bxsl:processing-instruction name="{$sqf:changePrefix}-end" sqf:changeMarker="true">
                        <bxsl:text>attribute-change-</bxsl:text>
                        <bxsl:value-of select="generate-id()"/>
                    </bxsl:processing-instruction>
                </xsm:content>
            </xsm:add>
        </axsl:if>
        <xsm:replace>
            <bxsl:attribute name="node" select="es:getNodePath(.)"/>
            <xsm:content>
                <axsl:copy-of select="$nodeFac"/>
            </xsm:content>
        </xsm:replace>
    </xsl:template>

    <xsl:template match="sqf:replace" mode="xsm:no-xsm">
        <xsl:call-template name="nodeFac"/>
    </xsl:template>

    <!--
        Implementation of sqf:STRINGREPLACE
    -->
    <xsl:template match="sqf:stringReplace" mode="xsm:save-mode">
        <xsm:replace>
            <bxsl:attribute name="node" select="es:getNodePath(.)"/>
            <xsm:content>
                <bxsl:analyze-string select="." regex="{@regex}">
                    <bxsl:matching-substring>
                        <bxsl:processing-instruction name="{$sqf:changePrefix}-start" sqf:changeMarker="true">
                            <bxsl:text>stringReplace-</bxsl:text>
                            <bxsl:value-of select="$activityContext/generate-id()"/>
                        </bxsl:processing-instruction>
                        <xsl:apply-templates mode="template"/>
                        <bxsl:processing-instruction name="{$sqf:changePrefix}-end" sqf:changeMarker="true">
                            <bxsl:text>stringReplace-</bxsl:text>
                            <bxsl:value-of select="$activityContext/generate-id()"/>
                        </bxsl:processing-instruction>
                    </bxsl:matching-substring>
                    <bxsl:non-matching-substring>
                        <bxsl:value-of select="."/>
                    </bxsl:non-matching-substring>
                </bxsl:analyze-string>
            </xsm:content>
        </xsm:replace>
    </xsl:template>

    <xsl:template match="sqf:stringReplace" mode="xsm:no-xsm">
        <bxsl:analyze-string select="." regex="{@regex}">
            <bxsl:matching-substring>
                <bxsl:processing-instruction name="{$sqf:changePrefix}-start" sqf:changeMarker="true">
                    <bxsl:text>stringReplace-</bxsl:text>
                    <bxsl:value-of select="$activityContext/generate-id()"/>
                </bxsl:processing-instruction>
                <xsl:apply-templates mode="template"/>
                <bxsl:processing-instruction name="{$sqf:changePrefix}-end" sqf:changeMarker="true">
                    <bxsl:text>stringReplace-</bxsl:text>
                    <bxsl:value-of select="$activityContext/generate-id()"/>
                </bxsl:processing-instruction>
            </bxsl:matching-substring>
            <bxsl:non-matching-substring>
                <bxsl:value-of select="."/>
            </bxsl:non-matching-substring>
        </bxsl:analyze-string>
    </xsl:template>

    <!--
        Implementation of sqf:ADD
    -->
    <xsl:template match="sqf:add" mode="xsm:save-mode">
        <xsm:add>
            <axsl:variable name="match">
                <xsl:call-template name="nodeMatching">
                    <xsl:with-param name="nodes" select=" if (@match) then (@match) else ('self::node()')"/>
                </xsl:call-template>
            </axsl:variable>
            <axsl:variable name="position" select="'{@position}'"/>
            <axsl:variable name="node-type" select="'{@node-type}'"/>
            <axsl:attribute name="position" select="if ($position='') 
                then (
                if ($node-type='attribute') 
                then ('attribute') 
                else if ($node-type=('keep','') and (($match)[1] instance of attribute())) 
                then ('attribute') 
                else ('first-child')) 
                else ($position)"> </axsl:attribute>
            <bxsl:attribute name="node" select="es:getNodePath(.)"/>
            <xsm:content>
                <xsl:call-template name="nodeFac"/>
            </xsm:content>
        </xsm:add>
    </xsl:template>

    <xsl:template match="sqf:add" mode="xsm:no-xsm">
        <xsl:call-template name="nodeFac"/>
    </xsl:template>




    <!--   
    Content of activity elements
-->
    <xsl:template match="sqf:fix//node()" mode="template">
        <xsl:copy>
            <xsl:apply-templates select="@*" mode="template"/>
            <xsl:apply-templates select="node()" mode="template"/>
        </xsl:copy>
    </xsl:template>
    <xsl:template match="sqf:fix//@*" priority="10" mode="template">
        <axsl:attribute name="{name()}">
            <xsl:value-of select="."/>
        </axsl:attribute>
    </xsl:template>
    <xsl:template match="sqf:fix//xsl:*" priority="10" mode="template">
        <xsl:element name="axsl:{local-name()}">
            <xsl:apply-templates select="@*" mode="template"/>
            <xsl:apply-templates select="node()" mode="template"/>
        </xsl:element>
    </xsl:template>
    <xsl:template match="sqf:fix//sch:value-of" priority="10" mode="template">
        <bxsl:value-of select="{@select}">
            <xsl:call-template name="namespace"/>
        </bxsl:value-of>
    </xsl:template>
    <xsl:template match="sqf:fix//sch:let" priority="10" mode="template">
        <bxsl:variable name="{@name}" select="{@value}">
            <xsl:call-template name="namespace"/>
            <xsl:apply-templates select="node()" mode="template"/>
        </bxsl:variable>
    </xsl:template>
    <!--
	O T H E R   S Q F   E L E M E N T S
-->
    <!--
        Implementation of sqf:KEEP
    -->
    <xsl:template match="sqf:keep" mode="#all" priority="10">
        <bxsl:apply-templates select="{if (@select) 
                                     then (@select) 
                                     else ('node()')}">
            <bxsl:with-param name="xsm:xml-save-mode" select="false()" as="xs:boolean" tunnel="yes"/>
        </bxsl:apply-templates>
    </xsl:template>
    <!--
	Implementation of sqf:PARAM
-->
    <xsl:template match="sqf:param[not(@user-entry='yes')]">
        <axsl:variable>
            <xsl:copy-of select="@*|node()"/>
        </axsl:variable>
    </xsl:template>
    <xsl:template match="sqf:param[@user-entry='yes']">
        <xsl:param name="messageId" required="yes"/>
        <bxsl:param>
            <xsl:copy-of select="@* except (@user-entry, @name)"/>
            <xsl:attribute name="name">
                <xsl:text>sqf:</xsl:text>
                <xsl:value-of select="generate-id()"/>
                <xsl:text>_</xsl:text>
                <xsl:value-of select="$messageId"/>
                <xsl:text>_{generate-id()}</xsl:text>
            </xsl:attribute>

            <xsl:apply-templates select="node()" mode="template"/>
        </bxsl:param>
    </xsl:template>
    <xsl:template match="sqf:user-entry" mode="copy" priority="101">
        <xsl:param name="messageId" required="yes"/>
        <xsl:copy>
            <xsl:copy-of select="@* except @ref"/>
            <xsl:call-template name="namespace"/>
            <xsl:apply-templates mode="#current"/>
            <sqf:param name="sqf:{generate-id()}">
                <xsl:variable name="ref-param" select="ancestor::sqf:fix/sqf:param[@name=current()/@ref]"/>
                <xsl:copy-of select="$ref-param/@*[not(name()=('select','user-entry'))]"/>
                <xsl:attribute name="param-id">
                    <!--                    <xsl:text>sqf:</xsl:text>-->
                    <xsl:value-of select="$ref-param/generate-id()"/>
                    <xsl:text>_</xsl:text>
                    <xsl:value-of select="$messageId"/>
                    <xsl:text>_{generate-id()}</xsl:text>
                </xsl:attribute>
                <xsl:call-template name="defaultAsString">
                    <xsl:with-param name="ref-param" select="$ref-param"/>
                </xsl:call-template>
            </sqf:param>
        </xsl:copy>
    </xsl:template>

    <xsl:template name="defaultAsString">
        <xsl:param name="ref-param" as="element(sqf:param)"/>
        <xsl:choose>
            <xsl:when test="$ref-param/@select">
                <axsl:value-of select="{$ref-param/@select}"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:apply-templates select="$ref-param/node()"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <!--
        Implementation of sqf:USER-ENTRY
    -->
    <xsl:template match="sqf:user-entry//*" mode="copy">
        <xsl:copy>
            <xsl:copy-of select="@*"/>
            <xsl:call-template name="namespace"/>
            <xsl:apply-templates mode="#current"/>
        </xsl:copy>
    </xsl:template>
    <!--
        Implementation of sqf:description
    -->
    <xsl:template match="sqf:description/sqf:p" mode="#all" priority="100">
        <svrl:text>
            <xsl:apply-templates/>
        </svrl:text>
    </xsl:template>
    <xsl:template match="sqf:description/sqf:title" mode="#all" priority="100">
        <sqf:title>
            <xsl:apply-templates/>
        </sqf:title>
    </xsl:template>
    <xsl:template match="sqf:description"/>


    <xsl:template match="sqf:*"/>

    <!--<xsl:template match="sqf:fix//*[namespace-uri()='http://www.w3.org/1999/XSL/Transform']">
        <xsl:element name="axsl:{local-name()}">
            <xsl:copy-of select="@*"/>
            <xsl:call-template name="namespace"/>
            <xsl:apply-templates/>
        </xsl:element>
    </xsl:template>-->



    <!--
	V A R I A B L E S   C O N T E X T
-->
    <!--
	create xsl:for-each loops into the manipulator
	to create the context of variables
	
	First loop: set the $ruleContext
	   - context of the sch:rule, for variabels inside of the Schematron rule.
    Second loop: set the $activityContext
        - Context of the activity elements (sqf:add, sqf:replace, ...)
        - for variables inside of the activity elements
-->
    <xsl:template name="setVarContext">
        <xsl:param name="messageId" as="xs:string"/>
        <xsl:param name="templateBody" as="node()*"/>
        <xsl:variable name="activityElement" select="."/>
        <xsl:variable name="fix" select="parent::sqf:fix"/>
        <xsl:variable name="fixOrGroup" select=" if ($fix/parent::sqf:group) 
                                        then ($fix/parent::sqf:group) 
                                        else ($fix)"/>
        <xsl:variable name="rule" select="$fixOrGroup/parent::sch:rule" as="element(sch:rule)"/>

        <bxsl:variable name="ruleContext">
            <axsl:attribute name="select">
                <xsl:call-template name="nodeMatching">
                    <xsl:with-param name="nodes" select="'self::node()'"/>
                </xsl:call-template>
            </axsl:attribute>
        </bxsl:variable>
        <bxsl:variable name="activityContext">
            <axsl:attribute name="select">self::node()</axsl:attribute>
        </bxsl:variable>
        <xsl:for-each select="$fix/sqf:param[@user-entry='yes']">
            <bxsl:variable name="{@name}">
                <xsl:attribute name="select">
                    <xsl:text>$sqf:</xsl:text>
                    <xsl:value-of select="generate-id()"/>
                    <xsl:text>_</xsl:text>
                    <xsl:value-of select="$messageId"/>
                    <xsl:text>_{generate-id()}</xsl:text>
                </xsl:attribute>
            </bxsl:variable>
        </xsl:for-each>
        <bxsl:for-each select="$ruleContext">
            <xsl:variable name="ruleLevelVars" select="$fixOrGroup/preceding-sibling::* intersect ($rule/sch:let, $rule/xsl:variable)"/>
            <xsl:variable name="fixLevelVars" select="$activityElement/preceding-sibling::* intersect ($fix/sqf:param, $fix/sch:let, $fix/xsl:variable)"/>
            <xsl:for-each select="$ruleLevelVars, $fixLevelVars">
                <xsl:choose>
                    <xsl:when test="self::sqf:param[@user-entry='yes'] ">
                        <bxsl:variable name="{@name}">
                            <xsl:attribute name="select">
                                <xsl:text>$sqf:</xsl:text>
                                <xsl:value-of select="generate-id()"/>
                                <xsl:text>_</xsl:text>
                                <xsl:value-of select="$messageId"/>
                                <xsl:text>_{generate-id()}</xsl:text>
                            </xsl:attribute>
                        </bxsl:variable>
                    </xsl:when>
                    <xsl:otherwise>
                        <bxsl:variable name="{@name}">
                            <xsl:if test="@value|@select">
                                <axsl:attribute name="select">
                                    <xsl:value-of select="replace(@value|@select,'current\(\)','\$ruleContext')"/>
                                </axsl:attribute>
                            </xsl:if>
                            <xsl:copy-of select="node()"/>
                        </bxsl:variable>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:for-each>

            <!--<xsl:for-each select="ancestor::sqf:fix/sqf:param[not(@user-entry='yes')]          |ancestor::sch:rule/sch:let          |ancestor::sqf:*/sch:let          |ancestor::sch:rule/xsl:variable          |ancestor::sqf:*/xsl:variable">
                <bxsl:variable name="{@name}">
                    <xsl:if test="@value|@select">
                        <axsl:attribute name="select">
                            <xsl:value-of select="replace(@value|@select,'current\(\)','\$ruleContext')"/>
                        </axsl:attribute>
                    </xsl:if>
                    <xsl:copy-of select="node()"/>
                </bxsl:variable>
            </xsl:for-each>-->
            <bxsl:for-each select="$activityContext">
                <xsl:for-each select="sch:let">
                    <bxsl:variable name="{@name}" select="{@value}"/>
                </xsl:for-each>
                <xsl:copy-of select="$templateBody"/>
            </bxsl:for-each>
        </bxsl:for-each>
    </xsl:template>
    <!--
	M A T C H - G E N E R A T O R
-->
    <!--
    Creates in validator an absolute xpath expression
    which matches on the node(s) of $nodes
-->
    <!--<xsl:template name="nodeMatching">
        <xsl:param name="nodes" select="'self::node()'"/>
        <axsl:if test="({$nodes})[. instance of attribute()] and ({$nodes})[not(. instance of attribute())]">
            <axsl:message terminate="yes">mixing attribute nodes and non attribute nodes are not implementated yet!</axsl:message>
        </axsl:if>
        <axsl:value-of select=" if (({$nodes})[1] instance of attribute())              then ('@')              else ()"/>
        <xsl:text>node()[generate-id(.)=('</xsl:text>
        <axsl:value-of select="string-join(for $node              in {$nodes}              return generate-id($node),             $sqf_string)"/>
        <xsl:text>')]</xsl:text>
    </xsl:template>-->
    <xsl:template name="nodeMatching">
        <xsl:param name="nodes" select="'self::node()'"/>
        <axsl:value-of select="string-join(for $n in {$nodes} return es:getNodePath($n), ' | ')" separator=" | "/>
    </xsl:template>
    <!-- 
	N O D E - F A C T O R Y
-->
    <!--
    Creates a new node in the manipulator
-->
    <xsl:template name="nodeFac">
        <xsl:choose>
            <xsl:when test="@node-type='element'">
                <xsl:call-template name="elementFac"/>
            </xsl:when>
            <xsl:when test="@node-type='attribute'">
                <xsl:call-template name="attributeFac"/>
            </xsl:when>
            <xsl:when test="@node-type='comment'">
                <xsl:call-template name="commentFac"/>
            </xsl:when>
            <xsl:when test="@node-type=('pi','processing-instruction')">
                <xsl:call-template name="piFac"/>
            </xsl:when>
            <xsl:when test="@node-type='none'">
                <bxsl:processing-instruction name="{$sqf:changePrefix}-start" sqf:changeMarker="true">
                    <bxsl:text>
                        <xsl:value-of select="local-name()"/>
                        <xsl:text>-</xsl:text>
                    </bxsl:text>
                    <bxsl:value-of select="generate-id()"/>
                </bxsl:processing-instruction>
                <xsl:choose>
                    <xsl:when test="@select">
                        <bxsl:apply-templates select="{@select}">
                            <bxsl:with-param name="xsm:xml-save-mode" select="false()" as="xs:boolean" tunnel="yes"/>
                        </bxsl:apply-templates>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:apply-templates mode="template"/>
                    </xsl:otherwise>
                </xsl:choose>
                <bxsl:processing-instruction name="{$sqf:changePrefix}-end" sqf:changeMarker="true">
                    <bxsl:text>
                        <xsl:value-of select="local-name()"/>
                        <xsl:text>-</xsl:text>
                    </bxsl:text>
                    <bxsl:value-of select="generate-id()"/>
                </bxsl:processing-instruction>
            </xsl:when>
            <xsl:when test="@node-type='keep' or not(@node-type)">
                <xsl:variable name="match" select=" if (@match) then (@match) else ('self::node()')"/>
                <axsl:choose>
                    <axsl:when test="({$match})[1] instance of element()">
                        <xsl:call-template name="elementFac"/>
                    </axsl:when>
                    <axsl:when test="({$match})[1] instance of attribute()">
                        <xsl:call-template name="attributeFac"/>
                    </axsl:when>
                    <axsl:when test="({$match})[1] instance of comment()">
                        <xsl:call-template name="commentFac"/>
                    </axsl:when>
                    <axsl:when test="({$match})[1] instance of processing-instruction()">
                        <xsl:call-template name="piFac"/>
                    </axsl:when>
                    <axsl:otherwise>
                        <axsl:message>unexpected node art</axsl:message>
                    </axsl:otherwise>
                </axsl:choose>
            </xsl:when>
            <xsl:otherwise>
                <xsl:message>unexpected node art</xsl:message>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    <!--
        Creates a new element in the manipulator
	-->
    <xsl:template name="elementFac">
        <bxsl:processing-instruction name="{$sqf:changePrefix}-start" sqf:changeMarker="true">
            <bxsl:text>
                <xsl:value-of select="local-name()"/>
                <xsl:text>-</xsl:text>
            </bxsl:text>
            <bxsl:value-of select="generate-id()"/>
        </bxsl:processing-instruction>
        <bxsl:element>
            <axsl:attribute name="name">
                <xsl:value-of select="@target"/>
            </axsl:attribute>
            <xsl:choose>
                <xsl:when test="@select">
                    <bxsl:choose>
                        <bxsl:when test="({@select})[1] instance of node()">
                            <bxsl:apply-templates select="{@select}">
                                <bxsl:with-param name="xsm:xml-save-mode" select="false()" as="xs:boolean" tunnel="yes"/>
                            </bxsl:apply-templates>
                        </bxsl:when>
                        <bxsl:otherwise>
                            <bxsl:value-of select="{@select}"/>
                        </bxsl:otherwise>
                    </bxsl:choose>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:apply-templates mode="template"/>
                </xsl:otherwise>
            </xsl:choose>
        </bxsl:element>
        <bxsl:processing-instruction name="{$sqf:changePrefix}-end" sqf:changeMarker="true">
            <bxsl:text>
                <xsl:value-of select="local-name()"/>
                <xsl:text>-</xsl:text>
            </bxsl:text>
            <bxsl:value-of select="generate-id()"/>
        </bxsl:processing-instruction>
    </xsl:template>
    <!--
        Creates a new attribute in the manipulator
	-->
    <xsl:template name="attributeFac">
        <bxsl:attribute>
            <axsl:attribute name="name">
                <xsl:value-of select="@target"/>
            </axsl:attribute>
            <xsl:apply-templates select="node()|@select" mode="template"/>
        </bxsl:attribute>
        <!--<bxsl:attribute name="{$sqf:changePrefix}:attribute-change-no{count(preceding-sibling::sqf:*)}" namespace="http://www.schematron-quickfix.com/validator/process/changes" sqf:changeMarker="true">
            <xsl:value-of select="@target"/>
        </bxsl:attribute>-->
    </xsl:template>
    <!--
        Creates a new comment in the manipulator
	-->
    <xsl:template name="commentFac">
        <bxsl:processing-instruction name="{$sqf:changePrefix}-start" sqf:changeMarker="true">
            <bxsl:text>
                <xsl:value-of select="local-name()"/>
                <xsl:text>-</xsl:text>
            </bxsl:text>
            <bxsl:value-of select="generate-id()"/>
        </bxsl:processing-instruction>
        <bxsl:comment>
            <xsl:choose>
                <xsl:when test="@select">
                    <bxsl:apply-templates select="{@select}">
                        <bxsl:with-param name="xsm:xml-save-mode" select="false()" as="xs:boolean" tunnel="yes"/>
                    </bxsl:apply-templates>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:apply-templates mode="template"/>
                </xsl:otherwise>
            </xsl:choose>
        </bxsl:comment>
        <bxsl:processing-instruction name="{$sqf:changePrefix}-end" sqf:changeMarker="true">
            <bxsl:text>
                <xsl:value-of select="local-name()"/>
                <xsl:text>-</xsl:text>
            </bxsl:text>
            <bxsl:value-of select="generate-id()"/>
        </bxsl:processing-instruction>
    </xsl:template>
    <!--
        Creates a new pi in the manipulator
	-->
    <xsl:template name="piFac">
        <bxsl:processing-instruction name="{$sqf:changePrefix}-start" sqf:changeMarker="true">
            <bxsl:text>
                <xsl:value-of select="local-name()"/>
                <xsl:text>-</xsl:text>
            </bxsl:text>
            <bxsl:value-of select="generate-id()"/>
        </bxsl:processing-instruction>
        <bxsl:processing-instruction>
            <axsl:attribute name="name">
                <xsl:value-of select="@target"/>
            </axsl:attribute>
            <xsl:choose>
                <xsl:when test="@select">
                    <bxsl:apply-templates select="{@select}">
                        <bxsl:with-param name="xsm:xml-save-mode" select="false()" as="xs:boolean" tunnel="yes"/>
                    </bxsl:apply-templates>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:apply-templates mode="template"/>
                </xsl:otherwise>
            </xsl:choose>
        </bxsl:processing-instruction>
        <bxsl:processing-instruction name="{$sqf:changePrefix}-end" sqf:changeMarker="true">
            <bxsl:text>
                <xsl:value-of select="local-name()"/>
                <xsl:text>-</xsl:text>
            </bxsl:text>
            <bxsl:value-of select="generate-id()"/>
        </bxsl:processing-instruction>
    </xsl:template>
</xsl:stylesheet>
