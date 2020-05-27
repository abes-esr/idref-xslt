<xsl:stylesheet version="1.0" xmlns="http://www.loc.gov/MARC21/slim"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:msxml="urn:schemas-microsoft-com:xslt">
    <xsl:output encoding="UTF-8" indent="yes" method="xml"/>
    <xsl:strip-space elements="*"/>
    <!--
  Transformation from UNIMARC XML representation to MARCXML.
  Based upon http://www.loc.gov/marc/unimarctomarc21.html
    -->
    <xsl:template match="/">
        <xsl:choose>
            <xsl:when test="//collection">
                <collection xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
                    xsi:schemaLocation="http://www.loc.gov/MARC21/slim http://www.loc.gov/standards/marcxml/schema/MARC21slim.xsd">
                    <xsl:for-each select="//collection/record">
                        <record>
                            <xsl:call-template name="record"/>
                        </record>
                    </xsl:for-each>
                </collection>
            </xsl:when>
            <xsl:otherwise>
                <record xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
                    xsi:schemaLocation="http://www.loc.gov/MARC21/slim http://www.loc.gov/standards/marcxml/schema/MARC21slim.xsd">
                    <xsl:for-each select="//record">
                        <xsl:call-template name="record"/>
                    </xsl:for-each>
                </record>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template name="record">
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
            <!--        il faut générer ind0 = rien, ind1 = 7  -->
        </xsl:call-template>
        
        <!-- 015->024 -->
        <xsl:call-template name="transform-datafield">
            <xsl:with-param name="srcTag">015</xsl:with-param>
            <xsl:with-param name="dstTag">024</xsl:with-param>
            <!--        il faut générer ind0 = rien, ind1 = 7  -->
            <!--        $2 ISADN sera là de facto   -->
        </xsl:call-template>
        
        <!-- 033->024 -->
        <xsl:call-template name="transform-datafield">
            <xsl:with-param name="srcTag">033</xsl:with-param>
            <xsl:with-param name="dstTag">024</xsl:with-param>
            <!--     il faut générer ind0 = rien, ind1 = 7  -->
        </xsl:call-template>
        
        <!-- 035->035 -->
        <xsl:call-template name="transform-datafield">
            <xsl:with-param name="srcTag">035</xsl:with-param>
            <xsl:with-param name="dstTag">035</xsl:with-param>
        </xsl:call-template>
        <!--FML ajout d'une 035 générée à partir de la zone 001-->
        <datafield tag="035" ind1=" " ind2=" ">
            <subfield code="a">
                <xsl:value-of select="concat('(IDREF)', $z001)"/>
            </subfield>
        </datafield>
        
        <!-- Bloc 1XX -->
        <!-- 100->008 : OK voir transform-008-->
        <!-- 101->377   (précision : code de langue MARC : est-ce un souci ?)-->
        <!-- MIH modif 13/05/20 d'après la loc (https://www.loc.gov/marc/languages/introduction.pdf) le code de langue MARC diffère de l'ISO 639-2 pour 22 langues -->
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
       <!--  <xsl:call-template name="transform-datafield"> -->
       <!--      <xsl:with-param name="srcTag">120</xsl:with-param> -->
       <!--     <xsl:with-param name="dstTag">375</xsl:with-param> -->
       <!--  </xsl:call-template> -->
       <!--  Conversion ajoutée à la fin du template transform-008 (variable 120 déjà définie)  -->

        <!-- 123 pas reprise -->

        <!-- 152->040 -->
        <xsl:call-template name="transform-datafield">
            <xsl:with-param name="srcTag">152</xsl:with-param>
            <xsl:with-param name="dstTag">040</xsl:with-param>
            <xsl:with-param name="srcCodes">a</xsl:with-param>
            <xsl:with-param name="dstCodes">2</xsl:with-param>
            <!--  $2 AFNOR sera là de facto   -->
        </xsl:call-template>

        <!-- 160->043 -->
        <!-- MIH 13.05.20 Attention champ 043 Marc21 déjà mappé avec champ 370 Unimarc. Zone 160 Unimarc pas définie par l'IFLA ni par la Transition Bibliographique -->
        <xsl:call-template name="transform-datafield">
            <xsl:with-param name="srcTag">160</xsl:with-param>
            <xsl:with-param name="dstTag">043</xsl:with-param>
        </xsl:call-template>

        <!-- 180 pas d'équivalent -->
        <!-- MIH 13.05.20 : ce serait utile de conserver l'information. La coder en zone 049 (utilisée en Intermarc) ? -->
        
        <!-- Bloc des points d'accès 2XX : NOK car trop sommaire mais OK pour test -->
        <!-- 200->100 -->
        <xsl:call-template name="Z_PT_ACCES_200">
            <xsl:with-param name="srcTag">200</xsl:with-param>
            <xsl:with-param name="dstTag">100</xsl:with-param>
        </xsl:call-template>
        <!-- 210->110 -->
        <xsl:call-template name="Z_PT_ACCES_210">
            <xsl:with-param name="srcTag">210</xsl:with-param>
            <xsl:with-param name="dstTag">110</xsl:with-param>
        </xsl:call-template>
        <!-- 215->151 -->
        <xsl:call-template name="transform-datafield">
            <xsl:with-param name="srcTag">215</xsl:with-param>
            <xsl:with-param name="dstTag">151</xsl:with-param>
            <xsl:with-param name="srcCodes">axyz</xsl:with-param>
            <xsl:with-param name="dstCodes">axzy</xsl:with-param>
        </xsl:call-template>
        <!-- 216->150 -->
        <xsl:call-template name="transform-datafield">
            <xsl:with-param name="srcTag">216</xsl:with-param>
            <xsl:with-param name="dstTag">150</xsl:with-param>
            <xsl:with-param name="srcCodes">afcxyz</xsl:with-param>
            <xsl:with-param name="dstCodes">aggxzy</xsl:with-param>
        </xsl:call-template>
        <!-- 220->100 -->
        <!-- MIH 13.05.20 générer un 1er indicateur 3 -->
        <xsl:call-template name="transform-datafield">
            <xsl:with-param name="srcTag">220</xsl:with-param>
            <xsl:with-param name="dstTag">100</xsl:with-param>
            <!-- MIH 13.05.20 modif : codes Unimarc c et d repris en Marc21 g et g -->
            <xsl:with-param name="srcCodes">acdfxyz</xsl:with-param>
            <xsl:with-param name="dstCodes">aggdxzy</xsl:with-param>
        </xsl:call-template>
        <!-- 230->130 -->
        <xsl:call-template name="Z_PT_ACCES_230">
            <xsl:with-param name="srcTag">230</xsl:with-param>
            <xsl:with-param name="dstTag">130</xsl:with-param>
        </xsl:call-template>
        <!-- RIEN à propose de 231/232 ?  -->
        <!-- MIH 13.05.20 pour l'instant, seule la zone 130 contient des informations sur les titres -->
        <!-- 240->100 -->
        <xsl:call-template name="Z_PT_ACCES_240">
            <xsl:with-param name="srcTag">240</xsl:with-param>
            <xsl:with-param name="dstTag">100</xsl:with-param>
        </xsl:call-template>
        <!-- 250->150 -->
        <xsl:call-template name="transform-datafield">
            <xsl:with-param name="srcTag">250</xsl:with-param>
            <xsl:with-param name="dstTag">150</xsl:with-param>
            <xsl:with-param name="srcCodes">axyz</xsl:with-param>
            <xsl:with-param name="dstCodes">axzy</xsl:with-param>
        </xsl:call-template>
        <!-- 280->155 -->
        <xsl:call-template name="transform-datafield">
            <xsl:with-param name="srcTag">280</xsl:with-param>
            <xsl:with-param name="dstTag">155</xsl:with-param>
            <xsl:with-param name="srcCodes">axyz</xsl:with-param>
            <xsl:with-param name="dstCodes">axzy</xsl:with-param>
        </xsl:call-template>
        
        <!-- Notes 3XX -->
        <!-- 300->680 -->
        <xsl:call-template name="transform-datafield">
            <xsl:with-param name="srcTag">300</xsl:with-param>
            <xsl:with-param name="dstTag">680</xsl:with-param>
            <!-- MIH 13.05.20 ajout : mapping code a->i -->
            <xsl:with-param name="srcCodes">a</xsl:with-param>
            <xsl:with-param name="dstCodes">i</xsl:with-param>
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
            <xsl:with-param name="dstTag">680</xsl:with-param>
            <!-- MIH 13.05.20 ajout : mapping code a->i -->
            <xsl:with-param name="srcCodes">a</xsl:with-param>
            <xsl:with-param name="dstCodes">i</xsl:with-param>
        </xsl:call-template>
        <!-- 330->680 -->
        <xsl:call-template name="transform-datafield">
            <xsl:with-param name="srcTag">330</xsl:with-param>
            <xsl:with-param name="dstTag">680</xsl:with-param>
            <!-- MIH 13.05.20 ajout : mapping code a->i -->
            <xsl:with-param name="srcCodes">a</xsl:with-param>
            <xsl:with-param name="dstCodes">i</xsl:with-param>        
        </xsl:call-template>
        <!-- 340->678 -->
        <!-- MIH 13.05.20 modif : plutôt mapping 340->680. La zone 678 contient le nom développé d'une personne -->
        <xsl:call-template name="transform-datafield">
            <xsl:with-param name="srcTag">340</xsl:with-param>
            <xsl:with-param name="dstTag">680</xsl:with-param>
            <!-- MIH 13.05.20 ajout : mapping code a->i -->
            <xsl:with-param name="srcCodes">a</xsl:with-param>
            <xsl:with-param name="dstCodes">i</xsl:with-param>  
        </xsl:call-template>
        <!-- 356->680 -->
        <xsl:call-template name="transform-datafield">
            <xsl:with-param name="srcTag">356</xsl:with-param>
            <xsl:with-param name="dstTag">680</xsl:with-param>
            <!-- MIH 13.05.20 ajout : mapping code a->i -->
            <xsl:with-param name="srcCodes">a</xsl:with-param>
            <xsl:with-param name="dstCodes">i</xsl:with-param>          
        </xsl:call-template>
        
        <!-- Bloc des 4XX -->
        <!-- 400->400 -->
        <xsl:call-template name="transform-datafield">
        <!-- MIH 13.05.2020 Besoin d'une règle propre au point d'accès similaire à "Z_PT_ACCES_200"-->
            <xsl:with-param name="srcTag">400</xsl:with-param>
            <xsl:with-param name="dstTag">400</xsl:with-param>
        </xsl:call-template>
        <!-- 410->410 -->
        <xsl:call-template name="transform-datafield">
        <!-- MIH 13.05.2020 Besoin d'une règle propre au point d'accès similaire à "Z_PT_ACCES_210"-->
            <xsl:with-param name="srcTag">410</xsl:with-param>
            <xsl:with-param name="dstTag">410</xsl:with-param>
        </xsl:call-template>
        <!-- 415->451 -->
        <xsl:call-template name="transform-datafield">
            <xsl:with-param name="srcTag">415</xsl:with-param>
            <xsl:with-param name="dstTag">451</xsl:with-param>
            <xsl:with-param name="srcCodes">axyz</xsl:with-param>
            <xsl:with-param name="dstCodes">axzy</xsl:with-param>
        </xsl:call-template>
        <!-- 416->450 -->
        <xsl:call-template name="transform-datafield">
            <xsl:with-param name="srcTag">416</xsl:with-param>
            <xsl:with-param name="dstTag">450</xsl:with-param>
            <xsl:with-param name="srcCodes">afcxyz</xsl:with-param>
            <xsl:with-param name="dstCodes">aggxzy</xsl:with-param>
        </xsl:call-template>
        <!-- 420->400 -->
        <!-- MIH 13.05.20 générer un 1er indicateur 3 -->
        <xsl:call-template name="transform-datafield">
            <xsl:with-param name="srcTag">420</xsl:with-param>
            <xsl:with-param name="dstTag">400</xsl:with-param>
            <!-- MIH 13.05.20 modif : codes Unimarc c et d repris en Marc21 g et g -->
            <xsl:with-param name="srcCodes">acdfxyz</xsl:with-param>
            <xsl:with-param name="dstCodes">aggdxzy</xsl:with-param>
        </xsl:call-template>
        <!-- 430->430 -->
        <xsl:call-template name="transform-datafield">
        <!-- MIH 13.05.2020 Besoin d'une règle propre au point d'accès similaire à "Z_PT_ACCES_230"-->
            <xsl:with-param name="srcTag">430</xsl:with-param>
            <xsl:with-param name="dstTag">430</xsl:with-param>
        </xsl:call-template>
        <!-- RIEN à propose de 431/432 ?  -->
        <!-- MIH 13.05.20 pour l'instant, seule la zone 430 contient des informations sur les titres -->
        <!-- 440->400 -->
        <xsl:call-template name="transform-datafield">
        <!-- MIH 13.05.2020 Besoin d'une règle propre au point d'accès similaire à "Z_PT_ACCES_240"-->
            <xsl:with-param name="srcTag">440</xsl:with-param>
            <xsl:with-param name="dstTag">400</xsl:with-param>
        </xsl:call-template>
        <!-- 450->450 -->
        <xsl:call-template name="transform-datafield">
            <xsl:with-param name="srcTag">450</xsl:with-param>
            <xsl:with-param name="dstTag">450</xsl:with-param>
            <xsl:with-param name="srcCodes">axyz</xsl:with-param>
            <xsl:with-param name="dstCodes">axzy</xsl:with-param>
        </xsl:call-template>
        <!-- 480->455 -->
        <xsl:call-template name="transform-datafield">
            <xsl:with-param name="srcTag">480</xsl:with-param>
            <xsl:with-param name="dstTag">455</xsl:with-param>
            <xsl:with-param name="srcCodes">axyz</xsl:with-param>
            <xsl:with-param name="dstCodes">axzy</xsl:with-param>
        </xsl:call-template>

        <!-- Bloc des 5XX -->
        <!-- 500->500-->
        <xsl:call-template name="transform-datafield">
        <!-- MIH 13.05.2020 Besoin d'une règle propre au point d'accès, similaire à "Z_PT_ACCES_200"-->
            <xsl:with-param name="srcTag">500</xsl:with-param>
            <xsl:with-param name="dstTag">500</xsl:with-param>
        </xsl:call-template>
        <!-- 510->510 -->
        <xsl:call-template name="transform-datafield">
        <!-- MIH 13.05.2020 Besoin d'une règle propre au point d'accès, similaire à "Z_PT_ACCES_210"-->
            <xsl:with-param name="srcTag">510</xsl:with-param>
            <xsl:with-param name="dstTag">510</xsl:with-param>
        </xsl:call-template>
        <!-- 515->551 -->
        <xsl:call-template name="transform-datafield">
            <xsl:with-param name="srcTag">515</xsl:with-param>
            <xsl:with-param name="dstTag">551</xsl:with-param>
            <xsl:with-param name="srcCodes">axyz</xsl:with-param>
            <xsl:with-param name="dstCodes">axzy</xsl:with-param>
        </xsl:call-template>
        <!-- 516->550 -->
        <xsl:call-template name="transform-datafield">
            <xsl:with-param name="srcTag">216</xsl:with-param>
            <xsl:with-param name="dstTag">150</xsl:with-param>
            <xsl:with-param name="srcCodes">afcxyz</xsl:with-param>
            <xsl:with-param name="dstCodes">aggxzy</xsl:with-param>
        </xsl:call-template>
        <!-- 520->500 -->
        <!-- MIH 13.05.20 générer un 1er indicateur 3 -->
        <xsl:call-template name="transform-datafield">
            <xsl:with-param name="srcTag">520</xsl:with-param>
            <xsl:with-param name="dstTag">500</xsl:with-param>
            <!-- MIH 13.05.20 modif : codes Unimarc c et d repris en Marc21 g et g -->
            <xsl:with-param name="srcCodes">acdfxyz</xsl:with-param>
            <xsl:with-param name="dstCodes">aggdxzy</xsl:with-param>
        </xsl:call-template>
        <!-- 530->530 -->
        <xsl:call-template name="transform-datafield">
        <!-- MIH 13.05.2020 Besoin d'une règle propre au point d'accès, similaire à "Z_PT_ACCES_230"-->
            <xsl:with-param name="srcTag">530</xsl:with-param>
            <xsl:with-param name="dstTag">530</xsl:with-param>
        </xsl:call-template>
        <!-- RIEN à propose de 531/532 ?  -->
        <!-- MIH 13.05.20 pour l'instant, seule la zone 530 contient des informations sur les titres -->
        <!-- 540->500 -->
        <xsl:call-template name="transform-datafield">
        <!-- MIH 13.05.2020 Besoin d'une règle propre au point d'accès similaire à "Z_PT_ACCES_240"-->
            <xsl:with-param name="srcTag">540</xsl:with-param>
            <xsl:with-param name="dstTag">500</xsl:with-param>
        </xsl:call-template>
        <!-- 550->550 -->
        <xsl:call-template name="transform-datafield">
            <xsl:with-param name="srcTag">550</xsl:with-param>
            <xsl:with-param name="dstTag">550</xsl:with-param>
            <xsl:with-param name="srcCodes">axyz</xsl:with-param>
            <xsl:with-param name="dstCodes">axzy</xsl:with-param>
        </xsl:call-template>
        <!-- 580->555 -->
        <xsl:call-template name="transform-datafield">
            <xsl:with-param name="srcTag">580</xsl:with-param>
            <xsl:with-param name="dstTag">555</xsl:with-param>
            <xsl:with-param name="srcCodes">axyz</xsl:with-param>
            <xsl:with-param name="dstCodes">axzy</xsl:with-param>
        </xsl:call-template>     
        
        <!-- Bloc des 6XX -->
        <!-- 676->082 -->
        <xsl:call-template name="transform-datafield">
            <xsl:with-param name="srcTag">676</xsl:with-param>
            <xsl:with-param name="dstTag">082</xsl:with-param>
            <xsl:with-param name="srcCodes">av</xsl:with-param>
            <xsl:with-param name="dstCodes">a2</xsl:with-param>
        </xsl:call-template>
        <!-- 686->065 -->
        <xsl:call-template name="transform-datafield">
            <xsl:with-param name="srcTag">686</xsl:with-param>
            <xsl:with-param name="dstTag">065</xsl:with-param>
        </xsl:call-template>
 
        <!-- Bloc des 7XX -->
        <!-- MIH 13.05.20 les traductions et translittérations d'un point d'accès autorisé sont signalées en zones 4XX en Marc21 -->
        <!-- 700->400 -->
        <xsl:call-template name="transform-datafield">
        <!-- MIH 13.05.2020 Besoin d'une règle propre au point d'accès similaire à "Z_PT_ACCES_200"-->
            <xsl:with-param name="srcTag">700</xsl:with-param>
            <xsl:with-param name="dstTag">400</xsl:with-param>
        </xsl:call-template>
        <!-- 710->410 -->
        <xsl:call-template name="transform-datafield">
        <!-- MIH 13.05.2020 Besoin d'une règle propre au point d'accès similaire à "Z_PT_ACCES_210"-->
            <xsl:with-param name="srcTag">710</xsl:with-param>
            <xsl:with-param name="dstTag">410</xsl:with-param>
        </xsl:call-template>
        <!-- 715->451 -->
        <xsl:call-template name="transform-datafield">
            <xsl:with-param name="srcTag">715</xsl:with-param>
            <xsl:with-param name="dstTag">451</xsl:with-param>
            <xsl:with-param name="srcCodes">axyz</xsl:with-param>
            <xsl:with-param name="dstCodes">axzy</xsl:with-param>
        </xsl:call-template>
        <!-- 716->450 -->
        <xsl:call-template name="transform-datafield">
            <xsl:with-param name="srcTag">716</xsl:with-param>
            <xsl:with-param name="dstTag">450</xsl:with-param>
            <xsl:with-param name="srcCodes">afcxyz</xsl:with-param>
            <xsl:with-param name="dstCodes">aggxzy</xsl:with-param>
        </xsl:call-template>
        <!-- 720->400 -->
        <!-- MIH 13.05.20 générer un 1er indicateur 3 -->
        <xsl:call-template name="transform-datafield">
            <xsl:with-param name="srcTag">720</xsl:with-param>
            <xsl:with-param name="dstTag">400</xsl:with-param>
            <!-- MIH 13.05.20 modif : codes Unimarc c et d repris en Marc21 g et g -->
            <xsl:with-param name="srcCodes">acdfxyz</xsl:with-param>
            <xsl:with-param name="dstCodes">aggdxzy</xsl:with-param>
        </xsl:call-template>
        <!-- 730->430 -->
        <xsl:call-template name="transform-datafield">
        <!-- MIH 13.05.2020 Besoin d'une règle propre au point d'accès similaire à "Z_PT_ACCES_230"-->
            <xsl:with-param name="srcTag">730</xsl:with-param>
            <xsl:with-param name="dstTag">430</xsl:with-param>
        </xsl:call-template>
        <!-- 740->400 -->
        <xsl:call-template name="transform-datafield">
        <!-- MIH 13.05.2020 Besoin d'une règle propre au point d'accès similaire à "Z_PT_ACCES_240"-->
            <xsl:with-param name="srcTag">740</xsl:with-param>
            <xsl:with-param name="dstTag">400</xsl:with-param>
        </xsl:call-template>
        <!-- 750->450 -->
        <xsl:call-template name="transform-datafield">
            <xsl:with-param name="srcTag">750</xsl:with-param>
            <xsl:with-param name="dstTag">450</xsl:with-param>
            <xsl:with-param name="srcCodes">axyz</xsl:with-param>
            <xsl:with-param name="dstCodes">axzy</xsl:with-param>
        </xsl:call-template>
        <!-- 780->455 -->
        <xsl:call-template name="transform-datafield">
            <xsl:with-param name="srcTag">780</xsl:with-param>
            <xsl:with-param name="dstTag">455</xsl:with-param>
            <xsl:with-param name="srcCodes">axyz</xsl:with-param>
            <xsl:with-param name="dstCodes">axzy</xsl:with-param>
        </xsl:call-template>
            
        <!-- Bloc des 8XX -->
        <!-- 801->040 : template particulier ?
801  si Ind 1= 0 ou 1, alors 040 ; 
$b + $a  -> insérer en $a avec tiret comme séparateur (exemple $a FR $b BN -> $a FR - BN)
$g -> $e ; 
générer $b fre ; 
ne pas reprendre $c $h $2
        
801 si 801 Ind 1 = 2 ou 3, alors 040
$b + $a  -> insérer en $d avec tiret comme séparateur (exemple $a FR $b BN -> $d FR - BN)
$g -> $e
générer $b fre
ne pas reprendre $c $h $2       
        
Dans les deux cas, si plusieurs 801, ne faire qu' une seule zone 040, celle de l' ABES 
exemple: 801 3$aFR$bABES$c20111220$gAFNOR$h027268462  -> 040 _ _  $d FR - ABES $b fre $e AFNOR        
 -->
        <!-- 810->670 -->
        <xsl:call-template name="transform-datafield">
            <xsl:with-param name="srcTag">810</xsl:with-param>
            <xsl:with-param name="dstTag">670</xsl:with-param>
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
        <!-- 822->682  : template particulier ?
reprendre seulement $a + $2 à mettre en 680 $a (remplacer le $2 par  espace tiret espace)
822 12 $a Fantômes $2 RVMLaval $d 2013-10-22  -> 680 _ _  $a Fantômes - RVMLaval
822 : reprise du site transition bibliographique
en MARC21, l'équivalent dans un autre référentiel va en zone 7XX pour les vocabulaires 
mais pas pour les classifications : le plus simple est de transférer l'info en 680 (note publique) 
ou alors à l'identique dans une zone locale par exemple 829-->
        <!-- 825->667 -->
        <xsl:call-template name="transform-datafield">
            <xsl:with-param name="srcTag">825</xsl:with-param>
            <xsl:with-param name="dstTag">667</xsl:with-param>
        </xsl:call-template>
        <!-- 830->667 -->
        <xsl:call-template name="transform-datafield">
            <xsl:with-param name="srcTag">830</xsl:with-param>
            <xsl:with-param name="dstTag">667</xsl:with-param>
        </xsl:call-template>
        <!-- 835->682 -->
        <xsl:call-template name="transform-datafield">
            <xsl:with-param name="srcTag">835</xsl:with-param>
            <xsl:with-param name="dstTag">682</xsl:with-param>
        </xsl:call-template>
        <!-- 836->682 -->
        <xsl:call-template name="transform-datafield">
            <xsl:with-param name="srcTag">836</xsl:with-param>
            <xsl:with-param name="dstTag">682</xsl:with-param>
        </xsl:call-template>
 
 <!-- 839->682 : cette zone n'existe pas en unimarcxml ; elle devient une 035$appn fusionné $9sudoc
        <xsl:call-template name="transform-datafield">
            <xsl:with-param name="srcTag">839</xsl:with-param>
            <xsl:with-param name="dstTag">682</xsl:with-param>
            <xsl:with-param name="srcCodes"></xsl:with-param>
            <xsl:with-param name="dstCodes"></xsl:with-param>
        </xsl:call-template> -->
        <!-- 856->856 -->
        <xsl:call-template name="transform-datafield">
            <xsl:with-param name="srcTag">856</xsl:with-param>
            <xsl:with-param name="dstTag">856</xsl:with-param>
        </xsl:call-template>
        <!-- et nos 9XX ? -->
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
        <datafield tag="075" ind1=" " ind2=" ">
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
    
    <!-- Génération des zones 100, 106, 120, 154 à partir de la 008 -->
    <xsl:template name="transform-008">
        <xsl:variable name="source100" select="datafield[@tag = '100']/subfield[@code = 'a']"/>
        <xsl:variable name="source106" select="datafield[@tag = '106']"/>
        <xsl:variable name="source120" select="datafield[@tag = '120']/subfield[@code = 'a']"/>
        <xsl:variable name="source154" select="datafield[@tag = '154']/subfield[@code = 'a']"/>
        <xsl:variable name="dest00-05" select="substring($source100, 2, 6)"/>
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
        <xsl:variable name="dest10-14" select="'|||||'"> </xsl:variable>
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
                <datafield tag="375" ind1=" " ind2=" ">
                    <subfield code="a">
                        <xsl:value-of select="$dest375"/>
                    </subfield>
                    <subfield code="2">unimarc</subfield>
                </datafield>
           </xsl:if>
        </xsl:if>  
    </xsl:template>

    <!-- Règle générale de transformation des étiquettes Marc et des codes de sous-champs -->
    <xsl:template name="transform-datafield">
        <xsl:param name="srcTag"/>
        <xsl:param name="dstTag" select="@srcTag"/>
        <xsl:param name="srcCodes" select="$all-codes"/>
        <xsl:param name="dstCodes" select="$srcCodes"/>
        <xsl:if test="datafield[@tag = $srcTag]/subfield[contains($srcCodes, @code)]">
            <xsl:for-each select="datafield[@tag = $srcTag]">
                <datafield tag="{$dstTag}">
                    <!--ERM ajout du parametre dstTag pour faire des traitements spécifiques sur les indicateurs de certaines zones-->
                    <xsl:call-template name="copy-indicators">
                        <xsl:with-param name="dstTag" select="$dstTag"/>
                    </xsl:call-template>
                    <xsl:call-template name="transform-subfields">
                        <xsl:with-param name="srcCodes" select="$srcCodes"/>
                        <xsl:with-param name="dstCodes" select="$dstCodes"/>
                    </xsl:call-template>
                </datafield>
            </xsl:for-each>
        </xsl:if>
    </xsl:template>

    <xsl:template name="Z_PT_ACCES_200">
    <!-- MIH 20.05.20 : ordre des sous-champs pris en compte ? -->
        <xsl:param name="srcTag"/>
        <xsl:param name="dstTag" select="@srcTag"/>
        <xsl:for-each select="datafield[@tag = $srcTag]">
            <datafield tag="{$dstTag}">
                <xsl:call-template name="copy-indicators">
                    <xsl:with-param name="dstTag" select="$dstTag"/>
                </xsl:call-template>
                <subfield code="a">
                    <xsl:value-of select="subfield[@code = 'a']"> </xsl:value-of>
                    <xsl:if test="subfield[@code = 'b'] != ''">
                        <xsl:value-of select="concat(', ', subfield[@code = 'b'])"/>
                    </xsl:if>
                </subfield>
                <xsl:if test="subfield[@code = 'd'] != ''">
                <!-- MIH 20.05.20 : faut-il ajouter une règle spécifique pour le sous-champ $D ? -->
                    <subfield code="b">
                        <xsl:value-of select="subfield[@code = 'd']"/>
                    </subfield>
                </xsl:if>
                 <xsl:if test="subfield[@code = 'g'] != ''">
                    <subfield code="q">
                        <xsl:value-of select="subfield[@code = 'g']"/>
                    </subfield>
                </xsl:if>
                <xsl:if test="subfield[@code = 'c'] != ''">
                    <subfield code="c">
                        <xsl:value-of select="subfield[@code = 'c']"/>
                    </subfield>
                </xsl:if>
                <xsl:if test="subfield[@code = 'f'] != ''">
                    <subfield code="d">
                        <xsl:value-of select="subfield[@code = 'f']"/>
                    </subfield>
                </xsl:if>
                 <xsl:if test="subfield[@code = 'x'] != ''">
                    <subfield code="x">
                        <xsl:value-of select="subfield[@code = 'x']"/>
                    </subfield>
                </xsl:if>
                <xsl:if test="subfield[@code = 'y'] != ''">
                    <subfield code="z">
                        <xsl:value-of select="subfield[@code = 'y']"/>
                    </subfield>
                </xsl:if>
                <xsl:if test="subfield[@code = 'z'] != ''">
                    <subfield code="y">
                        <xsl:value-of select="subfield[@code = 'z']"/>
                    </subfield>
                </xsl:if>
                <!-- MIH 20.05.20 : règles pour le sous-champ $6
                pas d'équivalent MARC21 -->
                <!-- MIH 27.05.20 : règles pour le sous-champ $7
                positions 0-1 : pas d'équivalent MARC21
                positions 2-3 : pas d'équivalent MARC21
                positions 4-5 : pas d'équivalent MARC21. Pratique Ex Libris (Alma) : $9
                La norme utilisée n'est pas déclarée, mais c'est sans doute la norme MARC21.
                positions 5-6 : pas d'équivalent MARC21
                -->
                <!-- MIH 26.05.20 : règles pour le sous-champ $8
                positions 0-2 : pas d'équivalent MARC21
                positions 3-5 : pas d'équivalent MARC21 officiel. Pratique Ex Libris (Alma) : $9
                La norme utilisée n'est pas déclarée, mais c'est sans doute la norme MARC21.
                -->
                <!-- MIH 26.05.20 : règles pour le sous-champ $9
                pas d'équivalent MARC21
                -->
            </datafield>
        </xsl:for-each>
    </xsl:template>
    
    <xsl:template name="Z_PT_ACCES_230">
        <xsl:param name="srcTag"/>
        <xsl:param name="dstTag" select="@srcTag"/>
        <xsl:for-each select="datafield[@tag = $srcTag]">
            <datafield tag="{$dstTag}">
                <xsl:call-template name="copy-indicators">
                    <xsl:with-param name="dstTag" select="$dstTag"/>
                </xsl:call-template>
                <subfield code="a">
                    <xsl:value-of select="subfield[@code = 'a']"/>
                </subfield>
                <xsl:if test="subfield[@code = 'h'] != ''">
                    <subfield code="n">
                        <xsl:value-of select="subfield[@code = 'h']"/>
                    </subfield>
                </xsl:if>
                <xsl:if test="subfield[@code = 'i'] != ''">
                    <subfield code="p">
                        <xsl:value-of select="subfield[@code = 'i']"/>
                    </subfield>
                </xsl:if>
                <xsl:if test="subfield[@code = 'k'] != ''">
                    <subfield code="f">
                        <xsl:value-of select="subfield[@code = 'k']"/>
                    </subfield>
                </xsl:if>
                <xsl:if test="subfield[@code = 'l'] != ''">
                    <subfield code="k">
                        <xsl:value-of select="subfield[@code = 'l']"/>
                    </subfield>
                </xsl:if>
                <xsl:if test="subfield[@code = 'm'] != ''">
                    <subfield code="l">
                        <xsl:value-of select="subfield[@code = 'm']"/>
                    </subfield>
                </xsl:if>
                <xsl:if test="subfield[@code = 'n'] != ''">
                    <subfield code="g">
                        <xsl:value-of select="subfield[@code = 'n']"/>
                    </subfield>
                </xsl:if>
                <xsl:if test="subfield[@code = 'q'] != ''">
                    <subfield code="s">
                        <xsl:value-of select="subfield[@code = 'q']"/>
                    </subfield>
                </xsl:if>
                <xsl:if test="subfield[@code = 'r'] != ''">
                    <subfield code="m">
                        <xsl:value-of select="subfield[@code = 'r']"/>
                    </subfield>
                </xsl:if>
                <xsl:if test="subfield[@code = 's'] != ''">
                    <subfield code="g">
                        <xsl:value-of select="subfield[@code = 's']"/>
                    </subfield>
                </xsl:if>
                <xsl:if test="subfield[@code = 'u'] != ''">
                    <subfield code="r">
                        <xsl:value-of select="subfield[@code = 'u']"/>
                    </subfield>
                </xsl:if>
                <xsl:if test="subfield[@code = 'w'] != ''">
                    <subfield code="o">
                        <xsl:value-of select="subfield[@code = 'w']"/>
                    </subfield>
                </xsl:if>
            </datafield>
        </xsl:for-each>
    </xsl:template>
    
    <xsl:template name="Z_PT_ACCES_240">
        <xsl:param name="srcTag"/>
        <xsl:param name="dstTag" select="@srcTag"/>
        <xsl:for-each select="datafield[@tag = $srcTag]">
            <datafield tag="{$dstTag}">
                <xsl:call-template name="copy-indicators">
                    <xsl:with-param name="dstTag" select="$dstTag"/>
                </xsl:call-template>
                <subfield code="a">
                    <xsl:value-of select="subfield[@code = 'a']"/>
                </subfield>
                <xsl:if test="subfield[@code = 't'] != ''">
                    <subfield code="t">
                        <xsl:value-of select="subfield[@code = 't']"/>
                    </subfield>
                </xsl:if>
<!--    faut-il vraiment faire ça : si  (dates) -> $d 
                                    et si    (dates ; qualificatif) -> $c qualificatif $d dates-->
        <!--AJO rem: oui -->
            </datafield>
        </xsl:for-each>
    </xsl:template>

    <xsl:template name="Z_PT_ACCES_210">
        <xsl:param name="srcTag"/>
        <xsl:param name="dstTag" select="@srcTag"/>
        <xsl:for-each select="datafield[@tag = $srcTag]">
            <datafield tag="{$dstTag}">
                <xsl:call-template name="copy-indicators">
                    <xsl:with-param name="dstTag" select="$dstTag"/>
                </xsl:call-template>
                <subfield code="a">
                       <xsl:value-of select="subfield[@code = 'a']"/>
                </subfield>
                <xsl:if test="subfield[@code = 'b'] != ''">
                    <subfield code="b">
                        <xsl:value-of select="subfield[@code = 'b']"/>
                    </subfield>
                </xsl:if>
                <!--   <xsl:if test="subfield[@code = 'g'] != ''">
                      <xsl:text>.</xsl:text>
                 <xsl:if test="subfield[@code = 'h'] != ''">
                        <xsl:text>.</xsl:text>
                </xsl:if>-->
                <xsl:if test="subfield[@code = 'c'] != ''">
                    <subfield code="g">
                        <xsl:value-of select="subfield[@code = 'c']"/>
                    </subfield>
                </xsl:if>
                <xsl:if test="subfield[@code = 'd'] != ''">
                    <subfield code="n">
                        <xsl:value-of select="subfield[@code = 'd']"/>
                    </subfield>
                </xsl:if>
                <xsl:if test="subfield[@code = 'e'] != ''">
                    <subfield code="c">
                        <xsl:value-of select="subfield[@code = 'e']"/>
                    </subfield>
                </xsl:if>
                <xsl:if test="subfield[@code = 'f'] != ''">
                    <subfield code="d">
                        <xsl:value-of select="subfield[@code = 'f']"/>
                    </subfield>
                </xsl:if>
                
                <xsl:if test="subfield[@code = 'x'] != ''">
                    <subfield code="x">
                        <xsl:value-of select="subfield[@code = 'x']"/>
                    </subfield>
                </xsl:if>
                <xsl:if test="subfield[@code = 'y'] != ''">
                    <subfield code="y">
                        <xsl:value-of select="subfield[@code = 'y']"/>
                    </subfield>
                </xsl:if>
                <xsl:if test="subfield[@code = 'z'] != ''">
                    <subfield code="z">
                        <xsl:value-of select="subfield[@code = 'z']"/>
                    </subfield>
                </xsl:if>
            </datafield>
        </xsl:for-each>
    </xsl:template>




<!--Poursuivre avc les autres points d'accès et les 400 et les 500
-->



























    <xsl:template name="transform-personal-name">
        <xsl:param name="srcTag"/>
        <xsl:param name="dstTag"/>
        <xsl:for-each select="datafield[@tag = $srcTag]">
            <datafield tag="{$dstTag}" ind1="{@ind2}" ind2="">
                <xsl:call-template name="transform-subfields">
                    <xsl:with-param name="srcCodes" select="'acdfgp4'"/>
                    <xsl:with-param name="dstCodes" select="'acbdqu4'"/>
                </xsl:call-template>
            </datafield>
        </xsl:for-each>
    </xsl:template>

    <xsl:template name="copy-indicators">
        <!--Traitements spécifiques sur les indicateurs de certaines zones en fonction du paramètre dstTag-->
        <xsl:param name="dstTag"/>
        <xsl:attribute name="ind1">
            <xsl:choose>
                <xsl:when test="$dstTag = 024">7</xsl:when>
                <xsl:when test="$dstTag = 300">#</xsl:when>
                <xsl:when test="$dstTag = 305">#</xsl:when>
                <xsl:when test="$dstTag = 310">#</xsl:when>
                <xsl:when test="$dstTag = 320">#</xsl:when>
                <xsl:when test="$dstTag = 330">#</xsl:when>
                <xsl:when test="$dstTag = 340">#</xsl:when>
                
                <xsl:when test="$dstTag = 100">
                    <xsl:choose>
                        <xsl:when test="@ind1 = ' '">
                            <xsl:value-of select="@ind2"/>
                        </xsl:when>
                        <xsl:when test="@ind1 = '|'">
                            <xsl:value-of select="@ind2"/>
                        </xsl:when>
                        <xsl:when test="@ind1 = '#'">
                            <xsl:value-of select="@ind2"/>
                        </xsl:when>
                    </xsl:choose>
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
              
                 <xsl:when test="$dstTag = 100">
                    <xsl:choose>
                        <xsl:when test="@ind1=' '">
                            <xsl:value-of select="@ind1"/>
                        </xsl:when>
                        <xsl:when test="@ind1='|'">
                            <xsl:value-of select="@ind1"/>
                        </xsl:when>
                        <xsl:when test="@ind1='#'">
                            <xsl:value-of select="@ind1"/>
                        </xsl:when>
                    </xsl:choose>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="translate(@ind2, '#', '')"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:attribute>
    </xsl:template>
    
    <xsl:template name="transform-subfields">
        <xsl:param name="srcCodes" select="$all-codes"/>
        <xsl:param name="dstCodes" select="$srcCodes"/>
        <xsl:for-each select="subfield[contains($srcCodes, @code)]">
            <subfield code="{translate(@code, $srcCodes, $dstCodes)}">
                <xsl:value-of select="text()"/>
            </subfield>
        </xsl:for-each>
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
    <xsl:variable name="all-codes">abcdefghijklmnopqrstuvwxyz123456789</xsl:variable>
</xsl:stylesheet>
