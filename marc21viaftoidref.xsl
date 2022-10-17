<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" exclude-result-prefixes="marc"
	xmlns="http://www.loc.gov/MARC21/slim"
	xmlns:marc="http://www.loc.gov/MARC21/slim"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
	<xsl:output method="xml" version="1.0" encoding="UTF-8" indent="yes"/>
	
	<!--ERM initialisation du paramètre transmis par le programme java, faut-il une valeur par défaut ? -->		
<xsl:param name="idviaf" select="'bidon'" />
	
	<xsl:template match="/">
				<xsl:for-each select="marc:record">
					<record type="Authority" format="UNIMARC">
						<xsl:for-each select="marc:leader">
							<leader>
								<xsl:variable name="recordLenght">00000</xsl:variable>
								<xsl:variable name="recordStatus">
									<xsl:choose>
										<xsl:when test="substring(text(), 6, 1) = 'a'">c</xsl:when>
										<xsl:when test="substring(text(), 6, 1) = 's'">d</xsl:when>
										<xsl:when test="substring(text(), 6, 1) = 'x'">d</xsl:when>
										<!-- problem: obsolete record conversion -->
										<xsl:when test="substring(text(), 6, 1) = 'o'">d</xsl:when>
										<xsl:otherwise>
											<xsl:value-of select="substring(text(), 6, 1)"/>
										</xsl:otherwise>
									</xsl:choose>
								</xsl:variable>
								<xsl:variable name="recordType">
									<xsl:value-of select="substring(text(), 7, 1)"/>
								</xsl:variable>
								<!-- Fixme: add Type of Entity -->
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
								<!-- use 18 Punctuation policy? -->
								<xsl:value-of
									select="concat($recordLenght, $recordStatus, $recordType, '  ', $entityType, '22', $baseAddressOfData, $encodingLevel, '  45  ')"/>
							</leader>
						</xsl:for-each>
						<!--  <xsl:for-each select="marc:controlfield[@tag = '001']">
							<controlfield tag="001">
								<xsl:value-of select="text()"/>
							</controlfield>
						</xsl:for-each>
						<xsl:for-each select="marc:controlfield[@tag = '005']">
							<controlfield tag="005">
								<xsl:value-of select="text()"/>
							</controlfield>
						</xsl:for-each>-->
						<!--Ajout FML -->						
						<xsl:for-each select="marc:controlfield[@tag = '001']">
									<datafield tag="035" ind1=" " ind2=" ">
									<subfield code="a">
										<xsl:value-of select="text()"/>
									</subfield>
									</datafield>
						</xsl:for-each>
						
						<!--Ajout FML : besoin d'aide pour récupérer l'idviaf venant du JAVA -->	
						<datafield ind1="#" ind2="#" tag="035">							
							<subfield code="a">
								<xsl:value-of select="$idviaf"/>
							</subfield>
						</datafield>
						
						
						
						<xsl:for-each select="marc:datafield[@tag = '035']">
							<datafield tag="035" ind1=" " ind2=" ">
								<xsl:for-each select="marc:subfield[@code = 'a']">
									<subfield code="a">
										<xsl:value-of select="text()"/>
									</subfield>
								</xsl:for-each>
								<xsl:for-each select="marc:subfield[@code = 'z']">
									<subfield code="z">
										<xsl:value-of select="text()"/>
									</subfield>
								</xsl:for-each>
							</datafield>
						</xsl:for-each>
						
						<xsl:for-each select="marc:controlfield[@tag = '008']">
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
												<xsl:value-of select="marc:datafield[@tag = '040']/subfield[@code = 'b']" />
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
											<xsl:when test="substring(../marc:leader, 10, 1) = 'a'">50  </xsl:when>-->
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
							<datafield tag="120" ind1=" " ind2=" ">
								<subfield code="a">
									<xsl:choose>
										<xsl:when test="substring(text(), 33, 1) = 'a'"> a</xsl:when>
										<xsl:when test="substring(text(), 33, 1) = 'b'"> b</xsl:when>
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
						
						<xsl:for-each select="marc:datafield[@tag = '046']">
							<datafield tag="103" ind1=" " ind2=" ">
								<xsl:for-each select="marc:subfield[@code = 'f']">
									<subfield code="a">
										<xsl:value-of select="translate(.,'-', '')"/>
									</subfield>
								</xsl:for-each>
								<xsl:for-each select="marc:subfield[@code = 'g']">
									<subfield code="b">
										<xsl:value-of select="translate(.,'-', '')"/>
									</subfield>
								</xsl:for-each>
								<xsl:for-each select="marc:subfield[@code = 's']">
									<subfield code="c">
										<xsl:value-of select="translate(.,'-', '')"/>
									</subfield>
								</xsl:for-each>
								<xsl:for-each select="marc:subfield[@code = 't']">
									<subfield code="d">
										<xsl:value-of select="translate(.,'-', '')"/>
									</subfield>
								</xsl:for-each>
							</datafield>
						</xsl:for-each>
						
						<!--	Ajout FML-->						
						<xsl:for-each select="marc:datafield[@tag = '377']">
							<datafield tag="101" ind1=" " ind2=" ">
								<xsl:for-each select="marc:subfield[@code = 'a']">
									<subfield code="a">
										<xsl:value-of select="text()"/>
									</subfield>
								</xsl:for-each>
							</datafield>
						</xsl:for-each>
						
						<!--	Ajout FML-->										
						<xsl:for-each select="marc:datafield[@tag = '043']">
							<datafield tag="102" ind1=" " ind2=" ">
								<xsl:for-each select="marc:subfield[@code = 'c']">
									<subfield code="a">
										<xsl:value-of select="text()"/>
									</subfield>
								</xsl:for-each>
							</datafield>
						</xsl:for-each>
						

						<xsl:for-each select="marc:datafield[@tag = '100']">
							<xsl:choose>
								<xsl:when test="@ind1 != 3" >
									<datafield tag="200" ind1=" ">
										<xsl:call-template name="convertPersonalNameSubfields">
											<xsl:with-param name="field" select="."/>
										</xsl:call-template>
									</datafield>
								</xsl:when>
								<xsl:otherwise>
									<datafield tag="720" ind1=" " ind2=" ">
										<xsl:for-each select="marc:subfield[@code = 'a']">
											<subfield code="a">
												<xsl:value-of select="text()"/>
											</subfield>
										</xsl:for-each>
										<xsl:for-each select="marc:subfield[@code = 'd']">
											<subfield code="f">
												<xsl:value-of select="text()"/>
											</subfield>
										</xsl:for-each>
										<xsl:for-each select="marc:subfield[@code = '4']">
											<subfield code="4">
												<xsl:value-of select="text()"/>
											</subfield>
										</xsl:for-each>
									</datafield>
								</xsl:otherwise>
							</xsl:choose>
						</xsl:for-each>
						<xsl:for-each select="marc:datafield[@tag = '400']">
							<datafield tag="400" ind1=" ">
								<xsl:choose>
									<xsl:when test="@ind1 != 3" >
										<xsl:call-template name="convertPersonalNameSubfields">
											<xsl:with-param name="field" select="."/>
										</xsl:call-template>
									</xsl:when>
								</xsl:choose>
							</datafield>
						</xsl:for-each>
						<xsl:for-each select="marc:datafield[@tag = '400']">
							<datafield tag="700" ind1=" ">
								<xsl:choose>
									<xsl:when test="@ind1 != 3" >
										<xsl:call-template name="convertPersonalNameSubfields">
											<xsl:with-param name="field" select="."/>
										</xsl:call-template>
									</xsl:when>
								</xsl:choose>
							</datafield>
						</xsl:for-each>
						<!-- <xsl:for-each select="marc:datafield[@tag = '040']">
							<xsl:for-each select="marc:subfield[@code = 'a']">
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
							<xsl:for-each select="marc:subfield[@code = 'c']">
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
							<xsl:for-each select="marc:subfield[@code = 'd']">
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
						<xsl:for-each select="marc:datafield[@tag = '670']">
							<datafield tag="810" ind1=" " ind2=" ">
								<xsl:for-each select="marc:subfield[@code = 'a']">
									<subfield code="a">
										<xsl:value-of select="text()"/>
									</subfield>
								</xsl:for-each>
								<xsl:for-each select="marc:subfield[@code = 'b']">
									<subfield code="b">
										<xsl:value-of select="text()"/>
									</subfield>
								</xsl:for-each>
							</datafield>
						</xsl:for-each>
						<xsl:for-each select="marc:datafield[@tag = '667']">
							<datafield tag="830" ind1=" " ind2=" ">
								<xsl:for-each select="marc:subfield[@code = 'a']">
									<subfield code="a">
										<xsl:value-of select="text()"/>
									</subfield>
								</xsl:for-each>
							</datafield>
						</xsl:for-each>
						
						<datafield ind1="#" ind2="#" tag="899">
							<xsl:variable name="dateJour">
								<xsl:value-of select="format-date(current-date(), '[D01]/[M01]/[Y0001]')"/>
							</xsl:variable>
							<subfield code="a">
								<xsl:value-of
									select="concat('Notice issue de VIAF dérivée via IdRef, le ', $dateJour)"/>
							</subfield>
						</datafield>


						
						<xsl:call-template name="datafield856" />
						
					</record>
				</xsl:for-each>
	</xsl:template>
	
	<xsl:template name="convertPersonalNameSubfields">
		<xsl:param name="field"></xsl:param>
		<xsl:attribute name="ind2">
			<xsl:value-of select="@ind1"/>
		</xsl:attribute>
		<xsl:for-each select="marc:subfield[@code = 'a']">
			<xsl:choose>
				<xsl:when test="contains(text(), ', ')">
					<subfield code="a">
						<xsl:value-of select="substring-before(text(), ', ')"/>
					</subfield>
					<subfield code="b" xmlns="http://www.loc.gov/MARC21/slim">
						<xsl:call-template name="removeEndPuctuation">
							<xsl:with-param name="text" select="substring-after(text(), ', ')"/>
						</xsl:call-template>
					</subfield>
				</xsl:when>
				<xsl:otherwise>
					<subfield code="a" xmlns="http://www.loc.gov/MARC21/slim">
						<xsl:call-template name="removeEndPuctuation">
							<xsl:with-param name="text" select="text()"/>
						</xsl:call-template>
					</subfield>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:for-each>
		<xsl:for-each select="marc:subfield[@code = 'b']">
			<subfield code="d" xmlns="http://www.loc.gov/MARC21/slim">
				<xsl:call-template name="removeEndPuctuation">
					<xsl:with-param name="text" select="text()"/>
				</xsl:call-template>
			</subfield>
		</xsl:for-each>
		<xsl:for-each select="marc:subfield[@code = 'c']">
			<subfield code="c" xmlns="http://www.loc.gov/MARC21/slim">
				<xsl:value-of select="text()"/>
			</subfield>
		</xsl:for-each>
		<xsl:for-each select="marc:subfield[@code = 'd']">
			<subfield code="f" xmlns="http://www.loc.gov/MARC21/slim">
				<xsl:call-template name="removeEndPuctuation">
					<xsl:with-param name="text" select="text()"/>
				</xsl:call-template>
			</subfield>
		</xsl:for-each>
		<xsl:for-each select="marc:subfield[@code = 'e']">
			<subfield code="4" xmlns="http://www.loc.gov/MARC21/slim">
				<xsl:value-of select="text()"/>
			</subfield>
		</xsl:for-each>
		<xsl:for-each select="marc:subfield[@code = 'q']">
			<subfield code="g" xmlns="http://www.loc.gov/MARC21/slim">
				<xsl:call-template name="removeEndPuctuation">
					<xsl:with-param name="text" select="text()"/>
				</xsl:call-template>
			</subfield>
		</xsl:for-each>
		<xsl:for-each select="marc:subfield[@code = 'u']">
			<subfield code="p" xmlns="http://www.loc.gov/MARC21/slim">
				<xsl:value-of select="text()"/>
			</subfield>
		</xsl:for-each>
		<!--<xsl:for-each select="marc:subfield[@code='?']"><subfield code="3"><xsl:value-of select="text()" /></subfield></xsl:for-each>-->
		<xsl:for-each select="marc:subfield[@code = '4']">
			<subfield code="4" xmlns="http://www.loc.gov/MARC21/slim">
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
				<subfield xmlns="http://www.loc.gov/MARC21/slim">
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
						<subfield xmlns="http://www.loc.gov/MARC21/slim">
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
		<xsl:for-each select="marc:datafield[@tag=856]">
			<datafield tag="856" xmlns="http://www.loc.gov/MARC21/slim">
				<xsl:attribute name="ind1">
					<xsl:value-of select="@ind1"/>
				</xsl:attribute>
				<xsl:attribute name="ind2">
					<xsl:value-of select="@ind2"/>
				</xsl:attribute>
				<xsl:for-each select="marc:subfield[@code]">
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
