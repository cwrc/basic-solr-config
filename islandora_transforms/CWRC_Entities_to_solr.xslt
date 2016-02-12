<?xml version="1.0" encoding="UTF-8"?>

<!-- Basic CWRC Entities - transform for Solr -->

<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:foxml="info:fedora/fedora-system:def/foxml#" xmlns:xlink="http://www.w3.org/1999/xlink" xmlns:mods="http://www.loc.gov/mods/v3" exclude-result-prefixes="mods">
    <!--

    <xsl:include href="/usr/local/fedora/tomcat/webapps/fedoragsearch/WEB-INF/classes/fgsconfigFinal/index/FgsIndex/islandora_transforms/CWRC_GeoLoc.xslt" />

    -->

    <!-- this template used to help test  -->

    <!-- 
    <xsl:template match="/">
            <xsl:apply-templates select="/foxml:digitalObject/foxml:datastream[@ID='TITLE']/foxml:datastreamVersion[last()]">
                <xsl:with-param name="content" select="/foxml:digitalObject/foxml:datastream[@ID='TITLE']/foxml:datastreamVersion[last()]/foxml:xmlContent"></xsl:with-param>
        </xsl:apply-templates>

    </xsl:template>
 -->


    <!-- ********************************************************* -->
    <!-- CWRC PLACE Entity solr index Fedora Datastream -->
    <!-- ********************************************************* -->
    <xsl:template match="foxml:datastream[@ID='PLACE']/foxml:datastreamVersion[last()]" name="index_CWRC_PLACE_ENTITY">

        <xsl:param name="content" select="entity/place"/>
        <xsl:param name="prefix" select="'cwrc_entity_'"/>
        <xsl:param name="suffix" select="'_et'"/>
        <!-- 'edged' (edge n-gram) text, for auto-completion -->

        <xsl:variable name="identity" select="$content/entity/place/identity"/>
        <xsl:variable name="description" select="$content/entity/place/description"/>
        <xsl:variable name="recordInfo" select="$content/entity/place/recordInfo"/>
        <xsl:variable name="local_prefix" select="concat($prefix, 'place_')"/>

        <!-- ensure that the preferred name is first -->
        <xsl:apply-templates select="$identity/preferredForm">
            <xsl:with-param name="prefix" select="$local_prefix"/>
            <xsl:with-param name="suffix" select="$suffix"/>
        </xsl:apply-templates>

        <!-- Variant forms of the name -->
        <xsl:apply-templates select="$identity/variantForms">
            <xsl:with-param name="prefix" select="$local_prefix"/>
            <xsl:with-param name="suffix" select="$suffix"/>
        </xsl:apply-templates>

        <!-- Descriptive Geo Location - latitude and longitude -->
        <xsl:if test="$description/latitude and $description/longitude">
            <field>
                <xsl:attribute name="name">
                    <xsl:value-of select="concat($local_prefix, 'geoloc', '_s')"/>
                </xsl:attribute>

                <xsl:value-of select="concat($description/latitude, ',', $description/longitude)"/>
            </field>
        </xsl:if>

        <!-- Descriptive Geo Location - country name -->
        <xsl:if test="$description/countryName">
            <field>
                <xsl:attribute name="name">
                    <xsl:value-of select="concat($local_prefix, 'countryName', $suffix)"/>
                </xsl:attribute>

                <xsl:value-of select="$description/countryName"/>
            </field>
        </xsl:if>

        <!-- Descriptive Geo Location - first adminstrative division-->
        <xsl:if test="$description/firstAdministrativeDivision">
            <field>
                <xsl:attribute name="name">
                    <xsl:value-of select="concat($local_prefix, 'firstAdministrativeDivision', $suffix)"/>
                </xsl:attribute>

                <xsl:value-of select="$description/firstAdministrativeDivision"/>
            </field>
        </xsl:if>

        <!-- Descriptive featureClass - -->
        <xsl:if test="$description/featureClass">
            <field>
                <xsl:attribute name="name">
                    <xsl:value-of select="concat($local_prefix, 'featureClass', $suffix)"/>
                </xsl:attribute>

                <xsl:value-of select="$description/featureClass"/>
            </field>
        </xsl:if>

        <!-- access condition -->
        <xsl:call-template name="assemble_cwrc_access_condition">
            <xsl:with-param name="prefix" select="$local_prefix"/>
            <xsl:with-param name="content" select="$recordInfo/accessCondition"/>
        </xsl:call-template>

        <!-- project id -->
        <xsl:call-template name="assemble_cwrc_project_id">
            <xsl:with-param name="prefix" select="$local_prefix"/>
            <xsl:with-param name="content" select="$recordInfo/originInfo/projectId"/>
        </xsl:call-template>

        <!-- factuality -->
        <xsl:call-template name="assemble_cwrc_factuality">
            <xsl:with-param name="prefix" select="$local_prefix"/>
            <xsl:with-param name="content" select="$description/factuality"/>
        </xsl:call-template>

    </xsl:template>


    <!-- ********************************************************* -->
    <!-- CWRC ORGANIZATION Entity solr index Fedora Datastream -->
    <!-- ********************************************************* -->
    <xsl:template match="foxml:datastream[@ID='ORGANIZATION']/foxml:datastreamVersion[last()]" name="index_CWRC_ORGANIZATION_ENTITY">

        <xsl:param name="content" select="entity/organization"/>
        <xsl:param name="prefix" select="'cwrc_entity_'"/>
        <xsl:param name="suffix" select="'_et'"/>
        <!-- 'edged' (edge n-gram) text, for auto-completion -->

        <xsl:variable name="identity" select="$content/entity/organization/identity"/>
        <xsl:variable name="description" select="$content/entity/organization/description"/>
        <xsl:variable name="recordInfo" select="$content/entity/organization/recordInfo"/>
        <xsl:variable name="local_prefix" select="concat($prefix, 'org_')"/>


        <!-- ensure that the preferred name is first -->
        <xsl:apply-templates select="$identity/preferredForm">
            <xsl:with-param name="prefix" select="$local_prefix"/>
            <xsl:with-param name="suffix" select="$suffix"/>
        </xsl:apply-templates>

        <!-- Variant forms of the name -->
        <xsl:apply-templates select="$identity/variantForms">
            <xsl:with-param name="prefix" select="$local_prefix"/>
            <xsl:with-param name="suffix" select="$suffix"/>
        </xsl:apply-templates>

        <!-- access condition -->
        <xsl:call-template name="assemble_cwrc_access_condition">
            <xsl:with-param name="prefix" select="$local_prefix"/>
            <xsl:with-param name="content" select="$recordInfo/accessCondition"/>
        </xsl:call-template>

        <!-- project id -->
        <xsl:call-template name="assemble_cwrc_project_id">
            <xsl:with-param name="prefix" select="$local_prefix"/>
            <xsl:with-param name="content" select="$recordInfo/originInfo/projectId"/>
        </xsl:call-template>

        <!-- factuality -->
        <xsl:call-template name="assemble_cwrc_factuality">
            <xsl:with-param name="prefix" select="$local_prefix"/>
            <xsl:with-param name="content" select="$description/factuality"/>
        </xsl:call-template>

    </xsl:template>



    <!-- ********************************************************* -->
    <!-- CWRC TITLE Entity solr index Fedora Datastream -->
    <!-- ********************************************************* -->
    <xsl:template match="foxml:datastream[@ID='MODS']/foxml:datastreamVersion[last()]" name="index_CWRC_TITLE_ENTITY" mode="cwrc_entities">

        <xsl:param name="content" select="."/>
        <xsl:param name="prefix" select="'cwrc_entity_'"/>
        <xsl:param name="suffix" select="'_et'"/>

        <!-- 'edged' (edge n-gram) text, for auto-completion -->
        <xsl:variable name="identity" select="$content/mods:mods"/>
        <xsl:variable name="local_prefix" select="concat($prefix, 'title_')"/>

        <!-- the preferred/authoritative title (name of title)-->
        <!-- variant titles -->
        <xsl:apply-templates select="$identity/mods:titleInfo" mode="cwrc_entities">
            <xsl:with-param name="prefix" select="$local_prefix"/>
            <xsl:with-param name="suffix" select="$suffix"/>
        </xsl:apply-templates>

        <!-- ensure that the author name -->
        <xsl:apply-templates select="$identity/mods:name" mode="cwrc_entities">
            <xsl:with-param name="prefix" select="$local_prefix"/>
            <xsl:with-param name="suffix" select="$suffix"/>
        </xsl:apply-templates>

        <!--
        Date location logic
        - conditional checks based on priority, first checking monograph whole or periodical issue, then
        monograph chapter, and then periodical article, and in each of these sections checking for dates
        in this order: dateIssued, copyrightDate, and then dateCreated; finally, the part/date is checked
        for periodical articles
 
        Format logic:
        - first check for issuance element value, and then check for the presense of the part element
         Monograph whole:
        issuance: /mods/originInfo/issuance with value equal to "monographic"
        Monograph chapter:
        issuance: /mods/relatedItem/originInfo/issuance with value equal to "monographic"
        Periodical article:
        issuance: /mods/relatedItem/originInfo/issuance with value equal to "continuing"
        Periodical issue:
        issuance: /mods/originInfo/issuance with value equal to "continuing"
        -->
        <xsl:variable name="local_date">
            <!-- * date location logic * -->
            <!-- monograph whole or periodical issue -->
            <xsl:choose>
               <xsl:when test="$identity/mods:originInfo/mods:dateIssued/text()!=''">
                   <xsl:value-of select="$identity/mods:originInfo/mods:dateIssued/text()"/>
               </xsl:when>
            </xsl:choose>
            <xsl:choose>
                <xsl:when test="$identity/mods:originInfo/mods:copyrightDate/text()!=''">
                    <xsl:value-of select="$identity/mods:originInfo/mods:copyrightDate/text()"/>
                </xsl:when>
            </xsl:choose>
            <xsl:choose>
                <xsl:when test="$identity/mods:originInfo/mods:dateCreate/text()!=''">
                    <xsl:value-of select="$identity/mods:originInfo/mods:dateCreated/text()"/>
                </xsl:when>
            </xsl:choose>
            <!-- monograph chapter -->
            <xsl:choose>
                <xsl:when test="$identity/mods:relatedItem/mods:originInfo/mods:dateIssued/text()!=''">
                    <xsl:value-of select="$identity/mods:relatedItem/mods:originInfo/mods:dateIssued/text()"/>
                </xsl:when>
            </xsl:choose>
            <xsl:choose>
                <xsl:when test="$identity/mods:relatedItem/mods:originInfo/mods:copyrightDate/text()!=''">
                    <xsl:value-of select="$identity/mods:relatedItem/mods:originInfo/mods:copyrightDate/text()"/>
                </xsl:when>
            </xsl:choose>
            <xsl:choose>
                <xsl:when test="$identity/mods:relatedItem/mods:originInfo/mods:dateCreate/text()!=''">
                    <xsl:value-of select="$identity/mods:relatedItem/mods:originInfo/mods:dateCreated/text()"/>
                </xsl:when>
            </xsl:choose>
            <!-- periodical article -->
            <xsl:choose>
                <xsl:when test="$identity/mods:relatedItem/mods:part/mods:date/text()!=''">
                    <xsl:value-of select="$identity/mods:relatedItem/mods:part/mods:date/text()"/>
                </xsl:when>
            </xsl:choose>
        </xsl:variable>
        
        <!-- * format conditional logic * -->
        <xsl:variable name="local_format">
            <xsl:choose>
            <xsl:when test="$identity/mods:originInfo/mods:issuance/text()='monographic'">
                <xsl:text>Monographic whole</xsl:text>
            </xsl:when>
            <xsl:when test="$identity/mods:originInfo/mods:issuance/text()='continuing'">
                <xsl:text>Periodical issue</xsl:text>
            </xsl:when>
            <xsl:when test="$identity/mods:relatedItem/mods:originInfo/mods:issuance/text()='monographic'">
                <xsl:text>Monograph chapter</xsl:text>
            </xsl:when>
            <xsl:when test="$identity/mods:relatedItem/mods:originInfo/mods:issuance/text()='continuing'">
                <xsl:text>Periodical article</xsl:text>
            </xsl:when>
            <xsl:when test="$identity/mods:relatedItem/mods:part/text()">
                <xsl:text>Periodical article</xsl:text>
            </xsl:when>
            <xsl:otherwise>
                <xsl:text>Unknown</xsl:text>
            </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        
        
         <xsl:call-template name="assemble_cwrc_title_formats">
              <xsl:with-param name="prefix" select="$local_prefix"/>
              <xsl:with-param name="date" select="$local_date"/>
              <xsl:with-param name="format" select="$local_format"/>
         </xsl:call-template>
            
        <!-- access condition -->
        <xsl:call-template name="assemble_cwrc_access_condition">
            <xsl:with-param name="prefix" select="$local_prefix"/>
            <xsl:with-param name="content" select="$identity/mods:accessCondition"/>
        </xsl:call-template>

        <!-- project id -->
        <xsl:call-template name="assemble_cwrc_project_id">
            <xsl:with-param name="prefix" select="$local_prefix"/>
            <xsl:with-param name="content" select="$identity/mods:recordInfo/mods:recordContentSource/text()"/>
        </xsl:call-template>


        <!-- language facet -->
        <xsl:apply-templates select="$identity/mods:language/mods:languageTerm">
            <xsl:with-param name="prefix" select="$local_prefix"/>
        </xsl:apply-templates>
       

        <!-- genre -->
        <xsl:apply-templates select="$identity/mods:genre">
            <xsl:with-param name="prefix" select="$local_prefix"/>
        </xsl:apply-templates>



        <!-- langauge facet -->



        <!--
        * lookup geoloc
        *
        -->
        <!--
        <xsl:for-each select="$identity/mods:relatedItem/mods:originInfo/mods:placeTerm | $identity/mods:originInfo/mods:place/mods:placeTerm ">
            <xsl:call-template name="cwrc_lookup_geoloc">
                <xsl:with-param name="str_to_query_geoloc" select="text()" /> 
            </xsl:call-template>
        </xsl:for-each>
        -->

    </xsl:template>




    <!-- ********************************************************* -->
    <!-- CWRC PERSON Entity solr index Fedora Datastream -->
    <!-- ********************************************************* -->
    <xsl:template match="foxml:datastream[@ID='PERSON']/foxml:datastreamVersion[last()]" name="index_CWRC_PERSON_ENTITY">

        <xsl:param name="content" select="entity/person"/>
        <xsl:param name="prefix" select="'cwrc_entity_'"/>
        <xsl:param name="suffix" select="'_et'"/>
        <!-- 'edged' (edge n-gram) text, for auto-completion -->

        <xsl:variable name="identity" select="$content/entity/person/identity"/>
        <xsl:variable name="description" select="$content/entity/person/description"/>
        <xsl:variable name="recordInfo" select="$content/entity/person/recordInfo"/>
        <xsl:variable name="local_prefix" select="concat($prefix, 'person_')"/>

        <!-- ensure that the preferred name is first -->
        <xsl:apply-templates select="$identity/preferredForm">
            <xsl:with-param name="prefix" select="$local_prefix"/>
            <xsl:with-param name="suffix" select="$suffix"/>
        </xsl:apply-templates>

        <!-- Variant forms of the name -->
        <xsl:apply-templates select="$identity/variantForms">
            <xsl:with-param name="prefix" select="$local_prefix"/>
            <xsl:with-param name="suffix" select="$suffix"/>
        </xsl:apply-templates>

        <!-- Descriptive Birthdate -->
        <!-- assume all date types are Birth or Death -->
        <xsl:apply-templates select="$description/existDates">
            <xsl:with-param name="prefix" select="$local_prefix"/>
            <xsl:with-param name="suffix" select="$suffix"/>
        </xsl:apply-templates>

        <!-- access condition -->
        <xsl:call-template name="assemble_cwrc_access_condition">
            <xsl:with-param name="prefix" select="$local_prefix"/>
            <xsl:with-param name="content" select="$recordInfo/accessCondition"/>
        </xsl:call-template>

        <!-- project id -->
        <xsl:call-template name="assemble_cwrc_project_id">
            <xsl:with-param name="prefix" select="$local_prefix"/>
            <xsl:with-param name="content" select="$recordInfo/originInfo/projectId"/>
        </xsl:call-template>

        <!-- factuality -->
        <xsl:call-template name="assemble_cwrc_factuality">
            <xsl:with-param name="prefix" select="$local_prefix"/>
            <xsl:with-param name="content" select="$description/factuality"/>
        </xsl:call-template>

    </xsl:template>








    <!-- ********************************************************* -->
    <!-- HELPER Templates -->
    <!-- ********************************************************* -->

    <!-- Assemble basic field - single value -->
    <xsl:template name="assemble_cwrc_basic_field">
        <xsl:param name="field_value"/>
        <xsl:param name="field_name"/>

        <field>
            <xsl:attribute name="name">
                <xsl:value-of select="$field_name"/>
            </xsl:attribute>

            <xsl:value-of select="$field_value" />
        </field>

    </xsl:template>


    <!-- CWRC Person perferred name forms -->
    <xsl:template match="preferredForm">
        <xsl:param name="prefix"/>
        <xsl:param name="suffix"/>

        <field>
            <xsl:attribute name="name">
                <xsl:value-of select="concat($prefix, 'preferredForm', $suffix)"/>
            </xsl:attribute>

            <xsl:call-template name="assemble_cwrc_person_name"/>
        </field>

    </xsl:template>


    <!-- CWRC Person variant name forms -->
    <xsl:template match="variantForms">
        <xsl:param name="prefix"/>
        <xsl:param name="suffix"/>

        <xsl:for-each select="variant">

            <field>
                <xsl:attribute name="name">
                    <xsl:value-of select="concat($prefix, 'variantForm', $suffix)"/>
                </xsl:attribute>

                <xsl:call-template name="assemble_cwrc_person_name"/>
            </field>

        </xsl:for-each>

    </xsl:template>


    <!-- Descriptive Birthdate -->
    <!-- assume all date types are Birth or Death -->
    <xsl:template match="existDates">
        <xsl:param name="prefix"/>
        <xsl:param name="suffix"/>

        <!-- birth date -->
        <xsl:variable name="var_birthDate" select="(dateRange/fromDate|dateSingle)[child::dateType/text()='birth']/standardDate"/>

        <xsl:if test="$var_birthDate">
            <field>
                <xsl:attribute name="name">
                    <xsl:value-of select="concat($prefix, 'birthDate', '_s')"/>
                </xsl:attribute>
                <xsl:value-of select="$var_birthDate"/>
            </field>
            <!-- invalid dates - 2014-04-10 braking indexing
            <field>
                <xsl:attribute name="name">
                    <xsl:value-of select="concat($prefix, 'birthDate', '_dt')"/>
                </xsl:attribute>
                <xsl:value-of select="$var_birthDate"/>
            </field>
            -->
        </xsl:if>

        <!-- death date -->
        <xsl:variable name="var_deathDate" select="(dateRange/toDate|dateSingle)[child::dateType/text()='death']/standardDate"/>

        <xsl:if test="$var_deathDate">
            <field>
                <xsl:attribute name="name">
                    <xsl:value-of select="concat($prefix, 'deathDate', '_s')"/>
                </xsl:attribute>
                <xsl:value-of select="$var_deathDate"/>
            </field>
            <!-- invalid dates - 2014-04-10 braking indexing 
            <field>
                <xsl:attribute name="name">
                    <xsl:value-of select="concat($prefix, 'deathDate', '_dt')"/>
                </xsl:attribute>
                <xsl:value-of select="$var_deathDate"/>
            </field>
             -->
        </xsl:if>


    </xsl:template>


    <!-- assemble the person name from the component parts, if necessary -->
    <xsl:template name="assemble_cwrc_person_name">
         
        <xsl:variable name="name">
            
            <!--
                * see the CWRC entities schema for attribute values of the
                * assumes the namePart element are in the proper order
                * and does support the comma surname and givename format
            -->
            <xsl:for-each select="namePart">
                <xsl:choose>
                    <xsl:when test="@type='initials'">
                        <xsl:text> (</xsl:text>
                        <xsl:value-of select="displayForm"/>
                        <xsl:text>) </xsl:text>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="."/>                        
                    </xsl:otherwise>
                </xsl:choose>
                <xsl:text> </xsl:text>
            </xsl:for-each>
            
            <xsl:if test="displayForm">
                <xsl:text> (</xsl:text>
                <xsl:value-of select="displayForm"/>
                <xsl:text>) </xsl:text>
            </xsl:if>            
        </xsl:variable>
        
        <xsl:value-of select="normalize-space($name)"/>
        
    </xsl:template>


    <!-- CWRC perferred/authoritative or primary title forms -->
    <xsl:template match="mods:titleInfo" mode="cwrc_entities">
        <xsl:param name="prefix"/>
        <xsl:param name="suffix"/>


        <xsl:variable name="title_type">
            <xsl:call-template name="get_title_type"/>
        </xsl:variable>

        <field>
            <xsl:attribute name="name">
                <xsl:value-of select="concat($prefix, $title_type, $suffix)"/>
            </xsl:attribute>

            <xsl:value-of select="mods:title/text()"/>

        </field>

    </xsl:template>

    <!-- CWRC title author(s) name forms -->
    <xsl:template match="mods:name" mode="cwrc_entities">
        <xsl:param name="prefix"/>
        <xsl:param name="suffix"/>

        <field>
            <xsl:attribute name="name">
                <xsl:value-of select="concat($prefix, 'author', $suffix)"/>
            </xsl:attribute>

            <xsl:call-template name="assemble_cwrc_title_author"/>
        </field>

    </xsl:template>


    <!-- given a title entity figure out the type/format -->
    <xsl:template name="get_title_type">
        <xsl:choose>
            <xsl:when test="not(@type) and mods:title">
                <xsl:value-of select="'uniformTitle'"/>
            </xsl:when>
            <xsl:when test="not(@type) and @usage='primary' and mods:title ">
                <xsl:value-of select="'uniformTitle'"/>
            </xsl:when>
            <xsl:when test="@type='alternative' or @type='abbreviated' or @type='translated' or @type='uniform'">
                <xsl:value-of select="'variantTitle'"/>
                <!-- multiple titles, don't use type='alternative' -->
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="'variantTitle'"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>


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


    <xsl:template match="mods:roleTerm" mode="assemble_cwrc_title_author">
        <xsl:text> (</xsl:text>
        <xsl:value-of select="(./text())"/>
        <xsl:text>)</xsl:text>
        <xsl:if test="position()!=last()">
            <xsl:text> </xsl:text>
        </xsl:if>
    </xsl:template>

    <xsl:template match="mods:namePart" mode="assemble_cwrc_title_author">
        <xsl:variable name="name_text" select="normalize-space(./text())"/>
        <xsl:if test="$name_text!=''">
            <xsl:value-of select="$name_text"/>
            <xsl:if test="position()!=last()">
                <xsl:text> </xsl:text>
            </xsl:if>
        </xsl:if>
    </xsl:template>




    <!-- title entity: output the date and format -->
    <xsl:template name="assemble_cwrc_title_formats">
        <xsl:param name="prefix"/>
        <xsl:param name="date"/>
        <xsl:param name="format"/>
 
        <field>
            <xsl:attribute name="name">
                <xsl:value-of select="concat($prefix, 'date', '_ms')"/>
            </xsl:attribute>

            <!--
            <xsl:value-of select="$date"/>
            -->
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
            <xsl:call-template name="cwrc_orlando_date_repair">
              <xsl:with-param name="date" select="$date" />
            </xsl:call-template>

        </field>

        <xsl:if test="$format and $format!=''"> 
            <field>
                <xsl:attribute name="name">
                    <xsl:value-of select="concat($prefix, 'format', '_s')"/>
                </xsl:attribute>
                <xsl:value-of select="$format"/>
            </field>
        </xsl:if>
    </xsl:template>

<!-- language template -->
<xsl:template match="mods:language/mods:languageTerm">
    <xsl:param name="prefix"/>
    
    <xsl:variable name="local_language_code" select="(.)[@type='code']/text()" />
    <xsl:variable name="local_language_text" select="(.)[@type='text']/text()" />
    <xsl:if test="$local_language_code">
        <xsl:call-template name="assemble_cwrc_basic_field">
            <xsl:with-param name="field_name" select="concat($prefix, 'language_code', '_s')"/>
            <xsl:with-param name="field_value" select="$local_language_code"/>
        </xsl:call-template>
    </xsl:if>
    <xsl:if test="$local_language_text">
        <xsl:call-template name="assemble_cwrc_basic_field">
            <xsl:with-param name="field_name" select="concat($prefix, 'language_text', '_s')"/>
            <xsl:with-param name="field_value" select="$local_language_text"/>
        </xsl:call-template>
    </xsl:if>
</xsl:template>

    <!-- title entity: output the Genre -->
    <xsl:template match="mods:genre">
        <xsl:param name="prefix"/>

        <xsl:variable name="field_name">
            <xsl:choose>
                <xsl:when test="mods:genre[@type='format']">
                    <xsl:text>genre_format</xsl:text>
                </xsl:when>
                <xsl:when test="mods:genre[@type='primaryGenre' or @type='subgenre']">
                    <xsl:text>genre_primary_subgenre</xsl:text>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:text>genre_folksonomic</xsl:text>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>

        <xsl:variable name="content" select="./text()" />
        <xsl:if test="$content">
            <field>
                <xsl:attribute name="name">
                    <xsl:value-of select="concat($prefix, $field_name, '_ms')"/>
                </xsl:attribute>

                <xsl:value-of select="$content"/>
            </field>
        </xsl:if>

    </xsl:template>


    <!-- generic entity: output the Project ID -->
    <xsl:template name="assemble_cwrc_project_id">
        <xsl:param name="prefix"/>
        <xsl:param name="content"/>

        <xsl:if test="$content">
            <field>
                <xsl:attribute name="name">
                    <xsl:value-of select="concat($prefix, 'project_id', '_ms')"/>
                </xsl:attribute>

                <xsl:value-of select="$content"/>
            </field>
        </xsl:if>

    </xsl:template>


    <!-- generic entity: output the Factuality -->
    <xsl:template name="assemble_cwrc_factuality">
        <xsl:param name="prefix"/>
        <xsl:param name="content"/>

        <xsl:if test="$content">
            <field>
                <xsl:attribute name="name">
                    <xsl:value-of select="concat($prefix, 'factuality', '_s')"/>
                </xsl:attribute>

                <xsl:value-of select="$content"/>
            </field>
        </xsl:if>

    </xsl:template>



    <!-- generic entity: output the access condition -->
    <xsl:template name="assemble_cwrc_access_condition">
        <xsl:param name="prefix"/>
        <xsl:param name="content"/>

        <xsl:if test="$content">
            <field>
                <xsl:attribute name="name">
                    <xsl:value-of select="concat($prefix, 'access_condition', '_ms')"/>
                </xsl:attribute>

                <!-- <xsl:value-of select="$content"/> -->
                
                <xsl:for-each select="$content/child::node()">
                    <xsl:choose>
                        <xsl:when test="self::text()">
                            <xsl:value-of select="."/>
                        </xsl:when>
                        <xsl:when test="self::*">
                            <xsl:text>&lt;</xsl:text>
                            <xsl:value-of select="name()" />
                            <xsl:for-each select="./@*">
                                <xsl:text> </xsl:text>
                                <xsl:value-of select="name()"></xsl:value-of>
                                <xsl:text>="</xsl:text>                      
                                <xsl:value-of select="."></xsl:value-of>
                                <xsl:text>"</xsl:text>
                            </xsl:for-each>
                            <xsl:text>&gt;</xsl:text>
                            <xsl:value-of select="." />
                            <xsl:text>&lt;/</xsl:text>
                            <xsl:value-of select="name()" />
                            <xsl:text>&gt;</xsl:text>
                        </xsl:when>
                    </xsl:choose>
                </xsl:for-each>
                
                <xsl:if test="$content/@type and $content/@type!=''">
                    <xsl:text> (</xsl:text>
                    <xsl:value-of select="$content/@type"/>
                    <xsl:text>) </xsl:text>
                </xsl:if>
            </field>
        </xsl:if>

    </xsl:template>



</xsl:stylesheet>
