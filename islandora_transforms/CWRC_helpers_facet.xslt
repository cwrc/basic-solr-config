<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:SimpleDateFormat="java.text.SimpleDateFormat" xmlns:Date="java.util.Date" exclude-result-prefixes="SimpleDateFormat Date xs" version="1.0">

    <xsl:output method="text"/>

    <xsl:template match="/">

        <xsl:call-template name="cwrc_convert_point_date_to_period">
            <xsl:with-param name="point_date">9876</xsl:with-param>
        </xsl:call-template>
        <xsl:text>&#xa;</xsl:text>
        <xsl:call-template name="cwrc_convert_point_date_to_period">
            <xsl:with-param name="point_date">9876-01</xsl:with-param>
        </xsl:call-template>
        <xsl:text>&#xa;</xsl:text>
        <xsl:call-template name="cwrc_convert_point_date_to_period">
            <xsl:with-param name="point_date">9876-01-01</xsl:with-param>
        </xsl:call-template>
        <xsl:text>&#xa;</xsl:text>
        <xsl:call-template name="cwrc_convert_point_date_to_period">
            <xsl:with-param name="point_date">876-01</xsl:with-param>
        </xsl:call-template>
        <xsl:text>&#xa;</xsl:text>
        <xsl:call-template name="cwrc_convert_point_date_to_period">
            <xsl:with-param name="point_date">0876-01</xsl:with-param>
        </xsl:call-template>
        <xsl:text>&#xa;</xsl:text>
        <xsl:call-template name="cwrc_convert_point_date_to_period">
            <xsl:with-param name="point_date">-9876</xsl:with-param>
        </xsl:call-template>
        <xsl:text>&#xa;</xsl:text>
        <xsl:call-template name="cwrc_convert_point_date_to_period">
            <xsl:with-param name="point_date">-9876-01</xsl:with-param>
        </xsl:call-template>

        <xsl:text>&#xa;</xsl:text>
        <xsl:call-template name="cwrc_convert_range_date_to_period">
            <xsl:with-param name="from_date">2011</xsl:with-param>
            <xsl:with-param name="to_date">2000</xsl:with-param>
        </xsl:call-template>

        <xsl:text>&#xa;</xsl:text>
        <xsl:call-template name="cwrc_convert_range_date_to_period">
            <xsl:with-param name="from_date">1000</xsl:with-param>
            <xsl:with-param name="to_date">1011</xsl:with-param>
        </xsl:call-template>

        <xsl:text>&#xa;</xsl:text>
        <xsl:call-template name="cwrc_convert_range_date_to_period">
            <xsl:with-param name="from_date">2010</xsl:with-param>
            <xsl:with-param name="to_date">2015</xsl:with-param>
        </xsl:call-template>

        <xsl:text>&#xa;</xsl:text>
        <xsl:call-template name="cwrc_convert_range_date_to_period">
            <xsl:with-param name="from_date">2000</xsl:with-param>
            <xsl:with-param name="to_date"/>
        </xsl:call-template>


    </xsl:template>


    <!-- create YYYY mask - to be used with number-format -->
    <xsl:variable name="cwrc_year_four_digit" select="'#0000'"/>


    <!-- Build Solr field for a given point date - date facet
        * assume ISO8601 formatted date
        * care taken to handle both BC and AD dates
    -->
    <xsl:template name="cwrc_convert_point_date_to_period">
        <xsl:param name="point_date" select="''"/>

        <!-- extract year from ISO 8601 date -->
        <xsl:variable name="year_str">
            <xsl:call-template name="cwrc_create_ISO_8601_to_BCE_AD_year">
                <xsl:with-param name="point_date" select="$point_date"/>
            </xsl:call-template>
        </xsl:variable>

        <!-- start of date interval -->
        <xsl:variable name="fromYear">
            <xsl:call-template name="cwrc_date_interval_start">
                <xsl:with-param name="year_str" select="$year_str"/>
            </xsl:call-template>
        </xsl:variable>

        <!-- end of date interval -->
        <xsl:variable name="toYear">
            <xsl:call-template name="cwrc_date_interval_end">
                <xsl:with-param name="year_str" select="$year_str"/>
            </xsl:call-template>
        </xsl:variable>
        <xsl:call-template name="cwrc_write_solr_field">
            <xsl:with-param name="local_content">
                <xsl:value-of select="concat($fromYear, ' TO ', $toYear)"/>
            </xsl:with-param>
        </xsl:call-template>

    </xsl:template>


    <!-- build the Solr fields for a given range - date facet -->
    <xsl:template name="cwrc_convert_range_date_to_period">
        <xsl:param name="from_date" select="''"/>
        <xsl:param name="to_date" select="''"/>

        <xsl:choose>
            <xsl:when test="$from_date='' and $to_date!=''">
                <!-- only the to_date therefor treat to_date as a point date
                    can't see how to go from the beginning of time to to_date  -->
                <xsl:call-template name="cwrc_convert_point_date_to_period">
                    <xsl:with-param name="point_date">
                        <xsl:value-of select="$to_date"/>
                    </xsl:with-param>
                </xsl:call-template>
            </xsl:when>
            <xsl:when test="$from_date!='' and $to_date=''">
                <!-- only the from_date therefor create intervals from $from_date to NOW -->
                <xsl:call-template name="cwrc_create_intervals_from_to_date">
                    <xsl:with-param name="from_date" select="$from_date"/>
                    <xsl:with-param name="to_date" select="''"/>
                </xsl:call-template>
            </xsl:when>
            <xsl:otherwise>
                <!-- boh from and to dates -->
                <xsl:call-template name="cwrc_create_intervals_from_to_date">
                    <xsl:with-param name="from_date" select="$from_date"/>
                    <xsl:with-param name="to_date" select="$to_date"/>
                </xsl:call-template>
            </xsl:otherwise>
        </xsl:choose>

    </xsl:template>


    <!-- write the given content as the value of a Solr field -->
    <xsl:template name="cwrc_write_solr_field">
        <xsl:param name="local_content"/>
        <xsl:param name="prefix" select="'cwrc_'"/>

        <!-- output Solr field element -->
        <xsl:if test="$local_content != ''">
            <field>
                <xsl:attribute name="name">
                    <!--
                    <xsl:value-of select="concat($prefix, 'facet_date', '_mdt')"/>
                    -->
                    <xsl:value-of select="concat($prefix, 'facet_date', '_mt')"/>
                </xsl:attribute>
                <xsl:value-of select="$local_content"/>
            </field>
        </xsl:if>
    </xsl:template>

    <!-- 
        create multiple intervals between the to_date and from_date
        * if from is greater than to date then don't try to correct
    -->
    <xsl:template name="cwrc_create_intervals_from_to_date" xmlns:date="java:java.util.Date">
        <xsl:param name="from_date"/>
        <xsl:param name="to_date"/>

        <!-- start year -->
        <xsl:variable name="fromYear">
            <xsl:call-template name="cwrc_date_interval_start">
                <xsl:with-param name="year_str" select="$from_date"/>
            </xsl:call-template>
        </xsl:variable>

        <!-- end year -->
        <xsl:variable name="tmpToYear">
            <xsl:call-template name="cwrc_date_interval_end">
                <xsl:with-param name="year_str" select="$to_date"/>
            </xsl:call-template>
        </xsl:variable>

        <xsl:variable name="toYear">
            <xsl:choose>
                <xsl:when test="$tmpToYear=''">
                    <!-- get today's year -->
                    <xsl:variable name="s" select="SimpleDateFormat:new('yyyy')"/>
                    <xsl:variable name="date" select="Date:new()"/>
                    <xsl:value-of select="SimpleDateFormat:format($s,$date)"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="$tmpToYear"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>

        <xsl:call-template name="cwrc_create_intervals_recursively">
            <xsl:with-param name="start_year" select="$fromYear"/>
            <xsl:with-param name="end_year" select="$toYear"/>
            <xsl:with-param name="open_ended_range">
                <xsl:choose>
                    <xsl:when test="$tmpToYear=''">1</xsl:when>
                    <xsl:otherwise/>
                </xsl:choose>
            </xsl:with-param>
        </xsl:call-template>

    </xsl:template>


    <!-- create a list of interval recursively -->
    <xsl:template name="cwrc_create_intervals_recursively">
        <xsl:param name="start_year"/>
        <xsl:param name="end_year"/>
        <xsl:param name="open_ended_range"/>

        <xsl:choose>
            <xsl:when test="number($start_year) &lt;= number($end_year)">
                <xsl:variable name="interval_end_year" select="number($start_year)+10"/>
                <xsl:choose>
                    <xsl:when test="number($interval_end_year) &gt; number($end_year) and $open_ended_range!=''">
                        <xsl:call-template name="cwrc_write_solr_field">
                            <xsl:with-param name="local_content">
                                <xsl:value-of select="concat($start_year, ' TO NOW')"/>
                            </xsl:with-param>
                        </xsl:call-template>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:call-template name="cwrc_write_solr_field">
                            <xsl:with-param name="local_content">
                                <xsl:value-of select="concat($start_year, ' TO ', $interval_end_year)"/>
                            </xsl:with-param>
                        </xsl:call-template>
                    </xsl:otherwise>
                </xsl:choose>

                <xsl:call-template name="cwrc_create_intervals_recursively">
                    <xsl:with-param name="start_year" select="$interval_end_year"/>
                    <xsl:with-param name="end_year" select="$end_year"/>
                    <xsl:with-param name="open_ended_range" select="$open_ended_range"/>
                </xsl:call-template>
            </xsl:when>
            <xsl:otherwise>
                <xsl:text/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>


    <!-- extract the year from an ISO 8601 date -->
    <xsl:template name="cwrc_create_ISO_8601_to_BCE_AD_year">
        <xsl:param name="point_date"/>

        <!-- extract year from ISO 8601 date -->
        <xsl:variable name="yearStr">
            <xsl:choose>
                <xsl:when test="starts-with($point_date,'-')">
                    <!-- remove negative sign indicating BCE -->
                    <xsl:variable name="remove_BCE" select="substring($point_date,2,string-length())"/>
                    <!-- get year -->
                    <xsl:variable name="year_only">
                        <xsl:call-template name="cwrc_create_ISO_8601_year">
                            <xsl:with-param name="point_date" select="$remove_BCE"/>
                        </xsl:call-template>
                    </xsl:variable>
                    <!-- concat '-' and year -->
                    <xsl:value-of select="concat('-', $year_only)"/>
                </xsl:when>
                <xsl:otherwise>
                    <!-- AD date -->
                    <xsl:call-template name="cwrc_create_ISO_8601_year">
                        <xsl:with-param name="point_date" select="$point_date"/>
                    </xsl:call-template>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>

        <!-- prepend 0 to make year 4 digits -->
        <xsl:value-of select="format-number(number($yearStr), '#0000')"/>

    </xsl:template>


    <!-- given an ISO 8601 date, return the year portion -->
    <xsl:template name="cwrc_create_ISO_8601_year">
        <xsl:param name="point_date"/>

        <xsl:choose>
            <!-- AD date e.g. YYYY-MM-DD -->
            <xsl:when test="contains($point_date,'-')">
                <xsl:value-of select="substring-before($point_date,'-')"/>
            </xsl:when>
            <!-- AD date - year only e.g. YYYY or maybe only year 689 -->
            <xsl:otherwise>
                <xsl:value-of select="substring($point_date,1,string-length($point_date))"/>
            </xsl:otherwise>
        </xsl:choose>

    </xsl:template>


    <!-- create the start of the interval -->
    <xsl:template name="cwrc_date_interval_start">
        <xsl:param name="year_str"/>

        <!-- replace last character with 0 or 9 (from and to respectively) -->
        <!-- start of date interval: use 'div 10' and floor -->
        <xsl:choose>
            <xsl:when test="string(number($year_str))!='NaN'">
                <xsl:value-of select="format-number(floor(number($year_str) div 10)*10,$cwrc_year_four_digit)"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:text/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>


    <!-- create the end of the interval -->
    <xsl:template name="cwrc_date_interval_end">
        <xsl:param name="year_str"/>

        <!-- end of date interval: use 'div 10' and ceiling -->
        <xsl:choose>
            <xsl:when test="string(number($year_str))!='NaN'">
                <xsl:value-of select="format-number(ceiling(number($year_str) div 10)*10,$cwrc_year_four_digit)"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:text/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>



</xsl:stylesheet>
