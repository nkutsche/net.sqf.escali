<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:es="http://www.escali.schematron-quickfix.com/"
    xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl"
    exclude-result-prefixes="xs xd"
    version="2.0">
    <xsl:import href="escali_validator_2_sqf-postprocess.xsl"/>
    <xd:doc scope="stylesheet">
        <xd:desc>
            <xd:p><xd:b>Created on:</xd:b> Nov 19, 2013</xd:p>
            <xd:p><xd:b>Author:</xd:b> Nico Kutscherauer</xd:p>
            <xd:p/>
        </xd:desc>
    </xd:doc>
    
    <xsl:template match="svrl:schematron-output">
        <xsl:copy>
            <xsl:apply-templates select="@*"/>
            <xsl:apply-templates select="*[not(@es:patternId)]"/>
            <xsl:for-each-group select="*[@es:patternId]" group-by="@es:patternId">
                <xsl:apply-templates select="current-group()"/>
            </xsl:for-each-group>
        </xsl:copy>
    </xsl:template>
    
<!--    <xsl:template match="svrl:fired-rule[following-sibling::*[1]/self::svrl:fired-rule]"/>
    <xsl:template match="svrl:fired-rule[not(following-sibling::*[1])]"/>-->
    
    
    <xsl:template match="@es:patternId"/>
    
    <!--
        copies all nodes
    -->
    <xsl:template match="node() | @*">
        <xsl:copy>
            <xsl:apply-templates select="@*"/>
            <xsl:apply-templates select="node()"/>
        </xsl:copy>
    </xsl:template>
    
</xsl:stylesheet>