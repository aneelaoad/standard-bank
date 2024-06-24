public class CI_TrackingController{
  @AuraEnabled
 public static void Track(String description) {     
        //String Session = UserInfo.getSessionId();     

        CI_Tracking__c newTrack = new CI_Tracking__c(Description__c = description);
        insert newTrack;  
                 
    }       
          
}