<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:es="http://www.escali.schematron-quickfix.com/"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl" xmlns:sqf="http://www.schematron-quickfix.com/validator/process"
    exclude-result-prefixes="xs xd"
    version="2.0">
    <xd:doc scope="stylesheet">
        <xd:desc>
            <xd:p><xd:b>Created on:</xd:b> Nov 19, 2013</xd:p>
            <xd:p><xd:b>Author:</xd:b> Nico Kutscherauer</xd:p>
            <xd:p/>
        </xd:desc>
    </xd:doc>
    <!--
	S Q F - E X T E N S I O N S
-->
    <xsl:key name="sqfLangnodesByLang" match="sqf:p" use="(es:getLang(.), '#ALL')"/>
    <xsl:key name="sqfSelectedNodesById" match="key('sqfLangnodesByLang', $es:lang)" use="generate-id()"/>
    
    <xsl:template match="sqf:p" priority="100">
        <xsl:choose>
            <xsl:when test="key('sqfSelectedNodesById', generate-id())">
                <xsl:next-match/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:comment>Deleted because selected language <xsl:value-of select="$es:lang"/> != <xsl:value-of select="es:getLang(.)"/>.</xsl:comment>
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
            <xsl:apply-templates select="@name |@as | @user-entry"/>
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