<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step xmlns:p="http://www.w3.org/ns/xproc" xmlns:es="http://www.escali.schematron-quickfix.com/" xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:sqf="http://www.schematron-quickfix.com/validator/process"
    xmlns:c="http://www.w3.org/ns/xproc-step" version="1.0" name="main-escali-quickFix">
    
<!--    <p:input port="svrl" primary="true"/>-->
    <p:input port="config">
        <p:document href="../../META-INF/config.xml"/>
    </p:input>
    
        <!--<p:output port="source" primary="true"/>-->
    
    <p:option name="fixId"/>
    <p:option name="userEntries" select="''"/>
    
    <p:import href="escali-schematron-lib.xpl"/>
    
    <p:variable name="tempFolder" select="resolve-uri(/es:config/es:tempFolder, document-uri(/))">
        <p:pipe port="config" step="main-escali-quickFix"/>
    </p:variable>
    <p:load name="svrlLoad">
        <p:with-option name="href" select="concat($tempFolder, 'temp.svrl')"/>
    </p:load>
    <es:getSvrlParam name="userEntrieParams">
        <p:with-option name="commandline" select="$userEntries"/>
        <p:with-option name="fixId" select="$fixId"/>
    </es:getSvrlParam>
    <p:load name="instanceLoad">
        <p:with-option name="href" select="/svrl:schematron-output/sqf:topLevel/@instance">
            <p:pipe port="result" step="svrlLoad"/>
        </p:with-option>
    </p:load>
    <p:choose>
        <p:when test="$userEntries=''">
            <es:quickFix>
                <p:input port="svrl">
                    <p:pipe port="result" step="svrlLoad"/>
                </p:input>
                <p:input port="source">
                    <p:pipe port="result" step="instanceLoad"/>
                </p:input>
                <p:with-param name="dummy" select="''"/>
                <p:with-option name="fixId" select="$fixId"/>
                <p:with-option name="xml-save-mode" select="/es:config/es:output/es:xml-save-mode">
                    <p:pipe port="config" step="main-escali-quickFix"/>
                </p:with-option>
            </es:quickFix>
        </p:when>
        <p:otherwise>
            <es:quickFix>
                <p:input port="svrl">
                    <p:pipe port="result" step="svrlLoad"/>
                </p:input>
                <p:input port="source">
                    <p:pipe port="result" step="instanceLoad"/>
                </p:input>
                <p:input port="params">
                    <p:pipe port="result" step="userEntrieParams"/>
                </p:input>
                <p:with-option name="fixId" select="$fixId"/>
                <p:with-option name="xml-save-mode" select="/es:config/es:output/es:xml-save-mode">
                    <p:pipe port="config" step="main-escali-quickFix"/>
                </p:with-option>
            </es:quickFix>
        </p:otherwise>
    </p:choose>
    <p:choose>
        <p:variable name="xml-save-mode" select="/es:config/es:output/es:xml-save-mode">
            <p:pipe port="config" step="main-escali-quickFix"/>
        </p:variable>
        <p:variable name="xsmFolder" select="resolve-uri(/es:config/es:output/es:xsm-processor, document-uri(/))">
            <p:pipe port="config" step="main-escali-quickFix"/>
        </p:variable>
        <p:when test="$xml-save-mode='true'">
            <es:xsm>
                <p:with-option name="tempFolder" select="$tempFolder"/>
                <p:with-option name="xsmFolder" select="$xsmFolder"/>
            </es:xsm>
        </p:when>
        <p:otherwise>
            <p:store>
                <p:with-option name="href" select="$tempOutput"/>
            </p:store>
        </p:otherwise>
    </p:choose>
    <!--<p:store>
        <p:with-option name="href" select="$out"/>
    </p:store>-->
<!--    <p:sink/>-->
</p:declare-step>