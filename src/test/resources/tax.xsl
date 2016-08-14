<?xml version="1.0"?>
<xsl:stylesheet version="2.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:hrbofx="http://besl.hrblock.com/operations/hrbofx"
                xmlns:ddm="http://schemas.hrblock.com/DDM/Tax"
                xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
                xmlns:datetime="http://exslt.org/dates-and-times"
                xmlns:fn="http://www.w3.org/2005/02/xpath-functions" exclude-result-prefixes="datetime xsi">

    <xsl:output method="xml" indent="yes"/>

    <xsl:template match="/">
        <xsl:apply-templates select="OFX"/>
    </xsl:template>
    <!--  FY 12 ERROR CODE -->
    <xsl:variable name="statusCode" select="OFX/SIGNONMSGSRSV1/SONRS/STATUS/CODE"/>
    <!--  FY 13 MESSAGE -->
    <xsl:variable name="statusMessage" select="OFX/SIGNONMSGSRSV1/SONRS/STATUS/MESSAGE"/>


    <xsl:template match="OFX">
        <xsl:choose>
            <xsl:when test="TAX1098MSGSRSV1">
                <xsl:apply-templates select="TAX1098MSGSRSV1"/>
            </xsl:when>
            <xsl:when test="TAXW2MSGSRSV1">
                <xsl:apply-templates select="TAXW2MSGSRSV1"/>
            </xsl:when>
            <xsl:when test="TAX1099MSGSRSV1">
                <xsl:apply-templates select="TAX1099MSGSRSV1"/>
            </xsl:when>
        </xsl:choose>
    </xsl:template>

    <!-- 1098 -->
    <xsl:template name="Form1098" match="TAX1098MSGSRSV1">
        <hrbofx:OFXServiceResponse>
            <hrbofx:TransactionId>
                <xsl:value-of select="TAX1098TRNRS/TRNUID"/>
            </hrbofx:TransactionId>
            <hrbofx:TaxFormType>1098</hrbofx:TaxFormType>
            <xsl:apply-templates select="TAX1098TRNRS"/>
        </hrbofx:OFXServiceResponse>
    </xsl:template>
    <xsl:template match="TAX1098TRNRS">
        <xsl:apply-templates select="TAX1098RS"/>
        <xsl:apply-templates select="STATUS"/>
    </xsl:template>
    <xsl:template match="TAX1098MSGSRSV1/TAX1098TRNRS/TAX1098RS">
        <hrbofx:OFXServiceTaxForms>
            <hrbofx:FederalIdNumber>
                <!-- <xsl:call-template name="Strip-dashes">
            <xsl:with-param name="ssn" select="TAX1098_V100/LENDERID"/>
            </xsl:call-template> -->
                <xsl:call-template name="FixFedNumb">
                    <xsl:with-param name="fednum" select="TAXW2_V200/EMPLOYER/FEDIDNUMBER"/>
                </xsl:call-template>
            </hrbofx:FederalIdNumber>
            <xsl:for-each select="TAX1098_V100">
                <ddm:TAXDATA TAXYEAR="{TAXYEAR}">
                    <ddm:FD>
                        <ddm:FDA RECID="-1" OWNER="1" SOURCE="I" MODIFIEDON="{datetime:dateTime()}" ENGINERECID="-1">
                            <ddm:FDA_MORTGAGES RECID="-1" OWNER="1" SOURCE="I" MODIFIEDON="{datetime:dateTime()}"
                                               ENGINERECID="-1">
                                <xsl:if test="LENDERADDR">
                                    <ddm:LENDER VALUE="{LENDERADDR/LENDERNAME}" SOURCE="I"
                                                MODIFIEDON="{datetime:dateTime()}"/>
                                </xsl:if>
                                <xsl:if test="MORTGAGEINTEREST">
                                    <ddm:AMT_INT_1098 VALUE="{format-number(round(MORTGAGEINTEREST),'#0')}" SOURCE="I"
                                                      MODIFIEDON="{datetime:dateTime()}"/>
                                </xsl:if>
                                <xsl:if test="POINTS">
                                    <ddm:AMT_POINTS_1098 VALUE="{format-number(round(POINTS),'#0')}" SOURCE="I"
                                                         MODIFIEDON="{datetime:dateTime()}"/>
                                </xsl:if>
                                <xsl:if test="../ACCTNUM">
                                    <ddm:AccountNumber VALUE="{../ACCTNUM}" SOURCE="I"
                                                       MODIFIEDON="{datetime:dateTime()}"/>
                                </xsl:if>
                                <xsl:if test="../SSN">
                                    <ddm:BorrowerId SOURCE="I" MODIFIEDON="{datetime:dateTime()}">
                                        <xsl:attribute name="VALUE">
                                            <xsl:call-template name="Strip-dashes">
                                                <xsl:with-param name="ssn" select="../SSN"/>
                                            </xsl:call-template>
                                        </xsl:attribute>
                                    </ddm:BorrowerId>
                                </xsl:if>
                                <xsl:if test="LENDERID">
                                    <ddm:LenderEIN SOURCE="I" MODIFIEDON="{datetime:dateTime()}">
                                        <xsl:attribute name="VALUE">
                                            <xsl:call-template name="Strip-dashes">
                                                <xsl:with-param name="ssn" select="LENDERID"/>
                                            </xsl:call-template>
                                        </xsl:attribute>
                                    </ddm:LenderEIN>
                                </xsl:if>
                                <xsl:if test="LENDERADDR">
                                    <xsl:if test="LENDERADDR/ADDR1">
                                        <ddm:LenderAddress1 VALUE="{LENDERADDR/ADDR1}" SOURCE="I"
                                                            MODIFIEDON="{datetime:dateTime()}"/>
                                    </xsl:if>
                                    <xsl:if test="LENDERADDR/ADDR2">
                                        <ddm:LenderAddress2 VALUE="{LENDERADDR/ADDR2}" SOURCE="I"
                                                            MODIFIEDON="{datetime:dateTime()}"/>
                                    </xsl:if>
                                    <xsl:if test="LENDERADDR/ADDR3">
                                        <ddm:LenderAddress3 VALUE="{LENDERADDR/ADDR3}" SOURCE="I"
                                                            MODIFIEDON="{datetime:dateTime()}"/>
                                    </xsl:if>
                                    <xsl:if test="BORROWERADDR/CITY">
                                        <ddm:LenderCity VALUE="{LENDERADDR/CITY}" SOURCE="I"
                                                        MODIFIEDON="{datetime:dateTime()}"/>
                                    </xsl:if>
                                    <xsl:if test="LENDERADDR/STATE">
                                        <ddm:LenderState VALUE="{LENDERADDR/STATE}" SOURCE="I"
                                                         MODIFIEDON="{datetime:dateTime()}"/>
                                    </xsl:if>
                                    <xsl:if test="LENDERADDR/POSTALCODE">
                                        <ddm:LenderZipCode VALUE="{LENDERADDR/POSTALCODE}" SOURCE="I"
                                                           MODIFIEDON="{datetime:dateTime()}"/>
                                    </xsl:if>
                                </xsl:if>
                                <xsl:if test="BORROWERID">
                                    <ddm:SSN VALUE="{BORROWERID}" SOURCE="I" MODIFIEDON="{datetime:dateTime()}"/>
                                </xsl:if>
                                <xsl:if test="BORROWERADDR">
                                    <ddm:BorrowerName VALUE="{BORROWERADDR/BORROWERNAME}" SOURCE="I"
                                                      MODIFIEDON="{datetime:dateTime()}"/>
                                    <xsl:if test="BORROWERADDR/ADDR1">
                                        <ddm:BorrowerAddress1 VALUE="{BORROWERADDR/ADDR1}" SOURCE="I"
                                                              MODIFIEDON="{datetime:dateTime()}"/>
                                    </xsl:if>
                                    <xsl:if test="BORROWERADDR/ADDR2">
                                        <ddm:BorrowerAddress2 VALUE="{BORROWERADDR/ADDR2}" SOURCE="I"
                                                              MODIFIEDON="{datetime:dateTime()}"/>
                                    </xsl:if>
                                    <xsl:if test="BORROWERADDR/ADDR3">
                                        <ddm:BorrowerAddress3 VALUE="{BORROWERADDR/ADDR1}" SOURCE="I"
                                                              MODIFIEDON="{datetime:dateTime()}"/>
                                    </xsl:if>
                                    <xsl:if test="BORROWERADDR/CITY">
                                        <ddm:BorrowerCity VALUE="{BORROWERADDR/CITY}" SOURCE="I"
                                                          MODIFIEDON="{datetime:dateTime()}"/>
                                    </xsl:if>
                                    <xsl:if test="BORROWERADDR/STATE">
                                        <ddm:BorrowerState VALUE="{BORROWERADDR/STATE}" SOURCE="I"
                                                           MODIFIEDON="{datetime:dateTime()}"/>
                                    </xsl:if>
                                    <xsl:if test="BORROWERADDR/POSTALCODE">
                                        <ddm:BorrowerZIPCode VALUE="{BORROWERADDR/POSTALCODE}" SOURCE="I"
                                                             MODIFIEDON="{datetime:dateTime()}"/>
                                    </xsl:if>
                                </xsl:if>
                                <xsl:if test="OVERPAIDREFUND">
                                    <ddm:Overpaid_Amount VALUE="{format-number(round(OVERPAIDREFUND),'#0')}" SOURCE="I"
                                                         MODIFIEDON="{datetime:dateTime()}"/>
                                </xsl:if>
                                <xsl:if test="OTHERLOANINFO">
                                    <ddm:OtherInfo VALUE="{OTHERLOANINFO}" SOURCE="I"
                                                   MODIFIEDON="{datetime:dateTime()}"/>
                                </xsl:if>
                            </ddm:FDA_MORTGAGES>
                        </ddm:FDA>
                    </ddm:FD>
                </ddm:TAXDATA>
            </xsl:for-each>
        </hrbofx:OFXServiceTaxForms>
    </xsl:template>

    <!-- W2 -->
    <xsl:template name="FormW2" match="TAXW2MSGSRSV1">
        <hrbofx:OFXServiceResponse>
            <hrbofx:TransactionId>
                <xsl:value-of select="//OFX/TAXW2MSGSRSV1/TAXW2TRNRS/TRNUID"/>
            </hrbofx:TransactionId>
            <hrbofx:TaxFormType>W2</hrbofx:TaxFormType>
            <xsl:apply-templates select="TAXW2TRNRS"/>
        </hrbofx:OFXServiceResponse>
    </xsl:template>
    <xsl:template match="TAXW2TRNRS">
        <xsl:apply-templates select="TAXW2RS"/>
        <xsl:apply-templates select="STATUS"/>
    </xsl:template>
    <xsl:template match="TAXW2RS">
        <hrbofx:OFXServiceTaxForms>
            <hrbofx:FederalIdNumber>
                <!-- <xsl:call-template name="Strip-dashes">
            <xsl:with-param name="ssn" select="TAXW2_V200/EMPLOYER/FEDIDNUMBER"/>
            </xsl:call-template> -->
                <xsl:call-template name="FixFedNumb">
                    <xsl:with-param name="fednum" select="TAXW2_V200/EMPLOYER/FEDIDNUMBER"/>
                </xsl:call-template>
            </hrbofx:FederalIdNumber>
            <xsl:for-each select="TAXW2_V200">
                <ddm:TAXDATA TAXYEAR="{TAXYEAR}">
                    <ddm:GL>
                        <ddm:GLW2 RECID="-1" OWNER="1" SOURCE="I" MODIFIEDON="{datetime:dateTime()}" ENGINERECID="-1">
                            <xsl:if test="CNTRLNO">
                                <ddm:W2_control_no VALUE="{CNTRLNO}" SOURCE="I" MODIFIEDON="{datetime:dateTime()}"/>
                            </xsl:if>
                            <ddm:bb SOURCE="I" MODIFIEDON="{datetime:dateTime()}">
                                <xsl:attribute name="VALUE">
                                    <!-- <xsl:call-template name="Strip-dashes">
                                <xsl:with-param name="ssn" select="EMPLOYER/FEDIDNUMBER"/>
                                </xsl:call-template> -->
                                    <xsl:call-template name="FixFedNumb">
                                        <xsl:with-param name="fednum" select="EMPLOYER/FEDIDNUMBER"/>
                                    </xsl:call-template>
                                </xsl:attribute>
                            </ddm:bb>
                            <xsl:if test="STATUTORY">
                                <ddm:W2_Statutory_flag VALUE="{STATUTORY}" SOURCE="I"
                                                       MODIFIEDON="{datetime:dateTime()}"/>
                            </xsl:if>
                            <!--
                        <xsl:if test="RETIREMENTPLAN">
                        <ddm:W2_PensionPlan_flag VALUE="{RETIREMENTPLAN}" SOURCE="I" MODIFIEDON="{datetime:dateTime()}"/>
                        </xsl:if>-->
                            <xsl:if test="ALLOCATEDTIPS">
                                <ddm:W2_Allocated_tips VALUE="{format-number(round(ALLOCATEDTIPS),'#0')}" SOURCE="I"
                                                       MODIFIEDON="{datetime:dateTime()}"/>
                            </xsl:if>
                            <xsl:if test="ADVANCEDEIC">
                                <ddm:W2_Advance_EIC VALUE="{format-number(round(ADVANCEDEIC),'#0')}" SOURCE="I"
                                                    MODIFIEDON="{datetime:dateTime()}"/>
                            </xsl:if>
                            <xsl:if test="FEDTAXWH">
                                <ddm:W2_Fed_WH VALUE="{format-number(round(FEDTAXWH),'#0')}" SOURCE="I"
                                               MODIFIEDON="{datetime:dateTime()}"/>
                            </xsl:if>
                            <xsl:if test="WAGES">
                                <ddm:W2_wages VALUE="{format-number(round(WAGES),'#0')}" SOURCE="I"
                                              MODIFIEDON="{datetime:dateTime()}"/>
                            </xsl:if>
                            <xsl:if test="SSTAXWH">
                                <ddm:W2_SS_WH VALUE="{format-number(round(SSTAXWH),'#0')}" SOURCE="I"
                                              MODIFIEDON="{datetime:dateTime()}"/>
                            </xsl:if>
                            <xsl:if test="SSWAGES">
                                <ddm:W2_SS_wages VALUE="{format-number(round(SSWAGES),'#0')}" SOURCE="I"
                                                 MODIFIEDON="{datetime:dateTime()}"/>
                            </xsl:if>
                            <xsl:if test="SSTIPS">
                                <ddm:W2_SS_tips VALUE="{format-number(round(SSTIPS),'#0')}" SOURCE="I"
                                                MODIFIEDON="{datetime:dateTime()}"/>
                            </xsl:if>
                            <xsl:if test="MEDICAREWAGES">
                                <ddm:W2_Medicare_wages VALUE="{format-number(round(MEDICAREWAGES),'#0')}" SOURCE="I"
                                                       MODIFIEDON="{datetime:dateTime()}"/>
                            </xsl:if>
                            <xsl:if test="MEDICARETAXWH">
                                <ddm:W2_Medicare_WH VALUE="{format-number(round(MEDICARETAXWH),'#0')}" SOURCE="I"
                                                    MODIFIEDON="{datetime:dateTime()}"/>
                            </xsl:if>
                            <xsl:if test="NONQUALPLAN">
                                <ddm:W2_NonQual_Plan VALUE="{format-number(round(NONQUALPLAN),'#0')}" SOURCE="I"
                                                     MODIFIEDON="{datetime:dateTime()}"/>
                            </xsl:if>
                            <xsl:if test="DEPCAREBENEFIT">
                                <ddm:W2_DCB VALUE="{format-number(round(DEPCAREBENEFIT),'#0')}" SOURCE="I"
                                            MODIFIEDON="{datetime:dateTime()}"/>
                            </xsl:if>
                            <xsl:if test="EMPLOYER/NAME2">
                                <ddm:InCareOf VALUE="{EMPLOYER/NAME2}" SOURCE="I" MODIFIEDON="{datetime:dateTime()}"/>
                            </xsl:if>
                            <xsl:if test="THIRDPARTYSICKPAY">
                                <ddm:W2_3rdParty_flag VALUE="{THIRDPARTYSICKPAY}" SOURCE="I"
                                                      MODIFIEDON="{datetime:dateTime()}"/>
                            </xsl:if>
                            <ddm:bc_ename VALUE="{EMPLOYER/NAME1}" SOURCE="I" MODIFIEDON="{datetime:dateTime()}"/>
                            <ddm:bc_eaddress VALUE="{EMPLOYER/ADDR1}" SOURCE="I" MODIFIEDON="{datetime:dateTime()}"/>
                            <ddm:bc_ecity VALUE="{EMPLOYER/CITY}" SOURCE="I" MODIFIEDON="{datetime:dateTime()}"/>
                            <ddm:bc_estate VALUE="{EMPLOYER/STATE}" SOURCE="I" MODIFIEDON="{datetime:dateTime()}"/>
                            <ddm:bc_ezip VALUE="{EMPLOYER/POSTALCODE}" SOURCE="I" MODIFIEDON="{datetime:dateTime()}"/>
                            <xsl:if test="EMPLOYEE/ADDR1">
                                <ddm:be_address VALUE="{EMPLOYEE/ADDR1}" SOURCE="I" MODIFIEDON="{datetime:dateTime()}"/>
                            </xsl:if>
                            <xsl:if test="EMPLOYEE/CITY">
                                <ddm:be_city VALUE="{EMPLOYEE/CITY}" SOURCE="I" MODIFIEDON="{datetime:dateTime()}"/>
                            </xsl:if>
                            <xsl:if test="EMPLOYER/STATE">
                                <ddm:be_state VALUE="{EMPLOYEE/STATE}" SOURCE="I" MODIFIEDON="{datetime:dateTime()}"/>
                            </xsl:if>
                            <xsl:if test="EMPLOYEE/POSTALCODE">
                                <ddm:be_zip VALUE="{EMPLOYEE/POSTALCODE}" SOURCE="I"
                                            MODIFIEDON="{datetime:dateTime()}"/>
                            </xsl:if>
                            <xsl:if test="EMPLOYER/COUNTRYSTRING">
                                <ddm:EFOREIGNCOUNTRY VALUE="{EMPLOYER/COUNTRYSTRING}" SOURCE="I"
                                                     MODIFIEDON="{datetime:dateTime()}"/>
                            </xsl:if>
                            <xsl:if test="EMPLOYEE/COUNTRYSTRING">
                                <ddm:beforeign_country VALUE="{EMPLOYEE/COUNTRYSTRING}" SOURCE="I"
                                                       MODIFIEDON="{datetime:dateTime()}"/>
                            </xsl:if>
                            <xsl:if test="EMPLOYER/ADDR2">
                                <ddm:EmployerAddress2 VALUE="{EMPLOYER/ADDR2}" SOURCE="I"
                                                      MODIFIEDON="{datetime:dateTime()}"/>
                            </xsl:if>
                            <xsl:if test="EMPLOYER/ADDR3">
                                <ddm:EmployerAddress3 VALUE="{EMPLOYER/ADDR3}" SOURCE="I"
                                                      MODIFIEDON="{datetime:dateTime()}"/>
                            </xsl:if>
                            <ddm:EmployeeSSN SOURCE="I" MODIFIEDON="{datetime:dateTime()}">
                                <xsl:attribute name="VALUE">
                                    <xsl:call-template name="Strip-dashes">
                                        <xsl:with-param name="ssn" select="EMPLOYEE/SSN"/>
                                    </xsl:call-template>
                                </xsl:attribute>
                            </ddm:EmployeeSSN>
                            <ddm:EmployeeFirstName VALUE="{EMPLOYEE/FIRSTNAME}" SOURCE="I"
                                                   MODIFIEDON="{datetime:dateTime()}"/>
                            <xsl:if test="EMPLOYEE/MIDDLENAME">
                                <ddm:EmployeeMidInitial VALUE="{EMPLOYEE/MIDDLENAME}" SOURCE="I"
                                                        MODIFIEDON="{datetime:dateTime()}"/>
                            </xsl:if>
                            <ddm:EmployeeLastName VALUE="{EMPLOYEE/LASTNAME}" SOURCE="I"
                                                  MODIFIEDON="{datetime:dateTime()}"/>
                            <xsl:if test="SUFFIX">
                                <ddm:EmployeeSuffix VALUE="{EMPLOYEE/SUFFIX}" SOURCE="I"
                                                    MODIFIEDON="{datetime:dateTime()}"/>
                            </xsl:if>
                            <xsl:if test="EMPLOYEE/ADDR2">
                                <ddm:EmployeeAddress2 VALUE="{EMPLOYEE/ADDR2}" SOURCE="I"
                                                      MODIFIEDON="{datetime:dateTime()}"/>
                            </xsl:if>
                            <xsl:if test="EMPLOYEE/ADDR3">
                                <ddm:EmployeeAddress3 VALUE="{EMPLOYEE/ADDR3}" SOURCE="I"
                                                      MODIFIEDON="{datetime:dateTime()}"/>
                            </xsl:if>
                            <xsl:if test="BENEFITSBOX1">
                                <ddm:Box1Benefits VALUE="{BENEFITSBOX1}" SOURCE="I" MODIFIEDON="{datetime:dateTime()}"/>
                            </xsl:if>
                            <xsl:if test="DEFERREDCOMP">
                                <ddm:DeferredCompensation VALUE="{format-number(round(DEFERREDCOMP),'#0')}" RECID="-1"
                                                          OWNER="1" SOURCE="I" MODIFIEDON="{datetime:dateTime()}"
                                                          ENGINERECID="-1"/>
                            </xsl:if>
                            <xsl:if test="DECEASED">
                                <ddm:DeceasedFlag VALUE="{DECEASED}" SOURCE="I" MODIFIEDON="{datetime:dateTime()}"/>
                            </xsl:if>
                            <xsl:if test="RETIREMENTPLAN">
                                <ddm:W2_PensionFlag VALUE="{RETIREMENTPLAN}" SOURCE="I"
                                                    MODIFIEDON="{datetime:dateTime()}"/>
                            </xsl:if>
                            <!-- 15 Dec 2015 start -->
                            <xsl:if test="W2VERIFICATIONCODE">
                                <ddm:W2VERIFICATIONCODE VALUE="{W2VERIFICATIONCODE}" SOURCE="I"
                                                        MODIFIEDON="{datetime:dateTime()}"/>
                            </xsl:if>
                            <!-- end -->
                            <xsl:if test="OTHER">
                                <xsl:for-each select="OTHER">
                                    <ddm:GLW2_OTHERINFO RECID="-1" OWNER="1" SOURCE="I"
                                                        MODIFIEDON="{datetime:dateTime()}" ENGINERECID="-1">
                                        <ddm:Description VALUE="{OTHERDESC}" SOURCE="I"
                                                         MODIFIEDON="{datetime:dateTime()}"/>
                                        <ddm:Amount VALUE="{format-number(round(OTHERAMOUNT),'#0')}" SOURCE="I"
                                                    MODIFIEDON="{datetime:dateTime()}"/>
                                    </ddm:GLW2_OTHERINFO>
                                </xsl:for-each>
                            </xsl:if>
                            <xsl:choose>
                                <xsl:when test="(STATEINFO) and (LOCALINFO)">
                                    <xsl:variable name="stcnt" select="count(STATEINFO)"/>
                                    <xsl:variable name="lclcnt" select="count(LOCALINFO)"/>
                                    <!--
                                <stateinfocnt  value="{$stcnt}"/>
                                <lclinfocnt value="{$lclcnt}"/>-->
                                    <xsl:choose>
                                        <xsl:when test="$stcnt &lt; $lclcnt">
                                            <xsl:for-each select="STATEINFO">
                                                <xsl:variable name="stpos" select="position()"/>
                                                <xsl:for-each select="../LOCALINFO">
                                                    <ddm:GLW2_STATEINFO RECID="-1" OWNER="1" SOURCE="I"
                                                                        MODIFIEDON="{datetime:dateTime()}"
                                                                        ENGINERECID="-1">
                                                        <xsl:if test="$stpos = position()">

                                                            <xsl:if test="../STATEINFO/STATECODE">

                                                                <ddm:ST_Name VALUE="{../STATEINFO/STATECODE}" SOURCE="I"
                                                                             MODIFIEDON="{datetime:dateTime()}"/>
                                                            </xsl:if>
                                                            <xsl:if test="../STATEINFO/EMPLOYERSTID">
                                                                <ddm:ST_Id VALUE="{../STATEINFO/EMPLOYERSTID}"
                                                                           SOURCE="I"
                                                                           MODIFIEDON="{datetime:dateTime()}"/>
                                                            </xsl:if>
                                                            <xsl:if test="../STATEINFO/STATEWAGES">
                                                                <ddm:ST_Wages
                                                                        VALUE="{format-number(round(../STATEINFO/STATEWAGES),'#0')}"
                                                                        SOURCE="I" MODIFIEDON="{datetime:dateTime()}"/>
                                                            </xsl:if>
                                                            <xsl:if test="../STATEINFO/STATETAXWH">
                                                                <ddm:ST_tax
                                                                        VALUE="{format-number(round(../STATEINFO/STATETAXWH),'#0')}"
                                                                        SOURCE="I" MODIFIEDON="{datetime:dateTime()}"/>
                                                            </xsl:if>
                                                        </xsl:if>

                                                        <xsl:if test="LOCALITY">
                                                            <ddm:Loc_Name VALUE="{LOCALITY}" SOURCE="I"
                                                                          MODIFIEDON="{datetime:dateTime()}"/>
                                                        </xsl:if>
                                                        <xsl:if test="LOCALWAGES">
                                                            <ddm:Loc_Wages
                                                                    VALUE="{format-number(round(LOCALWAGES),'#0')}"
                                                                    SOURCE="I" MODIFIEDON="{datetime:dateTime()}"/>
                                                        </xsl:if>
                                                        <xsl:if test="LOCALTAXWH">
                                                            <ddm:Loc_tax VALUE="{format-number(round(LOCALTAXWH),'#0')}"
                                                                         SOURCE="I" MODIFIEDON="{datetime:dateTime()}"/>
                                                        </xsl:if>
                                                        <!--  FY14 start -->
                                                        <xsl:if test="LOCALITYSTATE">
                                                            <ddm:Loc_state VALUE="{LOCALITYSTATE}" SOURCE="I"
                                                                           MODIFIEDON="{datetime:dateTime()}"/>
                                                        </xsl:if>
                                                        <!--  FY14 end -->
                                                    </ddm:GLW2_STATEINFO>
                                                </xsl:for-each>
                                            </xsl:for-each>
                                        </xsl:when>
                                        <xsl:when test="$lclcnt &lt; $stcnt">
                                            <xsl:for-each select="LOCALINFO">
                                                <xsl:variable name="lclpos" select="position()"/>

                                                <xsl:for-each select="../STATEINFO">

                                                    <ddm:GLW2_STATEINFO RECID="-1" OWNER="1" SOURCE="I"
                                                                        MODIFIEDON="{datetime:dateTime()}"
                                                                        ENGINERECID="-1">

                                                        <xsl:if test="STATECODE">

                                                            <ddm:ST_Name VALUE="{STATECODE}" SOURCE="I"
                                                                         MODIFIEDON="{datetime:dateTime()}"/>
                                                        </xsl:if>
                                                        <xsl:if test="EMPLOYERSTID">
                                                            <ddm:ST_Id VALUE="{EMPLOYERSTID}" SOURCE="I"
                                                                       MODIFIEDON="{datetime:dateTime()}"/>
                                                        </xsl:if>
                                                        <xsl:if test="STATEWAGES">
                                                            <ddm:ST_Wages
                                                                    VALUE="{format-number(round(STATEWAGES),'#0')}"
                                                                    SOURCE="I" MODIFIEDON="{datetime:dateTime()}"/>
                                                        </xsl:if>
                                                        <xsl:if test="STATETAXWH">
                                                            <ddm:ST_tax VALUE="{format-number(round(STATETAXWH),'#0')}"
                                                                        SOURCE="I" MODIFIEDON="{datetime:dateTime()}"/>
                                                        </xsl:if>
                                                        <xsl:if test="$lclpos = position()">


                                                            <xsl:if test="../LOCALINFO/LOCALITY">
                                                                <ddm:Loc_Name VALUE="{../LOCALINFO/LOCALITY}" SOURCE="I"
                                                                              MODIFIEDON="{datetime:dateTime()}"/>
                                                            </xsl:if>
                                                            <xsl:if test="../LOCALINFO/LOCALWAGES">
                                                                <ddm:Loc_Wages
                                                                        VALUE="{format-number(round(../LOCALINFO/LOCALWAGES),'#0')}"
                                                                        SOURCE="I" MODIFIEDON="{datetime:dateTime()}"/>
                                                            </xsl:if>
                                                            <xsl:if test="../LOCALINFO/LOCALTAXWH">
                                                                <ddm:Loc_tax
                                                                        VALUE="{format-number(round(../LOCALINFO/LOCALTAXWH),'#0')}"
                                                                        SOURCE="I" MODIFIEDON="{datetime:dateTime()}"/>
                                                            </xsl:if>
                                                            <!--  FY14 start -->
                                                            <xsl:if test="../LOCALINFO/LOCALITYSTATE">
                                                                <ddm:Loc_state VALUE="{../LOCALINFO/LOCALITYSTATE}"
                                                                               SOURCE="I"
                                                                               MODIFIEDON="{datetime:dateTime()}"/>
                                                            </xsl:if>
                                                            <!--  FY14 end -->
                                                        </xsl:if>
                                                    </ddm:GLW2_STATEINFO>
                                                </xsl:for-each>
                                            </xsl:for-each>
                                        </xsl:when>
                                        <xsl:when test="$lclcnt = $stcnt">

                                            <xsl:for-each select="STATEINFO">
                                                <xsl:variable name="stateCount" select="position()"/>
                                                <ddm:GLW2_STATEINFO RECID="-1" OWNER="1" SOURCE="I"
                                                                    MODIFIEDON="{datetime:dateTime()}" ENGINERECID="-1">

                                                    <ddm:ST_Name VALUE="{STATECODE}" SOURCE="I"
                                                                 MODIFIEDON="{datetime:dateTime()}"/>
                                                    <xsl:if test="EMPLOYERSTID">
                                                        <ddm:ST_Id VALUE="{EMPLOYERSTID}" SOURCE="I"
                                                                   MODIFIEDON="{datetime:dateTime()}"/>
                                                    </xsl:if>
                                                    <xsl:if test="STATEWAGES">
                                                        <ddm:ST_Wages VALUE="{format-number(round(STATEWAGES),'#0')}"
                                                                      SOURCE="I" MODIFIEDON="{datetime:dateTime()}"/>
                                                    </xsl:if>
                                                    <xsl:if test="STATETAXWH">
                                                        <ddm:ST_tax VALUE="{format-number(round(STATETAXWH),'#0')}"
                                                                    SOURCE="I" MODIFIEDON="{datetime:dateTime()}"/>
                                                    </xsl:if>

                                                    <xsl:if test="../LOCALINFO[$stateCount]/LOCALITY">
                                                        <ddm:Loc_Name VALUE="{../LOCALINFO[$stateCount]/LOCALITY}"
                                                                      SOURCE="I" MODIFIEDON="{datetime:dateTime()}"/>
                                                    </xsl:if>
                                                    <xsl:if test="../LOCALINFO[$stateCount]/LOCALWAGES">
                                                        <ddm:Loc_Wages
                                                                VALUE="{format-number(round(../LOCALINFO[$stateCount]/LOCALWAGES),'#0')}"
                                                                SOURCE="I" MODIFIEDON="{datetime:dateTime()}"/>
                                                    </xsl:if>
                                                    <xsl:if test="../LOCALINFO[$stateCount]/LOCALTAXWH">
                                                        <ddm:Loc_tax
                                                                VALUE="{format-number(round(../LOCALINFO[$stateCount]/LOCALTAXWH),'#0')}"
                                                                SOURCE="I" MODIFIEDON="{datetime:dateTime()}"/>
                                                    </xsl:if>
                                                    <!--  FY14 start -->
                                                    <xsl:if test="../LOCALINFO[$stateCount]/LOCALITYSTATE">
                                                        <ddm:Loc_state VALUE="{../LOCALINFO[$stateCount]/LOCALITYSTATE}"
                                                                       SOURCE="I" MODIFIEDON="{datetime:dateTime()}"/>
                                                    </xsl:if>
                                                    <!--  FY14 end -->
                                                </ddm:GLW2_STATEINFO>
                                            </xsl:for-each>
                                        </xsl:when>
                                    </xsl:choose>
                                </xsl:when>
                                <xsl:when test="STATEINFO">

                                    <xsl:for-each select="STATEINFO">
                                        <ddm:GLW2_STATEINFO RECID="-1" OWNER="1" SOURCE="I"
                                                            MODIFIEDON="{datetime:dateTime()}" ENGINERECID="-1">

                                            <ddm:ST_Name VALUE="{STATECODE}" SOURCE="I"
                                                         MODIFIEDON="{datetime:dateTime()}"/>
                                            <xsl:if test="EMPLOYERSTID">
                                                <ddm:ST_Id VALUE="{EMPLOYERSTID}" SOURCE="I"
                                                           MODIFIEDON="{datetime:dateTime()}"/>
                                            </xsl:if>
                                            <xsl:if test="STATEWAGES">
                                                <ddm:ST_Wages VALUE="{format-number(round(STATEWAGES),'#0')}" SOURCE="I"
                                                              MODIFIEDON="{datetime:dateTime()}"/>
                                            </xsl:if>
                                            <xsl:if test="STATETAXWH">
                                                <ddm:ST_tax VALUE="{format-number(round(STATETAXWH),'#0')}" SOURCE="I"
                                                            MODIFIEDON="{datetime:dateTime()}"/>
                                            </xsl:if>
                                            <!--
                                        <xsl:if test="LOCALITY">
                                        <ddm:Loc_Name VALUE="{LOCALITY}" SOURCE="I" MODIFIEDON="{datetime:dateTime()}"/>
                                        </xsl:if>
                                        <xsl:if test="LOCALWAGES">
                                        <ddm:Loc_Wages VALUE="{format-number(round(LOCALWAGES),'#0')}" SOURCE="I" MODIFIEDON="{datetime:dateTime()}"/>
                                        </xsl:if>
                                        <xsl:if test="LOCALTAXWH">
                                        <ddm:Loc_tax VALUE="{format-number(round(LOCALTAXWH),'#0')}" SOURCE="I" MODIFIEDON="{datetime:dateTime()}"/>
                                        </xsl:if>-->
                                        </ddm:GLW2_STATEINFO>
                                    </xsl:for-each>
                                </xsl:when>
                                <xsl:when test="LOCALINFO">
                                    <xsl:for-each select="LOCALINFO">

                                        <ddm:GLW2_STATEINFO RECID="-1" OWNER="1" SOURCE="I"
                                                            MODIFIEDON="{datetime:dateTime()}" ENGINERECID="-1">
                                            <ddm:Loc_Name VALUE="{LOCALITY}" SOURCE="I"
                                                          MODIFIEDON="{datetime:dateTime()}"/>
                                            <xsl:if test="LOCALWAGES">
                                                <ddm:Loc_Wages VALUE="{format-number(round(LOCALWAGES),'#0')}"
                                                               SOURCE="I" MODIFIEDON="{datetime:dateTime()}"/>
                                            </xsl:if>
                                            <xsl:if test="LOCALTAXWH">
                                                <ddm:Loc_tax VALUE="{format-number(round(LOCALTAXWH),'#0')}" SOURCE="I"
                                                             MODIFIEDON="{datetime:dateTime()}"/>
                                            </xsl:if>
                                            <xsl:if test="LOCALITYSTATE">
                                                <ddm:Loc_state VALUE="{LOCALITYSTATE}" SOURCE="I"
                                                               MODIFIEDON="{datetime:dateTime()}"/>
                                            </xsl:if>
                                        </ddm:GLW2_STATEINFO>
                                    </xsl:for-each>
                                </xsl:when>
                            </xsl:choose>

                            <xsl:if test="CODES">
                                <xsl:for-each select="CODES">
                                    <ddm:GLW2_FRINGEBENEFITS RECID="-1" OWNER="1" SOURCE="I"
                                                             MODIFIEDON="{datetime:dateTime()}" ENGINERECID="-1">
                                        <ddm:Code VALUE="{normalize-space(CODE)}" SOURCE="I"
                                                  MODIFIEDON="{datetime:dateTime()}"/>
                                        <ddm:Amount VALUE="{format-number(round(CODEAMOUNT),'#0')}" SOURCE="I"
                                                    MODIFIEDON="{datetime:dateTime()}"/>
                                    </ddm:GLW2_FRINGEBENEFITS>
                                </xsl:for-each>
                            </xsl:if>
                        </ddm:GLW2>
                    </ddm:GL>
                </ddm:TAXDATA>
            </xsl:for-each>
        </hrbofx:OFXServiceTaxForms>
    </xsl:template>

    <!-- 1099 -->
    <xsl:template name="Form1099" match="TAX1099MSGSRSV1">
        <hrbofx:OFXServiceResponse>
            <!--xsl:attribute name="xsi:schemaLocation">http://besl.hrblock.com/operations/hrbofx file:///h:/HRBlock/DDM/xsd/HRBOFX.xsd</xsl:attribute-->
            <hrbofx:TransactionId>
                <xsl:value-of select="TAX1099TRNRS/TRNUID"/>
            </hrbofx:TransactionId>
            <hrbofx:TaxFormType>1099</hrbofx:TaxFormType>
            <xsl:apply-templates select="TAX1099TRNRS"/>
        </hrbofx:OFXServiceResponse>
    </xsl:template>
    <xsl:template match="TAX1099TRNRS">
        <xsl:apply-templates select="TAX1099RS"/>
        <xsl:apply-templates select="STATUS"/>
    </xsl:template>
    <xsl:template match="TAX1099MSGSRSV1/TAX1099TRNRS/TAX1099RS">
        <xsl:if test="TAX1099INT_V100">
            <hrbofx:OFXServiceTaxForms>
                <hrbofx:FederalIdNumber>
                    <!-- <xsl:call-template name="Strip-dashes">
                <xsl:with-param name="ssn" select="TAX1099INT_V100[last()]/PAYERID"/>
                </xsl:call-template> -->
                    <xsl:call-template name="FixFedNumb">
                        <xsl:with-param name="fednum" select="TAXW2_V200/EMPLOYER/FEDIDNUMBER"/>
                    </xsl:call-template>
                </hrbofx:FederalIdNumber>
                <hrbofx:TaxFormSubType>INT</hrbofx:TaxFormSubType>
                <xsl:apply-templates select="TAX1099INT_V100"/>
            </hrbofx:OFXServiceTaxForms>
        </xsl:if>
        <xsl:if test="TAX1099DIV_V100">
            <hrbofx:OFXServiceTaxForms>
                <hrbofx:FederalIdNumber>
                    <!--<xsl:call-template name="Strip-dashes">
                <xsl:with-param name="ssn" select="TAX1099DIV_V100[last()]/PAYERID"/>
                </xsl:call-template> -->
                    <xsl:call-template name="FixFedNumb">
                        <xsl:with-param name="fednum" select="TAXW2_V200/EMPLOYER/FEDIDNUMBER"/>
                    </xsl:call-template>
                </hrbofx:FederalIdNumber>
                <hrbofx:TaxFormSubType>DIV</hrbofx:TaxFormSubType>
                <xsl:apply-templates select="TAX1099DIV_V100"/>
            </hrbofx:OFXServiceTaxForms>
        </xsl:if>
        <xsl:if test="TAX1099B_V100">
            <hrbofx:OFXServiceTaxForms>
                <hrbofx:FederalIdNumber>
                    <!-- <xsl:call-template name="Strip-dashes">
                <xsl:with-param name="ssn" select="TAX1099B_V100[last()]/PAYERID"/>
                </xsl:call-template> -->
                    <xsl:call-template name="FixFedNumb">
                        <xsl:with-param name="fednum" select="TAXW2_V200/EMPLOYER/FEDIDNUMBER"/>
                    </xsl:call-template>
                </hrbofx:FederalIdNumber>
                <hrbofx:TaxFormSubType>B</hrbofx:TaxFormSubType>
                <xsl:apply-templates select="TAX1099B_V100"/>
            </hrbofx:OFXServiceTaxForms>
        </xsl:if>
        <xsl:if test="TAX1099OID_V100">
            <hrbofx:OFXServiceTaxForms>
                <hrbofx:FederalIdNumber>
                    <!-- <xsl:call-template name="Strip-dashes">
                <xsl:with-param name="ssn" select="TAX1099OID_V100[last()]/PAYERID"/>
                </xsl:call-template> -->
                    <xsl:call-template name="FixFedNumb">
                        <xsl:with-param name="fednum" select="TAXW2_V200/EMPLOYER/FEDIDNUMBER"/>
                    </xsl:call-template>
                </hrbofx:FederalIdNumber>
                <hrbofx:TaxFormSubType>OID</hrbofx:TaxFormSubType>
                <xsl:apply-templates select="TAX1099OID_V100"/>
            </hrbofx:OFXServiceTaxForms>
        </xsl:if>
        <xsl:if test="TAX1099R_V100">
            <hrbofx:OFXServiceTaxForms>
                <hrbofx:FederalIdNumber>
                    <!-- <xsl:call-template name="Strip-dashes">
                <xsl:with-param name="ssn" select="TAX1099R_V100[last()]/PAYERID"/>
                </xsl:call-template> -->
                    <xsl:call-template name="FixFedNumb">
                        <xsl:with-param name="fednum" select="TAXW2_V200/EMPLOYER/FEDIDNUMBER"/>
                    </xsl:call-template>
                </hrbofx:FederalIdNumber>
                <hrbofx:TaxFormSubType>R</hrbofx:TaxFormSubType>
                <xsl:apply-templates select="TAX1099R_V100"/>
            </hrbofx:OFXServiceTaxForms>
        </xsl:if>
        <xsl:if test="TAX1099MISC_V100">
            <hrbofx:OFXServiceTaxForms>
                <hrbofx:FederalIdNumber>
                    <!-- <xsl:call-template name="Strip-dashes">
                <xsl:with-param name="ssn" select="TAX1099MISC_V100[last()]/PAYERID"/>
                </xsl:call-template> -->
                    <xsl:call-template name="FixFedNumb">
                        <xsl:with-param name="fednum" select="TAXW2_V200/EMPLOYER/FEDIDNUMBER"/>
                    </xsl:call-template>
                </hrbofx:FederalIdNumber>
                <hrbofx:TaxFormSubType>MISC</hrbofx:TaxFormSubType>
                <xsl:apply-templates select="TAX1099MISC_V100"/>
            </hrbofx:OFXServiceTaxForms>
        </xsl:if>
    </xsl:template>
    <xsl:template match="TAX1099B_V100">
        <xsl:for-each select=".">
            <ddm:TAXDATA TAXYEAR="{TAXYEAR}">
                <ddm:FD>
                    <ddm:FDD RECID="-1" OWNER="1" SOURCE="I" MODIFIEDON="{datetime:dateTime()}" ENGINERECID="-1">
                        <xsl:choose>
                            <xsl:when test="EXTDBINFO_V100">
                                <xsl:for-each select="EXTDBINFO_V100/PROCDET_V100">
                                    <ddm:FDD_S1_SALES RECID="-1" OWNER="1" SOURCE="I" MODIFIEDON="{datetime:dateTime()}"
                                                      ENGINERECID="-1">

                                        <!-- TY2014 changes Nov 26 2014 start -->
                                        <xsl:if test="FORM8949CODE">
                                            <ddm:form8949Code VALUE="{FORM8949CODE}" SOURCE="I"
                                                              MODIFIEDON="{datetime:dateTime()}"/>
                                        </xsl:if>
                                        <xsl:if test="STATECODE2">
                                            <ddm:StateCode2 VALUE="{STATECODE2}" SOURCE="I"
                                                            MODIFIEDON="{datetime:dateTime()}"/>
                                        </xsl:if>

                                        <xsl:if test="STATEIDNUM2">
                                            <ddm:StateIdNum2 VALUE="{STATEIDNUM2}" SOURCE="I"
                                                             MODIFIEDON="{datetime:dateTime()}"/>
                                        </xsl:if>

                                        <xsl:if test="STATETAXWHELD2">
                                            <ddm:StateTaxWheld2 VALUE="{format-number(round(STATETAXWHELD2),'#0')}"
                                                                SOURCE="I" MODIFIEDON="{datetime:dateTime()}"/>
                                        </xsl:if>

                                        <!-- TY2014 changes Nov 26 2014 end -->

                                        <!-- 2013 changes to OFX addendum Oct8th 2012 start -->
                                        <xsl:if test="STATECODE">
                                            <ddm:StateCode VALUE="{STATECODE}" SOURCE="I"
                                                           MODIFIEDON="{datetime:dateTime()}"/>
                                        </xsl:if>

                                        <xsl:if test="STATEIDNUM">
                                            <ddm:StateIdNum VALUE="{STATEIDNUM}" SOURCE="I"
                                                            MODIFIEDON="{datetime:dateTime()}"/>
                                        </xsl:if>

                                        <xsl:if test="STATETAXWHELD">
                                            <ddm:StateTaxWheld VALUE="{format-number(round(STATETAXWHELD),'#0')}"
                                                               SOURCE="I" MODIFIEDON="{datetime:dateTime()}"/>
                                        </xsl:if>
                                        <!-- 2013 changes to OFX addendum Oct8th 2012 end -->
                                        <!-- commented for FY 12. New logic below. <xsl:if test="(NUMSHRS) and (SECNAME)">
                                    <xsl:if test="string-length(concat(NUMSHRS, ' ', SECNAME)) &gt; 20">
                                    <ddm:description VALUE="{substring(concat(NUMSHRS, ' ', SECNAME),1,20)}" SOURCE="I" MODIFIEDON="{datetime:dateTime()}"/>
                                    </xsl:if>
                                    <xsl:if test="string-length(concat(NUMSHRS, ' ', SECNAME)) &lt; 21">
                                    <ddm:description VALUE="{substring(concat(NUMSHRS, ' ', SECNAME),1,20)}" SOURCE="I" MODIFIEDON="{datetime:dateTime()}"/>
                                    </xsl:if>
                                    </xsl:if> -->
                                        <!-- FY 12 Start -->
                                        <xsl:choose>
                                            <xsl:when test="SALEDESCRIPTION">
                                                <ddm:description VALUE="{SALEDESCRIPTION}" SOURCE="I"
                                                                 MODIFIEDON="{datetime:dateTime()}"/>
                                            </xsl:when>
                                            <xsl:when test="(NUMSHRS) and (SECNAME)">
                                                <xsl:if test="string-length(concat(NUMSHRS, ' ', SECNAME)) &gt; 20">
                                                    <ddm:description
                                                            VALUE="{substring(concat(NUMSHRS, ' ', SECNAME),1,20)}"
                                                            SOURCE="I" MODIFIEDON="{datetime:dateTime()}"/>
                                                </xsl:if>
                                                <xsl:if test="string-length(concat(NUMSHRS, ' ', SECNAME)) &lt; 21">
                                                    <ddm:description
                                                            VALUE="{substring(concat(NUMSHRS, ' ', SECNAME),1,20)}"
                                                            SOURCE="I" MODIFIEDON="{datetime:dateTime()}"/>
                                                </xsl:if>
                                            </xsl:when>
                                        </xsl:choose>
                                        <!-- FY 12 End -->
                                        <xsl:if test="DTAQD">
                                            <ddm:dateAcq SOURCE="I" MODIFIEDON="{datetime:dateTime()}">
                                                <xsl:attribute name="VALUE">
                                                    <xsl:call-template name="FormatDate">
                                                        <xsl:with-param name="DateTime" select="DTAQD"/>
                                                    </xsl:call-template>
                                                </xsl:attribute>
                                            </ddm:dateAcq>
                                        </xsl:if>
                                        <ddm:dateSold SOURCE="I" MODIFIEDON="{datetime:dateTime()}">
                                            <xsl:attribute name="VALUE">
                                                <xsl:call-template name="FormatDate">
                                                    <xsl:with-param name="DateTime" select="DTSALE"/>
                                                </xsl:call-template>
                                            </xsl:attribute>
                                        </ddm:dateSold>
                                        <ddm:salesPrice VALUE="{format-number(round(SALESPR),'#0')}" SOURCE="I"
                                                        MODIFIEDON="{datetime:dateTime()}"/>

                                        <xsl:if test="FEDTAXWH">
                                            <ddm:FDD_TAX_WITHHELD VALUE="{format-number(round(FEDTAXWH),'#0')}"
                                                                  SOURCE="I" MODIFIEDON="{datetime:dateTime()}"/>
                                        </xsl:if>
                                        <xsl:if test="DTVAR">
                                            <ddm:DATEACQ_LIST VALUE="3" SOURCE="I" MODIFIEDON="{datetime:dateTime()}"/>
                                        </xsl:if>

                                        <!-- TY2014 changes Nov 26 2014 start -->
                                        <xsl:choose>
                                            <xsl:when test="WASHSALELOSSDISALLOWED">
                                                <ddm:WashSaleDisallowed
                                                        VALUE="{format-number(round(WASHSALELOSSDISALLOWED),'#0')}"
                                                        SOURCE="I" MODIFIEDON="{datetime:dateTime()}"/>
                                            </xsl:when>
                                            <xsl:when test="ADJUSTMENTAMT">
                                                <ddm:adjustmentAmount VALUE="{format-number(round(ADJUSTMENTAMT),'#0')}"
                                                                      SOURCE="I" MODIFIEDON="{datetime:dateTime()}"/>
                                            </xsl:when>
                                        </xsl:choose>
                                        <!-- TY2014 changes Nov 26 2014 end -->
                                        <xsl:if test="NONCOVEREDSECURITY">
                                            <ddm:NoncoveredSecurity SOURCE="I" MODIFIEDON="{datetime:dateTime()}">
                                                <xsl:attribute name="VALUE">
                                                    <xsl:call-template name="BoolToBin">
                                                        <xsl:with-param name="value" select="NONCOVEREDSECURITY"/>
                                                    </xsl:call-template>
                                                </xsl:attribute>
                                            </ddm:NoncoveredSecurity>
                                        </xsl:if>
                                        <!-- FY 12 End -->

                                        <!-- TY2014 changes Nov 26 2014 start -->
                                        <xsl:if test="LOSSNOTALLOWED">
                                            <ddm:lossNotAllowed SOURCE="I" MODIFIEDON="{datetime:dateTime()}">
                                                <xsl:attribute name="VALUE">
                                                    <xsl:call-template name="BoolToBin">
                                                        <xsl:with-param name="value" select="LOSSNOTALLOWED"/>
                                                    </xsl:call-template>
                                                </xsl:attribute>
                                            </ddm:lossNotAllowed>
                                        </xsl:if>

                                        <xsl:choose>
                                            <xsl:when test="WASHSALE">
                                                <ddm:WASH_SALE SOURCE="I" MODIFIEDON="{datetime:dateTime()}">
                                                    <xsl:attribute name="VALUE">
                                                        <xsl:call-template name="BoolToBin">
                                                            <xsl:with-param name="value" select="WASHSALE"/>
                                                        </xsl:call-template>
                                                    </xsl:attribute>
                                                </ddm:WASH_SALE>
                                            </xsl:when>
                                            <xsl:when test="SALECODE">
                                                <ddm:saleCode VALUE="{SALECODE}" SOURCE="I"
                                                              MODIFIEDON="{datetime:dateTime()}"/>
                                            </xsl:when>
                                        </xsl:choose>
                                        <!-- TY2014 changes Nov 26 2014 end -->

                                        <ddm:PayerName1 VALUE="{../../PAYERADDR/PAYERNAME1}" SOURCE="I"
                                                        MODIFIEDON="{datetime:dateTime()}"/>
                                        <xsl:if test="../../PAYERADDR/PAYERNAME2">
                                            <ddm:PayerName2 VALUE="{../../PAYERADDR/PAYERNAME2}" SOURCE="I"
                                                            MODIFIEDON="{datetime:dateTime()}"/>
                                        </xsl:if>
                                        <ddm:PayerAddress1 VALUE="{../../PAYERADDR/ADDR1}" SOURCE="I"
                                                           MODIFIEDON="{datetime:dateTime()}"/>
                                        <xsl:if test="../../PAYERADDR/ADDR2">
                                            <ddm:PayerAddress2 VALUE="{../../PAYERADDR/ADDR2}" SOURCE="I"
                                                               MODIFIEDON="{datetime:dateTime()}"/>
                                        </xsl:if>
                                        <xsl:if test="../../PAYERADDR/ADDR3">
                                            <ddm:PayerAddress3 VALUE="{../../PAYERADDR/ADDR3}" SOURCE="I"
                                                               MODIFIEDON="{datetime:dateTime()}"/>
                                        </xsl:if>
                                        <ddm:PayerCity VALUE="{../../PAYERADDR/CITY}" SOURCE="I"
                                                       MODIFIEDON="{datetime:dateTime()}"/>
                                        <ddm:PayerState VALUE="{../../PAYERADDR/STATE}" SOURCE="I"
                                                        MODIFIEDON="{datetime:dateTime()}"/>
                                        <ddm:PayerZipCode VALUE="{../../PAYERADDR/POSTALCODE}" SOURCE="I"
                                                          MODIFIEDON="{datetime:dateTime()}"/>
                                        <xsl:if test="../../PAYERADDR/PHONE">
                                            <ddm:PayerPhone VALUE="{../../PAYERADDR/PHONE}" SOURCE="I"
                                                            MODIFIEDON="{datetime:dateTime()}">
                                                <xsl:attribute name="VALUE">
                                                    <xsl:call-template name="Strip-cntrycode">
                                                        <xsl:with-param name="phone" select="../../PAYERADDR/PHONE"/>
                                                    </xsl:call-template>
                                                </xsl:attribute>
                                            </ddm:PayerPhone>
                                        </xsl:if>
                                        <ddm:PayerEIN SOURCE="I" MODIFIEDON="{datetime:dateTime()}">
                                            <xsl:attribute name="VALUE">
                                                <!-- <xsl:call-template name="Strip-dashes">
                                            <xsl:with-param name="ssn" select="../../PAYERID"/>
                                            </xsl:call-template> -->
                                                <xsl:call-template name="FixFedNumb">
                                                    <xsl:with-param name="fednum" select="../../PAYERID"/>
                                                </xsl:call-template>
                                            </xsl:attribute>
                                        </ddm:PayerEIN>
                                        <xsl:if test="../../RECADDR">
                                            <ddm:RecipientName1 VALUE="{../../RECADDR/RECNAME1}" SOURCE="I"
                                                                MODIFIEDON="{datetime:dateTime()}"/>
                                            <xsl:if test="../../RECADDR/RECNAME2">
                                                <ddm:RecipientName2 VALUE="{../../RECADDR/RECNAME2}" SOURCE="I"
                                                                    MODIFIEDON="{datetime:dateTime()}"/>
                                            </xsl:if>
                                            <ddm:RecipientAddr1 VALUE="{../../RECADDR/ADDR1}" SOURCE="I"
                                                                MODIFIEDON="{datetime:dateTime()}"/>
                                            <xsl:if test="../../RECADDR/ADDR2">
                                                <ddm:RecipientAddr2 VALUE="{../../RECADDR/ADDR2}" SOURCE="I"
                                                                    MODIFIEDON="{datetime:dateTime()}"/>
                                            </xsl:if>
                                            <xsl:if test="../../RECADDR/ADDR3">
                                                <ddm:RecipientAddr3 VALUE="{../../RECADDR/ADDR3}" SOURCE="I"
                                                                    MODIFIEDON="{datetime:dateTime()}"/>
                                            </xsl:if>
                                            <xsl:if test="../../RECADDR/CITY">
                                                <ddm:RecipientCity VALUE="{../../RECADDR/CITY}" SOURCE="I"
                                                                   MODIFIEDON="{datetime:dateTime()}"/>
                                            </xsl:if>
                                            <xsl:if test="../../RECADDR/STATE">
                                                <ddm:RecipientState VALUE="{../../RECADDR/STATE}" SOURCE="I"
                                                                    MODIFIEDON="{datetime:dateTime()}"/>
                                            </xsl:if>
                                            <xsl:if test="../../RECADDR/POSTALCODE">
                                                <ddm:RecipientZipCode VALUE="{../../RECADDR/POSTALCODE}" SOURCE="I"
                                                                      MODIFIEDON="{datetime:dateTime()}"/>
                                            </xsl:if>
                                            <xsl:if test="../../RECADDR/COUNTRYSTRING">
                                                <ddm:RecipientCountry VALUE="{../../RECADDR/COUNTRYSTRING}" SOURCE="I"
                                                                      MODIFIEDON="{datetime:dateTime()}"/>
                                            </xsl:if>
                                            <xsl:if test="../../RECADDR/PHONE">
                                                <ddm:RecipientPhone SOURCE="I" MODIFIEDON="{datetime:dateTime()}">
                                                    <xsl:attribute name="VALUE">
                                                        <xsl:call-template name="Strip-cntrycode">
                                                            <xsl:with-param name="phone" select="../../RECADDR/PHONE"/>
                                                        </xsl:call-template>
                                                    </xsl:attribute>
                                                </ddm:RecipientPhone>
                                            </xsl:if>
                                        </xsl:if>
                                        <!--  FY13 DDM changed from NumberShares to NumShrs  -->
                                        <xsl:if test="NUMSHRS">
                                            <ddm:NumShrs VALUE="{NUMSHRS}" SOURCE="I"
                                                         MODIFIEDON="{datetime:dateTime()}"/>
                                        </xsl:if>
                                        <xsl:if test="LONGSHORT">
                                            <ddm:HoldingPeriod VALUE="{LONGSHORT}" SOURCE="I"
                                                               MODIFIEDON="{datetime:dateTime()}"/>
                                        </xsl:if>
                                        <ddm:RecipientSSN SOURCE="I" MODIFIEDON="{datetime:dateTime()}">
                                            <xsl:attribute name="VALUE">
                                                <xsl:call-template name="Strip-dashes">
                                                    <xsl:with-param name="ssn" select="../../RECID"/>
                                                </xsl:call-template>
                                            </xsl:attribute>
                                        </ddm:RecipientSSN>
                                        <xsl:if test="../../RECACCT">
                                            <ddm:AccountNumber VALUE="{../../RECACCT}" SOURCE="I"
                                                               MODIFIEDON="{datetime:dateTime()}"/>
                                        </xsl:if>
                                        <!-- added to check if SECNAME present or not. if SALEDESCRIPTION is present then SECNAME will not be present in the OFX response - EEI (2012.01.26) -->
                                        <!--  FY13 DDM changed from SecurityName to SecName  -->
                                        <xsl:if test="SECNAME">
                                            <ddm:SecName VALUE="{SECNAME}" SOURCE="I"
                                                         MODIFIEDON="{datetime:dateTime()}"/>
                                        </xsl:if>
                                        <xsl:if test="COSTBASIS">
                                            <ddm:FAKE_BASIS VALUE="{format-number(round(COSTBASIS),'#0')}" SOURCE="I"
                                                            MODIFIEDON="{datetime:dateTime()}"/>
                                        </xsl:if>
                                        <!-- BEGIN: added for the new OFX tags beginning TY2011 - EEI (2012.01.26) -->
                                        <xsl:if test="BASISNOTSHOWN">
                                            <ddm:BasisNotShown SOURCE="I" MODIFIEDON="{datetime:dateTime()}">
                                                <xsl:attribute name="VALUE">
                                                    <xsl:call-template name="BoolToBin">
                                                        <xsl:with-param name="value" select="BASISNOTSHOWN"/>
                                                    </xsl:call-template>
                                                </xsl:attribute>
                                            </ddm:BasisNotShown>
                                        </xsl:if>
                                        <xsl:if test="FORM1099BNOTRECEIVED">
                                            <ddm:Form1099BNotReceived SOURCE="I" MODIFIEDON="{datetime:dateTime()}">
                                                <xsl:attribute name="VALUE">
                                                    <xsl:call-template name="BoolToBin">
                                                        <xsl:with-param name="value" select="FORM1099BNOTRECEIVED"/>
                                                    </xsl:call-template>
                                                </xsl:attribute>
                                            </ddm:Form1099BNotReceived>
                                        </xsl:if>
                                        <!-- END: added for the new OFX tags beginning TY2011 -->

                                    </ddm:FDD_S1_SALES>
                                </xsl:for-each>
                            </xsl:when>
                            <xsl:otherwise>
                                <ddm:FDD_S1_SALES RECID="-1" OWNER="1" SOURCE="I" MODIFIEDON="{datetime:dateTime()}"
                                                  ENGINERECID="-1">
                                    <!-- TY2014 changes Nov 26 2014 start -->
                                    <xsl:if test="FORM8949CODE">
                                        <ddm:form8949Code VALUE="{FORM8949CODE}" SOURCE="I"
                                                          MODIFIEDON="{datetime:dateTime()}"/>
                                    </xsl:if>
                                    <xsl:if test="STATECODE2">
                                        <ddm:StateCode2 VALUE="{STATECODE2}" SOURCE="I"
                                                        MODIFIEDON="{datetime:dateTime()}"/>
                                    </xsl:if>

                                    <xsl:if test="STATEIDNUM2">
                                        <ddm:StateIdNum2 VALUE="{STATEIDNUM2}" SOURCE="I"
                                                         MODIFIEDON="{datetime:dateTime()}"/>
                                    </xsl:if>

                                    <xsl:if test="STATETAXWHELD2">
                                        <ddm:StateTaxWheld2 VALUE="{format-number(round(STATETAXWHELD2),'#0')}"
                                                            SOURCE="I" MODIFIEDON="{datetime:dateTime()}"/>
                                    </xsl:if>
                                    <!-- TY2014 changes Nov 26 2014 end -->
                                    <!-- 2013 changes to OFX addendum Oct8th 2012 start -->
                                    <xsl:if test="STATECODE">
                                        <ddm:StateCode VALUE="{STATECODE}" SOURCE="I"
                                                       MODIFIEDON="{datetime:dateTime()}"/>
                                    </xsl:if>

                                    <xsl:if test="STATEIDNUM">
                                        <ddm:StateIdNum VALUE="{STATEIDNUM}" SOURCE="I"
                                                        MODIFIEDON="{datetime:dateTime()}"/>
                                    </xsl:if>

                                    <xsl:if test="STATETAXWHELD">
                                        <ddm:StateTaxWheld VALUE="{format-number(round(STATETAXWHELD),'#0')}" SOURCE="I"
                                                           MODIFIEDON="{datetime:dateTime()}"/>
                                    </xsl:if>
                                    <!-- 2013 changes to OFX addendum Oct8th 2012 end -->
                                    <xsl:if test="FEDTAXWH">
                                        <ddm:FDD_TAX_WITHHELD VALUE="{format-number(round(FEDTAXWH),'#0')}" SOURCE="I"
                                                              MODIFIEDON="{datetime:dateTime()}"/>
                                    </xsl:if>
                                    <ddm:PayerName1 VALUE="{PAYERADDR/PAYERNAME1}" SOURCE="I"
                                                    MODIFIEDON="{datetime:dateTime()}"/>
                                    <xsl:if test="PAYERADDR/PAYERNAME2">
                                        <ddm:PayerName2 VALUE="{PAYERADDR/PAYERNAME2}" SOURCE="I"
                                                        MODIFIEDON="{datetime:dateTime()}"/>
                                    </xsl:if>
                                    <ddm:PayerAddress1 VALUE="{PAYERADDR/ADDR1}" SOURCE="I"
                                                       MODIFIEDON="{datetime:dateTime()}"/>
                                    <xsl:if test="PAYERADDR/ADDR2">
                                        <ddm:PayerAddress2 VALUE="{PAYERADDR/ADDR2}" SOURCE="I"
                                                           MODIFIEDON="{datetime:dateTime()}"/>
                                    </xsl:if>
                                    <xsl:if test="PAYERADDR/ADDR3">
                                        <ddm:PayerAddress3 VALUE="{PAYERADDR/ADDR3}" SOURCE="I"
                                                           MODIFIEDON="{datetime:dateTime()}"/>
                                    </xsl:if>
                                    <ddm:PayerCity VALUE="{PAYERADDR/CITY}" SOURCE="I"
                                                   MODIFIEDON="{datetime:dateTime()}"/>
                                    <ddm:PayerState VALUE="{PAYERADDR/STATE}" SOURCE="I"
                                                    MODIFIEDON="{datetime:dateTime()}"/>
                                    <ddm:PayerZipCode VALUE="{PAYERADDR/POSTALCODE}" SOURCE="I"
                                                      MODIFIEDON="{datetime:dateTime()}"/>
                                    <xsl:if test="PAYERADDR/PHONE">
                                        <ddm:PayerPhone SOURCE="I" MODIFIEDON="{datetime:dateTime()}">
                                            <xsl:attribute name="VALUE">
                                                <xsl:call-template name="Strip-cntrycode">
                                                    <xsl:with-param name="phone" select="PAYERADDR/PHONE"/>
                                                </xsl:call-template>
                                            </xsl:attribute>
                                        </ddm:PayerPhone>
                                    </xsl:if>
                                    <ddm:PayerEIN SOURCE="I" MODIFIEDON="{datetime:dateTime()}">
                                        <xsl:attribute name="VALUE">
                                            <!-- <xsl:call-template name="Strip-dashes">
                                        <xsl:with-param name="ssn" select="PAYERID"/>
                                        </xsl:call-template> -->
                                            <xsl:call-template name="FixFedNumb">
                                                <xsl:with-param name="fednum" select="PAYERID"/>
                                            </xsl:call-template>
                                        </xsl:attribute>
                                    </ddm:PayerEIN>
                                    <xsl:if test="RECADDR">
                                        <ddm:RecipientName1 VALUE="{RECADDR/RECNAME1}" SOURCE="I"
                                                            MODIFIEDON="{datetime:dateTime()}"/>
                                        <xsl:if test="RECADDR/RECNAME2">
                                            <ddm:RecipientName2 VALUE="{RECADDR/RECNAME2}" SOURCE="I"
                                                                MODIFIEDON="{datetime:dateTime()}"/>
                                        </xsl:if>
                                        <ddm:RecipientAddr1 VALUE="{RECADDR/ADDR1}" SOURCE="I"
                                                            MODIFIEDON="{datetime:dateTime()}"/>
                                        <xsl:if test="RECADDR/ADDR2">
                                            <ddm:RecipientAddr2 VALUE="{RECADDR/ADDR2}" SOURCE="I"
                                                                MODIFIEDON="{datetime:dateTime()}"/>
                                        </xsl:if>
                                        <xsl:if test="RECADDR/ADDR3">
                                            <ddm:RecipientAddr3 VALUE="{RECADDR/ADDR3}" SOURCE="I"
                                                                MODIFIEDON="{datetime:dateTime()}"/>
                                        </xsl:if>
                                        <xsl:if test="RECADDR/CITY">
                                            <ddm:RecipientCity VALUE="{RECADDR/CITY}" SOURCE="I"
                                                               MODIFIEDON="{datetime:dateTime()}"/>
                                        </xsl:if>
                                        <xsl:if test="RECADDR/STATE">
                                            <ddm:RecipientState VALUE="{RECADDR/STATE}" SOURCE="I"
                                                                MODIFIEDON="{datetime:dateTime()}"/>
                                        </xsl:if>
                                        <xsl:if test="RECADDR/POSTALCODE">
                                            <ddm:RecipientZipCode VALUE="{RECADDR/POSTALCODE}" SOURCE="I"
                                                                  MODIFIEDON="{datetime:dateTime()}"/>
                                        </xsl:if>
                                        <xsl:if test="RECADDR/COUNTRYSTRING">
                                            <ddm:RecipientCountry VALUE="{RECADDR/COUNTRYSTRING}" SOURCE="I"
                                                                  MODIFIEDON="{datetime:dateTime()}"/>
                                        </xsl:if>
                                        <xsl:if test="RECADDR/PHONE">
                                            <ddm:RecipientPhone SOURCE="I" MODIFIEDON="{datetime:dateTime()}">
                                                <xsl:attribute name="VALUE">
                                                    <xsl:call-template name="Strip-cntrycode">
                                                        <xsl:with-param name="phone" select="RECADDR/PHONE"/>
                                                    </xsl:call-template>
                                                </xsl:attribute>
                                            </ddm:RecipientPhone>
                                        </xsl:if>
                                    </xsl:if>
                                    <ddm:RecipientSSN SOURCE="I" MODIFIEDON="{datetime:dateTime()}">
                                        <xsl:attribute name="VALUE">
                                            <xsl:call-template name="Strip-dashes">
                                                <xsl:with-param name="ssn" select="RECID"/>
                                            </xsl:call-template>
                                        </xsl:attribute>
                                    </ddm:RecipientSSN>
                                    <xsl:if test="RECACCT">
                                        <ddm:AccountNumber VALUE="{RECACCT}" SOURCE="I"
                                                           MODIFIEDON="{datetime:dateTime()}"/>
                                    </xsl:if>
                                </ddm:FDD_S1_SALES>
                            </xsl:otherwise>
                        </xsl:choose>
                    </ddm:FDD>
                </ddm:FD>
            </ddm:TAXDATA>
        </xsl:for-each>
    </xsl:template>
    <xsl:template match="TAX1099R_V100">
        <xsl:for-each select=".">
            <ddm:TAXDATA TAXYEAR="{TAXYEAR}">
                <ddm:GL>
                    <ddm:GL1099R RECID="-1" OWNER="1" SOURCE="I" MODIFIEDON="{datetime:dateTime()}" ENGINERECID="-1">
                        <ddm:payer VALUE="{PAYERADDR/PAYERNAME1}" SOURCE="I" MODIFIEDON="{datetime:dateTime()}"/>
                        <ddm:payer_address VALUE="{PAYERADDR/ADDR1}" SOURCE="I" MODIFIEDON="{datetime:dateTime()}"/>
                        <ddm:payer_city VALUE="{PAYERADDR/CITY}" SOURCE="I" MODIFIEDON="{datetime:dateTime()}"/>
                        <xsl:if test="GROSSDIST">
                            <ddm:gross VALUE="{format-number(round(GROSSDIST),'#0')}" SOURCE="I"
                                       MODIFIEDON="{datetime:dateTime()}"/>
                        </xsl:if>
                        <xsl:if test="TAXAMT">
                            <ddm:taxable VALUE="{format-number(round(TAXAMT),'#0')}" SOURCE="I"
                                         MODIFIEDON="{datetime:dateTime()}"/>
                        </xsl:if>
                        <ddm:ein SOURCE="I" MODIFIEDON="{datetime:dateTime()}">
                            <xsl:attribute name="VALUE">
                                <!-- <xsl:call-template name="Strip-dashes">
                            <xsl:with-param name="ssn" select="PAYERID"/>
                            </xsl:call-template> -->
                                <xsl:call-template name="FixFedNumb">
                                    <xsl:with-param name="fednum" select="PAYERID"/>
                                </xsl:call-template>
                            </xsl:attribute>
                        </ddm:ein>
                        <ddm:ssn SOURCE="I" MODIFIEDON="{datetime:dateTime()}">
                            <xsl:attribute name="VALUE">
                                <xsl:call-template name="Strip-dashes">
                                    <xsl:with-param name="ssn" select="RECID"/>
                                </xsl:call-template>
                            </xsl:attribute>
                        </ddm:ssn>
                        <xsl:if test="CAPGAIN">
                            <ddm:cap_gain VALUE="{format-number(round(CAPGAIN),'#0')}" SOURCE="I"
                                          MODIFIEDON="{datetime:dateTime()}"/>
                        </xsl:if>
                        <xsl:if test="FEDTAXWH">
                            <ddm:fed_wh VALUE="{format-number(round(FEDTAXWH),'#0')}" SOURCE="I"
                                        MODIFIEDON="{datetime:dateTime()}"/>
                        </xsl:if>
                        <xsl:if test="EMPCONTINS">
                            <ddm:emp_cont VALUE="{format-number(round(EMPCONTINS),'#0')}" SOURCE="I"
                                          MODIFIEDON="{datetime:dateTime()}"/>
                        </xsl:if>
                        <xsl:if test="NETUNAPEMP">
                            <ddm:nua VALUE="{NETUNAPEMP}" SOURCE="I" MODIFIEDON="{datetime:dateTime()}"/>
                        </xsl:if>
                        <xsl:for-each select="DISTCODE">
                            <xsl:choose>
                                <xsl:when test="position() = 1">
                                    <ddm:code VALUE="{./text()}" SOURCE="I" MODIFIEDON="{datetime:dateTime()}"/>
                                </xsl:when>
                                <xsl:otherwise>
                                    <ddm:code1 VALUE="{./text()}" SOURCE="I" MODIFIEDON="{datetime:dateTime()}"/>
                                </xsl:otherwise>
                            </xsl:choose>
                        </xsl:for-each>
                        <xsl:if test="ANNCTRCTDIST">
                            <ddm:actuarial VALUE="{format-number(round(ANNCTRCTDIST),'#0')}" SOURCE="I"
                                           MODIFIEDON="{datetime:dateTime()}"/>
                        </xsl:if>
                        <xsl:if test="ANNCTRCTPER">
                            <ddm:percent_annuity VALUE="{ANNCTRCTPER}" SOURCE="I" MODIFIEDON="{datetime:dateTime()}"/>
                        </xsl:if>
                        <xsl:if test="PERTOTDIST">
                            <ddm:percent_total VALUE="{PERTOTDIST}" SOURCE="I" MODIFIEDON="{datetime:dateTime()}"/>
                        </xsl:if>

                        <xsl:for-each select="STTAXWHAGG">
                            <ddm:state_wh VALUE="{format-number(round(AMOUNT),'#0')}" SOURCE="I"
                                          MODIFIEDON="{datetime:dateTime()}"/>
                            <ddm:state VALUE="{PAYERSTATE}" SOURCE="I" MODIFIEDON="{datetime:dateTime()}"/>
                            <xsl:if test="PAYERSTID">
                                <ddm:state_ein VALUE="{PAYERSTID}" SOURCE="I" MODIFIEDON="{datetime:dateTime()}"/>
                            </xsl:if>
                        </xsl:for-each>
                        <xsl:for-each select="LCLTAXWHAGG">
                            <ddm:local_wh VALUE="{format-number(round(AMOUNT),'#0')}" SOURCE="I"
                                          MODIFIEDON="{datetime:dateTime()}"/>
                            <ddm:locality VALUE="{NAMELCL}" SOURCE="I" MODIFIEDON="{datetime:dateTime()}"/>
                        </xsl:for-each>
                        <ddm:payer_state VALUE="{PAYERADDR/STATE}" SOURCE="I" MODIFIEDON="{datetime:dateTime()}"/>
                        <ddm:payer_zip VALUE="{PAYERADDR/POSTALCODE}" SOURCE="I" MODIFIEDON="{datetime:dateTime()}"/>
                        <xsl:if test="STTAXWHAGG/STDIST">
                            <ddm:state_dist VALUE="{STTAXWHAGG/STDIST}" SOURCE="I" MODIFIEDON="{datetime:dateTime()}"/>
                        </xsl:if>
                        <xsl:if test="LCLTAXWHAGG/LCLDIST">
                            <ddm:local_dist VALUE="{LCLTAXWHAGG/LCLDIST}" SOURCE="I"
                                            MODIFIEDON="{datetime:dateTime()}"/>
                        </xsl:if>
                        <xsl:if test="TOTEMPCONT">
                            <ddm:tot_emp_cont VALUE="{TOTEMPCONT}" SOURCE="I" MODIFIEDON="{datetime:dateTime()}"/>
                        </xsl:if>
                        <xsl:if test="TOTALDIST">
                            <ddm:FAKE_TOTAL_DISTRIBUTION SOURCE="I" MODIFIEDON="{datetime:dateTime()}">
                                <xsl:attribute name="VALUE">
                                    <xsl:call-template name="BoolToBin">
                                        <xsl:with-param name="value" select="TOTALDIST"/>
                                    </xsl:call-template>
                                </xsl:attribute>
                            </ddm:FAKE_TOTAL_DISTRIBUTION>
                        </xsl:if>
                        <xsl:if test="TAXAMTND">
                            <ddm:FAKE_TAX_NOT_DETERMINED SOURCE="I" MODIFIEDON="{datetime:dateTime()}">
                                <xsl:attribute name="VALUE">
                                    <xsl:call-template name="BoolToBin">
                                        <xsl:with-param name="value" select="TAXAMTND"/>
                                    </xsl:call-template>
                                </xsl:attribute>
                            </ddm:FAKE_TAX_NOT_DETERMINED>
                        </xsl:if>
                        <xsl:if test="IRASEPSIMP">
                            <ddm:FAKE_IRA_SEP SOURCE="I" MODIFIEDON="{datetime:dateTime()}">
                                <xsl:attribute name="VALUE">
                                    <xsl:call-template name="BoolToBin">
                                        <xsl:with-param name="value" select="IRASEPSIMP"/>
                                    </xsl:call-template>
                                </xsl:attribute>
                            </ddm:FAKE_IRA_SEP>
                        </xsl:if>
                        <xsl:if test="PAYERADDR/PAYERNAME2">
                            <ddm:Payer2 VALUE="{PAYERADDR/PAYERNAME2}" SOURCE="I" MODIFIEDON="{datetime:dateTime()}"/>
                        </xsl:if>
                        <xsl:if test="PAYERADDR/ADDR2">
                            <ddm:Payer_Address2 VALUE="{PAYERADDR/ADDR2}" SOURCE="I"
                                                MODIFIEDON="{datetime:dateTime()}"/>
                        </xsl:if>
                        <xsl:if test="PAYERADDR/ADDR3">
                            <ddm:Payer_Address3 VALUE="{PAYERADDR/ADDR3}" SOURCE="I"
                                                MODIFIEDON="{datetime:dateTime()}"/>
                        </xsl:if>
                        <xsl:if test="PAYERADDR/PHONE">
                            <ddm:PayerPhone SOURCE="I" MODIFIEDON="{datetime:dateTime()}">
                                <xsl:attribute name="VALUE">
                                    <xsl:call-template name="Strip-cntrycode">
                                        <xsl:with-param name="phone" select="PAYERADDR/PHONE"/>
                                    </xsl:call-template>
                                </xsl:attribute>
                            </ddm:PayerPhone>
                        </xsl:if>
                        <xsl:if test="RECACCT">
                            <ddm:AccountNumber VALUE="{RECACCT}" SOURCE="I" MODIFIEDON="{datetime:dateTime()}"/>
                        </xsl:if>
                        <xsl:if test="RECADDR">
                            <ddm:RecipientName1 VALUE="{RECADDR/RECNAME1}" SOURCE="I"
                                                MODIFIEDON="{datetime:dateTime()}"/>
                            <xsl:if test="RECADDR/RECNAME2">
                                <ddm:RecipientName2 VALUE="{RECADDR/RECNAME2}" SOURCE="I"
                                                    MODIFIEDON="{datetime:dateTime()}"/>
                            </xsl:if>
                            <ddm:RecipientAddr1 VALUE="{RECADDR/ADDR1}" SOURCE="I" MODIFIEDON="{datetime:dateTime()}"/>
                            <xsl:if test="RECADDR/ADDR2">
                                <ddm:RecipientAddr2 VALUE="{RECADDR/ADDR2}" SOURCE="I"
                                                    MODIFIEDON="{datetime:dateTime()}"/>
                            </xsl:if>
                            <xsl:if test="RECADDR/ADDR3">
                                <ddm:RecipientAddr3 VALUE="{RECADDR/ADDR3}" SOURCE="I"
                                                    MODIFIEDON="{datetime:dateTime()}"/>
                            </xsl:if>
                            <xsl:if test="RECADDR/CITY">
                                <ddm:RecipientCity VALUE="{RECADDR/CITY}" SOURCE="I"
                                                   MODIFIEDON="{datetime:dateTime()}"/>
                            </xsl:if>
                            <xsl:if test="RECADDR/STATE">
                                <ddm:RecipientState VALUE="{RECADDR/STATE}" SOURCE="I"
                                                    MODIFIEDON="{datetime:dateTime()}"/>
                            </xsl:if>
                            <xsl:if test="RECADDR/POSTALCODE">
                                <ddm:RecipientZipCode VALUE="{RECADDR/POSTALCODE}" SOURCE="I"
                                                      MODIFIEDON="{datetime:dateTime()}"/>
                            </xsl:if>
                            <xsl:if test="RECADDR/COUNTRYSTRING">
                                <ddm:RecipientCountry VALUE="{RECADDR/COUNTRYSTRING}" SOURCE="I"
                                                      MODIFIEDON="{datetime:dateTime()}"/>
                            </xsl:if>
                            <xsl:if test="RECADDR/PHONE">
                                <ddm:RecipientPhone SOURCE="I" MODIFIEDON="{datetime:dateTime()}">
                                    <xsl:attribute name="VALUE">
                                        <xsl:call-template name="Strip-cntrycode">
                                            <xsl:with-param name="phone" select="RECADDR/PHONE"/>
                                        </xsl:call-template>
                                    </xsl:attribute>
                                </ddm:RecipientPhone>
                            </xsl:if>
                        </xsl:if>
                        <xsl:if test="VOID">
                            <ddm:Void VALUE="{VOID}" SOURCE="I" MODIFIEDON="{datetime:dateTime()}"/>
                        </xsl:if>
                        <xsl:if test="CORRECTED">
                            <ddm:Corrected VALUE="{CORRECTED}" SOURCE="I" MODIFIEDON="{datetime:dateTime()}"/>
                        </xsl:if>
                        <ddm:SSNBR SOURCE="I" MODIFIEDON="{datetime:dateTime()}">
                            <xsl:attribute name="VALUE">
                                <xsl:call-template name="Strip-dashes">
                                    <xsl:with-param name="ssn" select="RECID"/>
                                </xsl:call-template>
                            </xsl:attribute>
                        </ddm:SSNBR>
                        <xsl:for-each select="STTAXWHAGG">
                            <ddm:GL1099R_StateInfo RECID="-1" OWNER="1" SOURCE="I" MODIFIEDON="{datetime:dateTime()}"
                                                   ENGINERECID="-1">
                                <xsl:if test="STDIST">
                                    <ddm:StateDistribution VALUE="{format-number(round(STDIST),'#0')}" SOURCE="I"
                                                           MODIFIEDON="{datetime:dateTime()}"/>
                                </xsl:if>
                                <ddm:StateWithholding VALUE="{format-number(round(AMOUNT),'#0')}" SOURCE="I"
                                                      MODIFIEDON="{datetime:dateTime()}"/>
                                <ddm:StateName VALUE="{PAYERSTATE}" SOURCE="I" MODIFIEDON="{datetime:dateTime()}"/>
                                <xsl:if test="PAYERSTID">
                                    <ddm:StateTaxId VALUE="{PAYERSTID}" SOURCE="I" MODIFIEDON="{datetime:dateTime()}"/>
                                </xsl:if>
                            </ddm:GL1099R_StateInfo>
                        </xsl:for-each>
                        <xsl:for-each select="LCLTAXWHAGG">
                            <ddm:GL1099R_LocalInfo RECID="-1" OWNER="1" SOURCE="I" MODIFIEDON="{datetime:dateTime()}"
                                                   ENGINERECID="-1">
                                <xsl:if test="LCLDIST">
                                    <ddm:LocalDistribution VALUE="{format-number(round(LCLDIST),'#0')}" SOURCE="I"
                                                           MODIFIEDON="{datetime:dateTime()}"/>
                                </xsl:if>
                                <ddm:LocalWithholding VALUE="{format-number(round(AMOUNT),'#0')}" SOURCE="I"
                                                      MODIFIEDON="{datetime:dateTime()}"/>
                                <ddm:LocalityName VALUE="{NAMELCL}" SOURCE="I" MODIFIEDON="{datetime:dateTime()}"/>
                            </ddm:GL1099R_LocalInfo>
                        </xsl:for-each>
                        <!-- BEGIN: added for the new OFX tags beginning TY2011 - EEI (2012.01.26) -->
                        <xsl:if test="AMTALLOCABLEIRR">
                            <ddm:AmtAllocableIRR VALUE="{format-number(round(AMTALLOCABLEIRR),'#0')}" SOURCE="I"
                                                 MODIFIEDON="{datetime:dateTime()}"/>
                        </xsl:if>
                        <xsl:if test="FIRSTYEARDESIGROTH">
                            <ddm:FirstYearDesigRoth VALUE="{FIRSTYEARDESIGROTH}" SOURCE="I"
                                                    MODIFIEDON="{datetime:dateTime()}"/>
                        </xsl:if>
                        <!-- END: added for the new OFX tags beginning TY2011 - EEI (2012.01.26) -->
                    </ddm:GL1099R>
                </ddm:GL>
            </ddm:TAXDATA>
        </xsl:for-each>
    </xsl:template>
    <xsl:template match="TAX1099DIV_V100">
        <xsl:for-each select=".">
            <xsl:if test="(ORDDIV &gt; 0) or (QUALIFIEDDIV &gt; 0) or (TOTCAPGAIN &gt; 0) or (P28GAIN &gt; 0) or (UNRECSEC1250 &gt; 0) or (SEC1202 &gt; 0)">
                <ddm:TAXDATA TAXYEAR="{TAXYEAR}">
                    <ddm:FD>
                        <ddm:FDB RECID="-1" OWNER="1" SOURCE="I" MODIFIEDON="{datetime:dateTime()}" ENGINERECID="-1">
                            <ddm:FDB_L5_DIVIDEND RECID="-1" OWNER="1" SOURCE="I" MODIFIEDON="{datetime:dateTime()}"
                                                 ENGINERECID="-1">
                                <!-- 1099DIV -->
                                <ddm:TYPE VALUE="O" SOURCE="I" MODIFIEDON="{datetime:dateTime()}"/>
                                <ddm:source VALUE="{PAYERADDR/PAYERNAME1}" SOURCE="I"
                                            MODIFIEDON="{datetime:dateTime()}"/>
                                <xsl:if test="ORDDIV">
                                    <ddm:gross VALUE="{format-number(round(ORDDIV),'#0')}" SOURCE="I"
                                               MODIFIEDON="{datetime:dateTime()}"/>
                                </xsl:if>
                                <xsl:if test="TOTCAPGAIN">
                                    <ddm:cgd VALUE="{format-number(round(TOTCAPGAIN),'#0')}" SOURCE="I"
                                             MODIFIEDON="{datetime:dateTime()}"/>
                                </xsl:if>
                                <xsl:if test="NONTAXDIST">
                                    <ddm:nontaxable VALUE="{format-number(round(NONTAXDIST),'#0')}" SOURCE="I"
                                                    MODIFIEDON="{datetime:dateTime()}"/>
                                </xsl:if>
                                <xsl:if test="FEDTAXWH">
                                    <ddm:buwh VALUE="{format-number(round(FEDTAXWH),'#0')}" SOURCE="I"
                                              MODIFIEDON="{datetime:dateTime()}"/>
                                </xsl:if>
                                <xsl:if test="P28GAIN">
                                    <ddm:mid_cgd VALUE="{format-number(round(P28GAIN),'#0')}" SOURCE="I"
                                                 MODIFIEDON="{datetime:dateTime()}"/>
                                </xsl:if>
                                <xsl:if test="UNRECSEC1250">
                                    <ddm:S1250_gain VALUE="{format-number(round(UNRECSEC1250),'#0')}" SOURCE="I"
                                                    MODIFIEDON="{datetime:dateTime()}"/>
                                </xsl:if>
                                <xsl:if test="SEC1202">
                                    <ddm:gain1202 VALUE="{format-number(round(SEC1202),'#0')}" SOURCE="I"
                                                  MODIFIEDON="{datetime:dateTime()}"/>
                                </xsl:if>
                                <xsl:if test="FORTAXPD">
                                    <ddm:WEB_DIV_BOX6 VALUE="{format-number(round(FORTAXPD),'#0')}" SOURCE="I"
                                                      MODIFIEDON="{datetime:dateTime()}"/>
                                </xsl:if>
                                <xsl:if test="INVESTEXP">
                                    <ddm:WEB_DIV_BOX5 VALUE="{format-number(round(INVESTEXP),'#0')}" SOURCE="I"
                                                      MODIFIEDON="{datetime:dateTime()}"/>
                                </xsl:if>
                                <xsl:if test="QUALIFIEDDIV">
                                    <ddm:QUAL_DIV VALUE="{format-number(round(QUALIFIEDDIV),'#0')}" SOURCE="I"
                                                  MODIFIEDON="{datetime:dateTime()}"/>
                                </xsl:if>
                                <xsl:if test="PAYERADDR/PAYERNAME2">
                                    <ddm:PayerName2 VALUE="{PAYERADDR/PAYERNAME2}" SOURCE="I"
                                                    MODIFIEDON="{datetime:dateTime()}"/>
                                </xsl:if>
                                <ddm:PayerAddress1 VALUE="{PAYERADDR/ADDR1}" SOURCE="I"
                                                   MODIFIEDON="{datetime:dateTime()}"/>
                                <xsl:if test="PAYERADDR/ADDR2">
                                    <ddm:PayerAddress2 VALUE="{PAYERADDR/ADDR2}" SOURCE="I"
                                                       MODIFIEDON="{datetime:dateTime()}"/>
                                </xsl:if>
                                <xsl:if test="PAYERADDR/ADDR3">
                                    <ddm:PayerAddress3 VALUE="{PAYERADDR/ADDR3}" SOURCE="I"
                                                       MODIFIEDON="{datetime:dateTime()}"/>
                                </xsl:if>
                                <ddm:PayerCity VALUE="{PAYERADDR/CITY}" SOURCE="I" MODIFIEDON="{datetime:dateTime()}"/>
                                <ddm:PayerState VALUE="{PAYERADDR/STATE}" SOURCE="I"
                                                MODIFIEDON="{datetime:dateTime()}"/>
                                <ddm:PayerZipCode VALUE="{PAYERADDR/POSTALCODE}" SOURCE="I"
                                                  MODIFIEDON="{datetime:dateTime()}"/>
                                <xsl:if test="PAYERADDR/PHONE">
                                    <ddm:PayerPhone SOURCE="I" MODIFIEDON="{datetime:dateTime()}">
                                        <xsl:attribute name="VALUE">
                                            <xsl:call-template name="Strip-cntrycode">
                                                <xsl:with-param name="phone" select="PAYERADDR/PHONE"/>
                                            </xsl:call-template>
                                        </xsl:attribute>
                                    </ddm:PayerPhone>
                                </xsl:if>
                                <ddm:PayerEIN VALUE="{PAYERID}" SOURCE="I" MODIFIEDON="{datetime:dateTime()}">
                                    <xsl:attribute name="VALUE">
                                        <!-- <xsl:call-template name="Strip-dashes">
                                    <xsl:with-param name="ssn" select="PAYERID"/>
                                    </xsl:call-template> -->
                                        <xsl:call-template name="FixFedNumb">
                                            <xsl:with-param name="fednum" select="PAYERID"/>
                                        </xsl:call-template>
                                    </xsl:attribute>
                                </ddm:PayerEIN>
                                <xsl:if test="RECADDR">
                                    <ddm:RecipientName1 VALUE="{RECADDR/RECNAME1}" SOURCE="I"
                                                        MODIFIEDON="{datetime:dateTime()}"/>
                                    <xsl:if test="RECADDR/RECNAME2">
                                        <ddm:RecipientName2 VALUE="{RECADDR/RECNAME2}" SOURCE="I"
                                                            MODIFIEDON="{datetime:dateTime()}"/>
                                    </xsl:if>
                                    <ddm:RecipientAddr1 VALUE="{RECADDR/ADDR1}" SOURCE="I"
                                                        MODIFIEDON="{datetime:dateTime()}"/>
                                    <xsl:if test="RECADDR/ADDR2">
                                        <ddm:RecipientAddr2 VALUE="{RECADDR/ADDR2}" SOURCE="I"
                                                            MODIFIEDON="{datetime:dateTime()}"/>
                                    </xsl:if>
                                    <xsl:if test="RECADDR/ADDR3">
                                        <ddm:RecipientAddr3 VALUE="{RECADDR/ADDR3}" SOURCE="I"
                                                            MODIFIEDON="{datetime:dateTime()}"/>
                                    </xsl:if>
                                    <xsl:if test="RECADDR/CITY">
                                        <ddm:RecipientCity VALUE="{RECADDR/CITY}" SOURCE="I"
                                                           MODIFIEDON="{datetime:dateTime()}"/>
                                    </xsl:if>
                                    <xsl:if test="RECADDR/STATE">
                                        <ddm:RecipientState VALUE="{RECADDR/STATE}" SOURCE="I"
                                                            MODIFIEDON="{datetime:dateTime()}"/>
                                    </xsl:if>
                                    <xsl:if test="RECADDR/POSTALCODE">
                                        <ddm:RecipientZipCode VALUE="{RECADDR/POSTALCODE}" SOURCE="I"
                                                              MODIFIEDON="{datetime:dateTime()}"/>
                                    </xsl:if>
                                </xsl:if>
                                <ddm:RecipientSSN SOURCE="I" MODIFIEDON="{datetime:dateTime()}">
                                    <xsl:attribute name="VALUE">
                                        <xsl:call-template name="Strip-dashes">
                                            <xsl:with-param name="ssn" select="RECID"/>
                                        </xsl:call-template>
                                    </xsl:attribute>
                                </ddm:RecipientSSN>
                                <xsl:if test="RECACCT">
                                    <ddm:AccountNumber VALUE="{RECACCT}" SOURCE="I" MODIFIEDON="{datetime:dateTime()}"/>
                                </xsl:if>
                                <!-- TY2015 changes Dec 17 2015 start -->
                                <xsl:if test="FATCA">
                                    <ddm:QFATCA VALUE="{FATCA}" SOURCE="I" MODIFIEDON="{datetime:dateTime()}">
                                        <xsl:attribute name="VALUE">
                                            <xsl:call-template name="BoolToBin">
                                                <xsl:with-param name="value" select="FATCA"/>
                                            </xsl:call-template>
                                        </xsl:attribute>
                                    </ddm:QFATCA>
                                </xsl:if>
                                <!-- TY2015 changes Dec 17 2015 end -->

                                <xsl:if test="VOID">
                                    <ddm:VoidCheckBox VALUE="{VOID}" SOURCE="I" MODIFIEDON="{datetime:dateTime()}"/>
                                </xsl:if>
                                <xsl:if test="CORRECTED">
                                    <ddm:Corrected VALUE="{CORRECTED}" SOURCE="I" MODIFIEDON="{datetime:dateTime()}"/>
                                </xsl:if>
                                <xsl:if test="FORCNT">
                                    <ddm:CountryPaid VALUE="{FORCNT}" SOURCE="I" MODIFIEDON="{datetime:dateTime()}"/>
                                </xsl:if>
                                <xsl:if test="CASHLIQ">
                                    <ddm:CashLiquidation VALUE="{CASHLIQ}" SOURCE="I"
                                                         MODIFIEDON="{datetime:dateTime()}"/>
                                </xsl:if>
                                <xsl:if test="NONCASHLIQ">
                                    <ddm:NonCashLiquidation VALUE="{NONCASHLIQ}" SOURCE="I"
                                                            MODIFIEDON="{datetime:dateTime()}"/>
                                </xsl:if>
                                <xsl:if test="TOTCAPGAIN">
                                    <ddm:TotCapGain VALUE="{TOTCAPGAIN}" SOURCE="I" MODIFIEDON="{datetime:dateTime()}"/>
                                </xsl:if>
                                <!-- TY2014 changes to OFX addendum Nov20 2014 start -->
                                <xsl:choose>
                                    <xsl:when test="ADDLSTATETAXWHAGG">
                                        <xsl:for-each select="ADDLSTATETAXWHAGG">
                                            <xsl:if test="position() = 1">
                                                <xsl:if test="STATECODE">
                                                    <ddm:StateCode VALUE="{STATECODE}" SOURCE="I"
                                                                   MODIFIEDON="{datetime:dateTime()}"/>
                                                </xsl:if>
                                                <xsl:if test="STATEIDNUM">
                                                    <ddm:StateIdNum VALUE="{STATEIDNUM}" SOURCE="I"
                                                                    MODIFIEDON="{datetime:dateTime()}"/>
                                                </xsl:if>
                                                <xsl:if test="STATETAXWHELD">
                                                    <ddm:StateTaxWheld
                                                            VALUE="{format-number(round(STATETAXWHELD),'#0')}"
                                                            SOURCE="I" MODIFIEDON="{datetime:dateTime()}"/>
                                                </xsl:if>
                                            </xsl:if>
                                            <xsl:if test="position() = 2">
                                                <xsl:if test="STATECODE">
                                                    <ddm:StateCode2 VALUE="{STATECODE}" SOURCE="I"
                                                                    MODIFIEDON="{datetime:dateTime()}"/>
                                                </xsl:if>
                                                <xsl:if test="STATEIDNUM">
                                                    <ddm:StateIdNum2 VALUE="{STATEIDNUM}" SOURCE="I"
                                                                     MODIFIEDON="{datetime:dateTime()}"/>
                                                </xsl:if>
                                                <xsl:if test="STATETAXWHELD">
                                                    <ddm:StateTaxWheld2
                                                            VALUE="{format-number(round(STATETAXWHELD),'#0')}"
                                                            SOURCE="I" MODIFIEDON="{datetime:dateTime()}"/>
                                                </xsl:if>
                                            </xsl:if>
                                        </xsl:for-each>
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <xsl:if test="STATECODE">
                                            <ddm:StateCode VALUE="{STATECODE}" SOURCE="I"
                                                           MODIFIEDON="{datetime:dateTime()}"/>
                                        </xsl:if>
                                        <xsl:if test="STATEIDNUM">
                                            <ddm:StateIdNum VALUE="{STATEIDNUM}" SOURCE="I"
                                                            MODIFIEDON="{datetime:dateTime()}"/>
                                        </xsl:if>
                                        <xsl:if test="STATETAXWHELD">
                                            <ddm:StateTaxWheld VALUE="{format-number(round(STATETAXWHELD),'#0')}"
                                                               SOURCE="I" MODIFIEDON="{datetime:dateTime()}"/>
                                        </xsl:if>
                                    </xsl:otherwise>
                                </xsl:choose>
                                <!-- TY2014 changes to OFX addendum Nov 20th 2013 end -->
                            </ddm:FDB_L5_DIVIDEND>
                        </ddm:FDB>
                    </ddm:FD>
                </ddm:TAXDATA>
            </xsl:if>
            <xsl:if test="(EXEMPTINTDIV &gt; 0)   or (SPECIFIEDPABINTDIV &gt; 0)">
                <ddm:TAXDATA TAXYEAR="{TAXYEAR}">
                    <ddm:FD>
                        <ddm:FDB RECID="-1" OWNER="1" SOURCE="I" MODIFIEDON="{datetime:dateTime()}" ENGINERECID="-1">
                            <ddm:FDB_L5_DIVIDEND RECID="-1" OWNER="1" SOURCE="I" MODIFIEDON="{datetime:dateTime()}"
                                                 ENGINERECID="-1">
                                <!-- 1099DIV -->
                                <ddm:TYPE VALUE="F" SOURCE="I" MODIFIEDON="{datetime:dateTime()}"/>
                                <ddm:source VALUE="{PAYERADDR/PAYERNAME1}" SOURCE="I"
                                            MODIFIEDON="{datetime:dateTime()}"/>
                                <!--
                            <xsl:if test="NONTAXDIST">
                            <ddm:nontaxable VALUE="{format-number(round(NONTAXDIST),'#0')}" SOURCE="I" MODIFIEDON="{datetime:dateTime()}"/>
                            </xsl:if>
                            <xsl:if test="FEDTAXWH">
                            <ddm:buwh VALUE="{format-number(round(FEDTAXWH),'#0')}" SOURCE="I" MODIFIEDON="{datetime:dateTime()}"/>
                            </xsl:if>
                            <xsl:if test="FORTAXPD">
                            <ddm:WEB_DIV_BOX6 VALUE="{format-number(round(FORTAXPD),'#0')}" SOURCE="I" MODIFIEDON="{datetime:dateTime()}"/>
                            </xsl:if>
                            <xsl:if test="INVESTEXP">
                            <ddm:WEB_DIV_BOX5 VALUE="{format-number(round(INVESTEXP),'#0')}" SOURCE="I" MODIFIEDON="{datetime:dateTime()}"/>
                            </xsl:if>
                            -->
                                <xsl:if test="PAYERADDR/PAYERNAME2">
                                    <ddm:PayerName2 VALUE="{PAYERADDR/PAYERNAME2}" SOURCE="I"
                                                    MODIFIEDON="{datetime:dateTime()}"/>
                                </xsl:if>
                                <ddm:PayerAddress1 VALUE="{PAYERADDR/ADDR1}" SOURCE="I"
                                                   MODIFIEDON="{datetime:dateTime()}"/>
                                <xsl:if test="PAYERADDR/ADDR2">
                                    <ddm:PayerAddress2 VALUE="{PAYERADDR/ADDR2}" SOURCE="I"
                                                       MODIFIEDON="{datetime:dateTime()}"/>
                                </xsl:if>
                                <xsl:if test="PAYERADDR/ADDR3">
                                    <ddm:PayerAddress3 VALUE="{PAYERADDR/ADDR3}" SOURCE="I"
                                                       MODIFIEDON="{datetime:dateTime()}"/>
                                </xsl:if>
                                <ddm:PayerCity VALUE="{PAYERADDR/CITY}" SOURCE="I" MODIFIEDON="{datetime:dateTime()}"/>
                                <ddm:PayerState VALUE="{PAYERADDR/STATE}" SOURCE="I"
                                                MODIFIEDON="{datetime:dateTime()}"/>
                                <ddm:PayerZipCode VALUE="{PAYERADDR/POSTALCODE}" SOURCE="I"
                                                  MODIFIEDON="{datetime:dateTime()}"/>
                                <xsl:if test="PAYERADDR/PHONE">
                                    <ddm:PayerPhone SOURCE="I" MODIFIEDON="{datetime:dateTime()}">
                                        <xsl:attribute name="VALUE">
                                            <xsl:call-template name="Strip-cntrycode">
                                                <xsl:with-param name="phone" select="PAYERADDR/PHONE"/>
                                            </xsl:call-template>
                                        </xsl:attribute>
                                    </ddm:PayerPhone>
                                </xsl:if>
                                <ddm:PayerEIN VALUE="{PAYERID}" SOURCE="I" MODIFIEDON="{datetime:dateTime()}">
                                    <xsl:attribute name="VALUE">
                                        <!-- <xsl:call-template name="Strip-dashes">
                                    <xsl:with-param name="ssn" select="PAYERID"/>
                                    </xsl:call-template> -->
                                        <xsl:call-template name="FixFedNumb">
                                            <xsl:with-param name="fednum" select="PAYERID"/>
                                        </xsl:call-template>
                                    </xsl:attribute>
                                </ddm:PayerEIN>
                                <xsl:if test="RECADDR">
                                    <ddm:RecipientName1 VALUE="{RECADDR/RECNAME1}" SOURCE="I"
                                                        MODIFIEDON="{datetime:dateTime()}"/>
                                    <xsl:if test="RECADDR/RECNAME2">
                                        <ddm:RecipientName2 VALUE="{RECADDR/RECNAME2}" SOURCE="I"
                                                            MODIFIEDON="{datetime:dateTime()}"/>
                                    </xsl:if>
                                    <ddm:RecipientAddr1 VALUE="{RECADDR/ADDR1}" SOURCE="I"
                                                        MODIFIEDON="{datetime:dateTime()}"/>
                                    <xsl:if test="RECADDR/ADDR2">
                                        <ddm:RecipientAddr2 VALUE="{RECADDR/ADDR2}" SOURCE="I"
                                                            MODIFIEDON="{datetime:dateTime()}"/>
                                    </xsl:if>
                                    <xsl:if test="RECADDR/ADDR3">
                                        <ddm:RecipientAddr3 VALUE="{RECADDR/ADDR3}" SOURCE="I"
                                                            MODIFIEDON="{datetime:dateTime()}"/>
                                    </xsl:if>
                                    <xsl:if test="RECADDR/CITY">
                                        <ddm:RecipientCity VALUE="{RECADDR/CITY}" SOURCE="I"
                                                           MODIFIEDON="{datetime:dateTime()}"/>
                                    </xsl:if>
                                    <xsl:if test="RECADDR/STATE">
                                        <ddm:RecipientState VALUE="{RECADDR/STATE}" SOURCE="I"
                                                            MODIFIEDON="{datetime:dateTime()}"/>
                                    </xsl:if>
                                    <xsl:if test="RECADDR/POSTALCODE">
                                        <ddm:RecipientZipCode VALUE="{RECADDR/POSTALCODE}" SOURCE="I"
                                                              MODIFIEDON="{datetime:dateTime()}"/>
                                    </xsl:if>
                                </xsl:if>
                                <ddm:RecipientSSN SOURCE="I" MODIFIEDON="{datetime:dateTime()}">
                                    <xsl:attribute name="VALUE">
                                        <xsl:call-template name="Strip-dashes">
                                            <xsl:with-param name="ssn" select="RECID"/>
                                        </xsl:call-template>
                                    </xsl:attribute>
                                </ddm:RecipientSSN>
                                <xsl:if test="RECACCT">
                                    <ddm:AccountNumber VALUE="{RECACCT}" SOURCE="I" MODIFIEDON="{datetime:dateTime()}"/>
                                </xsl:if>
                                <!-- TY2015 changes Dec 17 2015 start -->
                                <xsl:if test="FATCA">
                                    <ddm:QFATCA VALUE="{FATCA}" SOURCE="I" MODIFIEDON="{datetime:dateTime()}">
                                        <xsl:attribute name="VALUE">
                                            <xsl:call-template name="BoolToBin">
                                                <xsl:with-param name="value" select="FATCA"/>
                                            </xsl:call-template>
                                        </xsl:attribute>
                                    </ddm:QFATCA>
                                </xsl:if>
                                <!-- TY2015 changes Dec 17 2015 end -->
                                <!-- TY2015 changes Dec 17 2015 end -->
                                <xsl:if test="VOID">
                                    <ddm:VoidCheckBox VALUE="{VOID}" SOURCE="I" MODIFIEDON="{datetime:dateTime()}"/>
                                </xsl:if>
                                <xsl:if test="CORRECTED">
                                    <ddm:Corrected VALUE="{CORRECTED}" SOURCE="I" MODIFIEDON="{datetime:dateTime()}"/>
                                </xsl:if>
                                <!--
                            <xsl:if test="FORCNT">
                            <ddm:CountryPaid VALUE="{FORCNT}" SOURCE="I" MODIFIEDON="{datetime:dateTime()}"/>
                            </xsl:if>
                            <xsl:if test="CASHLIQ">
                            <ddm:CashLiquidation VALUE="{CASHLIQ}" SOURCE="I" MODIFIEDON="{datetime:dateTime()}"/>
                            </xsl:if>
                            <xsl:if test="NONCASHLIQ">
                            <ddm:NonCashLiquidation VALUE="{NONCASHLIQ}" SOURCE="I" MODIFIEDON="{datetime:dateTime()}"/>
                            </xsl:if>
                            -->

                                <!-- 2013 changes to OFX addendum Oct8th 2012 start
                            commented 11th jan 2012 as state with holding should be in Type O only
                            <xsl:if test="STATECODE">
                            <ddm:StateCode VALUE="{STATECODE}" SOURCE="I" MODIFIEDON="{datetime:dateTime()}"/>
                            </xsl:if>
                            <xsl:if test="STATEIDNUM">
                            <ddm:StateIdNum VALUE="{STATEIDNUM}" SOURCE="I" MODIFIEDON="{datetime:dateTime()}"/>
                            </xsl:if>
                            <xsl:if test="STATETAXWHELD">
                            <ddm:StateTaxWheld VALUE="{format-number(round(STATETAXWHELD),'#0')}" SOURCE="I" MODIFIEDON="{datetime:dateTime()}"/>
                            </xsl:if>
                            -->
                                <xsl:if test="EXEMPTINTDIV">
                                    <ddm:ExemptIntDiv VALUE="{format-number(round(EXEMPTINTDIV),'#0')}" SOURCE="I"
                                                      MODIFIEDON="{datetime:dateTime()}"/>
                                </xsl:if>
                                <xsl:if test="SPECIFIEDPABINTDIV">
                                    <ddm:SpecifiedPabIntDiv VALUE="{format-number(round(SPECIFIEDPABINTDIV),'#0')}"
                                                            SOURCE="I" MODIFIEDON="{datetime:dateTime()}"/>
                                </xsl:if>
                                <!-- 2013 changes to OFX addendum Oct8th 2012 end -->
                            </ddm:FDB_L5_DIVIDEND>
                        </ddm:FDB>
                    </ddm:FD>
                </ddm:TAXDATA>
            </xsl:if>
            <xsl:if test="((EXEMPTINTDIV &lt; 0) and (SPECIFIEDPABINTDIV &lt; 0)) or ((ORDDIV &lt; 0) and (QUALIFIEDDIV &lt; 0) and (TOTCAPGAIN &lt; 0) and (P28GAIN &lt; 0) and (UNRECSEC1250 &lt; 0) and (SEC1202 &lt; 0))">
                <ddm:TAXDATA TAXYEAR="{TAXYEAR}">
                    <ddm:FD>
                        <ddm:FDB RECID="-1" OWNER="1" SOURCE="I" MODIFIEDON="{datetime:dateTime()}" ENGINERECID="-1">
                            <ddm:FDB_L5_DIVIDEND RECID="-1" OWNER="1" SOURCE="I" MODIFIEDON="{datetime:dateTime()}"
                                                 ENGINERECID="-1">
                                <!-- 1099DIV -->
                                <ddm:TYPE VALUE="O" SOURCE="I" MODIFIEDON="{datetime:dateTime()}"/>
                                <ddm:source VALUE="{PAYERADDR/PAYERNAME1}" SOURCE="I"
                                            MODIFIEDON="{datetime:dateTime()}"/>
                                <xsl:if test="ORDDIV">
                                    <ddm:gross VALUE="{format-number(round(ORDDIV),'#0')}" SOURCE="I"
                                               MODIFIEDON="{datetime:dateTime()}"/>
                                </xsl:if>
                                <xsl:if test="TOTCAPGAIN">
                                    <ddm:cgd VALUE="{format-number(round(TOTCAPGAIN),'#0')}" SOURCE="I"
                                             MODIFIEDON="{datetime:dateTime()}"/>
                                </xsl:if>
                                <xsl:if test="NONTAXDIST">
                                    <ddm:nontaxable VALUE="{format-number(round(NONTAXDIST),'#0')}" SOURCE="I"
                                                    MODIFIEDON="{datetime:dateTime()}"/>
                                </xsl:if>
                                <xsl:if test="FEDTAXWH">
                                    <ddm:buwh VALUE="{format-number(round(FEDTAXWH),'#0')}" SOURCE="I"
                                              MODIFIEDON="{datetime:dateTime()}"/>
                                </xsl:if>
                                <xsl:if test="P28GAIN">
                                    <ddm:mid_cgd VALUE="{format-number(round(P28GAIN),'#0')}" SOURCE="I"
                                                 MODIFIEDON="{datetime:dateTime()}"/>
                                </xsl:if>
                                <xsl:if test="UNRECSEC1250">
                                    <ddm:S1250_gain VALUE="{format-number(round(UNRECSEC1250),'#0')}" SOURCE="I"
                                                    MODIFIEDON="{datetime:dateTime()}"/>
                                </xsl:if>
                                <xsl:if test="SEC1202">
                                    <ddm:gain1202 VALUE="{format-number(round(SEC1202),'#0')}" SOURCE="I"
                                                  MODIFIEDON="{datetime:dateTime()}"/>
                                </xsl:if>
                                <xsl:if test="FORTAXPD">
                                    <ddm:WEB_DIV_BOX6 VALUE="{format-number(round(FORTAXPD),'#0')}" SOURCE="I"
                                                      MODIFIEDON="{datetime:dateTime()}"/>
                                </xsl:if>
                                <xsl:if test="INVESTEXP">
                                    <ddm:WEB_DIV_BOX5 VALUE="{format-number(round(INVESTEXP),'#0')}" SOURCE="I"
                                                      MODIFIEDON="{datetime:dateTime()}"/>
                                </xsl:if>

                                <xsl:if test="QUALIFIEDDIV">
                                    <ddm:QUAL_DIV VALUE="{format-number(round(QUALIFIEDDIV),'#0')}" SOURCE="I"
                                                  MODIFIEDON="{datetime:dateTime()}"/>
                                </xsl:if>
                                <xsl:if test="PAYERADDR/PAYERNAME2">
                                    <ddm:PayerName2 VALUE="{PAYERADDR/PAYERNAME2}" SOURCE="I"
                                                    MODIFIEDON="{datetime:dateTime()}"/>
                                </xsl:if>
                                <ddm:PayerAddress1 VALUE="{PAYERADDR/ADDR1}" SOURCE="I"
                                                   MODIFIEDON="{datetime:dateTime()}"/>
                                <xsl:if test="PAYERADDR/ADDR2">
                                    <ddm:PayerAddress2 VALUE="{PAYERADDR/ADDR2}" SOURCE="I"
                                                       MODIFIEDON="{datetime:dateTime()}"/>
                                </xsl:if>
                                <xsl:if test="PAYERADDR/ADDR3">
                                    <ddm:PayerAddress3 VALUE="{PAYERADDR/ADDR3}" SOURCE="I"
                                                       MODIFIEDON="{datetime:dateTime()}"/>
                                </xsl:if>
                                <ddm:PayerCity VALUE="{PAYERADDR/CITY}" SOURCE="I" MODIFIEDON="{datetime:dateTime()}"/>
                                <ddm:PayerState VALUE="{PAYERADDR/STATE}" SOURCE="I"
                                                MODIFIEDON="{datetime:dateTime()}"/>
                                <ddm:PayerZipCode VALUE="{PAYERADDR/POSTALCODE}" SOURCE="I"
                                                  MODIFIEDON="{datetime:dateTime()}"/>
                                <xsl:if test="PAYERADDR/PHONE">
                                    <ddm:PayerPhone SOURCE="I" MODIFIEDON="{datetime:dateTime()}">
                                        <xsl:attribute name="VALUE">
                                            <xsl:call-template name="Strip-cntrycode">
                                                <xsl:with-param name="phone" select="PAYERADDR/PHONE"/>
                                            </xsl:call-template>
                                        </xsl:attribute>
                                    </ddm:PayerPhone>
                                </xsl:if>
                                <ddm:PayerEIN VALUE="{PAYERID}" SOURCE="I" MODIFIEDON="{datetime:dateTime()}">
                                    <xsl:attribute name="VALUE">
                                        <!-- <xsl:call-template name="Strip-dashes">
                                    <xsl:with-param name="ssn" select="PAYERID"/>
                                    </xsl:call-template> -->
                                        <xsl:call-template name="FixFedNumb">
                                            <xsl:with-param name="fednum" select="PAYERID"/>
                                        </xsl:call-template>
                                    </xsl:attribute>
                                </ddm:PayerEIN>
                                <xsl:if test="RECADDR">
                                    <ddm:RecipientName1 VALUE="{RECADDR/RECNAME1}" SOURCE="I"
                                                        MODIFIEDON="{datetime:dateTime()}"/>
                                    <xsl:if test="RECADDR/RECNAME2">
                                        <ddm:RecipientName2 VALUE="{RECADDR/RECNAME2}" SOURCE="I"
                                                            MODIFIEDON="{datetime:dateTime()}"/>
                                    </xsl:if>
                                    <ddm:RecipientAddr1 VALUE="{RECADDR/ADDR1}" SOURCE="I"
                                                        MODIFIEDON="{datetime:dateTime()}"/>
                                    <xsl:if test="RECADDR/ADDR2">
                                        <ddm:RecipientAddr2 VALUE="{RECADDR/ADDR2}" SOURCE="I"
                                                            MODIFIEDON="{datetime:dateTime()}"/>
                                    </xsl:if>
                                    <xsl:if test="RECADDR/ADDR3">
                                        <ddm:RecipientAddr3 VALUE="{RECADDR/ADDR3}" SOURCE="I"
                                                            MODIFIEDON="{datetime:dateTime()}"/>
                                    </xsl:if>
                                    <xsl:if test="RECADDR/CITY">
                                        <ddm:RecipientCity VALUE="{RECADDR/CITY}" SOURCE="I"
                                                           MODIFIEDON="{datetime:dateTime()}"/>
                                    </xsl:if>
                                    <xsl:if test="RECADDR/STATE">
                                        <ddm:RecipientState VALUE="{RECADDR/STATE}" SOURCE="I"
                                                            MODIFIEDON="{datetime:dateTime()}"/>
                                    </xsl:if>
                                    <xsl:if test="RECADDR/POSTALCODE">
                                        <ddm:RecipientZipCode VALUE="{RECADDR/POSTALCODE}" SOURCE="I"
                                                              MODIFIEDON="{datetime:dateTime()}"/>
                                    </xsl:if>
                                </xsl:if>
                                <ddm:RecipientSSN SOURCE="I" MODIFIEDON="{datetime:dateTime()}">
                                    <xsl:attribute name="VALUE">
                                        <xsl:call-template name="Strip-dashes">
                                            <xsl:with-param name="ssn" select="RECID"/>
                                        </xsl:call-template>
                                    </xsl:attribute>
                                </ddm:RecipientSSN>
                                <xsl:if test="RECACCT">
                                    <ddm:AccountNumber VALUE="{RECACCT}" SOURCE="I" MODIFIEDON="{datetime:dateTime()}"/>
                                </xsl:if>
                                <!-- TY2015 changes Dec 17 2015 start -->
                                <xsl:if test="FATCA">
                                    <ddm:QFATCA VALUE="{FATCA}" SOURCE="I" MODIFIEDON="{datetime:dateTime()}">
                                        <xsl:attribute name="VALUE">
                                            <xsl:call-template name="BoolToBin">
                                                <xsl:with-param name="value" select="FATCA"/>
                                            </xsl:call-template>
                                        </xsl:attribute>
                                    </ddm:QFATCA>
                                </xsl:if>
                                <!-- TY2015 changes Dec 17 2015 end -->
                                <!-- TY2015 changes Dec 17 2015 end -->
                                <xsl:if test="VOID">
                                    <ddm:VoidCheckBox VALUE="{VOID}" SOURCE="I" MODIFIEDON="{datetime:dateTime()}"/>
                                </xsl:if>
                                <xsl:if test="CORRECTED">
                                    <ddm:Corrected VALUE="{CORRECTED}" SOURCE="I" MODIFIEDON="{datetime:dateTime()}"/>
                                </xsl:if>
                                <xsl:if test="FORCNT">
                                    <ddm:CountryPaid VALUE="{FORCNT}" SOURCE="I" MODIFIEDON="{datetime:dateTime()}"/>
                                </xsl:if>
                                <xsl:if test="CASHLIQ">
                                    <ddm:CashLiquidation VALUE="{CASHLIQ}" SOURCE="I"
                                                         MODIFIEDON="{datetime:dateTime()}"/>
                                </xsl:if>
                                <xsl:if test="NONCASHLIQ">
                                    <ddm:NonCashLiquidation VALUE="{NONCASHLIQ}" SOURCE="I"
                                                            MODIFIEDON="{datetime:dateTime()}"/>
                                </xsl:if>
                                <xsl:if test="TOTCAPGAIN">
                                    <ddm:TotCapGain VALUE="{TOTCAPGAIN}" SOURCE="I" MODIFIEDON="{datetime:dateTime()}"/>
                                </xsl:if>
                                <!-- TY2014 changes to OFX addendum Nov20 2014 start -->
                                <xsl:choose>
                                    <xsl:when test="ADDLSTATETAXWHAGG">
                                        <xsl:for-each select="ADDLSTATETAXWHAGG">
                                            <xsl:if test="position() = 1">
                                                <xsl:if test="STATECODE">
                                                    <ddm:StateCode VALUE="{STATECODE}" SOURCE="I"
                                                                   MODIFIEDON="{datetime:dateTime()}"/>
                                                </xsl:if>
                                                <xsl:if test="STATEIDNUM">
                                                    <ddm:StateIdNum VALUE="{STATEIDNUM}" SOURCE="I"
                                                                    MODIFIEDON="{datetime:dateTime()}"/>
                                                </xsl:if>
                                                <xsl:if test="STATETAXWHELD">
                                                    <ddm:StateTaxWheld
                                                            VALUE="{format-number(round(STATETAXWHELD),'#0')}"
                                                            SOURCE="I" MODIFIEDON="{datetime:dateTime()}"/>
                                                </xsl:if>
                                            </xsl:if>
                                            <xsl:if test="position() = 2">
                                                <xsl:if test="STATECODE">
                                                    <ddm:StateCode2 VALUE="{STATECODE}" SOURCE="I"
                                                                    MODIFIEDON="{datetime:dateTime()}"/>
                                                </xsl:if>
                                                <xsl:if test="STATEIDNUM">
                                                    <ddm:StateIdNum2 VALUE="{STATEIDNUM}" SOURCE="I"
                                                                     MODIFIEDON="{datetime:dateTime()}"/>
                                                </xsl:if>
                                                <xsl:if test="STATETAXWHELD">
                                                    <ddm:StateTaxWheld2
                                                            VALUE="{format-number(round(STATETAXWHELD),'#0')}"
                                                            SOURCE="I" MODIFIEDON="{datetime:dateTime()}"/>
                                                </xsl:if>
                                            </xsl:if>
                                        </xsl:for-each>
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <xsl:if test="STATECODE">
                                            <ddm:StateCode VALUE="{STATECODE}" SOURCE="I"
                                                           MODIFIEDON="{datetime:dateTime()}"/>
                                        </xsl:if>
                                        <xsl:if test="STATEIDNUM">
                                            <ddm:StateIdNum VALUE="{STATEIDNUM}" SOURCE="I"
                                                            MODIFIEDON="{datetime:dateTime()}"/>
                                        </xsl:if>
                                        <xsl:if test="STATETAXWHELD">
                                            <ddm:StateTaxWheld VALUE="{format-number(round(STATETAXWHELD),'#0')}"
                                                               SOURCE="I" MODIFIEDON="{datetime:dateTime()}"/>
                                        </xsl:if>
                                    </xsl:otherwise>
                                </xsl:choose>
                                <!-- TY2014 changes to OFX addendum Nov 20th 2013 end -->
                            </ddm:FDB_L5_DIVIDEND>
                        </ddm:FDB>
                    </ddm:FD>
                </ddm:TAXDATA>
            </xsl:if>
        </xsl:for-each>
    </xsl:template>
    <xsl:template match="TAX1099INT_V100">
        <xsl:for-each select=".">
            <xsl:choose>
                <xsl:when
                        test="( ( (INTINCOME) or (ERLWITHPEN) or (INTUSBNDTRS) or (FEDTAXWH) or (INVESTEXP) or (FORTAXPD) or (FORCNT) ) and not ((TAXEXEMPTINT) or (SPECIFIEDPABINT)) )"> <!-- (1 or 7) and no (8 or 9) -->
                    <ddm:TAXDATA TAXYEAR="{TAXYEAR}">


                        <ddm:FD>
                            <ddm:FDB RECID="-1" OWNER="1" SOURCE="I" MODIFIEDON="{datetime:dateTime()}"
                                     ENGINERECID="-1">


                                <ddm:FDB_L1_INTEREST RECID="-1" OWNER="1" SOURCE="I" MODIFIEDON="{datetime:dateTime()}"
                                                     ENGINERECID="-1">
                                    <!--1099INT-->
                                    <ddm:Int_Source VALUE="{PAYERADDR/PAYERNAME1}" SOURCE="I"
                                                    MODIFIEDON="{datetime:dateTime()}"/>
                                    <xsl:if test="INTINCOME">
                                        <ddm:Int_Box1 VALUE="{format-number(round(INTINCOME),'#0')}" SOURCE="I"
                                                      MODIFIEDON="{datetime:dateTime()}"/>
                                    </xsl:if>
                                    <xsl:if test="ERLWITHPEN">
                                        <ddm:Int_Box2 VALUE="{ERLWITHPEN}" SOURCE="I"
                                                      MODIFIEDON="{datetime:dateTime()}"/>
                                    </xsl:if>
                                    <!-- Int_Box3 uncommented by Aparna -->
                                    <xsl:if test="INTUSBNDTRS">
                                        <ddm:Int_Box3 VALUE="{format-number(round(INTUSBNDTRS),'#0')}" SOURCE="I"
                                                      MODIFIEDON="{datetime:dateTime()}"/>
                                    </xsl:if>
                                    <xsl:if test="FEDTAXWH">
                                        <ddm:Int_Box4 VALUE="{format-number(round(FEDTAXWH),'#0')}" SOURCE="I"
                                                      MODIFIEDON="{datetime:dateTime()}"/>
                                    </xsl:if>
                                    <xsl:if test="INVESTEXP">
                                        <ddm:Int_Box5 VALUE="{format-number(round(INVESTEXP),'#0')}" SOURCE="I"
                                                      MODIFIEDON="{datetime:dateTime()}"/>
                                    </xsl:if>
                                    <xsl:if test="FORTAXPD">
                                        <ddm:Int_Box6 VALUE="{format-number(round(FORTAXPD),'#0')}" SOURCE="I"
                                                      MODIFIEDON="{datetime:dateTime()}"/>
                                    </xsl:if>
                                    <ddm:INTEREST_TYPE VALUE="I" SOURCE="I" MODIFIEDON="{datetime:dateTime()}"/>
                                    <xsl:if test="TAXEXEMPTINT">
                                        <ddm:INT_EXEMPT VALUE="{format-number(round(TAXEXEMPTINT),'#0')}" SOURCE="I"
                                                        MODIFIEDON="{datetime:dateTime()}"/>
                                    </xsl:if>
                                    <ddm:DISPLAY_NAME VALUE="{PAYERADDR/PAYERNAME1}" SOURCE="I"
                                                      MODIFIEDON="{datetime:dateTime()}"/>
                                    <xsl:if test="INTINCOME">
                                        <ddm:DISPLAY_AMOUNT VALUE="{format-number(round(INTINCOME),'#0')}" SOURCE="I"
                                                            MODIFIEDON="{datetime:dateTime()}"/>
                                    </xsl:if>
                                    <xsl:if test="SPECIFIEDPABINT">
                                        <ddm:INT_AMT_AMOUNT VALUE="{format-number(round(SPECIFIEDPABINT),'#0')}"
                                                            SOURCE="I" MODIFIEDON="{datetime:dateTime()}"/>
                                    </xsl:if>
                                    <!-- TY2014 changes Nov 26 2014 start -->
                                    <xsl:if test="MARKETDISCOUNT">
                                        <ddm:marketDiscount VALUE="{format-number(round(MARKETDISCOUNT),'#0')}"
                                                            SOURCE="I" MODIFIEDON="{datetime:dateTime()}"/>
                                    </xsl:if>
                                    <xsl:if test="BONDPREMIUM">
                                        <ddm:bondPremium VALUE="{format-number(round(BONDPREMIUM),'#0')}" SOURCE="I"
                                                         MODIFIEDON="{datetime:dateTime()}"/>
                                    </xsl:if>
                                    <!-- ty2014 changes nov 26 2014 end -->
                                    <!-- TY2015 changes Dec 17 2015 start -->
                                    <xsl:if test="TEBONDPREMIUM">
                                        <ddm:EXEMPTBONDPREMIUM VALUE="{format-number(round(TEBONDPREMIUM),'#0')}"
                                                               SOURCE="I" MODIFIEDON="{datetime:dateTime()}"/>
                                    </xsl:if>
                                    <!-- TY2015 changes Dec 17 2015 end -->

                                    <!-- TY2014 changes to OFX addendum Nov20 2014 start
                                TY13 Schema - there is now a CHOICE when reporting StateTaxWheld: If one State to report - you can continue to use the TY12 tags (STATECODE, STATEIDNUM, STATETAXWHELD), OR you can use the new <ADDLSTATETAXWHAGG>. YOU CANNOT USE BOTH!
                                -->
                                    <xsl:choose>
                                        <xsl:when test="ADDLSTATETAXWHAGG">
                                            <xsl:variable name="sttaxwhagcnt" select="count(ADDLSTATETAXWHAGG)"/>
                                            <xsl:for-each select="ADDLSTATETAXWHAGG">
                                                <xsl:if test="position() = 1">
                                                    <xsl:if test="STATECODE">
                                                        <ddm:StateCode VALUE="{STATECODE}" SOURCE="I"
                                                                       MODIFIEDON="{datetime:dateTime()}"/>
                                                    </xsl:if>
                                                    <xsl:if test="STATEIDNUM">
                                                        <ddm:StateIdNum VALUE="{STATEIDNUM}" SOURCE="I"
                                                                        MODIFIEDON="{datetime:dateTime()}"/>
                                                    </xsl:if>
                                                    <xsl:if test="STATETAXWHELD">
                                                        <ddm:StateTaxWheld
                                                                VALUE="{format-number(round(STATETAXWHELD),'#0')}"
                                                                SOURCE="I" MODIFIEDON="{datetime:dateTime()}"/>
                                                    </xsl:if>
                                                </xsl:if>
                                                <xsl:if test="position() = 2">
                                                    <xsl:if test="STATECODE">
                                                        <ddm:StateCode2 VALUE="{STATECODE}" SOURCE="I"
                                                                        MODIFIEDON="{datetime:dateTime()}"/>
                                                    </xsl:if>
                                                    <xsl:if test="STATEIDNUM">
                                                        <ddm:StateIdNum2 VALUE="{STATEIDNUM}" SOURCE="I"
                                                                         MODIFIEDON="{datetime:dateTime()}"/>
                                                    </xsl:if>
                                                    <xsl:if test="STATETAXWHELD">
                                                        <ddm:StateTaxWheld2
                                                                VALUE="{format-number(round(STATETAXWHELD),'#0')}"
                                                                SOURCE="I" MODIFIEDON="{datetime:dateTime()}"/>
                                                    </xsl:if>
                                                </xsl:if>
                                            </xsl:for-each>
                                        </xsl:when>
                                        <xsl:otherwise>
                                            <xsl:if test="STATECODE">
                                                <ddm:StateCode VALUE="{STATECODE}" SOURCE="I"
                                                               MODIFIEDON="{datetime:dateTime()}"/>
                                            </xsl:if>
                                            <xsl:if test="STATEIDNUM">
                                                <ddm:StateIdNum VALUE="{STATEIDNUM}" SOURCE="I"
                                                                MODIFIEDON="{datetime:dateTime()}"/>
                                            </xsl:if>
                                            <xsl:if test="STATETAXWHELD">
                                                <ddm:StateTaxWheld VALUE="{format-number(round(STATETAXWHELD),'#0')}"
                                                                   SOURCE="I" MODIFIEDON="{datetime:dateTime()}"/>
                                            </xsl:if>
                                        </xsl:otherwise>
                                    </xsl:choose>
                                    <!-- TY2014 changes to OFX addendum Nov 20th 2013 end -->

                                    <xsl:if test="PAYERADDR/PAYERNAME2">
                                        <ddm:PayerName2 VALUE="{PAYERADDR/PAYERNAME2}" SOURCE="I"
                                                        MODIFIEDON="{datetime:dateTime()}"/>
                                    </xsl:if>
                                    <ddm:PayerAddress1 VALUE="{PAYERADDR/ADDR1}" SOURCE="I"
                                                       MODIFIEDON="{datetime:dateTime()}"/>
                                    <xsl:if test="PAYERADDR/ADDR2">
                                        <ddm:PayerAddress2 VALUE="{PAYERADDR/ADDR2}" SOURCE="I"
                                                           MODIFIEDON="{datetime:dateTime()}"/>
                                    </xsl:if>
                                    <xsl:if test="PAYERADDR/ADDR3">
                                        <ddm:PayerAddress3 VALUE="{PAYERADDR/ADDR3}" SOURCE="I"
                                                           MODIFIEDON="{datetime:dateTime()}"/>
                                    </xsl:if>
                                    <ddm:PayerCity VALUE="{PAYERADDR/CITY}" SOURCE="I"
                                                   MODIFIEDON="{datetime:dateTime()}"/>
                                    <ddm:PayerState VALUE="{PAYERADDR/STATE}" SOURCE="I"
                                                    MODIFIEDON="{datetime:dateTime()}"/>
                                    <ddm:PayerZipCode VALUE="{PAYERADDR/POSTALCODE}" SOURCE="I"
                                                      MODIFIEDON="{datetime:dateTime()}"/>
                                    <xsl:if test="PAYERADDR/PHONE">
                                        <ddm:PayerPhone SOURCE="I" MODIFIEDON="{datetime:dateTime()}">
                                            <xsl:attribute name="VALUE">
                                                <xsl:call-template name="Strip-cntrycode">
                                                    <xsl:with-param name="phone" select="PAYERADDR/PHONE"/>
                                                </xsl:call-template>
                                            </xsl:attribute>
                                        </ddm:PayerPhone>
                                    </xsl:if>
                                    <ddm:PayerEIN SOURCE="I" MODIFIEDON="{datetime:dateTime()}">
                                        <xsl:attribute name="VALUE">
                                            <!-- <xsl:call-template name="Strip-dashes">
                                        <xsl:with-param name="ssn" select="PAYERID"/>
                                        </xsl:call-template> -->
                                            <xsl:call-template name="FixFedNumb">
                                                <xsl:with-param name="fednum" select="PAYERID"/>
                                            </xsl:call-template>
                                        </xsl:attribute>
                                    </ddm:PayerEIN>
                                    <xsl:if test="RECADDR">
                                        <ddm:RecipientName1 VALUE="{RECADDR/RECNAME1}" SOURCE="I"
                                                            MODIFIEDON="{datetime:dateTime()}"/>
                                        <!--<xsl:if test="RECADDR/RECNAME2">
                                    <ddm:RecipientName2 VALUE="{RECADDR/RECNAME2}" SOURCE="I" MODIFIEDON="{datetime:dateTime()}"/>
                                    </xsl:if>-->
                                        <ddm:RecipientAddr1 VALUE="{RECADDR/ADDR1}" SOURCE="I"
                                                            MODIFIEDON="{datetime:dateTime()}"/>
                                        <xsl:if test="RECADDR/ADDR2">
                                            <ddm:RecipientAddr2 VALUE="{RECADDR/ADDR2}" SOURCE="I"
                                                                MODIFIEDON="{datetime:dateTime()}"/>
                                        </xsl:if>
                                        <xsl:if test="RECADDR/ADDR3">
                                            <ddm:RecipientAddr3 VALUE="{RECADDR/ADDR3}" SOURCE="I"
                                                                MODIFIEDON="{datetime:dateTime()}"/>
                                        </xsl:if>
                                        <xsl:if test="RECADDR/CITY">
                                            <ddm:RecipientCity VALUE="{RECADDR/CITY}" SOURCE="I"
                                                               MODIFIEDON="{datetime:dateTime()}"/>
                                        </xsl:if>
                                        <xsl:if test="RECADDR/STATE">
                                            <ddm:RecipientState VALUE="{RECADDR/STATE}" SOURCE="I"
                                                                MODIFIEDON="{datetime:dateTime()}"/>
                                        </xsl:if>
                                        <xsl:if test="RECADDR/POSTALCODE">
                                            <ddm:RecipientZipCode VALUE="{RECADDR/POSTALCODE}" SOURCE="I"
                                                                  MODIFIEDON="{datetime:dateTime()}"/>
                                        </xsl:if>
                                    </xsl:if>
                                    <ddm:RecipientSSN SOURCE="I" MODIFIEDON="{datetime:dateTime()}">
                                        <xsl:attribute name="VALUE">
                                            <xsl:call-template name="Strip-dashes">
                                                <xsl:with-param name="ssn" select="RECID"/>
                                            </xsl:call-template>
                                        </xsl:attribute>
                                    </ddm:RecipientSSN>
                                    <xsl:if test="RECACCT">
                                        <ddm:AccountNumber VALUE="{RECACCT}" SOURCE="I"
                                                           MODIFIEDON="{datetime:dateTime()}"/>
                                    </xsl:if>
                                    <xsl:if test="VOID">
                                        <ddm:VoidCheckBox VALUE="{VOID}" SOURCE="I" MODIFIEDON="{datetime:dateTime()}"/>
                                    </xsl:if>
                                    <xsl:if test="CORRECTED">
                                        <ddm:Corrected VALUE="{CORRECTED}" SOURCE="I"
                                                       MODIFIEDON="{datetime:dateTime()}"/>
                                    </xsl:if>

                                    <xsl:if test="PAYERRTN">
                                        <ddm:PayerRTN VALUE="{PAYERRTN}" SOURCE="I" MODIFIEDON="{datetime:dateTime()}"/>
                                    </xsl:if>

                                    <xsl:if test="FORCNT">
                                        <ddm:Int_Country VALUE="{FORCNT}" SOURCE="I"
                                                         MODIFIEDON="{datetime:dateTime()}"/>
                                    </xsl:if>
                                    <xsl:if test="CUSIPNUM">
                                        <ddm:CUSIP VALUE="{CUSIPNUM}" SOURCE="I" MODIFIEDON="{datetime:dateTime()}"/>
                                    </xsl:if>
                                    <!-- TY2015 changes Dec 17 2015 start -->
                                    <xsl:if test="FATCA">
                                        <ddm:QFATCA VALUE="{FATCA}" SOURCE="I" MODIFIEDON="{datetime:dateTime()}">
                                            <xsl:attribute name="VALUE">
                                                <xsl:call-template name="BoolToBin">
                                                    <xsl:with-param name="value" select="FATCA"/>
                                                </xsl:call-template>
                                            </xsl:attribute>
                                        </ddm:QFATCA>
                                    </xsl:if>
                                    <!-- TY2015 changes Dec 17 2015 end -->
                                </ddm:FDB_L1_INTEREST>

                                <!-- DDM has this mapped but these, as per OFX specification, do not exist for 1099INT OFX response -->
                                <!--FDB_L1_Interest_StateInfo>
                            <StateWithheld/>
                            <State_Name/>
                            <State_TaxId/>
                            <State_Amount_Input/>
                            </FDB_L1_Interest_StateInfo-->
                            </ddm:FDB>
                        </ddm:FD>
                    </ddm:TAXDATA>
                </xsl:when>
                <xsl:when
                        test="( ( (INTINCOME) or (ERLWITHPEN) or (INTUSBNDTRS) or (FEDTAXWH) or (INVESTEXP) or (FORTAXPD) or (FORCNT) ) and ((TAXEXEMPTINT) or (SPECIFIEDPABINT)) )"> <!-- Have (1 thro 7) and (8 or 9) -->
                    <ddm:TAXDATA TAXYEAR="{TAXYEAR}">


                        <ddm:FD>
                            <ddm:FDB RECID="-1" OWNER="1" SOURCE="I" MODIFIEDON="{datetime:dateTime()}"
                                     ENGINERECID="-1">


                                <ddm:FDB_L1_INTEREST RECID="-1" OWNER="1" SOURCE="I" MODIFIEDON="{datetime:dateTime()}"
                                                     ENGINERECID="-1">
                                    <!--1099INT-->
                                    <ddm:Int_Source VALUE="{PAYERADDR/PAYERNAME1}" SOURCE="I"
                                                    MODIFIEDON="{datetime:dateTime()}"/>
                                    <xsl:if test="INTINCOME">
                                        <ddm:Int_Box1 VALUE="{format-number(round(INTINCOME),'#0')}" SOURCE="I"
                                                      MODIFIEDON="{datetime:dateTime()}"/>
                                    </xsl:if>
                                    <xsl:if test="ERLWITHPEN">
                                        <ddm:Int_Box2 VALUE="{ERLWITHPEN}" SOURCE="I"
                                                      MODIFIEDON="{datetime:dateTime()}"/>
                                    </xsl:if>
                                    <xsl:if test="INTUSBNDTRS">
                                        <ddm:Int_Box3 VALUE="{format-number(round(INTUSBNDTRS),'#0')}" SOURCE="I"
                                                      MODIFIEDON="{datetime:dateTime()}"/>
                                    </xsl:if>
                                    <xsl:if test="FEDTAXWH">
                                        <ddm:Int_Box4 VALUE="{format-number(round(FEDTAXWH),'#0')}" SOURCE="I"
                                                      MODIFIEDON="{datetime:dateTime()}"/>
                                    </xsl:if>
                                    <xsl:if test="INVESTEXP">
                                        <ddm:Int_Box5 VALUE="{format-number(round(INVESTEXP),'#0')}" SOURCE="I"
                                                      MODIFIEDON="{datetime:dateTime()}"/>
                                    </xsl:if>
                                    <xsl:if test="FORTAXPD">
                                        <ddm:Int_Box6 VALUE="{format-number(round(FORTAXPD),'#0')}" SOURCE="I"
                                                      MODIFIEDON="{datetime:dateTime()}"/>
                                    </xsl:if>
                                    <xsl:choose>
                                        <xsl:when test="INTUSBNDTRS">
                                            <ddm:INTEREST_TYPE VALUE="E" SOURCE="I" MODIFIEDON="{datetime:dateTime()}"/>
                                        </xsl:when>
                                        <xsl:when test="INTINCOME">
                                            <ddm:INTEREST_TYPE VALUE="I" SOURCE="I" MODIFIEDON="{datetime:dateTime()}"/>
                                        </xsl:when>
                                    </xsl:choose>
                                    <ddm:DISPLAY_NAME VALUE="{PAYERADDR/PAYERNAME1}" SOURCE="I"
                                                      MODIFIEDON="{datetime:dateTime()}"/>
                                    <xsl:if test="INTINCOME">
                                        <ddm:DISPLAY_AMOUNT VALUE="{format-number(round(INTINCOME),'#0')}" SOURCE="I"
                                                            MODIFIEDON="{datetime:dateTime()}"/>
                                    </xsl:if>

                                    <!-- TY2014 changes to OFX addendum Nov20 2013 start -->
                                    <xsl:choose>
                                        <xsl:when test="ADDLSTATETAXWHAGG">
                                            <xsl:variable name="sttaxwhagcnt" select="count(ADDLSTATETAXWHAGG)"/>
                                            <xsl:for-each select="ADDLSTATETAXWHAGG">
                                                <xsl:if test="position() = 1">
                                                    <xsl:if test="STATECODE">
                                                        <ddm:StateCode VALUE="{STATECODE}" SOURCE="I"
                                                                       MODIFIEDON="{datetime:dateTime()}"/>
                                                    </xsl:if>
                                                    <xsl:if test="STATEIDNUM">
                                                        <ddm:StateIdNum VALUE="{STATEIDNUM}" SOURCE="I"
                                                                        MODIFIEDON="{datetime:dateTime()}"/>
                                                    </xsl:if>
                                                    <xsl:if test="STATETAXWHELD">
                                                        <ddm:StateTaxWheld
                                                                VALUE="{format-number(round(STATETAXWHELD),'#0')}"
                                                                SOURCE="I" MODIFIEDON="{datetime:dateTime()}"/>
                                                    </xsl:if>
                                                </xsl:if>
                                                <xsl:if test="position() = 2">
                                                    <xsl:if test="STATECODE">
                                                        <ddm:StateCode2 VALUE="{STATECODE}" SOURCE="I"
                                                                        MODIFIEDON="{datetime:dateTime()}"/>
                                                    </xsl:if>
                                                    <xsl:if test="STATEIDNUM">
                                                        <ddm:StateIdNum2 VALUE="{STATEIDNUM}" SOURCE="I"
                                                                         MODIFIEDON="{datetime:dateTime()}"/>
                                                    </xsl:if>
                                                    <xsl:if test="STATETAXWHELD">
                                                        <ddm:StateTaxWheld2
                                                                VALUE="{format-number(round(STATETAXWHELD),'#0')}"
                                                                SOURCE="I" MODIFIEDON="{datetime:dateTime()}"/>
                                                    </xsl:if>
                                                </xsl:if>
                                            </xsl:for-each>
                                        </xsl:when>
                                        <xsl:otherwise>
                                            <xsl:if test="STATECODE">
                                                <ddm:StateCode VALUE="{STATECODE}" SOURCE="I"
                                                               MODIFIEDON="{datetime:dateTime()}"/>
                                            </xsl:if>
                                            <xsl:if test="STATEIDNUM">
                                                <ddm:StateIdNum VALUE="{STATEIDNUM}" SOURCE="I"
                                                                MODIFIEDON="{datetime:dateTime()}"/>
                                            </xsl:if>
                                            <xsl:if test="STATETAXWHELD">
                                                <ddm:StateTaxWheld VALUE="{format-number(round(STATETAXWHELD),'#0')}"
                                                                   SOURCE="I" MODIFIEDON="{datetime:dateTime()}"/>
                                            </xsl:if>
                                        </xsl:otherwise>
                                    </xsl:choose>
                                    <!-- TY2013 changes to OFX addendum Nov 20th 2013 end -->
                                    <!-- TY2014 changes Nov 26 2014 start -->
                                    <xsl:if test="MARKETDISCOUNT">
                                        <ddm:marketDiscount VALUE="{format-number(round(MARKETDISCOUNT),'#0')}"
                                                            SOURCE="I" MODIFIEDON="{datetime:dateTime()}"/>
                                    </xsl:if>
                                    <xsl:if test="BONDPREMIUM">
                                        <ddm:bondPremium VALUE="{format-number(round(BONDPREMIUM),'#0')}" SOURCE="I"
                                                         MODIFIEDON="{datetime:dateTime()}"/>
                                    </xsl:if>
                                    <!-- TY2014 changes Nov 26 2014 end -->
                                    <!-- TY2015 changes Dec 17 2015 start -->
                                    <xsl:if test="TEBONDPREMIUM">
                                        <ddm:EXEMPTBONDPREMIUM VALUE="{format-number(round(TEBONDPREMIUM),'#0')}"
                                                               SOURCE="I" MODIFIEDON="{datetime:dateTime()}"/>
                                    </xsl:if>
                                    <!-- TY2015 changes Dec 17 2015 end -->

                                    <xsl:if test="PAYERADDR/PAYERNAME2">
                                        <ddm:PayerName2 VALUE="{PAYERADDR/PAYERNAME2}" SOURCE="I"
                                                        MODIFIEDON="{datetime:dateTime()}"/>
                                    </xsl:if>
                                    <ddm:PayerAddress1 VALUE="{PAYERADDR/ADDR1}" SOURCE="I"
                                                       MODIFIEDON="{datetime:dateTime()}"/>
                                    <xsl:if test="PAYERADDR/ADDR2">
                                        <ddm:PayerAddress2 VALUE="{PAYERADDR/ADDR2}" SOURCE="I"
                                                           MODIFIEDON="{datetime:dateTime()}"/>
                                    </xsl:if>
                                    <xsl:if test="PAYERADDR/ADDR3">
                                        <ddm:PayerAddress3 VALUE="{PAYERADDR/ADDR3}" SOURCE="I"
                                                           MODIFIEDON="{datetime:dateTime()}"/>
                                    </xsl:if>
                                    <ddm:PayerCity VALUE="{PAYERADDR/CITY}" SOURCE="I"
                                                   MODIFIEDON="{datetime:dateTime()}"/>
                                    <ddm:PayerState VALUE="{PAYERADDR/STATE}" SOURCE="I"
                                                    MODIFIEDON="{datetime:dateTime()}"/>
                                    <ddm:PayerZipCode VALUE="{PAYERADDR/POSTALCODE}" SOURCE="I"
                                                      MODIFIEDON="{datetime:dateTime()}"/>
                                    <xsl:if test="PAYERADDR/PHONE">
                                        <ddm:PayerPhone SOURCE="I" MODIFIEDON="{datetime:dateTime()}">
                                            <xsl:attribute name="VALUE">
                                                <xsl:call-template name="Strip-cntrycode">
                                                    <xsl:with-param name="phone" select="PAYERADDR/PHONE"/>
                                                </xsl:call-template>
                                            </xsl:attribute>
                                        </ddm:PayerPhone>
                                    </xsl:if>
                                    <ddm:PayerEIN SOURCE="I" MODIFIEDON="{datetime:dateTime()}">
                                        <xsl:attribute name="VALUE">
                                            <!-- <xsl:call-template name="Strip-dashes">
                                        <xsl:with-param name="ssn" select="PAYERID"/>
                                        </xsl:call-template> -->
                                            <xsl:call-template name="FixFedNumb">
                                                <xsl:with-param name="fednum" select="PAYERID"/>
                                            </xsl:call-template>
                                        </xsl:attribute>
                                    </ddm:PayerEIN>
                                    <xsl:if test="RECADDR">
                                        <ddm:RecipientName1 VALUE="{RECADDR/RECNAME1}" SOURCE="I"
                                                            MODIFIEDON="{datetime:dateTime()}"/>
                                        <!--<xsl:if test="RECADDR/RECNAME2">
                                    <ddm:RecipientName2 VALUE="{RECADDR/RECNAME2}" SOURCE="I" MODIFIEDON="{datetime:dateTime()}"/>
                                    </xsl:if>-->
                                        <ddm:RecipientAddr1 VALUE="{RECADDR/ADDR1}" SOURCE="I"
                                                            MODIFIEDON="{datetime:dateTime()}"/>
                                        <xsl:if test="RECADDR/ADDR2">
                                            <ddm:RecipientAddr2 VALUE="{RECADDR/ADDR2}" SOURCE="I"
                                                                MODIFIEDON="{datetime:dateTime()}"/>
                                        </xsl:if>
                                        <xsl:if test="RECADDR/ADDR3">
                                            <ddm:RecipientAddr3 VALUE="{RECADDR/ADDR3}" SOURCE="I"
                                                                MODIFIEDON="{datetime:dateTime()}"/>
                                        </xsl:if>
                                        <xsl:if test="RECADDR/CITY">
                                            <ddm:RecipientCity VALUE="{RECADDR/CITY}" SOURCE="I"
                                                               MODIFIEDON="{datetime:dateTime()}"/>
                                        </xsl:if>
                                        <xsl:if test="RECADDR/STATE">
                                            <ddm:RecipientState VALUE="{RECADDR/STATE}" SOURCE="I"
                                                                MODIFIEDON="{datetime:dateTime()}"/>
                                        </xsl:if>
                                        <xsl:if test="RECADDR/POSTALCODE">
                                            <ddm:RecipientZipCode VALUE="{RECADDR/POSTALCODE}" SOURCE="I"
                                                                  MODIFIEDON="{datetime:dateTime()}"/>
                                        </xsl:if>
                                    </xsl:if>
                                    <ddm:RecipientSSN SOURCE="I" MODIFIEDON="{datetime:dateTime()}">
                                        <xsl:attribute name="VALUE">
                                            <xsl:call-template name="Strip-dashes">
                                                <xsl:with-param name="ssn" select="RECID"/>
                                            </xsl:call-template>
                                        </xsl:attribute>
                                    </ddm:RecipientSSN>
                                    <xsl:if test="RECACCT">
                                        <ddm:AccountNumber VALUE="{RECACCT}" SOURCE="I"
                                                           MODIFIEDON="{datetime:dateTime()}"/>
                                    </xsl:if>
                                    <xsl:if test="VOID">
                                        <ddm:VoidCheckBox VALUE="{VOID}" SOURCE="I" MODIFIEDON="{datetime:dateTime()}"/>
                                    </xsl:if>
                                    <xsl:if test="CORRECTED">
                                        <ddm:Corrected VALUE="{CORRECTED}" SOURCE="I"
                                                       MODIFIEDON="{datetime:dateTime()}"/>
                                    </xsl:if>
                                    <xsl:if test="PAYERRTN">
                                        <ddm:PayerRTN VALUE="{PAYERRTN}" SOURCE="I" MODIFIEDON="{datetime:dateTime()}"/>
                                    </xsl:if>
                                    <xsl:if test="FORCNT">
                                        <ddm:Int_Country VALUE="{FORCNT}" SOURCE="I"
                                                         MODIFIEDON="{datetime:dateTime()}"/>
                                    </xsl:if>
                                    <xsl:if test="CUSIPNUM">
                                        <ddm:CUSIP VALUE="{CUSIPNUM}" SOURCE="I" MODIFIEDON="{datetime:dateTime()}"/>
                                    </xsl:if>
                                    <!-- TY2015 changes Dec 17 2015 start -->
                                    <xsl:if test="FATCA">
                                        <ddm:QFATCA VALUE="{FATCA}" SOURCE="I" MODIFIEDON="{datetime:dateTime()}">
                                            <xsl:attribute name="VALUE">
                                                <xsl:call-template name="BoolToBin">
                                                    <xsl:with-param name="value" select="FATCA"/>
                                                </xsl:call-template>
                                            </xsl:attribute>
                                        </ddm:QFATCA>
                                    </xsl:if>
                                    <!-- TY2015 changes Dec 17 2015 end -->
                                </ddm:FDB_L1_INTEREST>

                                <!-- DDM has this mapped but these, as per OFX specification, do not exist for 1099INT OFX response -->
                                <!--FDB_L1_Interest_StateInfo>
                            <StateWithheld/>
                            <State_Name/>
                            <State_TaxId/>
                            <State_Amount_Input/>
                            </FDB_L1_Interest_StateInfo-->
                            </ddm:FDB>
                        </ddm:FD>
                    </ddm:TAXDATA>
                    <ddm:TAXDATA TAXYEAR="{TAXYEAR}">


                        <ddm:FD>
                            <ddm:FDB RECID="-1" OWNER="1" SOURCE="I" MODIFIEDON="{datetime:dateTime()}"
                                     ENGINERECID="-1">


                                <ddm:FDB_L1_INTEREST RECID="-1" OWNER="1" SOURCE="I" MODIFIEDON="{datetime:dateTime()}"
                                                     ENGINERECID="-1">
                                    <!--1099INT-->
                                    <ddm:Int_Source VALUE="{PAYERADDR/PAYERNAME1}" SOURCE="I"
                                                    MODIFIEDON="{datetime:dateTime()}"/>

                                    <xsl:choose>
                                        <xsl:when test="INTUSBNDTRS">
                                            <ddm:INTEREST_TYPE VALUE="E" SOURCE="I" MODIFIEDON="{datetime:dateTime()}"/>
                                        </xsl:when>
                                        <xsl:when test="INTINCOME">
                                            <ddm:INTEREST_TYPE VALUE="I" SOURCE="I" MODIFIEDON="{datetime:dateTime()}"/>
                                        </xsl:when>
                                    </xsl:choose>
                                    <xsl:if test="TAXEXEMPTINT">
                                        <ddm:INT_EXEMPT VALUE="{format-number(round(TAXEXEMPTINT),'#0')}" SOURCE="I"
                                                        MODIFIEDON="{datetime:dateTime()}"/>
                                    </xsl:if>
                                    <ddm:DISPLAY_NAME VALUE="{PAYERADDR/PAYERNAME1}" SOURCE="I"
                                                      MODIFIEDON="{datetime:dateTime()}"/>
                                    <xsl:if test="INTINCOME">
                                        <ddm:DISPLAY_AMOUNT VALUE="{format-number(round(INTINCOME),'#0')}" SOURCE="I"
                                                            MODIFIEDON="{datetime:dateTime()}"/>
                                    </xsl:if>
                                    <xsl:if test="SPECIFIEDPABINT">
                                        <ddm:INT_AMT_AMOUNT VALUE="{format-number(round(SPECIFIEDPABINT),'#0')}"
                                                            SOURCE="I" MODIFIEDON="{datetime:dateTime()}"/>
                                    </xsl:if>
                                    <!-- TY2014 changes Nov 26 2014 start -->
                                    <xsl:if test="MARKETDISCOUNT">
                                        <ddm:marketDiscount VALUE="{format-number(round(MARKETDISCOUNT),'#0')}"
                                                            SOURCE="I" MODIFIEDON="{datetime:dateTime()}"/>
                                    </xsl:if>
                                    <xsl:if test="BONDPREMIUM">
                                        <ddm:bondPremium VALUE="{format-number(round(BONDPREMIUM),'#0')}" SOURCE="I"
                                                         MODIFIEDON="{datetime:dateTime()}"/>
                                    </xsl:if>
                                    <!-- TY2014 changes Nov 26 2014 end -->
                                    <!-- TY2015 changes Dec 17 2015 start -->
                                    <xsl:if test="TEBONDPREMIUM">
                                        <ddm:EXEMPTBONDPREMIUM VALUE="{format-number(round(TEBONDPREMIUM),'#0')}"
                                                               SOURCE="I" MODIFIEDON="{datetime:dateTime()}"/>
                                    </xsl:if>
                                    <!-- TY2015 changes Dec 17 2015 end -->

                                    <xsl:if test="PAYERADDR/PAYERNAME2">
                                        <ddm:PayerName2 VALUE="{PAYERADDR/PAYERNAME2}" SOURCE="I"
                                                        MODIFIEDON="{datetime:dateTime()}"/>
                                    </xsl:if>
                                    <ddm:PayerAddress1 VALUE="{PAYERADDR/ADDR1}" SOURCE="I"
                                                       MODIFIEDON="{datetime:dateTime()}"/>
                                    <xsl:if test="PAYERADDR/ADDR2">
                                        <ddm:PayerAddress2 VALUE="{PAYERADDR/ADDR2}" SOURCE="I"
                                                           MODIFIEDON="{datetime:dateTime()}"/>
                                    </xsl:if>
                                    <xsl:if test="PAYERADDR/ADDR3">
                                        <ddm:PayerAddress3 VALUE="{PAYERADDR/ADDR3}" SOURCE="I"
                                                           MODIFIEDON="{datetime:dateTime()}"/>
                                    </xsl:if>
                                    <ddm:PayerCity VALUE="{PAYERADDR/CITY}" SOURCE="I"
                                                   MODIFIEDON="{datetime:dateTime()}"/>
                                    <ddm:PayerState VALUE="{PAYERADDR/STATE}" SOURCE="I"
                                                    MODIFIEDON="{datetime:dateTime()}"/>
                                    <ddm:PayerZipCode VALUE="{PAYERADDR/POSTALCODE}" SOURCE="I"
                                                      MODIFIEDON="{datetime:dateTime()}"/>
                                    <xsl:if test="PAYERADDR/PHONE">
                                        <ddm:PayerPhone SOURCE="I" MODIFIEDON="{datetime:dateTime()}">
                                            <xsl:attribute name="VALUE">
                                                <xsl:call-template name="Strip-cntrycode">
                                                    <xsl:with-param name="phone" select="PAYERADDR/PHONE"/>
                                                </xsl:call-template>
                                            </xsl:attribute>
                                        </ddm:PayerPhone>
                                    </xsl:if>
                                    <ddm:PayerEIN SOURCE="I" MODIFIEDON="{datetime:dateTime()}">
                                        <xsl:attribute name="VALUE">
                                            <!-- <xsl:call-template name="Strip-dashes">
                                        <xsl:with-param name="ssn" select="PAYERID"/>
                                        </xsl:call-template> -->
                                            <xsl:call-template name="FixFedNumb">
                                                <xsl:with-param name="fednum" select="PAYERID"/>
                                            </xsl:call-template>
                                        </xsl:attribute>
                                    </ddm:PayerEIN>
                                    <xsl:if test="RECADDR">
                                        <ddm:RecipientName1 VALUE="{RECADDR/RECNAME1}" SOURCE="I"
                                                            MODIFIEDON="{datetime:dateTime()}"/>
                                        <!--<xsl:if test="RECADDR/RECNAME2">
                                    <ddm:RecipientName2 VALUE="{RECADDR/RECNAME2}" SOURCE="I" MODIFIEDON="{datetime:dateTime()}"/>
                                    </xsl:if>-->
                                        <ddm:RecipientAddr1 VALUE="{RECADDR/ADDR1}" SOURCE="I"
                                                            MODIFIEDON="{datetime:dateTime()}"/>
                                        <xsl:if test="RECADDR/ADDR2">
                                            <ddm:RecipientAddr2 VALUE="{RECADDR/ADDR2}" SOURCE="I"
                                                                MODIFIEDON="{datetime:dateTime()}"/>
                                        </xsl:if>
                                        <xsl:if test="RECADDR/ADDR3">
                                            <ddm:RecipientAddr3 VALUE="{RECADDR/ADDR3}" SOURCE="I"
                                                                MODIFIEDON="{datetime:dateTime()}"/>
                                        </xsl:if>
                                        <xsl:if test="RECADDR/CITY">
                                            <ddm:RecipientCity VALUE="{RECADDR/CITY}" SOURCE="I"
                                                               MODIFIEDON="{datetime:dateTime()}"/>
                                        </xsl:if>
                                        <xsl:if test="RECADDR/STATE">
                                            <ddm:RecipientState VALUE="{RECADDR/STATE}" SOURCE="I"
                                                                MODIFIEDON="{datetime:dateTime()}"/>
                                        </xsl:if>
                                        <xsl:if test="RECADDR/POSTALCODE">
                                            <ddm:RecipientZipCode VALUE="{RECADDR/POSTALCODE}" SOURCE="I"
                                                                  MODIFIEDON="{datetime:dateTime()}"/>
                                        </xsl:if>
                                    </xsl:if>
                                    <ddm:RecipientSSN SOURCE="I" MODIFIEDON="{datetime:dateTime()}">
                                        <xsl:attribute name="VALUE">
                                            <xsl:call-template name="Strip-dashes">
                                                <xsl:with-param name="ssn" select="RECID"/>
                                            </xsl:call-template>
                                        </xsl:attribute>
                                    </ddm:RecipientSSN>
                                    <xsl:if test="RECACCT">
                                        <ddm:AccountNumber VALUE="{RECACCT}" SOURCE="I"
                                                           MODIFIEDON="{datetime:dateTime()}"/>
                                    </xsl:if>
                                    <xsl:if test="VOID">
                                        <ddm:VoidCheckBox VALUE="{VOID}" SOURCE="I" MODIFIEDON="{datetime:dateTime()}"/>
                                    </xsl:if>
                                    <xsl:if test="CORRECTED">
                                        <ddm:Corrected VALUE="{CORRECTED}" SOURCE="I"
                                                       MODIFIEDON="{datetime:dateTime()}"/>
                                    </xsl:if>

                                    <xsl:if test="PAYERRTN">
                                        <ddm:PayerRTN VALUE="{PAYERRTN}" SOURCE="I" MODIFIEDON="{datetime:dateTime()}"/>
                                    </xsl:if>

                                    <!-- commented by aparna <xsl:if test="FORCNT">
                                <ddm:Int_Country VALUE="{FORCNT}" SOURCE="I" MODIFIEDON="{datetime:dateTime()}"/>
                                </xsl:if>-->

                                    <xsl:if test="CUSIPNUM">
                                        <ddm:CUSIP VALUE="{CUSIPNUM}" SOURCE="I" MODIFIEDON="{datetime:dateTime()}"/>
                                    </xsl:if>
                                    <!-- TY2015 changes Dec 17 2015 start -->
                                    <xsl:if test="FATCA">
                                        <ddm:QFATCA VALUE="{FATCA}" SOURCE="I" MODIFIEDON="{datetime:dateTime()}">
                                            <xsl:attribute name="VALUE">
                                                <xsl:call-template name="BoolToBin">
                                                    <xsl:with-param name="value" select="FATCA"/>
                                                </xsl:call-template>
                                            </xsl:attribute>
                                        </ddm:QFATCA>
                                    </xsl:if>
                                    <!-- TY2015 changes Dec 17 2015 end -->
                                </ddm:FDB_L1_INTEREST>

                                <!-- DDM has this mapped but these, as per OFX specification, do not exist for 1099INT OFX response -->
                                <!--FDB_L1_Interest_StateInfo>
                            <StateWithheld/>
                            <State_Name/>
                            <State_TaxId/>
                            <State_Amount_Input/>
                            </FDB_L1_Interest_StateInfo-->
                            </ddm:FDB>
                        </ddm:FD>
                    </ddm:TAXDATA>
                </xsl:when>
                <xsl:otherwise> <!-- Only 8 or 9 -->

                    <ddm:TAXDATA TAXYEAR="{TAXYEAR}">


                        <ddm:FD>
                            <ddm:FDB RECID="-1" OWNER="1" SOURCE="I" MODIFIEDON="{datetime:dateTime()}"
                                     ENGINERECID="-1">


                                <ddm:FDB_L1_INTEREST RECID="-1" OWNER="1" SOURCE="I" MODIFIEDON="{datetime:dateTime()}"
                                                     ENGINERECID="-1">
                                    <!--1099INT-->
                                    <ddm:Int_Source VALUE="{PAYERADDR/PAYERNAME1}" SOURCE="I"
                                                    MODIFIEDON="{datetime:dateTime()}"/>
                                    <xsl:if test="INTINCOME">
                                        <ddm:Int_Box1 VALUE="{format-number(round(INTINCOME),'#0')}" SOURCE="I"
                                                      MODIFIEDON="{datetime:dateTime()}"/>
                                    </xsl:if>
                                    <xsl:if test="ERLWITHPEN">
                                        <ddm:Int_Box2 VALUE="{ERLWITHPEN}" SOURCE="I"
                                                      MODIFIEDON="{datetime:dateTime()}"/>
                                    </xsl:if>
                                    <xsl:if test="INTUSBNDTRS">
                                        <ddm:Int_Box3 VALUE="{format-number(round(INTUSBNDTRS),'#0')}" SOURCE="I"
                                                      MODIFIEDON="{datetime:dateTime()}"/>
                                    </xsl:if>
                                    <xsl:if test="FEDTAXWH">
                                        <ddm:Int_Box4 VALUE="{format-number(round(FEDTAXWH),'#0')}" SOURCE="I"
                                                      MODIFIEDON="{datetime:dateTime()}"/>
                                    </xsl:if>
                                    <xsl:if test="INVESTEXP">
                                        <ddm:Int_Box5 VALUE="{format-number(round(INVESTEXP),'#0')}" SOURCE="I"
                                                      MODIFIEDON="{datetime:dateTime()}"/>
                                    </xsl:if>
                                    <xsl:if test="FORTAXPD">
                                        <ddm:Int_Box6 VALUE="{format-number(round(FORTAXPD),'#0')}" SOURCE="I"
                                                      MODIFIEDON="{datetime:dateTime()}"/>
                                    </xsl:if>
                                    <xsl:choose>
                                        <xsl:when test="INTUSBNDTRS">
                                            <ddm:INTEREST_TYPE VALUE="E" SOURCE="I" MODIFIEDON="{datetime:dateTime()}"/>
                                        </xsl:when>
                                        <xsl:when test="INTINCOME">
                                            <ddm:INTEREST_TYPE VALUE="I" SOURCE="I" MODIFIEDON="{datetime:dateTime()}"/>
                                        </xsl:when>
                                    </xsl:choose>
                                    <xsl:if test="TAXEXEMPTINT">
                                        <ddm:INT_EXEMPT VALUE="{format-number(round(TAXEXEMPTINT),'#0')}" SOURCE="I"
                                                        MODIFIEDON="{datetime:dateTime()}"/>
                                    </xsl:if>
                                    <ddm:DISPLAY_NAME VALUE="{PAYERADDR/PAYERNAME1}" SOURCE="I"
                                                      MODIFIEDON="{datetime:dateTime()}"/>
                                    <xsl:if test="INTINCOME">
                                        <ddm:DISPLAY_AMOUNT VALUE="{format-number(round(INTINCOME),'#0')}" SOURCE="I"
                                                            MODIFIEDON="{datetime:dateTime()}"/>
                                    </xsl:if>
                                    <xsl:if test="SPECIFIEDPABINT">
                                        <ddm:INT_AMT_AMOUNT VALUE="{format-number(round(SPECIFIEDPABINT),'#0')}"
                                                            SOURCE="I" MODIFIEDON="{datetime:dateTime()}"/>
                                    </xsl:if>
                                    <!-- TY2014 changes Nov 26 2014 start -->
                                    <xsl:if test="MARKETDISCOUNT">
                                        <ddm:marketDiscount VALUE="{format-number(round(MARKETDISCOUNT),'#0')}"
                                                            SOURCE="I" MODIFIEDON="{datetime:dateTime()}"/>
                                    </xsl:if>
                                    <xsl:if test="BONDPREMIUM">
                                        <ddm:bondPremium VALUE="{format-number(round(BONDPREMIUM),'#0')}" SOURCE="I"
                                                         MODIFIEDON="{datetime:dateTime()}"/>
                                    </xsl:if>
                                    <!-- TY2014 changes Nov 26 2014 end -->
                                    <!-- TY2015 changes Dec 17 2015 start -->
                                    <xsl:if test="TEBONDPREMIUM">
                                        <ddm:EXEMPTBONDPREMIUM VALUE="{format-number(round(TEBONDPREMIUM),'#0')}"
                                                               SOURCE="I" MODIFIEDON="{datetime:dateTime()}"/>
                                    </xsl:if>
                                    <!-- TY2015 changes Dec 17 2015 end -->

                                    <!-- TY2013 changes to OFX addendum Nov20 2013 start -->
                                    <xsl:choose>
                                        <xsl:when test="ADDLSTATETAXWHAGG">
                                            <xsl:variable name="sttaxwhagcnt" select="count(ADDLSTATETAXWHAGG)"/>
                                            <xsl:for-each select="ADDLSTATETAXWHAGG">
                                                <xsl:if test="position() = 1">
                                                    <xsl:if test="STATECODE">
                                                        <ddm:StateCode VALUE="{STATECODE}" SOURCE="I"
                                                                       MODIFIEDON="{datetime:dateTime()}"/>
                                                    </xsl:if>
                                                    <xsl:if test="STATEIDNUM">
                                                        <ddm:StateIdNum VALUE="{STATEIDNUM}" SOURCE="I"
                                                                        MODIFIEDON="{datetime:dateTime()}"/>
                                                    </xsl:if>
                                                    <xsl:if test="STATETAXWHELD">
                                                        <ddm:StateTaxWheld
                                                                VALUE="{format-number(round(STATETAXWHELD),'#0')}"
                                                                SOURCE="I" MODIFIEDON="{datetime:dateTime()}"/>
                                                    </xsl:if>
                                                </xsl:if>
                                                <xsl:if test="position() = 2">
                                                    <xsl:if test="STATECODE">
                                                        <ddm:StateCode2 VALUE="{STATECODE}" SOURCE="I"
                                                                        MODIFIEDON="{datetime:dateTime()}"/>
                                                    </xsl:if>
                                                    <xsl:if test="STATEIDNUM">
                                                        <ddm:StateIdNum2 VALUE="{STATEIDNUM}" SOURCE="I"
                                                                         MODIFIEDON="{datetime:dateTime()}"/>
                                                    </xsl:if>
                                                    <xsl:if test="STATETAXWHELD">
                                                        <ddm:StateTaxWheld2
                                                                VALUE="{format-number(round(STATETAXWHELD),'#0')}"
                                                                SOURCE="I" MODIFIEDON="{datetime:dateTime()}"/>
                                                    </xsl:if>
                                                </xsl:if>
                                            </xsl:for-each>
                                        </xsl:when>
                                        <xsl:otherwise>
                                            <xsl:if test="STATECODE">
                                                <ddm:StateCode VALUE="{STATECODE}" SOURCE="I"
                                                               MODIFIEDON="{datetime:dateTime()}"/>
                                            </xsl:if>
                                            <xsl:if test="STATEIDNUM">
                                                <ddm:StateIdNum VALUE="{STATEIDNUM}" SOURCE="I"
                                                                MODIFIEDON="{datetime:dateTime()}"/>
                                            </xsl:if>
                                            <xsl:if test="STATETAXWHELD">
                                                <ddm:StateTaxWheld VALUE="{format-number(round(STATETAXWHELD),'#0')}"
                                                                   SOURCE="I" MODIFIEDON="{datetime:dateTime()}"/>
                                            </xsl:if>
                                        </xsl:otherwise>
                                    </xsl:choose>
                                    <!-- TY2014 changes to OFX addendum Nov 20th 2013 end -->


                                    <xsl:if test="PAYERADDR/PAYERNAME2">
                                        <ddm:PayerName2 VALUE="{PAYERADDR/PAYERNAME2}" SOURCE="I"
                                                        MODIFIEDON="{datetime:dateTime()}"/>
                                    </xsl:if>
                                    <ddm:PayerAddress1 VALUE="{PAYERADDR/ADDR1}" SOURCE="I"
                                                       MODIFIEDON="{datetime:dateTime()}"/>
                                    <xsl:if test="PAYERADDR/ADDR2">
                                        <ddm:PayerAddress2 VALUE="{PAYERADDR/ADDR2}" SOURCE="I"
                                                           MODIFIEDON="{datetime:dateTime()}"/>
                                    </xsl:if>
                                    <xsl:if test="PAYERADDR/ADDR3">
                                        <ddm:PayerAddress3 VALUE="{PAYERADDR/ADDR3}" SOURCE="I"
                                                           MODIFIEDON="{datetime:dateTime()}"/>
                                    </xsl:if>
                                    <ddm:PayerCity VALUE="{PAYERADDR/CITY}" SOURCE="I"
                                                   MODIFIEDON="{datetime:dateTime()}"/>
                                    <ddm:PayerState VALUE="{PAYERADDR/STATE}" SOURCE="I"
                                                    MODIFIEDON="{datetime:dateTime()}"/>
                                    <ddm:PayerZipCode VALUE="{PAYERADDR/POSTALCODE}" SOURCE="I"
                                                      MODIFIEDON="{datetime:dateTime()}"/>
                                    <xsl:if test="PAYERADDR/PHONE">
                                        <ddm:PayerPhone SOURCE="I" MODIFIEDON="{datetime:dateTime()}">
                                            <xsl:attribute name="VALUE">
                                                <xsl:call-template name="Strip-cntrycode">
                                                    <xsl:with-param name="phone" select="PAYERADDR/PHONE"/>
                                                </xsl:call-template>
                                            </xsl:attribute>
                                        </ddm:PayerPhone>
                                    </xsl:if>
                                    <ddm:PayerEIN SOURCE="I" MODIFIEDON="{datetime:dateTime()}">
                                        <xsl:attribute name="VALUE">
                                            <!-- <xsl:call-template name="Strip-dashes">
                                        <xsl:with-param name="ssn" select="PAYERID"/>
                                        </xsl:call-template> -->
                                            <xsl:call-template name="FixFedNumb">
                                                <xsl:with-param name="fednum" select="PAYERID"/>
                                            </xsl:call-template>
                                        </xsl:attribute>
                                    </ddm:PayerEIN>
                                    <xsl:if test="RECADDR">
                                        <ddm:RecipientName1 VALUE="{RECADDR/RECNAME1}" SOURCE="I"
                                                            MODIFIEDON="{datetime:dateTime()}"/>
                                        <!--<xsl:if test="RECADDR/RECNAME2">
                                    <ddm:RecipientName2 VALUE="{RECADDR/RECNAME2}" SOURCE="I" MODIFIEDON="{datetime:dateTime()}"/>
                                    </xsl:if>-->
                                        <ddm:RecipientAddr1 VALUE="{RECADDR/ADDR1}" SOURCE="I"
                                                            MODIFIEDON="{datetime:dateTime()}"/>
                                        <xsl:if test="RECADDR/ADDR2">
                                            <ddm:RecipientAddr2 VALUE="{RECADDR/ADDR2}" SOURCE="I"
                                                                MODIFIEDON="{datetime:dateTime()}"/>
                                        </xsl:if>
                                        <xsl:if test="RECADDR/ADDR3">
                                            <ddm:RecipientAddr3 VALUE="{RECADDR/ADDR3}" SOURCE="I"
                                                                MODIFIEDON="{datetime:dateTime()}"/>
                                        </xsl:if>
                                        <xsl:if test="RECADDR/CITY">
                                            <ddm:RecipientCity VALUE="{RECADDR/CITY}" SOURCE="I"
                                                               MODIFIEDON="{datetime:dateTime()}"/>
                                        </xsl:if>
                                        <xsl:if test="RECADDR/STATE">
                                            <ddm:RecipientState VALUE="{RECADDR/STATE}" SOURCE="I"
                                                                MODIFIEDON="{datetime:dateTime()}"/>
                                        </xsl:if>
                                        <xsl:if test="RECADDR/POSTALCODE">
                                            <ddm:RecipientZipCode VALUE="{RECADDR/POSTALCODE}" SOURCE="I"
                                                                  MODIFIEDON="{datetime:dateTime()}"/>
                                        </xsl:if>
                                    </xsl:if>
                                    <ddm:RecipientSSN SOURCE="I" MODIFIEDON="{datetime:dateTime()}">
                                        <xsl:attribute name="VALUE">
                                            <xsl:call-template name="Strip-dashes">
                                                <xsl:with-param name="ssn" select="RECID"/>
                                            </xsl:call-template>
                                        </xsl:attribute>
                                    </ddm:RecipientSSN>
                                    <xsl:if test="RECACCT">
                                        <ddm:AccountNumber VALUE="{RECACCT}" SOURCE="I"
                                                           MODIFIEDON="{datetime:dateTime()}"/>
                                    </xsl:if>
                                    <xsl:if test="VOID">
                                        <ddm:VoidCheckBox VALUE="{VOID}" SOURCE="I" MODIFIEDON="{datetime:dateTime()}"/>
                                    </xsl:if>
                                    <xsl:if test="CORRECTED">
                                        <ddm:Corrected VALUE="{CORRECTED}" SOURCE="I"
                                                       MODIFIEDON="{datetime:dateTime()}"/>
                                    </xsl:if>

                                    <xsl:if test="PAYERRTN">
                                        <ddm:PayerRTN VALUE="{PAYERRTN}" SOURCE="I" MODIFIEDON="{datetime:dateTime()}"/>
                                    </xsl:if>

                                    <xsl:if test="FORCNT">
                                        <ddm:Int_Country VALUE="{FORCNT}" SOURCE="I"
                                                         MODIFIEDON="{datetime:dateTime()}"/>
                                    </xsl:if>
                                    <xsl:if test="CUSIPNUM">
                                        <ddm:CUSIP VALUE="{CUSIPNUM}" SOURCE="I" MODIFIEDON="{datetime:dateTime()}"/>
                                    </xsl:if>
                                    <!-- TY2015 changes Dec 17 2015 start -->
                                    <xsl:if test="FATCA">
                                        <ddm:QFATCA VALUE="{FATCA}" SOURCE="I" MODIFIEDON="{datetime:dateTime()}">
                                            <xsl:attribute name="VALUE">
                                                <xsl:call-template name="BoolToBin">
                                                    <xsl:with-param name="value" select="FATCA"/>
                                                </xsl:call-template>
                                            </xsl:attribute>
                                        </ddm:QFATCA>
                                    </xsl:if>
                                    <!-- TY2015 changes Dec 17 2015 end -->
                                </ddm:FDB_L1_INTEREST>

                                <!-- DDM has this mapped but these, as per OFX specification, do not exist for 1099INT OFX response -->
                                <!--FDB_L1_Interest_StateInfo>
                            <StateWithheld/>
                            <State_Name/>
                            <State_TaxId/>
                            <State_Amount_Input/>
                            </FDB_L1_Interest_StateInfo-->
                            </ddm:FDB>
                        </ddm:FD>
                    </ddm:TAXDATA>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:for-each>
    </xsl:template>
    <xsl:template match="TAX1099OID_V100">
        <xsl:for-each select=".">
            <ddm:TAXDATA TAXYEAR="{TAXYEAR}">
                <ddm:FD>
                    <ddm:FDB RECID="-1" OWNER="1" SOURCE="I" MODIFIEDON="{datetime:dateTime()}" ENGINERECID="-1">
                        <ddm:FDB_L1_INTEREST RECID="-1" OWNER="1" SOURCE="I" MODIFIEDON="{datetime:dateTime()}"
                                             ENGINERECID="-1">
                            <!--1099OID-->
                            <ddm:OID_Source VALUE="{PAYERADDR/PAYERNAME1}" SOURCE="I"
                                            MODIFIEDON="{datetime:dateTime()}"/>
                            <xsl:if test="ORIGISDISC">
                                <ddm:OID_Box1 VALUE="{format-number(round(ORIGISDISC),'#0')}" SOURCE="I"
                                              MODIFIEDON="{datetime:dateTime()}"/>
                            </xsl:if>
                            <xsl:if test="OTHERPERINT">
                                <ddm:OID_Box2 VALUE="{format-number(round(OTHERPERINT),'#0')}" SOURCE="I"
                                              MODIFIEDON="{datetime:dateTime()}"/>
                            </xsl:if>
                            <xsl:if test="ERLWITHPEN">
                                <ddm:OID_Box3 VALUE="{format-number(round(ERLWITHPEN),'#0')}" SOURCE="I"
                                              MODIFIEDON="{datetime:dateTime()}"/>
                            </xsl:if>
                            <xsl:if test="FEDTAXWH">
                                <ddm:OID_Box4 VALUE="{format-number(round(FEDTAXWH),'#0')}" SOURCE="I"
                                              MODIFIEDON="{datetime:dateTime()}"/>
                            </xsl:if>
                            <xsl:if test="OIDONUSTRES">
                                <ddm:OID_Box6 VALUE="{format-number(round(OIDONUSTRES),'#0')}" SOURCE="I"
                                              MODIFIEDON="{datetime:dateTime()}"/>
                            </xsl:if>
                            <xsl:if test="INVESTEXP">
                                <ddm:OID_Box7 VALUE="{format-number(round(INVESTEXP),'#0')}" SOURCE="I"
                                              MODIFIEDON="{datetime:dateTime()}"/>
                            </xsl:if>


                            <!-- TY2014 changes Nov 26 2014 start -->
                            <xsl:if test="MARKETDISCOUNT">
                                <ddm:oidMarketDiscount VALUE="{format-number(round(MARKETDISCOUNT),'#0')}" SOURCE="I"
                                                       MODIFIEDON="{datetime:dateTime()}"/>
                            </xsl:if>
                            <xsl:if test="ACQPREMIUM">
                                <ddm:oidAcquisitionPremium VALUE="{format-number(round(ACQPREMIUM),'#0')}" SOURCE="I"
                                                           MODIFIEDON="{datetime:dateTime()}"/>
                            </xsl:if>
                            <!-- TY2014 changes Nov 26 2014 end -->

                            <!-- TY2013 changes to OFX addendum Nov20 2013 start. Removed in TY2014, Nov26th 2014
                        <xsl:if test="FORCNT">
                        <ddm:Int_Country VALUE="{FORCNT}" SOURCE="I" MODIFIEDON="{datetime:dateTime()}"/>
                        </xsl:if>
                        <xsl:if test="FORTAXPD">
                        <ddm:Int_Box6 VALUE="{format-number(round(FORTAXPD),'#0')}" SOURCE="I" MODIFIEDON="{datetime:dateTime()}"/>
                        </xsl:if>
                        -->
                            <xsl:choose>
                                <xsl:when test="ADDLSTATETAXWHAGG">
                                    <xsl:for-each select="ADDLSTATETAXWHAGG">
                                        <xsl:if test="position() = 1">
                                            <xsl:if test="STATECODE">
                                                <ddm:OIDStateCode VALUE="{STATECODE}" SOURCE="I"
                                                                  MODIFIEDON="{datetime:dateTime()}"/>
                                            </xsl:if>
                                            <xsl:if test="STATEIDNUM">
                                                <ddm:OIDStateIdNum VALUE="{STATEIDNUM}" SOURCE="I"
                                                                   MODIFIEDON="{datetime:dateTime()}"/>
                                            </xsl:if>
                                            <xsl:if test="STATETAXWHELD">
                                                <ddm:OIDStateTaxWheld VALUE="{format-number(round(STATETAXWHELD),'#0')}"
                                                                      SOURCE="I" MODIFIEDON="{datetime:dateTime()}"/>
                                            </xsl:if>
                                        </xsl:if>
                                        <xsl:if test="position() = 2">
                                            <xsl:if test="STATECODE">
                                                <ddm:OIDStateCode2 VALUE="{STATECODE}" SOURCE="I"
                                                                   MODIFIEDON="{datetime:dateTime()}"/>
                                            </xsl:if>
                                            <xsl:if test="STATEIDNUM">
                                                <ddm:OIDStateIdNum2 VALUE="{STATEIDNUM}" SOURCE="I"
                                                                    MODIFIEDON="{datetime:dateTime()}"/>
                                            </xsl:if>
                                            <xsl:if test="STATETAXWHELD">
                                                <ddm:OIDStateTaxWheld2
                                                        VALUE="{format-number(round(STATETAXWHELD),'#0')}" SOURCE="I"
                                                        MODIFIEDON="{datetime:dateTime()}"/>
                                            </xsl:if>
                                        </xsl:if>
                                    </xsl:for-each>
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:if test="STATECODE">
                                        <ddm:OIDStateCode VALUE="{STATECODE}" SOURCE="I"
                                                          MODIFIEDON="{datetime:dateTime()}"/>
                                    </xsl:if>
                                    <xsl:if test="STATEIDNUM">
                                        <ddm:OIDStateIdNum VALUE="{STATEIDNUM}" SOURCE="I"
                                                           MODIFIEDON="{datetime:dateTime()}"/>
                                    </xsl:if>
                                    <xsl:if test="STATETAXWHELD">
                                        <ddm:OIDStateTaxWheld VALUE="{format-number(round(STATETAXWHELD),'#0')}"
                                                              SOURCE="I" MODIFIEDON="{datetime:dateTime()}"/>
                                    </xsl:if>
                                </xsl:otherwise>
                            </xsl:choose>
                            <!-- TY2014 changes to OFX addendum Nov 20th 2013 end -->
                            <!--<xsl:if test="DESCRIPTION">
                        <ddm:OID_Adjust VALUE="{DESCRIPTION}" SOURCE="I" MODIFIEDON="{datetime:dateTime()}"/>
                        </xsl:if>-->
                            <!--<xsl:choose>
                        <xsl:when test="ORIGISDISC">
                        <ddm:INTEREST_TYPE VALUE="O" SOURCE="I" MODIFIEDON="{datetime:dateTime()}"/>
                        </xsl:when>
                        <xsl:otherwise>
                        <ddm:INTEREST_TYPE VALUE="I" SOURCE="I" MODIFIEDON="{datetime:dateTime()}"/>
                        </xsl:otherwise>
                        </xsl:choose>-->
                            <ddm:INTEREST_TYPE VALUE="O" SOURCE="I" MODIFIEDON="{datetime:dateTime()}"/>
                            <ddm:DISPLAY_NAME VALUE="{PAYERADDR/PAYERNAME1}" SOURCE="I"
                                              MODIFIEDON="{datetime:dateTime()}"/>
                            <xsl:if test="OIDONUSTRES">
                                <ddm:DISPLAY_AMOUNT VALUE="{format-number(round(OIDONUSTRES),'#0')}" SOURCE="I"
                                                    MODIFIEDON="{datetime:dateTime()}"/>
                            </xsl:if>
                            <xsl:if test="PAYERADDR/PAYERNAME2">
                                <ddm:PayerName2 VALUE="{PAYERADDR/PAYERNAME2}" SOURCE="I"
                                                MODIFIEDON="{datetime:dateTime()}"/>
                            </xsl:if>
                            <ddm:PayerAddress1 VALUE="{PAYERADDR/ADDR1}" SOURCE="I" MODIFIEDON="{datetime:dateTime()}"/>
                            <xsl:if test="PAYERADDR/ADDR2">
                                <ddm:PayerAddress2 VALUE="{PAYERADDR/ADDR2}" SOURCE="I"
                                                   MODIFIEDON="{datetime:dateTime()}"/>
                            </xsl:if>
                            <xsl:if test="PAYERADDR/ADDR3">
                                <ddm:PayerAddress3 VALUE="{PAYERADDR/ADDR3}" SOURCE="I"
                                                   MODIFIEDON="{datetime:dateTime()}"/>
                            </xsl:if>
                            <ddm:PayerCity VALUE="{PAYERADDR/CITY}" SOURCE="I" MODIFIEDON="{datetime:dateTime()}"/>
                            <ddm:PayerState VALUE="{PAYERADDR/STATE}" SOURCE="I" MODIFIEDON="{datetime:dateTime()}"/>
                            <ddm:PayerZipCode VALUE="{PAYERADDR/POSTALCODE}" SOURCE="I"
                                              MODIFIEDON="{datetime:dateTime()}"/>
                            <xsl:if test="PAYERADDR/PHONE">
                                <ddm:PayerPhone SOURCE="I" MODIFIEDON="{datetime:dateTime()}">
                                    <xsl:attribute name="VALUE">
                                        <xsl:call-template name="Strip-cntrycode">
                                            <xsl:with-param name="phone" select="PAYERADDR/PHONE"/>
                                        </xsl:call-template>
                                    </xsl:attribute>
                                </ddm:PayerPhone>
                            </xsl:if>
                            <ddm:PayerEIN SOURCE="I" MODIFIEDON="{datetime:dateTime()}">
                                <xsl:attribute name="VALUE">
                                    <!-- <xsl:call-template name="Strip-dashes">
                                <xsl:with-param name="ssn" select="PAYERID"/>
                                </xsl:call-template> -->
                                    <xsl:call-template name="FixFedNumb">
                                        <xsl:with-param name="fednum" select="PAYERID"/>
                                    </xsl:call-template>
                                </xsl:attribute>
                            </ddm:PayerEIN>
                            <xsl:if test="RECADDR">
                                <ddm:RecipientName1 VALUE="{RECADDR/RECNAME1}" SOURCE="I"
                                                    MODIFIEDON="{datetime:dateTime()}"/>
                                <!--<xsl:if test="RECADDR/RECNAME2">
                            <ddm:RecipientName2 VALUE="{RECADDR/RECNAME2}" SOURCE="I" MODIFIEDON="{datetime:dateTime()}"/>
                            </xsl:if>-->
                                <ddm:RecipientAddr1 VALUE="{RECADDR/ADDR1}" SOURCE="I"
                                                    MODIFIEDON="{datetime:dateTime()}"/>
                                <xsl:if test="RECADDR/ADDR2">
                                    <ddm:RecipientAddr2 VALUE="{RECADDR/ADDR2}" SOURCE="I"
                                                        MODIFIEDON="{datetime:dateTime()}"/>
                                </xsl:if>
                                <xsl:if test="RECADDR/ADDR3">
                                    <ddm:RecipientAddr3 VALUE="{RECADDR/ADDR3}" SOURCE="I"
                                                        MODIFIEDON="{datetime:dateTime()}"/>
                                </xsl:if>
                                <xsl:if test="RECADDR/CITY">
                                    <ddm:RecipientCity VALUE="{RECADDR/CITY}" SOURCE="I"
                                                       MODIFIEDON="{datetime:dateTime()}"/>
                                </xsl:if>
                                <xsl:if test="RECADDR/STATE">
                                    <ddm:RecipientState VALUE="{RECADDR/STATE}" SOURCE="I"
                                                        MODIFIEDON="{datetime:dateTime()}"/>
                                </xsl:if>
                                <xsl:if test="RECADDR/POSTALCODE">
                                    <ddm:RecipientZipCode VALUE="{RECADDR/POSTALCODE}" SOURCE="I"
                                                          MODIFIEDON="{datetime:dateTime()}"/>
                                </xsl:if>
                            </xsl:if>
                            <ddm:RecipientSSN SOURCE="I" MODIFIEDON="{datetime:dateTime()}">
                                <xsl:attribute name="VALUE">
                                    <xsl:call-template name="Strip-dashes">
                                        <xsl:with-param name="ssn" select="RECID"/>
                                    </xsl:call-template>
                                </xsl:attribute>
                            </ddm:RecipientSSN>
                            <xsl:if test="RECACCT">
                                <ddm:AccountNumber VALUE="{RECACCT}" SOURCE="I" MODIFIEDON="{datetime:dateTime()}"/>
                            </xsl:if>
                            <xsl:if test="VOID">
                                <ddm:VoidCheckBox VALUE="{VOID}" SOURCE="I" MODIFIEDON="{datetime:dateTime()}"/>
                            </xsl:if>
                            <xsl:if test="CORRECTED">
                                <ddm:Corrected VALUE="{CORRECTED}" SOURCE="I" MODIFIEDON="{datetime:dateTime()}"/>
                            </xsl:if>
                        </ddm:FDB_L1_INTEREST>
                    </ddm:FDB>
                </ddm:FD>
            </ddm:TAXDATA>
        </xsl:for-each>
    </xsl:template>


    <!--STATUS-->
    <xsl:template match="STATUS">
        <hrbofx:OFXStatus>
            <CODE>
                <!-- changed for FY 12 ERROR CODE  -->
                <xsl:choose>
                    <xsl:when test="$statusCode=''">
                        <xsl:value-of select="CODE"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:choose>
                            <xsl:when test="contains(CODE,'15')">
                                <xsl:value-of select="$statusCode"/>
                            </xsl:when>
                            <xsl:when test="not(contains(CODE,'15'))">
                                <xsl:value-of select="CODE"/>
                            </xsl:when>
                        </xsl:choose>
                    </xsl:otherwise>
                </xsl:choose>
            </CODE>
            <!--  FY 13 MESSAGE -->

            <SEVERITY>
                <xsl:value-of select="SEVERITY"/>
            </SEVERITY>

            <MESSAGE>
                <!-- <xsl:value-of select="MESSAGE"/>  original-->
                <!--  start FY13 -->
                <xsl:choose>
                    <xsl:when test="$statusMessage=''">
                        <xsl:value-of select="MESSAGE"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:choose>
                            <xsl:when test="contains(CODE,'15')">
                                <xsl:choose>
                                    <xsl:when test="$statusMessage != ''">
                                        <xsl:value-of select="$statusMessage"/>
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <xsl:value-of select="MESSAGE"/>
                                    </xsl:otherwise>
                                </xsl:choose>
                            </xsl:when>
                            <xsl:when test="not(contains(CODE,'15'))">
                                <xsl:value-of select="MESSAGE"/>
                            </xsl:when>
                        </xsl:choose>
                    </xsl:otherwise>
                </xsl:choose>
                <!--  end FY13
            -->
            </MESSAGE>
        </hrbofx:OFXStatus>
    </xsl:template>

    <!--utility templates-->
    <xsl:template name="Strip-dashes">
        <xsl:param name="ssn"/>
        <!--xsl:variable name="stripped" select="replace($ssn,'\-','')"/>
    <xsl:value-of select="$stripped"/-->
        <xsl:choose>
            <xsl:when test="contains($ssn,'-')">
                <xsl:variable name="stripped1" select="substring-before($ssn,'-')"/>
                <xsl:value-of select="$stripped1"/>
                <xsl:variable name="tmp_ssn" select="substring-after($ssn,'-')"/>
                <xsl:choose>
                    <xsl:when test="contains($tmp_ssn,'-')">
                        <xsl:variable name="stripped2" select="substring-before($tmp_ssn,'-')"/>
                        <xsl:value-of select="$stripped2"/>
                        <xsl:variable name="stripped3" select="substring-after($tmp_ssn,'-')"/>
                        <xsl:value-of select="$stripped3"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="$tmp_ssn"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="$ssn"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    <xsl:template name="Strip-cntrycode">
        <xsl:param name="phone"/>
        <xsl:choose>
            <xsl:when test="starts-with($phone, '1-')">
                <xsl:variable name="stripped" select="substring-after($phone,'1-')"/>
                <xsl:value-of select="$stripped"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="$phone"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    <xsl:template name="FormatDate">
        <xsl:param name="DateTime"/>
        <!-- new date format 2006-Jan-14T08:55:22 -->
        <xsl:variable name="mo">
            <xsl:value-of select="substring($DateTime,5,2)"/>
        </xsl:variable>
        <xsl:variable name="day">
            <xsl:value-of select="substring($DateTime,7,2)"/>
        </xsl:variable>
        <xsl:variable name="year">
            <xsl:value-of select="substring($DateTime,1,4)"/>
        </xsl:variable>
        <xsl:value-of select="$mo"/>
        <xsl:value-of select="'/'"/>
        <xsl:value-of select="$day"/>
        <xsl:value-of select="'/'"/>
        <xsl:value-of select="$year"/>
    </xsl:template>
    <xsl:template name="BoolToBin">
        <xsl:param name="value"/>
        <xsl:choose>
            <xsl:when test="$value = 'Y'">
                <xsl:value-of select="1"/>
            </xsl:when>
            <xsl:when test="$value = 'N'">
                <xsl:value-of select="0"/>
            </xsl:when>
        </xsl:choose>
    </xsl:template>

    <xsl:template name="FixFedNumb">
        <xsl:param name="fednum"/>
        <xsl:choose>
            <!-- test for FEDIDNUMBER tag being absent for or being empty in 1099 -->
            <xsl:when test="(not($fednum)) or ($fednum='')">
                <xsl:value-of select="$fednum"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="format-number(number(translate($fednum, '-', '')),'000000000')"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

</xsl:stylesheet>