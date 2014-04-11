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
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:es="http://www.escali.schematron-quickfix.com/"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl" xmlns:sqf="http://www.schematron-quickfix.com/validator/process"
    exclude-result-prefixes="xs xd"
    version="2.0">
    
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
	S Q F - E X T E N S I O N S
-->
    <xsl:key name="sqfLangnodesByLang" match="sqf:p" use="(es:getLang(.), '#ALL')"/>
    <xsl:key name="sqfSelectedNodesById" match="key('sqfLangnodesByLang', $lang)" use="generate-id()"/>
    
    
    <xsl:template match="sqf:p" priority="100">
        <xsl:choose>
            <xsl:when test="key('sqfSelectedNodesById', generate-id())">
                <xsl:next-match/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:comment>Deleted because selected language <xsl:value-of select="$lang"/> != <xsl:value-of select="es:getLang(.)"/>.</xsl:comment>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <!--
	sqf:call-fix
-->
    <xsl:template match="sqf:call-fix">
        <xsl:variable name="idref" select="@ref"/>
        <xsl:apply-templates select="ancestor::*/sqf:fix[@id=$idref]" mode="callFix">
            <xsl:with-param name="params" select="sqf:with-param" tunnel="yes"/>
        </xsl:apply-templates>
    </xsl:template>
    <xsl:template match="sqf:fix/sqf:param" priority="100" mode="#all">
        <xsl:param name="params" select="()" tunnel="yes"/>
        <xsl:variable name="overlayedParam" select="$params[@name=current()/@name]"/>
        <xsl:copy>
            <xsl:apply-templates select="@name | @user-entry"/>
            <xsl:if test="$es:type-available != 'false'">
                <xsl:apply-templates select="@as"/>
            </xsl:if>
            <xsl:choose>
                <xsl:when test="normalize-space($overlayedParam)!='' or $overlayedParam/@select">
                    <xsl:apply-templates select="$overlayedParam/@select | $overlayedParam/node()"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:copy-of select="@select"/>
                    <xsl:apply-templates/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="sqf:fix" mode="callFix" priority="100">
        <xsl:apply-templates select="node()" mode="#current"/>
    </xsl:template>
    <xsl:template match="sqf:description" mode="callFix" priority="100"/>
</xsl:stylesheet>