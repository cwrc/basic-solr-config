<?xml version="1.0" encoding="UTF-8"?>                                                  
<!-- Basic CWRC Entities - transform for Solr -->
 
<xsl:stylesheet 
    version="2.0" 
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


    <xsl:template name="cwrc_orlando_date_repair">
      <xsl:param name="date" />

          <!--
            * fix weird orlando dates that are not ISO valid e.g. 2000-01- 2000- -
            * XSLT version 2.0
            -->
            <!--
            <xsl:value-of select="replace($date, '-{1,2}$','')" />
            -->
            <!--
            * XSLT version 1.0
            -->
            <xsl:variable name="trim_date" select="normalize-space($date)"></xsl:variable>
            <xsl:choose>
                <xsl:when test="substring($trim_date,string-length($trim_date),string-length($trim_date))='-'">
                    <xsl:variable name="remove_last_char" select="substring($trim_date,0,string-length($trim_date))" />
                    <xsl:choose>
                        <xsl:when test="substring($remove_last_char, string-length($remove_last_char), string-length($remove_last_char))='-'">
                            <xsl:value-of select="substring($remove_last_char, 0, string-length($remove_last_char))" />
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:value-of select="$remove_last_char"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="$trim_date"/>
                </xsl:otherwise>
            </xsl:choose>

    </xsl:template>

</xsl:stylesheet>
