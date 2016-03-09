<?xml version="1.0" encoding="UTF-8"?>                                                  
<!-- 
    CWRC helpers
    * GeoLocation
    * Orlando dates

-->
 
<xsl:stylesheet version="2.0" 
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
    xmlns:foxml="info:fedora/fedora-system:def/foxml#" 
    xmlns:xlink="http://www.w3.org/1999/xlink" 
    xmlns:mods="http://www.loc.gov/mods/v3" 
    xmlns:java="http://xml.apache.org/xalan/java" 
    exclude-result-prefixes="java mods"
    >

    <xsl:output method="xml"/>

    <xsl:variable name="CWRC_GEOLOC_PROT">http</xsl:variable>
    <xsl:variable name="CWRC_GEOLOC_HOST">beta.cwrc.ca</xsl:variable>
    <xsl:variable name="CWRC_GEOLOC_PORT">80</xsl:variable>
    <xsl:variable name="CWRC_GEOLOC_URN">/CWRC-MTP/geonames</xsl:variable>



    <!-- 
         test for the presence of the MODS temporal subject to 
         determine whether to use it or the content dates
    -->
    <xsl:template match="foxml:datastream[@ID='MODS']/foxml:datastreamVersion[last()]" mode="cwrc_date_facet_period_source">

        <xsl:param name="content" select="."/>

        <xsl:choose>
            <xsl:when test="$content/mods:mods/mods:subject/mods:temporal/text()!=''">
                <xsl:text>1</xsl:text>
            </xsl:when>
            <xsl:otherwise>
                <xsl:text></xsl:text>
            </xsl:otherwise>
        </xsl:choose>

    </xsl:template>


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

        <xsl:variable name="local_textDate">
            <xsl:if test="$textDate!='' and $local_pointDate='' and $local_fromDate='' and $local_toDate=''">
                <!-- try to interpret the text date -->
                <xsl:call-template name="get_ISO8601_date">
                    <xsl:with-param name="date" select="$textDate"/>
                    <xsl:with-param name="pid" select="'not provided'"/>
                    <xsl:with-param name="datastream" select="'not provided'"/>
                </xsl:call-template>
            </xsl:if>
        </xsl:variable>


        <!-- build Solr field content value -->
            <xsl:choose>
                <xsl:when test="$local_pointDate!=''">
                    <xsl:call-template name="cwrc_convert_point_date_to_period">
                        <xsl:with-param name="point_date" select="$local_pointDate" />
                    </xsl:call-template>
                    <!--
                    <xsl:value-of select="$local_pointDate"/>
                    -->
                </xsl:when>
                <xsl:when test="$local_fromDate!='' and $local_toDate!=''">
                    <xsl:call-template name="cwrc_convert_range_date_to_period">
                        <xsl:with-param name="from_date" select="$local_fromDate" />
                        <xsl:with-param name="to_date" select="$local_toDate" />
                    </xsl:call-template>
                    <!--
                    <xsl:text>[</xsl:text>
                    <xsl:value-of select="$local_fromDate"/>
                    <xsl:text> TO </xsl:text>
                    <xsl:value-of select="$local_toDate"/>
                    <xsl:text>]</xsl:text>
                    -->
                </xsl:when>
                <xsl:when test="$local_fromDate!=''">
                    <xsl:call-template name="cwrc_convert_range_date_to_period">
                        <xsl:with-param name="from_date" select="$local_fromDate" />
                        <xsl:with-param name="to_date" select="''" />
                    </xsl:call-template>
                    <!--
                    <xsl:text>[</xsl:text>
                    <xsl:value-of select="$local_fromDate"/>
                    <xsl:text> TO </xsl:text>
                    <xsl:text>]</xsl:text>
                    -->
                </xsl:when>
                <xsl:when test="$local_toDate!=''">
                    <!-- 
                    <xsl:text>[</xsl:text>
                    <xsl:text> TO </xsl:text>
                    <xsl:value-of select="$local_toDate"/>
                    <xsl:text>]</xsl:text>
                     -->
                </xsl:when>
                <xsl:when test="$local_textDate!=''">
                    <xsl:call-template name="cwrc_convert_point_date_to_period">
                        <xsl:with-param name="point_date" select="$local_textDate" />
                    </xsl:call-template>
                </xsl:when>
                <xsl:when test="$local_textDate='' and $textDate!=''">
                    <!-- text date not in an recognized format -->
                    <!-- try interpreting as a Season -->
                    <!-- "textDate='' and $local_pointDate='' and $local_fromDate='' and $local_toDate=''-->
                    <xsl:call-template name="cwrc_season_date">
                        <xsl:with-param name="src_date" select="$textDate" />
                    </xsl:call-template>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:text/>
                </xsl:otherwise>
            </xsl:choose>
        
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
            <xsl:choose>
                <xsl:when test="$year_str = $fromYear">
                    <!-- nudge number: otherwise floor and ceiling return the same -->
                    <xsl:call-template name="cwrc_date_interval_end">
                        <xsl:with-param name="year_str" select="number($year_str)+.1"/>
                    </xsl:call-template>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:call-template name="cwrc_date_interval_end">
                        <xsl:with-param name="year_str" select="$year_str"/>
                    </xsl:call-template>
                </xsl:otherwise>
            </xsl:choose>
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

    <!--
    <xsl:value-of select="concat($prefix, 'facet_date', '_mdt')"/>
    -->

        <!-- output Solr field element -->
        <xsl:if test="$local_content != ''">
            <field>
                <xsl:attribute name="name">
                   <xsl:value-of select="concat($prefix, 'facet_date', '_ms')"/>
                </xsl:attribute>
                <xsl:value-of select="$local_content"/>
            </field>
        </xsl:if>
    </xsl:template>
    
    <!-- 
        create multiple intervals between the to_date and from_date
        * if from is greater than to date then don't try to correct
    -->
    <xsl:template name="cwrc_create_intervals_from_to_date">
        <xsl:param name="from_date"/>
        <xsl:param name="to_date"/>
        
        <!-- start year -->
        <xsl:variable name="fromYear">
            <xsl:call-template name="cwrc_date_interval_start">
                <xsl:with-param name="year_str">
                    <xsl:call-template name="cwrc_create_ISO_8601_to_BCE_AD_year">
                        <xsl:with-param name="point_date" select="$from_date"/>
                    </xsl:call-template>
                </xsl:with-param>
            </xsl:call-template>
        </xsl:variable>
        
        <!-- end year -->
        <xsl:variable name="toYear">
            <xsl:choose>
                <xsl:when test="$to_date=''">
                    <!-- requires https://github.com/cwrc/dgi_gsearch_extensions-->
                    <!-- get today's year -->
                    <!-- This technique didn't work in the context of FedoraGSearch
                         Error at xsl:variable on line 275 column 83 of 
                         CWRC_helpers.xslt: XPST0017 XPath syntax error at 
                         char 0 on line 275 in 
                         {SimpleDateFormat:new('yyyy')}: 
                         Cannot find a matching 1-argument function named {java.text.SimpleDateFormat}new().
                         Note that direct calls to Java methods are not 
                         available under Saxon-HE


                        http://stackoverflow.com/questions/13136229/xslt-call-java-instance-method 
                        http://cafeconleche.org/books/xmljava/chapters/ch17s03.html
                        http://www.heber.it/?p=1053/
                        xmlns:SimpleDateFormat="java.text.SimpleDateFormat" 
                        xmlns:Date="java.util.Date" 
                        xmlns:date="java:java.util.Date"
                        <xsl:variable name="s" select="java:java.text.SimpleDateFormat:new('yyyy')"/>
                        <xsl:variable name="date" select="Date:new()"/>
                        <xsl:value-of select="SimpleDateFormat:format($s,$date)"/>
                        might be due to how xalan was setup
                        https://saxonica.plan.io/boards/3/topics/5389
                    -->
                    <!-- <xsl:value-of select="'2016'" /> -->
                    <xsl:call-template name='get_todays_year' />
                </xsl:when>
                <xsl:otherwise>
                    <xsl:call-template name="cwrc_create_ISO_8601_to_BCE_AD_year">
                        <xsl:with-param name="point_date" select="$to_date"/>
                    </xsl:call-template>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        
        <xsl:call-template name="cwrc_create_intervals_recursively">
            <xsl:with-param name="start_year" select="$fromYear"/>
            <xsl:with-param name="end_year" select="$toYear"/>
            <xsl:with-param name="open_ended_range">
                <xsl:choose>
                    <xsl:when test="$to_date=''">1</xsl:when>
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
                <xsl:variable name="interval_end_year" select="format-number(number($start_year)+10-1,$cwrc_year_four_digit)"/>
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
                    <xsl:with-param name="start_year" select="format-number(number($interval_end_year)+1,$cwrc_year_four_digit)"/>
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
        <xsl:value-of select="format-number(number($yearStr),$cwrc_year_four_digit)"/>
        
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
            <!-- test if number -->
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
                <xsl:value-of select="format-number(ceiling(number($year_str) div 10)*10-1,$cwrc_year_four_digit)"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:text/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>


    <!-- given a date of the form: season 2010 (e.g. printemps 2012) convert to an Solr date interval field -->
    <xsl:template name="cwrc_season_date">
        <xsl:param name="src_date" />
        
        <xsl:variable name="smallcase" select="'abcdefghijklmnopqrstuvwxyzé'" />
        <xsl:variable name="uppercase" select="'ABCDEFGHIJKLMNOPQRSTUVWXYZÉ'" />
        
        <xsl:variable name="lower_src_date" select="translate($src_date,$uppercase,$smallcase)" />
        
        <xsl:choose>
            <xsl:when test="contains($lower_src_date,'summer')">
                <xsl:variable name="yearStr" select="normalize-space(substring-after($lower_src_date, 'summer'))" />
                <xsl:call-template name="cwrc_convert_range_date_to_period">
                    <xsl:with-param name="from_date" select="concat($yearStr,'-07')" />
                    <xsl:with-param name="to_date" select="concat($yearStr,'-09')" />
                </xsl:call-template>
            </xsl:when>
            <xsl:when test="contains($lower_src_date,'été')">
                <xsl:variable name="yearStr" select="normalize-space(substring-after($lower_src_date, 'été'))" />
                <xsl:call-template name="cwrc_convert_range_date_to_period">
                    <xsl:with-param name="from_date" select="concat($yearStr,'-07')" />
                    <xsl:with-param name="to_date" select="concat($yearStr,'-09')" />
                </xsl:call-template>
            </xsl:when>
            <xsl:when test="contains($lower_src_date,'fall')">
                <xsl:variable name="yearStr" select="normalize-space(substring-after($lower_src_date, 'fall'))" />
                <xsl:call-template name="cwrc_convert_range_date_to_period">
                    <xsl:with-param name="from_date" select="concat($yearStr,'-10')" />
                    <xsl:with-param name="to_date" select="concat($yearStr,'-12')" />
                </xsl:call-template>
            </xsl:when>
            <xsl:when test="contains($lower_src_date,'autumn')">
                <xsl:variable name="yearStr" select="normalize-space(substring-after($lower_src_date, 'autumn'))" />
                <xsl:call-template name="cwrc_convert_range_date_to_period">
                    <xsl:with-param name="from_date" select="concat($yearStr,'-10')" />
                    <xsl:with-param name="to_date" select="concat($yearStr,'-12')" />
                </xsl:call-template>
            </xsl:when>
            <xsl:when test="contains($lower_src_date,'tomber')">
                <xsl:variable name="yearStr" select="normalize-space(substring-after($lower_src_date, 'tomber'))" />
                <xsl:call-template name="cwrc_convert_range_date_to_period">
                    <xsl:with-param name="from_date" select="concat($yearStr,'-10')" />
                    <xsl:with-param name="to_date" select="concat($yearStr,'-12')" />
                </xsl:call-template>
            </xsl:when>
            <xsl:when test="contains($lower_src_date,'automne')">
                <xsl:variable name="yearStr" select="normalize-space(substring-after($lower_src_date, 'automne'))" />
                <xsl:call-template name="cwrc_convert_range_date_to_period">
                    <xsl:with-param name="from_date" select="concat($yearStr,'-10')" />
                    <xsl:with-param name="to_date" select="concat($yearStr,'-12')" />
                </xsl:call-template>
            </xsl:when>
            <xsl:when test="contains($lower_src_date,'winter')">
                <xsl:variable name="yearStr" select="normalize-space(substring-after($lower_src_date, 'winter'))" />
                <xsl:call-template name="cwrc_convert_range_date_to_period">
                    <xsl:with-param name="from_date" select="concat($yearStr,'-01')" />
                    <xsl:with-param name="to_date" select="concat($yearStr,'-03')" />
                </xsl:call-template>
            </xsl:when>
            <xsl:when test="contains($lower_src_date,'hiver')">
                <xsl:variable name="yearStr" select="normalize-space(substring-after($lower_src_date, 'hiver'))" />
                <xsl:call-template name="cwrc_convert_range_date_to_period">
                    <xsl:with-param name="from_date" select="concat($yearStr,'-01')" />
                    <xsl:with-param name="to_date" select="concat($yearStr,'-03')" />
                </xsl:call-template>
            </xsl:when>
            <xsl:when test="contains($lower_src_date,'spring')">
                <xsl:variable name="yearStr" select="normalize-space(substring-after($lower_src_date, 'spring'))" />
                <xsl:call-template name="cwrc_convert_range_date_to_period">
                    <xsl:with-param name="from_date" select="concat($yearStr,'-04')" />
                    <xsl:with-param name="to_date" select="concat($yearStr,'-06')" />
                </xsl:call-template>
            </xsl:when>
            <xsl:when test="contains($lower_src_date,'printempts')">
                <xsl:variable name="yearStr" select="normalize-space(substring-after($lower_src_date, 'printemps'))" />
                <xsl:call-template name="cwrc_convert_range_date_to_period">
                    <xsl:with-param name="from_date" select="concat($yearStr,'-04')" />
                    <xsl:with-param name="to_date" select="concat($yearStr,'-06')" />
                </xsl:call-template>
            </xsl:when>
        </xsl:choose>
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

