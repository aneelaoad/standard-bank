/*************************************************************************\
    @ Author        : Dane Williams (Deloitte)
    @ Date          : July-2017
    @ Test File     : CI_ClientInfoControllerTest
    @ Description   : This class contains all methods used by the "Client Info" section of the Client Insights app
    @ Last Modified By  :   Dane Williams
    @ Last Modified On  :   05-Oct-2017
    @ Last Modified Reason  :   Added getKYC
****************************************************************************/

public without sharing class CI_ClientInfoController {

    @AuraEnabled
    public static CI_ResponseDto getEngagements(String clientId, String audienceType) {
        CI_SharedUtilities sharedUtils = new CI_SharedUtilities();
        CI_CardListObjectModel clom = new CI_CardListObjectModel();
        
        if(!sharedUtils.canAccessFields(Schema.SObjectType.Call_Report__c.fields.getMap(), new String[] {'Meeting_Audience__c', 'End__c', 'Contact__c', 'Core_Meeting__c', 'Date__c', 'Subject__c', 'Description__c'})){ 
            return new CI_ResponseDto(false, 'You do not have the required permissions to view this data');
        }
        
        clom.cardObjectList = [SELECT Meeting_Audience__c, End__c, Report_Client_Contact__r.Name, Core_Meeting__c, Date__c, Subject__c, Description__c, Outcomes__c 
                        FROM Call_Report__c
                        WHERE (Relate_to_Client__r.Id =: clientId 
                        OR Relate_to_Opp__r.Account.Id =: clientId)
                        AND Meeting_Audience__c =: audienceType];

        return new CI_ResponseDto(clom);
    }     

    @AuraEnabled
    public static CI_ResponseDto getClientContacts(String clientId) {
        CI_SharedUtilities sharedUtils = new CI_SharedUtilities();
        CI_CardListObjectModel clom = new CI_CardListObjectModel();
        
        if(!sharedUtils.canAccessFields(Schema.SObjectType.Contact.fields.getMap(), new String[] {'Name', 'Title', 'Email', 'Phone', 'Birthdate', 'AssistantName', 'AssistantPhone','Assistant_Email__c', 'MailingAddress', 'Phone_Country__c'})){ 
            return new CI_ResponseDto(false, 'You do not have the required permissions to view this data');
        }
        
        clom.cardObjectList = [SELECT Name, Title, Email, Phone, Birth_Day_Month__c, AssistantName, AssistantPhone, Assistant_Email__c, MailingAddress, Phone_Country__c  
                        FROM Contact 
                        WHERE AccountId =: clientId];

        return new CI_ResponseDto(clom);
    }  

    @AuraEnabled
    public static CI_ResponseDto getClientServiceTeam(String clientId) {
        CI_SharedUtilities sharedUtils = new CI_SharedUtilities();
        CI_CardListObjectModel clom = new CI_CardListObjectModel();
        
        if(!sharedUtils.canAccessFields(Schema.SObjectType.Custom_Client_Team__c.fields.getMap(), new String[] {'Client_Role__c', 'User_Country__c', 'Team_Member__c'})){ 
            return new CI_ResponseDto(false, 'You do not have the required permissions to view this data');
        }
        
        clom.cardObjectList = [SELECT Team_Member__r.Name, Client_Role__c, User_Country__c,Team_Member__r.Email , Team_Member__r.Phone  
                        FROM Custom_Client_Team__c 
                        WHERE Account__c =: clientId];

        return new CI_ResponseDto(clom);
    }  

    @AuraEnabled
    public static CI_ResponseDto getKYCAtRisk(String clientId) {
        CI_SharedUtilities sharedUtils = new CI_SharedUtilities();
        CI_SharedUtilities.ClientHierarchyTools clientHierarchyTools = new CI_SharedUtilities.ClientHierarchyTools();
        CI_CardListObjectModel clom = new CI_CardListObjectModel();

        if(!sharedUtils.canAccessFields(Schema.SObjectType.Custom_Client_Team__c.fields.getMap(), new String[] {'Account__c', 'Team_Member__c'})){ 
            return new CI_ResponseDto(false, 'You do not have the required permissions to view this Custom_Client_Team__c data');
        }

        //Get client IDs in user's CST
        Id userID = UserInfo.getUserId();
        List<Account> cstClientList = [SELECT Id
                            FROM Account
                            WHERE Id IN 
                            (SELECT Account__c 
                            FROM Custom_Client_Team__c 
                            WHERE Team_Member__c =: userID)];
        Set<Id> cstClientIds = (new Map<Id,Account>(cstClientList)).keySet();

        //System.debug ('getKYCAtRisk UserInfo.getName(): ' + UserInfo.getName());
        //System.debug ('getKYCAtRisk clientId: ' + clientId);
        //System.debug ('getKYCAtRisk cstClientIds: ' + cstClientIds);

        //Get client IDs in the client's hierarchy
        Set<String> hierClientIds = new Set<String>(clientHierarchyTools.getClientIdsInHierarchy(CI_ClientSearchController.getClientHierarchy(clientId)));

        //System.debug ('getKYCAtRisk hierClientIds: ' + hierClientIds);

        List<String> allowedClientIds = new List<String>();
        //Loop through client IDs in the hierarchy and add the ones found in the cstClientIds
        for(String hierClientId : hierClientIds)
        {
            if(cstClientIds.contains(hierClientId))
            {
                allowedClientIds.add(hierClientId);
            }
        }

        //System.debug ('getKYCAtRisk allowedClientIds: ' + allowedClientIds);

        if(!sharedUtils.canAccessFields(Schema.SObjectType.KYC_Status__c.fields.getMap(), new String[] {'Client__c', 'Provisional_Suspension_Date__c'})){ 
            return new CI_ResponseDto(false, 'You do not have the required permissions to view this KYC_Status__c data');
        }

        //Get KYC status with the minimum Provisional_Suspension_Date__c for each client
        List<AggregateResult> clientKYCStatuses = [SELECT 
                                                Client__c, 
                                                Client__r.Name,
                                                MIN(Provisional_Suspension_Date__c) Provisional_Suspension_Date__c
                                                FROM KYC_Status__c
                                                WHERE Client__c IN: allowedClientIds
                                                AND KYC_Status__c = 'Not Complete'
                                                GROUP BY Client__c, Client__r.Name];

        //System.debug ('getKYCAtRisk clientKYCStatuses: ' + clientKYCStatuses);
        //System.debug ('getKYCAtRisk clientRevenueTotals: ' + clientRevenueTotals);

        //Loop through clientKYCStatuses and clientRevenueTotals and build the CI_CardMapModel where client's match
        for(AggregateResult kycStatus : clientKYCStatuses)
        {
            Map<String, String> kycAtRiskMap = new Map<String, String>();
            Boolean clientRevenueFound = false;       
            if(!clientRevenueFound)
            {
                kycAtRiskMap.put('clientName', String.valueOf(kycStatus.get('Name')));
                kycAtRiskMap.put('revenue', '0');
                kycAtRiskMap.put('suspensionDate', String.valueOf(kycStatus.get('Provisional_Suspension_Date__c')));
            }

            clom.cardObjectList.add(kycAtRiskMap);
        }

        //System.debug ('getKYCAtRisk clom: ' + clom);
        
        return new CI_ResponseDto(clom);
    }   
}