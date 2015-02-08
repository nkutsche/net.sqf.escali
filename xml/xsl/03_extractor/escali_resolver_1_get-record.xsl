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
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:sqf="http://www.schematron-quickfix.com/validator/process" xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl" xmlns:svrl="http://purl.oclc.org/dsdl/svrl" exclude-result-prefixes="xd" version="2.0" xpath-default-namespace="http://purl.oclc.org/dsdl/svrl">
    
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
    
    <xsl:template name="getRecord">
        <xsl:choose>
            <xsl:when test="doc-available($inputRecord) and $inputRecord!=''">
                <xsl:result-document href="{$outputRecord}">
                    <xsl:apply-templates select="doc($inputRecord)" mode="resultSVRL"/>
                </xsl:result-document>
            </xsl:when>
            <xsl:otherwise>
                <xsl:result-document href="{$outputRecord}">
                    <xsl:call-template name="newResultSVRL">
                        <xsl:with-param name="oldRecord" select="true()"/>
                    </xsl:call-template>
                </xsl:result-document>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template match="svrl:schematron-output" name="newResultSVRL" mode="resultSVRL">
        <xsl:param name="oldRecord" select="false()"/>
        <xsl:copy>
            <xsl:apply-templates select="@*" mode="resultSVRL"/>
            <xsl:if test="not($oldRecord)">
                <xsl:copy-of select="node()"/>
            </xsl:if>
            <svrl:step input="{$inputRecord}" output="{$outputRecord}">
                <xsl:for-each select="$selectedFix">
                    <xsl:variable name="fix" select="."/>
                    <xsl:for-each select="parent::*">
                        <xsl:copy>
                            <xsl:copy-of select="@*"/>
                            <xsl:copy-of select="node() except sqf:fix"/>
                            <xsl:copy-of select="$fix"/>
                        </xsl:copy>
                    </xsl:for-each>
                </xsl:for-each>
            </svrl:step>
        </xsl:copy>
    </xsl:template>




</xsl:stylesheet>
