<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step xmlns:p="http://www.w3.org/ns/xproc" xmlns:es="http://www.escali.schematron-quickfix.com/"
    xmlns:c="http://www.w3.org/ns/xproc-step" version="1.0" name="main-escali-validation">
    
    <p:input port="source" primary="true"/>
    <p:input port="schema"/>
    <p:input port="config">
        <p:document href="../../META-INF/config.xml"/>
    </p:input>
    
    <p:output port="html" primary="true">
        <p:pipe port="result" step="html"/>
    </p:output>
    
    
    <p:import href="escali-schematron-lib.xpl"/>
    
    <p:variable name="tempFolder" select="resolve-uri(/es:config/es:tempFolder, document-uri(/))">
        <p:pipe port="config" step="main-escali-validation"/>
    </p:variable>
    
    <p:variable name="phase" select="/es:config/es:phase">
        <p:pipe port="config" step="main-escali-validation"/>
    </p:variable>
    
    <es:schematron name="svrl">
        <p:input port="source">
            <p:pipe port="source" step="main-escali-validation"/>
        </p:input>
        <p:input port="schema">
            <p:pipe port="schema" step="main-escali-validation"/>
        </p:input>
        <p:with-option name="phase" select="$phase"/>
    </es:schematron>
    
    <p:xslt name="html">
        <p:input port="stylesheet">
            <p:document href="../xsl/02_validator/escali_validator_3_html-report.xsl"/>
        </p:input>
        <p:with-param name="dummy" select="''"/>
    </p:xslt>
    
    
    <p:store>
        <p:with-option name="href" select="concat($tempFolder, 'temp.svrl')"/>
        <p:input port="source">
            <p:pipe port="result" step="svrl"/>
        </p:input>
    </p:store>
<!--    <p:sink/>-->
</p:declare-step>