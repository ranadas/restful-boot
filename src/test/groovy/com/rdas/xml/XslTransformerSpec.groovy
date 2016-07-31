package com.rdas.xml

import spock.lang.Specification

import javax.xml.transform.Source
import javax.xml.transform.Transformer
import javax.xml.transform.TransformerFactory
import javax.xml.transform.stream.StreamResult
import javax.xml.transform.stream.StreamSource

/**
 * Created by rdas on 31/07/2016.
 */
class XslTransformerSpec extends Specification {


    def input = '''
<?xml version="1.0" ?>
<persons>
    <person username="JS1">
        <name>John</name>
        <family_name>Smith</family_name>
    </person>
    <person username="ND1">
        <name>Nancy</name>
        <family_name>Davolio</family_name>
    </person>
</persons>
'''.trim()

    def xslt = '''
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
    <xsl:template match="/persons">
        <html xmlns="http://www.w3.org/1999/xhtml">
        <head>
            <title>Testing XML Example</title>
        </head>
        <body>
            <h1>Persons</h1>
            <ul>
            <xsl:apply-templates select="person">
                <xsl:sort select="family_name" />
            </xsl:apply-templates>
            </ul>
        </body>
        </html>
    </xsl:template>
    <xsl:template match="person">
        <li>
            <xsl:value-of select="family_name"/>,
            <xsl:value-of select="name"/>
        </li>
    </xsl:template>
</xsl:stylesheet>
'''.trim()

    def "transform given input "() {
        expect:
        def factory = TransformerFactory.newInstance()
        def transformer = factory.newTransformer(new StreamSource(new StringReader(xslt)))
        transformer.transform(new StreamSource(new StringReader(input)), new StreamResult(System.out))
    }

    def "read xml and xsl and verify not null"() {
        given:
        String outputFileName = "ddm.xml"
        TransformerFactory factory = TransformerFactory.newInstance()
        String xslString = new File("src/test/resources/tax.xsl").text
        String xmlString = new File("src/test/resources/ofx.Xml").text

        when:
        Source xslDoc = new StreamSource(new StringReader(xslString))
        Source xmlDoc = new StreamSource(new StringReader(xmlString))

        then:
        OutputStream ddlXml = new FileOutputStream(outputFileName);

        Transformer transformer = factory.newTransformer(xslDoc)
        transformer.transform(xmlDoc, new StreamResult(ddlXml))
    }
}
