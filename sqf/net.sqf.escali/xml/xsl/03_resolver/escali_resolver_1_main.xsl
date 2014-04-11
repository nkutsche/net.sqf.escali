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
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:sqfc="http://www.schematron-quickfix.com/validator/process/changes" xmlns:sqf="http://www.schematron-quickfix.com/validator/process" xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl" xmlns:svrl="http://purl.oclc.org/dsdl/svrl" exclude-result-prefixes="xs xd" version="2.0">
    
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
    
    <xsl:include href="escali_resolver_1_get-record.xsl"/>
    
    <xsl:param name="id" as="xs:string+" select="''"/>
    <xsl:param name="inputRecord" as="xs:string" select="''"/>
    <xsl:param name="outputRecord" as="xs:string" select="''"/>
    <xsl:param name="additionalTypes" select="()"/>
    <xsl:param name="markChanges" as="xs:boolean" select="true()"/>
    
    <!--	<xsl:param name="fixId" select="('replace')"/>-->
    <!--<xsl:param name="contextId"/>
	<xsl:param name="fixId"/>-->
    <xsl:variable name="idSeq" select="for $i in $id return tokenize($i,'\s')"/>
    <xsl:variable name="namespaceAlias" select="//sqf:topLevel/xsl:stylesheet/xsl:namespace-alias[@result-prefix='sqf']/@stylesheet-prefix"/>
    <xsl:variable name="selectedFix" select="//sqf:fix[@id=$idSeq]"/>
    <xsl:template match="svrl:schematron-output">
        <xsl:apply-templates select="//sqf:topLevel/xsl:stylesheet"/>
        <xsl:if test="$outputRecord!=''">
            <xsl:call-template name="getRecord"/>
        </xsl:if>
    </xsl:template>
    <xsl:template match="xsl:stylesheet">
        <xsl:copy>
            <xsl:variable name="namespaces" select="./namespace::*"/>
            <xsl:copy-of select="$namespaces"/>
            <xsl:attribute name="exclude-result-prefixes" select="concat(string-join($namespaces/name(),' '),' xsl')"/>
            <xsl:copy-of select="node()|@*"/>
            <!--            -->
            <xsl:apply-templates select="$selectedFix"/>
        </xsl:copy>
    </xsl:template>
    <xsl:template match="sqf:fix">
        <xsl:apply-templates select=".//sqf:sheet/node()"/>
    </xsl:template>

    <xsl:template match="xsl:param[@as=$additionalTypes]">
        <xsl:next-match/>
        <xsl:if test="starts-with(@as,'xs:')">
            <xsl:element name="xsl:variable">
                <xsl:attribute name="name" select="@name"/>
                <xsl:attribute name="select" select="concat(@as,'($',@name,')')"/>
            </xsl:element>
        </xsl:if>
    </xsl:template>

    <xsl:template match="xsl:param/@as">
        <xsl:attribute name="as">
            <xsl:choose>
                <xsl:when test=". = $additionalTypes">
                    <xsl:text>xs:string</xsl:text>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="."/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:attribute>
    </xsl:template>

    <!--  
        for sqf namespace alias  
    -->
    <xsl:template match="xsl:attribute/@name|xsl:element/@name">
        <xsl:variable name="namespaceAlias" select="string-join($namespaceAlias,'|')"/>
        <xsl:attribute name="{name()}">
            <xsl:call-template name="aliasReplace"/>
        </xsl:attribute>
    </xsl:template>
    <xsl:template match="xsl:attribute[matches(@name,'sqfc:attribute.*')]">
        <xsl:copy>
            <xsl:copy-of select="@*"/>
            <xsl:call-template name="aliasReplace"/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="*[@sqf:changeMarker='true'] | @sqfc:*" priority="100">
        <xsl:if test="$markChanges">
            <xsl:next-match/>
        </xsl:if>
    </xsl:template>
    
    <xsl:template match="@sqf:changeMarker" priority="100"/>
    
    
    
    <xsl:template name="aliasReplace">
        <xsl:analyze-string select="." regex="^({$namespaceAlias}):">
            <xsl:matching-substring>sqf:</xsl:matching-substring>
            <xsl:non-matching-substring>
                <xsl:value-of select="."/>
            </xsl:non-matching-substring>
        </xsl:analyze-string>
    </xsl:template>
    <!--
        Kopiert alle Knoten
    -->
    <xsl:template match="node() | @*" mode="#all">
        <xsl:copy>
            <xsl:apply-templates select="@*" mode="#current"/>
            <xsl:apply-templates select="node()" mode="#current"/>
        </xsl:copy>
    </xsl:template>
</xsl:stylesheet>
