<?xml version="1.0" encoding="UTF-8"?>                                                  
<!-- 
    CWRC helpers
    * GeoLocation
    * Orlando dates

-->
 
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:foxml="info:fedora/fedora-system:def/foxml#" xmlns:xlink="http://www.w3.org/1999/xlink" xmlns:mods="http://www.loc.gov/mods/v3" exclude-result-prefixes="mods">


    <xsl:variable name="CWRC_GEOLOC_PROT">http</xsl:variable>
    <xsl:variable name="CWRC_GEOLOC_HOST">beta.cwrc.ca</xsl:variable>
    <xsl:variable name="CWRC_GEOLOC_PORT">80</xsl:variable>
    <xsl:variable name="CWRC_GEOLOC_URN">/CWRC-MTP/geonames</xsl:variable>



    <!-- 
        * build Solr field of type "class solr.DateRangeField" to facet on date within content
        * solr.DateRangeField supports both point dates like TrieDateField and a "[ TO ]" syntax for ranges
        * https://cwiki.apache.org/confluence/display/solr/Working+with+Dates
    -->
    <xsl:template name="solr_field_date_facet">
        <xsl:param name="prefix"/>
        <xsl:param name="pointDate"/>
        <xsl:param name="fromDate"/>
        <xsl:param name="toDate"/>
        <xsl:param name="textDate"/>
        
        <!-- if only textDate (i.e., no attribute) then discard and don't try to parse. -->
        
        <!-- convert to ISO8601 -->
        <xsl:variable name="local_pointDate">
            <xsl:if test="$pointDate!=''">
                <xsl:call-template name="get_ISO8601_date">
                    <xsl:with-param name="date" select="$pointDate"/>
                    <xsl:with-param name="pid" select="'not provided'"/>
                    <xsl:with-param name="datastream" select="'not provided'"/>
                </xsl:call-template>
            </xsl:if>
        </xsl:variable>
        
        <xsl:variable name="local_fromDate">
            <xsl:if test="$fromDate!=''">
                <xsl:call-template name="get_ISO8601_date">
                    <xsl:with-param name="date" select="$fromDate"/>
                    <xsl:with-param name="pid" select="'not provided'"/>
                    <xsl:with-param name="datastream" select="'not provided'"/>
                </xsl:call-template>
            </xsl:if>
        </xsl:variable>
        
        <xsl:variable name="local_toDate">
            <xsl:if test="$toDate!=''">
                <xsl:call-template name="get_ISO8601_date">
                    <xsl:with-param name="date" select="$toDate"/>
                    <xsl:with-param name="pid" select="'not provided'"/>
                    <xsl:with-param name="datastream" select="'not provided'"/>
                </xsl:call-template>
            </xsl:if>
        </xsl:variable>
        
        <!-- build Solr field content value -->
        <xsl:variable name="local_content">
            <xsl:choose>
                <xsl:when test="$local_pointDate!=''">
                    <xsl:value-of select="$local_pointDate"/>
                </xsl:when>
                <xsl:when test="$local_fromDate!='' and $local_toDate!=''">
                    <xsl:text>[</xsl:text>
                    <xsl:value-of select="$local_fromDate"/>
                    <xsl:text> TO </xsl:text>
                    <xsl:value-of select="$local_toDate"/>
                    <xsl:text>]</xsl:text>
                </xsl:when>
                <xsl:when test="$local_fromDate!=''">
                    <xsl:text>[</xsl:text>
                    <xsl:value-of select="$local_fromDate"/>
                    <xsl:text> TO </xsl:text>
                    <xsl:text>]</xsl:text>
                </xsl:when>
                <xsl:when test="$local_toDate!=''">
                    <xsl:text>[</xsl:text>
                    <xsl:text> TO </xsl:text>
                    <xsl:value-of select="$local_toDate"/>
                    <xsl:text>]</xsl:text>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:text/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        
        <!-- output Solr field element -->
        <xsl:if test="$local_content != ''">
            <field>
                <xsl:attribute name="name">
                    <xsl:value-of select="concat($prefix, 'facet_date', '_mdt')"/>
                </xsl:attribute>
                <xsl:value-of select="$local_content"/>
            </field>
        </xsl:if>
    </xsl:template>
    
    

    <!--
    * Given an Orlando normalized narrative date
    * in the form of 
    * day month year - e.g. 6 June 1994
    * or month day, year - e.g. June 6, 1994
    * convert to ISO8601 (e.g., YYYY-MM-DD) date
    -->
    <xsl:template name="cwrc_parse_orlando_narrative_date">
        <xsl:param name="content"/>

        <!-- xslt version 1.0 easier in version 2.0 becuase can use regular expressions -->
        <xsl:variable name="lower" select="'abcdefghijklmnopqrstuvwxyz'"/>
        <xsl:variable name="upper" select="'ABCDEFGHIJKLMNOPQRSTUVWXYZ'"/>
        <xsl:variable name="digit" select="'0123456789'"/>

        <!-- BROKEN XSLT version 1.0 -->
        <!-- <xsl:for-each select="tokenize($content, ' ')">
            <xsl:sort select="position()" data-type="number" order="descending"/>
             -->

            <xsl:variable name="date_no_comma_token">
                <xsl:value-of select="translate(',',.,'')" />
            </xsl:variable>

            <xsl:variable name="date_narrative_token">
                <xsl:if test="not(contains($digit,$date_no_comma_token))">
                    <xsl:value-of select="."/>
                </xsl:if>
            </xsl:variable>

            <xsl:choose>
                <!-- year YYYY -->
                <xsl:when test="
                    position()=1 
                    and contains($digit,$date_no_comma_token) 
                    and string-length($date_no_comma_token)=4
                    ">
                    <xsl:value-of select="."/>
                </xsl:when>
                <!-- month in abv form or character form -->
                <xsl:when test="
                    (position()=3 or position()=2)
                    and not(contains($digit,$date_narrative_token)) 
                    and string-length($date_narrative_token)>0
                    ">
                    <xsl:if test="$date_narrative_token!=''">
                        <xsl:text>-</xsl:text>
                        <xsl:call-template name="cwrc_convert_text_to_numeric">
                            <xsl:with-param name="date_month_string" select="$date_narrative_token"/>
                        </xsl:call-template>
                     </xsl:if>
                </xsl:when>
                <!-- day DD -->
                <xsl:when test="
                    (position()=3 or position()=2) 
                    and contains($digit,$date_no_comma_token) 
                    ">
                    <xsl:variable name="tmp_day">
                        <!-- attempt to handle June 6th by removing 'th'-->
                        <xsl:value-of select="translate($lower,$date_no_comma_token,'')"/>                        
                    </xsl:variable>
                    <xsl:if test="$tmp_day!=''">
                        <xsl:text>-</xsl:text>
                        <xsl:if test="string-length($tmp_day)=1">
                            <xsl:text>0</xsl:text>
                        </xsl:if>
                        <xsl:value-of select="$tmp_day"></xsl:value-of>
                    </xsl:if>

                </xsl:when>
                <xsl:otherwise>
                    <xsl:text/>
                </xsl:otherwise>
            </xsl:choose>

            <!-- </xsl:for-each> -->

    </xsl:template>


    <!-- 
        convert from a month string to a month number
            "January": "01" 
    , "February": "02" 
    , "March": "03" 
    , "April": "04" 
    , "May": "05" 
    , "June": "06" 
    , "July": "07" 
    , "August": "08" 
    , "September": "09" 
    , "October": "10" 
    , "November": "11" 
    , "December": "12" 
    , "janvier": "01" 
    , "février": "02" 
    , "mars": "03" 
    , "avril": "04" 
    , "mai": "05" 
    , "juin": "06" 
    , "juillet": "07" 
    , "août": "08" 
    , "september": "09" 
    , "octobre": "10" 
    , "novembre": "11" 
    , "décembre": "12" 
    -->
    <xsl:template name="cwrc_convert_text_to_numeric">
        <xsl:param name="date_month_string"/>

        <xsl:variable name="lowercase" select="'abcdefghijklmnopqrstuvwxyz'"/>
        <xsl:variable name="uppercase" select="'ABCDEFGHIJKLMNOPQRSTUVWXYZ'"/>

        <xsl:variable name="date_month_lower" select="translate($date_month_string, $uppercase, $lowercase)"/>

        <xsl:choose>
            <xsl:when test="$date_month_lower='january'">01</xsl:when>
            <xsl:when test="$date_month_lower='february'">02</xsl:when>
            <xsl:when test="$date_month_lower='march'">03</xsl:when>
            <xsl:when test="$date_month_lower='april'">04</xsl:when>
            <xsl:when test="$date_month_lower='may'">05</xsl:when>
            <xsl:when test="$date_month_lower='june'">06</xsl:when>
            <xsl:when test="$date_month_lower='july'">07</xsl:when>
            <xsl:when test="$date_month_lower='august'">08</xsl:when>
            <xsl:when test="$date_month_lower='september'">09</xsl:when>
            <xsl:when test="$date_month_lower='october'">10</xsl:when>
            <xsl:when test="$date_month_lower='november'">11</xsl:when>
            <xsl:when test="$date_month_lower='december'">12</xsl:when>
            <xsl:when test="$date_month_lower='janvier'">01</xsl:when>
            <xsl:when test="$date_month_lower='février'">02</xsl:when>
            <xsl:when test="$date_month_lower='mars'">03</xsl:when>
            <xsl:when test="$date_month_lower='avril'">04</xsl:when>
            <xsl:when test="$date_month_lower='mai'">05</xsl:when>
            <xsl:when test="$date_month_lower='juin'">06</xsl:when>
            <xsl:when test="$date_month_lower='juillet'">07</xsl:when>
            <xsl:when test="$date_month_lower='août'">08</xsl:when>
            <xsl:when test="$date_month_lower='september'">09</xsl:when>
            <xsl:when test="$date_month_lower='octobre'">10</xsl:when>
            <xsl:when test="$date_month_lower='novembre'">11</xsl:when>
            <xsl:when test="$date_month_lower='décembre'">12</xsl:when>
        </xsl:choose>
    </xsl:template>


    <!-- change Orlando Legacy Doc Archive date into ISO8601 Dates - DEPRECATED-->
    <xsl:template name="cwrc_orlando_date_repair">
        <xsl:param name="date"/>

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
        <xsl:variable name="trim_date" select="normalize-space($date)"/>
        <xsl:choose>
            <xsl:when test="substring($trim_date,string-length($trim_date),string-length($trim_date))='-'">
                <xsl:variable name="remove_last_char" select="substring($trim_date,0,string-length($trim_date))"/>
                <xsl:choose>
                    <xsl:when test="substring($remove_last_char, string-length($remove_last_char), string-length($remove_last_char))='-'">
                        <xsl:value-of select="substring($remove_last_char, 0, string-length($remove_last_char))"/>
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
