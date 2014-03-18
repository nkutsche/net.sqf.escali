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
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl" xmlns:sqfc="http://www.schematron-quickfix.com/validator/process/changes" exclude-result-prefixes="xs sqfc" version="2.0">
    
    
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
    
    
    <xsl:output method="xml"/>
    <!-- 
        copies all nodes:
    -->
    <xsl:template match="node() | @*" mode="#all">
        <xsl:copy copy-namespaces="no">
            <xsl:call-template name="copyNamespaces"/>
            <xsl:apply-templates select="@*"/>
            <xsl:apply-templates select="node()"/>
        </xsl:copy>
    </xsl:template>

    <!-- 
        copies all nodes:
    -->
    <xsl:template match="*[@sqfc:*]" mode="#all">
        <xsl:variable name="firstChangeAttr" select="@sqfc:*[1]"/>
        <xsl:variable name="changePrefix" select="prefix-from-QName(QName( namespace-uri($firstChangeAttr), name($firstChangeAttr)))"/>
        <xsl:processing-instruction name="{$changePrefix}-start">attribute-change</xsl:processing-instruction>
        <xsl:copy copy-namespaces="no">
            <xsl:call-template name="copyNamespaces"/>
            <xsl:apply-templates select="@* except @sqfc:*"/>
            <xsl:processing-instruction name="{$changePrefix}-end">attribute-change</xsl:processing-instruction>
            <xsl:apply-templates select="node()"/>
        </xsl:copy>
    </xsl:template>

    <xsl:template name="copyNamespaces">
        <xsl:for-each select="reverse(namespace::*)">
            <xsl:if test=". != 'http://www.schematron-quickfix.com/validator/process/changes'">
                <xsl:namespace name="{name()}">
                    <xsl:value-of select="."/>
                </xsl:namespace>
            </xsl:if>
        </xsl:for-each>
    </xsl:template>


</xsl:stylesheet>
