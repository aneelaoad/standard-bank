/**
 * This class is used in a lightning Component
  * that creates Picklist dependencies
 *
 * @author		Emmanuel Mulea(Nocks)
 * @date	    April 2021
*/
public  class PBBLifeStyleConversationCtrl {
    
    /**
    * @description  This method is doing dependencies
    * @return   smartSquare data
    **/    
    @AuraEnabled
    public static Smart2Data getArrangedDependancies(){
		Map<String,List<Smart2DataOptions>> subCatMaps = new Map<String,List<Smart2DataOptions>>();
        Map<String,List<Smart2DataOptions>> respMaps = new Map<String,List<Smart2DataOptions>>();
        Map<String,List<String>> subCatMapsTrackDups = new Map<String,List<String>>();
        Map<String,List<String>> respMapsTrackDups = new Map<String,List<String>>();
        List<Conversation_Value__c> convValueList = SEL_ConversationValues.newInstance().selectAllConversationValues();
        Smart2Data smtData = new Smart2Data();
        Smart2DataOptions smtOpts;
        for(Conversation_Value__c cv: convValueList){

            checkOnSubCategory(subCatMapsTrackDups, cv, smtOpts, subCatMaps);
            checkOnResponse(respMapsTrackDups, cv, smtOpts, respMaps);
        }
        smtData.subCat = new List<String>(subCatMaps.keySet());
        smtData.resp = subCatMaps;
        smtData.reas = respMaps;
        return smtData;
    }

    /**
    * @description  This method is to get an Record Id
    * @param	recId Id of the Record
    * @return   Conversation object
    **/
    @AuraEnabled
    public static  Conversation__c getRecord(Id recId){
        Conversation__c conv = SEL_Conversations.newInstance().selectByIdWithExtraFields(new Set<Id>{recId})[0];
        return conv;
    }

    /**
    * @description  This method get Category field value
    * @return   Options
    **/
    @AuraEnabled 
    public static Map<String, String> getCategoryFieldValue(){
        Map<String, String> options = new Map<String, String>();
        
        Schema.DescribeFieldResult fieldResult = Conversation__c.Category__c.getDescribe();
        List<Schema.PicklistEntry> pValues = fieldResult.getPicklistValues();
        for (Schema.PicklistEntry p: pValues) {
            
            options.put(p.getValue(), p.getLabel());
        }
        return options;
    }

    /**
    * @description  This method for saving Conversation data
    * @param	conv Conversation object data
    **/
    @AuraEnabled 
    public static void saveData(Conversation__c conv){
        
        try{
            fflib_ISObjectUnitOfWork uow = ORG_Application.unitOfWork.newInstance();
            uow.registerDirty(conv);
            uow.commitWork();
        }
        catch(DmlException ex){
            
            SRV_Logger.newInstance().log(ex, DMN_Log.AREA_PBB_GATEWAY, PBBLifeStyleConversationCtrl.class.getName());
            throw new PBBLifeStyleConversationException(ex.getDmlMessage(0));
        }
    }
    
     /**
    * @description  This method is to create a new conversation
    * @param	clientId Id of the Client
    * @return   Conversation object
    **/
    @AuraEnabled 
    public static Conversation__c newConversation(Id clientId){

        try{
            
			Conversation__c conv = new Conversation__c(OwnerId=UserInfo.getUserId(),
                                                       Client__c=clientId,
                                                       Category__c=null,
                                                       Comments__c=null,
                                                       Expected_OI__c=null,
                                                       Future_Contact_Date__c=null,
                                                       PBB_HighValueCD__c=null,
                                                       Name=null,
                                                       Reason__c=null,
                                                       Response__c=null,
                                                       Subcategory__c=null
                                                      );
            return conv;
        }
        catch(DmlException ex){
            
            SRV_Logger.newInstance().log(ex, DMN_Log.AREA_PBB_GATEWAY, PBBLifeStyleConversationCtrl.class.getName());
            throw new PBBLifeStyleConversationException(ex.getDmlMessage(0));
        }
    }

    /**
    * @description  This method is to create a new conversation
    * @param	conv Object data
     * @return  Id of the conversation
    **/  
    @AuraEnabled 
    public static String createNewConversation(Conversation__c conv){
        try{
            fflib_ISObjectUnitOfWork uow = ORG_Application.unitOfWork.newInstance();
            uow.registerNew(conv);
            uow.commitWork();
            return conv.Id;
        }
        catch(DmlException ex){
            
            SRV_Logger.newInstance().log(ex, DMN_Log.AREA_PBB_GATEWAY, PBBLifeStyleConversationCtrl.class.getName());
            throw new PBBLifeStyleConversationException(ex.getDmlMessage(0));
        }
    }

    /**
    * @description  This method is to get HighValue field
    * @return   Options
    **/
    @AuraEnabled 
    public static Map<String, String> getHighValueFieldValue(){
        Map<String, String> options = new Map<String, String>();     
        Schema.DescribeFieldResult fieldResult = Conversation__c.PBB_HighValueCD__c.getDescribe();
        List<Schema.PicklistEntry> pValues = fieldResult.getPicklistValues();
        for (Schema.PicklistEntry p: pValues) {
            
            options.put(p.getValue(), p.getLabel());
        }
        return options;
    }

    /**
    * @description  This method is to get conversations
    * @param	clientId Id of the Client
    * @return   Conversation object
    **/
    @AuraEnabled
    public static Conversation__c[] getConversations(Id clientId) {
        
      return SEL_Conversations.newInstance().selectByAccounts(new Set<Id>{clientId});
    }
    
    private static void checkOnResponse(Map<String, List<String>> respMapsTrackDups, Conversation_Value__c cv, Smart2DataOptions smtOpts, Map<String, List<Smart2DataOptions>> respMaps) {
        if (respMapsTrackDups.get(cv.Response__c) == null) {
            smtOpts = new Smart2DataOptions();
            smtOpts.value = cv.Reason__c;
            smtOpts.label = cv.Reason__c;
            respMaps.put(cv.Response__c, new List<Smart2DataOptions>{
                    smtOpts
            });
            respMapsTrackDups.put(cv.Response__c, new List<String>{
                    cv.Reason__c
            });
        } else {
            smtOpts = new Smart2DataOptions();
            if (!respMapsTrackDups.get(cv.Response__c).contains(cv.Reason__c)) {
                smtOpts.value = cv.Reason__c;
                smtOpts.label = cv.Reason__c;
                respMaps.get(cv.Response__c).add(smtOpts);
                respMapsTrackDups.get(cv.Response__c).add(cv.Reason__c);
            }
        }
    }
    private static void checkOnSubCategory(Map<String, List<String>> subCatMapsTrackDups, Conversation_Value__c cv, Smart2DataOptions smtOpts, Map<String, List<Smart2DataOptions>> subCatMaps) {
        if (subCatMapsTrackDups.get(cv.Sub_Category__c) == null) {
            smtOpts = new Smart2DataOptions();
            smtOpts.value = cv.Response__c;
            smtOpts.label = cv.Response__c;
            subCatMaps.put(cv.Sub_Category__c, new List<Smart2DataOptions>{
                    smtOpts
            });
            subCatMapsTrackDups.put(cv.Sub_Category__c, new List<String>{
                    cv.Response__c
            });
        } else {
            smtOpts = new Smart2DataOptions();
            if (!subCatMapsTrackDups.get(cv.Sub_Category__c).contains(cv.Response__c)) {
                smtOpts.value = cv.Response__c;
                smtOpts.label = cv.Response__c;
                subCatMaps.get(cv.Sub_Category__c).add(smtOpts);
                subCatMapsTrackDups.get(cv.Sub_Category__c).add(cv.Response__c);
            }
        }
    }

    /**
     * This is a wrapper class for SubCategory response and reason
     *
     * @author		Emmanuel Mulea(Nocks)
     * @date	    April 2021
    */
    public class Smart2Data{
        @AuraEnabled
        public List<String> subCat;
        @AuraEnabled
        public Map<String,List<Smart2DataOptions>>resp;
        @AuraEnabled
        public Map<String,List<Smart2DataOptions>>reas;
    }

    /**
     * This is a wrapper class for options
     *
     * @author		Emmanuel Mulea(Nocks) 
     * @date	    April 2021
    */
    public class Smart2DataOptions{
        @AuraEnabled
        public String value;
        @AuraEnabled
        public String label;
    }

    public class PBBLifeStyleConversationException extends Exception{}
}