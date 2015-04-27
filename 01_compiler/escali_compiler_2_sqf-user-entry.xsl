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
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:sch="http://purl.oclc.org/dsdl/schematron"
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
    
    <xsl:key name="globalFixById" match="sqf:fixes/sqf:fix" use="@id"/>
    
<!--    <!-\-  
    marks as an user-entry-parameter
    -\->
    <xsl:template match="sqf:fix/sqf:param[@name=parent::sqf:fix/sqf:user-entry/@ref]" mode="#all">
        <xsl:copy>
            <xsl:attribute name="user-entry">yes</xsl:attribute>
            <xsl:apply-templates select="node() | @*" mode="#current"/>
        </xsl:copy>
    </xsl:template>-->
    
    <xsl:template match="sch:assert[@sqf:fix] |sch:report[@sqf:fix]" mode="#all" priority="1000">
        <xsl:variable name="local-fix" select="../sqf:fix"/>
        <xsl:variable name="prec-called-fixes" select="for $f in preceding-sibling::*/@sqf:fix return tokenize($f, '\s')" as="xs:string*"/>
        <xsl:variable name="global-fix-ids" select="tokenize(@sqf:fix, '\s')[not(. = ($local-fix/@id, $prec-called-fixes))]" as="xs:string*"/>
        <xsl:next-match/>
        <xsl:apply-templates select="key('globalFixById', $global-fix-ids)" mode="#current"/>
    </xsl:template>
    
    <xsl:template match="sqf:fixes" mode="#all" priority="1000"/>
        
    
    
</xsl:stylesheet>