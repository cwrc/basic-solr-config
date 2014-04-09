<?xml version="1.0" encoding="UTF-8"?>

<!-- Basic CWRC Entities - transform for Solr -->

<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:foxml="info:fedora/fedora-system:def/foxml#" xmlns:xlink="http://www.w3.org/1999/xlink" xmlns:mods="http://www.loc.gov/mods/v3" exclude-result-prefixes="mods">

    <!-- this template used to help test  -->

    <!-- 
    <xsl:template match="/">
            <xsl:apply-templates select="/foxml:digitalObject/foxml:datastream[@ID='TITLE']/foxml:datastreamVersion[last()]">
                <xsl:with-param name="content" select="/foxml:digitalObject/foxml:datastream[@ID='TITLE']/foxml:datastreamVersion[last()]/foxml:xmlContent"></xsl:with-param>
        </xsl:apply-templates>

    </xsl:template>
 -->


    <!-- ********************************************************* -->
    <!-- CWRC ORGANIZATION Entity solr index Fedora Datastream -->
    <!-- ********************************************************* -->
    <xsl:template match="foxml:datastream[@ID='PLACE']/foxml:datastreamVersion[last()]" name="index_CWRC_PLACE_ENTITY">

        <xsl:param name="content" select="entity/place"/>
        <xsl:param name="prefix" select="'cwrc_entity_'"/>
        <xsl:param name="suffix" select="'_et'"/>
        <!-- 'edged' (edge n-gram) text, for auto-completion -->

        <xsl:variable name="identity" select="$content/entity/place/identity"/>
        <xsl:variable name="description" select="$content/entity/place/description"/>
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
                    <xsl:value-of select="concat($prefix, 'geoloc', '_s')"/>
                </xsl:attribute>

                <xsl:value-of select="concat($description/latitude, ',', $description/longitude)"/>
            </field>
        </xsl:if>

        <!-- Descriptive Geo Location - country name -->
        <xsl:if test="$description/countryName">
            <field>
                <xsl:attribute name="name">
                    <xsl:value-of select="concat($prefix, 'countryName', $suffix)"/>
                </xsl:attribute>

                <xsl:value-of select="$description/countryName"/>
            </field>
        </xsl:if>

        <!-- Descriptive Geo Location - first adminstrative division-->
        <xsl:if test="$description/firstAdministrativeDivision">
            <field>
                <xsl:attribute name="name">
                    <xsl:value-of select="concat($prefix, 'firstAdministrativeDivision', $suffix)"/>
                </xsl:attribute>

                <xsl:value-of select="$description/firstAdministrativeDivision"/>
            </field>
        </xsl:if>

        <!-- Descriptive featureClass - -->
        <xsl:if test="$description/featureClass">
            <field>
                <xsl:attribute name="name">
                    <xsl:value-of select="concat($prefix, 'featureClass', $suffix)"/>
                </xsl:attribute>

                <xsl:value-of select="$description/featureClass"/>
            </field>
        </xsl:if>

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

    </xsl:template>



    <!-- ********************************************************* -->
    <!-- CWRC TITLE Entity solr index Fedora Datastream -->
    <!-- ********************************************************* -->
    <xsl:template match="foxml:datastream[@ID='TITLE']/foxml:datastreamVersion[last()]" name="index_CWRC_TITLE_ENTITY">

        <xsl:param name="content" select="."/>
        <xsl:param name="prefix" select="'cwrc_entity_'"/>
        <xsl:param name="suffix" select="'_et'"/>

        <!-- 'edged' (edge n-gram) text, for auto-completion -->
        <xsl:variable name="identity" select="$content/mods:mods"/>
        <xsl:variable name="local_prefix" select="concat($prefix, 'title_')"/>

        <!-- the preferred/authoritative title (name of title)-->
        <!-- variant titles -->
        <xsl:apply-templates select="$identity/mods:titleInfo">
            <xsl:with-param name="prefix" select="$local_prefix"/>
            <xsl:with-param name="suffix" select="$suffix"/>
        </xsl:apply-templates>

        <!-- ensure that the author name -->
        <xsl:apply-templates select="$identity/mods:name">
            <xsl:with-param name="prefix" select="$local_prefix"/>
            <xsl:with-param name="suffix" select="$suffix"/>
        </xsl:apply-templates>





        <!--
        Dates
        Monograph whole:
        date: /mods/originInfo/dateIssued
        issuance: /mods/originInfo/issuance with value equal to "monographic"

        Monograph chapter:
        date: /mods/relatedItem/originInfo/dateIssued/
        issuance: /mods/relatedItem/originInfo/issuance with value equal to "monographic"

        Periodical article:
        date: /mods/relatedItem/part/date
        issuance: /mods/relatedItem/originInfo/issuance with value equal to "continuing"
        -->
        <xsl:choose>
            <xsl:when test="mods:originInfo/mods:issuance/text()='monographic'">
                <!-- monograph whole -->
                <xsl:call-template name="assemble_cwrc_title_formats">
                    <xsl:with-param name="prefix" select="$local_prefix"/>
                    <xsl:with-param name="date" select="mods:originInfo/mods:dateIssued/text()"/>
                    <xsl:with-param name="format" select="'Monograph whole'"/>
                </xsl:call-template>
            </xsl:when>
            <!-- monograph chapter -->
            <xsl:when test="mods:relatedItem/mods:originInfo/mods:issuance/text()='monographic'">
                <xsl:call-template name="assemble_cwrc_title_formats">
                    <xsl:with-param name="prefix" select="$local_prefix"/>
                    <xsl:with-param name="date" select="mods:relatedItem/mods:originInfo/mods:dateIssued/text()"/>
                    <xsl:with-param name="format" select="'Monograph chapter'"/>
                </xsl:call-template>
            </xsl:when>
            <!-- periodical article -->
            <xsl:when test="mods:relatedItem/mods:originInfo/mods:issuance/text()='continuing'">
                <xsl:call-template name="assemble_cwrc_title_formats">
                    <xsl:with-param name="prefix" select="$local_prefix"/>
                    <xsl:with-param name="date" select="mods:relatedItem/mods:part/mods:date/text()"/>
                    <xsl:with-param name="format" select="'Periodical article'"/>
                </xsl:call-template>
            </xsl:when>
        </xsl:choose>
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
        <xsl:variable name="local_prefix" select="concat($prefix, 'name_')"/>

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

    </xsl:template>








    <!-- ********************************************************* -->
    <!-- HELPER Templates -->
    <!-- ********************************************************* -->

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
        <xsl:variable name="var_birthDate" select="(dateRange/fromDate|dateRange/toDate|dateSingle)[child::dateType/text()='birth']/standardDate"/>

        <xsl:if test="$var_birthDate">
            <field>
                <xsl:attribute name="name">
                    <xsl:value-of select="concat($prefix, 'birthDate', '_s')"/>
                </xsl:attribute>
                <xsl:value-of select="$var_birthDate"/>
            </field>
            <field>
                <xsl:attribute name="name">
                    <xsl:value-of select="concat($prefix, 'birthDate', '_dt')"/>
                </xsl:attribute>
                <xsl:value-of select="$var_birthDate"/>
            </field>
        </xsl:if>

        <!-- death date -->
        <xsl:variable name="var_deathDate" select="(dateRange/fromDate|dateRange/toDate|dateSingle)[child::dateType/text()='death']/standardDate"/>

        <xsl:if test="$var_deathDate">
            <field>
                <xsl:attribute name="name">
                    <xsl:value-of select="concat($prefix, 'deathDate', '_s')"/>
                </xsl:attribute>
                <xsl:value-of select="$var_deathDate"/>
            </field>
            <field>
                <xsl:attribute name="name">
                    <xsl:value-of select="concat($prefix, 'deathDate', '_dt')"/>
                </xsl:attribute>
                <xsl:value-of select="$var_deathDate"/>
            </field>
        </xsl:if>


    </xsl:template>


    <!-- assemble the person name from the component parts, if necessary -->
    <xsl:template name="assemble_cwrc_person_name">
        <!-- does a surname exist -->
        <xsl:variable name="is_surname_present" select="namePart/@partType='surname'"/>
        <!-- does a forename exist -->
        <xsl:variable name="is_forename_present" select="namePart/@partType='forename'"/>
        <xsl:variable name="is_display_label" select="identity/displayLabel"/>


        <xsl:choose>
            <!-- displayLabel -->
            <xsl:when test="$is_display_label">
                <xsl:value-of select="normalize-space($is_display_label)"/>
            </xsl:when>
            <!-- surname and forename -->
            <xsl:when test="$is_surname_present or $is_forename_present">
                <xsl:if test="$is_forename_present">
                    <xsl:value-of select="normalize-space(namePart[@partType='forename']/text())"/>
                </xsl:if>
                <xsl:if test="$is_forename_present and $is_surname_present">
                    <xsl:text> </xsl:text>
                </xsl:if>
                <xsl:if test="$is_surname_present">
                    <xsl:value-of select="normalize-space(namePart[@partType='surname']/text())"/>
                </xsl:if>
            </xsl:when>
            <!-- namePart -->
            <xsl:when test="namePart">
                <xsl:value-of select="normalize-space(namePart)"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:text/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>


    <!-- CWRC perferred/authoritative or primary title forms -->
    <xsl:template match="mods:titleInfo">
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
    <xsl:template match="mods:name">
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

        <!-- does a surname exist -->
        <xsl:variable name="is_surname_present" select="mods:namePart/@type='family'"/>
        <!-- does a forename exist -->
        <xsl:variable name="is_forename_present" select="mods:namePart/@type='given'"/>


        <xsl:choose>
            <!-- surname and forename -->
            <xsl:when test="$is_surname_present or $is_forename_present">
                <xsl:if test="$is_forename_present">
                    <xsl:value-of select="normalize-space(mods:namePart[@type='given']/text())"/>
                </xsl:if>
                <xsl:if test="$is_forename_present and $is_surname_present">
                    <xsl:text> </xsl:text>
                </xsl:if>
                <xsl:if test="$is_surname_present">
                    <xsl:value-of select="normalize-space(mods:namePart[@type='family']/text())"/>
                </xsl:if>
            </xsl:when>
            <!-- namePart -->
            <xsl:when test="mods:namePart">
                <xsl:value-of select="normalize-space(mods:namePart)"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:text/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>


    <!-- title entity: output the date and format -->
    <xsl:template name="assemble_cwrc_title_formats">
        <xsl:param name="prefix"/>
        <xsl:param name="date"/>
        <xsl:param name="format"/>
        <field>
            <xsl:attribute name="name">
                <xsl:value-of select="concat($prefix, 'date', '_dt')"/>
            </xsl:attribute>

            <xsl:value-of select="$date"/>
        </field>
        <field>
            <xsl:attribute name="name">
                <xsl:value-of select="concat($prefix, 'format', '_s')"/>
            </xsl:attribute>
            <xsl:value-of select="$format"/>
        </field>
    </xsl:template>

</xsl:stylesheet>
