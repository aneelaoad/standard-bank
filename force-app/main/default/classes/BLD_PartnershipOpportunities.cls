/**
* @description  : Builder class for PP_PartnershipOpportunity__c SObject
*
* @author Syed Ovais Ali (syed.ali@standardbank.co.za)
* @date July 2021
*/
@IsTest
public with sharing class BLD_PartnershipOpportunities extends ABS_ObjectBuilderBase {
    
    public static final String DEF_NAME  = 'Predictive Analytics for Credit Scoring';
    public static final String DEF_CONTENT = 'TEST';
    public static final String DEF_INDUSTRY = 'Agriculture';
    public static final String DEF_COUNTRY = 'South Africa';
    public static final Date DEF_PUBLISHSTARTDATE = Date.today().addDays(-10);
    public static final Date DEF_PUBLISHENDDATE = Date.today().addDays(10);
    public static final String DEF_SUMMARY = 'Test';
    public static final String DEF_STATUS = 'Approved';
    public static final Boolean DEF_FEATURED = true;

     public BLD_PartnershipOpportunities() {
        this(getNewUnitOfWork());
    }
    
    public BLD_PartnershipOpportunities(fflib_SObjectUnitOfWork workUnit) {
        super(PP_PartnershipOpportunity__c.SObjectType, workUnit);
    }
    
    public BLD_PartnershipOpportunities setPartnershipOpptyData() {
        return (BLD_PartnershipOpportunities) setField(PP_PartnershipOpportunity__c.Name,  DEF_NAME)
            .setField(PP_PartnershipOpportunity__c.PP_Content__c,  DEF_CONTENT)
            .setField(PP_PartnershipOpportunity__c.PP_Industry__c, DEF_INDUSTRY)
            .setField(PP_PartnershipOpportunity__c.PP_Country__c, DEF_COUNTRY)
            .setField(PP_PartnershipOpportunity__c.PP_PublishStartDate__c , DEF_PUBLISHSTARTDATE)
            .setField(PP_PartnershipOpportunity__c.PP_PublishEndDate__c,  DEF_PUBLISHENDDATE)
            .setField(PP_PartnershipOpportunity__c.PP_Summary__c, DEF_SUMMARY)
            .setField(PP_PartnershipOpportunity__c.PP_Status__c, DEF_STATUS)
            .setField(PP_PartnershipOpportunity__c.PP_Featured__c, DEF_FEATURED);
    }
    
    public static PP_PartnershipOpportunity__c getPartnershipOppty(){
        PP_PartnershipOpportunity__c partnership = new PP_PartnershipOpportunity__c();
        partnership.Name = DEF_NAME;
        partnership.PP_Content__c = DEF_CONTENT;
        partnership.PP_Industry__c = DEF_INDUSTRY;
        partnership.PP_Country__c = DEF_COUNTRY;
        partnership.PP_PublishStartDate__c = DEF_PUBLISHSTARTDATE;
        partnership.PP_PublishEndDate__c = DEF_PUBLISHENDDATE;
        partnership.PP_Summary__c = DEF_SUMMARY;
        partnership.PP_Status__c = DEF_STATUS;
        partnership.PP_Featured__c =  DEF_FEATURED;
        return partnership;
    }
    
    
}