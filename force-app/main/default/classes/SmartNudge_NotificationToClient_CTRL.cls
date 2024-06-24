/********************************************
* @author  		: Chandrasekhar Mokkala(chandrasekhar.mokkala@standardbank.co.za)
* @date    		: 4 August 2023
* @description 	: SFP-28741 - Send email notifications to Clients
* *****************************************/
public with sharing class SmartNudge_NotificationToClient_CTRL {
    private static final sbgplatform.rflib_Logger LOGGER = sbgplatform.rflib_LoggerUtil.getFactory().createLogger('SmartNudge_NotificationToClient_CTRL');

    /*****************************
    * @description : nudgeOwnerId
    * ***************************/
	public Id nudgeOwnerId {get;set;}
    /*****************************
    * @description : contactRecordId
    * ***************************/
	public Id contactRecordId {get;set;}
    
    /*****************************
    * @description : To return link for Header image
    * @return     	: String
    * ***************************/
    public String getHeaderImageURL(){
        return getImageLink('OSB_SN_Email_Banner_Image');
    }
    /*****************************
    * @description 	: It will return Insights which are owned by Contact or Dealer
    * @return     	: List<InsightWrapper>
    * ***************************/
    public List<InsightWrapper> getDealerOrContactInsights(){
        LOGGER.info('SmartNudge_NotificationToClient_CTRL:getDealerOrContactInsights initiated');
        List<InsightWrapper> insightWrapperList = new List<InsightWrapper>();
        try{
            LOGGER.debug('SmartNudge_NotificationToClient_CTRL:getDealerOrContactInsights Owner Info :'+nudgeOwnerId+ ' contact id :'+contactRecordId);
            
            if(nudgeOwnerId != null){
                insightWrapperList =  getDealerInsights();
            }
            else{
                insightWrapperList = getContactInsights();
            }
            
        }
        catch(Exception exp){
            LOGGER.error('SmartNudge_NotificationToClient_CTRL:getDealerOrContactInsights - Exception logged :',exp);
        }
        return insightWrapperList;
    }
    
    /*****************************
    * @description : It will return Insights which are owned by Owner
    * @return      : List<InsightWrapper>
    * ***************************/
    public List<InsightWrapper> getContactInsights(){
        LOGGER.info('SmartNudge_NotificationToClient_CTRL:getContactInsights initiated');
        List<InsightWrapper> insightWrapperList = new List<InsightWrapper>();
        try{
            
            Set<Id> insightIds = new Set<Id>();
            List<Insight_Client_Relationship__c> activeContactInsights = new SEL_InsightClientRelationships().selectActiveInsightClientRelationships(new Set<Id>{contactRecordId},90,40000);
            if(!activeContactInsights.isEmpty()){
                for(Insight_Client_Relationship__c insightClientRelationShip : activeContactInsights){
                    insightIds.add(insightClientRelationShip.Insight__c);
                }
            }
                        
            List<Insight__c> insightList = new List<Insight__c>();
            insightList = new SEL_Insights().getInsightsOrderByOptimizationRank(nudgeOwnerId,insightIds,3);
            LOGGER.debug('SmartNudge_NotificationToClient_CTRL:getContactInsights Nudges size :'+insightList.size()); 
            if(!insightList.isEmpty() ){
                for(Insight__c insight : insightList){
                    insightWrapperList.add(prepareInsightWrapper(insight));
                }
            }
        }catch(Exception exp){
            LOGGER.error('SmartNudge_NotificationToClient_CTRL:getContactInsights - Exception logged :',exp);
        }
        return insightWrapperList;
    }
    /*****************************
    * @description 	: It will return Insights which are owned by Owner
    * @return     	: List<InsightWrapper>
    * ***************************/
    public List<InsightWrapper> getDealerInsights(){
        LOGGER.info('SmartNudge_NotificationToClient_CTRL:getDealerInsights initiated');
        List<InsightWrapper> insightWrapperList = new List<InsightWrapper>();
        try{
            
            List<Insight__Share> insightShareList = new List<Insight__Share>();
            insightShareList = new SEL_InsightShares().getInsightSharesByInsightPersonaAndOwnerId(nudgeOwnerId,'Client'); 
            LOGGER.debug('SmartNudge_NotificationToClient_CTRL:getDealerInsights InsightShare records size :'+insightShareList.size()); 
            Set<Id> insightIds = new Set<Id>();
            if(!insightShareList.isEmpty()){
                for(Insight__Share insightShare : insightShareList){
                    insightIds.add(insightShare.ParentId);
                }
            }
            LOGGER.debug('SmartNudge_NotificationToClient_CTRL:getDealerInsights Insight Ids :'+insightIds);
            List<Insight__c> insightList = new List<Insight__c>();
            insightList = new SEL_Insights().getInsightsOrderByOptimizationRank(nudgeOwnerId,insightIds,3);
            LOGGER.debug('SmartNudge_NotificationToClient_CTRL:getDealerInsights Nudges size :'+insightList.size()); 
            if(!insightList.isEmpty() ){
                for(Insight__c insight : insightList){
                    insightWrapperList.add(prepareInsightWrapper(insight));
                }
            }
            
        }catch(Exception exp){
            LOGGER.error('SmartNudge_NotificationToClient_CTRL:getDealerInsights - Exception logged :',exp);
        }
        return insightWrapperList;
    }
    
    
    
    /*****************************
    * @description It will instatiate InsightWrapper record
    * @param insight
    * @return InsightWrapper
    * ***************************/
    public InsightWrapper prepareInsightWrapper(Insight__c insight){
        LOGGER.info('SmartNudge_NotificationToClient_CTRL:prepareInsightWrapper initiated');
        InsightWrapper insightWrap = new InsightWrapper();
        try{
            String expiryStyle = 'font-size:14px;';
            Date twoDays = System.today().addDays(2);
            Date sevenDays = System.today().addDays(7);
            if(insight.Expiry_Date__c <= twoDays){
                expiryStyle = expiryStyle + 'color: red';
            }
            else if(insight.Expiry_Date__c > twoDays && insight.Expiry_Date__c <= sevenDays){
                expiryStyle = expiryStyle + 'color:#FF681D';
            }
            else{
                expiryStyle = expiryStyle + 'color:black';
            }
            
            
            insightWrap.insightRecord = insight;
            insightWrap.expiryDateStyle = expiryStyle;
            insightWrap.insightLink = Url.getSalesforceBaseUrl().toExternalForm() + '/lightning/n/Akili_Insights?c__id='+insight.Id; 
            LOGGER.debug('SmartNudge_NotificationToClient_CTRL:prepareInsightWrapper Insight Record :'+insightWrap);
            return insightWrap;
        }
        catch(Exception exp){
            LOGGER.error('SmartNudge_NotificationToClient_CTRL:prepareInsightWrapper - Exception logged :',exp);
            return insightWrap;
        }
    }
    
    /*****************************
    * @description To form url to show images on the notification template based on the documentId
    * @param developerName
    * @return String
    * **************************/
    public string getImageLink(String developerName){
        String urlPrefix = '/servlet/servlet.ImageServer?id=';
        String documentLink;
        List<Document> documents = SEL_Documents.newInstance().selectByDeveloperName(new Set<String>{developerName});
        if(!documents.isEmpty()) {
            documentLink =  Url.getSalesforceBaseUrl().toExternalForm() + urlPrefix + documents[0].Id + '&oid=' + UserInfo.getOrganizationId();
        }
        return documentLink;
    }
    
    /***************
     * @description : This wrapper used to store Inight and insight link and insight detail values
     * *************/
    public class InsightWrapper{
       /***************
     * @description : insightRecord
     * *************/
        public Insight__c insightRecord{get;set;}
        /***************
     * @description : insightLink
     * *************/
        public String insightLink{get;set;}
        /***************
     * @description : expiryDateStyle
     * *************/
        public String expiryDateStyle{get;set;}
    }

}