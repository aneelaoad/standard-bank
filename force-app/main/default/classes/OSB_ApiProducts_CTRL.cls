/**
 * Controller class for OSBApiProducts component
 *
 * @author Wojciech Kowalczyk (wkowalczyk@deloittece.com)
 * @date May 2020
 */
public with sharing class OSB_ApiProducts_CTRL {

    /**
     * Returns a list of knowledge articles for the available APIS
     *
	 * @param userId String of user ID
	 *
     * @return List of Knowledge_kav
     **/
    @AuraEnabled
    public static List<Knowledge__kav> getApiProducts(Id userId) {
        List<Knowledge__kav> articles;
        try {
            Contact con = SEL_Contacts.newInstance().selectByUserId(new Set<Id>{userId})[0];
            Set<Id> exceptionArticleIds = new Set<Id>();
            for(Knowledge_Entitlement_Exception__c entitlementException : SEL_KnowledgeExceptions.newInstance().selectByContactIdWoSharing(new Set<Id>{con.Id})) {
                exceptionArticleIds.add(entitlementException.OSB_Knowledge_Article__c);
            }
            articles = SEL_KnowledgeArticleVersions.newInstance().selectByPublishStatusAndRecordTypeIdPersonaApiWoSharing(
                    new Set<String>{DMN_Knowledge.PUBLISH_STATUS_ONLINE},
                    new Set<Id>{UTL_RecordType.getRecordTypeId(DMN_Knowledge.OBJ_NAME, DMN_Knowledge.RT_API)},
                    con.OSB_Persona__c,
                    con.OSB_Operating_Country__c,
                    exceptionArticleIds
            );
        } catch(Exception e) {
            System.debug(e.getMessage());
        }
        return articles;
    }

    /**
     * Returns a list of knowledge articles for the available APIS based on Search Keyword
     *
     * @param searchKeyword String of Search Keyword
	 *
     * @return List of Knowledge_kav
     **/
    @AuraEnabled
    public static List<Knowledge__kav> getApiProductsSearchResults(String searchKeyword) {
        List<Knowledge__kav> articles;
        Map<String,Object> parameterMap = new Map<String,Object>{};
        Id userId = UserInfo.getUserId();
        try {
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
            Set<Id> recordTypeIds = new Set<Id>{UTL_RecordType.getRecordTypeId(DMN_Knowledge.OBJ_NAME, DMN_Knowledge.RT_API)};
            parameterMap.put('publishStatuses',publishStatuses);
            parameterMap.put('recordTypeIds',recordTypeIds);
            parameterMap.put('knowledgeIds',knowledgeSearchResults);
            parameterMap.put('persona',con.OSB_Persona__c);
            parameterMap.put('operatingCountries',con.OSB_Operating_Country__c);
            parameterMap.put('exceptionArticleIds',exceptionArticleIds);

            articles = SEL_KnowledgeArticleVersions.newInstance().selectByPublishStatusAndRecordTypewithSearchIDsWoSharing(
                    parameterMap
            );
        } catch(Exception e) {
            SRV_Logger.newInstance().log(e, DMN_Log.AREA_ONEHUB, OSB_ApiProducts_CTRL.class.getName());
            throw e;
        }
        return articles;
    }
}