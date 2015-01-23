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
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:es="http://www.escali.schematron-quickfix.com/" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl" xmlns:sch="http://purl.oclc.org/dsdl/schematron" exclude-result-prefixes="xs xd sch" version="2.0">

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



    <xsl:key name="phaseByActivePatternId" match="sch:phase" use="es:getRefPhases(.)/sch:active/@pattern"/>
    <xsl:key name="phaseByInactivePatternId" match="sch:phase" use="es:getRefPhases(.)/es:inactive/@pattern"/>

    <xsl:key name="nodeById" match="*[@id | @xml:id]" use="@id | @xml:id"/>

    <!--  
    returns for a $pattern if it is active (true) or inactive (false)
    the $pattern is active if:
        1. the $phase is '#ALL' 
            or $pattern is abstract or
        2. the $phase contains not the $deactivatePhase 
            and the $phaseEl contains not sch:active (es extension) or
        3. the $pattern has an @id and a $callingPhase which contains the $phase
   otherwise the $pattern is inactive

    -->
    <xsl:function name="es:isActive" as="xs:boolean">
        <xsl:param name="pattern" as="node()"/>
        <xsl:param name="phase" as="xs:string+"/>
        <xsl:variable name="phaseEl" select="key('nodeById', $phase, root($pattern))"/>
        <xsl:variable name="phaseEl" select="es:getRefPhases($phaseEl)"/>
        <xsl:variable name="callingPhase" select="key('phaseByActivePatternId',$pattern/@id, root($pattern))"/>
        <xsl:variable name="deactivatePhase" select="key('phaseByInactivePatternId',$pattern/@id, root($pattern))"/>
        <xsl:choose>
            <xsl:when test="$phase = '#ALL' or $pattern/@abstract='true'">
                <xsl:sequence select="es:getActiveDefault($pattern, true())"/>
            </xsl:when>
            <xsl:when test="$deactivatePhase/@id = $phase">
                <xsl:sequence select="false()"/>
            </xsl:when>
            <xsl:when test="$phaseEl and not($phaseEl/sch:active) and $phaseEl/es:inactive">
                <xsl:sequence select="es:getActiveDefault($pattern, true())"/>
            </xsl:when>
            <xsl:when test="not($pattern/@id) or not($callingPhase)">
                <xsl:sequence select="es:getActiveDefault($pattern, false())"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:sequence select="$callingPhase/@id = $phase"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>

    <xsl:function name="es:getActiveDefault" as="xs:boolean">
        <xsl:param name="pattern" as="element()"/>
        <xsl:param name="default" as="xs:boolean"/>
        <xsl:sequence select="if ($pattern/@abstract='true') 
                            then (true()) 
                         else if ($pattern/@es:active[.!='auto']) 
                            then ($pattern/@es:active = 'true') 
                            else ($default)"/>
    </xsl:function>
    <!--  
        es extension:
        resolves references from phases to other phases
        respects the es:phase elements (with @ref) as childs of sch:phase
    -->
    <xsl:function name="es:getRefPhases" as="node()*">
        <xsl:param name="phase" as="element(sch:phase)*"/>

        <xsl:variable name="refPhases" select="for $ph 
                                                in $phase 
                                            return key('nodeById', $ph/es:phase/@ref, root($ph))"/>
        <xsl:variable name="newPhases" select="$refPhases except $phase"/>
        <xsl:variable name="refNewPhases" select=" if (exists($newPhases)) then (es:getRefPhases(($newPhases union $phase)) except ($newPhases, $phase)) else ()"/>
        <xsl:sequence select="$phase, $newPhases, $refNewPhases"/>
    </xsl:function>




    <xsl:function name="es:getNodePath">
        <xsl:param name="node"/>
        <xsl:variable name="ancestor">
            <xsl:for-each select="$node/ancestor-or-self::node() except root($node)">
                <xsl:choose>
                    <xsl:when test=". instance of attribute()">
                        <xsl:call-template name="es:makeElementXPath">
                            <xsl:with-param name="axis">@</xsl:with-param>
                        </xsl:call-template>
                    </xsl:when>
                    <xsl:when test=". instance of element()">
                        <xsl:call-template name="es:makeElementXPath"/>
                    </xsl:when>
                    <xsl:when test=". instance of text()">
                        <xsl:call-template name="es:makeElementXPath">
                            <xsl:with-param name="type">text()</xsl:with-param>
                        </xsl:call-template>
                    </xsl:when>
                    <xsl:when test=". instance of comment()">
                        <xsl:call-template name="es:makeElementXPath">
                            <xsl:with-param name="type">comment()</xsl:with-param>
                        </xsl:call-template>
                    </xsl:when>
                    <xsl:when test=". instance of processing-instruction()">
                        <xsl:call-template name="es:makeElementXPath">
                            <xsl:with-param name="type">processing-instruction()</xsl:with-param>
                        </xsl:call-template>
                    </xsl:when>
                    <xsl:otherwise/>
                </xsl:choose>
            </xsl:for-each>
        </xsl:variable>
        <xsl:value-of select="$ancestor"/>
    </xsl:function>
    <xsl:template name="es:makeElementXPath">
        <xsl:param name="axis" select="''"/>
        <xsl:param name="type">*</xsl:param>
        <xsl:variable name="name" select="name()"/>
        <xsl:variable name="local-name" select="local-name()"/>
        <xsl:variable name="ns-uri" select="namespace-uri()"/>
        <xsl:text>/</xsl:text>
        <xsl:choose>
            <xsl:when test="$type = '*'">
                <xsl:value-of select="$axis"/>
                <xsl:text>*:</xsl:text>
                <xsl:value-of select="local-name()"/>
                <xsl:text>[namespace-uri()='</xsl:text>
                <xsl:value-of select="namespace-uri()"/>
                <xsl:text>']</xsl:text>
            </xsl:when>
            <xsl:when test="$type = 'processing-instruction()'">
                <xsl:text>processing-instruction()[local-name()='</xsl:text>
                <xsl:value-of select="local-name()"/>
                <xsl:text>']</xsl:text>
            </xsl:when>
            <xsl:when test="$type = ('comment()', 'text()')">
                <xsl:value-of select="$type"/>
            </xsl:when>
        </xsl:choose>
        <!--<xsl:value-of select="concat('/', $axis, $type)"/>
        <xsl:if test="not($type = ('comment()', 'text()'))">
            <xsl:text>[namespace-uri()='</xsl:text>
            <xsl:value-of select="namespace-uri()"/>
            <xsl:text>'][local-name()='</xsl:text>
            <xsl:value-of select="local-name()"/>
            <xsl:text>']</xsl:text>
        </xsl:if>-->
        <xsl:text>[</xsl:text>
        <xsl:choose>
            <xsl:when test="$type= 'text()'">
                <xsl:value-of select="count(preceding-sibling::text())+1"/>
            </xsl:when>
            <xsl:when test="$type= 'comment()'">
                <xsl:value-of select="count(preceding-sibling::comment())+1"/>
            </xsl:when>
            <xsl:when test="$type= 'processing-instruction()'">
                <xsl:value-of select="count(preceding-sibling::processing-instruction()[local-name()=$local-name])+1"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="count(preceding-sibling::*[local-name() = $local-name][namespace-uri() = $ns-uri])+1"/>
            </xsl:otherwise>
        </xsl:choose>
        <xsl:text>]</xsl:text>
    </xsl:template>

    <xsl:function name="es:quoteRegex" as="xs:string">
        <xsl:param name="regex" as="xs:string"/>
        <xsl:variable name="quoted" as="xs:string*">
            <xsl:analyze-string select="$regex" regex="[-\[\]()*+?.,\\^$|#]">
                <xsl:matching-substring>
                    <xsl:text>\</xsl:text>
                    <xsl:value-of select="."/>
                </xsl:matching-substring>
                <xsl:non-matching-substring>
                    <xsl:value-of select="."/>
                </xsl:non-matching-substring>
            </xsl:analyze-string>
        </xsl:variable>
        <xsl:sequence select="string-join($quoted, '')"/>
    </xsl:function>
</xsl:stylesheet>
