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
                <xsl:value-of select="concat('IDREF', $z001)"/>
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
        <xsl:call-template name="transform-datafield">
            <xsl:with-param name="srcTag">102</xsl:with-param>
            <xsl:with-param name="dstTag">370</xsl:with-param>
            <xsl:with-param name="srcCodes">a</xsl:with-param>
            <xsl:with-param name="dstCodes">c</xsl:with-param>
            <!--        il faut générer en plus un $2 ISO 3166-1 -->
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
        <xsl:call-template name="transform-datafield">
            <xsl:with-param name="srcTag">120</xsl:with-param>
            <xsl:with-param name="dstTag">375</xsl:with-param>
        </xsl:call-template>
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
        <xsl:call-template name="transform-datafield">
            <xsl:with-param name="srcTag">160</xsl:with-param>
            <xsl:with-param name="dstTag">043</xsl:with-param>
        </xsl:call-template>
        <!-- 180 pas d'équivalent -->
        <!-- Bloc des points d'accès 2XX : NOK car trop sommaire mais OK pour test -->
        <!-- 200->100 -->
        <xsl:call-template name="transform-datafield">
            <xsl:with-param name="srcTag">200</xsl:with-param>
            <xsl:with-param name="dstTag">100</xsl:with-param>
            <xsl:with-param name="srcCodes">abfc</xsl:with-param>
            <xsl:with-param name="dstCodes">ach</xsl:with-param>
        </xsl:call-template>
        <!-- 210->110 -->
        <xsl:call-template name="transform-datafield">
            <xsl:with-param name="srcTag">210</xsl:with-param>
            <xsl:with-param name="dstTag">110</xsl:with-param>
            <xsl:with-param name="srcCodes">acd</xsl:with-param>
            <xsl:with-param name="dstCodes">abc</xsl:with-param>
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
            <xsl:with-param name="dstCodes">agxzy</xsl:with-param>
        </xsl:call-template>
        <!-- 220->100 -->
        <xsl:call-template name="transform-datafield">
            <xsl:with-param name="srcTag">220</xsl:with-param>
            <xsl:with-param name="dstTag">100</xsl:with-param>
            <xsl:with-param name="srcCodes">afxyz</xsl:with-param>
            <xsl:with-param name="dstCodes">adxzy</xsl:with-param>
        </xsl:call-template>
        <!-- 230->130 -->
        <xsl:call-template name="transform-datafield">
            <xsl:with-param name="srcTag">230</xsl:with-param>
            <xsl:with-param name="dstTag">130</xsl:with-param>
            <xsl:with-param name="srcCodes">a</xsl:with-param>
            <xsl:with-param name="dstCodes">a</xsl:with-param>
        </xsl:call-template>
        <!-- RIEN à propose de 231/232 ?  -->
        <!-- 240->100 -->
        <xsl:call-template name="transform-datafield">
            <xsl:with-param name="srcTag">240</xsl:with-param>
            <xsl:with-param name="dstTag">100</xsl:with-param>
            <xsl:with-param name="srcCodes">at</xsl:with-param>
            <xsl:with-param name="dstCodes">at</xsl:with-param>
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
        </xsl:call-template>
        <!-- 330->680 -->
        <xsl:call-template name="transform-datafield">
            <xsl:with-param name="srcTag">330</xsl:with-param>
            <xsl:with-param name="dstTag">680</xsl:with-param>
        </xsl:call-template>
        <!-- 340->678 -->
        <xsl:call-template name="transform-datafield">
            <xsl:with-param name="srcTag">340</xsl:with-param>
            <xsl:with-param name="dstTag">678</xsl:with-param>
        </xsl:call-template>
        <!-- 356->680 -->
        <xsl:call-template name="transform-datafield">
            <xsl:with-param name="srcTag">356</xsl:with-param>
            <xsl:with-param name="dstTag">680</xsl:with-param>
        </xsl:call-template>
        <!-- Bloc des 4XX -->
        <!-- Bloc des 5XX -->
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
        <xsl:variable name="leader17" select="translate(substring($leader, 18, 1), '#', 'n')"/>
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
        <!-- Création de la zone 075 à partir de la position 9 du leader-->
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
        <xsl:variable name="dest07" select="' '"> </xsl:variable>
        <xsl:variable name="dest08">
            <xsl:choose>
                <xsl:when test="substring($source100,10,3) = 'fre'">
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
        <xsl:variable name="dest10-14" select="'     '"> </xsl:variable>
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
        <xsl:variable name="dest16-31">            
                    <xsl:text>               </xsl:text>
        </xsl:variable>
        <xsl:variable name="dest32">
            <xsl:choose>
                <xsl:when test="$source120 != ''">
                    <xsl:value-of select="substring($source120,1,1)"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:text> </xsl:text>
                </xsl:otherwise>
            </xsl:choose>      
        </xsl:variable>      
        <controlfield tag="008">           
            <xsl:value-of select="concat($dest00-05, $dest06,$dest07, $dest08, $dest09,$dest10-14,$dest15,$dest16-31,$dest32)"/>
        </controlfield>
    </xsl:template>
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
        <!--ERM ajout du parametre dstTag pour faire des traitements spécifiques sur les indicateurs de certaines zones-->
        <xsl:param name="dstTag"/>
        <xsl:attribute name="ind1">
            <xsl:choose>
                <xsl:when test="$dstTag = 024">7</xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="translate(@ind1, '#', '')"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:attribute>
        <xsl:attribute name="ind2">
            <xsl:value-of select="translate(@ind2, '#', '')"/>
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
    <!--FML ajout Mapping des codes types d'autorités-->
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
