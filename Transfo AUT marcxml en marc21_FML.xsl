<xsl:stylesheet version="1" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
    <xsl:output encoding="UTF-8" indent="yes" method="xml" omit-xml-declaration="yes"/>
    <xsl:strip-space elements="*"/>
    <!--
  Transformation from UNIMARC XML representation to MARCXML. (ERM créé 2020)
  Based upon http://www.loc.gov/marc/unimarctomarc21.html
    -->
    <!--
       ERM le 25/06/20 
        * déclaration XSL : ajout de l'attribut omit-xml-declaration="yes" pour ne pas écrire le prologue XML <?xml version="1.0" encoding="UTF-8"?> en sortie puisque le protocole OAI l'intègre déjà 
        * mise en ordre des zones via variables
        * identifiants 010, 033 et 035 sous-zones $2 en lowercase
        
         ERM le 01/07 + AJO  06/07
         * 801 (+152) -> 040      
         
         ERM /AJO
         * bloc des point d'accès autorisé 
         - 200 / 220 / 240 
         - 210  
         - 215
         - 230
         - AJO 250
         - AJO 280
         
         ERM / AJO
         * bloc des variantes de points d'accès
         - 400 / 420 / 440 
         - 410
         - 415
         - 430
         - AJO 450
         - AJO 480
          
         ERM / AJO
         * bloc des points d'accès en relation
          - 500 / 520 / 540
          - 510
          - AJO 515 / 550 / 580
         
         ERM / AJO
         * bloc des points d'accès autorisés parallèles
         - 700 / 720 / 740 
         - 710
         - 715
         - 730
         - AJO 750
         - AJO 780
              
         AJO 20/07 : correction traitement sous-zones 3XX pour supprimer $6$7, ajouté 898
                      correction dans template copy-indicators  
                      
         ERM 13/08/20  correction date de création de la notice
         Unimarc z100 -> MARC21 z008
         <xsl:variable name="dest00-05" select="substring($source100, 2, 6)"/>
          corrigé en
         <xsl:variable name="dest00-05" select="substring($source100, 3, 6)"/>
  
       -->
    <xsl:variable name="all-codes">abcdefghijklmnopqrstuvwxyz123456789</xsl:variable>
    <xsl:variable name="smallcase">
        <xsl:text>abcdefghijklmnopqrstuvwxyz</xsl:text>
    </xsl:variable>
    <xsl:variable name="uppercase">
        <xsl:text>ABCDEFGHIJKLMNOPQRSTUVWXYZ</xsl:text>
    </xsl:variable>
    <xsl:key match="datafield[@tag = '200']" name="key200" use="@tag"/>
    <xsl:key match="datafield[@tag = '210' and @ind1 = '0']" name="key210" use="@tag"/>
    <xsl:key match="datafield[@tag = '210' and @ind1 = '1']" name="key211" use="@tag"/>
    <xsl:key match="datafield[@tag = '215']" name="key215" use="@tag"/>
    <xsl:key match="datafield[@tag = '216']" name="key216" use="@tag"/>
    <xsl:key match="datafield[@tag = '220']" name="key220" use="@tag"/>
    <xsl:key match="datafield[@tag = '230']" name="key230" use="@tag"/>
    <xsl:key match="datafield[@tag = '240']" name="key240" use="@tag"/>
    <xsl:key match="datafield[@tag = '250']" name="key250" use="@tag"/>
    <xsl:key match="datafield[@tag = '280']" name="key280" use="@tag"/>
    <xsl:template match="/">
        <xsl:apply-templates select="//record"/>
    </xsl:template>
    <xsl:template match="record">
        <!--ERM le 25/06/20-->
        <!--arbre1 : variable qui contient les zones non ordonnées-->
        <xsl:variable name="arbre1">
            <record>
                <xsl:if test="@type">
                    <xsl:attribute name="type">
                        <xsl:value-of select="@type"/>
                    </xsl:attribute>
                </xsl:if>
                <xsl:call-template name="transform-leader"/>
                <xsl:variable name="z001" select="controlfield[@tag = '001']"/>
                <!-- 010->024 -->
                <xsl:call-template name="transform-datafield">
                    <xsl:with-param name="srcTag">010</xsl:with-param>
                    <xsl:with-param name="dstTag">024</xsl:with-param>
                    <xsl:with-param name="srcCodes">ayz2</xsl:with-param>
                    <xsl:with-param name="dstCodes">azz2</xsl:with-param>
                    <!--      pour les indicateurs (ind0 = rien, ind1 = 7), voir template  copy-indicators -->
                </xsl:call-template>
                <!--015->024 supprimé du mapping (obsolète)-->
                <!--<xsl:call-template name="transform-datafield">
                           <xsl:with-param name="srcTag">015</xsl:with-param>
                           <xsl:with-param name="dstTag">024</xsl:with-param>
             <!-\- pour les indicateurs (ind0 = rien, ind1 = 7), voir template  copy-indicators
                     $2 ISADN sera là de facto  -\-> 
               </xsl:call-template> -->
                <!-- 033->024 -->
                <xsl:call-template name="transform-datafield">
                    <xsl:with-param name="srcTag">033</xsl:with-param>
                    <xsl:with-param name="dstTag">024</xsl:with-param>
                    <xsl:with-param name="srcCodes">a2z</xsl:with-param>
                    <xsl:with-param name="dstCodes">02z</xsl:with-param>
                    <!--     , voir template  copy-indicators pour : ind0 = rien, ind1 = 7  -->
                </xsl:call-template>
                <!-- 035->035 -->
                <xsl:call-template name="transform-datafield">
                    <xsl:with-param name="srcTag">035</xsl:with-param>
                    <xsl:with-param name="dstTag">035</xsl:with-param>
                    <xsl:with-param name="srcCodes">az</xsl:with-param>
                    <xsl:with-param name="dstCodes">az</xsl:with-param>
                </xsl:call-template>
                <!--FML ajout d'une 035 générée à partir de la zone 001-->
                <datafield ind1=" " ind2=" " tag="035">
                    <subfield code="a">
                        <xsl:value-of select="concat('(IDREF)', $z001)"/>
                    </subfield>
                </datafield>
                <!-- Bloc 1XX -->
                <!-- 100->008 : OK voir transform008-->
                <!-- 101->377   (précision : code de langue MARC : est-ce un souci ?)-->
                <xsl:call-template name="transform-datafield">
                    <xsl:with-param name="srcTag">101</xsl:with-param>
                    <xsl:with-param name="dstTag">377</xsl:with-param>
                </xsl:call-template>
                <!-- 102->370 -->
                <!--AJO modif 14/04/20 370 pas OK, en MARC21 en clair. Cible = 043 $c  - testé OK -->
                <xsl:call-template name="transform-datafield">
                    <xsl:with-param name="srcTag">102</xsl:with-param>
                    <xsl:with-param name="dstTag">043</xsl:with-param>
                    <xsl:with-param name="srcCodes">a</xsl:with-param>
                    <xsl:with-param name="dstCodes">c</xsl:with-param>
                    <!--        il faut générer en plus un $2 ISO 3166-1 -->
                    <!--AJO rem: non, pas en 043, car inclus dans la définition MARC21 de $c -->
                </xsl:call-template>
                <!-- 103->046 -->
                <xsl:call-template name="transform-datafield">
                    <xsl:with-param name="srcTag">103</xsl:with-param>
                    <xsl:with-param name="dstTag">046</xsl:with-param>
                    <xsl:with-param name="srcCodes">abcd</xsl:with-param>
                    <xsl:with-param name="dstCodes">fgst</xsl:with-param>
                </xsl:call-template>
                <!-- 120->375 
                        mais il faut décoder en toutes lettres : a -> féminin ; b -> masculin  : exemple $a féminin  -->
                <!--AJO rem: seulement pos. 0; pos 1 va en 008/32-->
                <!--  <xsl:call-template name="transform-datafield">
                            <xsl:with-param name="srcTag">120</xsl:with-param>
                            <xsl:with-param name="dstTag">375</xsl:with-param>
                        </xsl:call-template> -->
                <!--  Conversion ajoutée à la fin du template transform-008 (variable 120 déjà définie)  -->
                <!-- 123->034 -->
                <!-- AJO nouveau 08/07 -->
                <xsl:call-template name="transform-datafield">
                    <xsl:with-param name="srcTag">123</xsl:with-param>
                    <xsl:with-param name="dstTag">034</xsl:with-param>
                    <xsl:with-param name="srcCodes">defg</xsl:with-param>
                    <xsl:with-param name="dstCodes">defg</xsl:with-param>
                </xsl:call-template>
                <!-- 152->040 voir template avec z040 car il faut combiner avec la 801 -->
                <!-- 160->043 -->
                <xsl:call-template name="transform-datafield">
                    <xsl:with-param name="srcTag">160</xsl:with-param>
                    <xsl:with-param name="dstTag">043</xsl:with-param>
                </xsl:call-template>
                <!-- 180 pas d'équivalent -->
                <!-- Bloc des points d'accès 2XX -->
                <!-- 
                    200 ->100 |  220 ->100 | 240 ->100 
                    215 -> 151 
                    210 @ind1=0 -> 110 ou  210 @ind1=1  -> 211 
                    230 -> 130 
                    250 -> 150
                    280 -> 155 
                -->
                <!-- mécanisme : appel du template Z_INTER_2XX qui permet de compter les zones 2XX et les $7 [substring(text(), 5, 2) = 'ba'] afin d'orienter (template Z_PT_ACCES_XXX ) vers la bonne zone marc21  :
                    * 1XX pour les zones retenues : $7 [substring(text(), 5, 2) = 'ba']
                    * 7XX pour les "retoquées"
                    => ce template permet d'alimenter les paramètres :  "position" / "nb2XX" / "nbsz7_ba" utiliseés par le template Z_PT_ACCES_XXX qui construit les zones 1XX / 7XX (natives et retoquées) / 4XX
                    -->
                <xsl:for-each
                    select="datafield[@tag = '200'] | datafield[@tag = '210'] | datafield[@tag = '215'] | datafield[@tag = '220'] | datafield[@tag = '230'] | datafield[@tag = '240'] | datafield[@tag = '250'] | datafield[@tag = '280']">
                    <xsl:call-template name="Z_INTER_2XX">
                        <xsl:with-param name="srcTag">
                            <xsl:choose>
                                <xsl:when test="@tag = '210' and @ind1 = '1'">
                                    <xsl:text>211</xsl:text>
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:value-of select="@tag"/>
                                </xsl:otherwise>
                            </xsl:choose>
                        </xsl:with-param>
                    </xsl:call-template>
                </xsl:for-each>
                <!-- 216->150 -->
                <xsl:call-template name="transform-datafield">
                    <xsl:with-param name="srcTag">216</xsl:with-param>
                    <xsl:with-param name="dstTag">150</xsl:with-param>
                    <xsl:with-param name="srcCodes">afcxyz</xsl:with-param>
                    <xsl:with-param name="dstCodes">aggxzy</xsl:with-param>
                </xsl:call-template>
                <!-- 230->130 -->
                <!--  traité ci-dessus traité ci-dessus via Z_INTER_2XX-->
                <!-- RIEN à propos de 231/232 ?  -->
                <!-- 250->150 -->
                <!-- AJO 20/07: 250/450/750 :  250->150  traité ci-dessus via Z_INTER_2XX-->
                <!-- 280->155 -->
                <!-- AJO 20/07: 280/480/780  280->155  traité ci-dessus via Z_INTER_2XX-->
                <!-- Notes 3XX -->
                <!-- AJO 20/07: complété traitement sous-zones 3XX pour supprimer $6$7-->
                <!-- 300->680 -->
                <xsl:call-template name="transform-datafield">
                    <xsl:with-param name="srcTag">300</xsl:with-param>
                    <xsl:with-param name="dstTag">680</xsl:with-param>
                    <xsl:with-param name="srcCodes">a</xsl:with-param>
                    <xsl:with-param name="dstCodes">a</xsl:with-param>
                </xsl:call-template>
                <!-- 305->360 -->
                <xsl:call-template name="transform-datafield">
                    <xsl:with-param name="srcTag">305</xsl:with-param>
                    <xsl:with-param name="dstTag">360</xsl:with-param>
                    <xsl:with-param name="srcCodes">ab</xsl:with-param>
                    <xsl:with-param name="dstCodes">ia</xsl:with-param>
                </xsl:call-template>
                <!-- 310->260 -->
                <xsl:call-template name="transform-datafield">
                    <xsl:with-param name="srcTag">310</xsl:with-param>
                    <xsl:with-param name="dstTag">260</xsl:with-param>
                    <xsl:with-param name="srcCodes">ab</xsl:with-param>
                    <xsl:with-param name="dstCodes">ia</xsl:with-param>
                </xsl:call-template>
                <!-- 320->680 -->
                <xsl:call-template name="transform-datafield">
                    <xsl:with-param name="srcTag">320</xsl:with-param>
                    <xsl:with-param name="dstTag">666</xsl:with-param>
                    <xsl:with-param name="srcCodes">a</xsl:with-param>
                    <xsl:with-param name="dstCodes">a</xsl:with-param>
                </xsl:call-template>
                <!-- 330->680 -->
                <xsl:call-template name="transform-datafield">
                    <xsl:with-param name="srcTag">330</xsl:with-param>
                    <xsl:with-param name="dstTag">680</xsl:with-param>
                    <xsl:with-param name="srcCodes">a</xsl:with-param>
                    <xsl:with-param name="dstCodes">a</xsl:with-param>
                </xsl:call-template>
                <!-- 340->678 -->
                <xsl:call-template name="transform-datafield">
                    <xsl:with-param name="srcTag">340</xsl:with-param>
                    <xsl:with-param name="dstTag">678</xsl:with-param>
                    <xsl:with-param name="srcCodes">a</xsl:with-param>
                    <xsl:with-param name="dstCodes">a</xsl:with-param>
                </xsl:call-template>
                <!-- 356->680 -->
                <xsl:call-template name="transform-datafield">
                    <xsl:with-param name="srcTag">356</xsl:with-param>
                    <xsl:with-param name="dstTag">680</xsl:with-param>
                    <xsl:with-param name="srcCodes">a</xsl:with-param>
                    <xsl:with-param name="dstCodes">a</xsl:with-param>
                </xsl:call-template>
                <!-- Bloc des 4XX -->
                <!-- ERM 09/07/10 : 400 / 420 / 440 => 400  conditionné au traitement de la 200 / 220 qui devient 100 pour pouvoir reprendre éventuellement, si 4XX n'a pas de $f, le 200$f pour une 400 et le 220$f pour une 420 -->
                <!-- 410  -> 410 (si ind1=0 -> collectivité) ou 411 (si ind1=1 -> congrès)-->
                <!--  appel du template Z_PT_ACCES_2or4or710_11 pour construire les 410 (si ind1=0 -> collectivité) ou 411 (si ind1=1 -> congrès)-->
                <xsl:for-each select="datafield[@tag = '410']">
                    <xsl:call-template name="Z_PT_ACCES_2or4or710_11">
                        <xsl:with-param name="srcTag" select="@tag"/>
                        <xsl:with-param name="type">
                            <xsl:choose>
                                <xsl:when test="@ind1 = '0'">
                                    <xsl:text>410</xsl:text>
                                </xsl:when>
                                <xsl:otherwise>411</xsl:otherwise>
                            </xsl:choose>
                        </xsl:with-param>
                    </xsl:call-template>
                </xsl:for-each>
                <!-- 415 -> 451 -->
                <!--  appel du template Z_PT_ACCES_215_415_715 pour construire les 451-->
                <xsl:for-each select="datafield[@tag = '415']">
                    <xsl:call-template name="Z_PT_ACCES_215_415_715">
                        <xsl:with-param name="srcTag" select="@tag"/>
                        <xsl:with-param name="type" select="451"/>
                    </xsl:call-template>
                </xsl:for-each>
                <!-- 430 -> 430 -->
                <!--  appel du template Z_PT_ACCES_230_430_730 pour construire les 430-->
                <xsl:for-each select="datafield[@tag = '430']">
                    <xsl:call-template name="Z_PT_ACCES_230_430_730">
                        <xsl:with-param name="srcTag" select="@tag"/>
                        <xsl:with-param name="type" select="430"/>
                    </xsl:call-template>
                </xsl:for-each>
                <!--  AJO 20/07: appel du template Z_PT_ACCES_250_450_750 pour construire les 450-->
                <xsl:for-each select="datafield[@tag = '450']">
                    <xsl:call-template name="Z_PT_ACCES_250_450_750">
                        <xsl:with-param name="srcTag" select="@tag"/>
                        <xsl:with-param name="type" select="450"/>
                    </xsl:call-template>
                </xsl:for-each>
                <!--  AJO 20/07: appel du template Z_PT_ACCES_280_480_780 pour construire les 455-->
                <xsl:for-each select="datafield[@tag = '480']">
                    <xsl:call-template name="Z_PT_ACCES_280_480_780">
                        <xsl:with-param name="srcTag" select="@tag"/>
                        <xsl:with-param name="type" select="455"/>
                    </xsl:call-template>
                </xsl:for-each>
                <!-- Bloc des 5XX -->
                <!--  appel du template Z_PT_ACCES_510 -->
                <xsl:for-each select="datafield[@tag = '510']">
                    <xsl:call-template name="Z_PT_ACCES_510">
                        <xsl:with-param name="srcTag" select="@tag"/>
                    </xsl:call-template>
                </xsl:for-each>
                <!-- 500 / 520 / 540 ->500 -->
                <!--  appel du template Z_PT_ACCES_500_20_40 -->
                <xsl:for-each
                    select="datafield[@tag = '500'] | datafield[@tag = '520'] | datafield[@tag = '540']">
                    <xsl:call-template name="Z_PT_ACCES_500_20_40">
                        <xsl:with-param name="srcTag" select="@tag"/>
                    </xsl:call-template>
                </xsl:for-each>
                <!--  AJO 20/07: 515/550/580 -->
                <xsl:for-each
                    select="datafield[@tag = '515'] | datafield[@tag = '550'] | datafield[@tag = '580']">
                    <xsl:call-template name="Z_PT_ACCES_515_50_80">
                        <xsl:with-param name="srcTag" select="@tag"/>
                    </xsl:call-template>
                </xsl:for-each>
                <!-- Bloc des 6XX -->
                <!-- 676->083 -->
                <!-- AJO 20/07: corr. dstTag: 083 et non 082 -->
                <xsl:call-template name="transform-datafield">
                    <xsl:with-param name="srcTag">676</xsl:with-param>
                    <xsl:with-param name="dstTag">083</xsl:with-param>
                    <xsl:with-param name="srcCodes">av</xsl:with-param>
                    <xsl:with-param name="dstCodes">a2</xsl:with-param>
                </xsl:call-template>
                <!-- 686->065 -->
                <xsl:call-template name="transform-datafield">
                    <xsl:with-param name="srcTag">686</xsl:with-param>
                    <xsl:with-param name="dstTag">065</xsl:with-param>
                </xsl:call-template>
                <!-- Bloc des 7XX -->
                <!-- 700 / 720 / 740 ->700 -->
                <!--  appel du template Z_PT_ACCES_2or400_20_40 avec les variables qui permettent :
                - de déterminer la zone de destination 
                - de construire les zones 100 / 700 (natives et retoquées) / 400
                -->
                <xsl:for-each
                    select="datafield[@tag = '700'] | datafield[@tag = '720'] | datafield[@tag = '740']">
                    <xsl:call-template name="Z_PT_ACCES_2or4or700_20_40">
                        <xsl:with-param name="srcTag" select="@tag"/>
                        <xsl:with-param name="type" select="700"/>
                    </xsl:call-template>
                </xsl:for-each>
                <!-- 710  ->710 (si ind1=0 -> collectivité) ou 711 (si ind1=1 -> congrès)-->
                <!--  appel du template Z_PT_ACCES_2or4or710_11 pour construire les 710 (si ind1=0 -> collectivité) ou 7411 (si ind1=1 -> congrès)-->
                <xsl:for-each select="datafield[@tag = '710']">
                    <xsl:call-template name="Z_PT_ACCES_2or4or710_11">
                        <xsl:with-param name="srcTag" select="@tag"/>
                        <xsl:with-param name="type">
                            <xsl:choose>
                                <xsl:when test="@ind1 = '0'">
                                    <xsl:text>710</xsl:text>
                                </xsl:when>
                                <xsl:otherwise>711</xsl:otherwise>
                            </xsl:choose>
                        </xsl:with-param>
                    </xsl:call-template>
                </xsl:for-each>
                <!-- 715  ->751 -->
                <!--  appel du template Z_PT_ACCES_215_415_715 pour construire les 751-->
                <xsl:for-each select="datafield[@tag = '715']">
                    <xsl:call-template name="Z_PT_ACCES_215_415_715">
                        <xsl:with-param name="srcTag" select="@tag"/>
                        <xsl:with-param name="type" select="751"/>
                    </xsl:call-template>
                </xsl:for-each>
                <!-- 730 ->730 -->
                <!--  appel du template Z_PT_ACCES_230_430_730 pour construire les 730-->
                <xsl:for-each select="datafield[@tag = '730']">
                    <xsl:call-template name="Z_PT_ACCES_230_430_730">
                        <xsl:with-param name="srcTag" select="@tag"/>
                        <xsl:with-param name="type" select="730"/>
                    </xsl:call-template>
                </xsl:for-each>
                <!-- 750  ->750 -->
                <!--  AJO 20/07: appel du template Z_PT_ACCES_250_450_750 pour construire les 750-->
                <xsl:for-each select="datafield[@tag = '750']">
                    <xsl:call-template name="Z_PT_ACCES_250_450_750">
                        <xsl:with-param name="srcTag" select="@tag"/>
                        <xsl:with-param name="type" select="750"/>
                    </xsl:call-template>
                </xsl:for-each>
                <!-- 780  ->755 -->
                <!--  AJO 20/07: appel du template Z_PT_ACCES_280_480_780 pour construire les 755-->
                <xsl:for-each select="datafield[@tag = '780']">
                    <xsl:call-template name="Z_PT_ACCES_280_480_780">
                        <xsl:with-param name="srcTag" select="@tag"/>
                        <xsl:with-param name="type" select="755"/>
                    </xsl:call-template>
                </xsl:for-each>
                <!-- Bloc des 8XX -->
                <!-- 801->040 : template particulier  -->
                <!--ERM le 01/07 + AJO (06.07)                               
                adjonctions pour un fonctionnement correcte de la transformation de 152 $b + 801 (plusieurs zones) en 040 (une seule zone)-->
                <!--AJO 06/07: ajouté @ind2=3, sinon pas de 040 dans ce cas -->
                <!--AJO 08/07: ajouté @ind2=#, sinon pas de 040 dans ce cas (utilisé à la place de 0)-->
                <xsl:choose>
                    <xsl:when test="datafield[@tag = '801'][@ind2 = '0']">
                        <xsl:call-template name="z040">
                            <xsl:with-param name="base040" select="'0'"/>
                        </xsl:call-template>
                    </xsl:when>
                    <xsl:when test="datafield[@tag = '801'][@ind2 = '#']">
                        <xsl:call-template name="z040">
                            <xsl:with-param name="base040" select="'#'"/>
                        </xsl:call-template>
                    </xsl:when>
                    <xsl:when test="datafield[@tag = '801'][@ind2 = '1']">
                        <xsl:call-template name="z040">
                            <xsl:with-param name="base040" select="'1'"/>
                        </xsl:call-template>
                    </xsl:when>
                    <xsl:when test="datafield[@tag = '801'][@ind2 = '2']">
                        <xsl:call-template name="z040">
                            <xsl:with-param name="base040" select="'2'"/>
                        </xsl:call-template>
                    </xsl:when>
                    <xsl:when test="datafield[@tag = '801'][@ind2 = '3']">
                        <xsl:call-template name="z040">
                            <xsl:with-param name="base040" select="'3'"/>
                        </xsl:call-template>
                    </xsl:when>
                </xsl:choose>
                <!-- 810->670 -->
                <!--AJO 21/07: ajouté sous-zones a et b pour supprimer 6 et 7 -->
                <!-- pas dans le format IdRef, mais apparemment utilisé -->
                <xsl:call-template name="transform-datafield">
                    <xsl:with-param name="srcTag">810</xsl:with-param>
                    <xsl:with-param name="dstTag">670</xsl:with-param>
                    <xsl:with-param name="srcCodes">ab</xsl:with-param>
                    <xsl:with-param name="dstCodes">ab</xsl:with-param>
                </xsl:call-template>
                <!-- 815->675 -->
                <xsl:call-template name="transform-datafield">
                    <xsl:with-param name="srcTag">815</xsl:with-param>
                    <xsl:with-param name="dstTag">675</xsl:with-param>
                </xsl:call-template>
                <!-- 820->667 -->
                <xsl:call-template name="transform-datafield">
                    <xsl:with-param name="srcTag">820</xsl:with-param>
                    <xsl:with-param name="dstTag">667</xsl:with-param>
                </xsl:call-template>
                <!-- 822-> 680  : template particulier
                    reprendre seulement $a + $2 à mettre en 680 $a (remplacer le $2 par  espace tiret espace)
                    822 12 $a Fantômes $2 RVMLaval $d 2013-10-22  -> 680 _ _  $a Fantômes - RVMLaval
                -->
                <xsl:call-template name="z680">
                    <xsl:with-param name="srcTag">822</xsl:with-param>
                    <xsl:with-param name="dstTag">680</xsl:with-param>
                </xsl:call-template>
                <!-- 825->681 -->
                <!-- 825    AJO 19/06/20 utilisation du champ prévu dans MARC21: 681 $i détails voir concordance principale-->
                <!--AJO modif 19/06/20 : la zone correcte 681, également utilisée pour VIAF-->
                <xsl:call-template name="transform-datafield">
                    <xsl:with-param name="srcTag">825</xsl:with-param>
                    <xsl:with-param name="dstTag">681</xsl:with-param>
                    <xsl:with-param name="srcCodes">a</xsl:with-param>
                    <xsl:with-param name="dstCodes">i</xsl:with-param>
                </xsl:call-template>
                <!-- 830->667 -->
                <xsl:call-template name="transform-datafield">
                    <xsl:with-param name="srcTag">830</xsl:with-param>
                    <xsl:with-param name="dstTag">667</xsl:with-param>
                </xsl:call-template>
                <!-- 835->682 -->
                <!-- AJO 20/07: complété traitement sous-zones 835 -->
                <xsl:call-template name="transform-datafield">
                    <xsl:with-param name="srcTag">835</xsl:with-param>
                    <xsl:with-param name="dstTag">682</xsl:with-param>
                    <xsl:with-param name="srcCodes">ab3</xsl:with-param>
                    <xsl:with-param name="dstCodes">ia0</xsl:with-param>
                </xsl:call-template>
                <!-- 836->682 -->
                <!-- AJO 20/07: complété traitement sous-zones 836 -->
                <xsl:call-template name="transform-datafield">
                    <xsl:with-param name="srcTag">836</xsl:with-param>
                    <xsl:with-param name="dstTag">688</xsl:with-param>
                    <xsl:with-param name="srcCodes">b</xsl:with-param>
                    <xsl:with-param name="dstCodes">a</xsl:with-param>
                </xsl:call-template>
                <!-- 839->682 : cette zone n'existe pas en unimarcxml ; elle devient une 035$appn fusionné $9sudoc-->
                <!-- 856->856 -->
                <!-- AJO 20/07: complété traitement sous-zones 856 -->
                <xsl:call-template name="transform-datafield">
                    <xsl:with-param name="srcTag">856</xsl:with-param>
                    <xsl:with-param name="dstTag">856</xsl:with-param>
                    <xsl:with-param name="srcCodes">ue</xsl:with-param>
                    <xsl:with-param name="dstCodes">uz</xsl:with-param>
                </xsl:call-template>
                <!-- AJO 20/07: ajouté-->
                <xsl:call-template name="z898">
                    <xsl:with-param name="srcTag">898</xsl:with-param>
                    <xsl:with-param name="dstTag">667</xsl:with-param>
                </xsl:call-template>
                <!-- nos 9XX : les voudriez-vous ? AJO: NON -->
            </record>
        </xsl:variable>
        <!--ERM le 25/06/20-->
        <!-- arbre2 : variable qui contient la copie ordonnée des zones de arbre1-->
        <xsl:variable name="arbre2">
            <record>
                <xsl:for-each select="common:node-set($arbre1)/record/*"
                    xmlns:common="http://exslt.org/common">
                    <xsl:sort select="@tag"/>
                    <xsl:copy-of select="."/>
                </xsl:for-each>
            </record>
        </xsl:variable>
        <!--ERM le 25/06/20 -->
        <!-- permet d'écrire le résultat-->
        <xsl:copy-of select="$arbre2"/>
    </xsl:template>
    <xsl:template name="transform-leader">
        <xsl:variable name="leader" select="leader"/>
        <!--FML 14/01/20 Peut-il y avoir une valeur o ? -->
        <xsl:variable name="leader05" select="translate(substring($leader, 06, 1), 'o', 'c')"/>
        <!--encodage du vide &#x20;-->
        <xsl:variable name="leader06" select="translate(substring($leader, 07, 1), 'xz', 'z ')"/>
        <xsl:variable name="leader07-08" select="substring($leader, 08, 2)"/>
        <xsl:variable name="leader09_075" select="substring($leader, 10, 1)"/>
        <xsl:variable name="leader09" select="'a'"/>
        <xsl:variable name="leader10-16" select="substring($leader, 11, 7)"/>
        <!--AJO modif 14/04/20 translation 2 valeurs - testé - OK -->
        <xsl:variable name="leader17" select="translate(substring($leader, 18, 1), '#3', 'no')"/>
        <xsl:variable name="leader18" select="'c'"/>
        <xsl:variable name="leader19-23" select="' 4500'"/>
        <leader>
            <xsl:value-of
                select="concat('     ', $leader05, $leader06, $leader07-08, $leader09, $leader10-16, $leader17, $leader18, $leader19-23)"
            />
        </leader>
        <xsl:call-template name="copy-control">
            <xsl:with-param name="tag">001</xsl:with-param>
        </xsl:call-template>
        <xsl:call-template name="copy-control">
            <xsl:with-param name="tag">005</xsl:with-param>
        </xsl:call-template>
        <xsl:call-template name="transform-008"/>
        <!-- Création de la zone 075 à partir de la position 9 du leader -->
        <datafield ind1=" " ind2=" " tag="075">
            <subfield code="a">
                <xsl:call-template name="typeAut">
                    <xsl:with-param name="code" select="$leader09_075"/>
                </xsl:call-template>
            </subfield>
            <subfield code="b">
                <xsl:value-of select="$leader09_075"/>
            </subfield>
            <subfield code="2">unimarc</subfield>
        </datafield>
    </xsl:template>
    <xsl:template name="copy-control">
        <xsl:param name="tag"/>
        <xsl:for-each select="controlfield[@tag = $tag]">
            <controlfield tag="{$tag}">
                <xsl:value-of select="substring(text(), 1, 16)"/>
            </controlfield>
        </xsl:for-each>
    </xsl:template>
    <xsl:template name="transform-008">
        <xsl:variable name="source100" select="datafield[@tag = '100']/subfield[@code = 'a']"/>
        <xsl:variable name="source106" select="datafield[@tag = '106']"/>
        <xsl:variable name="source120" select="datafield[@tag = '120']/subfield[@code = 'a']"/>
        <xsl:variable name="source154" select="datafield[@tag = '154']/subfield[@code = 'a']"/>
        <!--ERM 13/08/20 date création de la notice
            <xsl:variable name="dest00-05" select="substring($source100, 2, 6)"/>-->
        <xsl:variable name="dest00-05" select="substring($source100, 3, 6)"/>
        <xsl:variable name="dest06">
            <xsl:choose>
                <xsl:when test="$source106/subfield[@code = 'c'] != ''">
                    <xsl:call-template name="z106c">
                        <xsl:with-param name="code" select="$source106/subfield[@code = 'c']"/>
                    </xsl:call-template>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:text>n</xsl:text>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <!--AJO modif 14/04/20 : | (pas de blanc dans cette pos.) -->
        <xsl:variable name="dest07" select="'|'"> </xsl:variable>
        <xsl:variable name="dest08">
            <xsl:choose>
                <xsl:when test="substring($source100, 10, 3) = 'fre'">
                    <xsl:text>f</xsl:text>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:text>|</xsl:text>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:variable name="dest09">
            <xsl:choose>
                <xsl:when test="$source106/subfield[@code = 'b'] != ''">
                    <xsl:call-template name="z106b">
                        <xsl:with-param name="code" select="$source106/subfield[@code = 'b']"/>
                    </xsl:call-template>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:text> </xsl:text>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <!--AJO modif 14/04/20 : ||||| (pas de blanc dans cette pos.) -->
        <!--AJO modif 19/06/20 : zz||| (valeurs par défaut pour règles, pos. 10-11: zz) -->
        <xsl:variable name="dest10-14" select="'zz|||'"> </xsl:variable>
        <xsl:variable name="dest15">
            <xsl:choose>
                <xsl:when test="$source106/subfield[@code = 'a'] != ''">
                    <xsl:call-template name="z106a">
                        <xsl:with-param name="code" select="$source106/subfield[@code = 'a']"/>
                    </xsl:call-template>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:text> </xsl:text>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <!--AJO modif 14/04/20 dest16-31: 16 pos., pas 15; pos. 16, 17, 28, 29, 31: | (pas de blanc dans ces pos.)-->
        <xsl:variable name="dest16-31">
            <xsl:text>||          || |</xsl:text>
        </xsl:variable>
        <xsl:variable name="dest32">
            <xsl:choose>
                <!--AJO modif 14/04/20 diff/undiff person name: 120 $a pos. 1 (et non 0) -->
                <xsl:when test="$source120 != ''">
                    <xsl:value-of select="substring($source120, 2, 1)"/>
                </xsl:when>
                <!--AJO modif 14/04/20 otherwise: | (pas de blanc dans cette pos.) -->
                <xsl:otherwise>
                    <xsl:text>|</xsl:text>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <!--AJO modif 14/04/20 (ajout): Status of authorized access point / Level of establishment-->
        <xsl:variable name="dest33">
            <xsl:choose>
                <xsl:when test="substring($source100, 9, 1) = 'x'">
                    <xsl:text>n</xsl:text>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="substring($source100, 9, 1)"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <!--AJO modif 14/04/20 (ajout): fin de la zone 008 (pos. 34-39, pos. par défaut)-->
        <xsl:variable name="dest34-39">
            <xsl:text>     d</xsl:text>
        </xsl:variable>
        <controlfield tag="008">
            <xsl:value-of
                select="concat($dest00-05, $dest06, $dest07, $dest08, $dest09, $dest10-14, $dest15, $dest16-31, $dest32, $dest33, $dest34-39)"
            />
        </controlfield>
        <!-- Création de la zone 375 à partir de la position 0 de 120 -->
        <!-- La zone n'est crée qu'en présence des valeurs a, b ou c -->
        <!--AJO modif 14/04/20 (ajout)-->
        <xsl:if test="$source120 != ''">
            <xsl:variable name="dest375">
                <xsl:choose>
                    <xsl:when test="substring($source120, 1, 1) = 'a'">
                        <xsl:text>féminin</xsl:text>
                    </xsl:when>
                    <xsl:when test="substring($source120, 1, 1) = 'b'">
                        <xsl:text>masculin</xsl:text>
                    </xsl:when>
                    <xsl:when test="substring($source120, 1, 1) = 'c'">
                        <xsl:text>transgenre</xsl:text>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:text>xxx</xsl:text>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:variable>
            <xsl:if test="$dest375 != 'xxx'">
                <datafield ind1=" " ind2=" " tag="375">
                    <subfield code="a">
                        <xsl:value-of select="$dest375"/>
                    </subfield>
                    <subfield code="2">unimarc</subfield>
                </datafield>
            </xsl:if>
        </xsl:if>
    </xsl:template>
    <xsl:template name="transform-datafield">
        <xsl:param name="srcTag"/>
        <xsl:param name="dstTag" select="@srcTag"/>
        <xsl:param name="srcCodes" select="$all-codes"/>
        <xsl:param name="dstCodes" select="$srcCodes"/>
        <xsl:if test="datafield[@tag = $srcTag]/subfield[contains($srcCodes, @code)]">
            <xsl:for-each select="datafield[@tag = $srcTag]">
                <datafield tag="{$dstTag}">
                    <!--ERM le 25/06/20 -->
                    <!-- ajout du paramètre dstTag pour faire des traitements spécifiques sur les indicateurs de certaines zones-->
                    <xsl:call-template name="copy-indicators">
                        <xsl:with-param name="dstTag" select="$dstTag"/>
                    </xsl:call-template>
                    <xsl:call-template name="transform-subfields">
                        <xsl:with-param name="srcTag" select="$srcTag"/>
                        <xsl:with-param name="srcCodes" select="$srcCodes"/>
                        <xsl:with-param name="dstCodes" select="$dstCodes"/>
                    </xsl:call-template>
                </datafield>
            </xsl:for-each>
        </xsl:if>
    </xsl:template>
    <!--ERM le 09/07/20
    révision du bloc des points d'accès 2XX
    règle utilisée pour documenter les cardinalités dans les commentaires :
    ? => élément facultatif et unique
    * => élément facultatif et répétable
    + => élément obligatoire et répétable
    
    [] séquence 
    [] ? => séquence facultative et unique
    [] * => séquence facultative et répétable
    [] + => séquence obligatoire et répétable
     -->
    <!-- Quelle 200 ->100 |  220 ->100 | 240 ->100 | 215 -> 151 |
        ERM : 09/07/20 : 
                    mécanisme : 
                    Ce template est un template intermédiaire qui permet de compter les zones 2XX = variable nb2XX  (en les regroupant par @tag) et les $7 [substring(text(), 5, 2) = 'ba'] = variable nbsz7_ba 
                    afin que le template Z_PT_ACCES_XXX oriente ces 2XX vers la bonne zone marc21  :
                    * 1XX pour les 2XX retenues : $7 [substring(text(), 5, 2) = 'ba']
                    * 7XX pour les "retoquées"
                    => ce template permet d'alimenter les paramètres :  "position" / "nb2XX" / "nbsz7_ba" utilisés par le template Z_PT_ACCES_XXX.                   
                   -->
    <xsl:template name="Z_INTER_2XX">
        <xsl:param name="srcTag"/>
        <xsl:variable name="key" select="concat('key', $srcTag)"/>
        <xsl:for-each select="self::node()[count(. | key($key, @tag)[1]) = 1]">
            <xsl:variable name="group2XX" select="key($key, @tag)"/>
            <xsl:variable name="nb2XX" select="count($group2XX)"/>
            <xsl:variable name="nbsz7_ba"
                select="count($group2XX/subfield[@code = '7'][substring(text(), 5, 2) = 'ba'])"/>
            <!--  appel des templates en fonction de  $srcTag 
                * Z_PT_ACCES_2or4or700_20_40 avec les variables qui permettent :
                - de déterminer la zone de destination 
                - de construire les zones 100 / 700 (natives et retoquées) / 400
                  * Z_PT_ACCES_2or4or710_11  avec les variables qui permettent :
                  - de déterminer la zone de destination 
                  - de construire les zones 110 ou 111 / 710 ou 711  (natives et retoquées) / 410 ou 411
                * Z_PT_ACCES_215_415_715
                  - de déterminer la zone de destination 
                  - de construire les zones 151 / 751 (natives et retoquées) / 451
                  * Z_PT_ACCES_230_430_730
                  - de déterminer la zone de destination 
                  - de construire les zones 130 / 730 (natives et retoquées) / 430
                  * Z_PT_ACCES_250_450_750
                  - de déterminer la zone de destination 
                -->
            <xsl:for-each select="$group2XX/.">
                <xsl:choose>
                    <xsl:when test="$srcTag = '200' or $srcTag = '220' or $srcTag = '240'">
                        <xsl:call-template name="Z_PT_ACCES_2or4or700_20_40">
                            <xsl:with-param name="srcTag" select="$srcTag"/>
                            <xsl:with-param name="position" select="position()"/>
                            <xsl:with-param name="nb2XX" select="$nb2XX"/>
                            <xsl:with-param name="nbsz7_ba" select="$nbsz7_ba"/>
                        </xsl:call-template>
                    </xsl:when>
                    <xsl:when test="$srcTag = '210' or $srcTag = '211'">
                        <xsl:call-template name="Z_PT_ACCES_2or4or710_11">
                            <xsl:with-param name="srcTag" select="'210'"/>
                            <xsl:with-param name="position" select="position()"/>
                            <xsl:with-param name="nb2XX" select="$nb2XX"/>
                            <xsl:with-param name="nbsz7_ba" select="$nbsz7_ba"/>
                        </xsl:call-template>
                    </xsl:when>
                    <xsl:when test="$srcTag = '215'">
                        <xsl:call-template name="Z_PT_ACCES_215_415_715">
                            <xsl:with-param name="srcTag" select="$srcTag"/>
                            <xsl:with-param name="position" select="position()"/>
                            <xsl:with-param name="nb2XX" select="$nb2XX"/>
                            <xsl:with-param name="nbsz7_ba" select="$nbsz7_ba"/>
                        </xsl:call-template>
                    </xsl:when>
                    <xsl:when test="$srcTag = '230'">
                        <xsl:call-template name="Z_PT_ACCES_230_430_730">
                            <xsl:with-param name="srcTag" select="$srcTag"/>
                            <xsl:with-param name="position" select="position()"/>
                            <xsl:with-param name="nb2XX" select="$nb2XX"/>
                            <xsl:with-param name="nbsz7_ba" select="$nbsz7_ba"/>
                        </xsl:call-template>
                    </xsl:when>
                    <!-- AJO 20/07: 250/450/750 -->
                    <xsl:when test="$srcTag = '250'">
                        <xsl:call-template name="Z_PT_ACCES_250_450_750">
                            <xsl:with-param name="srcTag" select="$srcTag"/>
                            <xsl:with-param name="position" select="position()"/>
                            <xsl:with-param name="nb2XX" select="$nb2XX"/>
                            <xsl:with-param name="nbsz7_ba" select="$nbsz7_ba"/>
                        </xsl:call-template>
                    </xsl:when>
                    <!-- AJO 20/07: 280/480/780 -->
                    <xsl:when test="$srcTag = '280'">
                        <xsl:call-template name="Z_PT_ACCES_280_480_780">
                            <xsl:with-param name="srcTag" select="$srcTag"/>
                            <xsl:with-param name="position" select="position()"/>
                            <xsl:with-param name="nb2XX" select="$nb2XX"/>
                            <xsl:with-param name="nbsz7_ba" select="$nbsz7_ba"/>
                        </xsl:call-template>
                    </xsl:when>
                </xsl:choose>
            </xsl:for-each>
        </xsl:for-each>
    </xsl:template>
    <xsl:template name="Z_PT_ACCES_2or4or700_20_40">
        <xsl:param name="srcTag"/>
        <xsl:param name="type"/>
        <xsl:param name="position"/>
        <xsl:param name="nb2XX"/>
        <xsl:param name="nbsz7_ba"/>
        <xsl:param name="date_szf"/>
        <xsl:param name="z2XX_liee"/>
        <xsl:variable name="ind1" select="@ind1"/>
        <xsl:variable name="ind2" select="@ind2"/>
        <xsl:variable name="sz7_pos5-6" select="substring(subfield[@code = '7'], 5, 2)"/>
        <!-- ERM : algo qui permet de déterminer pour les 2XX / 7XX / 4XX quelle est la zone de destination marc21
            * quelle 2XX > 100 ?
            * quelle 2XX > 700 = les 2XX retoquées 
            * 7XX natives > 700 
            * 4XX > 400
              
        algo quelle 2XX > 100 ?
            - si $nb2XX = 1 -> 100
            - si $nb2XX > 1
             alors test sur $7    si $nbsz7_ba = ba0  = 0  -> prendre la 1ère  2XX (bien que $7 != ba) -> 100
                                             si $nbsz7_ba = ba0  = 1 -> prendre cette 2XX -> 100
                                             si $nbsz7_ba = ba0  > 1 -> prendre la 1ère  2XX dont  $7 = ba-> 100
        -->
        <xsl:variable name="dstTag">
            <xsl:choose>
                <!-- cas des 7XX natives et 4XX (en auto-rappel) -->
                <xsl:when test="$type != ''">
                    <xsl:value-of select="$type"/>
                </xsl:when>
                <!--  pour déterminer quelle 2XX ira en 100-->
                <xsl:when test="$nb2XX = 1">100</xsl:when>
                <xsl:when test="$nb2XX > 1">
                    <xsl:choose>
                        <xsl:when test="$nbsz7_ba = 0">
                            <xsl:choose>
                                <xsl:when test="position() = 1">100</xsl:when>
                                <xsl:otherwise>700</xsl:otherwise>
                            </xsl:choose>
                        </xsl:when>
                        <xsl:when test="$nbsz7_ba = 1">
                            <xsl:choose>
                                <xsl:when test="$sz7_pos5-6 = 'ba'">100</xsl:when>
                                <xsl:otherwise>700</xsl:otherwise>
                            </xsl:choose>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:choose>
                                <xsl:when
                                    test="$sz7_pos5-6 = 'ba' and not(preceding-sibling::datafield[@tag = $srcTag]/subfield[@code = '7'][substring(text(), 5, 2) = 'ba'])"
                                    >100</xsl:when>
                                <xsl:otherwise>700</xsl:otherwise>
                            </xsl:choose>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:when>
            </xsl:choose>
        </xsl:variable>
        <!-- construction de ind1 via une variable $destInd1-->
        <xsl:variable name="destInd1">
            <xsl:choose>
                <!-- ind1 <=  200 ind2 / 700 ind2 / 400 ind2-->
                <xsl:when test="$srcTag = '200' or $srcTag = '700' or $srcTag = '400'">
                    <xsl:value-of select="$ind2"/>
                </xsl:when>
                <!-- ind1 <=  220 / 720 / 420 -->
                <xsl:when test="$srcTag = '220' or $srcTag = '720' or $srcTag = '420'">
                    <!--100 ind1= 3 / 700 ind1= 3 -->
                    <xsl:text>3</xsl:text>
                </xsl:when>
                <!-- ind1 <=  240 / 740 / 440-->
                <xsl:when test="$srcTag = '240' or $srcTag = '740' or $srcTag = '440'">
                    <!--100 ind1= 1 / 700 ind1= 1 -->
                    <xsl:text>1</xsl:text>
                </xsl:when>
            </xsl:choose>
        </xsl:variable>
        <!-- construction de ind2 via une variable $destInd2-->
        <xsl:variable name="destInd2">
            <xsl:choose>
                <!-- ind2 <=  200 ind1 / 700 ind1 / 400 ind1-->
                <xsl:when test="$srcTag = '200' or $srcTag = '700' or $srcTag = '400'">
                    <xsl:value-of select="$ind1"/>
                </xsl:when>
                <!-- ind2 <=  220 / 720 / 420 -->
                <xsl:when test="$srcTag = '220' or $srcTag = '720' or $srcTag = '420'">
                    <xsl:choose>
                        <xsl:when test="$dstTag = '100' or $dstTag = '400'">
                            <!--100 ind2= ' '  /  400 ind2= ' '-->
                            <xsl:text> </xsl:text>
                        </xsl:when>
                        <xsl:otherwise>
                            <!--700 ind2 =  4 -->
                            <xsl:text>4</xsl:text>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:when>
                <!-- ind2 <=  240 / 740  / 440-->
                <xsl:when test="$srcTag = '240' or $srcTag = '740' or $srcTag = '440'">
                    <!--100 ind2= ' ' / 700 ind2= ' ' / 400 ind2= ' ' -->
                    <xsl:text> </xsl:text>
                </xsl:when>
            </xsl:choose>
        </xsl:variable>
        <!-- construction de la sous-zone $a via une variable $sza-->
        <datafield ind1="{$destInd1}" ind2="{$destInd2}" tag="{$dstTag}">
            <!-- $a  -->
            <xsl:if test="subfield[@code = 'a'] != ''">
                <subfield code="a">
                    <!--template z00z20z40_SZ_a pour construire la sous-zone $a dans les zones Z00 / Z20 / Z40 -->
                    <xsl:call-template name="z00z20z40_SZ_a">
                        <xsl:with-param name="srcTag" select="$srcTag"/>
                    </xsl:call-template>
                </subfield>
            </xsl:if>
            <!-- $b <=  200$d / 700$d / 400$d -->
            <xsl:if
                test="($srcTag = '200' or $srcTag = '700' or $srcTag = '400') and subfield[@code = 'd'] != ''">
                <subfield code="b">
                    <xsl:value-of select="subfield[@code = 'd']"/>
                </subfield>
            </xsl:if>
            <!-- $c  -->
            <!--template z00z20z40_SZ_c pour construire la sous-zone $c dans les zones Z00 / Z20 / Z40 -->
            <xsl:call-template name="z00z20z40_SZ_c">
                <xsl:with-param name="srcTag" select="$srcTag"/>
            </xsl:call-template>
            <!-- $d-->
            <!-- $d <= 200$f / 700$f /  400$f  / 220$f / 720$f  / 420$f    -->
            <xsl:choose>
                <!-- quand $f existe-->
                <xsl:when
                    test="($srcTag = '200' or $srcTag = '700' or $srcTag = '400' or $srcTag = '220' or $srcTag = '720' or $srcTag = '420') and subfield[@code = 'f']">
                    <subfield code="d">
                        <xsl:value-of select="subfield[@code = 'f']"/>
                    </subfield>
                </xsl:when>
                <!-- et pour 400 et 420 si pas de $f on prend, via la variable $date_szf  passée en paramètre, la valeur :
                    du 200$f (pour une 400) ie z2XX_liee='200'
                    du 220$f (pour une 420) ie z2XX_liee='220'-->
                <xsl:when
                    test="$srcTag = '400' and not(subfield[@code = 'f']) and $z2XX_liee = '200' and $date_szf != ''">
                    <subfield code="d">
                        <xsl:value-of select="$date_szf"/>
                    </subfield>
                </xsl:when>
                <xsl:when
                    test="$srcTag = '420' and not(subfield[@code = 'f']) and $z2XX_liee = '220' and $date_szf != ''">
                    <subfield code="d">
                        <xsl:value-of select="$date_szf"/>
                    </subfield>
                </xsl:when>
            </xsl:choose>
            <!-- $d <= segment entre ( et ) ou entre ( et  ; de 240$a / 740$a   / 440$a-->
            <xsl:if
                test="($srcTag = '240' or $srcTag = '740' or $srcTag = '440') and contains(subfield[@code = 'a'], '(')">
                <subfield code="d">
                    <xsl:choose>
                        <xsl:when test="contains(subfield[@code = 'a'], ';')">
                            <xsl:value-of
                                select="normalize-space(substring-before(substring-after(subfield[@code = 'a'], '('), ';'))"
                            />
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:value-of
                                select="normalize-space(substring-before(substring-after(subfield[@code = 'a'], '('), ')'))"
                            />
                        </xsl:otherwise>
                    </xsl:choose>
                </subfield>
            </xsl:if>
            <!-- $q <= 200$g / 700$g  / 400$g   -->
            <xsl:if
                test="($srcTag = '200' or $srcTag = '700' or $srcTag = '400') and subfield[@code = 'g'] != ''">
                <subfield code="q">
                    <xsl:value-of select="subfield[@code = 'g']"/>
                </subfield>
            </xsl:if>
            <!-- $t <= 240$t / 740$t  / 440$t   -->
            <xsl:if
                test="($srcTag = '240' or $srcTag = '740' or $srcTag = '440') and subfield[@code = 't'] != ''">
                <subfield code="t">
                    <xsl:value-of select="subfield[@code = 't']"/>
                </subfield>
            </xsl:if>
            <!-- $x / $y / $z  -->
            <!--template sous-zones : $x$y$z-->
            <xsl:call-template name="SZ_xyz"/>
            <!--template sous-zones SZ_w4i : 
           pour les 7XX (retoquée) $4 = paaenl  
            +
            pour 7XX natives / 4XX / 5XX : si $5 unimarc 
                        == > $w = r  
                                  $4 = $5
                                  $i =  $5 décodée
            +
            pour 4XX $0 R => $i R
            -->
            <xsl:call-template name="SZ_w4i">
                <xsl:with-param name="dstTag" select="$dstTag"/>
                <xsl:with-param name="srcTag" select="$srcTag"/>
            </xsl:call-template>
        </datafield>
        <!-- ERM le 09/07/20 : AUTO-RAPPEL de  Z_PT_ACCES_2or400_20_40 pour traiter les 4XX
                   AU MOMENT DE LA CREATION DE LA  2XX -> 100  :            
                * création de la variable date_szf 
                   si point départ pour les 4XX est la 200 -> 100 : alimentation avec 200$f au cas où la 400 traitée par Z_PT_ACCES_2or400_20_40 n'en aurait pas => z2XX_liee = 200
                ou
                   si point départ pour les 4XX est la 220 -> 100 : alimentation avec 220$f au cas où la 420 traitée par Z_PT_ACCES_2or400_20_40 n'en aurait pas => z2XX_liee = 220
                ou 
                 si point départ pour les 4XX est la 240 -> 100 : la variable  date_szf est vide
                
                * appel du template Z_PT_ACCES_2or400_20_40 avec les paramètres :
                - srcTag = @tag soit 400 ou 420 ou 440
                - type ="'400'"  qui permet de déterminer $dstTag = 400     
                - date_szf qui vaut si 200$f ou 220$f (rien en cas de 240)
                - z2XX_liee qui vaut 200 ou 220 ou 240
                -->
        <xsl:if test="$dstTag = '100'">
            <xsl:variable name="date_szf" select="subfield[@code = 'f']"/>
            <xsl:variable name="z2XX_liee" select="@tag"/>
            <!-- 400 <= 400 / 420 / 440 -->
            <xsl:for-each
                select="//datafield[@tag = '400'] | //datafield[@tag = '420'] | //datafield[@tag = '440']">
                <xsl:call-template name="Z_PT_ACCES_2or4or700_20_40">
                    <xsl:with-param name="srcTag" select="@tag"/>
                    <xsl:with-param name="type" select="'400'"/>
                    <xsl:with-param name="date_szf" select="$date_szf"/>
                    <xsl:with-param name="z2XX_liee" select="$z2XX_liee"/>
                </xsl:call-template>
            </xsl:for-each>
        </xsl:if>
    </xsl:template>
    <xsl:template name="Z_PT_ACCES_2or4or710_11">
        <xsl:param name="srcTag"/>
        <xsl:param name="type"/>
        <xsl:param name="position"/>
        <xsl:param name="nb2XX"/>
        <xsl:param name="nbsz7_ba"/>
        <xsl:variable name="ind1" select="@ind1"/>
        <xsl:variable name="ind2" select="@ind2"/>
        <xsl:variable name="sz7_pos5-6" select="substring(subfield[@code = '7'], 5, 2)"/>
        <!-- ERM : algo qui permet de déterminer pour les 2XX / 7XX / 4XX quelle est la zone de destination marc21
            * quelle 210 @ind1=0 > 110 ou quelle  210 @ind1=1  > 111 ?
            * quelle 210 @ind1=0 > 710 ou quelle  210 @ind1=1  > 711 ? (= les  retoquées)
            * 710 @ind1=0 > 710 ou quelle  710 @ind1=1  > 711 
            * 410 @ind1=0 > 410 ou quelle  410 @ind1=1  > 411 
     voir l'algo dans Z_PT_ACCES_2or4or700_20_40
        -->
        <xsl:variable name="dstTag">
            <xsl:choose>
                <!-- cas des 710 natives et 410-->
                <xsl:when test="$type != ''">
                    <xsl:value-of select="$type"/>
                </xsl:when>
                <!--  pour déterminer quelle 210 ira en 110 ou en 111-->
                <xsl:when test="$nb2XX = 1">
                    <xsl:value-of select="concat('11', @ind1)"/>
                </xsl:when>
                <xsl:when test="$nb2XX > 1">
                    <xsl:choose>
                        <xsl:when test="$nbsz7_ba = 0">
                            <xsl:choose>
                                <xsl:when test="position() = 1">
                                    <xsl:value-of select="concat('11', @ind1)"/>
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:value-of select="concat('71', @ind1)"/>
                                </xsl:otherwise>
                            </xsl:choose>
                        </xsl:when>
                        <xsl:when test="$nbsz7_ba = 1">
                            <xsl:choose>
                                <xsl:when test="$sz7_pos5-6 = 'ba'">
                                    <xsl:value-of select="concat('11', @ind1)"/>
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:value-of select="concat('71', @ind1)"/>
                                </xsl:otherwise>
                            </xsl:choose>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:choose>
                                <xsl:when
                                    test="$sz7_pos5-6 = 'ba' and not(preceding-sibling::datafield[@tag = $srcTag]/subfield[@code = '7'][substring(text(), 5, 2) = 'ba'])">
                                    <xsl:value-of select="concat('11', @ind1)"/>
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:value-of select="concat('71', @ind1)"/>
                                </xsl:otherwise>
                            </xsl:choose>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:when>
            </xsl:choose>
        </xsl:variable>
        <!-- construction de ind1 via une variable $destInd1-->
        <xsl:variable name="destInd1">
            <xsl:choose>
                <!--210 / 410 / 710 <= 210 / 410 / 710 @ind1=0  
                    ind1 vaut @ind2 unimarc sauf si ' ' alors vaut 2
                      211 / 411 / 711 <= 210 / 410 / 710 @ind1=1
                    vaut toujours 2-->
                <xsl:when test="@ind1 = '0' and @ind2 != ' '">
                    <xsl:value-of select="$ind2"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:text>2</xsl:text>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <!-- construction de ind2 via une variable $destInd2-->
        <xsl:variable name="destInd2" select="' '"/>
        <datafield ind1="{$destInd1}" ind2="{$destInd2}" tag="{$dstTag}">
            <!-- $a <= 210$a / 410$a / 710$a -->
            <xsl:if test="subfield[@code = 'a'] != ''">
                <subfield code="a">
                    <xsl:value-of select="subfield[@code = 'a']"/>
                </subfield>
            </xsl:if>
            <!-- séquence unimarc répétable sans ordre pré-établi  ($b* | $c* | $d* | $e | $f)*  à rendre en marc21 avec les mêmes répétitions dans le même ordre
                - uni $b ind1=0 * > m21 $b* X10  |   uni  $b ind1=1 * > m21 $e* X11
                - uni   $c * > m21 $g*    
                - uni   $d  * > m21 $n* 
                - uni   $e   > m21 $c    
                - uni   $f   > m21 $d 
            -->
            <xsl:for-each
                select="subfield[@code = 'b'][text() != ''] | subfield[@code = 'c'][text() != ''] | subfield[@code = 'd'][text() != ''] | subfield[@code = 'e'][text() != ''] | subfield[@code = 'f'][text() != '']">
                <xsl:choose>
                    <xsl:when test="parent::node()/@ind1 = '0' and @code = 'b'">
                        <subfield code="b">
                            <xsl:value-of select="."/>
                        </subfield>
                    </xsl:when>
                    <xsl:when test="parent::node()/@ind1 = '1' and @code = 'b'">
                        <subfield code="e">
                            <xsl:value-of select="."/>
                        </subfield>
                    </xsl:when>
                    <xsl:when test="@code = 'c'">
                        <subfield code="g">
                            <xsl:value-of select="."/>
                        </subfield>
                    </xsl:when>
                    <xsl:when test="@code = 'd'">
                        <subfield code="n">
                            <xsl:value-of select="."/>
                        </subfield>
                    </xsl:when>
                    <xsl:when test="@code = 'e'">
                        <subfield code="c">
                            <xsl:value-of select="."/>
                        </subfield>
                    </xsl:when>
                    <xsl:when test="@code = 'f'">
                        <subfield code="d">
                            <xsl:value-of select="."/>
                        </subfield>
                    </xsl:when>
                </xsl:choose>
            </xsl:for-each>
            <!--TODO-->
            <!-- uni   $g   > m21     -->
            <!-- uni   $h   > m21     -->
            <!-- $x / $y / $z  -->
            <!--template sous-zones : $x$y$z-->
            <xsl:call-template name="SZ_xyz"/>
            <!--template sous-zones SZ_w4i : 
           pour les 7XX (retoquée) $4 = paaenl  
            +
            pour 7XX natives / 4XX / 5XX : si $5 unimarc 
                        == > $w = r  
                                  $4 = $5
                                  $i =  $5 décodée
            +
            pour 4XX $0 R => $i R
    -->
            <xsl:call-template name="SZ_w4i">
                <xsl:with-param name="dstTag" select="$dstTag"/>
                <xsl:with-param name="srcTag" select="$srcTag"/>
            </xsl:call-template>
        </datafield>
    </xsl:template>
    <xsl:template name="Z_PT_ACCES_215_415_715">
        <xsl:param name="srcTag"/>
        <xsl:param name="type"/>
        <xsl:param name="position"/>
        <xsl:param name="nb2XX"/>
        <xsl:param name="nbsz7_ba"/>
        <xsl:variable name="ind1" select="@ind1"/>
        <xsl:variable name="ind2" select="@ind2"/>
        <xsl:variable name="sz7_pos5-6" select="substring(subfield[@code = '7'], 5, 2)"/>
        <!-- ERM : algo qui permet de déterminer pour les 2XX / 7XX / 4XX quelle est la zone de destination marc21
            * quelle 215 > 151 ?
            * quelle 215 > 751 = les 215 retoquées 
            * 715 natives > 751 
            * 415 > 451
     voir l'algo dans Z_PT_ACCES_2or4or700_20_40
        -->
        <xsl:variable name="dstTag">
            <xsl:choose>
                <!-- cas des 715 natives et 415-->
                <xsl:when test="$type != ''">
                    <xsl:value-of select="$type"/>
                </xsl:when>
                <!--  pour déterminer quelle 215 ira en 151-->
                <xsl:when test="$nb2XX = 1">151</xsl:when>
                <xsl:when test="$nb2XX > 1">
                    <xsl:choose>
                        <xsl:when test="$nbsz7_ba = 0">
                            <xsl:choose>
                                <xsl:when test="position() = 1">151</xsl:when>
                                <xsl:otherwise>751</xsl:otherwise>
                            </xsl:choose>
                        </xsl:when>
                        <xsl:when test="$nbsz7_ba = 1">
                            <xsl:choose>
                                <xsl:when test="$sz7_pos5-6 = 'ba'">151</xsl:when>
                                <xsl:otherwise>751</xsl:otherwise>
                            </xsl:choose>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:choose>
                                <xsl:when
                                    test="$sz7_pos5-6 = 'ba' and not(preceding-sibling::datafield[@tag = $srcTag]/subfield[@code = '7'][substring(text(), 5, 2) = 'ba'])"
                                    >151</xsl:when>
                                <xsl:otherwise>751</xsl:otherwise>
                            </xsl:choose>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:when>
            </xsl:choose>
        </xsl:variable>
        <!-- construction de ind1 via une variable $destInd1-->
        <xsl:variable name="destInd1" select="$ind1"/>
        <!-- construction de ind2 via une variable $destInd2-->
        <xsl:variable name="destInd2">
            <xsl:choose>
                <!-- ind2 <=  715 -->
                <xsl:when test="$dstTag = '751'">
                    <xsl:text>4</xsl:text>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="$ind2"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <datafield ind1="{$destInd1}" ind2="{$destInd2}" tag="{$dstTag}">
            <!-- $a <= 215$a / 415$a / 715$a -->
            <xsl:if test="subfield[@code = 'a'] != ''">
                <subfield code="a">
                    <xsl:value-of select="subfield[@code = 'a']"/>
                </subfield>
            </xsl:if>
            <!-- $x / $y / $z  -->
            <!--template sous-zones : $x$y$z-->
            <xsl:call-template name="SZ_xyz"/>
            <!--template sous-zones SZ_w4i : 
           pour les 7XX (retoquée) $4 = paaenl  
            +
            pour 7XX natives / 4XX / 5XX : si $5 unimarc 
                        == > $w = r  
                                  $4 = $5
                                  $i =  $5 décodée
            +
            pour 4XX $0 R => $i R
    -->
            <xsl:call-template name="SZ_w4i">
                <xsl:with-param name="dstTag" select="$dstTag"/>
                <xsl:with-param name="srcTag" select="$srcTag"/>
            </xsl:call-template>
        </datafield>
    </xsl:template>
    <xsl:template name="Z_PT_ACCES_230_430_730">
        <xsl:param name="srcTag"/>
        <xsl:param name="type"/>
        <xsl:param name="position"/>
        <xsl:param name="nb2XX"/>
        <xsl:param name="nbsz7_ba"/>
        <xsl:variable name="ind1" select="@ind1"/>
        <xsl:variable name="ind2" select="@ind2"/>
        <xsl:variable name="sz7_pos5-6" select="substring(subfield[@code = '7'], 5, 2)"/>
        <!-- ERM : algo qui permet de déterminer pour les 2XX / 7XX / 4XX quelle est la zone de destination marc21
            * quelle 230 > 130 ?
            * quelle 230 > 730 = les 230 retoquées 
            * 730 natives > 730 
            * 430 > 430
     voir l'algo dans Z_PT_ACCES_2or4or700_20_40
        -->
        <xsl:variable name="dstTag">
            <xsl:choose>
                <!-- cas des 730 natives et 430-->
                <xsl:when test="$type != ''">
                    <xsl:value-of select="$type"/>
                </xsl:when>
                <!--  pour déterminer quelle 230 ira en 130-->
                <xsl:when test="$nb2XX = 1">130</xsl:when>
                <xsl:when test="$nb2XX > 1">
                    <xsl:choose>
                        <xsl:when test="$nbsz7_ba = 0">
                            <xsl:choose>
                                <xsl:when test="position() = 1">130</xsl:when>
                                <xsl:otherwise>730</xsl:otherwise>
                            </xsl:choose>
                        </xsl:when>
                        <xsl:when test="$nbsz7_ba = 1">
                            <xsl:choose>
                                <xsl:when test="$sz7_pos5-6 = 'ba'">130</xsl:when>
                                <xsl:otherwise>730</xsl:otherwise>
                            </xsl:choose>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:choose>
                                <xsl:when
                                    test="$sz7_pos5-6 = 'ba' and not(preceding-sibling::datafield[@tag = $srcTag]/subfield[@code = '7'][substring(text(), 5, 2) = 'ba'])"
                                    >130</xsl:when>
                                <xsl:otherwise>730</xsl:otherwise>
                            </xsl:choose>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:when>
            </xsl:choose>
        </xsl:variable>
        <!-- construction de ind1 via une variable $destInd1-->
        <xsl:variable name="destInd1" select="$ind1"/>
        <!-- construction de ind2 via une variable $destInd2-->
        <xsl:variable name="destInd2">
            <xsl:choose>
                <!-- ind2 pour 130 et 430 -->
                <xsl:when test="$dstTag = '130' or $dstTag = '430'">
                    <xsl:text>0</xsl:text>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="4"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <datafield ind1="{$destInd1}" ind2="{$destInd2}" tag="{$dstTag}">
            <!-- $a <= 230$a / 430$a / 730$a -->
            <xsl:if test="subfield[@code = 'a'] != ''">
                <subfield code="a">
                    <xsl:value-of select="subfield[@code = 'a']"/>
                </subfield>
            </xsl:if>
            <!-- $n*<= 230$h* / 430$h* / 730$h* -->
            <xsl:for-each select="subfield[@code = 'h'][text() != '']">
                <subfield code="n">
                    <xsl:value-of select="."/>
                </subfield>
            </xsl:for-each>
            <!-- $p*<= 230$i* / 430$i* / 730$i* -->
            <xsl:for-each select="subfield[@code = 'i'][text() != '']">
                <subfield code="p">
                    <xsl:value-of select="."/>
                </subfield>
            </xsl:for-each>
            <!-- $f <= 230$k / 430$k / 730$k -->
            <xsl:if test="subfield[@code = 'k'] != ''">
                <subfield code="f">
                    <xsl:value-of select="subfield[@code = 'k']"/>
                </subfield>
            </xsl:if>
            <!-- $k <= 230$l / 430$l / 730$l -->
            <xsl:if test="subfield[@code = 'l'] != ''">
                <subfield code="k">
                    <xsl:value-of select="subfield[@code = 'l']"/>
                </subfield>
            </xsl:if>
            <!-- $l <= 230$m / 430$m/ 730$m -->
            <xsl:if test="subfield[@code = 'm'] != ''">
                <subfield code="l">
                    <xsl:value-of select="subfield[@code = 'm']"/>
                </subfield>
            </xsl:if>
            <!-- $g*<= 230$n* / 430$n* / 730$n* -->
            <xsl:for-each select="subfield[@code = 'n'][text() != '']">
                <subfield code="g">
                    <xsl:value-of select="."/>
                </subfield>
            </xsl:for-each>
            <!-- $s <= 230$q / 430$q/ 730$q -->
            <xsl:if test="subfield[@code = 'q'] != ''">
                <subfield code="s">
                    <xsl:value-of select="subfield[@code = 'q']"/>
                </subfield>
            </xsl:if>
            <!-- $m*<= 230$r* / 430$r* / 730$r* -->
            <xsl:for-each select="subfield[@code = 'r'][text() != '']">
                <subfield code="m">
                    <xsl:value-of select="."/>
                </subfield>
            </xsl:for-each>
            <!-- $n*<= 230$s* / 430$s* / 730$s* -->
            <xsl:for-each select="subfield[@code = 's'][text() != '']">
                <subfield code="n">
                    <xsl:value-of select="."/>
                </subfield>
            </xsl:for-each>
            <!-- $r <= 230$u / 430$u/ 730$u -->
            <xsl:if test="subfield[@code = 'u'] != ''">
                <subfield code="r">
                    <xsl:value-of select="subfield[@code = 'u']"/>
                </subfield>
            </xsl:if>
            <!-- $x / $y / $z  -->
            <!--template sous-zones : $x$y$z-->
            <xsl:call-template name="SZ_xyz"/>
            <!--template sous-zones SZ_w4i : 
           pour les 7XX (retoquée) $4 = paaenl  
            +
            pour 7XX natives / 4XX / 5XX : si $5 unimarc 
                        == > $w = r  
                                  $4 = $5
                                  $i =  $5 décodée
            +
            pour 4XX $0 R => $i R
    -->
            <xsl:call-template name="SZ_w4i">
                <xsl:with-param name="dstTag" select="$dstTag"/>
                <xsl:with-param name="srcTag" select="$srcTag"/>
            </xsl:call-template>
        </datafield>
    </xsl:template>
    <!-- AJO 20/07: 250/450/750 -->
    <xsl:template name="Z_PT_ACCES_250_450_750">
        <xsl:param name="srcTag"/>
        <xsl:param name="type"/>
        <xsl:param name="position"/>
        <xsl:param name="nb2XX"/>
        <xsl:param name="nbsz7_ba"/>
        <xsl:variable name="ind1" select="@ind1"/>
        <xsl:variable name="ind2" select="@ind2"/>
        <xsl:variable name="sz7_pos5-6" select="substring(subfield[@code = '7'], 5, 2)"/>
        <!-- ERM : algo qui permet de déterminer pour les 2XX / 7XX / 4XX quelle est la zone de destination marc21
            * quelle 250 > 150 ?
            * quelle 250 > 750 = les 250 retoquées ()
            * 750 natives > 750
            * 450 > 450
     voir l'algo dans Z_PT_ACCES_2or4or700_20_40
        -->
        <xsl:variable name="dstTag">
            <xsl:choose>
                <!-- cas des 750 natives et 450-->
                <xsl:when test="$type != ''">
                    <xsl:value-of select="$type"/>
                </xsl:when>
                <!--  pour déterminer quelle 250 ira en 150-->
                <xsl:when test="$nb2XX = 1">150</xsl:when>
                <xsl:when test="$nb2XX > 1">
                    <xsl:choose>
                        <xsl:when test="$nbsz7_ba = 0">
                            <xsl:choose>
                                <xsl:when test="position() = 1">150</xsl:when>
                                <xsl:otherwise>750</xsl:otherwise>
                            </xsl:choose>
                        </xsl:when>
                        <xsl:when test="$nbsz7_ba = 1">
                            <xsl:choose>
                                <xsl:when test="$sz7_pos5-6 = 'ba'">150</xsl:when>
                                <xsl:otherwise>750</xsl:otherwise>
                            </xsl:choose>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:choose>
                                <xsl:when
                                    test="$sz7_pos5-6 = 'ba' and not(preceding-sibling::datafield[@tag = $srcTag]/subfield[@code = '7'][substring(text(), 5, 2) = 'ba'])"
                                    >150</xsl:when>
                                <xsl:otherwise>750</xsl:otherwise>
                            </xsl:choose>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:when>
            </xsl:choose>
        </xsl:variable>
        <!-- construction de ind1 via une variable $destInd1-->
        <xsl:variable name="destInd1" select="$ind1"/>
        <!-- construction de ind2 via une variable $destInd2-->
        <xsl:variable name="destInd2">
            <xsl:choose>
                <!-- ind2 <=  750 -->
                <xsl:when test="$dstTag = '750'">
                    <xsl:text>4</xsl:text>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="$ind2"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <datafield ind1="{$destInd1}" ind2="{$destInd2}" tag="{$dstTag}">
            <!-- $a <= 250$a / 450$a / 750$a -->
            <xsl:if test="subfield[@code = 'a'] != ''">
                <subfield code="a">
                    <xsl:value-of select="subfield[@code = 'a']"/>
                </subfield>
            </xsl:if>
            <!-- $x / $y / $z  -->
            <!--template sous-zones : $x$y$z-->
            <xsl:call-template name="SZ_xyz"/>
            <!--template sous-zones SZ_w4i : 
           pour les 7XX (retoquée) $4 = paaenl  
            +
            pour 7XX natives / 4XX / 5XX : si $5 unimarc 
                        == > $w = r  
                                  $4 = $5
                                  $i =  $5 décodée
            +
            pour 4XX $0 R => $i R
    -->
            <xsl:call-template name="SZ_w4i">
                <xsl:with-param name="dstTag" select="$dstTag"/>
                <xsl:with-param name="srcTag" select="$srcTag"/>
            </xsl:call-template>
        </datafield>
    </xsl:template>
    <!-- AJO 20/07: 280/480/780 -->
    <xsl:template name="Z_PT_ACCES_280_480_780">
        <xsl:param name="srcTag"/>
        <xsl:param name="type"/>
        <xsl:param name="position"/>
        <xsl:param name="nb2XX"/>
        <xsl:param name="nbsz7_ba"/>
        <xsl:variable name="ind1" select="@ind1"/>
        <xsl:variable name="ind2" select="@ind2"/>
        <xsl:variable name="sz7_pos5-6" select="substring(subfield[@code = '7'], 5, 2)"/>
        <!-- ERM : algo qui permet de déterminer pour les 2XX / 7XX / 4XX quelle est la zone de destination marc21
            * quelle 280 > 155 ?
            * quelle 280 > 755 = les 280 retoquées ()
            * 780 natives > 780
            * 480 > 455
     voir l'algo dans Z_PT_ACCES_2or4or700_20_40
        -->
        <xsl:variable name="dstTag">
            <xsl:choose>
                <!-- cas des 780 natives et 480-->
                <xsl:when test="$type != ''">
                    <xsl:value-of select="$type"/>
                </xsl:when>
                <!--  pour déterminer quelle 280 ira en 155-->
                <xsl:when test="$nb2XX = 1">155</xsl:when>
                <xsl:when test="$nb2XX > 1">
                    <xsl:choose>
                        <xsl:when test="$nbsz7_ba = 0">
                            <xsl:choose>
                                <xsl:when test="position() = 1">155</xsl:when>
                                <xsl:otherwise>755</xsl:otherwise>
                            </xsl:choose>
                        </xsl:when>
                        <xsl:when test="$nbsz7_ba = 1">
                            <xsl:choose>
                                <xsl:when test="$sz7_pos5-6 = 'ba'">155</xsl:when>
                                <xsl:otherwise>755</xsl:otherwise>
                            </xsl:choose>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:choose>
                                <xsl:when
                                    test="$sz7_pos5-6 = 'ba' and not(preceding-sibling::datafield[@tag = $srcTag]/subfield[@code = '7'][substring(text(), 5, 2) = 'ba'])"
                                    >155</xsl:when>
                                <xsl:otherwise>755</xsl:otherwise>
                            </xsl:choose>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:when>
            </xsl:choose>
        </xsl:variable>
        <!-- construction de ind1 via une variable $destInd1-->
        <xsl:variable name="destInd1" select="$ind1"/>
        <!-- construction de ind2 via une variable $destInd2-->
        <xsl:variable name="destInd2">
            <xsl:choose>
                <!-- ind2 <=  755 -->
                <xsl:when test="$dstTag = '755'">
                    <xsl:text>4</xsl:text>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="$ind2"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <datafield ind1="{$destInd1}" ind2="{$destInd2}" tag="{$dstTag}">
            <!-- $a <= 280$a / 480$a / 780$a -->
            <xsl:if test="subfield[@code = 'a'] != ''">
                <subfield code="a">
                    <xsl:value-of select="subfield[@code = 'a']"/>
                </subfield>
            </xsl:if>
            <!-- $x / $y / $z  -->
            <!--template sous-zones : $x$y$z-->
            <xsl:call-template name="SZ_xyz"/>
            <!--template sous-zones SZ_w4i : 
           pour les 7XX (retoquée) $4 = paaenl  
            +
            pour 7XX natives / 4XX / 5XX : si $5 unimarc 
                        == > $w = r  
                                  $4 = $5
                                  $i =  $5 décodée
            +
            pour 4XX $0 R => $i R
    -->
            <xsl:call-template name="SZ_w4i">
                <xsl:with-param name="dstTag" select="$dstTag"/>
                <xsl:with-param name="srcTag" select="$srcTag"/>
            </xsl:call-template>
        </datafield>
    </xsl:template>
    <xsl:template name="Z_PT_ACCES_500_20_40">
        <xsl:param name="srcTag"/>
        <xsl:variable name="ind1" select="@ind1"/>
        <xsl:variable name="ind2" select="@ind2"/>
        <xsl:variable name="dstTag" select="'500'"/>
        <!-- construction de ind1 via une variable $destInd1-->
        <xsl:variable name="destInd1">
            <xsl:choose>
                <!-- ind1 <=  500 ind2 -->
                <xsl:when test="$srcTag = '500'">
                    <xsl:value-of select="$ind2"/>
                </xsl:when>
                <!-- ind1 = 3<=  520 -->
                <xsl:when test="$srcTag = '520'">
                    <xsl:text>3</xsl:text>
                </xsl:when>
                <!-- ind1 = 1<=  540 -->
                <xsl:when test="$srcTag = '540'">
                    <xsl:text>1</xsl:text>
                </xsl:when>
            </xsl:choose>
        </xsl:variable>
        <!-- construction de ind2 via une variable $destInd2-->
        <xsl:variable name="destInd2">
            <xsl:choose>
                <!-- ind2 <=  500 ind1-->
                <xsl:when test="$srcTag = '500'">
                    <xsl:value-of select="$ind1"/>
                </xsl:when>
                <!-- ind2 = ' ' <=  520 / 540 -->
                <xsl:otherwise>
                    <xsl:text> </xsl:text>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <datafield ind1="{$destInd1}" ind2="{$destInd2}" tag="{$dstTag}">
            <!--template sous-zones SZ_w4i : 
           pour 5XX 
                       $0 R => $i R
                       $3 => $0 (IDREF)$3
            +
            pour 7XX natives / 4XX / 5XX : si $5 unimarc 
                        == > $w = r  
                                  $4 = $5
                                  $i =  $5 décodée
             -->
            <xsl:call-template name="SZ_w4i">
                <xsl:with-param name="dstTag" select="$dstTag"/>
                <xsl:with-param name="srcTag" select="$srcTag"/>
            </xsl:call-template>
            <xsl:if test="subfield[@code = 'a'] != ''">
                <subfield code="a">
                    <!--template z00z20z40_SZ_a pour construire la sous-zone $a dans les zones Z00 / Z20 / Z40 -->
                    <xsl:call-template name="z00z20z40_SZ_a">
                        <xsl:with-param name="srcTag" select="$srcTag"/>
                    </xsl:call-template>
                </subfield>
            </xsl:if>
            <!-- $b <=  500$d -->
            <xsl:if test="($srcTag = '500') and subfield[@code = 'd'] != ''">
                <subfield code="b">
                    <xsl:value-of select="subfield[@code = 'd']"/>
                </subfield>
            </xsl:if>
            <!-- $c  -->
            <!--template z00z20z40_SZ_c pour construire la sous-zone $c dans les zones Z00 / Z20 / Z40 -->
            <xsl:call-template name="z00z20z40_SZ_c">
                <xsl:with-param name="srcTag" select="$srcTag"/>
            </xsl:call-template>
            <!-- $d-->
            <!-- $d <= 500$f /  520$f     -->
            <xsl:if test="($srcTag = '500' or $srcTag = '520') and subfield[@code = 'f']">
                <subfield code="d">
                    <xsl:value-of select="subfield[@code = 'f']"/>
                </subfield>
            </xsl:if>
            <!-- $d <= segment entre ( et ) ou entre ( et  ; de 540$a-->
            <xsl:if test="$srcTag = '540' and contains(subfield[@code = 'a'], '(')">
                <subfield code="d">
                    <xsl:choose>
                        <xsl:when test="contains(subfield[@code = 'a'], ';')">
                            <xsl:value-of
                                select="normalize-space(substring-before(substring-after(subfield[@code = 'a'], '('), ';'))"
                            />
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:value-of
                                select="normalize-space(substring-before(substring-after(subfield[@code = 'a'], '('), ')'))"
                            />
                        </xsl:otherwise>
                    </xsl:choose>
                </subfield>
            </xsl:if>
            <!-- $q <= 500$g  -->
            <xsl:if test="$srcTag = '500' and subfield[@code = 'g'] != ''">
                <subfield code="q">
                    <xsl:value-of select="subfield[@code = 'g']"/>
                </subfield>
            </xsl:if>
            <!-- $t <= 540$t   -->
            <xsl:if test="$srcTag = '540' and subfield[@code = 't'] != ''">
                <subfield code="t">
                    <xsl:value-of select="subfield[@code = 't']"/>
                </subfield>
            </xsl:if>
            <!-- $x / $y / $z  -->
            <!--template sous-zones : $x$y$z-->
            <xsl:call-template name="SZ_xyz"/>
        </datafield>
    </xsl:template>
    <xsl:template name="Z_PT_ACCES_510">
        <xsl:param name="srcTag"/>
        <xsl:variable name="ind1" select="@ind1"/>
        <xsl:variable name="ind2" select="@ind2"/>
        <xsl:variable name="dstTag">
            <xsl:choose>
                <xsl:when test="@ind1 = '0'">510</xsl:when>
                <xsl:otherwise>511</xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <!-- construction de ind1 via une variable $destInd1-->
        <xsl:variable name="destInd1">
            <xsl:choose>
                <!--510 <= 510@ind1=0  
                    ind1 vaut @ind2 unimarc sauf si ' ' alors vaut 2
                      511 <= 510@ind1=1
                    vaut toujours 2-->
                <xsl:when test="@ind1 = '0' and @ind2 != ' '">
                    <xsl:value-of select="$ind2"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:text>2</xsl:text>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <!-- construction de ind2 via une variable $destInd2-->
        <xsl:variable name="destInd2" select="' '"/>
        <datafield ind1="{$destInd1}" ind2="{$destInd2}" tag="{$dstTag}">
            <!--template sous-zones SZ_w4i : 
           pour 5XX 
                       $0 R => $i R
                       $3 => $0 (IDREF)$3
            +
            pour 7XX natives / 4XX / 5XX : si $5 unimarc 
                        == > $w = r  
                                  $4 = $5
                                  $i =  $5 décodée
             -->
            <xsl:call-template name="SZ_w4i">
                <xsl:with-param name="dstTag" select="$dstTag"/>
                <xsl:with-param name="srcTag" select="$srcTag"/>
            </xsl:call-template>
            <!-- $a <= 510$a -->
            <xsl:if test="subfield[@code = 'a'] != ''">
                <subfield code="a">
                    <xsl:value-of select="subfield[@code = 'a']"/>
                </subfield>
            </xsl:if>
            <!-- séquence unimarc répétable sans ordre pré-établi  ($b* | $c* | $d* | $e | $f)*  à rendre en marc21 avec les mêmes répétitions dans le même ordre
                - uni $b ind1=0 * > m21 $b* X10  |   uni  $b ind1=1 * > m21 $e* X11
                - uni   $c * > m21 $g*    
                - uni   $d  * > m21 $n* 
                - uni   $e   > m21 $c    
                - uni   $f   > m21 $d 
            -->
            <xsl:for-each
                select="subfield[@code = 'b'][text() != ''] | subfield[@code = 'c'][text() != ''] | subfield[@code = 'd'][text() != ''] | subfield[@code = 'e'][text() != ''] | subfield[@code = 'f'][text() != '']">
                <xsl:choose>
                    <xsl:when test="parent::node()/@ind1 = '0' and @code = 'b'">
                        <subfield code="b">
                            <xsl:value-of select="."/>
                        </subfield>
                    </xsl:when>
                    <xsl:when test="parent::node()/@ind1 = '1' and @code = 'b'">
                        <subfield code="e">
                            <xsl:value-of select="."/>
                        </subfield>
                    </xsl:when>
                    <xsl:when test="@code = 'c'">
                        <subfield code="g">
                            <xsl:value-of select="."/>
                        </subfield>
                    </xsl:when>
                    <xsl:when test="@code = 'd'">
                        <subfield code="n">
                            <xsl:value-of select="."/>
                        </subfield>
                    </xsl:when>
                    <xsl:when test="@code = 'e'">
                        <subfield code="c">
                            <xsl:value-of select="."/>
                        </subfield>
                    </xsl:when>
                    <xsl:when test="@code = 'f'">
                        <subfield code="d">
                            <xsl:value-of select="."/>
                        </subfield>
                    </xsl:when>
                </xsl:choose>
            </xsl:for-each>
            <!--TODO-->
            <!-- uni   $g   > m21     -->
            <!-- uni   $h   > m21     -->
            <!-- $x / $y / $z  -->
            <!--template sous-zones : $x$y$z-->
            <xsl:call-template name="SZ_xyz"/>
        </datafield>
    </xsl:template>
    <!-- AJO 20/07: 515/550/580 -->
    <xsl:template name="Z_PT_ACCES_515_50_80">
        <xsl:param name="srcTag"/>
        <xsl:variable name="dstTag">
            <xsl:choose>
                <xsl:when test="$srcTag = '515'">
                    <xsl:text>551</xsl:text>
                </xsl:when>
                <xsl:when test="$srcTag = '550'">
                    <xsl:text>550</xsl:text>
                </xsl:when>
                <xsl:when test="$srcTag = '580'">
                    <xsl:text>555</xsl:text>
                </xsl:when>
            </xsl:choose>
        </xsl:variable>
        <datafield ind1=" " ind2=" " tag="{$dstTag}">
            <!--template sous-zones SZ_w4i : 
           pour 5XX 
                       $0 R => $i R
                       $3 => $0 (IDREF)$3
            +
            pour 7XX natives / 4XX / 5XX : si $5 unimarc 
                        == > $w = r  
                                  $4 = $5
                                  $i =  $5 décodée
             -->
            <xsl:call-template name="SZ_w4i">
                <xsl:with-param name="dstTag" select="$dstTag"/>
                <xsl:with-param name="srcTag" select="$srcTag"/>
            </xsl:call-template>
            <!-- $a <= 515$a / 550$a / 580$a -->
            <xsl:if test="subfield[@code = 'a'] != ''">
                <subfield code="a">
                    <xsl:value-of select="subfield[@code = 'a']"/>
                </subfield>
            </xsl:if>
            <!-- $x / $y / $z  -->
            <!--template sous-zones : $x$y$z-->
            <xsl:call-template name="SZ_xyz"/>
        </datafield>
    </xsl:template>
    <!--template z00z20z40_SZ_a pour construire la sous-zone $a dans les zones Z00 / Z20 / Z40 -->
    <xsl:template name="z00z20z40_SZ_a">
        <xsl:param name="srcTag"/>
        <xsl:choose>
            <!-- $a <=  Z00$a [, $b]?  -->
            <xsl:when test="substring($srcTag, 2, 2) = '00'">
                <xsl:value-of select="normalize-space(subfield[@code = 'a'])"/>
                <xsl:if test="subfield[@code = 'b'] != ''">
                    <xsl:value-of select="concat(', ', subfield[@code = 'b'])"/>
                </xsl:if>
            </xsl:when>
            <!-- $a <=  Z20$a [($c? ; $d* ; $f?)?] -->
            <xsl:when test="substring($srcTag, 2, 2) = '20'">
                <xsl:value-of select="normalize-space(subfield[@code = 'a'])"/>
                <xsl:if
                    test="subfield[@code = 'c'] != '' or subfield[@code = 'd'] != '' or subfield[@code = 'f'] != ''">
                    <xsl:text> (</xsl:text>
                    <xsl:for-each
                        select="subfield[@code = 'c'][text() != ''] | subfield[@code = 'd'][text() != ''] | subfield[@code = 'f'][text() != '']">
                        <xsl:sort select="@code"/>
                        <xsl:choose>
                            <xsl:when test="position() != 1">
                                <xsl:text> ; </xsl:text>
                            </xsl:when>
                            <xsl:otherwise/>
                        </xsl:choose>
                        <xsl:value-of select="."/>
                    </xsl:for-each>
                    <xsl:text>)</xsl:text>
                </xsl:if>
            </xsl:when>
            <!-- $a <=  Z40 segment devant ( $a  sinon $a  -->
            <xsl:when test="substring($srcTag, 2, 2) = '40'">
                <xsl:choose>
                    <xsl:when test="contains(subfield[@code = 'a'], '(')">
                        <xsl:value-of
                            select="normalize-space(substring-before(subfield[@code = 'a'], '('))"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="normalize-space(subfield[@code = 'a'])"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:when>
        </xsl:choose>
    </xsl:template>
    <!--template z00z20z40_SZ_a pour construire la sous-zone $c dans les zones Z00 / Z20 / Z40 -->
    <xsl:template name="z00z20z40_SZ_c">
        <xsl:param name="srcTag"/>
        <!-- $c sous-zone répétable <= Z00$c  sous-zone répétable  -->
        <xsl:if test="substring($srcTag, 2, 2) = '00' and subfield[@code = 'c']">
            <xsl:for-each select="subfield[@code = 'c'][text() != '']">
                <subfield code="c">
                    <xsl:value-of select="."/>
                </subfield>
            </xsl:for-each>
        </xsl:if>
        <!-- $c <= segment entre ; et ) de Z40$a  -->
        <xsl:if test="substring($srcTag, 2, 2) = '40' and contains(subfield[@code = 'a'], ';')">
            <subfield code="c">
                <xsl:value-of
                    select="normalize-space(substring-before(substring-after(subfield[@code = 'a'], ';'), ')'))"
                />
            </subfield>
        </xsl:if>
    </xsl:template>
    <!--template sous-zones SZ_xyz : $x$y$z-->
    <xsl:template name="SZ_xyz">
        <!-- $x sous-zone répétable <= $x sous-zone répétable -->
        <xsl:for-each select="subfield[@code = 'x'][text() != '']">
            <subfield code="x">
                <xsl:value-of select="."/>
            </subfield>
        </xsl:for-each>
        <!-- $y sous-zone répétable <= $z sous-zone répétable -->
        <xsl:for-each select="subfield[@code = 'z'][text() != '']">
            <subfield code="y">
                <xsl:value-of select="."/>
            </subfield>
        </xsl:for-each>
        <!-- $z sous-zone répétable <= $y sous-zone répétable -->
        <xsl:for-each select="subfield[@code = 'y'][text() != '']">
            <subfield code="z">
                <xsl:value-of select="."/>
            </subfield>
        </xsl:for-each>
    </xsl:template>
    <!--template sous-zones SZ_w4i : 
           pour 5XX 
                       $0 R => $i R
                       $3 => $0 (IDREF)$3
            +
            pour les 7XX (retoquée) $4 = paaenl  
            +
            pour 7XX natives / 4XX / 5XX : si $5 unimarc 
                        == > $w = r  
                                  $4 = $5
                                  $i =  $5 décodée
            +
            pour 4XX $0 R => $i R
    -->
    <xsl:template name="SZ_w4i">
        <xsl:param name="dstTag"/>
        <xsl:param name="srcTag"/>
        <!--$4 = paaenl  pour les 2XX orientées en 7XX -->
        <xsl:if test="starts-with($dstTag, '7') and starts-with($srcTag, '2')">
            <subfield code="4">
                <xsl:text>paaenl</xsl:text>
            </subfield>
        </xsl:if>
        <xsl:if test="starts-with($dstTag, '5')">
            <xsl:for-each select="subfield[@code = '0'][text() != '']">
                <subfield code="i">
                    <xsl:value-of select="."/>
                </subfield>
            </xsl:for-each>
            <xsl:if
                test="subfield[@code = '3'][text() != ''] or subfield[@code = 'Q'][text() != '']"/>
            <subfield code="0">
                <xsl:choose>
                    <xsl:when test="subfield[@code = '3'][text() != '']">
                        <xsl:value-of select="concat('(IDREF)', subfield[@code = '3'])"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="subfield[@code = 'Q']"/>
                    </xsl:otherwise>
                </xsl:choose>
            </subfield>
        </xsl:if>
        <xsl:if
            test="((starts-with($dstTag, '7') and starts-with($srcTag, '7')) or starts-with($dstTag, '4') or starts-with($dstTag, '5')) and subfield[@code = '5'] != ''">
            <!-- $w = r-->
            <subfield code="w">
                <xsl:text>r</xsl:text>
            </subfield>
            <!-- $4 <= $5-->
            <subfield code="4">
                <xsl:value-of select="subfield[@code = '5']"/>
            </subfield>
            <!-- $i = decodage du $5 via template de mapping szi_fromsz5
                nb : $i non généré si $5 vaut  "Autre" soit  codes : "xxz" et "z"-->
            <xsl:if test="not(contains(subfield[@code = '5'], 'z'))">
                <subfield code="i">
                    <xsl:call-template name="szi_fromsz5">
                        <xsl:with-param name="sz5" select="subfield[@code = '5']"/>
                    </xsl:call-template>
                </subfield>
            </xsl:if>
        </xsl:if>
        <!-- 4XX$i sous-zone répétable <= 4XX$0 sous-zone répétable -->
        <xsl:if test="starts-with($dstTag, '4')">
            <xsl:for-each select="subfield[@code = '0'][text() != '']">
                <subfield code="i">
                    <xsl:value-of select="."/>
                </subfield>
            </xsl:for-each>
        </xsl:if>
    </xsl:template>
    <xsl:template name="z680">
        <xsl:param name="srcTag"/>
        <xsl:param name="dstTag" select="@srcTag"/>
        <xsl:for-each select="datafield[@tag = $srcTag]">
            <datafield tag="{$dstTag}">
                <xsl:call-template name="copy-indicators">
                    <xsl:with-param name="dstTag" select="$dstTag"/>
                </xsl:call-template>
                <subfield code="a">
                    <xsl:value-of select="subfield[@code = 'a']"> </xsl:value-of>
                    <xsl:if test="subfield[@code = '2'] != ''">
                        <xsl:value-of select="concat(' - ', subfield[@code = '2'])"/>
                    </xsl:if>
                </subfield>
            </datafield>
        </xsl:for-each>
    </xsl:template>
    <!-- AJO 20/07: ajouté-->
    <xsl:template name="z898">
        <xsl:param name="srcTag"/>
        <xsl:param name="dstTag" select="@srcTag"/>
        <xsl:for-each select="datafield[@tag = $srcTag]">
            <datafield tag="{$dstTag}">
                <xsl:call-template name="copy-indicators">
                    <xsl:with-param name="dstTag" select="$dstTag"/>
                </xsl:call-template>
                <subfield code="a">
                    <xsl:value-of select="subfield[@code = 'a']"> </xsl:value-of>
                    <xsl:if test="subfield[@code = 'd'] != ''">
                        <xsl:value-of select="concat(' - ', subfield[@code = 'd'])"/>
                    </xsl:if>
                </subfield>
            </datafield>
        </xsl:for-each>
    </xsl:template>
    <!--801 multiples + 152 -> 040 unique        
    SI zone 801 ind2 = 0 et/ou zone 801 ind2 = 1 
            alors zone 040 unique fondée sur - par ordre de priorité - zone 801 ind2 = 0 (sinon zone 801 ind2 = 1)  
                   et si zone 801 ind2 = 2 et/ou zone 801 ind2 = 3      
                             alors alimentation de la 040 $d avec le $b de  - par ordre de priorité - zone 801 ind2 = 2 (sinon zone 801 ind2 = 3)  
                    et si zone 152 
                             alors alimentation de la zone 040 $f par la zone 152 $b
    SINON  (pas de zone 801 ind2 = 0 ni de zone 801 ind2 = 1) ==> création de zone la zone 040 sur la base de 801 ind2 = 3 uniquement
    
    AJO (06.07): 152 $a pas nécessaire, constante AFNOR en 801; 152 $b -> 040 $f
     - ajout de l'instance [1] dans le traitement de de la sous-zone 801 _3 $b (sinon il y a plusieurs contenus le cas échéant)
   -->
    <xsl:template name="z040">
        <xsl:param name="base040"/>
        <!--<xsl:value-of select="$base040"/>-->
        <xsl:variable name="szb2szd">
            <xsl:choose>
                <xsl:when test="//datafield[@tag = '801'][@ind2 = '2']">
                    <xsl:value-of
                        select="//datafield[@tag = '801'][@ind2 = '2']/subfield[@code = 'b']"/>
                </xsl:when>
                <xsl:when test="//datafield[@tag = '801'][@ind2 = '3']">
                    <!-- <xsl:value-of
                    select="//datafield[@tag = '801'][@ind2 = '3']/subfield[@code = 'b']"/>-->
                    <xsl:value-of
                        select="//datafield[@tag = '801'][@ind2 = '3'][1]/subfield[@code = 'b']"/>
                </xsl:when>
            </xsl:choose>
        </xsl:variable>
        <xsl:for-each select="//datafield[@tag = '801'][@ind2 = $base040][1]">
            <!--   <datafield tag="040" ind1="' '" ind2="' '">-->
            <datafield ind1=" " ind2=" " tag="040">
                <subfield code="a">
                    <xsl:value-of select="subfield[@code = 'b']"/>
                </subfield>
                <subfield code="b">
                    <xsl:text>fre</xsl:text>
                </subfield>
                <subfield code="c">
                    <xsl:value-of select="subfield[@code = 'b']"/>
                </subfield>
                <xsl:if test="$szb2szd != ''">
                    <subfield code="d">
                        <xsl:value-of select="$szb2szd"/>
                    </subfield>
                </xsl:if>
                <subfield code="e">
                    <xsl:value-of select="'AFNOR'"/>
                </subfield>
                <!--   <xsl:for-each select="//datafield[@tag = '152']/subfield[@code = 'a'][text() != '']">-->
                <xsl:for-each select="//datafield[@tag = '152']/subfield[@code = 'b'][text() != '']">
                    <subfield code="f">
                        <xsl:value-of select="."/>
                    </subfield>
                </xsl:for-each>
                <!--  <xsl:for-each select="//datafield[@tag = '152']/subfield[@code = 'b'][text() != '']">
                <subfield code="g">
                    <xsl:value-of select="."/>
                </subfield>
            </xsl:for-each>-->
            </datafield>
        </xsl:for-each>
    </xsl:template>
    <xsl:template name="transform-personal-name">
        <xsl:param name="srcTag"/>
        <xsl:param name="dstTag"/>
        <xsl:for-each select="datafield[@tag = $srcTag]">
            <datafield ind1="{@ind2}" ind2="" tag="{$dstTag}">
                <xsl:call-template name="transform-subfields">
                    <xsl:with-param name="srcCodes" select="'acdfgp4'"/>
                    <xsl:with-param name="dstCodes" select="'acbdqu4'"/>
                </xsl:call-template>
            </datafield>
        </xsl:for-each>
    </xsl:template>
    <xsl:template name="copy-indicators">
        <!--ERM le 25/06/20 -->
        <!--Traitements spécifiques sur les indicateurs de certaines zones en fonction du pramètre dstTag-->
        <!--AJO le 20/07 : $dstTag doit contenir étiquette destination; ind1/ind2 = " " et non # -->
        <!-- 300 -> 680
             305 -> 360
             310 -> 280
             330 -> 680
             autres zones 3XX: indicateurs Unimarc " " -->
        <xsl:param name="dstTag"/>
        <xsl:attribute name="ind1">
            <xsl:choose>
                <xsl:when test="$dstTag = 024">
                    <xsl:text>7</xsl:text>
                </xsl:when>
                <xsl:when test="$dstTag = 280">
                    <xsl:text> </xsl:text>
                </xsl:when>
                <xsl:when test="$dstTag = 360">
                    <xsl:text> </xsl:text>
                </xsl:when>
                <xsl:when test="$dstTag = 680">
                    <xsl:text> </xsl:text>
                </xsl:when>
                <xsl:when test="$dstTag = 856">
                    <xsl:text>4</xsl:text>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="translate(@ind1, '#', '')"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:attribute>
        <xsl:attribute name="ind2">
            <xsl:choose>
                <xsl:when test="$dstTag = 300">#</xsl:when>
                <xsl:when test="$dstTag = 305">#</xsl:when>
                <xsl:when test="$dstTag = 310">#</xsl:when>
                <xsl:when test="$dstTag = 320">#</xsl:when>
                <xsl:when test="$dstTag = 330">#</xsl:when>
                <xsl:when test="$dstTag = 340">#</xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="translate(@ind2, '#', '')"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:attribute>
    </xsl:template>
    <xsl:template name="transform-subfields">
        <xsl:param name="srcTag"/>
        <xsl:param name="srcCodes" select="$all-codes"/>
        <xsl:param name="dstCodes" select="$srcCodes"/>
        <xsl:for-each select="subfield[contains($srcCodes, @code)]">
            <subfield code="{translate(@code, $srcCodes, $dstCodes)}">
                <xsl:choose>
                    <xsl:when test="($srcTag = '010' or $srcTag = '033') and @code = '2'">
                        <xsl:value-of select="translate(text(), $uppercase, $smallcase)"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="text()"/>
                    </xsl:otherwise>
                </xsl:choose>
            </subfield>
        </xsl:for-each>
    </xsl:template>
    <!--Mapping des $5 unimarc pour i-->
    <!--AJ0 15/07 complété les codes avec |xxx -->
    <xsl:template name="szi_fromsz5">
        <xsl:param name="sz5"/>
        <xsl:variable name="szi"
            >;a|xxx=Forme&#x20;antérieure&#x20;du&#x20;nom;b|xxx=Forme&#x20;postérieure&#x20;du&#x20;nom;e|xxx=Pseudonyme;f|xxx=Nom&#x20;à&#x20;l'état&#x20;civil;g|xxx=Terme&#x20;générique;h|xxx=Terme&#x20;spécifique;i|xxx=Nom&#x20;de&#x20;religion;j|xxx=Nom&#x20;de&#x20;mariage;k|xxx=Nom&#x20;de&#x20;jeune&#x20;fille;l|xxx=Pseudonyme&#x20;collectif;r|xxx=Regroupe;s|xxx=Regroupé&#x20;par;u|xxx=Inconnu;z|xxx=Autre;xxc=Descendant&#x20;de;xxd=Ascendant&#x20;de;xxe=Marié(e)&#x20;avec;xxg=Enfant&#x20;de;xxh=Parent&#x20;de;xxj=Frère/soeur&#x20;de;xxk=Membre&#x20;de;xxl=A&#x20;pour&#x20;membre;xxm=Fonde;xxn=Fondé&#x20;par;xxp=Collectivité&#x20;subordonnée;xxq=Fait&#x20;partie&#x20;de&#x20;la&#x20;collectivité;xxs=Possède;xxt=Possédé(e)&#x20;par;xxz=Autre</xsl:variable>
        <xsl:value-of select="substring-before(substring-after($szi, concat(';', $sz5, '=')), ';')"
        />
    </xsl:template>
    <!--Mapping des codes types d'autorités-->
    <xsl:template name="typeAut">
        <xsl:param name="code"/>
        <xsl:variable name="rolemap"
            >;a=personne;b=collectivité/congrès;c=nom&#x20;géographique;d=marque;e=famille;f=titre;
            h=auteur/titre;j=sujet;l=forme/genre</xsl:variable>
        <xsl:value-of
            select="substring-before(substring-after($rolemap, concat(';', $code, '=')), ';')"/>
    </xsl:template>
    <xsl:template name="z106c">
        <xsl:param name="code"/>
        <xsl:variable name="rolemap">;0=&#x20;;1=i;2=i;3=i</xsl:variable>
        <xsl:value-of
            select="substring-before(substring-after($rolemap, concat(';', $code, '=')), ';')"/>
    </xsl:template>
    <xsl:template name="z106a">
        <xsl:param name="code"/>
        <xsl:variable name="rolemap">;0=a;1=b</xsl:variable>
        <xsl:value-of
            select="substring-before(substring-after($rolemap, concat(';', $code, '=')), ';')"/>
    </xsl:template>
    <xsl:template name="z106b">
        <xsl:param name="code"/>
        <xsl:variable name="rolemap">;0=f;1=a;2=d</xsl:variable>
        <xsl:value-of
            select="substring-before(substring-after($rolemap, concat(';', $code, '=')), ';')"/>
    </xsl:template>
</xsl:stylesheet>
