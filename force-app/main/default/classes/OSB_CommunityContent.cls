/**
 * OSB_CommunityContent class used in OneHub community
 *
 * @author Ayush Garg (ayusgarg@deloitte.com)
 * @date April 2020
 *
 **/
public with sharing class OSB_CommunityContent {
    private static String endpoint = null;
    private static final String PING_URL = '/services/auth/sso/';
	private static final String OFFSET_API = '&offset=';
    private static final String COUNT_API = '&count=20';
    private static final String API_SEARCH = '&safeSearch=strict&originalImg=true';
    private static final String API_ATTRIBUTE = 'callout:Bing_Api?mkt=en-US&Category=';
    private static final String ALL_USERS = 'All Users';
    private static final String CATEGORY_TECHNOLOGY = 'Technology';
    private static final String CATEGORY_BUSINESS = 'Business';
    private static final String DOCUMENT_INITIAL_URL = '/servlet/servlet.FileDownload?file=';
    
    /**
     * Redirects the user to the login page if not logged into community.
     * Prevents ilegal access if the user knows the URL
     *
     * @return PageReference
     **/
    public PageReference doRedirectToPing(){
        PageReference pageRef = new PageReference(PING_URL+OSB_SRV_PingIntegration.AUTH_PROVIDER_NAME);
        pageRef.setRedirect(true);
        return pageRef;
    }

    /**
     * Returns a list of knowledge articles for the available APIS
     *
     * @param apiId knowledge article Id
     *
     * @return List of Knowledge_kav
     **/
    @AuraEnabled(Cacheable=true)
    public static List<Knowledge__kav> getApiDetails(Id apiId) {
        return SEL_KnowledgeArticleVersions.newInstance().selectByPublishStatusIdAndRecordTypeIdWoSharing(
                new Set<String>{DMN_Knowledge.PUBLISH_STATUS_ONLINE},
                new Set<Id>{apiId},
                new Set<Id>{UTL_RecordType.getRecordTypeId(DMN_Knowledge.OBJ_NAME, DMN_Knowledge.RT_API)}
        );
    }

    /**
     * Users for the a specific Notification
     *
     * @param notificationId id of notification
     *
     * @return String
     **/
    @AuraEnabled(Cacheable=true)
    public static String getAssignedUsers(Id notificationId){
        return SEL_Notifications.newInstance().selectById(new Set<Id>{notificationId})[0].Users__c;
    }

    /**
     * map of user names and ids
     *
     * @return Map<Id, String> containing user ID as key and user name as value
     **/
    @AuraEnabled(Cacheable=true)
    public static Map<Id, String> getAvailableUsers() {
        List<User> userList = SEL_Users.newInstance().selectByIsActiveAndProfileNameWoSharing(new Set<String>{DMN_Profile.ONE_HUB_COMMUNITY});
        Map<Id, String> userMap = new Map<Id, String>();
        for(User u:userList){
            userMap.put(u.Id,u.Name);
        }
        return userMap;
    }

    /**
     * Returns a list of notifications for user
     *
     * @return List<object> feedItems
     **/
    @AuraEnabled(Cacheable=true)
    public static List<Object> getFeedItemsForUser() {
        Id userId=UserInfo.getUserId();
        List<Object> feedItems = [
                SELECT Id, Title__c, Content__c, CreatedDate, Subtitle__c, Is_Unread__c
                FROM Notification__c
                WHERE OwnerId = :userId OR Users__c INCLUDES(:userId, :ALL_USERS)
                ORDER BY CreatedDate DESC
        ];
        return feedItems;
    }

    /**
     * Returns a list for the industry picklist on the community
     *
     * @return List<string> options
     **/
    @AuraEnabled(Cacheable=true)
    public static List<String> getIndustryPicklistValues() {
        List<String> options = new List<String>();
        for( Schema.PicklistEntry f : UTL_Picklist.getPicklistValues(Contact.Company_Industry__c)) {
            options.add(f.getValue());
        }
        return options;
    }

    /**
     * Provides OSBMarketgramProducts component with information required for displaying different
     * knowledge articles, comments and votes
     * 
     * @author Wojciech Kowalczyk
     * 
     * @return map of Knowledge articles,Votes, Feed items and current user's Id
     */
    @AuraEnabled
    public static Map<String, Object> getProductsAndVotes() {
        Id userId = UserInfo.getUserId();
        Contact con = SEL_Contacts.newInstance().selectByUserId(New Set<Id>{userId})[0]; 
        Set <Id> exceptionArticleIds = new Set<Id>();
        List<Knowledge__kav> finalProductsList = new List<Knowledge__kav> ();
        List<Knowledge__kav> finalarticlesWithActivitiesList = new List<Knowledge__kav> ();
        
        for(Knowledge_Entitlement_Exception__c expRecord : SEL_KnowledgeExceptions.newInstance().selectByContactIdWoSharing(new Set<Id>{con.Id})){
            exceptionArticleIds.add(expRecord.OSB_Knowledge_Article__c);
        }
        Set<String> publishStatusSet = new Set<String>{
            DMN_Knowledge.PUBLISH_STATUS_ONLINE
        };
        Set<Id> recordTypesIds = new Set<Id>{
            UTL_RecordType.getRecordTypeId(DMN_Knowledge.OBJ_NAME, DMN_Knowledge.RT_API),
            UTL_RecordType.getRecordTypeId(DMN_Knowledge.OBJ_NAME, DMN_Knowledge.RT_Solution)
        };  

        List<Knowledge__kav> apiArticles;
        apiArticles = SEL_KnowledgeArticleVersions.newInstance().selectByPublishStatusAndRecordTypeIdPersonaApiWoSharing(
                    new Set<String>{DMN_Knowledge.PUBLISH_STATUS_ONLINE},
                    new Set<Id>{UTL_RecordType.getRecordTypeId(DMN_Knowledge.OBJ_NAME, DMN_Knowledge.RT_API)},
                    con.OSB_Persona__c,
                    con.OSB_Operating_Country__c,
                    exceptionArticleIds
            );
        
        List<Knowledge__kav> solutionArticles;
        solutionArticles = SEL_KnowledgeArticleVersions.newInstance().selectByPublishStatusAndRecordTypeIdPersonaSolutionWoSharing(
                    new Set<String>{DMN_Knowledge.PUBLISH_STATUS_ONLINE},
                    new Set<Id>{UTL_RecordType.getRecordTypeId(DMN_Knowledge.OBJ_NAME, DMN_Knowledge.RT_SOLUTION)},
            		new Set<Id>{},
                    con.OSB_Persona__c,
                    con.OSB_Operating_Country__c,
                    exceptionArticleIds
            );
        finalProductsList.addAll(apiArticles);
        finalProductsList.addAll(solutionArticles);
        
        Map<Id, Knowledge__ka> articlesWithActivities = new Map<Id, Knowledge__ka>(
                new SEL_KnowledgeArticles().selectWithVotesAndFeedsByVersionRecordTypePersona(
                        recordTypesIds,
                        publishStatusSet,
                    	exceptionArticleIds,
                    	con.OSB_Persona__c,
                    	con.OSB_Operating_Country__c
                )
        );
        
        Map<String, Object> name2Object = new Map<String, Object>();
        name2Object.put('products', finalProductsList);
        name2Object.put('articlesWithActivities', articlesWithActivities);
        name2Object.put('userId', userId);
        return name2Object;
    }

    /**
     * Checks if the user has been logged in for the first time for guided tour
     *
     * @return Contact
     **/
    @AuraEnabled(Cacheable=false)
    public static Contact getOnboardingDetails() {
        try{
            if (UTL_User.isLoggedInUser()) {
                Contact contacts = SEL_Contacts.newInstance().selectByUserId(new Set<Id>{UserInfo.getUserId()})[0];
                return contacts;
            }
            return null;
        }
        catch(Exception ex){
            return null;
        }
    }

    /**
     * Gets the users email
     *
     * @return String email
     **/
    @AuraEnabled(Cacheable=true)
    public static String getUserEmail() {
        return UserInfo.getUserEmail();
    }

    /**
     * Checks if the current user is login to community
     *
     * @return Boolean
     **/
    @AuraEnabled(Cacheable=true)
    public static Boolean isUserLoggedIn() {
        return UTL_User.isLoggedInUser();
    }

    /**
     * Updates the notification as read
     *
     * @param recordId of Notification__c
     * @return error message if update fails
     **/
    @AuraEnabled(Cacheable=false)
    public static String markReadNotification(Id recordId) {
        fflib_ISObjectUnitOfWork uow = ORG_Application.unitOfWork.newInstance();
        Notification__c notif = new Notification__c(Id =  recordId, Is_Unread__c = false);
        try {
            uow.registerDirty(notif);
            uow.commitWork();
        } catch(Exception ex) {
            return ex.getMessage();
        }
        return '';
    }

    /**
     * Updates knowledge article scoring after user's interaction in OSBMarketgramProduct component
     *
     * @param voteId if it is not null, then method updates existing vote, in other case, it's creating new one
     * @param knowledgeId id of Knowledge__ka that is being scored
     * @param operationType LIKE or DISLIKE
     *
     * @return vote's Id
     */
    @AuraEnabled(Cacheable=false)
    public static String updateScoring(Id voteId, Id knowledgeId, String operationType) {
        fflib_ISObjectUnitOfWork uow = ORG_Application.unitOfWork.newInstance();
        
        String voteType = operationType == 'LIKE' ? '5' : '1';
        Vote userVote = new Vote(Id = voteId, ParentId = knowledgeId, Type = voteType);
        uow.registerUpsert(userVote);
        uow.commitWork();
		
        return userVote.Id;
    }
    
    /**
     * Inserts a new Subscribed Solution record and returns true if successful and false if not
     * 
     * @param  solutionId String
     *
     **/
    @AuraEnabled(Cacheable=false)
    public static void createUserSubscribedSolution(Id solutionId) {
        fflib_ISObjectUnitOfWork uow = ORG_Application.unitOfWork.newInstance(); 
        Subscribed_Solutions__c subscribedSolution = new Subscribed_Solutions__c();
        subscribedSolution.User__c = UserInfo.getUserId();
        subscribedSolution.Solution__c = solutionId; 
        uow.registerNew(subscribedSolution);
        uow.commitWork();
    }
    
    /**
     * Deletes a Subscribed Solution record and returns true if successful and false if not
     * 
     * @param  solutionId String
     *
     **/
    @AuraEnabled(Cacheable=false)
    public static void removeUserSubscribedSolution(String solutionId) {
        fflib_ISObjectUnitOfWork uow = ORG_Application.unitOfWork.newInstance(); 
        List<Subscribed_Solutions__c> subscribedSolution  = SEL_SubscribedSolutions.newInstance().selectByUserIdAndSolutionId(new set<Id> {solutionId}, new set<Id> {UserInfo.getUserId()});
        uow.registerDeleted(subscribedSolution);
        uow.commitWork();
    }

    /**
     * Used to display team profile to the correct users 
     * 
     * @return Boolean true if user access is approved
     **/
    @AuraEnabled(Cacheable=true)
    public static Boolean getContactAuth() {
        Boolean authorisation = false;
        List <Contact> contactList = SEL_Contacts.newInstance().selectByUserId(new Set<Id>{UserInfo.getUserId()});
        if(!contactList.isEmpty()){
            if(contactList[0].OSB_Community_Access_Status__c == DMN_Contact.OSB_COMMUNITY_ACCESS_STATUS_APPROVED){
                authorisation = true;
            }
    	}
        return authorisation;
    }

}