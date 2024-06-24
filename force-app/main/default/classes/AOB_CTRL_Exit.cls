/**
* Controller for aob_cmp_exit component
*
* <p>DPB-9382</p>
*
* @author Layton Matyila
*
* @date 12 November 2021
*/
public class AOB_CTRL_Exit {
    
    /**
    * @description gets the current application details
    * @param applicationId 
    * @return ApplicationData
    */
    @auraEnabled
    public static ApplicationData getApplicationData(id applicationId) {
        // Define error fields
        String errMessage;
        AuraHandledException err = new AuraHandledException('');
        // Retrieve application data  
        List<AOB_Application__c> apps = new SEL_AOBApplication().selectAppsById(applicationId);
        if(apps.isEmpty()){
            errMessage = 'Application '+applicationId+' not found';
            err.setMessage(errMessage);
            throw err;
        }
        // Retrieve application item data 
        List<AOB_ApplicationLineItem__c> appItems = new SEL_AOBApplicationLineItem().selectAppLineItemsById(applicationId);
        if(appItems.isEmpty()){
            errMessage = 'Line items for application '+applicationId+' not found';
            err.setMessage(errMessage);
            throw err;
        }
        // Determine main product name
        String mainProductName;
        for (AOB_ApplicationLineItem__c appItem : appItems){
            if (appItem.AOB_Main__c == true){
                mainProductName = appItem.AOB_Product__r.Name; 
                break;
            }
        }
        if (mainProductName == null){
            errMessage = 'Main line item product not found for application '+applicationId;
            err.setMessage(errMessage);
            throw err;
        }
        // Return relevant application data
        return new ApplicationData(apps[0].AOB_DaysUptoExpiry__c,apps[0].AOB_CurrentScreen__c,mainProductName);
    }

    /**
    * @description wrapper class for application data
    * @param daysUpToExpiry, currentScreen, productName 
    */
    public class ApplicationData{
        @AuraEnabled
        public Decimal daysUpToExpiry { get; set;}
        @AuraEnabled
        public String currentScreen { get; set;}
        @AuraEnabled
        public String productName { get; set;}

        public ApplicationData(Decimal inDaysUpToExpiry,string inCurrentScreen,string inProductName){
            daysUpToExpiry=inDaysUpToExpiry;
            currentScreen=inCurrentScreen;
            productName=inProductName;            
        }
    }
}