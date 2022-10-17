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
    <xsl:strip-space elements="*"/>
    <xsl:template match="mx:record ">
        
        <record>
            <xsl:for-each select="//mx:datafield[@tag = '100']">
                <xsl:call-template name="z100"/>
            </xsl:for-each>
            
            
            
            <xsl:for-each select="//mx:datafield[@tag = '910']">
                <xsl:call-template name="z910"/>
            </xsl:for-each>
            
            
            <datafield tag="008">
                <subfield code="a">
                    <xsl:value-of
                        select="'Tp5'"/>
                </subfield>
            </datafield>
            
            <datafield ind1="#" ind2="#" tag="899">
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
    
    <xsl:template name="z100">
        <datafield ind1="#" ind2="#" tag="200">
            <subfield code="a">
                <xsl:value-of select="mx:subfield[@code = 'a']"/>
            </subfield>
            <subfield code="b">
                <xsl:value-of select="mx:subfield[@code = 'q']"/>
            </subfield>
            <subfield code="f">
                <xsl:value-of select="mx:subfield[@code = 'd']"/>
            </subfield>
        </datafield>
    </xsl:template>
    
    <xsl:template name="z910">
        <datafield ind1="#" ind2="#" tag="810">
            <subfield code="a">
                <xsl:value-of select="mx:subfield[@code = 'A']"/>
            </subfield>
        </datafield>
    </xsl:template>
    
</xsl:stylesheet>
