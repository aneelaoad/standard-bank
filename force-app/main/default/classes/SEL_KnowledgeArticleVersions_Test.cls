/**
 * @description Test class for SEL_KnowledgeArticleVersions
 *
 * @author Wayde Fagan (Wayde.fagan@tetrad.co.za)
 * @date july 2021
 * 
 * @LastModified March 2023
 * @author Milica Milicevic (milica.milicevic@standardbank.co.za)
 * @UserStory SFP-21025
 * @LastModifiedReason Added a test methods to accomodate the new methods incorporating categories
 * 
 * @LastModified May 2023
 * @author Milica Milicevic (milica.milicevic@standardbank.co.za)
 * @UserStory SFP-28081
 * @LastModifiedReason Update test class to accomodate for retrieving subscribed solutions based on contact ID instead of user ID
 * 
 * @LastModified May 2023
 * @author Milica Milicevic (milica.milicevic@standardbank.co.za)
 * @UserStory SFP-21026
 * @LastModifiedReason Update test method shouldSelectBySubscribedSolutionForUserWoSharing to accomodate for new record types 
 *
 * @LastModified October 2023
 * @author Nkosi Ncube (nkosi.ncube@standardbank.co.za)
 * @UserStory SFP-20792
 * @LastModifiedReason Added new test methods shouldSelectArticleByPublishStatusAndProvider and shouldSelectArticleByProviderId for ProviderSpaces
 * 
 * @LastModified November 2023
 * @author Nkosi Ncube (nkosi.ncube@standardbank.co.za)
 * @UserStory SFP-20792
 * @LastModifiedReason Updated variables for the following method shouldSelectArticleByPublishStatusAndProvider 
 * 
 */

 
@IsTest
private class SEL_KnowledgeArticleVersions_Test {
    
    private static final String PUBLISH_STATUS = 'Online';
    private static final String PERSONA = 'Client';
    private static final String OPERATING_COUNTRY = 'South Africa';
    private static final String CATEGORY = 'Tester Category';
    private static final String OBJ_NAME = 'Knowledge__kav';
    private static final String RT_API = 'Community_Content_API_Product';
    private static final String RT_SOLUTION = 'Community_Content_Solution';
    private static final String RT_SUCESSSTORIES = 'Community_Content_Success_Stories';
    private static final String RT_PROVIDER = 'Community_Content_Provider_Spaces';
    
	@IsTest
    static void shouldSelectArticleByPublishStatusAndRecordType() {
        SEL_KnowledgeArticleVersions.newInstance().selectArticleByPublishStatusAndRecordType(new Set<String>(),new Set<Id>(),1);
        fflib_QueryFactory result = fflib_QueryFactory.lastQueryFactory;
        Assert.areEqual(true, result.getCondition().containsIgnoreCase('PublishStatus IN :publishStatuses AND RecordTypeId IN :recordTypesIds'), 'Condition for record type and published status used');
    }
    
    @IsTest
    static void shouldSearchArticles() {
        string pubStatus = '';
        string searchKey = '';
        string artType = '';
        SEL_KnowledgeArticleVersions.newInstance().searchArticles(pubStatus, new list<String>(), searchKey, artType);
        fflib_QueryFactory result = fflib_QueryFactory.lastQueryFactory;
        Assert.areEqual(true, result.getCondition().containsIgnoreCase('PublishStatus =:publishStatus'),'Condition for published status is used');
    }
    
    @IsTest
    static void shouldselectByPublishStatusAndRecordTypewithSearchIDsWoSharing() {
        Set<String> publishStatuses = new Set<String>{PUBLISH_STATUS};
        Set<Id> recordTypeIds = new Set<Id>{UTL_RecordType.getRecordTypeId(OBJ_NAME, RT_API)};
        Set<Id> knowledgeIds = new Set<Id>{UTL_RecordType.getRecordTypeId(OBJ_NAME, RT_SOLUTION)};
        Set<Id> exceptionArticleIds = new Set<Id>{UTL_RecordType.getRecordTypeId(OBJ_NAME, RT_SUCESSSTORIES)};    
        Map <String,object> knowledgeArticlesMap = new Map <String,object>();
        knowledgeArticlesMap.put('publishStatuses',publishStatuses);
        knowledgeArticlesMap.put('recordTypeIds',recordTypeIds);
        knowledgeArticlesMap.put('knowledgeIds',knowledgeIds);
        knowledgeArticlesMap.put('persona',PERSONA);
        knowledgeArticlesMap.put('operatingCountries',OPERATING_COUNTRY);
        knowledgeArticlesMap.put('exceptionArticleIds',exceptionArticleIds);
        
        SEL_KnowledgeArticleVersions.newInstance().selectByPublishStatusAndRecordTypewithSearchIDsWoSharing(knowledgeArticlesMap);
        fflib_QueryFactory result = fflib_QueryFactory.lastQueryFactory;
        Assert.areEqual(true, result.getCondition().containsIgnoreCase('RecordTypeId IN :recordTypeIds AND PublishStatus IN :publishStatuses AND Id IN :knowledgeIds'), 'Condition for knowledge article ID and published status used');
    }
    
    @IsTest
    static void shouldSelectByPublishStatusAndRecordTypeIdWoSharing() {
        SEL_KnowledgeArticleVersions.newInstance().selectByPublishStatusAndRecordTypeIdWoSharing(new Set<String>(),new Set<Id>(),new Set<Id>());
        fflib_QueryFactory result = fflib_QueryFactory.lastQueryFactory;
        Assert.areEqual(true, result.getCondition().containsIgnoreCase('PublishStatus IN :publishStatuses AND RecordTypeId IN :recordTypesIds AND Id NOT IN :knowledgeIds'), 'Condition for record type and knowledge article ID used');
    }
    
    @IsTest
    static void shouldSelectByPublishStatusAndTitleWoSharing() {
        SEL_KnowledgeArticleVersions.newInstance().selectByPublishStatusAndTitleWoSharing(new Set<String>(),new Set<String>());
        fflib_QueryFactory result = fflib_QueryFactory.lastQueryFactory;
        Assert.areEqual(true, result.getCondition().containsIgnoreCase('PublishStatus IN :publishStatuses AND Title LIKE: knowledgeTitles'), 'Condition for title and published status used'); 
    }
    
    @IsTest
    static void shouldSelectBySubscribedSolutionForUserWoSharing() {
        SEL_KnowledgeArticleVersions.newInstance().selectBySubscribedSolutionForUserWoSharing(new Set<Id>(), new Set<Id>());
        fflib_QueryFactory result = fflib_QueryFactory.lastQueryFactory;
        Assert.areEqual(true, result.getCondition().containsIgnoreCase('Id IN (SELECT Solution__c FROM Subscribed_Solutions__c WHERE Contact__c IN :contactIds AND RecordTypeId IN :recordTypesIds)'), 'Condition for contact ID is used');

    }
    
    @IsTest
    static void shouldSelectByPublishStatusIdAndRecordTypeIdWoSharing() {
        SEL_KnowledgeArticleVersions.newInstance().selectByPublishStatusIdAndRecordTypeIdWoSharing(new Set<String>(),new Set<Id>(),new Set<Id>());
        fflib_QueryFactory result = fflib_QueryFactory.lastQueryFactory;
        Assert.areEqual(true, result.getCondition().containsIgnoreCase('PublishStatus IN :publishStatuses AND Id IN :knowledgeIds AND RecordTypeId IN :recordTypesIds'), 'Condition for record type, knowledge article Ids and published status used');
    }
    
    @IsTest
    static void shouldSelectByPublishStatusAndRecordTypeIdWithLogoPersonaWoSharing() {
        SEL_KnowledgeArticleVersions.newInstance().selectByPublishStatusAndRecordTypeIdWithLogoPersonaWoSharing(new Set<String>(),new Set<Id>(),new Set<Id>(),'');
        fflib_QueryFactory result = fflib_QueryFactory.lastQueryFactory;
        Assert.areEqual(true, result.getCondition().containsIgnoreCase('((PublishStatus IN :publishStatuses AND RecordTypeId IN :recordTypesIds AND OSB_Persona__c INCLUDES (:persona)) OR Id IN :knowledgeExceptions)'), 'Condition for record type, knowledge articles, excepmtions and published status used');
    }
    
    @IsTest
    static void shouldSelectByPublishStatusAndRecordTypeIdPersona() {
        SEL_KnowledgeArticleVersions.newInstance().selectByPublishStatusAndRecordTypeIdPersona(new Set<String>(),new Set<Id>(),new Set<Id>(),new Set<Id>(),'');
        fflib_QueryFactory result = fflib_QueryFactory.lastQueryFactory;
        Assert.areEqual(true, result.getCondition().containsIgnoreCase('(PublishStatus IN :publishStatuses AND RecordTypeId IN :recordTypesIds AND OSB_Persona__c INCLUDES (:persona) AND Id NOT IN :knowledgeIds) OR Id IN :exceptionRecords'), 'Condition for record type, persona and published status used');
    }
    
    @IsTest
    static void shouldSelectByPublishStatusAndRecordTypeIdPersonaApiWoSharing() {
        SEL_KnowledgeArticleVersions.newInstance().selectByPublishStatusAndRecordTypeIdPersonaApiWoSharing(new Set<String>(),new Set<Id>(),'Client','South Africa',new Set<Id>());
        fflib_QueryFactory result = fflib_QueryFactory.lastQueryFactory;
        Assert.areEqual(true, result.getCondition().containsIgnoreCase('RecordTypeId IN :recordTypeIds AND PublishStatus IN :publishStatuses'), 'Condition for record type and published status with api knowldge used');
    }
    
    @IsTest
    static void shouldSelectByPublishStatusAndRecordTypeIdPersonaSolutionWoSharing() {
        SEL_KnowledgeArticleVersions.newInstance().selectByPublishStatusAndRecordTypeIdPersonaSolutionWoSharing(new Set<String>(),new Set<Id>(),new Set<Id>(),'Client','South Africa',new Set<Id>());
        fflib_QueryFactory result = fflib_QueryFactory.lastQueryFactory;
        Assert.areEqual(true, result.getCondition().containsIgnoreCase('RecordTypeId IN :recordTypeIds AND PublishStatus IN :publishStatuses AND Id NOT IN :knowledgeIds'), 'Condition for record type and published status but not in knowldge article IDs used');
    }

    @IsTest
    static void shouldselectByPublishStatusAndRecordTypeIdPersonaAndCategorySolutionWoSharing() {
        SEL_KnowledgeArticleVersions.newInstance().selectByPublishStatusAndRecordTypeIdPersonaAndCategorySolutionWoSharing(new Set<String>(),new Set<Id>(),new Set<Id>(),'Client','South Africa',new Set<Id>(), CATEGORY);
        fflib_QueryFactory result = fflib_QueryFactory.lastQueryFactory;
        Assert.areEqual(true, result.getCondition().containsIgnoreCase('RecordTypeId IN :recordTypeIds AND PublishStatus IN :publishStatuses AND Id NOT IN :knowledgeIds'), 'Condition for record type, knowledge article ID and published status used without sharing');
    }
    
    @IsTest
    static void shouldselectByCategoryAndPublishStatusAndRecordTypewithSearchIDsWoSharing() {
        Set<String> publishStatuses = new Set<String>{PUBLISH_STATUS};
        Set<Id> recordTypeIds = new Set<Id>{UTL_RecordType.getRecordTypeId(OBJ_NAME, RT_API)};
        Set<Id> knowledgeIds = new Set<Id>{UTL_RecordType.getRecordTypeId(OBJ_NAME, RT_SOLUTION)};
        Set<Id> exceptionArticleIds = new Set<Id>{UTL_RecordType.getRecordTypeId(OBJ_NAME, RT_SUCESSSTORIES)};    
        Map <String,object> knowledgeArticlesMap = new Map <String,object>();
        knowledgeArticlesMap.put('publishStatuses',publishStatuses);
        knowledgeArticlesMap.put('recordTypeIds',recordTypeIds);
        knowledgeArticlesMap.put('knowledgeIds',knowledgeIds);
        knowledgeArticlesMap.put('persona',PERSONA);
        knowledgeArticlesMap.put('operatingCountries',OPERATING_COUNTRY);
        knowledgeArticlesMap.put('exceptionArticleIds',exceptionArticleIds);
        knowledgeArticlesMap.put('categories',CATEGORY);
        
        SEL_KnowledgeArticleVersions.newInstance().selectByCategoryAndPublishStatusAndRecordTypewithSearchIDsWoSharing(knowledgeArticlesMap);
        fflib_QueryFactory result = fflib_QueryFactory.lastQueryFactory;
        Assert.areEqual(true, result.getCondition().containsIgnoreCase('RecordTypeId IN :recordTypeIds AND PublishStatus IN :publishStatuses AND Id IN :knowledgeIds'), 'Condition for published status and not equaling to record type used');
    }

    @IsTest
    static void shouldSelectFeaturedArticles(){
        Set<String> publishStatuses = new Set<String>{PUBLISH_STATUS};
        Integer intLimit = 1;
        SEL_KnowledgeArticleVersions.newInstance().selectFeaturedArticles(publishStatuses, intLimit);
        fflib_QueryFactory result = fflib_QueryFactory.lastQueryFactory;
        Assert.areEqual(true, result.getCondition().containsIgnoreCase('PublishStatus IN :publishStatuses AND Featured__c = true AND RecordTypeId != :recordTypeId'), 'Condition for published status and not equaling to record type used');
    }

    @IsTest
    static void shouldSelectArticleByPublishStatusAndProvider() {
        Set<String> publishStatuses = new Set<String>{PUBLISH_STATUS};
        Set<Id> recordTypeIds = new Set<Id>{UTL_RecordType.getRecordTypeId(OBJ_NAME, RT_PROVIDER)};
        Set<Id> providerIds = new Set<Id>{UTL_RecordType.getRecordTypeId(OBJ_NAME, RT_PROVIDER)};
        String operatingCountries;
        String persona;
        SEL_KnowledgeArticleVersions.newInstance().selectArticleByPublishStatusAndProvider(publishStatuses, recordTypeIds, providerIds, PERSONA, OPERATING_COUNTRY);
        fflib_QueryFactory result = fflib_QueryFactory.lastQueryFactory;
        Assert.areEqual(true, result.getCondition().containsIgnoreCase('PublishStatus IN :publishStatuses AND RecordTypeId IN :recordTypeIds AND Provider_Knowledge_Article__c IN :providerIds' ),  'Condition for published status and not equaling to record type used');
    }

    @IsTest
    static void shouldSelectArticleByProviderId() {
        Set<String> publishStatuses = new Set<String>{PUBLISH_STATUS};
        Set<Id> providerIds = new Set<Id>{UTL_RecordType.getRecordTypeId(OBJ_NAME, RT_PROVIDER)};       
        SEL_KnowledgeArticleVersions.newInstance().selectArticleByProviderId(publishStatuses, providerIds);
        fflib_QueryFactory result = fflib_QueryFactory.lastQueryFactory;
        Assert.areEqual(true, result.getCondition().containsIgnoreCase('PublishStatus IN :publishStatuses  AND Id IN :providerIds'), 'Condition for published status and not equaling to record type used');
    }
}