/**
* @description OSB_SolutionShowcase_CTRL class for Subscribed Solution records
*
* @author Wayde Fagan (Wayde.fagan@tetrad.co.za)
* @date October 2020
*
*
* @LastModified March 2023
* @author Milica Milicevic (milica.milicevic@standardbank.co.za)
* @UserStory SFP-21025
* @LastModifiedReason Add two methods to allow for retrieving solutions according to categories provided
*
* @LastModified May 2023
* @author Milica Milicevic (milica.milicevic@standardbank.co.za)
* @UserStory SFP-28081
* @LastModifiedReason Update to retrieve subscribed solutions based on contact ID instead of user ID
*
* @LastModified May 2023
* @author Milica Milicevic (milica.milicevic@standardbank.co.za)
* @UserStory SFP-21026
* @LastModifiedReason Update getRegisteredApplication to accomodate for new record types and variables
*
* @LastModified October 2023
* @author Nkosi Ncube (nkosi.ncube@standardbank.co.za)
* @UserStory SFP-20792
* @LastModifiedReason Add two methods to allow for retrieving solutions related to a provider space via a lookup field/Provider Id
*
* @LastModified October 2023
* @author Eldrin Shikwambana (Eldrin.Shikwambana@standardbank.co.za)
* @UserStory SFP-29736
* @LastModifiedReason Adding getSolutions that allows the retrieval of all solutions the user is able to access.
*
* @LastModified February 2024
* @author Milica Milicevic (milica.milicevic@standardbank.co.za)
* @UserStory SFP-36216
* @LastModifiedReason Update to getSolutionSearchResults and getSolutionSearchResultsWithCategory to only allow for search input of two characters.
*
*/
public without sharing class OSB_SolutionShowcase_CTRL {
    
    private static final sbgplatform.rflib_Logger LOGGER = sbgplatform.rflib_LoggerUtil.getFactory().createLogger('OSB_SolutionShowcase_CTRL');
    public static final String RT_APPLICATION = 'Subscribed_Applications';
    public static final String SUBSCRIBED_SOLUTION_OBJ_NAME = 'Subscribed_Solutions__c';
    
    /**
    * @description Returns a list of knowledge articles for the available Solutions
    *
    * @param userId String of user ID
    * 
    * @return List of Knowledge_kav
    **/
    @AuraEnabled(cacheable=true)
    public static List<Knowledge__kav> getSolutionShowcase(Id userId) {
        List<Knowledge__kav> articles;
        try {
            Contact con = SEL_Contacts.newInstance().selectByUserId(new Set<Id>{userId})[0];
            Set<Id> exceptionArticleIds = new Set<Id>();
            Set<Id> registeredKnowledgeIds = (new Map<Id,SObject>(getRegisteredApplication(con.Id))).keySet();
            for(Knowledge_Entitlement_Exception__c entitlementException : SEL_KnowledgeExceptions.newInstance().selectByContactIdWoSharing(new Set<Id>{con.Id})) {
                exceptionArticleIds.add(entitlementException.OSB_Knowledge_Article__c);
            }
            articles = SEL_KnowledgeArticleVersions.newInstance().selectByPublishStatusAndRecordTypeIdPersonaSolutionWoSharing(
                new Set<String>{DMN_Knowledge.PUBLISH_STATUS_ONLINE},
                new Set<Id>{UTL_RecordType.getRecordTypeId(DMN_Knowledge.OBJ_NAME, DMN_Knowledge.RT_SOLUTION)},
                new Set<Id>(registeredKnowledgeIds),
                con.OSB_Persona__c,
                con.OSB_Operating_Country__c,
                exceptionArticleIds
            );
        } catch(Exception e) {
            LOGGER.error('OSB_SolutionShowcase_CTRL : getSolutionShowcase  Retrieveing solutions Exception logged: ',e);
            OSB_SRV_ActionFailureHandler.newInstance().handleError(e, OSB_SolutionShowcase_CTRL.class.getName());
        }
        
        return articles;
    }

    /**
    * @description Returns a list of knowledge articles of the available solutions according to the categories provided
    *<br/>SFP-21025
    *
    * @param userId String of user ID
    * @param categories String of categories
    * 
    * @return List of Knowledge_kav
    **/
    @AuraEnabled(cacheable=true)
    public static List<Knowledge__kav> getSolutionShowcaseWithCategory(Id userId, string categories) {
        List<Knowledge__kav> articles;
        try {
            Contact con = SEL_Contacts.newInstance().selectByUserId(new Set<Id>{userId})[0];
            Set<Id> exceptionArticleIds = new Set<Id>();
            Set<Id> registeredKnowledgeIds = (new Map<Id,SObject>(getRegisteredApplication(con.Id))).keySet();
            for(Knowledge_Entitlement_Exception__c entitlementException : SEL_KnowledgeExceptions.newInstance().selectByContactIdWoSharing(new Set<Id>{con.Id})) {
                exceptionArticleIds.add(entitlementException.OSB_Knowledge_Article__c);
            }
            if(String.isBlank(categories)){
                articles = SEL_KnowledgeArticleVersions.newInstance().selectByPublishStatusAndRecordTypeIdPersonaSolutionWoSharing(
                    new Set<String>{DMN_Knowledge.PUBLISH_STATUS_ONLINE},
                    new Set<Id>{UTL_RecordType.getRecordTypeId(DMN_Knowledge.OBJ_NAME, DMN_Knowledge.RT_SOLUTION)},
                    new Set<Id>(registeredKnowledgeIds),
                    con.OSB_Persona__c,
                    con.OSB_Operating_Country__c,
                    exceptionArticleIds
                );
            }else{
                articles = SEL_KnowledgeArticleVersions.newInstance().selectByPublishStatusAndRecordTypeIdPersonaAndCategorySolutionWoSharing(
                    new Set<String>{DMN_Knowledge.PUBLISH_STATUS_ONLINE},
                    new Set<Id>{UTL_RecordType.getRecordTypeId(DMN_Knowledge.OBJ_NAME, DMN_Knowledge.RT_SOLUTION)},
                    new Set<Id>(registeredKnowledgeIds),
                    con.OSB_Persona__c,
                    con.OSB_Operating_Country__c,
                    exceptionArticleIds,
                    categories
                );
            }

        } catch(Exception e) {
            LOGGER.error('OSB_SolutionShowcase_CTRL : getSolutionShowcaseWithCategory  Retrieveing solutions Exception logged: ',e);
            OSB_SRV_ActionFailureHandler.newInstance().handleError(e, OSB_SolutionShowcase_CTRL.class.getName());
        }

        return articles;
    }
    
    /**
    * @description Gets a list of solutions that a user is subscribed to
    *
    * @param contactId String of user Id
    * 
    * @return List<Knowledge__kav> register applications
    **/
    @AuraEnabled(Cacheable=false)
    public static List<Knowledge__kav> getRegisteredApplication(String contactId) {
        return SEL_KnowledgeArticleVersions.newInstance().selectBySubscribedSolutionForUserWoSharing(
            new Set<Id>{contactId},
            new Set<Id>{UTL_RecordType.getRecordTypeId(SUBSCRIBED_SOLUTION_OBJ_NAME, RT_APPLICATION)}
        );
        
    }
    
    /**
    * @description Returns a list of knowledge articles based on Search criteria for Solutions
    *
    * @author Rajesh Yandrathi
    * @date March 2021
    * @param userId String of user ID
    * @param searchKeyword String to Search
    * @return List of Knowledge_kav
    **/
    @AuraEnabled(Cacheable=true)
    public static List<Knowledge__kav> getSolutionSearchResults(Id userId,String searchKeyword) {
    
        List<Knowledge__kav> articles;
        Map<String,Object> knowledgeArticlesMap = new Map<String,Object>{};
            try {
                if(searchKeyword.length() >= 2){  
                    Contact con = SEL_Contacts.newInstance().selectByUserId(new Set<Id>{userId})[0];
                    Set<Id> exceptionArticleIds = new Set<Id>();
                    String searchString = '*' + searchKeyword + '*';
                    List<List<Knowledge__kav>> knowledgeSearch = [Find :searchString IN ALL FIELDS RETURNING  Knowledge__kav(Title,Introduction__c)];
                    Knowledge__kav [] knowledgeSearchList = ((List<Knowledge__kav>)knowledgeSearch[0]);
                    Set<Id> knowledgeSearchResults = (new Map<Id,SObject>(knowledgeSearchList)).keySet();
    
                    for(Knowledge_Entitlement_Exception__c entitlementException : SEL_KnowledgeExceptions.newInstance().selectByContactIdWoSharing(new Set<Id>{con.Id})) {
                        exceptionArticleIds.add(entitlementException.OSB_Knowledge_Article__c);
                    }
                    Set<String> publishStatuses = new Set<String>{DMN_Knowledge.PUBLISH_STATUS_ONLINE};
                        Set<Id> recordTypeIds = new Set<Id>{UTL_RecordType.getRecordTypeId(DMN_Knowledge.OBJ_NAME, DMN_Knowledge.RT_SOLUTION)};
                            knowledgeArticlesMap.put('publishStatuses',publishStatuses);
                    knowledgeArticlesMap.put('recordTypeIds',recordTypeIds);
                    knowledgeArticlesMap.put('knowledgeIds',knowledgeSearchResults);
                    knowledgeArticlesMap.put('persona',con.OSB_Persona__c);
                    knowledgeArticlesMap.put('operatingCountries',con.OSB_Operating_Country__c);
                    knowledgeArticlesMap.put('exceptionArticleIds',exceptionArticleIds);
                    
                    articles = SEL_KnowledgeArticleVersions.newInstance().selectByPublishStatusAndRecordTypewithSearchIDsWoSharing(
                        knowledgeArticlesMap
                    );
                }
            } catch(Exception e) {
               LOGGER.error('OSB_SolutionShowcase_CTRL : getSolutionSearchResults  Retrieveing searched solutions Exception logged: ',e);
               OSB_SRV_ActionFailureHandler.newInstance().handleError(e, OSB_SolutionShowcase_CTRL.class.getName());
            }

        return articles;
    }

    /**
    * @description Returns a list of knowledge articles of the available solutions according to the search criteria and categories provided
    *<br/>SFP-21025
    *
    * @param userId String of user ID
    * @param searchKeyword String of search keyword
    * @param categories String of categories
    * 
    * @return List of Knowledge_kav
    **/
    @AuraEnabled(Cacheable=true)
    public static List<Knowledge__kav> getSolutionSearchResultsWithCategory(Id userId,String searchKeyword, String categories) {
        List<Knowledge__kav> articles;
        Map<String,Object> knowledgeArticlesMap = new Map<String,Object>{};
            try {
                if(searchKeyword.length() >= 2){                
                    Contact con = SEL_Contacts.newInstance().selectByUserId(new Set<Id>{userId})[0];
                    Set<Id> exceptionArticleIds = new Set<Id>();
                    String searchString = '*' + searchKeyword + '*';
                    List<List<Knowledge__kav>> knowledgeSearch = [Find :searchString IN ALL FIELDS RETURNING  Knowledge__kav(Title,Introduction__c)];

                    Knowledge__kav [] knowledgeSearchList = ((List<Knowledge__kav>)knowledgeSearch[0]);
                    Set<Id> knowledgeSearchResults = (new Map<Id,SObject>(knowledgeSearchList)).keySet();
                    for(Knowledge_Entitlement_Exception__c entitlementException : SEL_KnowledgeExceptions.newInstance().selectByContactIdWoSharing(new Set<Id>{con.Id})) {
                        exceptionArticleIds.add(entitlementException.OSB_Knowledge_Article__c);
                    }
                    Set<String> publishStatuses = new Set<String>{DMN_Knowledge.PUBLISH_STATUS_ONLINE};
                    Set<Id> recordTypeIds = new Set<Id>{UTL_RecordType.getRecordTypeId(DMN_Knowledge.OBJ_NAME, DMN_Knowledge.RT_SOLUTION)};
                        knowledgeArticlesMap.put('publishStatuses',publishStatuses);
                    knowledgeArticlesMap.put('recordTypeIds',recordTypeIds);
                    knowledgeArticlesMap.put('knowledgeIds',knowledgeSearchResults);
                    knowledgeArticlesMap.put('persona',con.OSB_Persona__c);
                    knowledgeArticlesMap.put('operatingCountries',con.OSB_Operating_Country__c);
                    knowledgeArticlesMap.put('exceptionArticleIds',exceptionArticleIds);

                    if(String.isBlank(categories)){
                        articles = SEL_KnowledgeArticleVersions.newInstance().selectByPublishStatusAndRecordTypewithSearchIDsWoSharing(
                            knowledgeArticlesMap
                        );

                    }else{
                        knowledgeArticlesMap.put('categories', categories);
                    
                        articles = SEL_KnowledgeArticleVersions.newInstance().selectByCategoryAndPublishStatusAndRecordTypewithSearchIDsWoSharing(
                            knowledgeArticlesMap
                        );
                    }
                }
            } catch(Exception e) {
               LOGGER.error('OSB_SolutionShowcase_CTRL : getSolutionSearchResultsWithCategory  Retrieveing searched solutions with category Exception logged: ',e);
               OSB_SRV_ActionFailureHandler.newInstance().handleError(e, OSB_SolutionShowcase_CTRL.class.getName());
            }

        return articles;
    }

    /**
     * @description Returns a list of knowledge articles for the specific Provider Space
     * @param providerId Id
     * @param userId Id
     * @return List<Knowledge__kav> of Provider spaces knowledge articles
     **/
    @AuraEnabled(cacheable=true)
    public static List<Knowledge__kav> getProviderSolutionShowcase(Id providerId, Id userId) {      
        List<Knowledge__kav> articles;
        try {   
            Contact con = SEL_Contacts.newInstance().selectByUserId(new Set<Id>{userId})[0];        
            articles = SEL_KnowledgeArticleVersions.newInstance().selectArticleByPublishStatusAndProvider(
                    new Set<String>{ DMN_Knowledge.PUBLISH_STATUS_ONLINE },
                    new Set<Id>{UTL_RecordType.getRecordTypeId(DMN_Knowledge.OBJ_NAME, DMN_Knowledge.RT_SOLUTION)},
                    new Set<Id>{ providerId },                   
                    con.OSB_Persona__c,
                    con.OSB_Operating_Country__c
                            
                );
            
        } catch (Exception e) {
            LOGGER.error('OSB_SolutionShowcase_CTRL : getProviderSolutionShowcase  Retrieveing provider solutions Exception logged: ', e);
            OSB_SRV_ActionFailureHandler.newInstance().handleError(e, OSB_SolutionShowcase_CTRL.class.getName());
        }  

        return articles;
    }

    /**
     * @description Queries for knowledge article record for the Provider Spaces
     * @param providerId Id
     * @return List<Knowledge__kav> of Provider spaces knowledge articles
     **/
    @AuraEnabled(Cacheable=true)
    public static List<Knowledge__kav> getProviderSpaces(Id providerId) {        
        List<Knowledge__kav> providerList;
        try {
            providerList = SEL_KnowledgeArticleVersions.newInstance().selectArticleByProviderId(new Set<String>{ DMN_Knowledge.PUBLISH_STATUS_ONLINE },new Set<Id>{ providerId });
            providerList.sort();
           
        } catch (Exception e) {
            LOGGER.error('OSB_SolutionShowcase_CTRL : getProviderSpaces  Retrieveing provider solutions Exception logged: ', e);
            OSB_SRV_ActionFailureHandler.newInstance().handleError(e, OSB_SolutionShowcase_CTRL.class.getName());
        }  

        return providerList;
    }


    /**
    * @description Returns a list of all knowledge articles a user have avaiable to them
    * @return List<Knowledge__kav>of knowledge articles
    **/
    @AuraEnabled(cacheable=true)
    public static List<Knowledge__kav> getSolutions() {
        List<Knowledge__kav> articles;
        try {
            articles = SEL_KnowledgeArticleVersions.newInstance().selectByPublishStatusAndRecordTypeIdWoSharing(
                new Set<String>{DMN_Knowledge.PUBLISH_STATUS_ONLINE},
                new Set<Id>{UTL_RecordType.getRecordTypeId(DMN_Knowledge.OBJ_NAME, DMN_Knowledge.RT_SOLUTION)},
                new Set<Id>{} );
                
            articles.sort();
        }catch(Exception e) {
            LOGGER.error('OSB_SolutionShowcase_CTR : getSolutions  Retrieveing knowledge articles Exception logged: ',e);
            OSB_SRV_ActionFailureHandler.newInstance().handleError(e, OSB_SolutionShowcase_CTRL.class.getName());
        }
        return articles;
    }
}