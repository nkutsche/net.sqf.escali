<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:sqf="http://www.schematron-quickfix.com/validator/process" xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl" xmlns:svrl="http://purl.oclc.org/dsdl/svrl" exclude-result-prefixes="xd" version="2.0" xpath-default-namespace="http://purl.oclc.org/dsdl/svrl">
    <xd:doc scope="stylesheet">
        <xd:desc>
            <xd:p><xd:b>Created on:</xd:b> Nov 19, 2013</xd:p>
            <xd:p><xd:b>Author:</xd:b> Nico Kutscherauer</xd:p>
            <xd:p/>
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
