<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl" xmlns:es="http://www.escali.schematron-quickfix.com/" xmlns:sch="http://purl.oclc.org/dsdl/schematron" xmlns:axsl="http://www.w3.org/1999/XSL/TransformAlias" exclude-result-prefixes="xs xd sch axsl es" version="2.0">
    <xsl:include href="escali_compiler_2_sqf-user-entry.xsl"/>
    <xd:doc scope="stylesheet">
        <xd:desc>
            <xd:p><xd:b>Created on:</xd:b> Nov 19, 2013</xd:p>
            <xd:p><xd:b>Author:</xd:b> Nico Kutscherauer</xd:p>
            <xd:p/>
        </xd:desc>
    </xd:doc>
    
    
    <!--
	   escali preprocess 2
	   Schematron:
	        abstracts Schematron patterns
	       
	   sx extensions:
	       languages of diagnostics
	   
	-->
    
    <xsl:output/>
    <!--	-->
    <xsl:namespace-alias stylesheet-prefix="axsl" result-prefix="xsl"/>

    <xsl:key name="abstractById" match="*[@abstract='true']" use="@id"/>
    
<!--  
        Handling a pattern call
    -->
    <xsl:template match="sch:pattern[@is-a]">
        <xsl:variable name="sx-id" select="@es:id"/>
        <xsl:variable name="template" select="key('abstractById', @is-a)"/>
        <xsl:choose>
            <xsl:when test="not($template)">
                <xsl:message>The called pattern <xsl:value-of select="@is-a"/> is not available or no abstract pattern.</xsl:message>
                <xsl:comment>The called pattern <xsl:value-of select="@is-a"/> is not available or no abstract pattern.</xsl:comment>
            </xsl:when>
            <xsl:otherwise>
                <xsl:apply-templates select="$template" mode="resolvePattern">
                    <xsl:with-param name="id" select="@id"/>
                    <xsl:with-param name="sx-id" select="$sx-id"/>
                    <xsl:with-param name="params" select="sch:param"/>
                </xsl:apply-templates>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template match="sch:pattern[@abstract='true']"/>

<!--
        Resolve the abstract patterns
        The resolved pattern gets the id of the calling pattern.
        @es:is-a safes the id of the called pattern.
    -->
    <xsl:template match="sch:pattern[@abstract='true']" mode="resolvePattern">
        <xsl:param name="id"/>
        <xsl:param name="sx-id"/>
        <xsl:param name="params"/>
        <xsl:copy>
            <xsl:apply-templates select="@* except @abstract" mode="resolvePattern">
                <xsl:with-param name="params" select="$params"/>
            </xsl:apply-templates>
            <xsl:attribute name="es:is-a" select="@id"/>
            <xsl:attribute name="es:id" select="$sx-id"/>
            <xsl:attribute name="id" select="$id"/>
            <xsl:apply-templates select="node()" mode="resolvePattern">
                <xsl:with-param name="params" select="$params" tunnel="yes"/>
            </xsl:apply-templates>
        </xsl:copy>
    </xsl:template>

<!--  
        resolves the parameters of the called pattern
        
    -->
    <xsl:template match="@*" mode="resolvePattern" priority="10">
        <xsl:param name="params" select="()" tunnel="yes" as="node()*"/>
        <xsl:attribute name="{name()}">
            <xsl:call-template name="resolveAttribute">
                <xsl:with-param name="value" select="."/>
                <xsl:with-param name="params" select="$params"/>
            </xsl:call-template>
        </xsl:attribute>
    </xsl:template>
<!--
        recursive template, resolves all parameters of a pattern call
        $value -> attribute value, wich could contains the param
        $params -> parameter of a calling pattern (sch:param)
    -->
    <xsl:template name="resolveAttribute">
        <xsl:param name="value" as="xs:string"/>
        <xsl:param name="params" as="node()*"/>
        <xsl:variable name="resParam" select="$params[1]"/>
        <xsl:choose>
            <xsl:when test="count($params) > 0">
                <xsl:variable name="paramName">
                    <xsl:analyze-string select="$resParam/@name" regex="[-\[\]()*+?.,\\^$|#]">
                        <xsl:matching-substring>
                            <xsl:text>\</xsl:text>
                            <xsl:value-of select="."/>
                        </xsl:matching-substring>
                        <xsl:non-matching-substring>
                            <xsl:value-of select="."/>
                        </xsl:non-matching-substring>
                    </xsl:analyze-string>
                </xsl:variable>
                <xsl:variable name="value">
                    <xsl:analyze-string select="$value" regex="\${$paramName}">
                        <xsl:matching-substring>
                            <xsl:value-of select="$resParam/@value"/>
                        </xsl:matching-substring>
                        <xsl:non-matching-substring>
                            <xsl:value-of select="."/>
                        </xsl:non-matching-substring>
                    </xsl:analyze-string>
                </xsl:variable>
                <xsl:call-template name="resolveAttribute">
                    <xsl:with-param name="value" select="$value"/>
                    <xsl:with-param name="params" select="$params except $resParam"/>
                </xsl:call-template>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="$value"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <!--  
        copies nodes of the refered rules
    -->
    <xsl:template match="sch:extends">
        <xsl:variable name="rule" select="@rule"/>
        <xsl:apply-templates select="key('abstractById', $rule)/node()"/>
    </xsl:template>
    
    <!--  
        deletes abstract rules
    -->
    <xsl:template match="sch:rule[@abstract='true']"/>
    
<!--    
        sx extension:
        concern asserts / reports which contains no message (after the es:lang filter):
        if they refer to exactly one diagnostic
        the message of the diagnostic will be used as the message of the assert / report
    -->
    <xsl:template match="sch:assert[not(node())] | sch:report[not(node())]">
        <xsl:variable name="diagnostics" select="tokenize(@diagnostics,'\s')"/>
        <xsl:variable name="refDiagnostic" select="/sch:schema/sch:diagnostics/sch:diagnostic[@id = $diagnostics]"/>
        <xsl:copy>
            <xsl:apply-templates select="if (count($refDiagnostic) = 1) 
                                       then (@* except @diagnostics, $refDiagnostic/@* except $refDiagnostic/@id, $refDiagnostic/node()) 
                                       else (@*, node())"/>
        </xsl:copy>
    </xsl:template>
    
<!-- 
        copies all nodes:
    -->
    <xsl:template match="node() | @*" mode="#all">
        <xsl:copy>
            <xsl:apply-templates select="@*" mode="#current"/>
            <xsl:apply-templates select="node()" mode="#current"/>
        </xsl:copy>
    </xsl:template>
    
</xsl:stylesheet>
