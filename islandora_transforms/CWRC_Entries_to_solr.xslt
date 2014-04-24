<?xml version="1.0" encoding="UTF-8"?>

<!-- Basic CWRC Entries (e.g. biography, writing, TEI - transform for Solr -->

<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:foxml="info:fedora/fedora-system:def/foxml#" xmlns:xlink="http://www.w3.org/1999/xlink" xmlns:mods="http://www.loc.gov/mods/v3" exclude-result-prefixes="mods">

    <!-- this template used to help test  -->

<!-- 
    <xsl:template match="/">
        <xsl:apply-templates select="/foxml:digitalObject/foxml:datastream[@ID='CWRC-CONTENT']/foxml:datastreamVersion[last()]">
            <xsl:with-param name="content" select="/foxml:digitalObject/foxml:datastream[@ID='CWRC-CONTENT']/foxml:datastreamVersion[last()]/foxml:xmlContent"/>
        </xsl:apply-templates>

    </xsl:template>
-->


    <!-- ********************************************************* -->
    <!-- Orlando Events - cwrc.ca/schema/orlando_events.rng  -->
    <!-- ********************************************************* -->
    <xsl:template match="foxml:datastream[@ID='CWRC-CONTENT']/foxml:datastreamVersion[last()]" name="index_CWRC_EVENT_ENTRY">

        <xsl:param name="content" select="(FREESTANDING_EVENT|EMBEDDED_EVENT)"/>
        <xsl:param name="prefix" select="'cwrc_entry_'"/>
        <xsl:param name="suffix" select="'_et'"/>
        <!-- 'edged' (edge n-gram) text, for auto-completion -->

        <xsl:variable name="local_prefix" select="concat($prefix, 'event_')"/>
        <xsl:variable name="local_content" select="$content/FREESTANDING_EVENT | $content/EMBEDDED_EVENT"/>


        <!-- Event Chronstruct date -->
        <field>
            <xsl:attribute name="name">
                <xsl:value-of select="concat($local_prefix, 'date', '_s')"/>
            </xsl:attribute>
            <xsl:apply-templates select="$local_content/CHRONSTRUCT/DATE | $local_content/CHRONSTRUCT/DATERANGE | $local_content/CHRONSTRUCT/DATESTRUCT">
                <xsl:with-param name="prefix" select="$local_prefix"/>
            </xsl:apply-templates>
        </field>


        <!-- PLACE - one to many stored in an array -->
        <xsl:for-each select="$local_content//PLACE">
            <field>
                <xsl:attribute name="name">
                    <xsl:value-of select="concat($local_prefix, 'place', '_mt')"/>
                </xsl:attribute>
                <xsl:call-template name="assemble_orlando_place"/>
            </field>
        </xsl:for-each>

        <!-- Event CHRONPROST - -->
        <xsl:if test="$local_content/CHRONSTRUCT/CHRONPROSE">
            <field>
                <xsl:attribute name="name">
                    <xsl:value-of select="concat($local_prefix, 'chronProse', $suffix)"/>
                </xsl:attribute>
                <xsl:value-of select="normalize-space($local_content/CHRONSTRUCT/CHRONPROSE)"/>
            </field>
        </xsl:if>

        <!-- Event Shortprose - -->
        <xsl:if test="$local_content/SHORTPROSE">
            <field>
                <xsl:attribute name="name">
                    <xsl:value-of select="concat($local_prefix, 'shortProse', $suffix)"/>
                </xsl:attribute>
                <xsl:value-of select="normalize-space($local_content/SHORTPROSE)"/>
            </field>
        </xsl:if>
    </xsl:template>

    <!-- build the Orlando Place into an indexible string -->
    <xsl:template name="assemble_orlando_place">
        <xsl:if test="ADDRESS">
            <xsl:call-template name="assemble_orlando_place_subelement">
                <xsl:with-param name="context" select="ADDRESS" />
            </xsl:call-template>
            <xsl:if test="AREA or GEOG or REGION or SETTLEMENT or PLACENAME">
                <xsl:text>, </xsl:text>
            </xsl:if>
        </xsl:if>
        <xsl:if test="PLACENAME">
            <xsl:call-template name="assemble_orlando_place_subelement">
                <xsl:with-param name="context" select="PLACENAME" />
            </xsl:call-template>
            <xsl:if test="AREA or GEOG or REGION or SETTLEMENT">
                <xsl:text>, </xsl:text>
            </xsl:if>
        </xsl:if>
        <xsl:if test="SETTLEMENT">
            <xsl:call-template name="assemble_orlando_place_subelement">
                <xsl:with-param name="context" select="SETTLEMENT" />
            </xsl:call-template>
            
            <xsl:if test="AREA or GEOG or REGION">
                <xsl:text>, </xsl:text>
            </xsl:if>
        </xsl:if>
        <xsl:if test="REGION">
            <xsl:call-template name="assemble_orlando_place_subelement">
                <xsl:with-param name="context" select="REGION" />
            </xsl:call-template>
            <xsl:if test="AREA or GEOG">
                <xsl:text>, </xsl:text>
            </xsl:if>
        </xsl:if>
        <xsl:if test="GEOG">
            <xsl:call-template name="assemble_orlando_place_subelement">
                <xsl:with-param name="context" select="GEOG" />
            </xsl:call-template>
            <xsl:if test="AREA">
                <xsl:text>, </xsl:text>
            </xsl:if>
        </xsl:if>
        <xsl:if test="AREA">
            <xsl:call-template name="assemble_orlando_place_subelement">
                <xsl:with-param name="context" select="AREA" />
            </xsl:call-template>
            
        </xsl:if>

    </xsl:template>


    <!--
    // for each of the PLACE subTags, a "CURRENT" and/or "REG" attribute
    // are options
    // If "CURRENT" is available then use the attribute "CURRENT".
    // If "REG" is available the use the REG's
    // regularized versions are better for use than the text content PCDATA.
    // If neither are available then just use the text content from the tag,
    // *IF* the entry and cleanup are done properly, then the text
    // of the tag is the 'REG' value
    -->
    <xsl:template name="assemble_orlando_place_subelement">
        <xsl:param name="context" />
        <!-- <xsl:value-of select="local-name($context)"/> -->
        <xsl:choose>
            <xsl:when test="$context/@CURRENT">
                <xsl:value-of select="$context/@CURRENT"/>
            </xsl:when>
            <xsl:when test="$context/@REG">
                <xsl:value-of select="$context/@REG"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="$context"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>


    <xsl:template match="CHRONSTRUCT/DATE">
        <xsl:value-of select="@VALUE"/>
    </xsl:template>

    <xsl:template match="CHRONSTRUCT/DATERANGE">
        <xsl:value-of select="@FROM" />
        <xsl:text> - </xsl:text>
        <xsl:value-of select="@TO" />
    </xsl:template>
    
    
    <!-- TODO interprete the Orlando SEASON element --> 
    <xsl:template match="CHRONSTRUCT/DATESTRUCT">
        <xsl:value-of select="@VALUE"/>
    </xsl:template>

</xsl:stylesheet>
