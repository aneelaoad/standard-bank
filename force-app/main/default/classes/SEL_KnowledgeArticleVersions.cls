/**
 * @description Selector class for Knowledge__kav SObject
 *
 * @author Wojciech Kowalczyk (wkowalczyk@deloittece.com)
 * @date May 2020
 * 
 * @LastModified March 2023
 * @author Milica Milicevic (milica.milicevic@standardbank.co.za)
 * @UserStory SFP-21025
 * @LastModifiedReason Adding methods to accomodate queries to include category selection
 * 
 * @LastModified May 2023
 * @author Milica Milicevic (milica.milicevic@standardbank.co.za)
 * @UserStory SFP-28081
 * @LastModifiedReason Update to retrieve subscribed solutions based on contact ID instead of user ID
 * 
 * @LastModified May 2023
 * @author Milica Milicevic (milica.milicevic@standardbank.co.za)
 * @UserStory SFP-21026
 * @LastModifiedReason Update selectBySubscribedSolutionForUser to accomodate for new record types 
 * 
 * @LastModified October 2023
 * @author Nkosi Ncube (nkosi.ncube@standardbank.co.za)
 * @UserStory SFP-20792
 * @LastModifiedReason Add two methods selectArticleByProviderId and selectArticleByPublishStatusAndProvider and a new field Solution_Provider__c
 * to allow for retrieving Provider solutions and related solutions
 * 
 * @LastModified November 2023
 * @author Nkosi Ncube (nkosi.ncube@standardbank.co.za)
 * @UserStory SFP-20792
 * @LastModifiedReason Refactored selectArticleByPublishStatusAndProvider to include persona and operating country
 * 
 */

@SuppressWarnings('PMD.ExcessivePublicCount')
public inherited sharing class SEL_KnowledgeArticleVersions extends fflib_SObjectSelector {

    private static final String 
        FAQ         = 'FAQ',
        HOW_TO_GUIDES       = 'How_to_Guides',
        PRODUCT_INFO        = 'Product_Info';
    /**
     * @description Creates a new instance of the selector via the application class. This is here to allow unit tests to override
     * and inject a mock instead of this class or to switch out this class for a new version.
     * @return Knowledge Article Versions
     */
    public static SEL_KnowledgeArticleVersions newInstance() {
        return (SEL_KnowledgeArticleVersions) ORG_Application.selector
                .include(new Map<SObjectType, Type>{Knowledge__kav.SObjectType => SEL_KnowledgeArticleVersions.class})
                .newInstance(Knowledge__kav.SObjectType);
    }

    /**
     * @description Returns the SObject type for the selector. This is used to retrieve the sObject name when building the SOQL
     * queries.
     * @return sObjectType of Knowledge__kav
     */
    public SObjectType getSObjectType() {
        return Knowledge__kav.SObjectType;
    }

    /**
     * @description  Returns the SObject fields
     * @return list of Knowledge__kav fields
     */
    public List<SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField>{
                Knowledge__kav.CreatedDate,
                Knowledge__kav.Created_date__c,   
                Knowledge__kav.External_url__c,    
                Knowledge__kav.Id,
                Knowledge__kav.Image__c,   
                Knowledge__kav.Introduction__c,
                Knowledge__kav.Is_coming_soon__c,
                Knowledge__kav.OSB_Country__c,
                Knowledge__kav.OSB_Persona__c,
                Knowledge__kav.URL__c,
                Knowledge__kav.KnowledgeArticleId,
                Knowledge__kav.Sign_Up_URL__c,
                Knowledge__kav.Solution_URL__c,
                Knowledge__kav.SSO_Redirect_URL__c,
                Knowledge__kav.Title,   
                Knowledge__kav.Categories__c,
                Knowledge__kav.Application_Owner__c,
                Knowledge__kav.Video_URL__c,
                Knowledge__kav.Podcast_URL__c,
                Knowledge__kav.External_url__c,
                Knowledge__kav.UrlName,
                Knowledge__kav.Is_Thought_Leadership__c,
                Knowledge__kav.Provider_Knowledge_Article__c,
                Knowledge__kav.Key_Words__c
        };
    }

    /**
     * @description Select Knowledge__kav based on PublishStatues and RecordTypeIds and Limit
     * User Story SFP-5296
     * @param publishStatuses set of searched PublishStatus picklist values
     * @param recordTypesIds set of searched record types' ids
     * @param recordLimit to set limit
     * @return list of Knowledge__kav
     */
    public List<Knowledge__kav> selectArticleByPublishStatusAndRecordType(Set<String> publishStatuses, Set<Id> recordTypesIds, Integer recordLimit) {
            
        fflib_QueryFactory articleQueryFactory = newQueryFactory(false, false, true);
       
        articleQueryFactory
            .selectField('Id')
            .selectField('RecordType.DeveloperName')
            .selectField('Title')
            .selectField('Summary')
            .selectField('UrlName')
            .selectField('Info__c')
            .selectField('Image__c')
            .selectField('Categories__c')
            .selectField('LastPublishedDate')
            .setCondition('PublishStatus IN :publishStatuses AND RecordTypeId IN :recordTypesIds')
            .removeOrderings()
            .addOrdering('LastPublishedDate', fflib_QueryFactory.SortOrder.DESCENDING);
        
        if(recordLimit != null){
            articleQueryFactory.setLimit(recordLimit);
        }
                
        return Database.query(articleQueryFactory.toSOQL());
    }

    /**
     * @description Select Featured Articles
     * User Story : SFP-4871
     * @param publishStatuses set of searched PublishStatus picklist values
     * @param recordLimit
     * @return list of Knowledge__kav
     */
    public List<Knowledge__kav> selectFeaturedArticles(Set<String> publishStatuses, Integer recordLimit) {
        
        Id recordTypeId = UTL_RecordType.getRecordTypeId(DMN_Knowledge.OBJ_NAME, DMN_Knowledge.RT_FAQCUSTOM);
        fflib_QueryFactory articleQueryFactory = newQueryFactory(false, false, true);
       
        articleQueryFactory
            .selectField('Id')
            .selectField('RecordType.DeveloperName')
            .selectField('Title')
            .selectField('Summary')
            .selectField('UrlName')
            .selectField('Info__c')
            .selectField('Image__c')
            .selectField('Featured__c')
            .selectField('Categories__c')
            .selectField('LastPublishedDate')
            .setCondition('PublishStatus IN :publishStatuses AND Featured__c = true AND RecordTypeId != :recordTypeId')
            .removeOrderings()
            .addOrdering('LastPublishedDate', fflib_QueryFactory.SortOrder.DESCENDING);
        
         if(recordLimit != null){
            articleQueryFactory.setLimit(recordLimit);
        }
        
        return Database.query(articleQueryFactory.toSOQL());
    }

    /**
     * @description OneHub - Knowledge Tab related component
     * User Story : SFP-7229
     * @param publishStatus
     * @param countries - List of countries the article is applicable to 
     * @param searchKey - searchKey passed from UI
     * @param articleType - type of article viz., recordtype name
     * @return list of Knowledge__kav
     */
    public List<Knowledge__kav> searchArticles(String publishStatus, list<String> countries, String searchKey, String articleType) {
        fflib_QueryFactory articleQueryFactory = newQueryFactory(false, false, true);
        String query = 'PublishStatus =:publishStatus' ;
        Set<String> recordTypeSet = new Set<String>(new String[]{
                                                 UTL_RecordType.getRecordTypeId('Knowledge__kav', FAQ)
                                                ,UTL_RecordType.getRecordTypeId('Knowledge__kav', HOW_TO_GUIDES)
                                                ,UTL_RecordType.getRecordTypeId('Knowledge__kav', PRODUCT_INFO)});
        if(countries.size() > 0 ){
            query+= ' AND OSB_Country__c INCLUDES '+ countries;  
        }
        if(!string.isBlank(searchKey)){
            query+= ' AND Title LIKE \'%'+ searchKey +'%\'';  
        }
        if(!string.isBlank(articleType)){
            query+=' AND RecordType.Name LIKE \'%'+ articleType +'%\'';
        }else {
            query+=' AND RecordTypeId IN :recordTypeSet';
        }
        
        articleQueryFactory
            .selectField('Id')
            .selectField('ArticleNumber')
            .selectField('Title')
            .selectField('Summary')
            .selectField('Info__c')
            .selectField('Categories__c')
            .selectField('RecordType.Name')
            .selectField('LastPublishedDate')
            .selectField('Feature_Management__c')
            .selectField('External_url__c')
            .selectField('UrlName')
            .setCondition(query)
            .removeOrderings()
            .addOrdering('LastPublishedDate', fflib_QueryFactory.SortOrder.DESCENDING);
        
        return Database.query(articleQueryFactory.toSOQL());
    }
    
    /**
     * @description for specified Knowledge ids, but only with certain PublishStatuses and recordt types
     *
     * @param publishStatuses set of searched PublishStatus picklist values
     * @param knowledgeIds set of searched Knowledge__kav ids
     * @param recordTypesIds set of searched record types' ids
     *
     * @return list of Knowledge__kav
     */
    public List<Knowledge__kav> selectByPublishStatusIdAndRecordTypeId(Set<String> publishStatuses, Set<Id> knowledgeIds, Set<Id> recordTypesIds) {
        return Database.query(
                newQueryFactory(false, false, true)
                .selectField('RecordType.DeveloperName')
                .setCondition('PublishStatus IN :publishStatuses AND Id IN :knowledgeIds AND RecordTypeId IN :recordTypesIds')
                .removeOrderings()
                .addOrdering('CreatedDate', fflib_QueryFactory.SortOrder.ASCENDING)
                .toSOQL()
        );
    }
    
    /**
     * @description Searches for specified Knowledge ids, but only with certain PublishStatuses and title
     *
     * @param publishStatuses set of searched PublishStatus picklist values
     * @param knowledgeTitles set of searched Knowledge__kav ids
     *
     * @return list of Knowledge__kav
     */
    public List<Knowledge__kav> selectByPublishStatusAndTitle(Set<String> publishStatuses, Set<String> knowledgeTitles) {
        return Database.query(
                newQueryFactory(false, false, true)
                .setCondition('PublishStatus IN :publishStatuses AND Title LIKE: knowledgeTitles')
                .toSOQL()
        );
    }

    /**
     * @description Select Knowledge__kav based on PublishStatus and RecordTypeId with RecordType.DeveloperName
     *
     * @param publishStatuses set of searched PublishStatus picklist values
     * @param recordTypesIds set of searched record types' ids
     * @param knowledgeIds set of Knowledge__kav Ids
     * @return list of Knowledge__kav
     */
    public List<Knowledge__kav> selectByPublishStatusAndRecordTypeId(Set<String> publishStatuses, Set<Id> recordTypesIds, Set<Id> knowledgeIds) {
        return Database.query(
                newQueryFactory(false, false, true)
                .selectField('RecordType.DeveloperName')
                .selectField('Medium_Solution_Logo__c')
                .selectField('Large_Solution_Logo__c')
                .selectField('CreatedDate')
                .selectField('Categories__c')
                .setCondition('PublishStatus IN :publishStatuses AND RecordTypeId IN :recordTypesIds AND Id NOT IN :knowledgeIds')
                .removeOrderings()
                .addOrdering('Is_coming_soon__c', fflib_QueryFactory.SortOrder.ASCENDING)
                .addOrdering('CreatedDate', fflib_QueryFactory.SortOrder.DESCENDING)
                .toSOQL()
        );
    }

    /**
     * @description Select Knowledge__kav based on PublishStatus and RecordTypeId with RecordType.DeveloperName
     *
     * @param publishStatuses set of searched PublishStatus picklist values
     * @param recordTypesIds set of searched record types' ids
     * @param knowledgeIds set of Knowledge__kav Ids
     * @param exceptionRecords set of Id that are to be included in the search
     * @param persona String of personas to be used to filter the results by (client,staff)
     * @return list of Knowledge__kav
     */
    public List<Knowledge__kav> selectByPublishStatusAndRecordTypeIdPersona(Set<String> publishStatuses, Set<Id> recordTypesIds, Set<Id> knowledgeIds, Set<Id> exceptionRecords,String persona) {
        return Database.query(
                newQueryFactory(false, false, true)
                .selectField('RecordType.DeveloperName')
                .selectField('Medium_Solution_Logo__c')
                .selectField('Large_Solution_Logo__c')
                .selectField('CreatedDate')
                .selectField('Categories__c')
                .setCondition('(PublishStatus IN :publishStatuses AND RecordTypeId IN :recordTypesIds AND OSB_Persona__c INCLUDES (:persona) AND Id NOT IN :knowledgeIds) OR Id IN :exceptionRecords')
                .removeOrderings()
                .addOrdering('Is_coming_soon__c', fflib_QueryFactory.SortOrder.ASCENDING)
                .addOrdering('CreatedDate', fflib_QueryFactory.SortOrder.DESCENDING)
                .toSOQL()
        );
    }

    /**
     * @description Select Knowledge__kav based on publishStatuses and recordTypeIds with RecordType.DeveloperName, persona, operatingCountries and exceptionArticleIds(knowledge)
     *
     * @param publishStatuses set of searched PublishStatus picklist values
     * @param recordTypeIds set of searched record types' ids
     * @param persona String of personas to be used to filter the results by (client,staff)
     * @param operatingCountries String of contact countries that the contact operates in
     * @param exceptionArticleIds set of Id that are to be included in the search
     *
     * @return list of Knowledge__kav
     */
    public List<Knowledge__kav> selectByPublishStatusAndRecordTypeIdPersonaApi(Set<String> publishStatuses, Set<Id> recordTypeIds, String persona, String operatingCountries, Set<Id> exceptionArticleIds) {
        String query = 'RecordTypeId IN :recordTypeIds ' +
                'AND PublishStatus IN :publishStatuses ' +
                'AND ((OSB_Persona__c INCLUDES (:persona) ' +
                'AND OSB_Country__c INCLUDES (';

        for (String country : operatingCountries.split(';')) {
            query += '\'' + country + '\',';
        }
        query = query.removeEnd(',') + '))';
        query += ' OR Id IN :exceptionArticleIds)';
        return Database.query(
                newQueryFactory(false, false, true)
                .selectField('RecordType.DeveloperName')
                .selectField('Medium_Solution_Logo__c')
                .selectField('Large_Solution_Logo__c')
                .selectField('CreatedDate')
                .selectField('Categories__c')
                .setCondition(query)
                .removeOrderings()
                .addOrdering('Is_coming_soon__c', fflib_QueryFactory.SortOrder.ASCENDING)
                .addOrdering('CreatedDate', fflib_QueryFactory.SortOrder.DESCENDING)
                .toSOQL()
        );
    }
    
    /**
     * @description Select Knowledge__kav based on publishStatuses and recordTypeIds with RecordType.DeveloperName, knowledgeIds (already subscribed solutions), persona, operatingCountries and exceptionArticleIds(knowledge)
     *
     * @param publishStatuses set of searched PublishStatus picklist values
     * @param recordTypeIds set of searched record types' ids
     * @param knowledgeIds list of knowledge to exclude from the query
     * @param persona String of personas to be used to filter the results by (client,staff)
     * @param operatingCountries set of Id that are to be included in the search
     * @param exceptionArticleIds set of Id that are to be included in the search
     *
     * @return list of Knowledge__kav
     */
    public List<Knowledge__kav> selectByPublishStatusAndRecordTypeIdPersonaSolution(Set<String> publishStatuses, Set<Id> recordTypeIds, Set<Id> knowledgeIds, String persona, String operatingCountries, Set<Id> exceptionArticleIds) {
        String query = 'RecordTypeId IN :recordTypeIds ' +
                'AND PublishStatus IN :publishStatuses ' +
                'AND Id NOT IN :knowledgeIds ' +
                'AND ((OSB_Persona__c INCLUDES (:persona) ' +
                'AND OSB_Country__c INCLUDES (';

        for (String country : operatingCountries.split(';')) {
            query += '\'' + country + '\',';
        }
        query = query.removeEnd(',') + '))';
        query += ' OR Id IN :exceptionArticleIds)';
        return Database.query(
                newQueryFactory(false, false, true)
                .selectField('RecordType.DeveloperName')
                .selectField('Medium_Solution_Logo__c')
                .selectField('Large_Solution_Logo__c')
                .selectField('CreatedDate')
                .selectField('Categories__c')
                .selectField('Application_Owner__c')
                .setCondition(query)
                .removeOrderings()
                .addOrdering('Is_coming_soon__c', fflib_QueryFactory.SortOrder.ASCENDING)
                .addOrdering('CreatedDate', fflib_QueryFactory.SortOrder.DESCENDING)
                .toSOQL()
        );
    }

    /**
    * @description Select knowledge articles based on publishStatuses and recordTypeIds with RecordType.DeveloperName, knowledgeIds (already subscribed solutions), persona, operatingCountries, categories, and exceptionArticleIds(knowledge)
    *<br/>SFP-21025
    *
    * @param publishStatuses set of searched PublishStatus picklist values
    * @param recordTypeIds set of searched record types' ids
    * @param knowledgeIds list of knowledge to exclude from the query
    * @param persona String of personas to be used to filter the results by (client,staff)
    * @param operatingCountries set of Id that are to be included in the search
    * @param exceptionArticleIds set of Id that are to be included in the search
    * @param categoriesList  list String of categories
    * 
    * @return List of Knowledge_kav
    **/
    public List<Knowledge__kav> selectByPublishStatusAndRecordTypeIdAndCategoryPersonaSolution(Set<String> publishStatuses, Set<Id> recordTypeIds, Set<Id> knowledgeIds, String persona, String operatingCountries, Set<Id> exceptionArticleIds, String categoriesList) {
        string query= 'RecordTypeId IN :recordTypeIds ' +
                'AND PublishStatus IN :publishStatuses ' +
                'AND Id NOT IN :knowledgeIds ' +
                'AND ((OSB_Persona__c INCLUDES (:persona) ' +
                'AND (Categories__c INCLUDES (';
        
        for (String category : categoriesList.split(',')) {
            query += '\'' + category + '\',';
        }
        
        query = query.removeEnd(',') + '))';
        query += 'AND OSB_Country__c INCLUDES (';



        for (String country : operatingCountries.split(';')) {
            query += '\'' + country + '\',';
        }
        query = query.removeEnd(',') + '))';
        query += ' OR Id IN :exceptionArticleIds)';
        
        return Database.query(
                newQueryFactory(false, false, true)
                .selectField('RecordType.DeveloperName')
                .selectField('Medium_Solution_Logo__c')
                .selectField('Large_Solution_Logo__c')
                .selectField('CreatedDate')
                .selectField('Categories__c')
                .selectField('Application_Owner__c')
                .setCondition(query)
                .removeOrderings()
                .addOrdering('Is_coming_soon__c', fflib_QueryFactory.SortOrder.ASCENDING)
                .addOrdering('CreatedDate', fflib_QueryFactory.SortOrder.DESCENDING)
                .toSOQL()
        );
    }

    /**
     * @description Select Knowledge__kav based on PublishStatus and RecordTypeId with RecordType.DeveloperName
     * @author Rajesh Yandrathi
     * @date March 2021
     * 
     * @param knowledgeArticlesMap Map of PublishStatus,RecordType,KnowledgeIds,Persona,OpertingCountries and ExceptionArticles
     *
     * @return list of Knowledge__kav
     */
    public List<Knowledge__kav> selectByPublishStatusAndRecordTypewithSearchIDs(Map<String,Object> knowledgeArticlesMap){
        
        Set<String> publishStatuses = (Set<String>)knowledgeArticlesMap.get('publishStatuses');
        Set<Id> recordTypeIds = (Set<Id>)knowledgeArticlesMap.get('recordTypeIds');
        Set<Id> knowledgeIds = (Set<Id>)knowledgeArticlesMap.get('knowledgeIds');
        String persona = String.valueof(knowledgeArticlesMap.get('persona'));
        String operatingCountries = String.valueof(knowledgeArticlesMap.get('operatingCountries'));
        Set<Id> exceptionArticleIds = (Set<Id>)knowledgeArticlesMap.get('exceptionArticleIds');
        
        String query = 'RecordTypeId IN :recordTypeIds ' +
                'AND PublishStatus IN :publishStatuses ' +
                'AND Id IN :knowledgeIds ' +
                'AND ((OSB_Persona__c INCLUDES (:persona) ' +
                'AND OSB_Country__c INCLUDES (';

        for (String country : operatingCountries.split(';')) {
            query += '\'' + country + '\',';
        }
        query = query.removeEnd(',') + '))';
        query += ' OR Id IN :exceptionArticleIds)';
        return Database.query(
                newQueryFactory(false, false, true)
                .selectField('RecordType.DeveloperName')
                .selectField('Medium_Solution_Logo__c')
                .selectField('Large_Solution_Logo__c')
                .selectField('Categories__c')               
                .selectField('CreatedDate')
                .setCondition(query)
                .removeOrderings()
                .addOrdering('Is_coming_soon__c', fflib_QueryFactory.SortOrder.ASCENDING)
                .addOrdering('CreatedDate', fflib_QueryFactory.SortOrder.DESCENDING)
                .toSOQL()
        );
    }

    /**
    * @description Select Knowledge__kav based on the knowledgeArticlesMap which contains the KnowledgeArticle IDs, recordTypeIds, Categories and persona.
    *<br/>SFP-21025
    *
    * @param knowledgeArticlesMap Map of PublishStatus,RecordType,KnowledgeIds,Persona,OpertingCountries and ExceptionArticles
    * 
    * @return List of Knowledge_kav
    **/
    public List<Knowledge__kav> selectByPublishStatusAndRecordTypewithSearchIDswithCategory(Map<String,Object> knowledgeArticlesMap){
        Set<String> publishStatuses = (Set<String>)knowledgeArticlesMap.get('publishStatuses');
        Set<Id> recordTypeIds = (Set<Id>)knowledgeArticlesMap.get('recordTypeIds');
        Set<Id> knowledgeIds = (Set<Id>)knowledgeArticlesMap.get('knowledgeIds');
        String persona = String.valueof(knowledgeArticlesMap.get('persona'));
        String operatingCountries = String.valueof(knowledgeArticlesMap.get('operatingCountries'));
        Set<Id> exceptionArticleIds = (Set<Id>)knowledgeArticlesMap.get('exceptionArticleIds');
        String categories = String.valueOf(knowledgeArticlesMap.get('categories'));

        string query= 'RecordTypeId IN :recordTypeIds ' +
        'AND PublishStatus IN :publishStatuses ' +
        'AND Id IN :knowledgeIds ' +
        'AND ((OSB_Persona__c INCLUDES (:persona) ' +
        'AND (Categories__c INCLUDES (';

        for (String category : categories.split(',')) {
        query += '\'' + category + '\',';
        }

        query = query.removeEnd(',') + '))';
        query += 'AND OSB_Country__c INCLUDES (';


        for (String country : operatingCountries.split(';')) {
            query += '\'' + country + '\',';
        }

        query = query.removeEnd(',') + '))';
        query += ' OR Id IN :exceptionArticleIds)';
        return Database.query(
                newQueryFactory(false, false, true)
                .selectField('RecordType.DeveloperName')
                .selectField('Medium_Solution_Logo__c')
                .selectField('Large_Solution_Logo__c')
                .selectField('Categories__c')               
                .selectField('CreatedDate')
                .setCondition(query)
                .removeOrderings()
                .addOrdering('Is_coming_soon__c', fflib_QueryFactory.SortOrder.ASCENDING)
                .addOrdering('CreatedDate', fflib_QueryFactory.SortOrder.DESCENDING)
                .toSOQL()
        );
    }

    /**
     * @description Calls method selectByPublishStatusAndRecordTypewithSearchIDs in without sharing context, 'WoSharing' stands for 'Without Sharing'
     * @author Rajesh Yandrathi
     * @date March 2021
     * 
     * @param knowledgeArticlesMap Map of PublishStatus,RecordType,KnowledgeIds,Persona,OpertingCountries and ExceptionArticles
     * @return list of Knowledge__kav
     */
    public List<Knowledge__kav> selectByPublishStatusAndRecordTypewithSearchIDsWoSharing(Map<String,Object> knowledgeArticlesMap) {
        return new WithoutSharing().selectByPublishStatusAndRecordTypewithSearchIDs(this,knowledgeArticlesMap);
    }

    /**
     * @description Calls method selectByPublishStatusAndRecordTypewithSearchIDswithCategory in without sharing context, 'WoSharing' stands for 'Without Sharing'
    *<br/>SFP-21025
    * 
    * @param knowledgeArticlesMap Map of PublishStatus,RecordType,KnowledgeIds,Persona,OpertingCountries and ExceptionArticles
    * 
    * @return List of Knowledge_kav
    **/
    public List<Knowledge__kav> selectByCategoryAndPublishStatusAndRecordTypewithSearchIDsWoSharing(Map<String,Object> knowledgeArticlesMap) {
        return new WithoutSharing().selectByPublishStatusAndRecordTypewithSearchIDswithCategory(this,knowledgeArticlesMap);
    }

    /**
     * @description Select Knowledge__kav based on PublishStatus and RecordTypeId with RecordType.DeveloperName and Large_Solution_Logo__c
     *
     * @param publishStatuses set of searched PublishStatus picklist values
     * @param recordTypesIds set of searched record types' ids
     * @param knowledgeExceptions set of Id that are to be included in the search
     * @param persona String of personas to be used to filter the results by (client,staff)
     * @return list of Knowledge__kav
     */
    public List<Knowledge__kav> selectByPublishStatusAndRecordTypeIdWithLogoPersona(Set<String> publishStatuses, Set<Id> recordTypesIds, Set<Id> knowledgeExceptions, String persona) {
        return Database.query(
                newQueryFactory(false, false, true)
                        .selectField('RecordType.DeveloperName')
                        .selectField('Large_Solution_Logo__c')
                        .setCondition('((PublishStatus IN :publishStatuses AND RecordTypeId IN :recordTypesIds AND OSB_Persona__c INCLUDES (:persona)) OR Id IN :knowledgeExceptions)')
                        .removeOrderings()
                        .addOrdering('CreatedDate', fflib_QueryFactory.SortOrder.ASCENDING)
                        .toSOQL()
        );
    }

    /**
     * @description Select Knowledge__kav based on PublishStatus and RecordTypeId with RecordType.DeveloperName
     *
     * @param contactIds set of userIds
     * @param recordTypesIds set of record type Ids
     * @return list of Knowledge__kav
     */
    public List<Knowledge__kav> selectBySubscribedSolutionForUser(Set<Id> contactIds, Set<Id> recordTypesIds) {
        return Database.query(
                newQueryFactory(false, false, true)
                .selectField('CreatedDate')
                .selectField('Large_Solution_Logo__c')
                .setCondition('Id IN (SELECT Solution__c FROM Subscribed_Solutions__c WHERE Contact__c IN :contactIds AND RecordTypeId IN :recordTypesIds)')
                .addOrdering('CreatedDate', fflib_QueryFactory.SortOrder.DESCENDING)
                .toSOQL()
        );
    }

    /**
     * @description Calls method selectByPublishStatusAndRecordTypeIdPersonaSolution in without sharing context, 'WoSharing' stands for 'Without Sharing'
     *
     * @param publishStatuses set of searched PublishStatus picklist values
     * @param recordTypeIds set of searched record types' ids
     * @param knowledgeIds list of knowledge to exclude from the query
     * @param persona String of personas to be used to filter the results by (client,staff)
     * @param operatingCountries set of Id that are to be included in the search
     * @param exceptionArticleIds set of Id that are to be included in the search
     *
     * @return list of Knowledge__kav
     */
    public List<Knowledge__kav> selectByPublishStatusAndRecordTypeIdPersonaSolutionWoSharing(Set<String> publishStatuses, Set<Id> recordTypeIds, Set<Id> knowledgeIds, String persona, String operatingCountries, Set<Id> exceptionArticleIds) {
        return new WithoutSharing().selectByPublishStatusAndRecordTypeIdPersonaSolution(this, publishStatuses, recordTypeIds, knowledgeIds,persona,operatingCountries,exceptionArticleIds);
    }

    /**
    * @description Calls method selectByPublishStatusAndRecordTypeIdAndCategoryPersonaSolution in without sharing context, 'WoSharing' stands for 'Without Sharing'
    *<br/>SFP-21025
    *
    * @param publishStatuses set of searched PublishStatus picklist values
    * @param recordTypeIds set of searched record types' ids
    * @param knowledgeIds list of knowledge to exclude from the query
    * @param persona String of personas to be used to filter the results by (client,staff)
    * @param operatingCountries set of Id that are to be included in the search
    * @param exceptionArticleIds set of Id that are to be included in the search
    * @param categoriesList list of string of categories
    * 
    * @return List of Knowledge_kav
    **/
    public List<Knowledge__kav> selectByPublishStatusAndRecordTypeIdPersonaAndCategorySolutionWoSharing(Set<String> publishStatuses, Set<Id> recordTypeIds, Set<Id> knowledgeIds, String persona, String operatingCountries, Set<Id> exceptionArticleIds, String categoriesList) {
        return new WithoutSharing().selectByPublishStatusAndRecordTypeIdAndCategoryPersonaSolution(this, publishStatuses, recordTypeIds, knowledgeIds,persona,operatingCountries,exceptionArticleIds, categoriesList);
    }
    
    /**
     * @description Calls method selectByPublishStatusAndRecordTypeIdPersonaApi in without sharing context, 'WoSharing' stands for 'Without Sharing'
     *
     * @param publishStatuses set of searched PublishStatus picklist values
     * @param recordTypeIds set of searched record types' ids
     * @param persona String of personas to be used to filter the results by (client,staff)
     * @param operatingCountries String of contact countries that the contact operates in
     * @param exceptionArticleIds set of Id that are to be included in the search
     *
     * @return list of Knowledge__kav
     */
    public List<Knowledge__kav> selectByPublishStatusAndRecordTypeIdPersonaApiWoSharing(Set<String> publishStatuses, Set<Id> recordTypeIds, String persona, String operatingCountries, Set<Id> exceptionArticleIds) {
        return new WithoutSharing().selectByPublishStatusAndRecordTypeIdPersonaApi(this, publishStatuses, recordTypeIds, persona,operatingCountries,exceptionArticleIds);
    }

    /**
     * @description Calls method selectByPublishStatusAndRecordTypeId in without sharing context, 'WoSharing' stands for 'Without Sharing'
     *
     * @param publishStatuses set of searched PublishStatus picklist values
     * @param recordTypesIds set of searched record types' ids
     * @param knowledgeIds list of knowledge to exclude from the query
     *
     * @return list of Knowledge__kav
     */
    public List<Knowledge__kav> selectByPublishStatusAndRecordTypeIdWoSharing(Set<String> publishStatuses, Set<Id> recordTypesIds, Set<Id> knowledgeIds) {
        return new WithoutSharing().selectByPublishStatusAndRecordTypeId(this, publishStatuses, recordTypesIds, knowledgeIds);
    }

    /**
     * @description Calls method selectByPublishStatusIdAndRecordTypeId in without sharing context, 'WoSharing' stands for 'Without Sharing'
     *
     * @param publishStatuses set of searched PublishStatus picklist values
     * @param knowledgeIds set of searched Knowledge__kav ids
     * @param recordTypesIds set of searched record types' ids
     *
     * @return list of Knowledge__kav
     */
    public List<Knowledge__kav> selectByPublishStatusIdAndRecordTypeIdWoSharing(Set<String> publishStatuses, Set<Id> knowledgeIds,  Set<Id> recordTypesIds) {
        return new WithoutSharing().selectByPublishStatusIdAndRecordTypeId(this, publishStatuses, knowledgeIds, recordTypesIds);
    }

    /**
     * @description Calls method selectByPublishStatusAndRecordTypeIdWithLogo in without sharing context
     *
     * @param publishStatuses set of searched PublishStatus picklist values
     * @param recordTypesIds set of searched record types' ids
     * @param knowledgeExceptions set of Id that are to be included in the search
     * @param persona String of personas to be used to filter the results by (client,staff)
     * @return list of Knowledge__kav
     */
    public List<Knowledge__kav> selectByPublishStatusAndRecordTypeIdWithLogoPersonaWoSharing(Set<String> publishStatuses, Set<Id> recordTypesIds, Set<Id> knowledgeExceptions, String persona) {
        return new WithoutSharing().selectByPublishStatusAndRecordTypeIdWithLogoPersona(this, publishStatuses, recordTypesIds, knowledgeExceptions, persona);
    }

    /**
     * @description Calls method selectBySubscribedSolutionForUser in without sharing context, 'WoSharing' stands for 'Without Sharing'
     *
     * @param contactIds set of contactId
     * @param recordTypesIds set of record type Ids
     *
     * @return list of Knowledge__kav
     */
    public List<Knowledge__kav> selectBySubscribedSolutionForUserWoSharing(Set<Id> contactIds, Set<Id> recordTypesIds) {
        return new WithoutSharing().selectBySubscribedSolutionForUser(this, contactIds, recordTypesIds);
    }
    
    /**
     * @description Calls method selectByPublishStatusAndTitle in without sharing context, 'WoSharing' stands for 'Without Sharing'
     *
     * @param publishStatuses set of searched PublishStatus picklist values
     * @param knowledgeTitles set of knowledge title
     *
     * @return list of Knowledge__kav
     */
    public List<Knowledge__kav> selectByPublishStatusAndTitleWoSharing(Set<String> publishStatuses, Set<String> knowledgeTitles) {
        return new WithoutSharing().selectByPublishStatusAndTitle(this, publishStatuses,knowledgeTitles);
    }

     /**    
     * @description Select Knowledge__kav based on PublishStatues and Provider_Knowledge_Article__c
     * @UserStory SFP-20792
     * @param publishStatuses set of searched PublishStatus picklist values
     * @param recordTypesIds Set of record type IDs
     * @param providerIds set of provider Ids
     * @param persona String of personas to be used to filter the results by (client,staff)
     * @param operatingCountries String of operating countries of user to filter solutions by country.
     * 
     * @return list of Knowledge__kav
     */
    public List<Knowledge__kav> selectArticleByPublishStatusAndProvider(Set<String> publishStatuses, Set<Id> recordTypeIds, Set<Id> providerIds, String persona, String operatingCountries ) {
       
       
        string query= 'PublishStatus IN :publishStatuses ' +
        'AND RecordTypeId IN :recordTypeIds ' +
        'AND Provider_Knowledge_Article__c IN :providerIds ' +
        'AND OSB_Persona__c INCLUDES (:persona) ' + 
        'AND OSB_Country__c INCLUDES (';

        for (String country : operatingCountries.split(';')) {
            query += '\'' + country + '\',';
        }

        query = query.removeEnd(',') + ')';
        return Database.query(
            newQueryFactory(false, false, true)        
            .selectField('Id')
            .selectField('RecordType.DeveloperName')
            .selectField('Title')
            .selectField('Summary')
            .selectField('UrlName')
            .selectField('Info__c')
            .selectField('Image__c')
            .selectField('Categories__c')
            .selectfield('OSB_Persona__c')
            .selectfield('OSB_Country__c')
            .selectField('Provider_Knowledge_Article__c')
            .selectField('LastPublishedDate')
            .setCondition(query)
            .toSOQL()
        );        
        
    }

    /**
     * @description Select Knowledge__kav  ids WHICH ARE PROVIDER SPACES
     * @UserStory SFP-20792
     * @param publishStatuses set of searched PublishStatus picklist values
     * @param providerIds set of Solution Provider Ids
     * 
     * @return list of Knowledge__kav
     */
    public List<Knowledge__kav> selectArticleByProviderId(Set<String> publishStatuses, Set<Id> providerIds) {
            
        fflib_QueryFactory articleQueryFactory = newQueryFactory(false, false, true);
       
        articleQueryFactory
            .selectField('Id')
            .selectField('RecordType.DeveloperName')
            .selectField('Title')
            .selectField('Summary')
            .selectField('UrlName')
            .selectField('Info__c')
            .selectField('Image__c')
            .selectField('Introduction__c')
            .selectField('Application_Owner__c')
            .selectField('Featured__c')
            .selectField('Is_coming_soon__c')
            .selectField('Categories__c')
            .selectField('Medium_Solution_Logo__c')
            .selectField('Large_Solution_Logo__c')
            .selectField('Provider_Knowledge_Article__c')
            .selectField('LastPublishedDate')         
            .setCondition('PublishStatus IN :publishStatuses  AND Id IN :providerIds')
      
            .removeOrderings();
                
        return Database.query(articleQueryFactory.toSOQL());
    }
    /**
     * @description Is used for omitting sharing setting, when needed
     */
    private without sharing class WithoutSharing {

        /**
        * @description
        * @param selKnowledge set of knowledge Article Versions
        * @param publishStatuses set of searched PublishStatus picklist values
        * @param knowledgeTitles set of knowledge title
        *
        * @return list of Knowledge__kav
        */
        public List<Knowledge__kav> selectByPublishStatusAndTitle(SEL_KnowledgeArticleVersions selKnowledge, Set<String> publishStatuses, Set<String> knowledgeTitles) {
            return selKnowledge.selectByPublishStatusAndTitle(publishStatuses, knowledgeTitles);
        }
        
        /**
        * @description
        * @param selKnowledge set of knowledge Article Versions
        * @param publishStatuses set of searched PublishStatus picklist values
        * @param recordTypesIds set of searched record types' ids
        * @param knowledgeIds list of knowledge include in the query
        * @return list of Knowledge__kav
        */
        public List<Knowledge__kav> selectByPublishStatusAndRecordTypeId(SEL_KnowledgeArticleVersions selKnowledge, Set<String> publishStatuses, Set<Id> recordTypesIds, Set<Id> knowledgeIds) {
            return selKnowledge.selectByPublishStatusAndRecordTypeId(publishStatuses, recordTypesIds, knowledgeIds);
        }

        /**
        * @description
        * @param selKnowledge set of knowledge Article Versions
        * @param publishStatuses set of searched PublishStatus picklist values
        * @param knowledgeIds list of knowledge include in the query
        * @param recordTypesIds set of searched record types' ids
        * @return list of Knowledge__kav
        */
        public List<Knowledge__kav> selectByPublishStatusIdAndRecordTypeId(SEL_KnowledgeArticleVersions selKnowledge, Set<String> publishStatuses, Set<Id> knowledgeIds, Set<Id> recordTypesIds) {
            return selKnowledge.selectByPublishStatusIdAndRecordTypeId(publishStatuses, knowledgeIds, recordTypesIds);
        }

        /**
        * @description
        * @param selKnowledge set of knowledge Article Versions
        * @param contactIds set of userIds
        * @param recordTypesIds set of record type Ids
        * @return list of Knowledge__kav
        */
        public List<Knowledge__kav> selectBySubscribedSolutionForUser(SEL_KnowledgeArticleVersions selKnowledge, Set<Id> contactIds, Set<Id> recordTypesIds) {
            return selKnowledge.selectBySubscribedSolutionForUser(contactIds, recordTypesIds);
        }

        /**
        * @description
        * @param selKnowledge set of knowledge Article Versions
        * @param publishStatuses set of searched PublishStatus picklist values
        * @param recordTypesIds set of searched record types' ids
        * @param knowledgeExceptions list of knowledge include in the query
        * @param persona String of personas to be used to filter the results by (client,staff)
        * @return list of Knowledge__kav
        */
        public List<Knowledge__kav> selectByPublishStatusAndRecordTypeIdWithLogoPersona(SEL_KnowledgeArticleVersions selKnowledge, Set<String> publishStatuses, Set<Id> recordTypesIds, Set<Id> knowledgeExceptions, String persona) {
            return selKnowledge.selectByPublishStatusAndRecordTypeIdWithLogoPersona(publishStatuses, recordTypesIds, knowledgeExceptions,persona);
        }

        /**
        * @description
        * @param selKnowledge set of knowledge Article Versions
        * @param publishStatuses set of searched PublishStatus picklist values
        * @param recordTypeIds set of searched record types' ids
        * @param knowledgeIds list of knowledge include in the query
        * @param persona String of personas to be used to filter the results by (client,staff)
        * @param operatingCountries set of Id that are to be included in the search
        * @param exceptionArticleIds set of Id that are to be included in the search 
        * @return list of Knowledge__kav
        */
        public List<Knowledge__kav> selectByPublishStatusAndRecordTypeIdPersonaSolution(SEL_KnowledgeArticleVersions selKnowledge, Set<String> publishStatuses, Set<Id> recordTypeIds, Set<Id> knowledgeIds, String persona, String operatingCountries, Set<Id> exceptionArticleIds) {
            return selKnowledge.selectByPublishStatusAndRecordTypeIdPersonaSolution(publishStatuses, recordTypeIds,knowledgeIds,persona,operatingCountries,exceptionArticleIds);
        }

        /**
        * @description Calls method selectByPublishStatusAndRecordTypeIdAndCategoryPersonaSolution in without sharing context
        *<br/>SFP-21025
        *
        * @param selKnowledge SEL_KnowledgeArticleVersions
        * @param publishStatuses set of searched PublishStatus picklist values
        * @param recordTypeIds set of searched record types' ids
        * @param knowledgeIds list of knowledge to exclude from the query
        * @param persona String of personas to be used to filter the results by (client,staff)
        * @param operatingCountries set of Id that are to be included in the search
        * @param exceptionArticleIds set of Id that are to be included in the search
        * @param categoriesList String of categories
        * 
        * @return List of Knowledge_kav
        **/
        public List<Knowledge__kav> selectByPublishStatusAndRecordTypeIdAndCategoryPersonaSolution(SEL_KnowledgeArticleVersions selKnowledge, Set<String> publishStatuses, Set<Id> recordTypeIds, Set<Id> knowledgeIds, String persona, String operatingCountries, Set<Id> exceptionArticleIds, String categoriesList) {
            return selKnowledge.selectByPublishStatusAndRecordTypeIdAndCategoryPersonaSolution(publishStatuses, recordTypeIds,knowledgeIds,persona,operatingCountries,exceptionArticleIds, categoriesList);
        }
        
        /**
        * @description
        * @param selKnowledge set of knowledge Article Versions
        * @param publishStatuses set of searched PublishStatus picklist values
        * @param recordTypeIds set of searched record types' ids
        * @param persona String of personas to be used to filter the results by (client,staff)
        * @param operatingCountries set of Id that are to be included in the search
        * @param exceptionArticleIds set of Id that are to be included in the search 
        * @return list of Knowledge__kav
        */
        public List<Knowledge__kav> selectByPublishStatusAndRecordTypeIdPersonaApi(SEL_KnowledgeArticleVersions selKnowledge, Set<String> publishStatuses, Set<Id> recordTypeIds, String persona, String operatingCountries, Set<Id> exceptionArticleIds) {
            return selKnowledge.selectByPublishStatusAndRecordTypeIdPersonaApi(publishStatuses, recordTypeIds,persona,operatingCountries,exceptionArticleIds);
        }

        /**
        * @description
        * @param selKnowledge set of knowledge Article Versions 
        * @param knowledgeArticlesMap Map of PublishStatus,RecordType,KnowledgeIds,Persona,OpertingCountries and ExceptionArticles
        * @return list of Knowledge__kav
        */
        public List<Knowledge__kav> selectByPublishStatusAndRecordTypewithSearchIDs(SEL_KnowledgeArticleVersions selKnowledge, Map<String,Object> knowledgeArticlesMap) {
            return selKnowledge.selectByPublishStatusAndRecordTypewithSearchIDs(knowledgeArticlesMap);
        }

        /**
        * @description Calls method selectByPublishStatusAndRecordTypewithSearchIDswithCategory in without sharing context
        *<br/>SFP-21025
        *
        * @param selKnowledge set of knowledge Article Versions 
        * @param knowledgeArticlesMap Map of PublishStatus,RecordType,KnowledgeIds,Persona,OpertingCountries and ExceptionArticles
        * 
        * @return List of Knowledge_kav
        **/
        public List<Knowledge__kav> selectByPublishStatusAndRecordTypewithSearchIDswithCategory(SEL_KnowledgeArticleVersions selKnowledge, Map<String,Object> knowledgeArticlesMap) {
            return selKnowledge.selectByPublishStatusAndRecordTypewithSearchIDswithCategory(knowledgeArticlesMap);
        }	

    }

}