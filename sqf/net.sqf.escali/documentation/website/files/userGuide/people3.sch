<?xml version="1.0" encoding="UTF-8"?>
<schema xmlns="http://purl.oclc.org/dsdl/schematron" queryBinding="xslt2" xmlns:sqf="http://www.schematron-quickfix.com/validator/process">
    <title>People - test</title>
    <pattern>
        <rule context="person">
            <let name="currYear" value="year-from-date(current-date())"/>
            <let name="maxBirth" value="replace(string(current-date()),string($currYear), string($currYear - age - 1))"/>
            <let name="minBirth" value="replace(string(current-date()),string($currYear), string($currYear - age))"/>
            <let name="birth" value="xs:date(dateOfBirth)"/>
            <assert test="$birth gt xs:date($maxBirth) and $birth le xs:date($minBirth)" sqf:fix="setAge"><value-of select="name"/> is not <value-of select="age"/> years old or is not born on <value-of select="dateOfBirth"/>.</assert>
            <assert test="not($birth gt xs:date($maxBirth) and $birth le xs:date($minBirth)) or number(age) ge 18" sqf:fix="delete birthEntry"><value-of select="name"/> is too young.</assert>
            <sqf:fix id="setAge">
                
            </sqf:fix>
            <sqf:fix id="delete">
                
            </sqf:fix>
            <sqf:fix id="birthEntry">
                
            </sqf:fix>
        </rule>
    </pattern>
</schema>