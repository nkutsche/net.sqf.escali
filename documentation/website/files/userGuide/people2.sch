<?xml version="1.0" encoding="UTF-8"?>
<schema xmlns="http://purl.oclc.org/dsdl/schematron" queryBinding="xslt2" xmlns:sqf="http://www.schematron-quickfix.com/validator/process">
    <title>People &#x2013; test</title>
    <pattern>
        <rule context="person">
            <let name="currYear" value="year-from-date(current-date())"/>
            <let name="maxBirth" value="replace(string(current-date()),string($currYear), string($currYear - age - 1))"/>
            <let name="minBirth" value="replace(string(current-date()),string($currYear), string($currYear - age))"/>
            <let name="birth" value="xs:date(dateOfBirth)"/>
            <assert test="$birth gt xs:date($maxBirth) and $birth le xs:date($minBirth)"><value-of select="name"/> is not <value-of select="age"/> years old or is not born on <value-of select="dateOfBirth"/>.</assert>
            <assert test="not($birth gt xs:date($maxBirth) and $birth le xs:date($minBirth)) or number(age) ge 18"><value-of select="name"/> is too young.</assert>
        </rule>
    </pattern>
</schema>