<?xml version="1.0" encoding="UTF-8"?>

<xsl:stylesheet 
    version="1.0" 
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"  
    xmlns:mods="http://www.loc.gov/mods/v3" 
    exclude-result-prefixes="mods"
    >
    
    <xsl:include href="CWRC_Helpers_MODS.xslt" />

    <!-- 
        * MARC Relator 
        * Foreach MARC Relator, create a Solr field with a key_name based on the relator term and value based on the person name
        
    -->

    <!-- XSLT 1.0 toLower -->
    <xsl:variable name="lowercase" select="'abcdefghijklmnopqrstuvwxyz'" />
    <xsl:variable name="uppercase" select="'ABCDEFGHIJKLMNOPQRSTUVWXYZ'" />


    <xsl:template match="/">
        <xsl:apply-templates select="mods:mods/mods:name" mode="cwrc_entities_mods">
            <xsl:with-param name="cwrc_1">1</xsl:with-param>
        </xsl:apply-templates>
    </xsl:template>

    <!-- For each person name -->
    <xsl:template match="mods:name" mode="cwrc_entities_mods">

        <xsl:param name="cwrc_1"></xsl:param>

        <xsl:variable name="cwrc_author_name">
            <xsl:call-template name="assemble_cwrc_title_author"/>
        </xsl:variable>

        <xsl:apply-templates select="mods:role" mode="cwrc_entities_mods">
            <xsl:with-param name="cwrc_author_name" select="$cwrc_author_name" />
            <xsl:with-param name="local_prefix" select="'mods'" />
        </xsl:apply-templates>

    </xsl:template>

    <!-- convert MARC relator to Solr field name -->
    <xsl:template match="mods:role" mode="cwrc_entities_mods">
        <xsl:param name="cwrc_author_name" select="'unknown'" />
        <xsl:param name="local_prefix" select="'mods'" />

        <!-- if mods:role contains multiple roleTerms which don't match then only the first will be recorded (hence [1] selector) -->
        <xsl:variable name="cwrc_authorrole_marcrelator_text">
            <!-- convert to lower case -->
            <xsl:value-of select="translate(mods:roleTerm[@authority = 'marcrelator' and @type = 'text'][1], $uppercase, $lowercase)" />
        </xsl:variable>
        <xsl:variable name="cwrc_authorrole_marcrelator_code" select="mods:roleTerm[@authority = 'marcrelator' and @type = 'code'][1]" />

        <xsl:variable name="cwrc_role_root">
            <xsl:call-template name="cwrc_mods_marcrelator_field_root">
                <xsl:with-param name="cwrc_authorrole_marcrelator_code" select="$cwrc_authorrole_marcrelator_code" />
                <xsl:with-param name="cwrc_authorrole_marcrelator_text" select="$cwrc_authorrole_marcrelator_text" />
            </xsl:call-template>
        </xsl:variable>

        <field>
            <xsl:attribute name="name">
                <xsl:value-of select="concat($local_prefix, '_name_role_', $cwrc_role_root ,'_s')" />
            </xsl:attribute>
            
            <xsl:value-of select="$cwrc_author_name"/>
        </field>

    </xsl:template>


    <!-- given a MODS marcrelator 'code' or 'text', return the root of the Solr field -->
    <xsl:template name="cwrc_mods_marcrelator_field_root">
        <xsl:param name="cwrc_authorrole_marcrelator_code"></xsl:param>
        <xsl:param name="cwrc_authorrole_marcrelator_text"></xsl:param>

            <xsl:choose>
                <xsl:when test="$cwrc_authorrole_marcrelator_code = 'abr' or $cwrc_authorrole_marcrelator_text = 'Abridger'">
                    <xsl:text>Abridger</xsl:text>
                </xsl:when>
                <xsl:when test="$cwrc_authorrole_marcrelator_code = 'acp' or $cwrc_authorrole_marcrelator_text = 'Art copyist'">
                    <xsl:text>ArtCopyist</xsl:text>
                </xsl:when>
                <xsl:when test="$cwrc_authorrole_marcrelator_code = 'act' or $cwrc_authorrole_marcrelator_text = 'Actor'">
                    <xsl:text>Actor</xsl:text>
                </xsl:when>
                <xsl:when test="$cwrc_authorrole_marcrelator_code = 'adi' or $cwrc_authorrole_marcrelator_text = 'Art director'">
                    <xsl:text>ArtDirector</xsl:text>
                </xsl:when>
                <xsl:when test="$cwrc_authorrole_marcrelator_code = 'adp' or $cwrc_authorrole_marcrelator_text = 'Adapter'">
                    <xsl:text>Adapter</xsl:text>
                </xsl:when>
                <xsl:when test="$cwrc_authorrole_marcrelator_code = 'aft' or $cwrc_authorrole_marcrelator_text = 'Author of afterword, colophon, etc.'">
                    <xsl:text>AuthorAfterwordColophon</xsl:text>
                </xsl:when>
                <xsl:when test="$cwrc_authorrole_marcrelator_code = 'anl' or $cwrc_authorrole_marcrelator_text = 'Analyst'">
                    <xsl:text>Analyst</xsl:text>
                </xsl:when>
                <xsl:when test="$cwrc_authorrole_marcrelator_code = 'anm' or $cwrc_authorrole_marcrelator_text = 'Animator'">
                    <xsl:text>Animator</xsl:text>
                </xsl:when>
                <xsl:when test="$cwrc_authorrole_marcrelator_code = 'ann' or $cwrc_authorrole_marcrelator_text = 'Annotator'">
                    <xsl:text>Annotator</xsl:text>
                </xsl:when>
                <xsl:when test="$cwrc_authorrole_marcrelator_code = 'ant' or $cwrc_authorrole_marcrelator_text = 'Bibliographic antecedent'">
                    <xsl:text>BibliographicAntecedent</xsl:text>
                </xsl:when>
                <xsl:when test="$cwrc_authorrole_marcrelator_code = 'ape' or $cwrc_authorrole_marcrelator_text = 'Appellee'">
                    <xsl:text>Appellee</xsl:text>
                </xsl:when>
                <xsl:when test="$cwrc_authorrole_marcrelator_code = 'apl' or $cwrc_authorrole_marcrelator_text = 'Appellant'">
                    <xsl:text>Appellant</xsl:text>
                </xsl:when>
                <xsl:when test="$cwrc_authorrole_marcrelator_code = 'app' or $cwrc_authorrole_marcrelator_text = 'Applicant'">
                    <xsl:text>Applicant</xsl:text>
                </xsl:when>
                <xsl:when test="$cwrc_authorrole_marcrelator_code = 'aqt' or $cwrc_authorrole_marcrelator_text = 'Author in quotations or text abstracts'">
                    <xsl:text>AuthorQuotationsTextAbstracts</xsl:text>
                </xsl:when>
                <xsl:when test="$cwrc_authorrole_marcrelator_code = 'arc' or $cwrc_authorrole_marcrelator_text = 'Architect'">
                    <xsl:text>Architect</xsl:text>
                </xsl:when>
                <xsl:when test="$cwrc_authorrole_marcrelator_code = 'ard' or $cwrc_authorrole_marcrelator_text = 'Artistic director'">
                    <xsl:text>ArtisticDirector</xsl:text>
                </xsl:when>
                <xsl:when test="$cwrc_authorrole_marcrelator_code = 'arr' or $cwrc_authorrole_marcrelator_text = 'Arranger'">
                    <xsl:text>Arranger</xsl:text>
                </xsl:when>
                <xsl:when test="$cwrc_authorrole_marcrelator_code = 'art' or $cwrc_authorrole_marcrelator_text = 'Artist'">
                    <xsl:text>Artist</xsl:text>
                </xsl:when>
                <xsl:when test="$cwrc_authorrole_marcrelator_code = 'asg' or $cwrc_authorrole_marcrelator_text = 'Assignee'">
                    <xsl:text>Assignee</xsl:text>
                </xsl:when>
                <xsl:when test="$cwrc_authorrole_marcrelator_code = 'asn' or $cwrc_authorrole_marcrelator_text = 'Associated name'">
                    <xsl:text>AssociatedName</xsl:text>
                </xsl:when>
                <xsl:when test="$cwrc_authorrole_marcrelator_code = 'ato' or $cwrc_authorrole_marcrelator_text = 'Autographer'">
                    <xsl:text>Autographer</xsl:text>
                </xsl:when>
                <xsl:when test="$cwrc_authorrole_marcrelator_code = 'att' or $cwrc_authorrole_marcrelator_text = 'Attributed name'">
                    <xsl:text>AttributedName</xsl:text>
                </xsl:when>
                <xsl:when test="$cwrc_authorrole_marcrelator_code = 'auc' or $cwrc_authorrole_marcrelator_text = 'Auctioneer'">
                    <xsl:text>Auctioneer</xsl:text>
                </xsl:when>
                <xsl:when test="$cwrc_authorrole_marcrelator_code = 'aud' or $cwrc_authorrole_marcrelator_text = 'Author of dialog'">
                    <xsl:text>AuthorDialog</xsl:text>
                </xsl:when>
                <xsl:when test="$cwrc_authorrole_marcrelator_code = 'aui' or $cwrc_authorrole_marcrelator_text = 'Author of introduction, etc.'">
                    <xsl:text>AuthorIntroduction</xsl:text>
                </xsl:when>
                <xsl:when test="$cwrc_authorrole_marcrelator_code = 'aus' or $cwrc_authorrole_marcrelator_text = 'Screenwriter'">
                    <xsl:text>Screenwriter</xsl:text>
                </xsl:when>
                <xsl:when test="$cwrc_authorrole_marcrelator_code = 'aut' or $cwrc_authorrole_marcrelator_text = 'Author'">
                    <xsl:text>Author</xsl:text>
                </xsl:when>
                <xsl:when test="$cwrc_authorrole_marcrelator_code = 'bdd' or $cwrc_authorrole_marcrelator_text = 'Binding designer'">
                    <xsl:text>BindingDesigner</xsl:text>
                </xsl:when>
                <xsl:when test="$cwrc_authorrole_marcrelator_code = 'bjd' or $cwrc_authorrole_marcrelator_text = 'Bookjacket designer'">
                    <xsl:text>BookjacketDesigner</xsl:text>
                </xsl:when>
                <xsl:when test="$cwrc_authorrole_marcrelator_code = 'bkd' or $cwrc_authorrole_marcrelator_text = 'Book designer'">
                    <xsl:text>BookDesigner</xsl:text>
                </xsl:when>
                <xsl:when test="$cwrc_authorrole_marcrelator_code = 'bkp' or $cwrc_authorrole_marcrelator_text = 'Book producer'">
                    <xsl:text>BookProducer</xsl:text>
                </xsl:when>
                <xsl:when test="$cwrc_authorrole_marcrelator_code = 'blw' or $cwrc_authorrole_marcrelator_text = 'Blurb writer'">
                    <xsl:text>BlurbWriter</xsl:text>
                </xsl:when>
                <xsl:when test="$cwrc_authorrole_marcrelator_code = 'bnd' or $cwrc_authorrole_marcrelator_text = 'Binder'">
                    <xsl:text>Binder</xsl:text>
                </xsl:when>
                <xsl:when test="$cwrc_authorrole_marcrelator_code = 'bpd' or $cwrc_authorrole_marcrelator_text = 'Bookplate designer'">
                    <xsl:text>BookplateDesigner</xsl:text>
                </xsl:when>
                <xsl:when test="$cwrc_authorrole_marcrelator_code = 'brd' or $cwrc_authorrole_marcrelator_text = 'Broadcaster'">
                    <xsl:text>Broadcaster</xsl:text>
                </xsl:when>
                <xsl:when test="$cwrc_authorrole_marcrelator_code = 'brl' or $cwrc_authorrole_marcrelator_text = 'Braille embosser'">
                    <xsl:text>BrailleEmbosser</xsl:text>
                </xsl:when>
                <xsl:when test="$cwrc_authorrole_marcrelator_code = 'bsl' or $cwrc_authorrole_marcrelator_text = 'Bookseller'">
                    <xsl:text>Bookseller</xsl:text>
                </xsl:when>
                <xsl:when test="$cwrc_authorrole_marcrelator_code = 'cas' or $cwrc_authorrole_marcrelator_text = 'Caster'">
                    <xsl:text>Caster</xsl:text>
                </xsl:when>
                <xsl:when test="$cwrc_authorrole_marcrelator_code = 'ccp' or $cwrc_authorrole_marcrelator_text = 'Conceptor'">
                    <xsl:text>Conceptor</xsl:text>
                </xsl:when>
                <xsl:when test="$cwrc_authorrole_marcrelator_code = 'chr' or $cwrc_authorrole_marcrelator_text = 'Choreographer'">
                    <xsl:text>Choreographer</xsl:text>
                </xsl:when>
                <xsl:when test="$cwrc_authorrole_marcrelator_code = '-clb' or $cwrc_authorrole_marcrelator_text = 'Collaborator'">
                    <xsl:text>Collaborator</xsl:text>
                </xsl:when>
                <xsl:when test="$cwrc_authorrole_marcrelator_code = 'cli' or $cwrc_authorrole_marcrelator_text = 'Client'">
                    <xsl:text>Client</xsl:text>
                </xsl:when>
                <xsl:when test="$cwrc_authorrole_marcrelator_code = 'cll' or $cwrc_authorrole_marcrelator_text = 'Calligrapher'">
                    <xsl:text>Calligrapher</xsl:text>
                </xsl:when>
                <xsl:when test="$cwrc_authorrole_marcrelator_code = 'clr' or $cwrc_authorrole_marcrelator_text = 'Colorist'">
                    <xsl:text>Colorist</xsl:text>
                </xsl:when>
                <xsl:when test="$cwrc_authorrole_marcrelator_code = 'clt' or $cwrc_authorrole_marcrelator_text = 'Collotyper'">
                    <xsl:text>Collotyper</xsl:text>
                </xsl:when>
                <xsl:when test="$cwrc_authorrole_marcrelator_code = 'cmm' or $cwrc_authorrole_marcrelator_text = 'Commentator'">
                    <xsl:text>Commentator</xsl:text>
                </xsl:when>
                <xsl:when test="$cwrc_authorrole_marcrelator_code = 'cmp' or $cwrc_authorrole_marcrelator_text = 'Composer'">
                    <xsl:text>Composer</xsl:text>
                </xsl:when>
                <xsl:when test="$cwrc_authorrole_marcrelator_code = 'cmt' or $cwrc_authorrole_marcrelator_text = 'Compositor'">
                    <xsl:text>Compositor</xsl:text>
                </xsl:when>
                <xsl:when test="$cwrc_authorrole_marcrelator_code = 'cnd' or $cwrc_authorrole_marcrelator_text = 'Conductor'">
                    <xsl:text>Conductor</xsl:text>
                </xsl:when>
                <xsl:when test="$cwrc_authorrole_marcrelator_code = 'cng' or $cwrc_authorrole_marcrelator_text = 'Cinematographer'">
                    <xsl:text>Cinematorgrapher</xsl:text>
                </xsl:when>
                <xsl:when test="$cwrc_authorrole_marcrelator_code = 'cns' or $cwrc_authorrole_marcrelator_text = 'Censor'">
                    <xsl:text>Censor</xsl:text>
                </xsl:when>
                <xsl:when test="$cwrc_authorrole_marcrelator_code = 'coe' or $cwrc_authorrole_marcrelator_text = 'Contestant-appellee'">
                    <xsl:text>ContestantAppellee</xsl:text>
                </xsl:when>
                <xsl:when test="$cwrc_authorrole_marcrelator_code = 'col' or $cwrc_authorrole_marcrelator_text = 'Collector'">
                    <xsl:text>Collector</xsl:text>
                </xsl:when>
                <xsl:when test="$cwrc_authorrole_marcrelator_code = 'com' or $cwrc_authorrole_marcrelator_text = 'Compiler'">
                    <xsl:text>Compiler</xsl:text>
                </xsl:when>
                <xsl:when test="$cwrc_authorrole_marcrelator_code = 'con' or $cwrc_authorrole_marcrelator_text = 'Conservator'">
                    <xsl:text>Conservator</xsl:text>
                </xsl:when>
                <xsl:when test="$cwrc_authorrole_marcrelator_code = 'cor' or $cwrc_authorrole_marcrelator_text = 'Collection registrar'">
                    <xsl:text>CollectionRegistrar</xsl:text>
                </xsl:when>
                <xsl:when test="$cwrc_authorrole_marcrelator_code = 'cos' or $cwrc_authorrole_marcrelator_text = 'Contestant'">
                    <xsl:text>Contestant</xsl:text>
                </xsl:when>
                <xsl:when test="$cwrc_authorrole_marcrelator_code = 'cot' or $cwrc_authorrole_marcrelator_text = 'Contestant-appellant'">
                    <xsl:text>ContestantAppellant</xsl:text>
                </xsl:when>
                <xsl:when test="$cwrc_authorrole_marcrelator_code = 'cou' or $cwrc_authorrole_marcrelator_text = 'Court governed'">
                    <xsl:text>CourtGoverned</xsl:text>
                </xsl:when>
                <xsl:when test="$cwrc_authorrole_marcrelator_code = 'cov' or $cwrc_authorrole_marcrelator_text = 'Cover designer'">
                    <xsl:text>CoverDesigner</xsl:text>
                </xsl:when>
                <xsl:when test="$cwrc_authorrole_marcrelator_code = 'cpc' or $cwrc_authorrole_marcrelator_text = 'Copyright claimant'">
                    <xsl:text>CopyrightClaimant</xsl:text>
                </xsl:when>
                <xsl:when test="$cwrc_authorrole_marcrelator_code = 'cpe' or $cwrc_authorrole_marcrelator_text = 'Complainant-appellee'">
                    <xsl:text>ComplainantAppellee</xsl:text>
                </xsl:when>
                <xsl:when test="$cwrc_authorrole_marcrelator_code = 'cph' or $cwrc_authorrole_marcrelator_text = 'Copyright holder'">
                    <xsl:text>CopyrightHolder</xsl:text>
                </xsl:when>
                <xsl:when test="$cwrc_authorrole_marcrelator_code = 'cpl' or $cwrc_authorrole_marcrelator_text = 'Complainant'">
                    <xsl:text>Complainant</xsl:text>
                </xsl:when>
                <xsl:when test="$cwrc_authorrole_marcrelator_code = 'cpt' or $cwrc_authorrole_marcrelator_text = 'Complainant-appellant'">
                    <xsl:text>ComplainantAppellant</xsl:text>
                </xsl:when>
                <xsl:when test="$cwrc_authorrole_marcrelator_code = 'cre' or $cwrc_authorrole_marcrelator_text = 'Creator'">
                    <xsl:text>Creator</xsl:text>
                </xsl:when>
                <xsl:when test="$cwrc_authorrole_marcrelator_code = 'crp' or $cwrc_authorrole_marcrelator_text = 'Correspondent'">
                    <xsl:text>Correspondent</xsl:text>
                </xsl:when>
                <xsl:when test="$cwrc_authorrole_marcrelator_code = 'crr' or $cwrc_authorrole_marcrelator_text = 'Corrector'">
                    <xsl:text>Corrector</xsl:text>
                </xsl:when>
                <xsl:when test="$cwrc_authorrole_marcrelator_code = 'crt' or $cwrc_authorrole_marcrelator_text = 'Court reporter'">
                    <xsl:text>CourtReporter</xsl:text>
                </xsl:when>
                <xsl:when test="$cwrc_authorrole_marcrelator_code = 'csl' or $cwrc_authorrole_marcrelator_text = 'Consultant'">
                    <xsl:text>Consultant</xsl:text>
                </xsl:when>
                <xsl:when test="$cwrc_authorrole_marcrelator_code = 'csp' or $cwrc_authorrole_marcrelator_text = 'Consultant to a project'">
                    <xsl:text>ConsultantProject</xsl:text>
                </xsl:when>
                <xsl:when test="$cwrc_authorrole_marcrelator_code = 'cst' or $cwrc_authorrole_marcrelator_text = 'Costume designer'">
                    <xsl:text>CostumeDesigner</xsl:text>
                </xsl:when>
                <xsl:when test="$cwrc_authorrole_marcrelator_code = 'ctb' or $cwrc_authorrole_marcrelator_text = 'Contributor'">
                    <xsl:text>Contributor</xsl:text>
                </xsl:when>
                <xsl:when test="$cwrc_authorrole_marcrelator_code = 'cte' or $cwrc_authorrole_marcrelator_text = 'Contestee-appellee'">
                    <xsl:text>ContesteeAppellee</xsl:text>
                </xsl:when>
                <xsl:when test="$cwrc_authorrole_marcrelator_code = 'ctg' or $cwrc_authorrole_marcrelator_text = 'Cartographer'">
                    <xsl:text>Cartographer</xsl:text>
                </xsl:when>
                <xsl:when test="$cwrc_authorrole_marcrelator_code = 'ctr' or $cwrc_authorrole_marcrelator_text = 'Contractor'">
                    <xsl:text>Contractor</xsl:text>
                </xsl:when>
                <xsl:when test="$cwrc_authorrole_marcrelator_code = 'cts' or $cwrc_authorrole_marcrelator_text = 'Contestee'">
                    <xsl:text>Contestee</xsl:text>
                </xsl:when>
                <xsl:when test="$cwrc_authorrole_marcrelator_code = 'ctt' or $cwrc_authorrole_marcrelator_text = 'Contestee-appellant'">
                    <xsl:text>ContesteeAppellant</xsl:text>
                </xsl:when>
                <xsl:when test="$cwrc_authorrole_marcrelator_code = 'cur' or $cwrc_authorrole_marcrelator_text = 'Curator'">
                    <xsl:text>Curator</xsl:text>
                </xsl:when>
                <xsl:when test="$cwrc_authorrole_marcrelator_code = 'cwt' or $cwrc_authorrole_marcrelator_text = 'Commentator for written text'">
                    <xsl:text>CommentatorWrittenText</xsl:text>
                </xsl:when>
                <xsl:when test="$cwrc_authorrole_marcrelator_code = 'dbp' or $cwrc_authorrole_marcrelator_text = 'Distribution place'">
                    <xsl:text>DistributionPlace</xsl:text>
                </xsl:when>
                <xsl:when test="$cwrc_authorrole_marcrelator_code = 'dfd' or $cwrc_authorrole_marcrelator_text = 'Defendant'">
                    <xsl:text>Defendant</xsl:text>
                </xsl:when>
                <xsl:when test="$cwrc_authorrole_marcrelator_code = 'dfe' or $cwrc_authorrole_marcrelator_text = 'Defendant-appellee'">
                    <xsl:text>Defendant</xsl:text>
                </xsl:when>
                <xsl:when test="$cwrc_authorrole_marcrelator_code = 'dft' or $cwrc_authorrole_marcrelator_text = 'Defendant-appellant'">
                    <xsl:text>DefendantAppellee</xsl:text>
                </xsl:when>
                <xsl:when test="$cwrc_authorrole_marcrelator_code = 'dgg' or $cwrc_authorrole_marcrelator_text = 'Degree granting institution'">
                    <xsl:text>DefendantAppellant</xsl:text>
                </xsl:when>
                <xsl:when test="$cwrc_authorrole_marcrelator_code = 'dgs' or $cwrc_authorrole_marcrelator_text = 'Degree supervisor'">
                    <xsl:text>DegreeSupervisor</xsl:text>
                </xsl:when>
                <xsl:when test="$cwrc_authorrole_marcrelator_code = 'dis' or $cwrc_authorrole_marcrelator_text = 'Dissertant'">
                    <xsl:text>Dissertant</xsl:text>
                </xsl:when>
                <xsl:when test="$cwrc_authorrole_marcrelator_code = 'dln' or $cwrc_authorrole_marcrelator_text = 'Delineator'">
                    <xsl:text>Delineator</xsl:text>
                </xsl:when>
                <xsl:when test="$cwrc_authorrole_marcrelator_code = 'dnc' or $cwrc_authorrole_marcrelator_text = 'Dancer'">
                    <xsl:text>Dancer</xsl:text>
                </xsl:when>
                <xsl:when test="$cwrc_authorrole_marcrelator_code = 'dnr' or $cwrc_authorrole_marcrelator_text = 'Donor'">
                    <xsl:text>Donor</xsl:text>
                </xsl:when>
                <xsl:when test="$cwrc_authorrole_marcrelator_code = 'dpc' or $cwrc_authorrole_marcrelator_text = 'Depicted'">
                    <xsl:text>Depicted</xsl:text>
                </xsl:when>
                <xsl:when test="$cwrc_authorrole_marcrelator_code = 'dpt' or $cwrc_authorrole_marcrelator_text = 'Depositor'">
                    <xsl:text>Depositor</xsl:text>
                </xsl:when>
                <xsl:when test="$cwrc_authorrole_marcrelator_code = 'drm' or $cwrc_authorrole_marcrelator_text = 'Draftsman'">
                    <xsl:text>Draftsman</xsl:text>
                </xsl:when>
                <xsl:when test="$cwrc_authorrole_marcrelator_code = 'drt' or $cwrc_authorrole_marcrelator_text = 'Director'">
                    <xsl:text>Director</xsl:text>
                </xsl:when>
                <xsl:when test="$cwrc_authorrole_marcrelator_code = 'dsr' or $cwrc_authorrole_marcrelator_text = 'Designer'">
                    <xsl:text>Designer</xsl:text>
                </xsl:when>
                <xsl:when test="$cwrc_authorrole_marcrelator_code = 'dst' or $cwrc_authorrole_marcrelator_text = 'Distributor'">
                    <xsl:text>Deistributor</xsl:text>
                </xsl:when>
                <xsl:when test="$cwrc_authorrole_marcrelator_code = 'dtc' or $cwrc_authorrole_marcrelator_text = 'Data contributor'">
                    <xsl:text>DataContributor</xsl:text>
                </xsl:when>
                <xsl:when test="$cwrc_authorrole_marcrelator_code = 'dte' or $cwrc_authorrole_marcrelator_text = 'Dedicatee'">
                    <xsl:text>Dedicatee</xsl:text>
                </xsl:when>
                <xsl:when test="$cwrc_authorrole_marcrelator_code = 'dtm' or $cwrc_authorrole_marcrelator_text = 'Data manager'">
                    <xsl:text>DataManager</xsl:text>
                </xsl:when>
                <xsl:when test="$cwrc_authorrole_marcrelator_code = 'dto' or $cwrc_authorrole_marcrelator_text = 'Dedicator'">
                    <xsl:text>Dedicator</xsl:text>
                </xsl:when>
                <xsl:when test="$cwrc_authorrole_marcrelator_code = 'dub' or $cwrc_authorrole_marcrelator_text = 'Dubious author'">
                    <xsl:text>DubiousAuthor</xsl:text>
                </xsl:when>
                <xsl:when test="$cwrc_authorrole_marcrelator_code = 'edc' or $cwrc_authorrole_marcrelator_text = 'Editor of compilation'">
                    <xsl:text>EditorCompilation</xsl:text>
                </xsl:when>
                <xsl:when test="$cwrc_authorrole_marcrelator_code = 'edm' or $cwrc_authorrole_marcrelator_text = 'Editor of moving image work'">
                    <xsl:text>EditorMovingImageWork</xsl:text>
                </xsl:when>
                <xsl:when test="$cwrc_authorrole_marcrelator_code = 'edt' or $cwrc_authorrole_marcrelator_text = 'Editor'">
                    <xsl:text>Editor</xsl:text>
                </xsl:when>
                <xsl:when test="$cwrc_authorrole_marcrelator_code = 'egr' or $cwrc_authorrole_marcrelator_text = 'Engraver'">
                    <xsl:text>Engraver</xsl:text>
                </xsl:when>
                <xsl:when test="$cwrc_authorrole_marcrelator_code = 'elg' or $cwrc_authorrole_marcrelator_text = 'Electrician'">
                    <xsl:text>Electrician</xsl:text>
                </xsl:when>
                <xsl:when test="$cwrc_authorrole_marcrelator_code = 'elt' or $cwrc_authorrole_marcrelator_text = 'Electrotyper'">
                    <xsl:text>Electrotyper</xsl:text>
                </xsl:when>
                <xsl:when test="$cwrc_authorrole_marcrelator_code = 'eng' or $cwrc_authorrole_marcrelator_text = 'Engineer'">
                    <xsl:text>Engineer</xsl:text>
                </xsl:when>
                <xsl:when test="$cwrc_authorrole_marcrelator_code = 'enj' or $cwrc_authorrole_marcrelator_text = 'Enacting jurisdiction'">
                    <xsl:text>EnactingJurisdiction</xsl:text>
                </xsl:when>
                <xsl:when test="$cwrc_authorrole_marcrelator_code = 'etr' or $cwrc_authorrole_marcrelator_text = 'Etcher'">
                    <xsl:text>Etcher</xsl:text>
                </xsl:when>
                <xsl:when test="$cwrc_authorrole_marcrelator_code = 'evp' or $cwrc_authorrole_marcrelator_text = 'Event place'">
                    <xsl:text>EventPlace</xsl:text>
                </xsl:when>
                <xsl:when test="$cwrc_authorrole_marcrelator_code = 'exp' or $cwrc_authorrole_marcrelator_text = 'Expert'">
                    <xsl:text>Expert</xsl:text>
                </xsl:when>
                <xsl:when test="$cwrc_authorrole_marcrelator_code = 'fac' or $cwrc_authorrole_marcrelator_text = 'Facsimilist'">
                    <xsl:text>Facsimilist</xsl:text>
                </xsl:when>
                <xsl:when test="$cwrc_authorrole_marcrelator_code = 'fds' or $cwrc_authorrole_marcrelator_text = 'Film distributor'">
                    <xsl:text>FilmDistributor</xsl:text>
                </xsl:when>
                <xsl:when test="$cwrc_authorrole_marcrelator_code = 'fld' or $cwrc_authorrole_marcrelator_text = 'Field director'">
                    <xsl:text>FieldDirector</xsl:text>
                </xsl:when>
                <xsl:when test="$cwrc_authorrole_marcrelator_code = 'flm' or $cwrc_authorrole_marcrelator_text = 'Film editor'">
                    <xsl:text>FilmEditor</xsl:text>
                </xsl:when>
                <xsl:when test="$cwrc_authorrole_marcrelator_code = 'fmd' or $cwrc_authorrole_marcrelator_text = 'Film director'">
                    <xsl:text>FilmDirector</xsl:text>
                </xsl:when>
                <xsl:when test="$cwrc_authorrole_marcrelator_code = 'fmk' or $cwrc_authorrole_marcrelator_text = 'Filmmaker'">
                    <xsl:text>Filmmaker</xsl:text>
                </xsl:when>
                <xsl:when test="$cwrc_authorrole_marcrelator_code = 'fmo' or $cwrc_authorrole_marcrelator_text = 'Former owner'">
                    <xsl:text>FormerOwner</xsl:text>
                </xsl:when>
                <xsl:when test="$cwrc_authorrole_marcrelator_code = 'fmp' or $cwrc_authorrole_marcrelator_text = 'Film producer'">
                    <xsl:text>FilmProducer</xsl:text>
                </xsl:when>
                <xsl:when test="$cwrc_authorrole_marcrelator_code = 'fnd' or $cwrc_authorrole_marcrelator_text = 'Funder'">
                    <xsl:text>Funder</xsl:text>
                </xsl:when>
                <xsl:when test="$cwrc_authorrole_marcrelator_code = 'fpy' or $cwrc_authorrole_marcrelator_text = 'First party'">
                    <xsl:text>FirstParty</xsl:text>
                </xsl:when>
                <xsl:when test="$cwrc_authorrole_marcrelator_code = 'frg' or $cwrc_authorrole_marcrelator_text = 'Forger'">
                    <xsl:text>Forger</xsl:text>
                </xsl:when>
                <xsl:when test="$cwrc_authorrole_marcrelator_code = 'gis' or $cwrc_authorrole_marcrelator_text = 'Geographic information specialist'">
                    <xsl:text>GeographicInformationSpecialist</xsl:text>
                </xsl:when>
                <xsl:when test="$cwrc_authorrole_marcrelator_code = '-grt' or $cwrc_authorrole_marcrelator_text = 'Graphic technician'">
                    <xsl:text>GraphicTechnician</xsl:text>
                </xsl:when>
                <xsl:when test="$cwrc_authorrole_marcrelator_code = 'his' or $cwrc_authorrole_marcrelator_text = 'Host institution'">
                    <xsl:text>HostInstitution</xsl:text>
                </xsl:when>
                <xsl:when test="$cwrc_authorrole_marcrelator_code = 'hnr' or $cwrc_authorrole_marcrelator_text = 'Honoree'">
                    <xsl:text>Honoree</xsl:text>
                </xsl:when>
                <xsl:when test="$cwrc_authorrole_marcrelator_code = 'hst' or $cwrc_authorrole_marcrelator_text = 'Host'">
                    <xsl:text>Host</xsl:text>
                </xsl:when>
                <xsl:when test="$cwrc_authorrole_marcrelator_code = 'ill' or $cwrc_authorrole_marcrelator_text = 'Illustrator'">
                    <xsl:text>Illustrator</xsl:text>
                </xsl:when>
                <xsl:when test="$cwrc_authorrole_marcrelator_code = 'ilu' or $cwrc_authorrole_marcrelator_text = 'Illuminator'">
                    <xsl:text>Illuminator</xsl:text>
                </xsl:when>
                <xsl:when test="$cwrc_authorrole_marcrelator_code = 'ins' or $cwrc_authorrole_marcrelator_text = 'Inscriber'">
                    <xsl:text>Inscriber</xsl:text>
                </xsl:when>
                <xsl:when test="$cwrc_authorrole_marcrelator_code = 'inv' or $cwrc_authorrole_marcrelator_text = 'Inventor'">
                    <xsl:text>Inventor</xsl:text>
                </xsl:when>
                <xsl:when test="$cwrc_authorrole_marcrelator_code = 'isb' or $cwrc_authorrole_marcrelator_text = 'Issuing body'">
                    <xsl:text>IssuingBody</xsl:text>
                </xsl:when>
                <xsl:when test="$cwrc_authorrole_marcrelator_code = 'itr' or $cwrc_authorrole_marcrelator_text = 'Instrumentalist'">
                    <xsl:text>Instrumentalist</xsl:text>
                </xsl:when>
                <xsl:when test="$cwrc_authorrole_marcrelator_code = 'ive' or $cwrc_authorrole_marcrelator_text = 'Interviewee'">
                    <xsl:text>Interviewee</xsl:text>
                </xsl:when>
                <xsl:when test="$cwrc_authorrole_marcrelator_code = 'ivr' or $cwrc_authorrole_marcrelator_text = 'Interviewer'">
                    <xsl:text>Interviewer</xsl:text>
                </xsl:when>
                <xsl:when test="$cwrc_authorrole_marcrelator_code = 'jud' or $cwrc_authorrole_marcrelator_text = 'Judge'">
                    <xsl:text>Judge</xsl:text>
                </xsl:when>
                <xsl:when test="$cwrc_authorrole_marcrelator_code = 'jug' or $cwrc_authorrole_marcrelator_text = 'Jurisdiction governed'">
                    <xsl:text>JusrisdictionGoverned</xsl:text>
                </xsl:when>
                <xsl:when test="$cwrc_authorrole_marcrelator_code = 'lbr' or $cwrc_authorrole_marcrelator_text = 'Laboratory'">
                    <xsl:text>Laboratory</xsl:text>
                </xsl:when>
                <xsl:when test="$cwrc_authorrole_marcrelator_code = 'lbt' or $cwrc_authorrole_marcrelator_text = 'Librettist'">
                    <xsl:text>Librettist</xsl:text>
                </xsl:when>
                <xsl:when test="$cwrc_authorrole_marcrelator_code = 'ldr' or $cwrc_authorrole_marcrelator_text = 'Laboratory director'">
                    <xsl:text>LaboratoryDirector</xsl:text>
                </xsl:when>
                <xsl:when test="$cwrc_authorrole_marcrelator_code = 'led' or $cwrc_authorrole_marcrelator_text = 'Lead'">
                    <xsl:text>Lead</xsl:text>
                </xsl:when>
                <xsl:when test="$cwrc_authorrole_marcrelator_code = 'lee' or $cwrc_authorrole_marcrelator_text = 'Libelee-appellee'">
                    <xsl:text>LibeleeAppellee</xsl:text>
                </xsl:when>
                <xsl:when test="$cwrc_authorrole_marcrelator_code = 'lel' or $cwrc_authorrole_marcrelator_text = 'Libelee'">
                    <xsl:text>Libelee</xsl:text>
                </xsl:when>
                <xsl:when test="$cwrc_authorrole_marcrelator_code = 'len' or $cwrc_authorrole_marcrelator_text = 'Lender'">
                    <xsl:text>Lender</xsl:text>
                </xsl:when>
                <xsl:when test="$cwrc_authorrole_marcrelator_code = 'let' or $cwrc_authorrole_marcrelator_text = 'Libelee-appellant'">
                    <xsl:text>LibeleeAppellant</xsl:text>
                </xsl:when>
                <xsl:when test="$cwrc_authorrole_marcrelator_code = 'lgd' or $cwrc_authorrole_marcrelator_text = 'Lighting designer'">
                    <xsl:text>LightingDesigner</xsl:text>
                </xsl:when>
                <xsl:when test="$cwrc_authorrole_marcrelator_code = 'lie' or $cwrc_authorrole_marcrelator_text = 'Libelant-appellee'">
                    <xsl:text>LibelantAppellee</xsl:text>
                </xsl:when>
                <xsl:when test="$cwrc_authorrole_marcrelator_code = 'lil' or $cwrc_authorrole_marcrelator_text = 'Libelant'">
                    <xsl:text>Libelant</xsl:text>
                </xsl:when>
                <xsl:when test="$cwrc_authorrole_marcrelator_code = 'lit' or $cwrc_authorrole_marcrelator_text = 'Libelant-appellant'">
                    <xsl:text>LebelantAppellant</xsl:text>
                </xsl:when>
                <xsl:when test="$cwrc_authorrole_marcrelator_code = 'lsa' or $cwrc_authorrole_marcrelator_text = 'Landscape architect'">
                    <xsl:text>LandscapeArchitect</xsl:text>
                </xsl:when>
                <xsl:when test="$cwrc_authorrole_marcrelator_code = 'lse' or $cwrc_authorrole_marcrelator_text = 'Licensee'">
                    <xsl:text>Licensee</xsl:text>
                </xsl:when>
                <xsl:when test="$cwrc_authorrole_marcrelator_code = 'lso' or $cwrc_authorrole_marcrelator_text = 'Licensor'">
                    <xsl:text>Licensor</xsl:text>
                </xsl:when>
                <xsl:when test="$cwrc_authorrole_marcrelator_code = 'ltg' or $cwrc_authorrole_marcrelator_text = 'Lithographer'">
                    <xsl:text>Lithographer</xsl:text>
                </xsl:when>
                <xsl:when test="$cwrc_authorrole_marcrelator_code = 'lyr' or $cwrc_authorrole_marcrelator_text = 'Lyricist'">
                    <xsl:text>Lyricist</xsl:text>
                </xsl:when>
                <xsl:when test="$cwrc_authorrole_marcrelator_code = 'mcp' or $cwrc_authorrole_marcrelator_text = 'Music copyist'">
                    <xsl:text>MusicCopyist</xsl:text>
                </xsl:when>
                <xsl:when test="$cwrc_authorrole_marcrelator_code = 'mdc' or $cwrc_authorrole_marcrelator_text = 'Metadata contact'">
                    <xsl:text>MetadataContact</xsl:text>
                </xsl:when>
                <xsl:when test="$cwrc_authorrole_marcrelator_code = 'med' or $cwrc_authorrole_marcrelator_text = 'Medium'">
                    <xsl:text>Medium</xsl:text>
                </xsl:when>
                <xsl:when test="$cwrc_authorrole_marcrelator_code = 'mfp' or $cwrc_authorrole_marcrelator_text = 'Manufacture place'">
                    <xsl:text>ManufacturePlace</xsl:text>
                </xsl:when>
                <xsl:when test="$cwrc_authorrole_marcrelator_code = 'mfr' or $cwrc_authorrole_marcrelator_text = 'Manufacturer'">
                    <xsl:text>manufacturer</xsl:text>
                </xsl:when>
                <xsl:when test="$cwrc_authorrole_marcrelator_code = 'mod' or $cwrc_authorrole_marcrelator_text = 'Moderator'">
                    <xsl:text>Moderator</xsl:text>
                </xsl:when>
                <xsl:when test="$cwrc_authorrole_marcrelator_code = 'mon' or $cwrc_authorrole_marcrelator_text = 'Monitor'">
                    <xsl:text>Monitor</xsl:text>
                </xsl:when>
                <xsl:when test="$cwrc_authorrole_marcrelator_code = 'mrb' or $cwrc_authorrole_marcrelator_text = 'Marbler'">
                    <xsl:text>Marbler</xsl:text>
                </xsl:when>
                <xsl:when test="$cwrc_authorrole_marcrelator_code = 'mrk' or $cwrc_authorrole_marcrelator_text = 'Markup editor'">
                    <xsl:text>MarkupEditor</xsl:text>
                </xsl:when>
                <xsl:when test="$cwrc_authorrole_marcrelator_code = 'msd' or $cwrc_authorrole_marcrelator_text = 'Musical director'">
                    <xsl:text>MisucalDirector</xsl:text>
                </xsl:when>
                <xsl:when test="$cwrc_authorrole_marcrelator_code = 'mte' or $cwrc_authorrole_marcrelator_text = 'Metal-engraver'">
                    <xsl:text>MetalEngraver</xsl:text>
                </xsl:when>
                <xsl:when test="$cwrc_authorrole_marcrelator_code = 'mtk' or $cwrc_authorrole_marcrelator_text = 'Minute taker'">
                    <xsl:text>MinuteTaker</xsl:text>
                </xsl:when>
                <xsl:when test="$cwrc_authorrole_marcrelator_code = 'mus' or $cwrc_authorrole_marcrelator_text = 'Musician'">
                    <xsl:text>Musician</xsl:text>
                </xsl:when>
                <xsl:when test="$cwrc_authorrole_marcrelator_code = 'nrt' or $cwrc_authorrole_marcrelator_text = 'Narrator'">
                    <xsl:text>Narrator</xsl:text>
                </xsl:when>
                <xsl:when test="$cwrc_authorrole_marcrelator_code = 'opn' or $cwrc_authorrole_marcrelator_text = 'Opponent'">
                    <xsl:text>Opponent</xsl:text>
                </xsl:when>
                <xsl:when test="$cwrc_authorrole_marcrelator_code = 'org' or $cwrc_authorrole_marcrelator_text = 'Originator'">
                    <xsl:text>Originator</xsl:text>
                </xsl:when>
                <xsl:when test="$cwrc_authorrole_marcrelator_code = 'orm' or $cwrc_authorrole_marcrelator_text = 'Organizer'">
                    <xsl:text>Organizer</xsl:text>
                </xsl:when>
                <xsl:when test="$cwrc_authorrole_marcrelator_code = 'osp' or $cwrc_authorrole_marcrelator_text = 'Onscreen presenter'">
                    <xsl:text>OnscreenPresenter</xsl:text>
                </xsl:when>
                <xsl:when test="$cwrc_authorrole_marcrelator_code = 'oth' or $cwrc_authorrole_marcrelator_text = 'Other'">
                    <xsl:text>Other</xsl:text>
                </xsl:when>
                <xsl:when test="$cwrc_authorrole_marcrelator_code = 'own' or $cwrc_authorrole_marcrelator_text = 'Owner'">
                    <xsl:text>Owner</xsl:text>
                </xsl:when>
                <xsl:when test="$cwrc_authorrole_marcrelator_code = 'pan' or $cwrc_authorrole_marcrelator_text = 'Panelist'">
                    <xsl:text>Panelist</xsl:text>
                </xsl:when>
                <xsl:when test="$cwrc_authorrole_marcrelator_code = 'pat' or $cwrc_authorrole_marcrelator_text = 'Patron'">
                    <xsl:text>Patron</xsl:text>
                </xsl:when>
                <xsl:when test="$cwrc_authorrole_marcrelator_code = 'pbd' or $cwrc_authorrole_marcrelator_text = 'Publishing director'">
                    <xsl:text>PublishingDirector</xsl:text>
                </xsl:when>
                <xsl:when test="$cwrc_authorrole_marcrelator_code = 'pbl' or $cwrc_authorrole_marcrelator_text = 'Publisher'">
                    <xsl:text>Publisher</xsl:text>
                </xsl:when>
                <xsl:when test="$cwrc_authorrole_marcrelator_code = 'pdr' or $cwrc_authorrole_marcrelator_text = 'Project director'">
                    <xsl:text>ProjectDirector</xsl:text>
                </xsl:when>
                <xsl:when test="$cwrc_authorrole_marcrelator_code = 'pfr' or $cwrc_authorrole_marcrelator_text = 'Proofreader'">
                    <xsl:text>Proofreader</xsl:text>
                </xsl:when>
                <xsl:when test="$cwrc_authorrole_marcrelator_code = 'pht' or $cwrc_authorrole_marcrelator_text = 'Photographer'">
                    <xsl:text>Photographer</xsl:text>
                </xsl:when>
                <xsl:when test="$cwrc_authorrole_marcrelator_code = 'plt' or $cwrc_authorrole_marcrelator_text = 'Platemaker'">
                    <xsl:text>Platemaker</xsl:text>
                </xsl:when>
                <xsl:when test="$cwrc_authorrole_marcrelator_code = 'pma' or $cwrc_authorrole_marcrelator_text = 'Permitting agency'">
                    <xsl:text>PermittingAgency</xsl:text>
                </xsl:when>
                <xsl:when test="$cwrc_authorrole_marcrelator_code = 'pmn' or $cwrc_authorrole_marcrelator_text = 'Production manager'">
                    <xsl:text>ProductionManager</xsl:text>
                </xsl:when>
                <xsl:when test="$cwrc_authorrole_marcrelator_code = 'pop' or $cwrc_authorrole_marcrelator_text = 'Printer of plates'">
                    <xsl:text>PinterPlates</xsl:text>
                </xsl:when>
                <xsl:when test="$cwrc_authorrole_marcrelator_code = 'ppm' or $cwrc_authorrole_marcrelator_text = 'Papermaker'">
                    <xsl:text>Papermaker</xsl:text>
                </xsl:when>
                <xsl:when test="$cwrc_authorrole_marcrelator_code = 'ppt' or $cwrc_authorrole_marcrelator_text = 'Puppeteer'">
                    <xsl:text>Puppeteer</xsl:text>
                </xsl:when>
                <xsl:when test="$cwrc_authorrole_marcrelator_code = 'pra' or $cwrc_authorrole_marcrelator_text = 'Praeses'">
                    <xsl:text>Praeses</xsl:text>
                </xsl:when>
                <xsl:when test="$cwrc_authorrole_marcrelator_code = 'prc' or $cwrc_authorrole_marcrelator_text = 'Process contact'">
                    <xsl:text>ProcessContact</xsl:text>
                </xsl:when>
                <xsl:when test="$cwrc_authorrole_marcrelator_code = 'prd' or $cwrc_authorrole_marcrelator_text = 'Production personnel'">
                    <xsl:text>ProductionPersonnel</xsl:text>
                </xsl:when>
                <xsl:when test="$cwrc_authorrole_marcrelator_code = 'pre' or $cwrc_authorrole_marcrelator_text = 'Presenter'">
                    <xsl:text>Presenter</xsl:text>
                </xsl:when>
                <xsl:when test="$cwrc_authorrole_marcrelator_code = 'prf' or $cwrc_authorrole_marcrelator_text = 'Performer'">
                    <xsl:text>Performer</xsl:text>
                </xsl:when>
                <xsl:when test="$cwrc_authorrole_marcrelator_code = 'prg' or $cwrc_authorrole_marcrelator_text = 'Programmer'">
                    <xsl:text>Programmer</xsl:text>
                </xsl:when>
                <xsl:when test="$cwrc_authorrole_marcrelator_code = 'prm' or $cwrc_authorrole_marcrelator_text = 'Printmaker'">
                    <xsl:text>Printmaker</xsl:text>
                </xsl:when>
                <xsl:when test="$cwrc_authorrole_marcrelator_code = 'prn' or $cwrc_authorrole_marcrelator_text = 'Production company'">
                    <xsl:text>ProductionCompany</xsl:text>
                </xsl:when>
                <xsl:when test="$cwrc_authorrole_marcrelator_code = 'pro' or $cwrc_authorrole_marcrelator_text = 'Producer'">
                    <xsl:text>Producer</xsl:text>
                </xsl:when>
                <xsl:when test="$cwrc_authorrole_marcrelator_code = 'prp' or $cwrc_authorrole_marcrelator_text = 'Production place'">
                    <xsl:text>ProductionPlace</xsl:text>
                </xsl:when>
                <xsl:when test="$cwrc_authorrole_marcrelator_code = 'prs' or $cwrc_authorrole_marcrelator_text = 'Production designer'">
                    <xsl:text>ProductionDesigner</xsl:text>
                </xsl:when>
                <xsl:when test="$cwrc_authorrole_marcrelator_code = 'prt' or $cwrc_authorrole_marcrelator_text = 'Printer'">
                    <xsl:text>Printer</xsl:text>
                </xsl:when>
                <xsl:when test="$cwrc_authorrole_marcrelator_code = 'prv' or $cwrc_authorrole_marcrelator_text = 'Provider'">
                    <xsl:text>Provider</xsl:text>
                </xsl:when>
                <xsl:when test="$cwrc_authorrole_marcrelator_code = 'pta' or $cwrc_authorrole_marcrelator_text = 'Patent applicant'">
                    <xsl:text>PatentApplicant</xsl:text>
                </xsl:when>
                <xsl:when test="$cwrc_authorrole_marcrelator_code = 'pte' or $cwrc_authorrole_marcrelator_text = 'Plaintiff-appellee'">
                    <xsl:text>PlaintiffAppellee</xsl:text>
                </xsl:when>
                <xsl:when test="$cwrc_authorrole_marcrelator_code = 'ptf' or $cwrc_authorrole_marcrelator_text = 'Plaintiff'">
                    <xsl:text>Plaintiff</xsl:text>
                </xsl:when>
                <xsl:when test="$cwrc_authorrole_marcrelator_code = 'pth' or $cwrc_authorrole_marcrelator_text = 'Patent holder'">
                    <xsl:text>PatentHolder</xsl:text>
                </xsl:when>
                <xsl:when test="$cwrc_authorrole_marcrelator_code = 'ptt' or $cwrc_authorrole_marcrelator_text = 'Plaintiff-appellant'">
                    <xsl:text>PlaintiffAppellant</xsl:text>
                </xsl:when>
                <xsl:when test="$cwrc_authorrole_marcrelator_code = 'pup' or $cwrc_authorrole_marcrelator_text = 'Publication place'">
                    <xsl:text>PublicationPlace</xsl:text>
                </xsl:when>
                <xsl:when test="$cwrc_authorrole_marcrelator_code = 'rbr' or $cwrc_authorrole_marcrelator_text = 'Rubricator'">
                    <xsl:text>Rubricator</xsl:text>
                </xsl:when>
                <xsl:when test="$cwrc_authorrole_marcrelator_code = 'rcd' or $cwrc_authorrole_marcrelator_text = 'Recordist'">
                    <xsl:text>Recordist</xsl:text>
                </xsl:when>
                <xsl:when test="$cwrc_authorrole_marcrelator_code = 'rce' or $cwrc_authorrole_marcrelator_text = 'Recording engineer'">
                    <xsl:text>RecordingEngineer</xsl:text>
                </xsl:when>
                <xsl:when test="$cwrc_authorrole_marcrelator_code = 'rcp' or $cwrc_authorrole_marcrelator_text = 'Addressee'">
                    <xsl:text>Addressee</xsl:text>
                </xsl:when>
                <xsl:when test="$cwrc_authorrole_marcrelator_code = 'rdd' or $cwrc_authorrole_marcrelator_text = 'Radio director'">
                    <xsl:text>RadioDirector</xsl:text>
                </xsl:when>
                <xsl:when test="$cwrc_authorrole_marcrelator_code = 'red' or $cwrc_authorrole_marcrelator_text = 'Redaktor'">
                    <xsl:text>Redaktor</xsl:text>
                </xsl:when>
                <xsl:when test="$cwrc_authorrole_marcrelator_code = 'ren' or $cwrc_authorrole_marcrelator_text = 'Renderer'">
                    <xsl:text>Renderer</xsl:text>
                </xsl:when>
                <xsl:when test="$cwrc_authorrole_marcrelator_code = 'res' or $cwrc_authorrole_marcrelator_text = 'Researcher'">
                    <xsl:text>Researcher</xsl:text>
                </xsl:when>
                <xsl:when test="$cwrc_authorrole_marcrelator_code = 'rev' or $cwrc_authorrole_marcrelator_text = 'Reviewer'">
                    <xsl:text>Reviewer</xsl:text>
                </xsl:when>
                <xsl:when test="$cwrc_authorrole_marcrelator_code = 'rpc' or $cwrc_authorrole_marcrelator_text = 'Radio producer'">
                    <xsl:text>RadioProducer</xsl:text>
                </xsl:when>
                <xsl:when test="$cwrc_authorrole_marcrelator_code = 'rps' or $cwrc_authorrole_marcrelator_text = 'Repository'">
                    <xsl:text>Repository</xsl:text>
                </xsl:when>
                <xsl:when test="$cwrc_authorrole_marcrelator_code = 'rpt' or $cwrc_authorrole_marcrelator_text = 'Reporter'">
                    <xsl:text>Reporter</xsl:text>
                </xsl:when>
                <xsl:when test="$cwrc_authorrole_marcrelator_code = 'rpy' or $cwrc_authorrole_marcrelator_text = 'Responsible party'">
                    <xsl:text>ResponsibleParty</xsl:text>
                </xsl:when>
                <xsl:when test="$cwrc_authorrole_marcrelator_code = 'rse' or $cwrc_authorrole_marcrelator_text = 'Respondent-appellee'">
                    <xsl:text>RespondentAppellee</xsl:text>
                </xsl:when>
                <xsl:when test="$cwrc_authorrole_marcrelator_code = 'rsg' or $cwrc_authorrole_marcrelator_text = 'Restager'">
                    <xsl:text>Restager</xsl:text>
                </xsl:when>
                <xsl:when test="$cwrc_authorrole_marcrelator_code = 'rsp' or $cwrc_authorrole_marcrelator_text = 'Respondent'">
                    <xsl:text>Respondent</xsl:text>
                </xsl:when>
                <xsl:when test="$cwrc_authorrole_marcrelator_code = 'rsr' or $cwrc_authorrole_marcrelator_text = 'Restorationist'">
                    <xsl:text>Restorationist</xsl:text>
                </xsl:when>
                <xsl:when test="$cwrc_authorrole_marcrelator_code = 'rst' or $cwrc_authorrole_marcrelator_text = 'Respondent-appellant'">
                    <xsl:text>RespondentAppellant</xsl:text>
                </xsl:when>
                <xsl:when test="$cwrc_authorrole_marcrelator_code = 'rth' or $cwrc_authorrole_marcrelator_text = 'Research team head'">
                    <xsl:text>ResearchTeamHead</xsl:text>
                </xsl:when>
                <xsl:when test="$cwrc_authorrole_marcrelator_code = 'rtm' or $cwrc_authorrole_marcrelator_text = 'Research team member'">
                    <xsl:text>ResearchTeamMember</xsl:text>
                </xsl:when>
                <xsl:when test="$cwrc_authorrole_marcrelator_code = 'sad' or $cwrc_authorrole_marcrelator_text = 'Scientific advisor'">
                    <xsl:text>ScientificAdvisor</xsl:text>
                </xsl:when>
                <xsl:when test="$cwrc_authorrole_marcrelator_code = 'sce' or $cwrc_authorrole_marcrelator_text = 'Scenarist'">
                    <xsl:text>Scenarist</xsl:text>
                </xsl:when>
                <xsl:when test="$cwrc_authorrole_marcrelator_code = 'scl' or $cwrc_authorrole_marcrelator_text = 'Sculptor'">
                    <xsl:text>Sculptor</xsl:text>
                </xsl:when>
                <xsl:when test="$cwrc_authorrole_marcrelator_code = 'scr' or $cwrc_authorrole_marcrelator_text = 'Scribe'">
                    <xsl:text>Scribe</xsl:text>
                </xsl:when>
                <xsl:when test="$cwrc_authorrole_marcrelator_code = 'sds' or $cwrc_authorrole_marcrelator_text = 'Sound designer'">
                    <xsl:text>SoundDesigner</xsl:text>
                </xsl:when>
                <xsl:when test="$cwrc_authorrole_marcrelator_code = 'sec' or $cwrc_authorrole_marcrelator_text = 'Secretary'">
                    <xsl:text>Secretary</xsl:text>
                </xsl:when>
                <xsl:when test="$cwrc_authorrole_marcrelator_code = 'sgd' or $cwrc_authorrole_marcrelator_text = 'Stage director'">
                    <xsl:text>StageDirector</xsl:text>
                </xsl:when>
                <xsl:when test="$cwrc_authorrole_marcrelator_code = 'sgn' or $cwrc_authorrole_marcrelator_text = 'Signer'">
                    <xsl:text>Signer</xsl:text>
                </xsl:when>
                <xsl:when test="$cwrc_authorrole_marcrelator_code = 'sht' or $cwrc_authorrole_marcrelator_text = 'Supporting host'">
                    <xsl:text>SupportingHost</xsl:text>
                </xsl:when>
                <xsl:when test="$cwrc_authorrole_marcrelator_code = 'sll' or $cwrc_authorrole_marcrelator_text = 'Seller'">
                    <xsl:text>Seller</xsl:text>
                </xsl:when>
                <xsl:when test="$cwrc_authorrole_marcrelator_code = 'sng' or $cwrc_authorrole_marcrelator_text = 'Singer'">
                    <xsl:text>Singer</xsl:text>
                </xsl:when>
                <xsl:when test="$cwrc_authorrole_marcrelator_code = 'spk' or $cwrc_authorrole_marcrelator_text = 'Speaker'">
                    <xsl:text>Speaker</xsl:text>
                </xsl:when>
                <xsl:when test="$cwrc_authorrole_marcrelator_code = 'spn' or $cwrc_authorrole_marcrelator_text = 'Sponsor'">
                    <xsl:text>Sponsor</xsl:text>
                </xsl:when>
                <xsl:when test="$cwrc_authorrole_marcrelator_code = 'spy' or $cwrc_authorrole_marcrelator_text = 'Second party'">
                    <xsl:text>SecondParty</xsl:text>
                </xsl:when>
                <xsl:when test="$cwrc_authorrole_marcrelator_code = 'srv' or $cwrc_authorrole_marcrelator_text = 'Surveyor'">
                    <xsl:text>Surveyor</xsl:text>
                </xsl:when>
                <xsl:when test="$cwrc_authorrole_marcrelator_code = 'std' or $cwrc_authorrole_marcrelator_text = 'Set designer'">
                    <xsl:text>SetDesigner</xsl:text>
                </xsl:when>
                <xsl:when test="$cwrc_authorrole_marcrelator_code = 'stg' or $cwrc_authorrole_marcrelator_text = 'Setting'">
                    <xsl:text>Setting</xsl:text>
                </xsl:when>
                <xsl:when test="$cwrc_authorrole_marcrelator_code = 'stl' or $cwrc_authorrole_marcrelator_text = 'Storyteller'">
                    <xsl:text>StoryTeller</xsl:text>
                </xsl:when>
                <xsl:when test="$cwrc_authorrole_marcrelator_code = 'stm' or $cwrc_authorrole_marcrelator_text = 'Stage manager'">
                    <xsl:text>StageManager</xsl:text>
                </xsl:when>
                <xsl:when test="$cwrc_authorrole_marcrelator_code = 'stn' or $cwrc_authorrole_marcrelator_text = 'Standards body'">
                    <xsl:text>StandardsBody</xsl:text>
                </xsl:when>
                <xsl:when test="$cwrc_authorrole_marcrelator_code = 'str' or $cwrc_authorrole_marcrelator_text = 'Stereotyper'">
                    <xsl:text>Stereotyper</xsl:text>
                </xsl:when>
                <xsl:when test="$cwrc_authorrole_marcrelator_code = 'tcd' or $cwrc_authorrole_marcrelator_text = 'Technical director'">
                    <xsl:text>TechnicalDirector</xsl:text>
                </xsl:when>
                <xsl:when test="$cwrc_authorrole_marcrelator_code = 'tch' or $cwrc_authorrole_marcrelator_text = 'Teacher'">
                    <xsl:text>Teacher</xsl:text>
                </xsl:when>
                <xsl:when test="$cwrc_authorrole_marcrelator_code = 'ths' or $cwrc_authorrole_marcrelator_text = 'Thesis advisor'">
                    <xsl:text>ThesisAdvisor</xsl:text>
                </xsl:when>
                <xsl:when test="$cwrc_authorrole_marcrelator_code = 'tld' or $cwrc_authorrole_marcrelator_text = 'Television director'">
                    <xsl:text>TelevisionDirector</xsl:text>
                </xsl:when>
                <xsl:when test="$cwrc_authorrole_marcrelator_code = 'tlp' or $cwrc_authorrole_marcrelator_text = 'Television producer'">
                    <xsl:text>TelevisionProducer</xsl:text>
                </xsl:when>
                <xsl:when test="$cwrc_authorrole_marcrelator_code = 'trc' or $cwrc_authorrole_marcrelator_text = 'Transcriber'">
                    <xsl:text>Transcriber</xsl:text>
                </xsl:when>
                <xsl:when test="$cwrc_authorrole_marcrelator_code = 'trl' or $cwrc_authorrole_marcrelator_text = 'Translator'">
                    <xsl:text>Translator</xsl:text>
                </xsl:when>
                <xsl:when test="$cwrc_authorrole_marcrelator_code = 'tyd' or $cwrc_authorrole_marcrelator_text = 'Type designer'">
                    <xsl:text>TypeDesigner</xsl:text>
                </xsl:when>
                <xsl:when test="$cwrc_authorrole_marcrelator_code = 'tyg' or $cwrc_authorrole_marcrelator_text = 'Typographer'">
                    <xsl:text>Typographer</xsl:text>
                </xsl:when>
                <xsl:when test="$cwrc_authorrole_marcrelator_code = 'uvp' or $cwrc_authorrole_marcrelator_text = 'University place'">
                    <xsl:text>UniversityPlace</xsl:text>
                </xsl:when>
                <xsl:when test="$cwrc_authorrole_marcrelator_code = 'vac' or $cwrc_authorrole_marcrelator_text = 'Voice actor'">
                    <xsl:text>VoiceActor</xsl:text>
                </xsl:when>
                <xsl:when test="$cwrc_authorrole_marcrelator_code = 'vdg' or $cwrc_authorrole_marcrelator_text = 'Videographer'">
                    <xsl:text>Videographer</xsl:text>
                </xsl:when>
                <xsl:when test="$cwrc_authorrole_marcrelator_code = '-voc' or $cwrc_authorrole_marcrelator_text = 'Vocalist'">
                    <xsl:text>Vocalist</xsl:text>
                </xsl:when>
                <xsl:when test="$cwrc_authorrole_marcrelator_code = 'wac' or $cwrc_authorrole_marcrelator_text = 'Writer of added commentary'">
                    <xsl:text>WriterAddedCommentary</xsl:text>
                </xsl:when>
                <xsl:when test="$cwrc_authorrole_marcrelator_code = 'wal' or $cwrc_authorrole_marcrelator_text = 'Writer of added lyrics'">
                    <xsl:text>WriterAddedLyrics</xsl:text>
                </xsl:when>
                <xsl:when test="$cwrc_authorrole_marcrelator_code = 'wam' or $cwrc_authorrole_marcrelator_text = 'Writer of accompanying material'">
                    <xsl:text>WriterAccompanyingMaterial</xsl:text>
                </xsl:when>
                <xsl:when test="$cwrc_authorrole_marcrelator_code = 'wat' or $cwrc_authorrole_marcrelator_text = 'Writer of added text'">
                    <xsl:text>WriterAddedText</xsl:text>
                </xsl:when>
                <xsl:when test="$cwrc_authorrole_marcrelator_code = 'wdc' or $cwrc_authorrole_marcrelator_text = 'Woodcutter'">
                    <xsl:text>Woodcutter</xsl:text>
                </xsl:when>
                <xsl:when test="$cwrc_authorrole_marcrelator_code = 'wde' or $cwrc_authorrole_marcrelator_text = 'Wood engraver'">
                    <xsl:text>WoodEngraver</xsl:text>
                </xsl:when>
                <xsl:when test="$cwrc_authorrole_marcrelator_code = 'win' or $cwrc_authorrole_marcrelator_text = 'Writer of introduction'">
                    <xsl:text>WriterIntroduction</xsl:text>
                </xsl:when>
                <xsl:when test="$cwrc_authorrole_marcrelator_code = 'wit' or $cwrc_authorrole_marcrelator_text = 'Witness'">
                    <xsl:text>Witness</xsl:text>
                </xsl:when>
                <xsl:when test="$cwrc_authorrole_marcrelator_code = 'wpr' or $cwrc_authorrole_marcrelator_text = 'Writer of preface'">
                    <xsl:text>WriterPreface</xsl:text>
                </xsl:when>
                <xsl:when test="$cwrc_authorrole_marcrelator_code = 'wst' or $cwrc_authorrole_marcrelator_text = 'Writer of supplementary textual content'">
                    <xsl:text>WriterSupplementaryTextualContent</xsl:text>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:text>Unknown</xsl:text>
                </xsl:otherwise>
            </xsl:choose>

    </xsl:template>


 


</xsl:stylesheet>
