/********************************************
* @author  	: Chandrasekhar Mokkala
* @date    	: 15 August 2022
* @description : Send email notifications to CST members
* *****************************************/
public with sharing class SmartNudge_InsightsInMyPortfolioHelper {
    /*****************************
    * @description : cstTeamMemberId
    * ***************************/
	public Id cstTeamMemberId {get;set;}
    /*****************************
    * @description : ownedInsightsCount
    * ***************************/
    public Integer ownedInsightsCount {get;set;}
    /*****************************
    * @description : cstTeamMemberName
    * ***************************/
    public String cstTeamMemberName {get;set;}
    
    /*****************************
    * @description : To return link for SmartNudge page
    * @return     	: String
    * ***************************/
    public String getSmartNudgeUrl(){
        return Url.getSalesforceBaseUrl().toExternalForm() + '/lightning/n/Akili_Insights'; 
    }
    /*****************************
    * @description : To return link for Header image
    * @return     	: String
    * ***************************/
    public String getHeaderImageURL(){
        return getImageLink('SmartNudge_Email_Header');
    }
    /*****************************
    * @description : To return link for Footer image
    * @return     	: String
    * ***************************/
    public String getFooterClickHereImageURL(){
        return getImageLink('SmartNudge_Email_Footer');
    }
    
    /*****************************
    * @description : It will return Insights which are owned by CST Team members
    * @return     	: List<Insight__c>
    * ***************************/
    public List<InsightWrapper> getMyLatestInsights(){
        Set<InsightWrapper> insightWrapperSet = new Set<InsightWrapper>();
        List<InsightWrapper> insightWrapperList = new List<InsightWrapper>();
        List<Insight__Share> insightShareList = new List<Insight__Share>();
        insightShareList = [Select Id,ParentId from Insight__Share where UserOrGroupId =: cstTeamMemberId];
        Set<Id> insightIds = new Set<Id>();
        if(!insightShareList.isEmpty()){
            for(Insight__Share insightShare : insightShareList){
                insightIds.add(insightShare.ParentId);
            }
        }
        List<Insight__c> insightList = new List<Insight__c>();
		insightList = new SEL_Insights().getInsightsWithDescendingOrder(cstTeamMemberId,insightIds);
        ownedInsightsCount = insightList.size();
        if(!insightList.isEmpty() && insightList.size() <= 10){
            
            for(Insight__c insight : insightList){
                insightWrapperList.add(prepareInsightWrapper(insight));
            }
            return insightWrapperList;
        }
        else if(!insightList.isEmpty() && insightList.size() > 10 ){
            Map<String,List<Insight__c>> clientWithInsightsMap = new Map<String,List<Insight__c>>();
            for(Insight__c insight : insightList){
                if(clientWithInsightsMap.containsKey(insight.Client__c)){
                    clientWithInsightsMap.get(insight.Client__c).add(insight);
                }
                else{
                    clientWithInsightsMap.put(insight.Client__c,new List<Insight__c>{insight});
                }
            }
            //If more than 10 clients found
            if(!clientWithInsightsMap.keySet().isEmpty() && clientWithInsightsMap.keySet().size() > 10){
                insightWrapperList.addAll(getInsightsWhenMorethan10Clients(clientWithInsightsMap));
            }
            else {//If less than 10 Clients found
                Set<Id> insightRecIds = new Set<Id>();
                for(String client : clientWithInsightsMap.keySet()){
                    insightWrapperSet.add(prepareInsightWrapper(clientWithInsightsMap.get(client)[0]));
                    insightRecIds.add(clientWithInsightsMap.get(client)[0].Id);
                }
                
                if(!insightWrapperSet.isEmpty() && insightWrapperSet.size() < 10){
                    insightWrapperSet.addAll(getRemainingInsights(insightList,insightRecIds));
                }
                insightWrapperList.addAll(insightWrapperSet);
            }
        }
        return insightWrapperList;
    }
    
    /*****************************
    * @description It will get top 10 insight records
    * @param clientWithInsightsMap
    * @return List<InsightWrapper>
    * ***************************/
    public List<InsightWrapper> getInsightsWhenMorethan10Clients(Map<String,List<Insight__c>> clientWithInsightsMap){
        List<InsightWrapper> insightWrapperList1 = new List<InsightWrapper>();
        Integer clientCount = 0;
        for(String client : clientWithInsightsMap.keySet()){
            if(clientCount < 10){
                insightWrapperList1.add(prepareInsightWrapper(clientWithInsightsMap.get(client)[0]));
            }
            else{ break;}
            clientCount = clientCount + 1;
        }
        return insightWrapperList1;
    }
    
    /*****************************
    * @description It will get remaining insight records
    * @param insightList 
    * @param insightIdSet
    * @return Set<InsightWrapper>
    * ***************************/
    public Set<InsightWrapper> getRemainingInsights(List<Insight__c> insightList, Set<Id> insightIdSet){
        Set<InsightWrapper> insightWrapperSet1 = new Set<InsightWrapper>();
        Integer insCount = insightIdSet.size();
        for(Insight__c insgt : insightList){
            if(!insightIdSet.contains(insgt.Id)){
                if(insCount != 10){
                    insightWrapperSet1.add(prepareInsightWrapper(insgt));
                }
                else{
                    break;
                }
                insCount = insCount + 1;
            }
        }
        
        return insightWrapperSet1;
    }
    
    /*****************************
    * @description It will instatiate InsightWrapper record
    * @param insight
    * @return InsightWrapper
    * ***************************/
    public InsightWrapper prepareInsightWrapper(Insight__c insight){
        InsightWrapper insightWrap = new InsightWrapper();
        insightWrap.insightRecord = insight;
        insightWrap.insightLink = Url.getSalesforceBaseUrl().toExternalForm() + '/lightning/n/Akili_Insights?c__id='+insight.Id; 
        insightWrap.insightDetail = getInsightDetails(insight.Insight__c);
        return insightWrap;
    }
    
    /*****************************
    * @description To show only 100 characters of Insight detail field value 
    * @param insightDetail
    * @return string
    * ***************************/
    public String getInsightDetails(String insightDetail){
        String returnValue = String.isNotBlank(insightDetail) ? insightDetail : '';
        if(String.isNotBlank(returnValue) && returnValue.length() > 100){
            returnValue = returnValue.substring(0,100) +'...'; 
        }
        else if(String.isNotBlank(returnValue)){
            returnValue = returnValue+'...'; 
        }
        return returnValue;
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
     * @description : insightDetail
     * *************/
        public String insightDetail{get;set;}
    }
}