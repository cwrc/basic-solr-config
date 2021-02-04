<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet 
    version="1.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:mods="http://www.loc.gov/mods/v3" 
    exclude-result-prefixes="mods"
    >


    <!-- reassemble the author name from a CWRC title entity -->
    <xsl:template name="assemble_cwrc_title_author">
        
        <!--
            * based on the MODS to DC transform -  Version 1.3     2013-12-09
        -->
        
        <!-- does a surname exist -->
        <xsl:variable name="is_given_present" select="mods:namePart/@type='family'"/>
        <!-- does a forename exist -->
        <xsl:variable name="is_family_present" select="mods:namePart/@type='given'"/>
        
        <xsl:variable name="name">
            <!-- family and given namePart elements present -->
            <xsl:if test="$is_given_present or $is_family_present">
                <xsl:if test="$is_family_present">
                    <xsl:apply-templates select="mods:namePart[@type='family']" mode="assemble_cwrc_title_author"/>
                </xsl:if>
                <xsl:if test="$is_given_present and $is_family_present">
                    <xsl:text>, </xsl:text>
                </xsl:if>
                <xsl:if test="$is_given_present">
                    <xsl:apply-templates select="mods:namePart[@type='given']" mode="assemble_cwrc_title_author"/>
                </xsl:if>
            </xsl:if>
            <!-- namePart with a termsOfAddress -->
            <xsl:if test="mods:namePart[@type='termsOfAddress']">
                <xsl:if test="$is_given_present or $is_family_present">
                    <xsl:text>, </xsl:text>
                </xsl:if>
                <xsl:value-of select="mods:namePart[@type='termsOfAddress']"/>
                <xsl:text/>
            </xsl:if>
            <!-- namePart elements without a type -->
            <xsl:if test="mods:namePart[not(@type) and text() != '']">
                <xsl:if test="$is_given_present or $is_family_present">
                    <xsl:text>; </xsl:text>
                </xsl:if>
                <xsl:apply-templates select="mods:namePart[not(@type) and text() != '']" mode="assemble_cwrc_title_author"/>
            </xsl:if>
            <!-- namePart with a date -->
            <xsl:if test="mods:namePart[@type='date']">
                <xsl:text>, </xsl:text>
                <xsl:value-of select="mods:namePart[@type='date']"/>
                <xsl:text/>
            </xsl:if>
            <!-- displayForm -->
            <xsl:if test="mods:displayForm">
                <xsl:text> (</xsl:text>
                <xsl:value-of select="mods:displayForm"/>
                <xsl:text>) </xsl:text>
            </xsl:if>
            <!-- role if not 'creator' nor empty -->
            <xsl:if test="
                mods:role[mods:roleTerm[@type='text']!='creator'] 
                or 
                mods:role[mods:roleTerm[@type='text']!='']">
                <xsl:text> </xsl:text>
                <xsl:apply-templates select="
                    mods:role[mods:roleTerm[@type='text']!='creator']/mods:roleTerm 
                    | 
                    mods:role[mods:roleTerm[@type='text']!='']/mods:roleTerm" mode="assemble_cwrc_title_author"/>
            </xsl:if>
        </xsl:variable>
        
        <xsl:value-of select="normalize-space($name)"/>
    </xsl:template>
    
</xsl:stylesheet>