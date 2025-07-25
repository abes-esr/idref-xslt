<?xml version="1.0" encoding="UTF-8"?>

<!--     XSL de transformation du marc21Xml des sources VIAF dans VIAF en marcXml Sudoc IdRef.
  
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
			<xsl:if test="mx:datafield[@tag = '100']">
				<datafield tag="008">
					<subfield code="a">
						<xsl:value-of select="'Tp5'"/>
					</subfield>
				</datafield>
			</xsl:if>
			
			<!--Ajout FML mai 2024 : traitement des Collectivités -->

			<xsl:if test="mx:datafield[@tag = '110']">
				<datafield tag="008">
					<subfield code="a">
						<xsl:value-of select="'Tb5'"/>
					</subfield>
				</datafield>
			</xsl:if>

			<xsl:for-each select="mx:datafield[@tag = '110']">
				<datafield tag="210" ind1="0" ind2="#">
					<subfield code="a">
						<xsl:value-of select="concat('@', mx:subfield[@code = 'a'])"/>
					</subfield>
					<xsl:if test="mx:subfield[@code = 'b']">
						<subfield code="b">
							<xsl:value-of select="mx:subfield[@code = 'b']"/>
						</subfield>
					</xsl:if>
					<xsl:if test="mx:subfield[@code = 'g']">
						<subfield code="c">
							<xsl:value-of select="mx:subfield[@code = 'g']"/>
						</subfield>
					</xsl:if>
				</datafield>
			</xsl:for-each>

			<xsl:if test="mx:datafield[@tag = '110']">
				<xsl:for-each select="mx:datafield[@tag = '410']">
					<datafield tag="410" ind1="0" ind2="#">
						<xsl:for-each select="mx:subfield[@code = 'w']">
							<subfield code="5">
								<xsl:value-of select="text()"/>
							</subfield>
						</xsl:for-each>
						<xsl:for-each select="mx:subfield[@code = 'a']">
							<subfield code="a">
								<xsl:value-of select="concat('@', text())"/>
							</subfield>
						</xsl:for-each>
						<xsl:for-each select="mx:subfield[@code = 'b']">
							<subfield code="b">
								<xsl:value-of select="text()"/>
							</subfield>
						</xsl:for-each>
						<xsl:for-each select="mx:subfield[@code = 'g']">
							<subfield code="c">
								<xsl:value-of select="text()"/>
							</subfield>
						</xsl:for-each>
					</datafield>
				</xsl:for-each>
			</xsl:if>

			<!-- FIN traitement des Collectivités -->

		   <!--Ajout FML juin 2025 : traitement des Congrès -->
		    <xsl:if test="mx:datafield[@tag = '111']">
		        <datafield tag="008">
		            <subfield code="a">
		                <xsl:value-of select="'Tb5'"/>
		            </subfield>
		        </datafield>
		    </xsl:if>
		    
			<xsl:for-each select="mx:datafield[@tag = '111']">
			    <datafield tag="210" ind1="1" ind2="#">
			        <subfield code="a">
			            <xsl:value-of select="concat('@', normalize-space(mx:subfield[@code = 'a']))"/>
			        </subfield>
			        
			        <xsl:if test="mx:subfield[@code = 'e']">
			            <subfield code="b">
			                <xsl:value-of select="normalize-space(translate(mx:subfield[@code = 'e'], '():,', ''))"/>
			            </subfield>
			        </xsl:if>
			        
			        <xsl:if test="mx:subfield[@code = 'n']">
			            <subfield code="d">
			                <xsl:value-of select="normalize-space(mx:subfield[@code = 'n'])"/>
			            </subfield>
			        </xsl:if>
			        
			        <xsl:if test="mx:subfield[@code = 'd']">
			            <subfield code="f">
			                <xsl:value-of select="normalize-space(translate(mx:subfield[@code = 'd'], '():,', ''))"/>
			            </subfield>
			        </xsl:if>
			        
			        <xsl:if test="mx:subfield[@code = 'c']">
			            <subfield code="e">
			                <xsl:value-of select="normalize-space(translate(mx:subfield[@code = 'c'], '():,', ''))"/>
			            </subfield>
			        </xsl:if>
			    </datafield>
			</xsl:for-each>

		    <xsl:if test="mx:datafield[@tag = '411']">
		        <xsl:for-each select="mx:datafield[@tag = '411']">
		            <datafield tag="410" ind1="0" ind2="#">
		                <xsl:for-each select="mx:subfield[@code = 'w']">
		                    <subfield code="5">
		                        <xsl:value-of select="text()"/>
		                    </subfield>
		                </xsl:for-each>
		                <xsl:for-each select="mx:subfield[@code = 'a']">
		                    <subfield code="a">
		                        <xsl:value-of select="concat('@', text())"/>
		                    </subfield>
		                </xsl:for-each>
		                <xsl:for-each select="mx:subfield[@code = 'e']">
		                    <subfield code="b">
		                        <xsl:value-of select="text()"/>
		                    </subfield>
		                </xsl:for-each>
		                <xsl:for-each select="mx:subfield[@code = 'n']">
		                    <subfield code="d">
		                        <xsl:value-of select="text()"/>
		                    </subfield>
		                </xsl:for-each>
			        <xsl:for-each select="mx:subfield[@code = 'd']">
		                    <subfield code="f">
		                        <xsl:value-of select="text()"/>
		                    </subfield>
		                </xsl:for-each>			    
		                <xsl:for-each select="mx:subfield[@code = 'c']">
		                    <subfield code="e">
		                        <xsl:value-of select="text()"/>
		                    </subfield>
		                </xsl:for-each>

		            </datafield>
		        </xsl:for-each>
		    </xsl:if>
		    
		    <!-- FIN traitement des Congrès -->

			<!--Ajout FML automne 2023 : traitement des Lieux Géographiques -->

			<xsl:if test="mx:datafield[@tag = '151']">
				<datafield tag="008">
					<subfield code="a">
						<xsl:value-of select="'Tg5'"/>
					</subfield>
				</datafield>
			</xsl:if>

			<xsl:for-each select="mx:datafield[@tag = '151']">
				<datafield tag="215">
					<subfield code="a">
						<xsl:value-of select="."/>
					</subfield>
				</datafield>
			</xsl:for-each>

			<xsl:if test="mx:datafield[@tag = '151']">
				<xsl:for-each select="mx:datafield[@tag = '551']">
					<datafield tag="415" ind1="#" ind2="#">
						<xsl:for-each select="mx:subfield[@code = 'w']">
							<subfield code="5">
								<xsl:value-of select="text()"/>
							</subfield>
						</xsl:for-each>
						<xsl:for-each select="mx:subfield[@code = 'a']">
							<subfield code="a">
								<xsl:value-of select="text()"/>
							</subfield>
						</xsl:for-each>
					</datafield>
				</xsl:for-each>
			</xsl:if>


			<!--Ajout FML juin 2025 -->
			    <xsl:for-each select="mx:controlfield[@tag = '001']">
			        <xsl:if test="contains(., 'RERO')">
			            <datafield tag="035" ind1="#" ind2="#">
			                <subfield code="a">
			                    <xsl:value-of select="substring-after(., '|')"/>
			                </subfield>
			                <subfield code="2">
			                    <xsl:text>RERO</xsl:text>
			                </subfield>
			            </datafield>
			        </xsl:if>
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

			<xsl:for-each select="mx:datafield[@tag = '034']">
				<datafield tag="123" ind1="#" ind2="#">
					<xsl:for-each select="mx:subfield[@code = 'd']">
						<subfield code="d">
							<xsl:value-of select="lower-case(text())"/>
						</subfield>
					</xsl:for-each>
					<xsl:for-each select="mx:subfield[@code = 'e']">
						<subfield code="e">
							<xsl:value-of select="lower-case(text())"/>
						</subfield>
					</xsl:for-each>
					<xsl:for-each select="mx:subfield[@code = 'f']">
						<subfield code="f">
							<xsl:value-of select="lower-case(text())"/>
						</subfield>
					</xsl:for-each>
					<xsl:for-each select="mx:subfield[@code = 'g']">
						<subfield code="g">
							<xsl:value-of select="lower-case(text())"/>
						</subfield>
					</xsl:for-each>
				</datafield>
			</xsl:for-each>


			<!--Ajout FML juillet 2024 -->
				<xsl:for-each select="mx:datafield[@tag = '024']">
				    <xsl:if test="mx:subfield[@code = '2'][normalize-space(lower-case(.)) = 'isni']">
				        <datafield tag="010">
				            <subfield code="a">
				                <xsl:variable name="id" select="mx:subfield[@code = 'a']"/>
				                <xsl:choose>
				                    <xsl:when test="contains($id, 'https://isni.org/isni/')">
				                        <xsl:value-of select="substring-after($id, 'https://isni.org/isni/')"/>
				                    </xsl:when>
				                    <xsl:otherwise>
				                        <xsl:value-of select="normalize-space($id)"/>
				                    </xsl:otherwise>
				                </xsl:choose>
				            </subfield>
				            <subfield code="2">
				                <xsl:text>ISNI</xsl:text>
				            </subfield>
				        </datafield>
				    </xsl:if>
				</xsl:for-each>


			<!--Ajout FML : l'idviaf venant du JAVA -->
			<datafield ind1="#" ind2="#" tag="035">
				<subfield code="a">
					<xsl:value-of select="concat('https://viaf.org/viaf/', $idviaf)"/>
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
			</datafield>

			<!--Ajout FML décembre 2024 -->
			<xsl:if test="mx:datafield[@tag = '035'][contains(mx:subfield[@code = 'a'], 'ISNI')]">
				<datafield tag="010">
					<subfield code="a">
						<xsl:value-of
							select="substring-after(mx:datafield[@tag = '035']/mx:subfield[@code = 'a'], '(ISNI)')"
						/>
					</subfield>
					<subfield code="2">
						<xsl:value-of select="'ISNI'"/>
					</subfield>
				</datafield>
			</xsl:if>

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


			<!--	Ajout FML-->
			<xsl:if test="mx:datafield[@tag = '100']">
				<datafield ind1="#" ind2="#" tag="106">
					<subfield code="a">0</subfield>
					<subfield code="b">1</subfield>
					<subfield code="c">0</subfield>
				</datafield>
			</xsl:if>


			<!--	Ajout FML ; ajout juin 24 du $q et $r  -->
			<xsl:for-each select="mx:datafield[@tag = '046']">
				<datafield tag="103" ind1="#" ind2="#">
					<xsl:for-each select="mx:subfield[@code = 'f']">
						<subfield code="a">
							<xsl:value-of select="translate(., '-', '')"/>
						</subfield>
					</xsl:for-each>
					<xsl:for-each select="mx:subfield[@code = 'g']">
						<subfield code="b">
							<xsl:value-of select="translate(., '-', '')"/>
						</subfield>
					</xsl:for-each>
					<xsl:for-each select="mx:subfield[@code = 'q']">
						<subfield code="a">
							<xsl:value-of select="translate(., '-', '')"/>
						</subfield>
					</xsl:for-each>
					<xsl:for-each select="mx:subfield[@code = 'r']">
						<subfield code="b">
							<xsl:value-of select="translate(., '-', '')"/>
						</subfield>
					</xsl:for-each>
					<xsl:for-each select="mx:subfield[@code = 's']">
						<subfield code="c">
							<xsl:value-of select="translate(., '-', '')"/>
						</subfield>
					</xsl:for-each>
					<xsl:for-each select="mx:subfield[@code = 't']">
						<subfield code="d">
							<xsl:value-of select="translate(., '-', '')"/>
						</subfield>
					</xsl:for-each>
				</datafield>
			</xsl:for-each>



			<!--	Ajout FML-->
			<xsl:for-each select="mx:datafield[@tag = '377']">
				<xsl:variable name="sz_a" select="mx:subfield[@code = 'a']"/>
				<xsl:if test="$sz_a != ''">
					<datafield tag="101" ind1="#" ind2="#">
						<xsl:for-each select="mx:subfield[@code = 'a']">
							<subfield code="a">
								<xsl:value-of select="text()"/>
							</subfield>
						</xsl:for-each>
					</datafield>
				</xsl:if>
			</xsl:for-each>

			<!--	Ajout FML-->
			<xsl:variable name="exclusion-list" select="'XA XD XB'"/>

			<xsl:if
				test="//mx:datafield[@tag = '043']/mx:subfield[@code = 'c'][text() != '' and not(contains($exclusion-list, text())) and string-length(normalize-space(text())) != 3]">
				<datafield tag="102" ind1="#" ind2="#">
					<xsl:for-each select="//mx:datafield[@tag = '043']/mx:subfield[@code = 'c']">
						<xsl:variable name="z102sz_c" select="upper-case(.)"/>
						<xsl:if
							test="$z102sz_c != '' and not(contains($exclusion-list, $z102sz_c)) and string-length(normalize-space($z102sz_c)) != 3">
							<xsl:for-each select="tokenize($z102sz_c, '-')">
								<xsl:if
									test="string-length(.) = 2 and not(contains($exclusion-list, .))">
									<subfield code="a">
										<xsl:value-of select="normalize-space(.)"/>
									</subfield>
								</xsl:if>
							</xsl:for-each>
						</xsl:if>
					</xsl:for-each>
				</datafield>
			</xsl:if>




			<xsl:for-each select="mx:datafield[@tag = '100']">
				<xsl:choose>
					<xsl:when test="@ind1 != 3">
						<datafield tag="200" ind1="#">
							<xsl:call-template name="convertPersonalNameSubfields">
								<xsl:with-param name="field" select="."/>
								<xsl:with-param name="tag" select="@tag"/>
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
						<xsl:when test="@ind1 != 3">
							<xsl:call-template name="convertPersonalNameSubfields">
								<xsl:with-param name="field" select="."/>
								<xsl:with-param name="tag" select="@tag"/>
							</xsl:call-template>
						</xsl:when>
					</xsl:choose>
				</datafield>
			</xsl:for-each>
			<xsl:for-each select="mx:datafield[@tag = '700']">
				<datafield tag="700" ind1="#">
					<xsl:choose>
						<xsl:when test="@ind1 != 3">
							<xsl:call-template name="convertPersonalNameSubfields">
								<xsl:with-param name="field" select="."/>
								<xsl:with-param name="tag" select="@tag"/>
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

			<!-- 01.07.2024 FML : traitement du $u 	-->
			<!-- <xsl:for-each select="mx:datafield[@tag = '670']">
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
			</xsl:for-each> -->

			<xsl:for-each select="mx:datafield[@tag = '670']">
				<xsl:choose>
					<!-- Cas où le subfield 'u' est présent -->
					<xsl:when test="mx:subfield[@code = 'u']">
						<datafield tag="810" ind1="#" ind2="#">
							<subfield code="a">
								<xsl:value-of select="mx:subfield[@code = 'u']/text()"/>
							</subfield>
						</datafield>
					</xsl:when>
					<!-- Cas où le subfield 'u' est absent -->
					<xsl:otherwise>
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
					</xsl:otherwise>
				</xsl:choose>
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

			<xsl:call-template name="datafield856"/>

			<datafield tag="899" ind1="#" ind2="#">
				<xsl:variable name="dateJour2">
					<xsl:value-of select="format-date(current-date(), '[D01]/[M01]/[Y0001]')"/>
				</xsl:variable>
				<subfield code="a">
					<xsl:value-of
						select="concat('Notice issue de VIAF dérivée via IdRef, le ', $dateJour2)"/>
				</subfield>
			</datafield>

		</record>
	</xsl:template>

	<xsl:template name="convertPersonalNameSubfields">
		<xsl:param name="field"/>
		<xsl:param name="tag"/>

		<xsl:attribute name="ind2">
			<xsl:value-of select="@ind1"/>
		</xsl:attribute>
		<xsl:for-each select="mx:subfield[@code = 'a']">
			<xsl:choose>
				<xsl:when test="contains(text(), ', ')">
					<subfield code="a">
						<xsl:value-of select="substring-before(text(), ', ')"/>
					</subfield>
					<xsl:choose>
						<xsl:when test="parent::node()/mx:subfield[@code = 'q']">
							<xsl:for-each select="parent::node()/mx:subfield[@code = 'q']">
								<subfield code="b">
									<xsl:call-template name="removeEndPuctuation">
										<xsl:with-param name="text"
											select="translate(translate(text(), '(', ''), ')', '')"
										/>
									</xsl:call-template>
								</subfield>
							</xsl:for-each>
						</xsl:when>
						<xsl:otherwise>
							<subfield code="b">
								<xsl:call-template name="removeEndPuctuation">
									<xsl:with-param name="text"
										select="substring-after(text(), ', ')"/>
								</xsl:call-template>
							</subfield>
						</xsl:otherwise>
					</xsl:choose>

				</xsl:when>
				<xsl:otherwise>
					<subfield code="a">
						<xsl:call-template name="removeEndPuctuation">
							<xsl:with-param name="text" select="text()"/>
						</xsl:call-template>
					</subfield>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:for-each>


		<xsl:for-each select="mx:subfield[@code = 'b']">
			<subfield code="d">
				<xsl:call-template name="removeEndPuctuation">
					<xsl:with-param name="text" select="text()"/>
				</xsl:call-template>
			</subfield>
		</xsl:for-each>
		<xsl:for-each select="mx:subfield[@code = 'c']">
			<subfield code="c">
				<xsl:value-of select="text()"/>
			</subfield>
		</xsl:for-each>
		<xsl:for-each select="mx:subfield[@code = 'd']">
			<subfield code="f">
				<xsl:value-of select="text()"/>
			</subfield>
		</xsl:for-each>

		<xsl:if test="$tag = '100'">
			<xsl:if test="mx:datafield[@tag = '100']/mx:subfield[@tag = 'd']">
				<xsl:call-template name="z200_vie_mort"> </xsl:call-template>
			</xsl:if>
		</xsl:if>


		<!--        <xsl:for-each select="mx:subfield[@code = 'd']">
            <subfield code="f" >
                <xsl:call-template name="removeEndPuctuation">
                    <xsl:with-param name="text" select="text()"/>
                </xsl:call-template>
            </subfield>
        </xsl:for-each>-->
		<xsl:for-each select="mx:subfield[@code = 'e']">
			<subfield code="4">
				<xsl:value-of select="text()"/>
			</subfield>
		</xsl:for-each>

		<xsl:for-each select="mx:subfield[@code = 'u']">
			<subfield code="p">
				<xsl:value-of select="text()"/>
			</subfield>
		</xsl:for-each>
		<!--<xsl:for-each select="mx:subfield[@code='?']"><subfield code="3"><xsl:value-of select="text()" /></subfield></xsl:for-each>-->
		<xsl:for-each select="mx:subfield[@code = '4']">
			<subfield code="4">
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
			<xsl:when
				test="contains($list, $delimiter) and substring-after($list, $delimiter) != ''">
				<subfield>
					<xsl:attribute name="code">
						<xsl:value-of select="$code"/>
					</xsl:attribute>
					<!-- get everything in front of the first delimiter -->
					<xsl:value-of select="substring-before($list, $delimiter)"/>
				</subfield>
				<xsl:call-template name="tokenizeSubfield">
					<!-- store anything left in another variable -->
					<xsl:with-param name="list"
						select="normalize-space(substring-after($list, $delimiter))"/>
					<xsl:with-param name="delimiter" select="$delimiter"/>
					<xsl:with-param name="code" select="$code"/>
				</xsl:call-template>
			</xsl:when>
			<xsl:otherwise>
				<xsl:choose>
					<xsl:when test="$list = ''"/>
					<xsl:otherwise>
						<subfield>
							<xsl:attribute name="code">
								<xsl:value-of select="$code"/>
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

	<xsl:template name="z200_vie_mort">
		<xsl:variable name="AnneeVie">
			<xsl:value-of
				select="substring(//mx:datafield[@tag = '046']/mx:subfield[@code = 'f'], 1, 4)"/>
		</xsl:variable>
		<xsl:variable name="AnneeMort">
			<xsl:value-of
				select="substring(//mx:datafield[@tag = '046']/mx:subfield[@code = 'g'], 1, 4)"/>
		</xsl:variable>

		<xsl:if test="$AnneeVie != '' or $AnneeMort != ''">
			<subfield code="f">
				<xsl:choose>
					<xsl:when test="$AnneeVie != ''">
						<xsl:value-of select="concat($AnneeVie, '-')"/>
					</xsl:when>
					<xsl:otherwise>....-</xsl:otherwise>
				</xsl:choose>
				<xsl:choose>
					<xsl:when test="$AnneeMort != ''">
						<xsl:value-of select="$AnneeMort"/>
					</xsl:when>
					<xsl:otherwise>....</xsl:otherwise>
				</xsl:choose>
			</subfield>
		</xsl:if>



	</xsl:template>

	<xsl:template name="removeEndPuctuation">
		<xsl:param name="text"/>
		<xsl:choose>
			<xsl:when
				test="string-length(translate(substring($text, string-length($text)), ' ,.:;/', '')) = 0">
				<xsl:value-of
					select="normalize-space(substring($text, 1, string-length($text) - 1))"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="$text"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template name="datafield856">
		<xsl:for-each select="mx:datafield[@tag = 856]">
			<datafield tag="856" ind1="#" ind2="#">
				<xsl:for-each select="mx:subfield[@code]">
					<subfield>
						<xsl:attribute name="code">
							<xsl:choose>
								<xsl:when test="@code = '3'">
									<xsl:value-of select="2"/>
								</xsl:when>
								<xsl:when test="@code = '2'">
									<xsl:value-of select="y"/>
								</xsl:when>
								<xsl:when test="@code = 'y'">
									<xsl:value-of select="2"/>
								</xsl:when>
								<xsl:otherwise>
									<xsl:value-of select="@code"/>
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
		<xsl:param name="marcOrgCode" select="text()"/>
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
