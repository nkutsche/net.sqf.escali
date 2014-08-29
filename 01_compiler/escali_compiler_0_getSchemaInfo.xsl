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
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:es="http://www.escali.schematron-quickfix.com/" xmlns:sch="http://purl.oclc.org/dsdl/schematron" xmlns:sqf="http://www.schematron-quickfix.com/validator/process" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl" exclude-result-prefixes="xs xd sqf" version="2.0">

    <xd:doc scope="stylesheet">
        <xd:desc>
            <xd:p><xd:b>Created on:</xd:b> Aug 08, 2014</xd:p>
            <xd:p><xd:b>Author:</xd:b> Nico Kutscherauer</xd:p>
        </xd:desc>
    </xd:doc>

    <xd:doc scope="version">
        <xd:desc>
            <xd:p>Version information</xd:p>
            <xd:ul>
                <xd:li>
                    <xd:p>2014-08-08</xd:p>
                    <xd:ul>
                        <xd:li>
                            <xd:p>first draft</xd:p>
                        </xd:li>
                    </xd:ul>
                </xd:li>
            </xd:ul>
        </xd:desc>
    </xd:doc>
    
    
    <!--
    returns the language value of a node
    it respects the inherited languages of the ancesors
    -->
    <xsl:function name="es:getLang" as="xs:string">
        <xsl:param name="node" as="node()"/>
        <xsl:variable name="lang" select="($node/ancestor-or-self::*/@xml:lang)[last()]"/>
        <xsl:value-of select="if ($lang) then ($lang) else ('#NULL')"/>
    </xsl:function>
    
    <xsl:key name="xmlLangNodes" match="sch:diagnostic | sch:assert/node() | sch:report/node() | sch:p | sqf:p" use="'xml-lang'"/>
    
    
    <xsl:template match="/">
        <xsl:variable name="includes" select="/schema/(sch:include|es:import|xsl:include)"/>
        <es:schemaInfo>
            <es:meta>
                <es:schema>
                    <xsl:attribute name="uri" select="document-uri(/)"/>
                    <xsl:if test="$includes">
                        <es:includes>
                            <xsl:apply-templates select="$includes" mode="meta"/>
                        </es:includes>
                    </xsl:if>
                </es:schema>
            </es:meta>
            <es:phases>
                <xsl:attribute name="default" select=" if (/sch:schema/@defaultPhase) then (/sch:schema/@defaultPhase) else ('#ALL')"/>
                <es:phase id="#ALL"/>
                <xsl:for-each select="/sch:schema/sch:phase">
                    <es:phase id="{@id}"/>
                </xsl:for-each>
                <xsl:apply-templates select="/sch:schema/es:import"/>
            </es:phases>
            <es:languages>
                <xsl:variable name="langs" as="element(es:lang)*">
                    <xsl:for-each-group select="key('xmlLangNodes', 'xml-lang')" group-by="es:getLang(.)">
                        <es:lang code="{current-grouping-key()}"/>
                    </xsl:for-each-group> 
                    <xsl:if test="$includes">
                        <xsl:apply-templates select="$includes" mode="lang"/>
                    </xsl:if>
                </xsl:variable>
                <xsl:variable name="defaultValue" select="    if (count($langs) = 1) 
                                                            then ($langs/@code) 
                                                         else if (/sch:schema/@xml:lang) 
                                                            then (/sch:schema/@xml:lang) 
                                                            else ('#ALL')"/>
                <xsl:attribute name="default" select="$defaultValue"/>
                <es:lang code="#ALL"/>
                <xsl:copy-of select="$langs"/>
            </es:languages>
        </es:schemaInfo>
    </xsl:template>

    <xsl:template match="sch:include|es:import|xsl:include" mode="meta">
        <xsl:variable name="abs-uri" select="resolve-uri(@href, document-uri(/))"/>
        <es:include>
            <xsl:attribute name="uri" select="$abs-uri"/>
            <xsl:attribute name="type" select=" if (self::sch:include) 
                                              then ('iso-schematron') 
                                           else if (self::xsl:include) 
                                              then ('xsl') 
                                           else if (self::es:import[@phase]) 
                                              then ('escali-by-phase') 
                                              else ('escali')"/>
            <xsl:if test="self::es:import[@phase]">
                <xsl:attribute name="phase" select="@phase"/>
            </xsl:if>
            <xsl:variable name="includes" select="doc($abs-uri)/*/(sch:include|es:import|xsl:include)"/>
            <xsl:apply-templates select="$includes" mode="#current"/>
        </es:include>
    </xsl:template>
    
    <xsl:template match="es:import" mode="phases">
        <xsl:variable name="import-doc" select="doc(resolve-uri(@href, document-uri(/)))"/>
        <xsl:for-each select="$import-doc/sch:schema/sch:phase">
            <es:phase id="{@id}"/>
        </xsl:for-each>
        <xsl:apply-templates select="$import-doc/sch:schema/es:import" mode="#current"/>
    </xsl:template>
    
    <xsl:template match="es:import[@phase]" mode="phases">
        <es:phase id="{@phase}"/>
    </xsl:template>
    
    <xsl:template match="sch:include|es:import|xsl:include" mode="lang">
        <xsl:variable name="import-doc" select="doc(resolve-uri(@href, document-uri(/)))"/>
        <xsl:for-each-group select="key('xmlLangNodes', 'xml-lang', $import-doc)" group-by="es:getLang(.)">
            <es:lang code="{current-grouping-key()}"/>
        </xsl:for-each-group>
        <xsl:apply-templates select="$import-doc/*/(sch:include|es:import|xsl:include)" mode="#current"/>
    </xsl:template>
</xsl:stylesheet>
