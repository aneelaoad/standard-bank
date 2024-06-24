/**
 * @description Builder class for Knowledge__kav SObject
 *
 * @author      Wojciech Kowalczyk (wkowalczyk@deloittece.com)
 * @date        March 2020
 * 
 * @LastModified March 2023
 * @author Milica Milicevic (milica.milicevic@standardbank.co.za)
 * @UserStory SFP-21025
 * @LastModifiedReason Added a method for a category to be assigned to a knowledge article
 * 
 * @LastModified October 2023
 * @author Nkosi Ncube (nkosi.ncube@standardbank.co.za)
 * @UserStory SFP-20792
 * @LastModifiedReason Added a method -useProviderSpace- for Provider Spaces
 */

@IsTest
public with sharing class BLD_Knowledge extends ABS_ObjectBuilderBase {
    public static final String DEF_TITLE = 'Test article';
    public static final String DEF_INTRODUCTION = 'Test introduction';
    public static final String DEF_URL = 'Test url';
    public static final String DEF_URL_NAME = 'Testname';
	public static final String DEF_OPERATING_COUNTRY = 'Angola;South Africa';
    public static final String DEF_PERSONA = 'Staff;Client';
    
    /**
     * @description New unit of work for Builder class for Knowledge__kav SObject
     * 
     */
    public BLD_Knowledge() {
        this(getNewUnitOfWorkWithKnowledge());
    }

    /**
     * @description New unit of work for Builder class for Knowledge__kav SObject with unit of work parameter
     * @param uow a unit of work in fflib_SObjectUnitOfWork
     * 
     */
    public BLD_Knowledge(fflib_SObjectUnitOfWork uow) {
        super(Knowledge__kav.SObjectType, uow);
    }

    /**
     * @description New unit of work for Builder class for Knowledge__kav SObject with unit of work and knowledge parameter
     * @param knowledge knowledge object
     * @param uow a unit of work in fflib_SObjectUnitOfWork
     */
    public BLD_Knowledge(Knowledge__kav knowledge, fflib_SObjectUnitOfWork uow) {
        super(knowledge, uow);
    }

    /**
     * @description Method to set up the knowledge object fields for 
     * @return Knowledge object
     */
    public BLD_Knowledge setOSBData() {
        return (BLD_Knowledge) setField(Knowledge__kav.Title,  DEF_TITLE)
                .setField(Knowledge__kav.Introduction__c,  DEF_INTRODUCTION)
                .setField(Knowledge__kav.URL__c, DEF_URL)
                .setField(Knowledge__kav.UrlName, DEF_URL_NAME)
            	.setField(Knowledge__kav.OSB_Persona__c, DEF_PERSONA)
            	.setField(Knowledge__kav.OSB_Country__c , DEF_OPERATING_COUNTRY);
    }

    /**
     * @description Set the url to the knowldhe object record
     * @param url url in string format
     * @return knowledge object with url field set
     */
    public BLD_Knowledge url(String url) {
        return (BLD_Knowledge) setField(Knowledge__kav.URL__c, url);
    }

    /**
     * @description Set the url name to the knowldhe object record
     * @param urlName url name in string format
     * @return knowledge object with url name field set
     */
    public BLD_Knowledge urlName(String urlName) {
        return (BLD_Knowledge) setField(Knowledge__kav.UrlName, urlName);
    }

    /**
     * @description Set the coming soon field to the knowldhe object record
     * @param isComingSoon url in bool format
     * @return knowledge object with coming soon field set
     */
    public BLD_Knowledge isComingSoon(Boolean isComingSoon) {
        return (BLD_Knowledge) setField(Knowledge__kav.Is_coming_soon__c, isComingSoon);
    }

    /**
     * @description Set the record type for insights
     * @return knowledge object which is an insight
     */
    public BLD_Knowledge useInsightArticle() {
        return (BLD_Knowledge) setField(Knowledge__kav.RecordtypeId, UTL_RecordType.getRecordTypeId(DMN_Knowledge.OBJ_NAME, DMN_Knowledge.RT_INSIGHT));
    }

    /**
     * @description Set the record type got apis
     * @return knowledge object which is an api
     */
    public BLD_Knowledge useApiProduct() {
        return (BLD_Knowledge) setField(Knowledge__kav.RecordtypeId, UTL_RecordType.getRecordTypeId(DMN_Knowledge.OBJ_NAME, DMN_Knowledge.RT_API));
    }

    /**
     * @description Set the record type got solution
     * @return knowledge object which is an solution
     */
    public BLD_Knowledge useSolution() {
        return (BLD_Knowledge) setField(Knowledge__kav.RecordtypeId, UTL_RecordType.getRecordTypeId(DMN_Knowledge.OBJ_NAME, DMN_Knowledge.RT_SOLUTION));
    }

    /**
     * @description Set the record type got FAQs
     * @return knowledge object which is an FAQ
     */
    public BLD_Knowledge useFAQ() {
        return (BLD_Knowledge) setField(Knowledge__kav.RecordtypeId, UTL_RecordType.getRecordTypeId(DMN_Knowledge.OBJ_NAME, DMN_Knowledge.RT_FAQCUSTOM));
    }

    /**
     * @description Set the record type got success story
     * @return knowledge object which is an success story
     */
    public BLD_Knowledge useSuccessStory() {
        return (BLD_Knowledge) setField(Knowledge__kav.RecordtypeId, UTL_RecordType.getRecordTypeId(DMN_Knowledge.OBJ_NAME, DMN_Knowledge.RT_SUCESSSTORIES));
    }

    /**
     * @description Set the category to the knowldhe object record
     * @param selectedCategory category in string format
     * @return knowledge object with category field set
     */
    public BLD_Knowledge selectedCategory(String selectedCategory) {
        return (BLD_Knowledge) setField(Knowledge__kav.Categories__c , selectedCategory);
    }

    /**
     * @description Set the record type for PROVIDER SPACES
     * @return knowledge object record which is an Provider Space
     */
    public BLD_Knowledge useProviderSpace() {
        return (BLD_Knowledge) setField(Knowledge__kav.RecordtypeId, UTL_RecordType.getRecordTypeId(DMN_Knowledge.OBJ_NAME, DMN_Knowledge.RT_PROVIDER_SPACES));
    }
}