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
                <sqf:description>
                    <sqf:p>Calculate the age from the date of birth.</sqf:p>
                </sqf:description>
                <let name="yearOfBirth" value="year-from-date($birth)"/>
                <let name="yearDif" value="$currYear - $yearOfBirth"/>
                <let name="birthdayInThisYear" value="replace(string($birth), string($yearOfBirth), string($currYear))"/>
                <let name="newAge" value="if(xs:date($birthdayInThisYear) > current-date()) 
                    then ($yearDif - 1)
                    else ($yearDif)"/>
                <sqf:replace match="age" target="age" select="$newAge"/>
            </sqf:fix>
            <sqf:fix id="delete">
                <sqf:description>
                    <sqf:p>Delete the person from the list.</sqf:p>
                </sqf:description>
                <sqf:delete/>
            </sqf:fix>
            <sqf:fix id="birthEntry">
                <sqf:description>
                    <sqf:p>The age and the date of birth are wrong. Enter the correct date of birth.</sqf:p>
                </sqf:description>
                <sqf:replace match="dateOfBirth" target="dateOfBirth">1986-04-05</sqf:replace>
            </sqf:fix>
        </rule>
    </pattern>
</schema>