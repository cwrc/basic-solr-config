<?xml version="1.0" encoding="UTF-8"?>

<xsl:stylesheet
    version="1.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:mods="http://www.loc.gov/mods/v3"
    exclude-result-prefixes="mods"
    >

    <xsl:output indent='yes'/>

    <xsl:include href="CWRC_Helpers_MODS.xslt" />

    <!--
        * MARC Relator
        * Foreach MARC Relator, create a Solr field with a key_name based on the relator term and value based on the person name

    -->

    <!-- XSLT 1.0 toLower -->
    <xsl:variable name="lowercase" select="'abcdefghijklmnopqrstuvwxyz'" />
    <xsl:variable name="uppercase" select="'ABCDEFGHIJKLMNOPQRSTUVWXYZ'" />


    <!-- MODS root -->
    <xsl:template match="/">
        <!-- handle titleInfo section -->
        <xsl:apply-templates select="mods:mods/mods:titleInfo" mode="cwrc_entities_mods">
            <xsl:with-param name="local_prefix" select="'mods'"/>
        </xsl:apply-templates>

        <!-- handle name section -->
        <xsl:apply-templates select="mods:mods/mods:name" mode="cwrc_entities_mods">
            <xsl:with-param name="local_prefix" select="'mods'" />
        </xsl:apply-templates>

        <!-- handle typeOfResource -->
        <xsl:apply-templates select="mods:mods/mods:typeOfResource" mode="cwrc_entities_mods">
            <xsl:with-param name="local_prefix" select="'mods'" />
            <xsl:with-param name="local_field_root" select="'_typeOfResource'" />
        </xsl:apply-templates>
        <xsl:apply-templates select="mods:mods/mods:typeOfResource | mods:mods/mods:genre[@type='formatType']" mode="cwrc_entities_mods">
            <xsl:with-param name="local_prefix" select="'mods'" />
            <xsl:with-param name="local_field_root" select="'_genre'" />
        </xsl:apply-templates>

        <!-- genre -->
        <xsl:apply-templates select="mods:mods/mods:genre[@type='formatType']" mode="cwrc_entities_mods">
            <xsl:with-param name="local_prefix" select="'mods'" />
            <xsl:with-param name="local_field_root" select="'_genre-format'" />
        </xsl:apply-templates>
        <xsl:apply-templates select="mods:mods/mods:genre[@type='primaryGenre']" mode="cwrc_entities_mods">
            <xsl:with-param name="local_prefix" select="'mods'" />
            <xsl:with-param name="local_field_root" select="'_genre-primaryGenre'" />
        </xsl:apply-templates>
        <xsl:apply-templates select="mods:mods/mods:genre[@type='subgenre']" mode="cwrc_entities_mods">
            <xsl:with-param name="local_prefix" select="'mods'" />
            <xsl:with-param name="local_field_root" select="'_genre_subgenre'" />
        </xsl:apply-templates>
        <xsl:apply-templates select="mods:mods/mods:genre" mode="cwrc_entities_mods">
            <xsl:with-param name="local_prefix" select="'mods'" />
            <xsl:with-param name="local_field_root" select="'_genre-folksonomic'" />
        </xsl:apply-templates>

        <!-- originInfo -->
        <xsl:apply-templates select="mods:mods/mods:originInfo" mode="cwrc_entities_mods">
            <xsl:with-param name="local_prefix" select="'mods_originInfo'" />
        </xsl:apply-templates>

        <!-- language -->
        <xsl:apply-templates select="mods:mods/mods:language/mods:languageTerm" mode="cwrc_entities_mods">
            <xsl:with-param name="local_field_name" select="'mods_language'" />
        </xsl:apply-templates>

        <!-- languageTerm -->
        <xsl:apply-templates select="mods:mods/mods:physicalDescription/mods:form[@authority='marccategory']" mode="cwrc_entities_mods">
            <xsl:with-param name="local_field_name" select="'mods_physicalDescription_form'" />
        </xsl:apply-templates>

        <!-- physicalDescription note -->
        <xsl:apply-templates select="mods:mods/mods:physicalDescription/mods:note" mode="cwrc_entities_mods">
            <xsl:with-param name="local_field_name" select="'mods_physicalDescription_note'" />
        </xsl:apply-templates>

        <!-- physicalDescription digitalOrigin -->
        <xsl:apply-templates select="mods:mods/mods:physicalDescription/mods:digitalOrigin" mode="cwrc_entities_mods">
            <xsl:with-param name="local_field_name" select="'mods_physicalDescription_digitalOrigin'" />
        </xsl:apply-templates>

        <!-- physicalDescription internetMediaType -->
        <xsl:apply-templates select="mods:mods/mods:physicalDescription/mods:internetMediaType" mode="cwrc_entities_mods">
            <xsl:with-param name="local_field_name" select="'mods_physicalDescription_internetMediaType'" />
        </xsl:apply-templates>

        <!-- abstract -->
        <xsl:apply-templates select="mods:mods/mods:abstract" mode="cwrc_entities_mods">
            <xsl:with-param name="local_field_name" select="'mods_abstract'"/>
        </xsl:apply-templates>

        <!-- scholarnote -->
        <xsl:apply-templates select="mods:mods/mods:note[@type='scholarNote']" mode="cwrc_entities_mods">
            <xsl:with-param name="local_field_name" select="'mods_scholarNote'"/>
        </xsl:apply-templates>

        <!-- researchNote -->
        <xsl:apply-templates select="mods:mods/mods:note[@type='researchNote']" mode="cwrc_entities_mods">
            <xsl:with-param name="local_field_name" select="'mods_researchNote'"/>
        </xsl:apply-templates>

        <!-- note -->
        <xsl:apply-templates select="mods:mods/mods:note[@type='scholarNote'] | mods:note[@type='researchNote']" mode="cwrc_entities_mods">
            <xsl:with-param name="local_field_name" select="'mods_note'"/>
        </xsl:apply-templates>

        <!-- handle subject -->
        <xsl:apply-templates select="mods:mods/mods:subject" mode="cwrc_entities_mods">
            <xsl:with-param name="local_prefix" select="'mods_subject'" />
        </xsl:apply-templates>

        <!-- handle related item -->
        <xsl:apply-templates select="mods:mods/mods:relatedItem" mode="cwrc_entities_mods">
            <xsl:with-param name="local_prefix" select="'mods_relatedItem'" />
        </xsl:apply-templates>

        <!-- handle identifier -->
        <xsl:apply-templates select="mods:mods/mods:identifier" mode="cwrc_entities_mods">
            <xsl:with-param name="local_field_name" select="'mods_identifier'" />
        </xsl:apply-templates>

        <xsl:apply-templates select="mods:mods/mods:identifier[@type='uri']" mode="cwrc_entities_mods">
            <xsl:with-param name="local_field_name" select="'mods_identifier-URI'" />
        </xsl:apply-templates>

        <xsl:apply-templates select="mods:mods/mods:identifier[@type='doi']" mode="cwrc_entities_mods">
            <xsl:with-param name="local_field_name" select="'mods_identifier-DOI'" />
        </xsl:apply-templates>

        <xsl:apply-templates select="mods:mods/mods:identifier[@type='isbn']" mode="cwrc_entities_mods">
            <xsl:with-param name="local_field_name" select="'mods_identifier-ISBN'" />
        </xsl:apply-templates>

        <xsl:apply-templates select="mods:mods/mods:identifier[@type='lccn']" mode="cwrc_entities_mods">
            <xsl:with-param name="local_field_name" select="'mods_identifier-LCCN'" />
        </xsl:apply-templates>

        <xsl:apply-templates select="mods:mods/mods:identifier[@type='isan']" mode="cwrc_entities_mods">
            <xsl:with-param name="local_field_name" select="'mods_identifier-ISAN'" />
        </xsl:apply-templates>

        <xsl:apply-templates select="mods:mods/mods:identifier[@type='videorecording-identifier']" mode="cwrc_entities_mods">
            <xsl:with-param name="local_field_name" select="'mods_identifier-VideoRecording'" />
        </xsl:apply-templates>

        <xsl:apply-templates select="mods:mods/mods:identifier[@type='ean']" mode="cwrc_entities_mods">
            <xsl:with-param name="local_field_name" select="'mods_identifier-EAN'" />
        </xsl:apply-templates>

        <xsl:apply-templates select="mods:mods/mods:identifier[@type='upc']" mode="cwrc_entities_mods">
            <xsl:with-param name="local_field_name" select="'mods_identifier-UPC'" />
        </xsl:apply-templates>

        <xsl:apply-templates select="mods:mods/mods:identifier[@type='issue-number']" mode="cwrc_entities_mods">
            <xsl:with-param name="local_field_name" select="'mods_identifier-IssueNumber'" />
        </xsl:apply-templates>

        <xsl:apply-templates select="mods:mods/mods:identifier[@type='matix-number']" mode="cwrc_entities_mods">
            <xsl:with-param name="local_field_name" select="'mods_identifier-MatrixNumber'" />
        </xsl:apply-templates>

        <xsl:apply-templates select="mods:mods/mods:identifier[@type='isrc']" mode="cwrc_entities_mods">
            <xsl:with-param name="local_field_name" select="'mods_identifier-ISRC'" />
        </xsl:apply-templates>

        <xsl:apply-templates select="mods:mods/mods:identifier[@type='iswc']" mode="cwrc_entities_mods">
            <xsl:with-param name="local_field_name" select="'mods_identifier-ISWC'" />
        </xsl:apply-templates>

        <xsl:apply-templates select="mods:mods/mods:identifier[@type='grid']" mode="cwrc_entities_mods">
            <xsl:with-param name="local_field_name" select="'mods_identifier-GRID'" />
        </xsl:apply-templates>

        <!-- handle location -->
        <xsl:apply-templates select="mods:mods/mods:location" mode="cwrc_entities_mods">
            <xsl:with-param name="local_prefix" select="'mods_location'" />
        </xsl:apply-templates>

        <!-- accessCondition: use and reproduction -->
        <xsl:apply-templates select="mods:mods/mods:accessCondition[@type='use and reproduction']" mode="cwrc_entities_mods">
            <xsl:with-param name="local_field_name" select="'mods_accessCondition-UseAndReproduction'" />
        </xsl:apply-templates>

        <!-- accessCondition: Not 'use and reproduction' -->
        <xsl:apply-templates select="mods:mods/mods:accessCondition[@type!='use and reproduction' or not(@type)]" mode="cwrc_entities_mods">
            <xsl:with-param name="local_field_name" select="'mods_accessCondition-Not-UseAndReproduction'" />
        </xsl:apply-templates>

        <!-- recordInfo -->
        <xsl:apply-templates select="mods:mods/mods:recordInfo" mode="cwrc_entities_mods">
            <xsl:with-param name="local_prefix" select="'mods_recordInfo'" />
        </xsl:apply-templates>

        <!-- record content source -->
        <xsl:apply-templates select="mods:mods/mods:recordContentSource" mode="cwrc_entities_mods">
            <xsl:with-param name="local_field_name" select="'mods_recordContentSource'" />
        </xsl:apply-templates>

        <!-- table of contents -->
        <xsl:apply-templates select="mods:tableOfContents" mode="cwrc_entities_mods">
            <xsl:with-param name="local_field_name" select="'mods_tableOfContents'" />
        </xsl:apply-templates>

        <!-- classificiation -->
        <xsl:apply-templates select="mods:classification" mode="cwrc_entities_mods">
            <xsl:with-param name="local_field_name" select="'mods_classification'" />
        </xsl:apply-templates>

        <!-- handle mods part -->
        <xsl:apply-templates select="mods:mods/mods:part" mode="cwrc_entities_mods">
            <xsl:with-param name="local_prefix" select="'mods_part'" />
        </xsl:apply-templates>

    </xsl:template>


    <!-- titleInfo section handling -->
    <xsl:template match="mods:titleInfo" mode="cwrc_entities_mods">
        <xsl:param name="local_prefix" select="'mods'" />

        <xsl:apply-templates select="mods:title | mods:subTitle" mode="cwrc_entities_mods">
            <xsl:with-param name="local_prefix" select="concat($local_prefix, '_titleInfo')" />
            <xsl:with-param name="field_root" select="'_anyTitle'" />
        </xsl:apply-templates>

        <xsl:apply-templates select="mods:title" mode="cwrc_entities_mods">
            <xsl:with-param name="local_prefix" select="concat($local_prefix, '_titleInfo')" />
            <xsl:with-param name="field_root" select="'_title'" />
        </xsl:apply-templates>

        <xsl:apply-templates select="mods:title[../@type = 'alternative']" mode="cwrc_entities_mods">
            <xsl:with-param name="local_prefix" select="concat($local_prefix, '_titleInfo')" />
            <xsl:with-param name="field_root" select="'_alternative_subTitle'" />
        </xsl:apply-templates>

        <xsl:apply-templates select="mods:subTitle" mode="cwrc_entities_mods">
            <xsl:with-param name="local_prefix" select="concat($local_prefix, '_titleInfo')" />
            <xsl:with-param name="field_root" select="'_subTitle'" />
        </xsl:apply-templates>

        <xsl:apply-templates select="@valueURI" mode="cwrc_entities_mods">
            <xsl:with-param name="local_prefix" select="concat($local_prefix, '_titleInfo')"/>
        </xsl:apply-templates>

    </xsl:template>

    <!-- title and sub titles -->
    <xsl:template match="mods:title | mods:subTitle" mode="cwrc_entities_mods">
        <xsl:param name="local_prefix" select="'mods_titleinfo'" />
        <xsl:param name="field_root" select="'field_root'" />

        <xsl:apply-templates select="text()" mode="cwrc_entities_mods">
            <xsl:with-param name="local_field_name" select="concat($local_prefix, $field_root, '_s')" />
        </xsl:apply-templates>

    </xsl:template>

    <!-- title URI-->
    <xsl:template match="mods:titleInfo/@valueURI" mode="cwrc_entities_mods">
        <xsl:param name="local_prefix" select="'mods_titleInfo'" />

        <field>
            <xsl:attribute name="name">
                <xsl:value-of select="concat($local_prefix, '_URI', '_s')" />
            </xsl:attribute>

            <xsl:value-of select="."/>
        </field>
    </xsl:template>


    <!-- name: for each person name -->
    <xsl:template match="mods:name" mode="cwrc_entities_mods">

        <xsl:param name="local_prefix" select="'mods'" />

        <xsl:variable name="cwrc_author_name">
            <xsl:call-template name="assemble_cwrc_title_author" />
        </xsl:variable>

        <xsl:apply-templates select="@valueURI" mode="cwrc_entities_mods">
            <xsl:with-param name="local_field_name" select="concat($local_prefix, '_name-URI')" />
        </xsl:apply-templates>

        <!-- use build the full name and output -->
        <xsl:if test="$cwrc_author_name">

            <xsl:call-template name="add_solr_field">
                <xsl:with-param name="solr_field_key" select="concat($local_prefix, '_name_loc_mods2dc', '_s')" />
                <xsl:with-param name="solr_field_value" select="$cwrc_author_name" />
            </xsl:call-template>

            <xsl:apply-templates select="mods:role" mode="cwrc_entities_mods">
                <xsl:with-param name="cwrc_author_name" select="$cwrc_author_name" />
                <xsl:with-param name="local_prefix" select="'mods'"></xsl:with-param>
            </xsl:apply-templates>

        </xsl:if>

        <xsl:apply-templates select="mods:affiliation" mode="cwrc_entities_mods">
            <xsl:with-param name="local_prefix" select="concat($local_prefix, '_name')" />
        </xsl:apply-templates>

        <xsl:apply-templates select="mods:namePart" mode="cwrc_entities_mods">
            <xsl:with-param name="local_prefix" select="concat($local_prefix, '_name')" />
        </xsl:apply-templates>

    </xsl:template>

    <!-- name affiliation -->
    <xsl:template match="mods:affiliation" mode="cwrc_entities_mods">
        <xsl:param name="local_prefix" />

        <xsl:call-template name="add_solr_field">
            <xsl:with-param name="solr_field_key" select="concat($local_prefix, '_affiliation', '_s')" />
            <xsl:with-param name="solr_field_value" select="text()" />
        </xsl:call-template>

    </xsl:template>

    <!-- name part -->
    <xsl:template match="mods:namePart" mode="cwrc_entities_mods">
        <xsl:param name="local_prefix" />

        <!-- full name of person or organization -->
        <xsl:if test="(parent::mods:name/@type = 'personal' or parent::mods:name/@type = 'corporate') and not(@type)">
            <xsl:call-template name="add_solr_field">
                <xsl:with-param name="solr_field_key" select="concat($local_prefix, '-', parent::mods:name/@type, '_namePart-noType', '_s')" />
                <xsl:with-param name="solr_field_value" select="current()[not(@type)]/text()" />
            </xsl:call-template>
        </xsl:if>

        <!-- name part -->
        <xsl:if test="@type = 'family' or @type = 'given'">
            <xsl:call-template name="add_solr_field">
                <xsl:with-param name="solr_field_key" select="concat($local_prefix, '_namePart-', @type, '_s')" />
                <xsl:with-param name="solr_field_value" select="text()" />
            </xsl:call-template>
        </xsl:if>

        <!-- any name -->
        <!--  unneeded as the `assemble_cwrc_title_author fulfils combining the name -->
        <!--
        <xsl:if test="parent::mods:name[@type = 'personal']/mods:namePart[not(@type)] or parent::mods:name[@type = 'corporate']/mods:namePart[not(@type)] or @type = 'family' or @type = 'given'">

            <xsl:call-template name="add_solr_field">
                <xsl:with-param name="solr_field_key" select="concat($local_prefix, '_anyName', '_s')" />
                <xsl:with-param name="solr_field_value" select="text()" />
            </xsl:call-template>

        </xsl:if>
        -->
    </xsl:template>

    <!-- convert MARC relator to Solr field name -->
    <xsl:template match="mods:role" mode="cwrc_entities_mods">
        <xsl:param name="cwrc_author_name" select="'unknown'" />
        <xsl:param name="local_prefix" select="'mods'" />

        <!-- if mods:role contains multiple roleTerms which don't match then only the first will be recorded (hence [1] selector) -->
        <xsl:variable name="cwrc_authorrole_marcrelator_text">
            <!-- convert to lower case: not all text marcrelators start with an upper case character -->
            <xsl:value-of select="translate(mods:roleTerm[@authority = 'marcrelator' and @type = 'text'][1], $uppercase, $lowercase)" />
        </xsl:variable>
        <xsl:variable name="cwrc_authorrole_marcrelator_code" select="mods:roleTerm[@authority = 'marcrelator' and @type = 'code'][1]" />

        <xsl:variable name="cwrc_role_root">
            <xsl:call-template name="cwrc_mods_marcrelator_field_root">
                <xsl:with-param name="cwrc_authorrole_marcrelator_code" select="$cwrc_authorrole_marcrelator_code" />
                <xsl:with-param name="cwrc_authorrole_marcrelator_text" select="$cwrc_authorrole_marcrelator_text" />
            </xsl:call-template>
        </xsl:variable>

        <xsl:call-template name="add_solr_field">
            <xsl:with-param name="solr_field_key" select="concat($local_prefix, '_name_role_', $cwrc_role_root, '_s')" />
            <xsl:with-param name="solr_field_value" select="$cwrc_author_name" />
        </xsl:call-template>

        <xsl:apply-templates select="mods:roleTerm" mode="cwrc_entities_mods">
            <xsl:with-param name="solr_field_key" select="concat($local_prefix, '_name_anyrole', '_s')" />
        </xsl:apply-templates>

    </xsl:template>

    <!-- name any role term -->
    <xsl:template match="mods:roleTerm" mode="cwrc_entities_mods">
        <xsl:param name="solr_field_key" select="'unknown'" />
        <xsl:call-template name="add_solr_field">
            <xsl:with-param name="solr_field_key" select="$solr_field_key" />
            <xsl:with-param name="solr_field_value" select="text()" />
        </xsl:call-template>

    </xsl:template>

    <!-- given a MODS marcrelator 'code' or 'text', return the root of the Solr field -->
    <xsl:template name="cwrc_mods_marcrelator_field_root">
        <xsl:param name="cwrc_authorrole_marcrelator_code" />
        <xsl:param name="cwrc_authorrole_marcrelator_text" />

        <xsl:choose>
            <xsl:when test="$cwrc_authorrole_marcrelator_code = 'abr' or $cwrc_authorrole_marcrelator_text = 'abridger'">
                <xsl:text>Abridger</xsl:text>
            </xsl:when>
            <xsl:when test="$cwrc_authorrole_marcrelator_code = 'acp' or $cwrc_authorrole_marcrelator_text = 'art copyist'">
                <xsl:text>ArtCopyist</xsl:text>
            </xsl:when>
            <xsl:when test="$cwrc_authorrole_marcrelator_code = 'act' or $cwrc_authorrole_marcrelator_text = 'actor'">
                <xsl:text>Actor</xsl:text>
            </xsl:when>
            <xsl:when test="$cwrc_authorrole_marcrelator_code = 'adi' or $cwrc_authorrole_marcrelator_text = 'art director'">
                <xsl:text>ArtDirector</xsl:text>
            </xsl:when>
            <xsl:when test="$cwrc_authorrole_marcrelator_code = 'adp' or $cwrc_authorrole_marcrelator_text = 'adapter'">
                <xsl:text>Adapter</xsl:text>
            </xsl:when>
            <xsl:when test="$cwrc_authorrole_marcrelator_code = 'aft' or $cwrc_authorrole_marcrelator_text = 'author of afterword, colophon, etc.'">
                <xsl:text>AuthorAfterwordColophon</xsl:text>
            </xsl:when>
            <xsl:when test="$cwrc_authorrole_marcrelator_code = 'anl' or $cwrc_authorrole_marcrelator_text = 'analyst'">
                <xsl:text>Analyst</xsl:text>
            </xsl:when>
            <xsl:when test="$cwrc_authorrole_marcrelator_code = 'anm' or $cwrc_authorrole_marcrelator_text = 'animator'">
                <xsl:text>Animator</xsl:text>
            </xsl:when>
            <xsl:when test="$cwrc_authorrole_marcrelator_code = 'ann' or $cwrc_authorrole_marcrelator_text = 'annotator'">
                <xsl:text>Annotator</xsl:text>
            </xsl:when>
            <xsl:when test="$cwrc_authorrole_marcrelator_code = 'ant' or $cwrc_authorrole_marcrelator_text = 'bibliographic antecedent'">
                <xsl:text>BibliographicAntecedent</xsl:text>
            </xsl:when>
            <xsl:when test="$cwrc_authorrole_marcrelator_code = 'ape' or $cwrc_authorrole_marcrelator_text = 'appellee'">
                <xsl:text>Appellee</xsl:text>
            </xsl:when>
            <xsl:when test="$cwrc_authorrole_marcrelator_code = 'apl' or $cwrc_authorrole_marcrelator_text = 'appellant'">
                <xsl:text>Appellant</xsl:text>
            </xsl:when>
            <xsl:when test="$cwrc_authorrole_marcrelator_code = 'app' or $cwrc_authorrole_marcrelator_text = 'applicant'">
                <xsl:text>Applicant</xsl:text>
            </xsl:when>
            <xsl:when test="$cwrc_authorrole_marcrelator_code = 'aqt' or $cwrc_authorrole_marcrelator_text = 'author in quotations or text abstracts'">
                <xsl:text>AuthorQuotationsTextAbstracts</xsl:text>
            </xsl:when>
            <xsl:when test="$cwrc_authorrole_marcrelator_code = 'arc' or $cwrc_authorrole_marcrelator_text = 'architect'">
                <xsl:text>Architect</xsl:text>
            </xsl:when>
            <xsl:when test="$cwrc_authorrole_marcrelator_code = 'ard' or $cwrc_authorrole_marcrelator_text = 'artistic director'">
                <xsl:text>ArtisticDirector</xsl:text>
            </xsl:when>
            <xsl:when test="$cwrc_authorrole_marcrelator_code = 'arr' or $cwrc_authorrole_marcrelator_text = 'arranger'">
                <xsl:text>Arranger</xsl:text>
            </xsl:when>
            <xsl:when test="$cwrc_authorrole_marcrelator_code = 'art' or $cwrc_authorrole_marcrelator_text = 'artist'">
                <xsl:text>Artist</xsl:text>
            </xsl:when>
            <xsl:when test="$cwrc_authorrole_marcrelator_code = 'asg' or $cwrc_authorrole_marcrelator_text = 'assignee'">
                <xsl:text>Assignee</xsl:text>
            </xsl:when>
            <xsl:when test="$cwrc_authorrole_marcrelator_code = 'asn' or $cwrc_authorrole_marcrelator_text = 'associated name'">
                <xsl:text>AssociatedName</xsl:text>
            </xsl:when>
            <xsl:when test="$cwrc_authorrole_marcrelator_code = 'ato' or $cwrc_authorrole_marcrelator_text = 'autographer'">
                <xsl:text>Autographer</xsl:text>
            </xsl:when>
            <xsl:when test="$cwrc_authorrole_marcrelator_code = 'att' or $cwrc_authorrole_marcrelator_text = 'attributed name'">
                <xsl:text>AttributedName</xsl:text>
            </xsl:when>
            <xsl:when test="$cwrc_authorrole_marcrelator_code = 'auc' or $cwrc_authorrole_marcrelator_text = 'auctioneer'">
                <xsl:text>Auctioneer</xsl:text>
            </xsl:when>
            <xsl:when test="$cwrc_authorrole_marcrelator_code = 'aud' or $cwrc_authorrole_marcrelator_text = 'author of dialog'">
                <xsl:text>AuthorDialog</xsl:text>
            </xsl:when>
            <xsl:when test="$cwrc_authorrole_marcrelator_code = 'aui' or $cwrc_authorrole_marcrelator_text = 'author of introduction, etc.'">
                <xsl:text>AuthorIntroduction</xsl:text>
            </xsl:when>
            <xsl:when test="$cwrc_authorrole_marcrelator_code = 'aus' or $cwrc_authorrole_marcrelator_text = 'screenwriter'">
                <xsl:text>Screenwriter</xsl:text>
            </xsl:when>
            <xsl:when test="$cwrc_authorrole_marcrelator_code = 'aut' or $cwrc_authorrole_marcrelator_text = 'author'">
                <xsl:text>Author</xsl:text>
            </xsl:when>
            <xsl:when test="$cwrc_authorrole_marcrelator_code = 'bdd' or $cwrc_authorrole_marcrelator_text = 'binding designer'">
                <xsl:text>BindingDesigner</xsl:text>
            </xsl:when>
            <xsl:when test="$cwrc_authorrole_marcrelator_code = 'bjd' or $cwrc_authorrole_marcrelator_text = 'bookjacket designer'">
                <xsl:text>BookjacketDesigner</xsl:text>
            </xsl:when>
            <xsl:when test="$cwrc_authorrole_marcrelator_code = 'bkd' or $cwrc_authorrole_marcrelator_text = 'book designer'">
                <xsl:text>BookDesigner</xsl:text>
            </xsl:when>
            <xsl:when test="$cwrc_authorrole_marcrelator_code = 'bkp' or $cwrc_authorrole_marcrelator_text = 'book producer'">
                <xsl:text>BookProducer</xsl:text>
            </xsl:when>
            <xsl:when test="$cwrc_authorrole_marcrelator_code = 'blw' or $cwrc_authorrole_marcrelator_text = 'blurb writer'">
                <xsl:text>BlurbWriter</xsl:text>
            </xsl:when>
            <xsl:when test="$cwrc_authorrole_marcrelator_code = 'bnd' or $cwrc_authorrole_marcrelator_text = 'binder'">
                <xsl:text>Binder</xsl:text>
            </xsl:when>
            <xsl:when test="$cwrc_authorrole_marcrelator_code = 'bpd' or $cwrc_authorrole_marcrelator_text = 'bookplate designer'">
                <xsl:text>BookplateDesigner</xsl:text>
            </xsl:when>
            <xsl:when test="$cwrc_authorrole_marcrelator_code = 'brd' or $cwrc_authorrole_marcrelator_text = 'broadcaster'">
                <xsl:text>Broadcaster</xsl:text>
            </xsl:when>
            <xsl:when test="$cwrc_authorrole_marcrelator_code = 'brl' or $cwrc_authorrole_marcrelator_text = 'braille embosser'">
                <xsl:text>BrailleEmbosser</xsl:text>
            </xsl:when>
            <xsl:when test="$cwrc_authorrole_marcrelator_code = 'bsl' or $cwrc_authorrole_marcrelator_text = 'bookseller'">
                <xsl:text>Bookseller</xsl:text>
            </xsl:when>
            <xsl:when test="$cwrc_authorrole_marcrelator_code = 'cas' or $cwrc_authorrole_marcrelator_text = 'caster'">
                <xsl:text>Caster</xsl:text>
            </xsl:when>
            <xsl:when test="$cwrc_authorrole_marcrelator_code = 'ccp' or $cwrc_authorrole_marcrelator_text = 'conceptor'">
                <xsl:text>Conceptor</xsl:text>
            </xsl:when>
            <xsl:when test="$cwrc_authorrole_marcrelator_code = 'chr' or $cwrc_authorrole_marcrelator_text = 'choreographer'">
                <xsl:text>Choreographer</xsl:text>
            </xsl:when>
            <xsl:when test="$cwrc_authorrole_marcrelator_code = '-clb' or $cwrc_authorrole_marcrelator_text = 'collaborator'">
                <xsl:text>Collaborator</xsl:text>
            </xsl:when>
            <xsl:when test="$cwrc_authorrole_marcrelator_code = 'cli' or $cwrc_authorrole_marcrelator_text = 'client'">
                <xsl:text>Client</xsl:text>
            </xsl:when>
            <xsl:when test="$cwrc_authorrole_marcrelator_code = 'cll' or $cwrc_authorrole_marcrelator_text = 'calligrapher'">
                <xsl:text>Calligrapher</xsl:text>
            </xsl:when>
            <xsl:when test="$cwrc_authorrole_marcrelator_code = 'clr' or $cwrc_authorrole_marcrelator_text = 'colorist'">
                <xsl:text>Colorist</xsl:text>
            </xsl:when>
            <xsl:when test="$cwrc_authorrole_marcrelator_code = 'clt' or $cwrc_authorrole_marcrelator_text = 'collotyper'">
                <xsl:text>Collotyper</xsl:text>
            </xsl:when>
            <xsl:when test="$cwrc_authorrole_marcrelator_code = 'cmm' or $cwrc_authorrole_marcrelator_text = 'commentator'">
                <xsl:text>Commentator</xsl:text>
            </xsl:when>
            <xsl:when test="$cwrc_authorrole_marcrelator_code = 'cmp' or $cwrc_authorrole_marcrelator_text = 'composer'">
                <xsl:text>Composer</xsl:text>
            </xsl:when>
            <xsl:when test="$cwrc_authorrole_marcrelator_code = 'cmt' or $cwrc_authorrole_marcrelator_text = 'compositor'">
                <xsl:text>Compositor</xsl:text>
            </xsl:when>
            <xsl:when test="$cwrc_authorrole_marcrelator_code = 'cnd' or $cwrc_authorrole_marcrelator_text = 'conductor'">
                <xsl:text>Conductor</xsl:text>
            </xsl:when>
            <xsl:when test="$cwrc_authorrole_marcrelator_code = 'cng' or $cwrc_authorrole_marcrelator_text = 'cinematographer'">
                <xsl:text>Cinematorgrapher</xsl:text>
            </xsl:when>
            <xsl:when test="$cwrc_authorrole_marcrelator_code = 'cns' or $cwrc_authorrole_marcrelator_text = 'censor'">
                <xsl:text>Censor</xsl:text>
            </xsl:when>
            <xsl:when test="$cwrc_authorrole_marcrelator_code = 'coe' or $cwrc_authorrole_marcrelator_text = 'contestant-appellee'">
                <xsl:text>ContestantAppellee</xsl:text>
            </xsl:when>
            <xsl:when test="$cwrc_authorrole_marcrelator_code = 'col' or $cwrc_authorrole_marcrelator_text = 'collector'">
                <xsl:text>Collector</xsl:text>
            </xsl:when>
            <xsl:when test="$cwrc_authorrole_marcrelator_code = 'com' or $cwrc_authorrole_marcrelator_text = 'compiler'">
                <xsl:text>Compiler</xsl:text>
            </xsl:when>
            <xsl:when test="$cwrc_authorrole_marcrelator_code = 'con' or $cwrc_authorrole_marcrelator_text = 'conservator'">
                <xsl:text>Conservator</xsl:text>
            </xsl:when>
            <xsl:when test="$cwrc_authorrole_marcrelator_code = 'cor' or $cwrc_authorrole_marcrelator_text = 'collection registrar'">
                <xsl:text>CollectionRegistrar</xsl:text>
            </xsl:when>
            <xsl:when test="$cwrc_authorrole_marcrelator_code = 'cos' or $cwrc_authorrole_marcrelator_text = 'contestant'">
                <xsl:text>Contestant</xsl:text>
            </xsl:when>
            <xsl:when test="$cwrc_authorrole_marcrelator_code = 'cot' or $cwrc_authorrole_marcrelator_text = 'contestant-appellant'">
                <xsl:text>ContestantAppellant</xsl:text>
            </xsl:when>
            <xsl:when test="$cwrc_authorrole_marcrelator_code = 'cou' or $cwrc_authorrole_marcrelator_text = 'court governed'">
                <xsl:text>CourtGoverned</xsl:text>
            </xsl:when>
            <xsl:when test="$cwrc_authorrole_marcrelator_code = 'cov' or $cwrc_authorrole_marcrelator_text = 'cover designer'">
                <xsl:text>CoverDesigner</xsl:text>
            </xsl:when>
            <xsl:when test="$cwrc_authorrole_marcrelator_code = 'cpc' or $cwrc_authorrole_marcrelator_text = 'copyright claimant'">
                <xsl:text>CopyrightClaimant</xsl:text>
            </xsl:when>
            <xsl:when test="$cwrc_authorrole_marcrelator_code = 'cpe' or $cwrc_authorrole_marcrelator_text = 'complainant-appellee'">
                <xsl:text>ComplainantAppellee</xsl:text>
            </xsl:when>
            <xsl:when test="$cwrc_authorrole_marcrelator_code = 'cph' or $cwrc_authorrole_marcrelator_text = 'copyright holder'">
                <xsl:text>CopyrightHolder</xsl:text>
            </xsl:when>
            <xsl:when test="$cwrc_authorrole_marcrelator_code = 'cpl' or $cwrc_authorrole_marcrelator_text = 'complainant'">
                <xsl:text>Complainant</xsl:text>
            </xsl:when>
            <xsl:when test="$cwrc_authorrole_marcrelator_code = 'cpt' or $cwrc_authorrole_marcrelator_text = 'complainant-appellant'">
                <xsl:text>ComplainantAppellant</xsl:text>
            </xsl:when>
            <xsl:when test="$cwrc_authorrole_marcrelator_code = 'cre' or $cwrc_authorrole_marcrelator_text = 'creator'">
                <xsl:text>Creator</xsl:text>
            </xsl:when>
            <xsl:when test="$cwrc_authorrole_marcrelator_code = 'crp' or $cwrc_authorrole_marcrelator_text = 'correspondent'">
                <xsl:text>Correspondent</xsl:text>
            </xsl:when>
            <xsl:when test="$cwrc_authorrole_marcrelator_code = 'crr' or $cwrc_authorrole_marcrelator_text = 'corrector'">
                <xsl:text>Corrector</xsl:text>
            </xsl:when>
            <xsl:when test="$cwrc_authorrole_marcrelator_code = 'crt' or $cwrc_authorrole_marcrelator_text = 'court reporter'">
                <xsl:text>CourtReporter</xsl:text>
            </xsl:when>
            <xsl:when test="$cwrc_authorrole_marcrelator_code = 'csl' or $cwrc_authorrole_marcrelator_text = 'consultant'">
                <xsl:text>Consultant</xsl:text>
            </xsl:when>
            <xsl:when test="$cwrc_authorrole_marcrelator_code = 'csp' or $cwrc_authorrole_marcrelator_text = 'consultant to a project'">
                <xsl:text>ConsultantProject</xsl:text>
            </xsl:when>
            <xsl:when test="$cwrc_authorrole_marcrelator_code = 'cst' or $cwrc_authorrole_marcrelator_text = 'costume designer'">
                <xsl:text>CostumeDesigner</xsl:text>
            </xsl:when>
            <xsl:when test="$cwrc_authorrole_marcrelator_code = 'ctb' or $cwrc_authorrole_marcrelator_text = 'contributor'">
                <xsl:text>Contributor</xsl:text>
            </xsl:when>
            <xsl:when test="$cwrc_authorrole_marcrelator_code = 'cte' or $cwrc_authorrole_marcrelator_text = 'contestee-appellee'">
                <xsl:text>ContesteeAppellee</xsl:text>
            </xsl:when>
            <xsl:when test="$cwrc_authorrole_marcrelator_code = 'ctg' or $cwrc_authorrole_marcrelator_text = 'cartographer'">
                <xsl:text>Cartographer</xsl:text>
            </xsl:when>
            <xsl:when test="$cwrc_authorrole_marcrelator_code = 'ctr' or $cwrc_authorrole_marcrelator_text = 'contractor'">
                <xsl:text>Contractor</xsl:text>
            </xsl:when>
            <xsl:when test="$cwrc_authorrole_marcrelator_code = 'cts' or $cwrc_authorrole_marcrelator_text = 'contestee'">
                <xsl:text>Contestee</xsl:text>
            </xsl:when>
            <xsl:when test="$cwrc_authorrole_marcrelator_code = 'ctt' or $cwrc_authorrole_marcrelator_text = 'contestee-appellant'">
                <xsl:text>ContesteeAppellant</xsl:text>
            </xsl:when>
            <xsl:when test="$cwrc_authorrole_marcrelator_code = 'cur' or $cwrc_authorrole_marcrelator_text = 'curator'">
                <xsl:text>Curator</xsl:text>
            </xsl:when>
            <xsl:when test="$cwrc_authorrole_marcrelator_code = 'cwt' or $cwrc_authorrole_marcrelator_text = 'commentator for written text'">
                <xsl:text>CommentatorWrittenText</xsl:text>
            </xsl:when>
            <xsl:when test="$cwrc_authorrole_marcrelator_code = 'dbp' or $cwrc_authorrole_marcrelator_text = 'distribution place'">
                <xsl:text>DistributionPlace</xsl:text>
            </xsl:when>
            <xsl:when test="$cwrc_authorrole_marcrelator_code = 'dfd' or $cwrc_authorrole_marcrelator_text = 'defendant'">
                <xsl:text>Defendant</xsl:text>
            </xsl:when>
            <xsl:when test="$cwrc_authorrole_marcrelator_code = 'dfe' or $cwrc_authorrole_marcrelator_text = 'defendant-appellee'">
                <xsl:text>Defendant</xsl:text>
            </xsl:when>
            <xsl:when test="$cwrc_authorrole_marcrelator_code = 'dft' or $cwrc_authorrole_marcrelator_text = 'defendant-appellant'">
                <xsl:text>DefendantAppellee</xsl:text>
            </xsl:when>
            <xsl:when test="$cwrc_authorrole_marcrelator_code = 'dgg' or $cwrc_authorrole_marcrelator_text = 'degree granting institution'">
                <xsl:text>DefendantAppellant</xsl:text>
            </xsl:when>
            <xsl:when test="$cwrc_authorrole_marcrelator_code = 'dgs' or $cwrc_authorrole_marcrelator_text = 'degree supervisor'">
                <xsl:text>DegreeSupervisor</xsl:text>
            </xsl:when>
            <xsl:when test="$cwrc_authorrole_marcrelator_code = 'dis' or $cwrc_authorrole_marcrelator_text = 'dissertant'">
                <xsl:text>Dissertant</xsl:text>
            </xsl:when>
            <xsl:when test="$cwrc_authorrole_marcrelator_code = 'dln' or $cwrc_authorrole_marcrelator_text = 'delineator'">
                <xsl:text>Delineator</xsl:text>
            </xsl:when>
            <xsl:when test="$cwrc_authorrole_marcrelator_code = 'dnc' or $cwrc_authorrole_marcrelator_text = 'dancer'">
                <xsl:text>Dancer</xsl:text>
            </xsl:when>
            <xsl:when test="$cwrc_authorrole_marcrelator_code = 'dnr' or $cwrc_authorrole_marcrelator_text = 'donor'">
                <xsl:text>Donor</xsl:text>
            </xsl:when>
            <xsl:when test="$cwrc_authorrole_marcrelator_code = 'dpc' or $cwrc_authorrole_marcrelator_text = 'depicted'">
                <xsl:text>Depicted</xsl:text>
            </xsl:when>
            <xsl:when test="$cwrc_authorrole_marcrelator_code = 'dpt' or $cwrc_authorrole_marcrelator_text = 'depositor'">
                <xsl:text>Depositor</xsl:text>
            </xsl:when>
            <xsl:when test="$cwrc_authorrole_marcrelator_code = 'drm' or $cwrc_authorrole_marcrelator_text = 'draftsman'">
                <xsl:text>Draftsman</xsl:text>
            </xsl:when>
            <xsl:when test="$cwrc_authorrole_marcrelator_code = 'drt' or $cwrc_authorrole_marcrelator_text = 'director'">
                <xsl:text>Director</xsl:text>
            </xsl:when>
            <xsl:when test="$cwrc_authorrole_marcrelator_code = 'dsr' or $cwrc_authorrole_marcrelator_text = 'designer'">
                <xsl:text>Designer</xsl:text>
            </xsl:when>
            <xsl:when test="$cwrc_authorrole_marcrelator_code = 'dst' or $cwrc_authorrole_marcrelator_text = 'distributor'">
                <xsl:text>Deistributor</xsl:text>
            </xsl:when>
            <xsl:when test="$cwrc_authorrole_marcrelator_code = 'dtc' or $cwrc_authorrole_marcrelator_text = 'data contributor'">
                <xsl:text>DataContributor</xsl:text>
            </xsl:when>
            <xsl:when test="$cwrc_authorrole_marcrelator_code = 'dte' or $cwrc_authorrole_marcrelator_text = 'dedicatee'">
                <xsl:text>Dedicatee</xsl:text>
            </xsl:when>
            <xsl:when test="$cwrc_authorrole_marcrelator_code = 'dtm' or $cwrc_authorrole_marcrelator_text = 'data manager'">
                <xsl:text>DataManager</xsl:text>
            </xsl:when>
            <xsl:when test="$cwrc_authorrole_marcrelator_code = 'dto' or $cwrc_authorrole_marcrelator_text = 'dedicator'">
                <xsl:text>Dedicator</xsl:text>
            </xsl:when>
            <xsl:when test="$cwrc_authorrole_marcrelator_code = 'dub' or $cwrc_authorrole_marcrelator_text = 'dubious author'">
                <xsl:text>DubiousAuthor</xsl:text>
            </xsl:when>
            <xsl:when test="$cwrc_authorrole_marcrelator_code = 'edc' or $cwrc_authorrole_marcrelator_text = 'editor of compilation'">
                <xsl:text>EditorCompilation</xsl:text>
            </xsl:when>
            <xsl:when test="$cwrc_authorrole_marcrelator_code = 'edm' or $cwrc_authorrole_marcrelator_text = 'editor of moving image work'">
                <xsl:text>EditorMovingImageWork</xsl:text>
            </xsl:when>
            <xsl:when test="$cwrc_authorrole_marcrelator_code = 'edt' or $cwrc_authorrole_marcrelator_text = 'editor'">
                <xsl:text>Editor</xsl:text>
            </xsl:when>
            <xsl:when test="$cwrc_authorrole_marcrelator_code = 'egr' or $cwrc_authorrole_marcrelator_text = 'engraver'">
                <xsl:text>Engraver</xsl:text>
            </xsl:when>
            <xsl:when test="$cwrc_authorrole_marcrelator_code = 'elg' or $cwrc_authorrole_marcrelator_text = 'electrician'">
                <xsl:text>Electrician</xsl:text>
            </xsl:when>
            <xsl:when test="$cwrc_authorrole_marcrelator_code = 'elt' or $cwrc_authorrole_marcrelator_text = 'electrotyper'">
                <xsl:text>Electrotyper</xsl:text>
            </xsl:when>
            <xsl:when test="$cwrc_authorrole_marcrelator_code = 'eng' or $cwrc_authorrole_marcrelator_text = 'engineer'">
                <xsl:text>Engineer</xsl:text>
            </xsl:when>
            <xsl:when test="$cwrc_authorrole_marcrelator_code = 'enj' or $cwrc_authorrole_marcrelator_text = 'enacting jurisdiction'">
                <xsl:text>EnactingJurisdiction</xsl:text>
            </xsl:when>
            <xsl:when test="$cwrc_authorrole_marcrelator_code = 'etr' or $cwrc_authorrole_marcrelator_text = 'etcher'">
                <xsl:text>Etcher</xsl:text>
            </xsl:when>
            <xsl:when test="$cwrc_authorrole_marcrelator_code = 'evp' or $cwrc_authorrole_marcrelator_text = 'event place'">
                <xsl:text>EventPlace</xsl:text>
            </xsl:when>
            <xsl:when test="$cwrc_authorrole_marcrelator_code = 'exp' or $cwrc_authorrole_marcrelator_text = 'expert'">
                <xsl:text>Expert</xsl:text>
            </xsl:when>
            <xsl:when test="$cwrc_authorrole_marcrelator_code = 'fac' or $cwrc_authorrole_marcrelator_text = 'facsimilist'">
                <xsl:text>Facsimilist</xsl:text>
            </xsl:when>
            <xsl:when test="$cwrc_authorrole_marcrelator_code = 'fds' or $cwrc_authorrole_marcrelator_text = 'film distributor'">
                <xsl:text>FilmDistributor</xsl:text>
            </xsl:when>
            <xsl:when test="$cwrc_authorrole_marcrelator_code = 'fld' or $cwrc_authorrole_marcrelator_text = 'field director'">
                <xsl:text>FieldDirector</xsl:text>
            </xsl:when>
            <xsl:when test="$cwrc_authorrole_marcrelator_code = 'flm' or $cwrc_authorrole_marcrelator_text = 'film editor'">
                <xsl:text>FilmEditor</xsl:text>
            </xsl:when>
            <xsl:when test="$cwrc_authorrole_marcrelator_code = 'fmd' or $cwrc_authorrole_marcrelator_text = 'film director'">
                <xsl:text>FilmDirector</xsl:text>
            </xsl:when>
            <xsl:when test="$cwrc_authorrole_marcrelator_code = 'fmk' or $cwrc_authorrole_marcrelator_text = 'filmmaker'">
                <xsl:text>Filmmaker</xsl:text>
            </xsl:when>
            <xsl:when test="$cwrc_authorrole_marcrelator_code = 'fmo' or $cwrc_authorrole_marcrelator_text = 'former owner'">
                <xsl:text>FormerOwner</xsl:text>
            </xsl:when>
            <xsl:when test="$cwrc_authorrole_marcrelator_code = 'fmp' or $cwrc_authorrole_marcrelator_text = 'film producer'">
                <xsl:text>FilmProducer</xsl:text>
            </xsl:when>
            <xsl:when test="$cwrc_authorrole_marcrelator_code = 'fnd' or $cwrc_authorrole_marcrelator_text = 'funder'">
                <xsl:text>Funder</xsl:text>
            </xsl:when>
            <xsl:when test="$cwrc_authorrole_marcrelator_code = 'fpy' or $cwrc_authorrole_marcrelator_text = 'first party'">
                <xsl:text>FirstParty</xsl:text>
            </xsl:when>
            <xsl:when test="$cwrc_authorrole_marcrelator_code = 'frg' or $cwrc_authorrole_marcrelator_text = 'forger'">
                <xsl:text>Forger</xsl:text>
            </xsl:when>
            <xsl:when test="$cwrc_authorrole_marcrelator_code = 'gis' or $cwrc_authorrole_marcrelator_text = 'geographic information specialist'">
                <xsl:text>GeographicInformationSpecialist</xsl:text>
            </xsl:when>
            <xsl:when test="$cwrc_authorrole_marcrelator_code = '-grt' or $cwrc_authorrole_marcrelator_text = 'graphic technician'">
                <xsl:text>GraphicTechnician</xsl:text>
            </xsl:when>
            <xsl:when test="$cwrc_authorrole_marcrelator_code = 'his' or $cwrc_authorrole_marcrelator_text = 'host institution'">
                <xsl:text>HostInstitution</xsl:text>
            </xsl:when>
            <xsl:when test="$cwrc_authorrole_marcrelator_code = 'hnr' or $cwrc_authorrole_marcrelator_text = 'honoree'">
                <xsl:text>Honoree</xsl:text>
            </xsl:when>
            <xsl:when test="$cwrc_authorrole_marcrelator_code = 'hst' or $cwrc_authorrole_marcrelator_text = 'host'">
                <xsl:text>Host</xsl:text>
            </xsl:when>
            <xsl:when test="$cwrc_authorrole_marcrelator_code = 'ill' or $cwrc_authorrole_marcrelator_text = 'illustrator'">
                <xsl:text>Illustrator</xsl:text>
            </xsl:when>
            <xsl:when test="$cwrc_authorrole_marcrelator_code = 'ilu' or $cwrc_authorrole_marcrelator_text = 'illuminator'">
                <xsl:text>Illuminator</xsl:text>
            </xsl:when>
            <xsl:when test="$cwrc_authorrole_marcrelator_code = 'ins' or $cwrc_authorrole_marcrelator_text = 'inscriber'">
                <xsl:text>Inscriber</xsl:text>
            </xsl:when>
            <xsl:when test="$cwrc_authorrole_marcrelator_code = 'inv' or $cwrc_authorrole_marcrelator_text = 'inventor'">
                <xsl:text>Inventor</xsl:text>
            </xsl:when>
            <xsl:when test="$cwrc_authorrole_marcrelator_code = 'isb' or $cwrc_authorrole_marcrelator_text = 'issuing body'">
                <xsl:text>IssuingBody</xsl:text>
            </xsl:when>
            <xsl:when test="$cwrc_authorrole_marcrelator_code = 'itr' or $cwrc_authorrole_marcrelator_text = 'instrumentalist'">
                <xsl:text>Instrumentalist</xsl:text>
            </xsl:when>
            <xsl:when test="$cwrc_authorrole_marcrelator_code = 'ive' or $cwrc_authorrole_marcrelator_text = 'interviewee'">
                <xsl:text>Interviewee</xsl:text>
            </xsl:when>
            <xsl:when test="$cwrc_authorrole_marcrelator_code = 'ivr' or $cwrc_authorrole_marcrelator_text = 'interviewer'">
                <xsl:text>Interviewer</xsl:text>
            </xsl:when>
            <xsl:when test="$cwrc_authorrole_marcrelator_code = 'jud' or $cwrc_authorrole_marcrelator_text = 'judge'">
                <xsl:text>Judge</xsl:text>
            </xsl:when>
            <xsl:when test="$cwrc_authorrole_marcrelator_code = 'jug' or $cwrc_authorrole_marcrelator_text = 'jurisdiction governed'">
                <xsl:text>JusrisdictionGoverned</xsl:text>
            </xsl:when>
            <xsl:when test="$cwrc_authorrole_marcrelator_code = 'lbr' or $cwrc_authorrole_marcrelator_text = 'laboratory'">
                <xsl:text>Laboratory</xsl:text>
            </xsl:when>
            <xsl:when test="$cwrc_authorrole_marcrelator_code = 'lbt' or $cwrc_authorrole_marcrelator_text = 'librettist'">
                <xsl:text>Librettist</xsl:text>
            </xsl:when>
            <xsl:when test="$cwrc_authorrole_marcrelator_code = 'ldr' or $cwrc_authorrole_marcrelator_text = 'laboratory director'">
                <xsl:text>LaboratoryDirector</xsl:text>
            </xsl:when>
            <xsl:when test="$cwrc_authorrole_marcrelator_code = 'led' or $cwrc_authorrole_marcrelator_text = 'lead'">
                <xsl:text>Lead</xsl:text>
            </xsl:when>
            <xsl:when test="$cwrc_authorrole_marcrelator_code = 'lee' or $cwrc_authorrole_marcrelator_text = 'libelee-appellee'">
                <xsl:text>LibeleeAppellee</xsl:text>
            </xsl:when>
            <xsl:when test="$cwrc_authorrole_marcrelator_code = 'lel' or $cwrc_authorrole_marcrelator_text = 'libelee'">
                <xsl:text>Libelee</xsl:text>
            </xsl:when>
            <xsl:when test="$cwrc_authorrole_marcrelator_code = 'len' or $cwrc_authorrole_marcrelator_text = 'lender'">
                <xsl:text>Lender</xsl:text>
            </xsl:when>
            <xsl:when test="$cwrc_authorrole_marcrelator_code = 'let' or $cwrc_authorrole_marcrelator_text = 'libelee-appellant'">
                <xsl:text>LibeleeAppellant</xsl:text>
            </xsl:when>
            <xsl:when test="$cwrc_authorrole_marcrelator_code = 'lgd' or $cwrc_authorrole_marcrelator_text = 'lighting designer'">
                <xsl:text>LightingDesigner</xsl:text>
            </xsl:when>
            <xsl:when test="$cwrc_authorrole_marcrelator_code = 'lie' or $cwrc_authorrole_marcrelator_text = 'libelant-appellee'">
                <xsl:text>LibelantAppellee</xsl:text>
            </xsl:when>
            <xsl:when test="$cwrc_authorrole_marcrelator_code = 'lil' or $cwrc_authorrole_marcrelator_text = 'libelant'">
                <xsl:text>Libelant</xsl:text>
            </xsl:when>
            <xsl:when test="$cwrc_authorrole_marcrelator_code = 'lit' or $cwrc_authorrole_marcrelator_text = 'libelant-appellant'">
                <xsl:text>LebelantAppellant</xsl:text>
            </xsl:when>
            <xsl:when test="$cwrc_authorrole_marcrelator_code = 'lsa' or $cwrc_authorrole_marcrelator_text = 'landscape architect'">
                <xsl:text>LandscapeArchitect</xsl:text>
            </xsl:when>
            <xsl:when test="$cwrc_authorrole_marcrelator_code = 'lse' or $cwrc_authorrole_marcrelator_text = 'licensee'">
                <xsl:text>Licensee</xsl:text>
            </xsl:when>
            <xsl:when test="$cwrc_authorrole_marcrelator_code = 'lso' or $cwrc_authorrole_marcrelator_text = 'licensor'">
                <xsl:text>Licensor</xsl:text>
            </xsl:when>
            <xsl:when test="$cwrc_authorrole_marcrelator_code = 'ltg' or $cwrc_authorrole_marcrelator_text = 'lithographer'">
                <xsl:text>Lithographer</xsl:text>
            </xsl:when>
            <xsl:when test="$cwrc_authorrole_marcrelator_code = 'lyr' or $cwrc_authorrole_marcrelator_text = 'lyricist'">
                <xsl:text>Lyricist</xsl:text>
            </xsl:when>
            <xsl:when test="$cwrc_authorrole_marcrelator_code = 'mcp' or $cwrc_authorrole_marcrelator_text = 'music copyist'">
                <xsl:text>MusicCopyist</xsl:text>
            </xsl:when>
            <xsl:when test="$cwrc_authorrole_marcrelator_code = 'mdc' or $cwrc_authorrole_marcrelator_text = 'metadata contact'">
                <xsl:text>MetadataContact</xsl:text>
            </xsl:when>
            <xsl:when test="$cwrc_authorrole_marcrelator_code = 'med' or $cwrc_authorrole_marcrelator_text = 'medium'">
                <xsl:text>Medium</xsl:text>
            </xsl:when>
            <xsl:when test="$cwrc_authorrole_marcrelator_code = 'mfp' or $cwrc_authorrole_marcrelator_text = 'manufacture place'">
                <xsl:text>ManufacturePlace</xsl:text>
            </xsl:when>
            <xsl:when test="$cwrc_authorrole_marcrelator_code = 'mfr' or $cwrc_authorrole_marcrelator_text = 'manufacturer'">
                <xsl:text>manufacturer</xsl:text>
            </xsl:when>
            <xsl:when test="$cwrc_authorrole_marcrelator_code = 'mod' or $cwrc_authorrole_marcrelator_text = 'moderator'">
                <xsl:text>Moderator</xsl:text>
            </xsl:when>
            <xsl:when test="$cwrc_authorrole_marcrelator_code = 'mon' or $cwrc_authorrole_marcrelator_text = 'monitor'">
                <xsl:text>Monitor</xsl:text>
            </xsl:when>
            <xsl:when test="$cwrc_authorrole_marcrelator_code = 'mrb' or $cwrc_authorrole_marcrelator_text = 'marbler'">
                <xsl:text>Marbler</xsl:text>
            </xsl:when>
            <xsl:when test="$cwrc_authorrole_marcrelator_code = 'mrk' or $cwrc_authorrole_marcrelator_text = 'markup editor'">
                <xsl:text>MarkupEditor</xsl:text>
            </xsl:when>
            <xsl:when test="$cwrc_authorrole_marcrelator_code = 'msd' or $cwrc_authorrole_marcrelator_text = 'musical director'">
                <xsl:text>MisucalDirector</xsl:text>
            </xsl:when>
            <xsl:when test="$cwrc_authorrole_marcrelator_code = 'mte' or $cwrc_authorrole_marcrelator_text = 'metal-engraver'">
                <xsl:text>MetalEngraver</xsl:text>
            </xsl:when>
            <xsl:when test="$cwrc_authorrole_marcrelator_code = 'mtk' or $cwrc_authorrole_marcrelator_text = 'minute taker'">
                <xsl:text>MinuteTaker</xsl:text>
            </xsl:when>
            <xsl:when test="$cwrc_authorrole_marcrelator_code = 'mus' or $cwrc_authorrole_marcrelator_text = 'musician'">
                <xsl:text>Musician</xsl:text>
            </xsl:when>
            <xsl:when test="$cwrc_authorrole_marcrelator_code = 'nrt' or $cwrc_authorrole_marcrelator_text = 'narrator'">
                <xsl:text>Narrator</xsl:text>
            </xsl:when>
            <xsl:when test="$cwrc_authorrole_marcrelator_code = 'opn' or $cwrc_authorrole_marcrelator_text = 'opponent'">
                <xsl:text>Opponent</xsl:text>
            </xsl:when>
            <xsl:when test="$cwrc_authorrole_marcrelator_code = 'org' or $cwrc_authorrole_marcrelator_text = 'originator'">
                <xsl:text>Originator</xsl:text>
            </xsl:when>
            <xsl:when test="$cwrc_authorrole_marcrelator_code = 'orm' or $cwrc_authorrole_marcrelator_text = 'organizer'">
                <xsl:text>Organizer</xsl:text>
            </xsl:when>
            <xsl:when test="$cwrc_authorrole_marcrelator_code = 'osp' or $cwrc_authorrole_marcrelator_text = 'onscreen presenter'">
                <xsl:text>OnscreenPresenter</xsl:text>
            </xsl:when>
            <xsl:when test="$cwrc_authorrole_marcrelator_code = 'oth' or $cwrc_authorrole_marcrelator_text = 'other'">
                <xsl:text>Other</xsl:text>
            </xsl:when>
            <xsl:when test="$cwrc_authorrole_marcrelator_code = 'own' or $cwrc_authorrole_marcrelator_text = 'owner'">
                <xsl:text>Owner</xsl:text>
            </xsl:when>
            <xsl:when test="$cwrc_authorrole_marcrelator_code = 'pan' or $cwrc_authorrole_marcrelator_text = 'panelist'">
                <xsl:text>Panelist</xsl:text>
            </xsl:when>
            <xsl:when test="$cwrc_authorrole_marcrelator_code = 'pat' or $cwrc_authorrole_marcrelator_text = 'patron'">
                <xsl:text>Patron</xsl:text>
            </xsl:when>
            <xsl:when test="$cwrc_authorrole_marcrelator_code = 'pbd' or $cwrc_authorrole_marcrelator_text = 'publishing director'">
                <xsl:text>PublishingDirector</xsl:text>
            </xsl:when>
            <xsl:when test="$cwrc_authorrole_marcrelator_code = 'pbl' or $cwrc_authorrole_marcrelator_text = 'publisher'">
                <xsl:text>Publisher</xsl:text>
            </xsl:when>
            <xsl:when test="$cwrc_authorrole_marcrelator_code = 'pdr' or $cwrc_authorrole_marcrelator_text = 'project director'">
                <xsl:text>ProjectDirector</xsl:text>
            </xsl:when>
            <xsl:when test="$cwrc_authorrole_marcrelator_code = 'pfr' or $cwrc_authorrole_marcrelator_text = 'proofreader'">
                <xsl:text>Proofreader</xsl:text>
            </xsl:when>
            <xsl:when test="$cwrc_authorrole_marcrelator_code = 'pht' or $cwrc_authorrole_marcrelator_text = 'photographer'">
                <xsl:text>Photographer</xsl:text>
            </xsl:when>
            <xsl:when test="$cwrc_authorrole_marcrelator_code = 'plt' or $cwrc_authorrole_marcrelator_text = 'platemaker'">
                <xsl:text>Platemaker</xsl:text>
            </xsl:when>
            <xsl:when test="$cwrc_authorrole_marcrelator_code = 'pma' or $cwrc_authorrole_marcrelator_text = 'permitting agency'">
                <xsl:text>PermittingAgency</xsl:text>
            </xsl:when>
            <xsl:when test="$cwrc_authorrole_marcrelator_code = 'pmn' or $cwrc_authorrole_marcrelator_text = 'production manager'">
                <xsl:text>ProductionManager</xsl:text>
            </xsl:when>
            <xsl:when test="$cwrc_authorrole_marcrelator_code = 'pop' or $cwrc_authorrole_marcrelator_text = 'printer of plates'">
                <xsl:text>PinterPlates</xsl:text>
            </xsl:when>
            <xsl:when test="$cwrc_authorrole_marcrelator_code = 'ppm' or $cwrc_authorrole_marcrelator_text = 'papermaker'">
                <xsl:text>Papermaker</xsl:text>
            </xsl:when>
            <xsl:when test="$cwrc_authorrole_marcrelator_code = 'ppt' or $cwrc_authorrole_marcrelator_text = 'puppeteer'">
                <xsl:text>Puppeteer</xsl:text>
            </xsl:when>
            <xsl:when test="$cwrc_authorrole_marcrelator_code = 'pra' or $cwrc_authorrole_marcrelator_text = 'praeses'">
                <xsl:text>Praeses</xsl:text>
            </xsl:when>
            <xsl:when test="$cwrc_authorrole_marcrelator_code = 'prc' or $cwrc_authorrole_marcrelator_text = 'process contact'">
                <xsl:text>ProcessContact</xsl:text>
            </xsl:when>
            <xsl:when test="$cwrc_authorrole_marcrelator_code = 'prd' or $cwrc_authorrole_marcrelator_text = 'production personnel'">
                <xsl:text>ProductionPersonnel</xsl:text>
            </xsl:when>
            <xsl:when test="$cwrc_authorrole_marcrelator_code = 'pre' or $cwrc_authorrole_marcrelator_text = 'presenter'">
                <xsl:text>Presenter</xsl:text>
            </xsl:when>
            <xsl:when test="$cwrc_authorrole_marcrelator_code = 'prf' or $cwrc_authorrole_marcrelator_text = 'performer'">
                <xsl:text>Performer</xsl:text>
            </xsl:when>
            <xsl:when test="$cwrc_authorrole_marcrelator_code = 'prg' or $cwrc_authorrole_marcrelator_text = 'programmer'">
                <xsl:text>Programmer</xsl:text>
            </xsl:when>
            <xsl:when test="$cwrc_authorrole_marcrelator_code = 'prm' or $cwrc_authorrole_marcrelator_text = 'printmaker'">
                <xsl:text>Printmaker</xsl:text>
            </xsl:when>
            <xsl:when test="$cwrc_authorrole_marcrelator_code = 'prn' or $cwrc_authorrole_marcrelator_text = 'production company'">
                <xsl:text>ProductionCompany</xsl:text>
            </xsl:when>
            <xsl:when test="$cwrc_authorrole_marcrelator_code = 'pro' or $cwrc_authorrole_marcrelator_text = 'producer'">
                <xsl:text>Producer</xsl:text>
            </xsl:when>
            <xsl:when test="$cwrc_authorrole_marcrelator_code = 'prp' or $cwrc_authorrole_marcrelator_text = 'production place'">
                <xsl:text>ProductionPlace</xsl:text>
            </xsl:when>
            <xsl:when test="$cwrc_authorrole_marcrelator_code = 'prs' or $cwrc_authorrole_marcrelator_text = 'production designer'">
                <xsl:text>ProductionDesigner</xsl:text>
            </xsl:when>
            <xsl:when test="$cwrc_authorrole_marcrelator_code = 'prt' or $cwrc_authorrole_marcrelator_text = 'printer'">
                <xsl:text>Printer</xsl:text>
            </xsl:when>
            <xsl:when test="$cwrc_authorrole_marcrelator_code = 'prv' or $cwrc_authorrole_marcrelator_text = 'provider'">
                <xsl:text>Provider</xsl:text>
            </xsl:when>
            <xsl:when test="$cwrc_authorrole_marcrelator_code = 'pta' or $cwrc_authorrole_marcrelator_text = 'patent applicant'">
                <xsl:text>PatentApplicant</xsl:text>
            </xsl:when>
            <xsl:when test="$cwrc_authorrole_marcrelator_code = 'pte' or $cwrc_authorrole_marcrelator_text = 'plaintiff-appellee'">
                <xsl:text>PlaintiffAppellee</xsl:text>
            </xsl:when>
            <xsl:when test="$cwrc_authorrole_marcrelator_code = 'ptf' or $cwrc_authorrole_marcrelator_text = 'plaintiff'">
                <xsl:text>Plaintiff</xsl:text>
            </xsl:when>
            <xsl:when test="$cwrc_authorrole_marcrelator_code = 'pth' or $cwrc_authorrole_marcrelator_text = 'patent holder'">
                <xsl:text>PatentHolder</xsl:text>
            </xsl:when>
            <xsl:when test="$cwrc_authorrole_marcrelator_code = 'ptt' or $cwrc_authorrole_marcrelator_text = 'plaintiff-appellant'">
                <xsl:text>PlaintiffAppellant</xsl:text>
            </xsl:when>
            <xsl:when test="$cwrc_authorrole_marcrelator_code = 'pup' or $cwrc_authorrole_marcrelator_text = 'publication place'">
                <xsl:text>PublicationPlace</xsl:text>
            </xsl:when>
            <xsl:when test="$cwrc_authorrole_marcrelator_code = 'rbr' or $cwrc_authorrole_marcrelator_text = 'rubricator'">
                <xsl:text>Rubricator</xsl:text>
            </xsl:when>
            <xsl:when test="$cwrc_authorrole_marcrelator_code = 'rcd' or $cwrc_authorrole_marcrelator_text = 'recordist'">
                <xsl:text>Recordist</xsl:text>
            </xsl:when>
            <xsl:when test="$cwrc_authorrole_marcrelator_code = 'rce' or $cwrc_authorrole_marcrelator_text = 'recording engineer'">
                <xsl:text>RecordingEngineer</xsl:text>
            </xsl:when>
            <xsl:when test="$cwrc_authorrole_marcrelator_code = 'rcp' or $cwrc_authorrole_marcrelator_text = 'addressee'">
                <xsl:text>Addressee</xsl:text>
            </xsl:when>
            <xsl:when test="$cwrc_authorrole_marcrelator_code = 'rdd' or $cwrc_authorrole_marcrelator_text = 'radio director'">
                <xsl:text>RadioDirector</xsl:text>
            </xsl:when>
            <xsl:when test="$cwrc_authorrole_marcrelator_code = 'red' or $cwrc_authorrole_marcrelator_text = 'redaktor'">
                <xsl:text>Redaktor</xsl:text>
            </xsl:when>
            <xsl:when test="$cwrc_authorrole_marcrelator_code = 'ren' or $cwrc_authorrole_marcrelator_text = 'renderer'">
                <xsl:text>Renderer</xsl:text>
            </xsl:when>
            <xsl:when test="$cwrc_authorrole_marcrelator_code = 'res' or $cwrc_authorrole_marcrelator_text = 'researcher'">
                <xsl:text>Researcher</xsl:text>
            </xsl:when>
            <xsl:when test="$cwrc_authorrole_marcrelator_code = 'rev' or $cwrc_authorrole_marcrelator_text = 'reviewer'">
                <xsl:text>Reviewer</xsl:text>
            </xsl:when>
            <xsl:when test="$cwrc_authorrole_marcrelator_code = 'rpc' or $cwrc_authorrole_marcrelator_text = 'radio producer'">
                <xsl:text>RadioProducer</xsl:text>
            </xsl:when>
            <xsl:when test="$cwrc_authorrole_marcrelator_code = 'rps' or $cwrc_authorrole_marcrelator_text = 'repository'">
                <xsl:text>Repository</xsl:text>
            </xsl:when>
            <xsl:when test="$cwrc_authorrole_marcrelator_code = 'rpt' or $cwrc_authorrole_marcrelator_text = 'reporter'">
                <xsl:text>Reporter</xsl:text>
            </xsl:when>
            <xsl:when test="$cwrc_authorrole_marcrelator_code = 'rpy' or $cwrc_authorrole_marcrelator_text = 'responsible party'">
                <xsl:text>ResponsibleParty</xsl:text>
            </xsl:when>
            <xsl:when test="$cwrc_authorrole_marcrelator_code = 'rse' or $cwrc_authorrole_marcrelator_text = 'respondent-appellee'">
                <xsl:text>RespondentAppellee</xsl:text>
            </xsl:when>
            <xsl:when test="$cwrc_authorrole_marcrelator_code = 'rsg' or $cwrc_authorrole_marcrelator_text = 'restager'">
                <xsl:text>Restager</xsl:text>
            </xsl:when>
            <xsl:when test="$cwrc_authorrole_marcrelator_code = 'rsp' or $cwrc_authorrole_marcrelator_text = 'respondent'">
                <xsl:text>Respondent</xsl:text>
            </xsl:when>
            <xsl:when test="$cwrc_authorrole_marcrelator_code = 'rsr' or $cwrc_authorrole_marcrelator_text = 'restorationist'">
                <xsl:text>Restorationist</xsl:text>
            </xsl:when>
            <xsl:when test="$cwrc_authorrole_marcrelator_code = 'rst' or $cwrc_authorrole_marcrelator_text = 'respondent-appellant'">
                <xsl:text>RespondentAppellant</xsl:text>
            </xsl:when>
            <xsl:when test="$cwrc_authorrole_marcrelator_code = 'rth' or $cwrc_authorrole_marcrelator_text = 'research team head'">
                <xsl:text>ResearchTeamHead</xsl:text>
            </xsl:when>
            <xsl:when test="$cwrc_authorrole_marcrelator_code = 'rtm' or $cwrc_authorrole_marcrelator_text = 'research team member'">
                <xsl:text>ResearchTeamMember</xsl:text>
            </xsl:when>
            <xsl:when test="$cwrc_authorrole_marcrelator_code = 'sad' or $cwrc_authorrole_marcrelator_text = 'scientific advisor'">
                <xsl:text>ScientificAdvisor</xsl:text>
            </xsl:when>
            <xsl:when test="$cwrc_authorrole_marcrelator_code = 'sce' or $cwrc_authorrole_marcrelator_text = 'scenarist'">
                <xsl:text>Scenarist</xsl:text>
            </xsl:when>
            <xsl:when test="$cwrc_authorrole_marcrelator_code = 'scl' or $cwrc_authorrole_marcrelator_text = 'sculptor'">
                <xsl:text>Sculptor</xsl:text>
            </xsl:when>
            <xsl:when test="$cwrc_authorrole_marcrelator_code = 'scr' or $cwrc_authorrole_marcrelator_text = 'scribe'">
                <xsl:text>Scribe</xsl:text>
            </xsl:when>
            <xsl:when test="$cwrc_authorrole_marcrelator_code = 'sds' or $cwrc_authorrole_marcrelator_text = 'sound designer'">
                <xsl:text>SoundDesigner</xsl:text>
            </xsl:when>
            <xsl:when test="$cwrc_authorrole_marcrelator_code = 'sec' or $cwrc_authorrole_marcrelator_text = 'secretary'">
                <xsl:text>Secretary</xsl:text>
            </xsl:when>
            <xsl:when test="$cwrc_authorrole_marcrelator_code = 'sgd' or $cwrc_authorrole_marcrelator_text = 'stage director'">
                <xsl:text>StageDirector</xsl:text>
            </xsl:when>
            <xsl:when test="$cwrc_authorrole_marcrelator_code = 'sgn' or $cwrc_authorrole_marcrelator_text = 'signer'">
                <xsl:text>Signer</xsl:text>
            </xsl:when>
            <xsl:when test="$cwrc_authorrole_marcrelator_code = 'sht' or $cwrc_authorrole_marcrelator_text = 'supporting host'">
                <xsl:text>SupportingHost</xsl:text>
            </xsl:when>
            <xsl:when test="$cwrc_authorrole_marcrelator_code = 'sll' or $cwrc_authorrole_marcrelator_text = 'seller'">
                <xsl:text>Seller</xsl:text>
            </xsl:when>
            <xsl:when test="$cwrc_authorrole_marcrelator_code = 'sng' or $cwrc_authorrole_marcrelator_text = 'singer'">
                <xsl:text>Singer</xsl:text>
            </xsl:when>
            <xsl:when test="$cwrc_authorrole_marcrelator_code = 'spk' or $cwrc_authorrole_marcrelator_text = 'speaker'">
                <xsl:text>Speaker</xsl:text>
            </xsl:when>
            <xsl:when test="$cwrc_authorrole_marcrelator_code = 'spn' or $cwrc_authorrole_marcrelator_text = 'sponsor'">
                <xsl:text>Sponsor</xsl:text>
            </xsl:when>
            <xsl:when test="$cwrc_authorrole_marcrelator_code = 'spy' or $cwrc_authorrole_marcrelator_text = 'second party'">
                <xsl:text>SecondParty</xsl:text>
            </xsl:when>
            <xsl:when test="$cwrc_authorrole_marcrelator_code = 'srv' or $cwrc_authorrole_marcrelator_text = 'surveyor'">
                <xsl:text>Surveyor</xsl:text>
            </xsl:when>
            <xsl:when test="$cwrc_authorrole_marcrelator_code = 'std' or $cwrc_authorrole_marcrelator_text = 'set designer'">
                <xsl:text>SetDesigner</xsl:text>
            </xsl:when>
            <xsl:when test="$cwrc_authorrole_marcrelator_code = 'stg' or $cwrc_authorrole_marcrelator_text = 'setting'">
                <xsl:text>Setting</xsl:text>
            </xsl:when>
            <xsl:when test="$cwrc_authorrole_marcrelator_code = 'stl' or $cwrc_authorrole_marcrelator_text = 'storyteller'">
                <xsl:text>StoryTeller</xsl:text>
            </xsl:when>
            <xsl:when test="$cwrc_authorrole_marcrelator_code = 'stm' or $cwrc_authorrole_marcrelator_text = 'stage manager'">
                <xsl:text>StageManager</xsl:text>
            </xsl:when>
            <xsl:when test="$cwrc_authorrole_marcrelator_code = 'stn' or $cwrc_authorrole_marcrelator_text = 'standards body'">
                <xsl:text>StandardsBody</xsl:text>
            </xsl:when>
            <xsl:when test="$cwrc_authorrole_marcrelator_code = 'str' or $cwrc_authorrole_marcrelator_text = 'stereotyper'">
                <xsl:text>Stereotyper</xsl:text>
            </xsl:when>
            <xsl:when test="$cwrc_authorrole_marcrelator_code = 'tcd' or $cwrc_authorrole_marcrelator_text = 'technical director'">
                <xsl:text>TechnicalDirector</xsl:text>
            </xsl:when>
            <xsl:when test="$cwrc_authorrole_marcrelator_code = 'tch' or $cwrc_authorrole_marcrelator_text = 'teacher'">
                <xsl:text>Teacher</xsl:text>
            </xsl:when>
            <xsl:when test="$cwrc_authorrole_marcrelator_code = 'ths' or $cwrc_authorrole_marcrelator_text = 'thesis advisor'">
                <xsl:text>ThesisAdvisor</xsl:text>
            </xsl:when>
            <xsl:when test="$cwrc_authorrole_marcrelator_code = 'tld' or $cwrc_authorrole_marcrelator_text = 'television director'">
                <xsl:text>TelevisionDirector</xsl:text>
            </xsl:when>
            <xsl:when test="$cwrc_authorrole_marcrelator_code = 'tlp' or $cwrc_authorrole_marcrelator_text = 'television producer'">
                <xsl:text>TelevisionProducer</xsl:text>
            </xsl:when>
            <xsl:when test="$cwrc_authorrole_marcrelator_code = 'trc' or $cwrc_authorrole_marcrelator_text = 'transcriber'">
                <xsl:text>Transcriber</xsl:text>
            </xsl:when>
            <xsl:when test="$cwrc_authorrole_marcrelator_code = 'trl' or $cwrc_authorrole_marcrelator_text = 'translator'">
                <xsl:text>Translator</xsl:text>
            </xsl:when>
            <xsl:when test="$cwrc_authorrole_marcrelator_code = 'tyd' or $cwrc_authorrole_marcrelator_text = 'type designer'">
                <xsl:text>TypeDesigner</xsl:text>
            </xsl:when>
            <xsl:when test="$cwrc_authorrole_marcrelator_code = 'tyg' or $cwrc_authorrole_marcrelator_text = 'typographer'">
                <xsl:text>Typographer</xsl:text>
            </xsl:when>
            <xsl:when test="$cwrc_authorrole_marcrelator_code = 'uvp' or $cwrc_authorrole_marcrelator_text = 'university place'">
                <xsl:text>UniversityPlace</xsl:text>
            </xsl:when>
            <xsl:when test="$cwrc_authorrole_marcrelator_code = 'vac' or $cwrc_authorrole_marcrelator_text = 'voice actor'">
                <xsl:text>VoiceActor</xsl:text>
            </xsl:when>
            <xsl:when test="$cwrc_authorrole_marcrelator_code = 'vdg' or $cwrc_authorrole_marcrelator_text = 'videographer'">
                <xsl:text>Videographer</xsl:text>
            </xsl:when>
            <xsl:when test="$cwrc_authorrole_marcrelator_code = '-voc' or $cwrc_authorrole_marcrelator_text = 'vocalist'">
                <xsl:text>Vocalist</xsl:text>
            </xsl:when>
            <xsl:when test="$cwrc_authorrole_marcrelator_code = 'wac' or $cwrc_authorrole_marcrelator_text = 'writer of added commentary'">
                <xsl:text>WriterAddedCommentary</xsl:text>
            </xsl:when>
            <xsl:when test="$cwrc_authorrole_marcrelator_code = 'wal' or $cwrc_authorrole_marcrelator_text = 'writer of added lyrics'">
                <xsl:text>WriterAddedLyrics</xsl:text>
            </xsl:when>
            <xsl:when test="$cwrc_authorrole_marcrelator_code = 'wam' or $cwrc_authorrole_marcrelator_text = 'writer of accompanying material'">
                <xsl:text>WriterAccompanyingMaterial</xsl:text>
            </xsl:when>
            <xsl:when test="$cwrc_authorrole_marcrelator_code = 'wat' or $cwrc_authorrole_marcrelator_text = 'writer of added text'">
                <xsl:text>WriterAddedText</xsl:text>
            </xsl:when>
            <xsl:when test="$cwrc_authorrole_marcrelator_code = 'wdc' or $cwrc_authorrole_marcrelator_text = 'woodcutter'">
                <xsl:text>Woodcutter</xsl:text>
            </xsl:when>
            <xsl:when test="$cwrc_authorrole_marcrelator_code = 'wde' or $cwrc_authorrole_marcrelator_text = 'wood engraver'">
                <xsl:text>WoodEngraver</xsl:text>
            </xsl:when>
            <xsl:when test="$cwrc_authorrole_marcrelator_code = 'win' or $cwrc_authorrole_marcrelator_text = 'writer of introduction'">
                <xsl:text>WriterIntroduction</xsl:text>
            </xsl:when>
            <xsl:when test="$cwrc_authorrole_marcrelator_code = 'wit' or $cwrc_authorrole_marcrelator_text = 'witness'">
                <xsl:text>Witness</xsl:text>
            </xsl:when>
            <xsl:when test="$cwrc_authorrole_marcrelator_code = 'wpr' or $cwrc_authorrole_marcrelator_text = 'writer of preface'">
                <xsl:text>WriterPreface</xsl:text>
            </xsl:when>
            <xsl:when test="$cwrc_authorrole_marcrelator_code = 'wst' or $cwrc_authorrole_marcrelator_text = 'writer of supplementary textual content'">
                <xsl:text>WriterSupplementaryTextualContent</xsl:text>
            </xsl:when>
            <xsl:otherwise>
                <xsl:text>Unknown</xsl:text>
            </xsl:otherwise>
        </xsl:choose>

    </xsl:template>


    <!-- genre section -->
    <xsl:template match="mods:typeOfResource | mods:genre" mode="cwrc_entities_mods">
        <xsl:param name="local_prefix" />
        <xsl:param name="local_field_root" />

        <xsl:call-template name="add_solr_field">
            <xsl:with-param name="solr_field_key" select="concat($local_prefix, $local_field_root, '_s')" />
            <xsl:with-param name="solr_field_value" select="text()" />
        </xsl:call-template>

    </xsl:template>


    <!-- handle originInfo section -->
    <xsl:template match="mods:originInfo" mode="cwrc_entities_mods">
        <xsl:param name="local_prefix" />

        <xsl:apply-templates select="mods:place/mods:placeTerm" mode="cwrc_entities_mods">
            <xsl:with-param name="local_field_name" select="concat($local_prefix,'_PlaceOfPublication')" />
        </xsl:apply-templates>

        <xsl:apply-templates select="mods:place/mods:placeTerm/@valueURI" mode="cwrc_entities_mods">
            <xsl:with-param name="local_field_name" select="concat($local_prefix,'_PlaceOfPublication-URI')" />
        </xsl:apply-templates>

        <xsl:apply-templates select="mods:publisher" mode="cwrc_entities_mods">
            <xsl:with-param name="local_field_name" select="concat($local_prefix, '_publisher')"/>
        </xsl:apply-templates>

        <xsl:apply-templates select="mods:publisher/@valueURI" mode="cwrc_entities_mods">
            <xsl:with-param name="local_field_name" select="concat($local_prefix, '_publisher-URI')"/>
        </xsl:apply-templates>

        <xsl:apply-templates select="mods:dateIssued" mode="cwrc_entities_mods">
            <xsl:with-param name="local_field_name" select="concat($local_prefix, '_dateIssued')"/>
        </xsl:apply-templates>

        <xsl:apply-templates select="mods:edition" mode="cwrc_entities_mods">
            <xsl:with-param name="local_field_name" select="concat($local_prefix, '_edition')"/>
        </xsl:apply-templates>

        <xsl:apply-templates select="mods:issuance" mode="cwrc_entities_mods">
            <xsl:with-param name="local_field_name" select="concat($local_prefix, '_issuance')"/>
        </xsl:apply-templates>

    </xsl:template>


    <!-- handle subject section -->
    <xsl:template match="mods:subject" mode="cwrc_entities_mods">
        <xsl:param name="local_prefix" />

        <xsl:apply-templates select="mods:topic" mode="cwrc_entities_mods">
            <xsl:with-param name="local_field_name" select="concat($local_prefix,'_topic')" />
        </xsl:apply-templates>

        <xsl:apply-templates select="mods:topic/@valueURI" mode="cwrc_entities_mods">
            <xsl:with-param name="local_field_name" select="concat($local_prefix,'_topic-URI')" />
        </xsl:apply-templates>

        <xsl:apply-templates select="mods:geographic" mode="cwrc_entities_mods">
            <xsl:with-param name="local_field_name" select="concat($local_prefix, '_geographic')"/>
        </xsl:apply-templates>

        <xsl:apply-templates select="mods:geographic/@valueURI" mode="cwrc_entities_mods">
            <xsl:with-param name="local_field_name" select="concat($local_prefix, '_geographic-URI')"/>
        </xsl:apply-templates>

        <xsl:apply-templates select="mods:temporal" mode="cwrc_entities_mods">
            <xsl:with-param name="local_field_name" select="concat($local_prefix, '_temporal')"/>
        </xsl:apply-templates>

        <xsl:apply-templates select="mods:titleInfo" mode="cwrc_entities_mods">
            <xsl:with-param name="local_field_name" select="concat($local_prefix, '_titleInfo')"/>
        </xsl:apply-templates>

        <xsl:apply-templates select="mods:titleInfo/@valueURI" mode="cwrc_entities_mods">
            <xsl:with-param name="local_prefix" select="concat($local_prefix, '_titleInfo')"/>
        </xsl:apply-templates>

        <xsl:apply-templates select="mods:namePart" mode="cwrc_entities_mods">
            <xsl:with-param name="local_field_name" select="concat($local_prefix, '_namePart')"/>
        </xsl:apply-templates>

        <xsl:apply-templates select="mods:namePart/@valueURI" mode="cwrc_entities_mods">
            <xsl:with-param name="local_field_name" select="concat($local_prefix, '_namePart-URI')"/>
        </xsl:apply-templates>

    </xsl:template>


    <!-- handle relatedItem section -->
    <xsl:template match="mods:relatedItem" mode="cwrc_entities_mods">
        <xsl:param name="local_prefix" />

        <xsl:apply-templates select=" current()[@type='host']/mods:titleInfo/mods:title" mode="cwrc_entities_mods">
            <xsl:with-param name="local_field_name" select="concat($local_prefix,'_ContainerOrHost')" />
        </xsl:apply-templates>

        <xsl:apply-templates select="current()[not(@type='host')]/mods:titleInfo/mods:title" mode="cwrc_entities_mods">
            <xsl:with-param name="local_field_name" select="$local_prefix" />
        </xsl:apply-templates>

        <!-- handle name section -->
        <xsl:apply-templates select="mods:name" mode="cwrc_entities_mods">
            <xsl:with-param name="local_prefix" select="concat($local_prefix,'_name')" />
        </xsl:apply-templates>

        <xsl:apply-templates select="
                mods:identifier[@type='issue-number']
                | mods:identifier[@type='matrix-number']
                | mods:identifier[@type='ean']
                | mods:identifier[@type='isbn']
                | mods:identifier[@type='upc']
            " mode="cwrc_entities_mods">
            <xsl:with-param name="local_field_name" select="concat($local_prefix,'_uniqueIdentifier')" />
        </xsl:apply-templates>

        <xsl:apply-templates select="mods:identifier[@type='issue-number']"  mode="cwrc_entities_mods">
            <xsl:with-param name="local_field_name" select="concat($local_prefix, '_issueNumber')"/>
        </xsl:apply-templates>

        <xsl:apply-templates select="mods:location" mode="cwrc_entities_mods">
            <xsl:with-param name="local_prefix" select="concat($local_prefix, '_location')"/>
        </xsl:apply-templates>

    </xsl:template>


    <!-- handle recordInfo section -->
    <xsl:template match="mods:recordInfo" mode="cwrc_entities_mods">
        <xsl:param name="local_prefix" />

        <xsl:apply-templates select="mods:recordIdentifier" mode="cwrc_entities_mods">
            <xsl:with-param name="local_field_name" select="concat($local_prefix,'_recordIdentifier')" />
        </xsl:apply-templates>

        <xsl:apply-templates select="mods:recordCreationDate" mode="cwrc_entities_mods">
            <xsl:with-param name="local_field_name" select="concat($local_prefix,'_recordCreationDate')" />
        </xsl:apply-templates>

        <xsl:apply-templates select="mods:recordOrigin" mode="cwrc_entities_mods">
            <xsl:with-param name="local_field_name" select="concat($local_prefix,'_recordOrigin')" />
        </xsl:apply-templates>

        <xsl:apply-templates select="mods:recordContentSource" mode="cwrc_entities_mods">
            <xsl:with-param name="local_field_name" select="concat($local_prefix,'_recordContentSource')" />
        </xsl:apply-templates>

    </xsl:template>


    <!-- handle location section -->
    <xsl:template match="mods:location" mode="cwrc_entities_mods">
        <xsl:param name="local_prefix" select="'unknown_location'"/>

        <xsl:apply-templates select="mods:url" mode="cwrc_entities_mods">
            <xsl:with-param name="local_field_name" select="concat($local_prefix,'-url')" />
        </xsl:apply-templates>

        <xsl:apply-templates select="mods:physicalLocation" mode="cwrc_entities_mods">
            <xsl:with-param name="local_field_name" select="concat($local_prefix,'_physicalLocation')" />
        </xsl:apply-templates>

        <xsl:apply-templates select="mods:shelfLocator" mode="cwrc_entities_mods">
            <xsl:with-param name="local_field_name" select="concat($local_prefix,'_shelfLocator')" />
        </xsl:apply-templates>

    </xsl:template>


    <!-- handle mods:part section -->
    <xsl:template match="mods:part" mode="cwrc_entities_mods">
        <xsl:param name="local_prefix" />

        <xsl:apply-templates select="mods:detail[@type='volume']" mode="cwrc_entities_mods">
            <xsl:with-param name="local_field_name" select="concat($local_prefix,'detail-volume')" />
        </xsl:apply-templates>

        <xsl:apply-templates select="mods:detail[@type='number'] | mods:detail/mods:number" mode="cwrc_entities_mods">
            <xsl:with-param name="local_field_name" select="concat($local_prefix,'detail-number')" />
        </xsl:apply-templates>

        <xsl:apply-templates select="mods:extent" mode="cwrc_entities_mods">
            <xsl:with-param name="local_field_name" select="concat($local_prefix,'_extent')" />
        </xsl:apply-templates>

    </xsl:template>


    <!-- generic field -->
    <xsl:template match="* | @*" mode="cwrc_entities_mods">
        <xsl:param name="local_field_name" select="'unknown'" />

        <xsl:call-template name="add_solr_field">
            <xsl:with-param name="solr_field_key" select="$local_field_name" />
            <xsl:with-param name="solr_field_value" select="." />
        </xsl:call-template>

    </xsl:template>

    <!-- generic field -->
    <xsl:template match="text()" mode="cwrc_entities_mods">
        <xsl:param name="local_field_name" select="'unknown'" />

        <xsl:call-template name="add_solr_field">
            <xsl:with-param name="solr_field_key" select="$local_field_name" />
            <xsl:with-param name="solr_field_value" select="." />
        </xsl:call-template>

    </xsl:template>

    <!-- generic field -->
    <xsl:template name="add_solr_field">
        <xsl:param name="solr_field_key" select="'unknown'" />
        <xsl:param name="solr_field_value" select="'unknown'" />

        <field>
            <xsl:attribute name="name">
                <xsl:value-of select="$solr_field_key" />
            </xsl:attribute>

            <xsl:value-of select="$solr_field_value" />
        </field>

    </xsl:template>


</xsl:stylesheet>
