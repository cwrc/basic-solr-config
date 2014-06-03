<?xml version="1.0" encoding="UTF-8"?>                                                  
<!-- Basic CWRC Entities - transform for Solr -->
 
<xsl:stylesheet 
    version="1.0" 
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
    xmlns:foxml="info:fedora/fedora-system:def/foxml#" 
    xmlns:xlink="http://www.w3.org/1999/xlink" 
    xmlns:mods="http://www.loc.gov/mods/v3" 
    exclude-result-prefixes="mods"
    >


    <xsl:variable name="CWRC_GEOLOC_PROT">http</xsl:variable>
    <xsl:variable name="CWRC_GEOLOC_HOST">beta.cwrc.ca</xsl:variable>        
    <xsl:variable name="CWRC_GEOLOC_PORT">80</xsl:variable>
    <xsl:variable name="CWRC_GEOLOC_URN">/CWRC-MTP/geonames</xsl:variable>


    <!--
    * Call API to lookup geoloc
    * https://github.com/cwrc/CWRC-Mapping-Timelines-Project/tree/master/geonames
    -->
    <xsl:template name="cwrc_lookup_geoloc">
        <xsl:param name="str_to_query_geoloc"/>
        <xsl:call-template name="cwrc_assemble_geoloc">
            <xsl:with-param name="geoname_results" select="document(concat($CWRC_GEOLOC_PROT, '://', $CWRC_GEOLOC_HOST, ':', $CWRC_GEOLOC_PORT, $CWRC_GEOLOC_URN, '?query=', $str_to_query_geoloc))"/>
        </xsl:call-template>
    </xsl:template>

    <!--
    * interpret response and create Solr fields 
    * https://github.com/cwrc/CWRC-Mapping-Timelines-Project/tree/master/geonames
    -->
    <xsl:template name="cwrc_assemble_geoloc">
        <xsl:param name="geoname_results"/>

        <field>
            <xsl:attribute name="name">
                <xsl:text>cwrc_general_place_geoloc_ms</xsl:text>
            </xsl:attribute>

            <xsl:choose>
                <xsl:when test="$geoname_results/geonames/geoname[1]">
                    <xsl:value-of select="$geoname_results/geonames/geoname[1]/lat"/>
                    <xsl:text>,</xsl:text>
                    <xsl:value-of select="$geoname_results/geonames/geoname[1]/lng"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:text>0,0</xsl:text>
                </xsl:otherwise>
            </xsl:choose>
        </field>

        <field>
            <xsl:attribute name="name">
                <xsl:text>cwrc_general_place_geoloc_debug_ms</xsl:text>
            </xsl:attribute>

            <xsl:choose>
                <xsl:when test="$geoname_results/geonames/geoname[1]">
                    <xsl:value-of select="$geoname_results/geonames/geoname[1]/name"/>
                    <xsl:text> </xsl:text>
                    <xsl:value-of select="$geoname_results/geonames/geoname[1]/countryCode"/>
                </xsl:when>
            </xsl:choose>
        </field>


        <!-- <xsl:copy-of select="$geoname_results"/> -->
    </xsl:template>


</xsl:stylesheet>
