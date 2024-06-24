/**
 * @description Controller class for staff assisted onboading
 *
 * @see AOB_internal_CTRL_Onboarding_Test
 *
 * @author Sibonelo Ngcobo
 *
 * @date March 2023
 * 
 * @modification description: SFP-25088
 */
public inherited sharing class AOB_internal_CTRL_Onboarding {
    
    /**
     * @description Fetches a list of AOB_Application__c records based on the provided record ID.
     * @param recordId The ID of the AOB_Application__c record to retrieve.
     * @return A list containing the specified AOB_Application__c record.
     * @throws AuraHandledException If no record is found with the specified ID.
     */
    @AuraEnabled
    public static List<AOB_Application__c> getApplicationData(Id recordId) {    
        List<AOB_Application__c> appLst = SEL_AOBApplication.newInstance().selectAppsById(recordId);
        
        if(appLst.isEmpty()) {
            throw new AuraHandledException('No Record Found..');
        }
        return appLst; 
     }
     
    /**
     * @description Fetches a list of Account records based on the provided registration number.
     * @param textkey The registration number to search for.
     * @return A list containing the Account records that match the specified registration number.
     * @throws AuraHandledException If no records are found with the specified registration number.
     */
     @AuraEnabled(Cacheable = true)
     public static List<Account> getAccountData(String textkey) {
        Set<String> registrationNumber = new Set<String>();
        registrationNumber.add(textkey);
        List<Account> accLst = SEL_Accounts.newInstance().selectByRegistrationNumber(registrationNumber);
        
        if(accLst.isEmpty()) {
            throw new AuraHandledException('No Record Foundss..');
        }
        
        return accLst; 
    }
    
    /**
     * @description Creates a new AOB_ApplicationLineItem__c record with the specified product and application IDs.
     * @param productId The ID of the product to associate with the new AOB_ApplicationLineItem__c record.
     * @param appId The ID of the AOB_Application__c record to associate with the new AOB_ApplicationLineItem__c record.
     * @return The ID of the newly created AOB_ApplicationLineItem__c record.
     */
    @AuraEnabled
    public static String createApplicationLineItem(String productId, String appId) {
        AOB_ApplicationLineItem__c appLine = new AOB_ApplicationLineItem__c();
        appLine.AOB_Product__c = productId;
        appLine.AOB_Application__c = appId;
        insert appLine;
        return appLine.Id;
    }
    
    /**
     * @description Creates a new AOB_Application__c record with the specified account and product IDs, and creates a new associated AOB_ApplicationLineItem__c record.
     * @param accountId The ID of the Account record to associate with the new AOB_Application__c record.
     * @param productId The ID of the product to associate with the new AOB_ApplicationLineItem__c record.
     * @return The ID of the newly created AOB_Application__c record.
     */
    @AuraEnabled
    public static String createApplication(String accountId, String productId) {
        AOB_Application__c app = new AOB_Application__c();
        app.AOB_Status__c = 'In Progress';
        app.AOB_CurrentScreen__c = 'PreApplication';
        app.AOB_Client__c = accountId;
        insert app;
        AOB_internal_CTRL_Onboarding.createApplicationLineItem(productId, app.Id);
        return app.Id;
    }
    
    /**
 	* @description Retrieves a list of AOB_ApplicationLineItem__c objects associated with the given record ID.
 	* @param recordId The record ID for which to retrieve the associated application line items.
 	* @return A list of AOB_ApplicationLineItem__c objects associated with the record ID.
 	* @throws AuraHandledException if no application line items are found for the given record ID.
 	*/
    public static List<AOB_ApplicationLineItem__c> getApplicationLineItem(String recordId) {
        List<AOB_ApplicationLineItem__c> applines =new  SEL_AOBApplicationLineItem().selectAppLineItemsById(recordId);
    	if (applines.isEmpty()) {
        throw new AuraHandledException('No Records Found..');
    	}
    
    return applines;
	}
	/**
 	* @description Finds an AOB_Application__c object by the provided product ID within the open applications associated with the given registration.
 	* @param registration The registration associated with the open applications.
 	* @param productId    The product ID to search for within the applications.
 	* @return The AOB_Application__c object that contains the matching product ID, or null if not found.
 	*/
	@AuraEnabled
	public static AOB_Application__c findApplicationByProductId(String registration, String productId) {
    if(String.isNotBlank(registration)){
    List<AOB_Application__c> openApplications = AOB_Internal_CTRL_FormCreator.getOpenApplications(registration);
  
    for (AOB_Application__c openApp : openApplications) {
        List<AOB_ApplicationLineItem__c> appLine = getApplicationLineItem(openApp.Id);
        
        for (AOB_ApplicationLineItem__c lineItem : appLine) {
            if (lineItem.AOB_Product__c.equals(productId)) {
                return openApp;
            } 
        }
    }
    }
    return null;
	}




     /**
     * @description Fetches a list of SObject records based on the provided parameters.
     * @param objectName The name of the SObject to query.
     * @param filterField The API name of the field to filter on.
     * @param searchString The search string to use when filtering.
     * @param value The specific record ID to retrieve, if applicable.
     * @return A list of RecordsData objects representing the queried records.
     */
    @AuraEnabled
    @SuppressWarnings('PMD.ExcessiveParameterList')
    public static List<RecordsData> fetchRecords(String objectName, String filterField, String searchString, String value) {
        List<RecordsData> recordsDataList = new List<RecordsData>();
        //Selector performs a key stroke search and is too complex to add to selector class
        String query = 'SELECT Id, ' + String.escapeSingleQuotes(filterField) + ' FROM '+ String.escapeSingleQuotes(objectName);
        
        if(String.isNotBlank(value)) {
            query += ' WHERE Id = \''+  String.escapeSingleQuotes(value) + '\' LIMIT 10';
        } else {
            query += ' WHERE '+ String.escapeSingleQuotes(filterField)+
                ' LIKE ' + '\'' + String.escapeSingleQuotes(searchString.trim()) + '%\' LIMIT 10';
        }
        
        // Execute the query and add the results to the recordsDataList
        for(SObject s : Database.query(query)) {
            recordsDataList.add( new RecordsData((String)s.get(filterField), (String)s.get('id')) );
        }
        
        return recordsDataList;
    }
 
    /**
     * @description Inner class used to represent SObject records returned by fetchRecords().
     */
    public class RecordsData {
        @AuraEnabled public String label;
        @AuraEnabled public String value;
        /**
        * @description Inner class used to RecordsData
        * @param label
        * @param value
        */ 
        public RecordsData(String label, String value) {
            this.label = label;
            this.value = value;
        }
    }
}