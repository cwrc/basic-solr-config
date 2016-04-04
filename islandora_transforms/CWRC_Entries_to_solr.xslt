<?xml version="1.0" encoding="UTF-8"?>

<!-- Basic CWRC Entries (e.g. biography, writing, TEI - transform for Solr -->

<xsl:stylesheet version="1.0" 
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
    xmlns:foxml="info:fedora/fedora-system:def/foxml#" 
    xmlns:xlink="http://www.w3.org/1999/xlink" 
    xmlns:mods="http://www.loc.gov/mods/v3" 
    xmlns:tei="http://www.tei-c.org/ns/1.0"
    exclude-result-prefixes="mods"
    >

    <!--
    <xsl:include href="/usr/local/fedora/tomcat/webapps/fedoragsearch/WEB-INF/classes/fgsconfigFinal/index/FgsIndex/islandora_transforms/CWRC_GeoLoc.xslt"/>
    -->

    <xsl:include href="/usr/local/fedora/tomcat/webapps/fedoragsearch/WEB-INF/classes/fgsconfigFinal/index/FgsIndex/islandora_transforms/CWRC_helpers.xslt"/>


    <!-- this template used to help test  -->

    <!-- 
    <xsl:template match="/">
        <xsl:apply-templates select="/foxml:digitalObject/foxml:datastream[@ID='CWRC-CONTENT']/foxml:datastreamVersion[last()]">
            <xsl:with-param name="content" select="/foxml:digitalObject/foxml:datastream[@ID='CWRC-CONTENT']/foxml:datastreamVersion[last()]/foxml:xmlContent"/>
        </xsl:apply-templates>

    </xsl:template>
-->

    <!-- ********************************************************* -->
    <!--
        CWRC entries and event conforming to the following schemas
        * http://cwrc.ca/schemas/cwrc_entry.rng
        * http://cwrc.ca/schemas/cwrc_tei_lite.rng
        * http://cwrc.ca/schemas/orlando_biography.rng
        * http://cwrc.ca/schemas/orlando_event.rng
        * http://cwrc.ca/schemas/orlando_writing.rng
        * 
    -->
    <!-- ********************************************************* -->
    <xsl:template match="foxml:datastream[@ID='CWRC']/foxml:datastreamVersion[@MIMETYPE='text/xml' or @MIMETYPE='application/xml'][last()]" name="index_CWRC_ENTRY">
        <xsl:param name="content" select="/"/>
        <xsl:param name="CWRC_PERIOD_DATE_USE_MODS_PERIOD" select="''"/>
        <xsl:param name="prefix" select="'cwrc_entry_'"/>
        <xsl:param name="suffix" select="'_et'"/>
        <!-- 'edged' (edge n-gram) text, for auto-completion -->


        <!-- allow facet on date content only if not overridden by the CWRC_PERIOD_DATE_USE_MODS_PERIOD -->
        <xsl:if test="$CWRC_PERIOD_DATE_USE_MODS_PERIOD=''">

            <xsl:apply-templates select="$content//DATE | $content//DATERANGE | $content//DATESTRUCT | $content//tei:date" mode="date_facet">
                <xsl:with-param name="prefix" select="cwrc_facet_"/>
                <xsl:with-param name="CWRC_PERIOD_DATE_USE_MODS_PERIOD" select="$CWRC_PERIOD_DATE_USE_MODS_PERIOD"/>
            </xsl:apply-templates>
        </xsl:if>


        <!-- index the XML content as text -->
        <field>
          <xsl:attribute name="name">
            <xsl:value-of select="concat($prefix, '_ds_as_text', '_hlt')"/>
          </xsl:attribute>
          <xsl:apply-templates select="$content" mode="index_text_nodes_as_a_text_field"/>
        </field>


    </xsl:template>

    <!-- 
        * assume date in not in the Legacy Orlando format (e.g., YYYY-) and in the ISO8601 format (e.g. YYYY)
        * key on @VALUE or text of element
    -->
    <xsl:template match="DATE" mode="date_facet">
        <xsl:param name="prefix"/>

        <!-- inspect date attributes -->
        <xsl:variable name="pointDate">
            <xsl:choose>
                <xsl:when test="@VALUE!=''">
                    <xsl:value-of select="@VALUE"/>
                </xsl:when>
            </xsl:choose>
        </xsl:variable>

        <!-- build Solr field -->
        <xsl:call-template name="solr_field_date_facet">
            <xsl:with-param name="prefix" select="$prefix"/>
            <xsl:with-param name="pointDate" select="$pointDate"/>
            <xsl:with-param name="fromDate" select="''"/>
            <xsl:with-param name="toDate" select="''"/>
            <xsl:with-param name="textDate" select="./text()"/>
        </xsl:call-template>

    </xsl:template>

    <!-- 
        * assume date in not in the Legacy Orlando format (e.g., YYYY-) and in the ISO8601 format (e.g. YYYY)
        * key on @TO / @FROM 
        * assume date attributes required (no need to use text)
    -->
    <xsl:template match="DATERANGE" mode="date_facet">
        <xsl:param name="prefix"/>

        <xsl:variable name="fromDate">
            <xsl:choose>
                <xsl:when test="@FROM!=''">
                    <xsl:value-of select="@FROM"/>
                </xsl:when>
            </xsl:choose>
        </xsl:variable>

        <xsl:variable name="toDate">
            <xsl:choose>
                <xsl:when test="@TO!=''">
                    <xsl:value-of select="@TO"/>
                </xsl:when>
            </xsl:choose>
        </xsl:variable>

        <!-- build Solr field -->
        <xsl:call-template name="solr_field_date_facet">
            <xsl:with-param name="prefix" select="$prefix"/>
            <xsl:with-param name="pointDate" select="''"/>
            <xsl:with-param name="fromDate" select="$fromDate"/>
            <xsl:with-param name="toDate" select="$toDate"/>
            <xsl:with-param name="textDate" select="''"/>
        </xsl:call-template>

    </xsl:template>

    <xsl:template match="DATESTRUCT" mode="date_facet">
        <xsl:param name="prefix"/>

        <!-- inspect date attributes -->
        <xsl:variable name="pointDate">
            <xsl:choose>
                <xsl:when test="@VALUE!=''">
                    <xsl:value-of select="@VALUE"/>
                </xsl:when>
            </xsl:choose>
        </xsl:variable>

        <!-- build Solr field -->
        <xsl:call-template name="solr_field_date_facet">
            <xsl:with-param name="prefix" select="$prefix"/>
            <xsl:with-param name="pointDate" select="$pointDate"/>
            <xsl:with-param name="fromDate" select="''"/>
            <xsl:with-param name="toDate" select="''"/>
            <xsl:with-param name="textDate" select="''"/>
        </xsl:call-template>

    </xsl:template>


    <!--
        TEI date handler
            * point date: 
            ** @when | @when-custom | when-iso
            * date range: 
            ** @to | @to-custom | @to-iso | @notBefore | @notBefore-custom | @notBefore-iso
            ** @from | @from-custom | @from-iso | @notAfter | @notAfter-custom | @notAfter-iso
        -->

    <xsl:template match="tei:date" mode="date_facet">
        <xsl:param name="prefix"/>

        <!-- inspect date attributes -->
        <xsl:variable name="pointDate">
            <xsl:choose>
                <xsl:when test="@when!=''">
                    <xsl:value-of select="@when"/>
                </xsl:when>
                <xsl:when test="@when-iso!=''">
                    <xsl:value-of select="@when-iso"/>
                </xsl:when>
                <xsl:when test="@when-custom!=''">
                    <xsl:value-of select="@when-custom"/>
                </xsl:when>
            </xsl:choose>
        </xsl:variable>

        <xsl:variable name="fromDate">
            <xsl:choose>
                <xsl:when test="@from!=''">
                    <xsl:value-of select="@from"/>
                </xsl:when>
                <xsl:when test="@from-iso!=''">
                    <xsl:value-of select="@from-iso"/>
                </xsl:when>
                <xsl:when test="@from-custom!=''">
                    <xsl:value-of select="@from-custom"/>
                </xsl:when>
                <xsl:when test="@notBefore!=''">
                    <xsl:value-of select="@notBefore"/>
                </xsl:when>
                <xsl:when test="@notBefore-iso!=''">
                    <xsl:value-of select="@notBefore-iso"/>
                </xsl:when>
                <xsl:when test="@notBefore-custom!=''">
                    <xsl:value-of select="@notBefore-custom"/>
                </xsl:when>
            </xsl:choose>
        </xsl:variable>

        <xsl:variable name="toDate">
            <xsl:choose>
                <xsl:when test="@to!=''">
                    <xsl:value-of select="@to"/>
                </xsl:when>
                <xsl:when test="@to-iso!=''">
                    <xsl:value-of select="@to-iso"/>
                </xsl:when>
                <xsl:when test="@to-custom!=''">
                    <xsl:value-of select="@to-custom"/>
                </xsl:when>
                <xsl:when test="@notAfter!=''">
                    <xsl:value-of select="@notAfter"/>
                </xsl:when>
                <xsl:when test="@notAfter-iso!=''">
                    <xsl:value-of select="@notAfter-iso"/>
                </xsl:when>
                <xsl:when test="@notAfter-custom!=''">
                    <xsl:value-of select="@notAfter-custom"/>
                </xsl:when>
            </xsl:choose>
        </xsl:variable>

        <!-- build Solr field -->
        <xsl:call-template name="solr_field_date_facet">
            <xsl:with-param name="prefix" select="$prefix"/>
            <xsl:with-param name="pointDate" select="$pointDate"/>
            <xsl:with-param name="fromDate" select="$fromDate"/>
            <xsl:with-param name="toDate" select="$toDate"/>
            <xsl:with-param name="textDate" select="./text()"/>
        </xsl:call-template>

    </xsl:template>




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
            <!--
                * Geo locate place
                -->
            <!--
            <xsl:call-template name="cwrc_lookup_geoloc">
                <xsl:with-param name="str_to_query_geoloc">
                    <xsl:choose>
                        <xsl:when test="./SETTLEMENT">
                            <xsl:call-template name="assemble_orlando_place_subelement">
                                <xsl:with-param name="context" select="./SETTLEMENT" />
                            </xsl:call-template>
                        </xsl:when>
                        <xsl:when test="./REGION">
                            <xsl:call-template name="assemble_orlando_place_subelement">
                                <xsl:with-param name="context" select="./REGION" />
                            </xsl:call-template>
                        </xsl:when>
                        <xsl:when test="./GEOG">
                            <xsl:call-template name="assemble_orlando_place_subelement">
                                <xsl:with-param name="context" select="./GEOG" />
                            </xsl:call-template>
                        </xsl:when>
                    </xsl:choose> 
                </xsl:with-param>
            </xsl:call-template>
            -->

        </xsl:for-each>

        <!-- Event CHRONPROST - -->
        <xsl:if test="$local_content/CHRONSTRUCT/CHRONPROSE">
            <field>
                <xsl:attribute name="name">
                    <xsl:value-of select="concat($local_prefix, 'chronProse', $suffix)"/>
                </xsl:attribute>
                <xsl:value-of select="normalize-space($local_content/CHRONSTRUCT/DATE | $local_content/CHRONSTRUCT/DATERANGE | $local_content/CHRONSTRUCT/DATESTRUCT )"/>
                <xsl:text>: </xsl:text>
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
                <xsl:with-param name="context" select="ADDRESS"/>
            </xsl:call-template>
            <xsl:if test="AREA or GEOG or REGION or SETTLEMENT or PLACENAME">
                <xsl:text>, </xsl:text>
            </xsl:if>
        </xsl:if>
        <xsl:if test="PLACENAME">
            <xsl:call-template name="assemble_orlando_place_subelement">
                <xsl:with-param name="context" select="PLACENAME"/>
            </xsl:call-template>
            <xsl:if test="AREA or GEOG or REGION or SETTLEMENT">
                <xsl:text>, </xsl:text>
            </xsl:if>
        </xsl:if>
        <xsl:if test="SETTLEMENT">
            <xsl:call-template name="assemble_orlando_place_subelement">
                <xsl:with-param name="context" select="SETTLEMENT"/>
            </xsl:call-template>

            <xsl:if test="AREA or GEOG or REGION">
                <xsl:text>, </xsl:text>
            </xsl:if>
        </xsl:if>
        <xsl:if test="REGION">
            <xsl:call-template name="assemble_orlando_place_subelement">
                <xsl:with-param name="context" select="REGION"/>
            </xsl:call-template>
            <xsl:if test="AREA or GEOG">
                <xsl:text>, </xsl:text>
            </xsl:if>
        </xsl:if>
        <xsl:if test="GEOG">
            <xsl:call-template name="assemble_orlando_place_subelement">
                <xsl:with-param name="context" select="GEOG"/>
            </xsl:call-template>
            <xsl:if test="AREA">
                <xsl:text>, </xsl:text>
            </xsl:if>
        </xsl:if>
        <xsl:if test="AREA">
            <xsl:call-template name="assemble_orlando_place_subelement">
                <xsl:with-param name="context" select="AREA"/>
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
        <xsl:param name="context"/>
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
        <xsl:call-template name="cwrc_orlando_date_repair">
            <xsl:with-param name="date" select="@VALUE"/>
        </xsl:call-template>
    </xsl:template>

    <xsl:template match="CHRONSTRUCT/DATERANGE">
        <xsl:call-template name="cwrc_orlando_date_repair">
            <xsl:with-param name="date" select="@FROM"/>
        </xsl:call-template>
        <xsl:text> - </xsl:text>
        <xsl:call-template name="cwrc_orlando_date_repair">
            <xsl:with-param name="date" select="@TO"/>
        </xsl:call-template>
    </xsl:template>


    <!-- TODO interprete the Orlando SEASON element -->
    <xsl:template match="CHRONSTRUCT/DATESTRUCT">
        <xsl:call-template name="cwrc_orlando_date_repair">
            <xsl:with-param name="date" select="@VALUE"/>
        </xsl:call-template>
    </xsl:template>

</xsl:stylesheet>
