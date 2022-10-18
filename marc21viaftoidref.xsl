<?xml version="1.0" encoding="UTF-8"?>

<!--     XSL de transformation du marc21Xml en marcXml Sudoc.
    Objectifs : rendre conforme au marcXml Sudoc :
    v 20221001
  -->
<xsl:stylesheet exclude-result-prefixes="srw  mx mxc xsi xs" version="2.0"
    xmlns:mxc="info:lc/xmlns/marcxchange-v2" xmlns:srw="http://www.loc.gov/zing/srw/"
    xmlns="http://www.w3.org/TR/xhtml1/strict" xmlns:mx="http://www.loc.gov/MARC21/slim"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
    <xsl:output encoding="UTF-8" indent="yes" method="xml"/>
    <xsl:param name="token"/>
    <xsl:param name="idviaf"/>
    <xsl:strip-space elements="*"/>
    <xsl:variable name="dateJour">
        <xsl:value-of select="format-date(current-date(), '[Y0001][M01][D01]')"/>
    </xsl:variable>
    <xsl:template match="/">
        <soap:Envelope xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/"
            xmlns:xsd="http://www.w3.org/2001/XMLSchema"
            xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
            <soap:Body>
                <ucp:updateRequest xmlns:srw="http://www.loc.gov/zing/srw/"
                    xmlns:ucp="http://www.loc.gov/zing/srw/update/">
                    <srw:version>1.0</srw:version>
                    <ucp:action>info:srw/action/1/creaute</ucp:action>
                    <srw:recordIdentifier/>
                    <ucp:recordVersions>
                        <ucp:recordVersion>
                            <ucp:versionType>timestamp</ucp:versionType>
                            <ucp:versionValue>124578</ucp:versionValue>
                        </ucp:recordVersion>
                    </ucp:recordVersions>
                    <srw:record>
                        <srw:recordPacking>xml</srw:recordPacking>
                        <srw:recordSchema>info:srw/schema/1/marcxml-v1.1</srw:recordSchema>
                        <srw:recordData>
                            <xsl:apply-templates select="mx:record"/>
                        </srw:recordData>
                    </srw:record>
                </ucp:updateRequest>
                <srw:extraRequestData>
                    <srw:authenticationToken>
                        <xsl:value-of select="$token"/>
                    </srw:authenticationToken>
                </srw:extraRequestData>
            </soap:Body>
        </soap:Envelope>
    </xsl:template>
    	
	<xsl:template match="mx:record">
					<record>
<!--						<xsl:for-each select="mx:leader">
							<leader>
								<xsl:variable name="recordLenght">00000</xsl:variable>
								<xsl:variable name="recordStatus">
									<xsl:choose>
										<xsl:when test="substring(text(), 6, 1) = 'a'">c</xsl:when>
										<xsl:when test="substring(text(), 6, 1) = 's'">d</xsl:when>
										<xsl:when test="substring(text(), 6, 1) = 'x'">d</xsl:when>
										<!-\- problem: obsolete record conversion -\->
										<xsl:when test="substring(text(), 6, 1) = 'o'">d</xsl:when>
										<xsl:otherwise>
											<xsl:value-of select="substring(text(), 6, 1)"/>
										</xsl:otherwise>
									</xsl:choose>
								</xsl:variable>
								<xsl:variable name="recordType">
									<xsl:value-of select="substring(text(), 7, 1)"/>
								</xsl:variable>
								<!-\- Fixme: add Type of Entity -\->
								<xsl:variable name="entityType">
									<xsl:value-of select="' '"/>
								</xsl:variable>
								<xsl:variable name="baseAddressOfData">02200</xsl:variable>
								<xsl:variable name="encodingLevel">
									<xsl:choose>
										<xsl:when test="substring(text(), 18, 1) = 'n'"> </xsl:when>
										<xsl:when test="substring(text(), 18, 1) = 'o'">3</xsl:when>
										<xsl:otherwise>
											<xsl:value-of select="' '"/>
										</xsl:otherwise>
									</xsl:choose>
								</xsl:variable>
								<!-\- use 18 Punctuation policy? -\->
								<xsl:value-of
									select="concat($recordLenght, $recordStatus, $recordType, '  ', $entityType, '22', $baseAddressOfData, $encodingLevel, '  45  ')"/>
							</leader>
						</xsl:for-each>-->
						<!--  <xsl:for-each select="mx:controlfield[@tag = '001']">
							<controlfield tag="001">
								<xsl:value-of select="text()"/>
							</controlfield>
						</xsl:for-each>
						<xsl:for-each select="mx:controlfield[@tag = '005']">
							<controlfield tag="005">
								<xsl:value-of select="text()"/>
							</controlfield>
						</xsl:for-each>-->
					    
					    <!--Ajout FML -->					    
					    <datafield tag="008">
					        <subfield code="a">
					            <xsl:value-of
					                select="'Tp5'"/>
					        </subfield>
					    </datafield>
											
						
<!--						<!-\-Ajout FML -\->						
						<xsl:for-each select="mx:controlfield[@tag = '001']">
							<datafield tag="035" ind1="#" ind2="#">
									<subfield code="a">
										<xsl:value-of select="text()"/>
									</subfield>
									</datafield>
						</xsl:for-each>
						
						<!-\-Ajout FML : l'idviaf venant du JAVA -\->	
						<datafield ind1="#" ind2="#" tag="035">							
							<subfield code="a">
								<xsl:value-of select="$idviaf"/>
							</subfield>
							<subfield code="2">
								<xsl:text>VIAF</xsl:text>
							</subfield>
							<subfield code="C">
								<xsl:text>VIAF</xsl:text>
							</subfield>
							<subfield code="d">
								<xsl:value-of select="$dateJour"/>
							</subfield>
							
						</datafield>-->
						
						
						
					<!--	<xsl:for-each select="mx:datafield[@tag = '035']">
							<datafield tag="035" ind1="#" ind2="#">
								<xsl:for-each select="mx:subfield[@code = 'a']">
									<subfield code="a">
										<xsl:value-of select="text()"/>
									</subfield>
								</xsl:for-each>
								<xsl:for-each select="mx:subfield[@code = 'z']">
									<subfield code="z">
										<xsl:value-of select="text()"/>
									</subfield>
								</xsl:for-each>
							</datafield>
						</xsl:for-each>-->
						
						<xsl:for-each select="mx:controlfield[@tag = '008']">
							<!--<datafield tag="100" ind1=" " ind2=" ">
								<subfield code="a">
									<xsl:variable name="dateEnteredOnFile">
										<xsl:choose>
											<xsl:when test="substring(text(), 1, 2) &lt; 70">
												<xsl:value-of select="concat('20', substring(text(), 1, 6))"/>
											</xsl:when>
											<xsl:otherwise>
												<xsl:value-of select="concat('19', substring(text(), 1, 6))"/>
											</xsl:otherwise>
										</xsl:choose>
									</xsl:variable>
									<xsl:variable name="establishmentLevel">
										<xsl:choose>
											<xsl:when test="substring(text(), 34, 1) = 'b'">a</xsl:when>
											<xsl:when test="substring(text(), 34, 1) = 'd'">c</xsl:when>
											<xsl:when test="substring(text(), 34, 1) = 'n'">x</xsl:when>
											<xsl:otherwise>
												<xsl:value-of select="substring(text(), 34, 1)"/>
											</xsl:otherwise>
										</xsl:choose>
									</xsl:variable>
									<xsl:variable name="cataloguingLanguage">
										<xsl:choose>
											<xsl:when test="datafield[@tag = '040']/subfield[@code = 'b']">
												<xsl:value-of select="mx:datafield[@tag = '040']/subfield[@code = 'b']" />
											</xsl:when>
											<xsl:otherwise>
												<xsl:choose>
													<xsl:when test="substring(text(), 34, 1) = 'b'">eng</xsl:when>
													<xsl:when test="substring(text(), 34, 1) = 'e'">eng</xsl:when>
													<xsl:when test="substring(text(), 34, 1) = 'f'">fre</xsl:when>
													<xsl:otherwise>-->
														<!-- Expected default for MARC21 -->
						<!-- <xsl:value-of select="'eng'"/>
													</xsl:otherwise>
												</xsl:choose>
											</xsl:otherwise>
										</xsl:choose>
									</xsl:variable>
									<xsl:variable name="transliterationCode">
										<xsl:choose>
											<xsl:when test="substring(text(), 8, 1) = 'a'">a</xsl:when>
											<xsl:when test="substring(text(), 8, 1) = 'b'">b</xsl:when>
											<xsl:when test="substring(text(), 8, 1) = 'c'">b</xsl:when>
											<xsl:when test="substring(text(), 8, 1) = 'd'">d</xsl:when>
											<xsl:when test="substring(text(), 8, 1) = 'e'">b</xsl:when>
											<xsl:when test="substring(text(), 8, 1) = 'f'">f</xsl:when>
											<xsl:when test="substring(text(), 8, 1) = 'g'">f</xsl:when>
											<xsl:when test="substring(text(), 8, 1) = 'n'">y</xsl:when>
											<xsl:otherwise> </xsl:otherwise>
										</xsl:choose>
									</xsl:variable>
									<xsl:variable name="characterSet">
										<xsl:choose>
											<xsl:when test="substring(../mx:leader, 10, 1) = 'a'">50  </xsl:when>-->
											<!-- what if MARC-8 encoding, and not UTF8? -->
						<!-- <xsl:otherwise>
												<xsl:value-of select="'    '"/>
											</xsl:otherwise>
										</xsl:choose>
									</xsl:variable>
									<xsl:variable name="additionalCharacterSet">
										<xsl:value-of select="'    '"/>
									</xsl:variable>-->
									<!-- Fixme Script of Cataloguing -->
						<!--<xsl:variable name="cataloguingScript">
										<xsl:value-of select="'  '"/>
									</xsl:variable>-->
									<!-- Fixme Direction of Script of Cataloguing -->
						<!--<xsl:variable name="scriptDirection">
										<xsl:value-of select="'1'"/>
									</xsl:variable>
									<xsl:value-of
										select="concat($dateEnteredOnFile, $establishmentLevel, 
											$cataloguingLanguage, $transliterationCode, 
											$characterSet, $additionalCharacterSet, 
											$cataloguingScript, $scriptDirection)"
									/>
								</subfield>
							</datafield> -->
						<!--<datafield tag="106" ind1=" " ind2=" ">
								<subfield code="a">
									<xsl:choose>
										<xsl:when test="substring(text(), 15, 1) = 'b'">
											<xsl:value-of select="'2'"/>
										</xsl:when>
										<xsl:when test="substring(text(), 16, 1) = 'a'">
											<xsl:value-of select="'0'"/>
										</xsl:when>
										<xsl:when test="substring(text(), 16, 1) = 'b'">
											<xsl:value-of select="'1'"/>
										</xsl:when>
									</xsl:choose>
								</subfield>
								<!-\- fixme complete conversion -\->
							</datafield>-->
							<datafield tag="120" ind1="#" ind2="#">
								<subfield code="a">
									<xsl:choose>
										<xsl:when test="substring(text(), 33, 1) = 'a'">a</xsl:when>
										<xsl:when test="substring(text(), 33, 1) = 'b'">b</xsl:when>
									</xsl:choose>
								</subfield>
							</datafield>
							<!--<datafield tag="150" ind1=" " ind2=" ">
								<subfield code="a">
									<xsl:value-of select="translate (substring(text(), 29, 1), ' acfilmosuz',  'ybeafdehcuz')"/>
								</subfield>
							</datafield>-->
							<!--<datafield tag="152" ind1=" " ind2=" ">
								<subfield code="a">
									<xsl:choose>-->
										<!-- fixme complete conversion -->
							<!--<xsl:when test="substring(text(), 11, 1) = 'c'">
											<xsl:value-of select="'AACR2'"/>
										</xsl:when>
									</xsl:choose>
								</subfield>
								<subfield code="b">
									<xsl:choose>
										<xsl:when test="substring(text(), 12, 1) = 'a'">
											<xsl:value-of select="'lc'"/>
										</xsl:when>
										<xsl:when test="substring(text(), 12, 1) = 'b'">
											<xsl:value-of select="'lcch'"/>
										</xsl:when>
										<xsl:when test="substring(text(), 12, 1) = 'c'">
											<xsl:value-of select="'mesh'"/>
										</xsl:when>
										<xsl:when test="substring(text(), 12, 1) = 'd'">
											<xsl:value-of select="'nal'"/>
										</xsl:when>
										<xsl:when test="substring(text(), 12, 1) = 'e' and substring(text(), 9, 1) = 'e'">
											<xsl:value-of select="'cae'"/>
										</xsl:when>
										<xsl:when test="substring(text(), 12, 1) = 'e' and substring(text(), 9, 1) = 'f'">
											<xsl:value-of select="'caf'"/>
										</xsl:when> -->
										<!-- What to do if thesaurus source is not specified (substring(text(), 12, 1) = 'd')?  -->
										<!-- What to do if Art and Architecture Thesaurus (substring(text(), 12, 1) = 'r')? -->
							<!-- <xsl:when test="substring(text(), 12, 1) = 's'">
											<xsl:value-of select="'sears'"/>
										</xsl:when> -->
										<!-- What to do if Répertoire de vedettes-matière (substring(text(), 12, 1) = 'v')? -->
							<!-- <xsl:when test="substring(text(), 12, 1) = 'z'">
											<xsl:value-of select="'local'"/>
										</xsl:when>
									</xsl:choose>
								</subfield>
								</datafield> -->
							<!--<datafield tag="154" ind1=" " ind2=" ">
								<subfield code="a">
									<xsl:value-of select="concat(translate(substring(text(), 13, 1), 'n', 'x'), ' ')"/>
								</subfield>
							</datafield>-->
						</xsl:for-each>
						
						<!--	Ajout FML-->
						<datafield ind1="#" ind2="#" tag="106">
										<subfield code="a">0</subfield>
										<subfield code="b">1</subfield>
										<subfield code="c">0</subfield>
					    </datafield>
						
						<!--	Ajout FML  -->
						
						<xsl:for-each select="mx:datafield[@tag = '046']">
							<datafield tag="103" ind1="#" ind2="#">
								<xsl:for-each select="mx:subfield[@code = 'f']">
									<subfield code="a">
										<xsl:value-of select="translate(.,'-', '')"/>
									</subfield>
								</xsl:for-each>
								<xsl:for-each select="mx:subfield[@code = 'g']">
									<subfield code="b">
										<xsl:value-of select="translate(.,'-', '')"/>
									</subfield>
								</xsl:for-each>
								<xsl:for-each select="mx:subfield[@code = 's']">
									<subfield code="c">
										<xsl:value-of select="translate(.,'-', '')"/>
									</subfield>
								</xsl:for-each>
								<xsl:for-each select="mx:subfield[@code = 't']">
									<subfield code="d">
										<xsl:value-of select="translate(.,'-', '')"/>
									</subfield>
								</xsl:for-each>
							</datafield>
						</xsl:for-each>
						
						<!--	Ajout FML-->						
						<xsl:for-each select="mx:datafield[@tag = '377']">
							<datafield tag="101" ind1="#" ind2="#">
								<xsl:for-each select="mx:subfield[@code = 'a']">
									<subfield code="a">
										<xsl:value-of select="text()"/>
									</subfield>
								</xsl:for-each>
							</datafield>
						</xsl:for-each>
						
						<!--	Ajout FML-->										
						<xsl:for-each select="mx:datafield[@tag = '043']">
							<datafield tag="102" ind1="#" ind2="#">
								<xsl:for-each select="mx:subfield[@code = 'c']">
									<subfield code="a">
										<xsl:value-of select="text()"/>
									</subfield>
								</xsl:for-each>
							</datafield>
						</xsl:for-each>
						

						<xsl:for-each select="mx:datafield[@tag = '100']">
							<xsl:choose>
								<xsl:when test="@ind1 != 3" >
									<datafield tag="200" ind1="#">
										<xsl:call-template name="convertPersonalNameSubfields">
											<xsl:with-param name="field" select="."/>
										</xsl:call-template>
									</datafield>
								</xsl:when>
								<xsl:otherwise>
									<datafield tag="720" ind1=" " ind2=" ">
										<xsl:for-each select="mx:subfield[@code = 'a']">
											<subfield code="a">
												<xsl:value-of select="text()"/>
											</subfield>
										</xsl:for-each>
										<xsl:for-each select="mx:subfield[@code = 'd']">
											<subfield code="f">
												<xsl:value-of select="text()"/>
											</subfield>
										</xsl:for-each>
										<xsl:for-each select="mx:subfield[@code = '4']">
											<subfield code="4">
												<xsl:value-of select="text()"/>
											</subfield>
										</xsl:for-each>
									</datafield>
								</xsl:otherwise>
							</xsl:choose>
						</xsl:for-each>
						<xsl:for-each select="mx:datafield[@tag = '400']">
							<datafield tag="400" ind1="#">
								<xsl:choose>
									<xsl:when test="@ind1 != 3" >
										<xsl:call-template name="convertPersonalNameSubfields">
											<xsl:with-param name="field" select="."/>
										</xsl:call-template>
									</xsl:when>
								</xsl:choose>
							</datafield>
						</xsl:for-each>
						<xsl:for-each select="mx:datafield[@tag = '400']">
							<datafield tag="700" ind1="#">
								<xsl:choose>
									<xsl:when test="@ind1 != 3" >
										<xsl:call-template name="convertPersonalNameSubfields">
											<xsl:with-param name="field" select="."/>
										</xsl:call-template>
									</xsl:when>
								</xsl:choose>
							</datafield>
						</xsl:for-each>
						<!-- <xsl:for-each select="mx:datafield[@tag = '040']">
							<xsl:for-each select="mx:subfield[@code = 'a']">
								<datafield tag="801" ind1=" " ind2="0">
									<subfield code="a">
										<xsl:call-template name="getCountryFromMarcOrgCode">
											<xsl:with-param name="marcOrgCode" select="text()" />
										</xsl:call-template>
									</subfield>
									<subfield code="b">
										<xsl:value-of select="text()"/>
									</subfield>
								</datafield>
							</xsl:for-each>
							<xsl:for-each select="mx:subfield[@code = 'c']">
								<datafield tag="801" ind1=" " ind2="1">
									<subfield code="a">
										<xsl:call-template name="getCountryFromMarcOrgCode">
											<xsl:with-param name="marcOrgCode" select="text()" />
										</xsl:call-template>
									</subfield>
									<subfield code="b">
										<xsl:value-of select="text()"/>
									</subfield>
								</datafield>
							</xsl:for-each>
							<xsl:for-each select="mx:subfield[@code = 'd']">
								<datafield tag="801" ind1=" " ind2="2">
									<subfield code="a">
										<xsl:call-template name="getCountryFromMarcOrgCode">
											<xsl:with-param name="marcOrgCode" select="text()" />
										</xsl:call-template>
									</subfield>
									<subfield code="b">
										<xsl:value-of select="text()"/>
									</subfield>
								</datafield>
							</xsl:for-each>
						</xsl:for-each> -->
						<xsl:for-each select="mx:datafield[@tag = '670']">
							<datafield tag="810" ind1="#" ind2="#">
								<xsl:for-each select="mx:subfield[@code = 'a']">
									<subfield code="a">
										<xsl:value-of select="text()"/>
									</subfield>
								</xsl:for-each>
								<xsl:for-each select="mx:subfield[@code = 'b']">
									<subfield code="b">
										<xsl:value-of select="text()"/>
									</subfield>
								</xsl:for-each>
							</datafield>
						</xsl:for-each>
						<xsl:for-each select="mx:datafield[@tag = '667']">
							<datafield tag="830" ind1="#" ind2="#">
								<xsl:for-each select="mx:subfield[@code = 'a']">
									<subfield code="a">
										<xsl:value-of select="text()"/>
									</subfield>
								</xsl:for-each>
							</datafield>
						</xsl:for-each>
						
						<datafield ind1="#" ind2="#" tag="899">
							<xsl:variable name="dateJour2">
								<xsl:value-of select="format-date(current-date(), '[D01]/[M01]/[Y0001]')"/>
							</xsl:variable>
							<subfield code="a">
								<xsl:value-of
									select="concat('Notice issue de VIAF dérivée via IdRef, le ', $dateJour2)"/>
							</subfield>
						</datafield>

						<xsl:call-template name="datafield856" />
						
	</record>
    </xsl:template>
    
    <xsl:template name="convertPersonalNameSubfields">
        <xsl:param name="field"></xsl:param>
        <xsl:attribute name="ind2">
            <xsl:value-of select="@ind1"/>
        </xsl:attribute>
        <xsl:for-each select="mx:subfield[@code = 'a']">
            <xsl:choose>
                <xsl:when test="contains(text(), ', ')">
                    <subfield code="a">
                        <xsl:value-of select="substring-before(text(), ', ')"/>
                    </subfield>
                    <subfield code="b" >
                        <xsl:call-template name="removeEndPuctuation">
                            <xsl:with-param name="text" select="substring-after(text(), ', ')"/>
                        </xsl:call-template>
                    </subfield>
                </xsl:when>
                <xsl:otherwise>
                    <subfield code="a" >
                        <xsl:call-template name="removeEndPuctuation">
                            <xsl:with-param name="text" select="text()"/>
                        </xsl:call-template>
                    </subfield>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:for-each>
        <xsl:for-each select="mx:subfield[@code = 'b']">
            <subfield code="d" >
                <xsl:call-template name="removeEndPuctuation">
                    <xsl:with-param name="text" select="text()"/>
                </xsl:call-template>
            </subfield>
        </xsl:for-each>
        <xsl:for-each select="mx:subfield[@code = 'c']">
            <subfield code="c" >
                <xsl:value-of select="text()"/>
            </subfield>
        </xsl:for-each>
        <xsl:for-each select="mx:subfield[@code = 'd']">
            <subfield code="f" >
                <xsl:call-template name="removeEndPuctuation">
                    <xsl:with-param name="text" select="text()"/>
                </xsl:call-template>
            </subfield>
        </xsl:for-each>
        <xsl:for-each select="mx:subfield[@code = 'e']">
            <subfield code="4" >
                <xsl:value-of select="text()"/>
            </subfield>
        </xsl:for-each>
        <xsl:for-each select="mx:subfield[@code = 'q']">
            <subfield code="g" >
                <xsl:call-template name="removeEndPuctuation">
                    <xsl:with-param name="text" select="text()"/>
                </xsl:call-template>
            </subfield>
        </xsl:for-each>
        <xsl:for-each select="mx:subfield[@code = 'u']">
            <subfield code="p" >
                <xsl:value-of select="text()"/>
            </subfield>
        </xsl:for-each>
        <!--<xsl:for-each select="mx:subfield[@code='?']"><subfield code="3"><xsl:value-of select="text()" /></subfield></xsl:for-each>-->
        <xsl:for-each select="mx:subfield[@code = '4']">
            <subfield code="4" >
                <xsl:value-of select="text()"/>
            </subfield>
        </xsl:for-each>
    </xsl:template>
    
    <xsl:template name="tokenizeSubfield">
        <!--passed template parameter -->
        <xsl:param name="list"/>
        <xsl:param name="delimiter"/>
        <xsl:param name="code"/>
        <xsl:choose>
            <xsl:when test="contains($list, $delimiter) and substring-after($list,$delimiter) != ''">
                <subfield >
                    <xsl:attribute name="code">
                        <xsl:value-of select="$code" />
                    </xsl:attribute>
                    <!-- get everything in front of the first delimiter -->
                    <xsl:value-of select="substring-before($list,$delimiter)"/>
                </subfield>
                <xsl:call-template name="tokenizeSubfield">
                    <!-- store anything left in another variable -->
                    <xsl:with-param name="list" select="normalize-space(substring-after($list,$delimiter))"/>
                    <xsl:with-param name="delimiter" select="$delimiter"/>
                    <xsl:with-param name="code" select="$code"/>
                </xsl:call-template>
            </xsl:when>
            <xsl:otherwise>
                <xsl:choose>
                    <xsl:when test="$list = ''"/>
                    <xsl:otherwise>
                        <subfield >
                            <xsl:attribute name="code">
                                <xsl:value-of select="$code" />
                            </xsl:attribute>
                            <xsl:call-template name="removeEndPuctuation">
                                <xsl:with-param name="text" select="$list"/>
                            </xsl:call-template>
                            
                        </subfield>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <xsl:template name="removeEndPuctuation">
        <xsl:param name="text"/>
        <xsl:choose>
            <xsl:when test="string-length(translate(substring($text, string-length($text)), ' ,.:;/', '')) = 0">
                <xsl:value-of
                    select="normalize-space(substring($text, 1, string-length($text)-1))"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of
                    select="$text"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <xsl:template name="datafield856">
        <xsl:for-each select="mx:datafield[@tag=856]">
            <datafield tag="856" >
                <xsl:attribute name="ind1">
                    <xsl:value-of select="@ind1"/>
                </xsl:attribute>
                <xsl:attribute name="ind2">
                    <xsl:value-of select="@ind2"/>
                </xsl:attribute>
                <xsl:for-each select="mx:subfield[@code]">
                    <subfield>
                        <xsl:attribute name="code">
                            <xsl:choose>
                                <xsl:when test="@code = 3">
                                    <xsl:value-of select="2" />
                                </xsl:when>
                                <xsl:when test="@code = 2">
                                    <xsl:value-of select="y" />
                                </xsl:when>
                                <xsl:when test="@code = y">
                                    <xsl:value-of select="2" />
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:value-of select="@code" />
                                </xsl:otherwise>
                            </xsl:choose>
                        </xsl:attribute>
                        <xsl:value-of select="text()"/>
                    </subfield>
                </xsl:for-each>
            </datafield>
        </xsl:for-each>
    </xsl:template>
    
    <xsl:template name="getCountryFromMarcOrgCode">
        <xsl:param name="marcOrgCode" select="text()" />
        <xsl:choose>
            <xsl:when test="substring($marcOrgCode, 3, 1) = '-'">
                <xsl:value-of select="substring($marcOrgCode, 1, 2)"/>
            </xsl:when>
            <xsl:when test="$marcOrgCode = 'DLC'">
                <xsl:value-of select="'US'"/>
            </xsl:when>
        </xsl:choose>
    </xsl:template>
   
    
</xsl:stylesheet>
