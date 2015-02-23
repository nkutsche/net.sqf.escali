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

<schema xmlns="http://purl.oclc.org/dsdl/schematron" xmlns:sch="http://purl.oclc.org/dsdl/schematron" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:sqf="http://www.schematron-quickfix.com/validator/process" xmlns:es="http://www.escali.schematron-quickfix.com/" queryBinding="xslt2" see="http://www.schematron-quickfix.com/quickFix/reference.html">
    <ns uri="http://purl.oclc.org/dsdl/schematron" prefix="sch"/>
    <ns uri="http://www.schematron-quickfix.com/validator/process" prefix="sqf"/>

    <pattern>
        <title>Embedinging correctly</title>
        <rule context="sch:*/sqf:fixes">
            <assert test="parent::sch:schema">The <name/> must be inserted just inside of the sch:schema element.</assert>
        </rule>
        <rule context="sch:*/sqf:fix | sch:*/sqf:group">
            <assert test="parent::sch:rule">The <name/> element must be inserted just inside of a sch:ruleelement.</assert>
        </rule>
        <rule context="sch:*/sqf:*">
            <report test="true()">The <name/> element is not allowed inside of the element <name path="parent::node()"/>.</report>
        </rule>
    </pattern>
    <pattern es:matchType="all">
        <title>Fix references</title>
        <rule context="sch:assert[@sqf:fix] | sch:report[@sqf:fix]">
            <let name="fixes" value="tokenize(@sqf:fix,'\s')"/>
            <let name="availableFixIds" value="../sqf:fix/@id | ../sqf:group/@id | /sch:schema/sqf:fixes/sqf:fix/@id | /sch:schema/sqf:fixes/sqf:group/@id"/>
            <assert test="every $fix in $fixes satisfies $availableFixIds[. = $fix]" see="http://www.schematron-quickfix.com/quickFix/reference.html#messageAttributes_fix">The fix(es) <value-of select="string-join($fixes[not(. = $availableFixIds)], ', ')"/> are not available in this rule.</assert>
        </rule>

        <rule context="sch:assert[@sqf:default-fix] | sch:report[@sqf:default-fix]">
            <let name="defaultFix" value="@sqf:default-fix"/>
            <let name="fixes" value="tokenize(@sqf:fix,'\s')"/>
            <assert test="$fixes[. = $defaultFix]" see="http://www.schematron-quickfix.com/quickFix/reference.html#messageAttributes_default-fix">The default fix "<value-of select="$defaultFix"/>" is not refered by the sqf:fix attribute.</assert>
        </rule>
    </pattern>

    <!--<pattern es:matchType="all">
        <title>User entries</title>
        <rule context="sqf:user-entry">
            <let name="ref" value="@ref"/>
            <assert test="../sqf:param[@name=$ref]" see="http://www.schematron-quickfix.com/quickFix/reference.html#sqf:usert-entry">The <name/> has to refer to a sqf:param by the name.</assert>
        </rule>
    </pattern>-->

    <pattern es:matchType="all">
        <title>Activity elements</title>
        <rule context="sqf:add[@node-type='attribute']">
            <assert test="not(@position)" see="http://www.schematron-quickfix.com/quickFix/reference.html#add_position">If the node-type attribute has the value "attribute" the position attribute should not be set.</assert>
        </rule>
        <rule context="sqf:add[@select]|sqf:replace[@select]">
            <report test="node()" see="http://www.schematron-quickfix.com/quickFix/reference.html#activityManipulate_select">If the select attribute is setted the <name/> element should be empty.</report>
        </rule>
        <rule context="sqf:add[@target] | sqf:replace[@target]" role="fatal">
            <assert test="@node-type" see="http://www.schematron-quickfix.com/quickFix/reference.html#activityManipulate_target">The attribute node-type is required if the target attribute has been set.</assert>
        </rule>
        <rule context="sqf:add[@node-type != 'comment'] | sqf:replace[@node-type != 'comment']" role="warn">
            <assert test="@target" see="http://www.schematron-quickfix.com/quickFix/reference.html#activityManipulate_node-type">The attribute target has been set if the node-type attribute has the value "comment".</assert>
        </rule>
    </pattern>

    <pattern es:matchType="all">
        <title>Generic fixes</title>
        <rule context="sqf:call-fix">
            <let name="ref" value="@ref"/>
            <let name="availableFixIds" value="../../sqf:fix/@id | /schema/sqf:fixes/sqf:fix/@id"/>
            <assert test="$ref = $availableFixIds" see="http://www.schematron-quickfix.com/quickFix/reference.html#sqf:call-fix">The QuickFix with the id <value-of select="$ref"/> is not available in this rule.</assert>
        </rule>
        <rule context="sqf:with-param">
            <let name="paramName" value="@name"/>
            <let name="refFixId" value="../@ref"/>
            <let name="localRefFix" value="../../sqf:fix[@id = $refFixId]"/>
            <let name="refFix" value="if ($localRefFix) 
                                    then ($localRefFix) 
                                    else (/schema/sqf:fixes/sqf:fix[@id = $refFixId])"/>
            <assert test="$refFix/sqf:param[@name=$paramName]" see="http://www.schematron-quickfix.com/quickFix/reference.html#sqf:with-param">The called QuickFix has no parameter with the name <value-of select="$paramName"/>.</assert>
            <report test="@select and node()" see="http://www.schematron-quickfix.com/quickFix/reference.html#with-param_select">If the select attribute is setted the <name/> element should be empty.</report>
        </rule>
        <rule context="sqf:param[@abstract='true']">
            <let name="forbiddenAttr" value="@* except (@abstract, @name)"/>
            <report test="$forbiddenAttr">The attributes <value-of select="string-join(for $a in $forbiddenAttr return name($a), ', ')"/> should not be set for abstract parameters.</report>
        </rule>
    </pattern>

    <xsl:function name="sqf:getLang" as="xs:string">
        <xsl:param name="node" as="node()"/>
        <xsl:variable name="lang" select="($node/ancestor-or-self::*/@xml:lang)[last()]"/>
        <xsl:value-of select="if ($lang) then ($lang) else ('#DEFAULT')"/>
    </xsl:function>
    <pattern es:matchType="all">
        <title>Localisation tests</title>
        <let name="root" value="/"/>
        <let name="languages" value="distinct-values((//@xml:lang))"/>
        <rule context="/sch:schema" role="info">
            <report test="count($languages) gt 0 and not(@xml:lang)" flag="location">Localisation failed. If you use the xml:lang attribute you should set a root language.</report>
        </rule>
        <rule context="sch:assert | sch:report" role="info">
            <let name="msgLang" value="if (node()) 
                                     then (sqf:getLang(.)) 
                                     else ()"/>
            <let name="diagnIDs" value="tokenize(@diagnostics,'\s')"/>
            <let name="usedLangs" value="(for $d 
                                          in /sch:schema/sch:diagnostics/sch:diagnostic[@id=$diagnIDs]
                                      return sqf:getLang($d)), 
                                             $msgLang"/>
            <report test="count($languages[not(. = $usedLangs)]) gt 0">Localisation failed. Missing a diagnostic or error message for the language(s) <value-of select="$languages[not(. = $usedLangs)]"/>.</report>
        </rule>
        <rule context="sqf:description" role="info">
            <let name="usedLangs" value="(for $p in sqf:p
                                         return sqf:getLang($p))"/>
            <report test="count($languages[not(. = $usedLangs)]) gt 0">Localisation failed. Missing a description for the language(s) <value-of select="$languages[not(. = $usedLangs)]"/>.</report>
        </rule>
    </pattern>
</schema>
