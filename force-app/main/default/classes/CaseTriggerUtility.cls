/*************************************************************************\
@ Author        :     Anurag Jain
@ Date          :     23 June 2011
@ Test File     :     CaseClassAndTriggerTests
@ Description   :     General trigger utility class for Cases.
Set the Case Owner user details on the Case Object custom fields.        

@ Last Modified By  : Nitish Kumar
@ Last Modified On  : 5 Dec , 2014
@ Last Modified Reason  : EN-0578 (Case: Production Support Process for ICBC)

@ Last Modified By  : Manoj Gupta
@ Last Modified On  : 23 Feb , 2016
@ Last Modified Reason  : EN-1123 CommB - updating support cases for Helpdesk
-----------------------------------------------------------------------------------
@description Last Update: 2017-11-15: Rudolf Niehaus - Cloudsmiths - Child / Parent Case status sync
@ Last Update: 2017-11-16: Rudolf Niehaus - Cloudsmiths - Entitelment automation
@ Last Update: 2017-11-20: Rudolf Niehaus - Cloudsmiths - Prevent parent closure if a child is still open
------------------------------------------------------------------------------------
@ Last Modified By  : Raja Kumar
@ Last Modified On  : 23 March , 2022
@ Last Modified Reason  : SFP-9714 Salesforce not maintaining a Contact record on a case
****************************************************************************/
public with sharing class CaseTriggerUtility {
    /**
* copyOwnerDetails
* @param newRec Case
* @param owner User
*/
    public static void copyOwnerDetails(Case newRec, User owner){
        if(newRec!=null && newRec.Owner != null){
            //Copy the Case Owner user details to the Case fields.
            newRec.Case_Owner_Business_Unit__c = owner.Business_Unit__c;
            newRec.Case_Owner_CIB_Global_Area__c = owner.User_CIB_Global_Area__c;
            newRec.Case_Owner_City__c = owner.User_City__c;
            newRec.Case_Owner_Country__c = owner.User_Country__c;
            newRec.Case_Owner_Division__c = owner.User_Division__c;
            newRec.Case_Owner_State_Province__c = owner.User_State_Province__c;
            newRec.Case_Owner_Team__c = owner.User_Team__c;
        }
    }
    /**
* handleCaseBeforeInsertTrigger
* @param newRecs Case[]
*/
    public static void handleCaseBeforeInsertTrigger(List<Case> newRecs){
        
        //RN - CloudSmiths
        //make instance of the case process interface class
        invISCaseProcessSettings caseProcessSettings = new invISCaseProcessSettings();
        
        /**************************************************************************\
CASE C1269  - new custom fields has been created on Case object that shall be populated with the value with Case Owner 
user details. fields created on the Case object are User CIB Global Area, User Division, User Business Unit, User Team, User City, User State/Province, User Country
****************************************************************************/
        // remove cases from the list with empty owners
        List<Case> newRecsWithOwner = new list<Case>();
        for(Case newRec : newRecs){
            if(newRec.ownerId != null)
                newRecsWithOwner.add(newRec);
        }
        
        User[] users = UTL_User.getCachedUsers(UTL_Collections.getIdList(newRecsWithOwner, Case.OwnerId, new Set<Schema.SObjectType>{User.getSObjectType()})) ;
        // User[] users = UTL_User.getCachedUsers(UTL_Collections.getIdList(newRecs, Case.OwnerId, new Set<Schema.SObjectType>{User.getSObjectType()})) ;
        
        Map<Id, User> mapId2User = new Map<Id, User>(users);
        //Case 1269 - Update the Case OWner field with the Case Owner
        for(Case newRec : newRecs){
            User caseOwner = mapId2User.get(newRec.OwnerId);
            if(caseOwner!=null){
                copyOwnerDetails(newRec, caseOwner);
            }
            
            //RN - CloudSmiths - Only include TPS cases
            if(newRec.RecordTypeId == UTL_RecordType.getRecordTypeId(DMN_Case.OBJ_NAME, DMN_Case.RT_TPS_CLIENT_CASE)){
                
                //RN - CloudSmiths - link new cases to relevant Entitlement
                String entId = caseProcessSettings.getEntitlementId(newRec.RecordTypeId, newRec.Custody_Category__c, newRec.Custody_Sub_Category__c);
                
                if(String.isNotBlank(entId)){
                    newRec.EntitlementId = entId;
                } 
            }
        }
    }
    
    /**
* handleCaseBeforeUpdateTrigger
* A new field Case Owner is created on Case object that shall be populated with the value in Case Owner
standard field. This will help in defining the formula fields on the Case object
viz. User CIB Global Area, User Division, User Business Unit, User Team, User City, User State/Province, User Country
* @param oldMap Map<Id, Case>
* @param newMap Map<Id, Case>
*/
    public static void handleCaseBeforeUpdateTrigger(Map<Id, Case> oldMap, Map<Id, Case> newMap){
        /**************************************************************************\
A new field Case Owner is created on Case object that shall be populated with the value in Case Owner 
standard field. This will help in defining the formula fields on the Case object 
viz. User CIB Global Area, User Division, User Business Unit, User Team, User City, User State/Province, User Country
****************************************************************************/
        //RN - CloudSmiths
        //make instance of the case process interface class
        invISCaseProcessSettings caseProcessSettings = new invISCaseProcessSettings();
        
        //RN - Check if any child cases are open
        set<Id> hasOpenChildren = new set<Id>();
        
        for(Case ca :[Select Id, IsClosed, (Select IsClosed From Cases) 
                      From Case Where Id IN :newMap.keySet()]){
                          
                          for (Case child :ca.Cases){
                              
                              if(!child.IsClosed){
                                  
                                  hasOpenChildren.add(ca.Id);
                              }
                          }              
                      }
        
        User[] users = UTL_User.getCachedUsers(UTL_Collections.getIdList(newMap.values(), Case.OwnerId, new Set<Schema.SObjectType>{User.getSObjectType()}));
        
        Map<Id, User> mapId2User = new Map<Id, User>(users);
        User currentUser = mapId2User.get(UserInfo.getUserId());
        List<Contact> conList = new List<Contact>();
        if(currentUser!=null) {
            conList = SEL_Contacts.newInstance().selectById(new Set<Id>{
                currentUser.Contact_Sync_Id__c
                    });
        }
        //Case 1269 - Update the Case OWner field with the Case Owner
        for(Case newRec : newMap.values()){
            User caseOwner = mapId2User.get(newRec.OwnerId);
            
            if(caseOwner!=null && newRec.OwnerId != oldMap.get(newRec.id).OwnerId){
                copyOwnerDetails(newRec, caseOwner);
            }
            
            WRP_CASE newCaseObj = new WRP_CASE(newRec);
            WRP_CASE oldCaseObj = new WRP_CASE(oldMap.get(newRec.id));
            if(newCaseObj.isClosed() && !oldCaseObj.isClosed() 
               && String.isBlank(newCaseObj.getRecord().Resolved_By__c)){
                   
                   if(!conList.isEmpty()){
                       newRec.Resolved_By__c = currentUser.Contact_Sync_Id__c;
                   }
                   
               }
            if(newRec.RecordTypeId == UTL_RecordType.getRecordTypeId(DMN_Case.OBJ_NAME, DMN_Case.RT_TPS_CLIENT_CASE)){
                
                //RN - CloudSmiths
                //We have to look at the statuses as the isClosed flag is only set in after events
                String cStatus = newRec.Status;
                
                if((cStatus != oldMap.get(newRec.Id).Status) && ( cStatus.contains('Closed') || cStatus.equals('Cancelled') ) ){
                    if(hasOpenChildren.contains(newRec.Id)){
                        newRec.addError('You cannot close this case at this stage. Please close all related child cases first'); 
                    }
                }
                //RN - CloudSmiths
                //Check if the category or sub category changed then assign new entitelemnt to the case
                if(String.isNotBlank(newRec.Custody_Category__c) && String.isNotBlank(newRec.Custody_Sub_Category__c)){
                    if(newRec.Custody_Category__c != oldMap.get(newRec.Id).Custody_Category__c || 
                       newRec.Custody_Sub_Category__c != oldMap.get(newRec.Id).Custody_Sub_Category__c){
                           
                           //RN - CloudSmiths - link updated cases to relevant Entitlement
                           String entId = caseProcessSettings.getEntitlementId(newRec.RecordTypeId, newRec.Custody_Category__c, newRec.Custody_Sub_Category__c);
                           
                           if(String.isNotBlank(entId)){
                               newRec.EntitlementId = entId; 
                           } 
                       }
                }
            }
        }
        // added by Raja Kumar (raja.kumar@standardbank.co.za) for EinsteinCaseClassification(ECC) validation
        // This code checks if the service type suggested by ECC belongs to the support team attached to case or not.
        Set<id> teamIds=new Set<id>();
        Set<id> serviceTypeIds=new Set<id>();
        Set<string> serviceTiers=new Set<string>();
        Boolean flag=False;
        String tier=null;
        for(Case newRec : newMap.values()){
            //if service type is upated 
            flag=False;
            if(newRec.Service_Type_Name__c != oldMap.get(newRec.id).Service_Type_Name__c){
                tier=(newRec.CIB_Service_Tier__c!=null) ? newRec.CIB_Service_Tier__c : 'Standard';
                teamIds.add(newRec.Support_Team__c);
                serviceTypeIds.add(newRec.Service_Type_Name__c);
                serviceTiers.add(tier);
                flag=True;
            }
        }
        if(flag==True && teamIds.size()!=null){
            Map<String,SVC_SupportServiceTypes__c> mapServiceTypeIdtoSupportServiceType=new Map<String,SVC_SupportServiceTypes__c>();
            
            
            List<SVC_SupportServiceTypes__c> supportServiceTypeRecList = SEL_SupportServiceType.newInstance().selectByServiceTypeIdTeamIdAndTier(teamIds , serviceTypeIds ,serviceTiers);
            //check if selected service type exist for team linked to case
            if(supportServiceTypeRecList.size()!=null){
                for(SVC_SupportServiceTypes__c sstRec:supportServiceTypeRecList){
                    mapServiceTypeIdtoSupportServiceType.put(sstRec.Service_Type__c+'-'+sstRec.Service_Tier__c+'-'+sstRec.CMN_Team__c, sstRec);
                }
                for(Case newRec : newMap.values()){
                    tier=(newRec.CIB_Service_Tier__c!=null) ? newRec.CIB_Service_Tier__c : 'Standard';
                    if(mapServiceTypeIdtoSupportServiceType.keySet().contains(newRec.Service_Type_Name__c+'-'+tier+'-'+newRec.Support_Team__c)){
                        newRec.EntitlementId=mapServiceTypeIdtoSupportServiceType.get(newRec.Service_Type_Name__c+'-'+tier+'-'+newRec.Support_Team__c).Entitlement__c;                    
                     }else{
                        newRec.Service_Type_Name__c.addError('The selected service type does not belong to the support team linked to this case. Please use the manual classification option to classify the case appropriately or search for the correct service type associated to the support team.');
                    }
                }  
            }
        }
    }
    /**
* handleCaseAfterInsertTrigger
* @param newCases Case[]
*/
    public static void handleCaseAfterInsertTrigger(Case[] newCases){
        Map<Id,Id> mapCaseId2ContactId = new Map<Id,Id>(); 
        
        for (Case newCase : newCases){ 
            if(String.isNotBlank(newCase.hContactId__c)){
                mapCaseId2ContactId.put(newCase.id, newCase.hContactId__c); 
            }
        }
        
        if (mapCaseId2ContactId.size() > 0) { 
            CaseTriggerUtility.reLinkCasesToContacts(mapCaseId2ContactId); 
        }
    }
    /**
* handleCaseAfterUpdateTrigger
* @param oldMap Map<Id, Case>
* @param newMap Map<Id, Case>
*/
    public static void handleCaseAfterUpdateTrigger(Map<Id, Case> oldMap, Map<Id, Case> newMap){
        Case[] closedCases = new Case[]{};
            Map<Id,Id> mapCaseId2ContactId = new Map<Id,Id>(); 
        for (Case newCase : newMap.values()){ 
            
            if(oldMap.get(newCase.Id).hContactId__c != newCase.hContactId__c){
                mapCaseId2ContactId.put(newCase.id, newCase.hContactId__c); 
            }
            
            if(newCase.Status != oldMap.get(newCase.Id).Status 
               && newCase.isClosed
               && !String.isEmpty(newCase.Resolution_Comment__c) ){
                   closedCases.add(newCase);
               }
        }
        
        if (mapCaseId2ContactId.size() > 0) { 
            CaseTriggerUtility.reLinkCasesToContacts(mapCaseId2ContactId); 
        }
        DMN_Case.createCloseCaseComments(closedCases);
        
        
    }
    
    
    /** EN-0578 (Case: Production Support Process for ICBC).
The checkbox on Contact is used to identify if a Case is an ICBC Case or a SBG Case.
*  @param newRecs List<Case>
*/
    public static void handleICBCCasebeforeInsUpdate (List<Case> newRecs) {
        
        //Local Variables
        Set<Id> icbcConId = new Set<Id>() ;
        Set<Id> setICBC = new Set<Id>();
        Map<Id,Id> mapICBC = new Map<Id,Id>();
        
        //Storing all the Contact Ids in a Set
        for (Case cas : newRecs){
            icbcConId.add(cas.ContactId);
            mapICBC.put(cas.Id ,cas.ContactId);
        }
        
        icbcConId.remove(null);
        if (!icbcConId.isEmpty()) {
            
            //getting the Contact (ICBC Checkbox) information from the Contacts
            List<Contact> contacts = [SELECT ICBC_Contact__c FROM Contact WHERE Id IN : icbcConId] ;
            
            //Storing all the ICBC Contacts in a Set
            for (Contact con : contacts){
                if (con.ICBC_Contact__c == true){
                    setICBC.add(con.Id);
                }
            }
        }
        
        //Removing the Contact Reference from the Case if its an ICBC Case
        // Updated  if condition to exclude this for cross border record type on 2022-03-22
        for (Case cas : newRecs){
            if (setICBC.Contains(cas.ContactId) && (String.valueOf(cas.RecordTypeId )!= String.valueOf(Schema.SObjectType.case.getRecordTypeInfosByName().get('Cross Border CoE Record Type').getRecordTypeId())) &&
                (String.valueOf(case.RecordTypeId) != String.valueOf(Schema.SObjectType.case.getRecordTypeInfosByName().get('Cross Border CoE Closed Record Type').getRecordTypeId())))
            {
                cas.ContactId = null ;  
                cas.ICBC_Case__c = true ;      
                cas.ICBC_Contact__c = mapICBC.get(cas.Id) ; // getting the ICBC Contact information
            }
            //If the Case is getting created manually SuppliedEmail will be null  
            if (cas.SuppliedEmail != null && (String.valueOf(cas.RecordTypeId )!= String.valueOf(Schema.SObjectType.case.getRecordTypeInfosByName().get('Cross Border CoE Record Type').getRecordTypeId())) &&
                (String.valueOf(case.RecordTypeId) != String.valueOf(Schema.SObjectType.case.getRecordTypeInfosByName().get('Cross Border CoE Closed Record Type').getRecordTypeId()))){
                    if (cas.SuppliedEmail.contains('icbc')){
                        cas.ContactId = null ;  
                        cas.ICBC_Case__c = true ;  
                    }
                }
        }
    }
    /**
* reLink Cases to Contacts
* @param sharedCases Map <Id,Id>
*/
    @future
    public static void reLinkCasesToContacts(Map <Id,Id> sharedCases){
        Map<Id,Id> contactIdMap = new Map <Id,Id>();
        List <Case> casesToUpdate = new List <Case>();
        
        Set<Id> partnerContactIdSet = new Set<Id>(); 
        for (Id partnerCaseContactId : sharedCases.values()) { 
            partnerContactIdSet.add(partnerCaseContactId); 
        } 
        
        for (PartnerNetworkRecordConnection contactConnection : 
             [SELECT Id, Status, ConnectionId, PartnerRecordId, LocalRecordId 
              FROM PartnerNetworkRecordConnection 
              WHERE PartnerRecordId in :partnerContactIdSet]) { 
                  
                  if (contactConnection.Status == 'Sent') {                                                                
                      contactIdMap.put(contactConnection.PartnerRecordId,contactConnection.LocalRecordId);
                  } 
              }
        
        List <Case> cccCases = [Select Id,ContactId, hContactId__c from Case where Id in :sharedCases.KeySet()];
        
        for (Case currentCase: cccCases) { 
            currentCase.ContactId = contactIdMap.get(currentCase.hContactId__c);
            casesToUpdate.add(currentCase);
        } 
        if(casesToUpdate.size()>0){
            Database.update(casesToUpdate,False);
        }
        
    }
    
    /**************************************************************************\
EN-1123 CommB - updating support cases for Helpdesk  .
The CommB Case checkbox will distinguish CIB and CommB cases.
@param newCases List<Case>
****************************************************************************/
    
    
    public static void handleCommBCasebeforeInsUpdate (List<Case> newCases) {
        
        //Local Variables
        Set<Id> commBConId = new Set<Id>() ;
        Set<String> conEmail = new Set<String>();
        
        
        
        //Storing all the Contact Ids in a Set
        for (Case cas : newCases){
            commBConId.add(cas.ContactId);
            
        }
        
        commBConId.remove(null);
        if (commBConId.isEmpty()) {
            return;
        }
        //getting the Contact information from the Contacts
        list<Contact> contactlst = [Select Id , Name , Email from Contact where Id IN : commBConId] ;
        
        //Storing all the Contacts Email in a Set
        for (Contact con : contactlst){
            if (String.isNotBlank(con.Email)){
                conEmail.add(con.Email);
            }
        }
        
        if (conEmail.isEmpty()) {
            return;
        }
        
        List<user> users = SEL_Users.newInstance().selectByUserCIBGlobalAndEmail(DMN_User.CIB_GA_COMMB,conEmail);
        
        Map<String, id> emailidToUserMap = new Map<String, id>();
        for(user u : users) {
            if (String.isNotBlank(u.Email)) {
                emailidToUserMap.put(u.Email, u.id);
            }
        }
        
        
        for (Case cas : newCases){
            if (emailidToUserMap.containsKey(cas.SuppliedEmail) ){
                cas.CommB_Case__c = true ;  
            }
        }
    }
}