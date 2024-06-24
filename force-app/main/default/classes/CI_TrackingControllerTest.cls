@isTest
public class CI_TrackingControllerTest {
    static testMethod void TrackTest() {    
        String randomTrack = 'Test'+Math.Random();

        CI_TrackingController.Track(randomTrack);
        List<CI_Tracking__c> track = [SELECT Description__c, Count__c 
                                    FROM CI_Tracking__c 
                                    where Description__c=:randomTrack]; 

        System.assertEquals(randomTrack, String.valueOf(track[0].Description__c)); 
    }        
      
}