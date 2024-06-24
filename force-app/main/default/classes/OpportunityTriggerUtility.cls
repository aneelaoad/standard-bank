/*************************************************************************\
    @ Func Area     : New Opportunities; User.Notify_when_Opportunity_created_by_other__c; Workflow Rule: Notify Client Owner If Opportunity Owner Different
    @ Author        :     Caro Reinecke
    @ Date          :     10 June 2011
    @ Test File     :     OpportunityClassAndTriggerTests
    @ Description   :     General trigger utility class for Opportunties.
                          Handles setting of CRT Feed flag for closed GM opportunities 
                          
    @ Last Modified By  : Anurag Jain
    @ Last Modified On  : 15 June 2011  
    @ Last Modified Reason  : CASE-01258 Code updated to handle the setting of Actual Close Date.
                              This is to replace the Workflow SA Opps Closed on Opportunity.

    @ Last Modified By  : Anurag Jain
    @ Last Modified On  : 21 June 2011  
    @ Last Modified Reason  : CASE-01690 Code updated to handle the setting of Start Date.
                              This is to replace the Workflow [SA_When an Opp is created] on Opportunity.     
                             
    @ Last Modified By  : Caro Reinecke
    @ Last Modified On  : 26 July 2011  
    @ Last Modified Reason  : CASE-01898 The Amount field used to be kept in sync with the opportunity product 
                              revenue roll-up field via workflow field update. This solution excluded private oppy's.
                              To cater for all oppy's including private the amount is now sync'ed using a before update
                              trigger.     
   
    @ Last Modified By  : Caro Reinecke
    @ Last Modified On  : 09 January 2012  
    @ Last Modified Reason  : Consolidated Triggers moved code from StdBank_OpptyBeforeInsert_Trigger on Opportunity (before insert)                        
    @ Description   : EMEA_SOW_StandardBank_009 
                      When a non-private opportunity is created on the Client by a different user
                      (i.e., who does not own the Client) notify by email the Client owner.
                        // ======User Story======
                        // When a non-private opportunity is created on the Client by a different user
                        // (i.e., who does not own the Client) notify by email the Client owner.
                    
                        // If the Opportunity is private (i.e., the Private flag is checked by the user at creation)
                        // then do not notify the Client Owner, even if the Client Owner has the same role as the 
                        // Opportunity Owner (i.e., the same 'team').
                        // If the Opportunity Owner has a Private role (today configured as either DCM or Advisory)
                        // and the Client Owner has a different role then do not notify the Client Owner. (removed Case#548)
                        // If the Opportunity Owner has a Private role and the Client Owner has the same role
                        // (i.e., the same 'team') then do notify the Client Owner. (removed Case#548)
                        // If the Opportunity is Public AND the Client Owner wants to receive the email
                        // notifications (this is a user-configurable preference) then notify the
                        // Client Owner via email.
                        // Note: if you believe that users should not be able to configure this preference
                        // it is a simple matter of altering the Field Level Security so that only
                        // System Administrators can configure the preference.
                        // ASSUMPTION: Users on the ‘public’ side of the wall should NEVER know anything
                        // about opportunities created by users on the ‘private’ side of the wall.
                        // ASSUMPTION: Client Owners who create Opportunities do not need to be notified.
                    
                        // NOTE: 'Notify' in this context means copying the user's checkbox to the Opportunity checkbox.
                        // The value of the checkbox is then used by a workflow rule to determine whether to send the email.
                        // Workflow Rule: Notify Client Owner If Opportunity Owner Different
                        
    @ Last Modified By  : Tracy Roberts
    @ Last Modified On  : 02 November 2012  
    @ Last Modified Reason  : Case#8735 - Client Name on Product not updating if Client Name on Opportunity updates.                      
    @ Description   : Update the handleOpportunityBeforeUpdateTrigger() method to update the Client on the Product 
                        if the Client on the Opportunity is being Updated.
    
    @ Last Modified By  : Charles Mutsu
    @ Last Modified On  : 25 January 2013  
    @ Last Modified Reason  : EN-0021 Added one method to sync the Opportunity Products    
                              Changed the version from 26 to 27 
                              
    @                          
    @ Last Modified By  :   Navin Rai
    @ Last Modified On  :   14/06/2013
    @ Last Modified Reason  : EN-101.Reverted to standard OpportunityTeamMember.Hence,removed 
                              Custom_sales_Team functinality.
                              Changed the version to 28.

    @ Last Modified By  :   Petr Roubal
    @ Last Modified On  :   12 Feb 2016
    @ Last Modified Reason  : CASE C-00001574 Total Revenue fields on the Opportunity are not in sync with the Product Revenues on the related Products
                               - added a condition which allows to propagate 0 value from 'Product Revenue' to 'Ammount'

    @ Last Modified By  : Petr Roubal
    @ Last Modified on  :  29 Feb 2016
    @ Last Modified Reason  : EN-0947 CST - dependency between Opp team role and user global area

    @ Last Modified By  : Petr Roubal
    @ Last Modified on  :  18 Apr 2016
    @ Last Modified Reason  : US-1273 RTB - OM - Game Changers Revenue Fields and Roll up Calculations
    
    @ Last Modified By  : Manoj Gupta
    @ Last Modified on  :  27 June 2016
    @ Last Modified Reason  : US-1391 RTB - OM - Game Changers additional roll up fields
    
    @ Last Modified By  : Manoj Gupta
    @ Last Modified on  :  Aug 2016
    @ Last Modified Reason  : US 1459:RTB - GC - Update the Probability based on Opportunity
    
    @ Last Modified By  : Manoj Gupta
    @ Last Modified on  :  Aug 2016
    @ Last Modified Reason  : US 1499 (DEF-002078): Moved the GameChanger logic  from Opportunitytriggerutility to OpportunityTriggerHelper class
                                                    (For above mentioned user stories US-1273,US-1391,US 1459) 

    @ Author        :     Wayne Solomon
    @ Date          :     7 Oct 2019
    @ Description   :     C-00002944 - Used a flag to temporarily disable a
                          validation rule to allow the save method to execute
                          in handleOpportunityBeforeUpdateTrigger and disbled
                          in handleOpportunityAfterUpdateTrigger

     @author         : Derek
    @date           : 6 April 2022
    @description    : Exclude the new Africa_Regions_Opportunity from the change in record type based on stage
                      Replace use of Name with DeveloperName (as that is best practice)

    @author         : Dzianisik Maksim
    @date           : April 2023
    @description    : SFP-9010 removed references for deprecated RecordTypes as a part of decommission story ('1 - Lead Opportunity', '2 - Develop Opportunity')
****************************************************************************/
public with sharing class OpportunityTriggerUtility {
    
    // public final variables
    public static final string LEAD_STAGE_VALUE             ='1 - Lead';
    public static final string DEVELOP_STAGE_VALUE          ='2 - Develop';
    
    /**
     * @description SA Global Markets Commodoties, Corporates and Buy-Side deals that are closed must be flagged for inclusion in 
        the CRT Feed for opportunities that where created after March 2011.
        When 
              Opportunity StageName IN ("3 - Closed Won","4 - Closed Lost")
          AND Opportunity Owner Global Area = "CIBSA" 
          AND Opportunity Owner Division = "Global Markets" 
          AND Opportunity Owner Business Unit IN ("Commodities","Corporates","Buy-Side")
          AND Opportunity Created After 31 March 2011 
        Do
            Set the Opportunity CIBSA Global Markets CRT Feed field to true

	 * @param newRecs
    */
    public static void handleOpportunityBeforeInsertTrigger(List<Opportunity> newRecs){
       Set<Id> closedOpportunityOwnerIds = new Set<Id>();
        
        for(Opportunity newRec : newRecs){
            if ((Date.today() > Date.newInstance(31, 3, 2011)) && (newRec.StageName=='3 - Closed Won' || newRec.StageName=='4 - Closed Lost')){
                //add rec to oppylist 
                closedOpportunityOwnerIds.add(newRec.OwnerId);
            } 

            //CASE-01258 Update Actual Close Date
            if ((newRec.StageName=='3 - Closed Won' || newRec.StageName=='4 - Closed Lost' || newRec.StageName == 'Cancel') && (newRec.Actual_Close_Date__c == Null)){
                //update actualCloseDate with Todays() date.
                newRec.Actual_Close_Date__c = Date.Today();
            } 
             
            //CASE-01690 Update Start Date
            if (newRec.Start_Date__c == Null){
                //update Satrt Date with Todays() date.
                newRec.Start_Date__c = Date.Today();
            }
            newRec.CurrencyIsoCode = 'ZAR';

        }
        // CASE-EMEA_SOW_StandardBank_009 - notify by email the Client owner
        set<Id> setAccIds = new set<Id>();
        map<Id, Boolean> mapAccIdToOwnerFlag = new map<Id, Boolean>();
    
        // Fetch User info for closed opportunities
        Map<Id, User> opportunityOwnerUserMap = new Map<Id,User>();
        if (!closedOpportunityOwnerIds.isEmpty()) {
            opportunityOwnerUserMap = new Map<Id, User>([
                SELECT User_CIB_Global_Area__c,
                    User_Division__c,
                    Business_Unit__c
                FROM User
                WHERE Id IN :closedOpportunityOwnerIds]);
        }
        User opportunityOwner;
        for(Opportunity newRec : newRecs){
            // Get the Account Ids    
            setAccIds.add(newRec.AccountId);
            // Identify new opportunities that have been closed recently. 
            if ((Date.today() > Date.newInstance(31, 3, 2011)) && (newRec.StageName=='3 - Closed Won' || newRec.StageName=='4 - Closed Lost')){
                //check if user is from SA Global Markets Commodoties, Corporates and Buy-Side
                opportunityOwner = opportunityOwnerUserMap.get(newRec.ownerId);
                if ((opportunityOwner.User_CIB_Global_Area__c == 'CIBSA') && (opportunityOwner.User_Division__c == 'Global Markets') && (opportunityOwner.Business_Unit__c=='Commodities' || opportunityOwner.Business_Unit__c=='Corporates' || opportunityOwner.Business_Unit__c=='Buy-Side')){
                    newRec.SA_Won__c = true;
                }
            }
        }
        // Fetch Client Owner info
        for (list<Account> listAccs : [select id,
                                      Name,
                                      Owner.Notify_when_Opportunity_created_by_other__c
                                      from Account
                                      where Id in : setAccIds]) {
            for (Account acc : listAccs) {
                mapAccIdToOwnerFlag.put(acc.Id, acc.Owner.Notify_when_Opportunity_created_by_other__c);
            }
        }
        for(Opportunity newRec : newRecs){
             System.debug('## newRec.IsPrivate: ' + newRec.IsPrivate); 
            if (!newRec.IsPrivate && mapAccIdToOwnerFlag.get(newRec.AccountId)!=null){
                System.debug('## Opportunity is public (i.e., not private) - copy Client Owners flag: ' + mapAccIdToOwnerFlag.get(newRec.AccountId)); 
                newRec.Client_Owner_Notify_Oppty_Create__c = mapAccIdToOwnerFlag.get(newRec.AccountId);
            } else {
                System.debug('## The Opportunity is private - no action required');
            }
        }

    }
    static Boolean runbeforeonce = false;
    
    /**
     * @description SA Global Markets Commodoties, Corporates and Buy-Side deals that are closed must be flagged for inclusion in 
        the CRT Feed for opportunities that where created after March 2011.
        When 
              Opportunity StageName IN ("3 - Closed Won","4 - Closed Lost")
          AND Opportunity Owner Global Area = "CIBSA" 
          AND Opportunity Owner Division = "Global Markets" 
          AND Opportunity Owner Business Unit IN ("Commodities","Corporates","Buy-Side")
          AND Opportunity Created After 31 March 2011 
        Do
         Set the Opportunity CIBSA Global Markets CRT Feed field to true
        Additional context:
            This flag will be set to true whenever the condition is met and the flag is not set already.

	 * @param oldMap
	 * @param newMap
    */
    public static void handleOpportunityBeforeUpdateTrigger(Map<Id, Opportunity> oldMap, Map<Id, Opportunity> newMap){
        Set<Id> closedOpportunityOwnerIds = new Set<Id>();
        List<SB_Product__c> listProducts = new List<SB_Product__c>();
        List<SB_Product__c> listProductsNew = new List<SB_Product__c>();
        Id oppId = null;

        for(Opportunity newRec : newMap.values()){
            Opportunity oldRec = oldMap.get(newRec.Id);
            //SFP-18038 : Adding opportunity stage to overide the flag for probability validation rule
            if (!runbeforeonce &&
                    (!oldRec.IsClosed && newRec.IsClosed) ||
                    ((!oldRec.IsClosed && !newRec.IsClosed) && ((oldRec.StageName=='1 - Lead' && newRec.StageName=='2 - Develop') || (oldRec.StageName=='2 - Develop' && newRec.StageName=='1 - Lead'))) ||
                	(oldRec.IsClosed && !newRec.IsClosed)
               )
            {
                newRec.OverrideOnClose__c=true;
                runbeforeonce=true;
            }

                // Identify updated opportunities that have been closed recently.
            if ((newRec.createdDate > Date.newInstance(31, 3, 2011)) && !(oldRec.SA_Won__c) && (newRec.StageName=='3 - Closed Won' || newRec.StageName=='4 - Closed Lost')){
                //add rec to oppylist 
                closedOpportunityOwnerIds.add(newRec.OwnerId);
            } 

            // CASE-01258 Update the ActualCloseDate for the Opportunities where the Stage has been changed to Closed Won or Closed Lost. 
            if ((newRec.StageName != oldRec.StageName) && (newRec.StageName=='3 - Closed Won' || newRec.StageName=='4 - Closed Lost' || newRec.StageName == 'Cancel')){
                //update actualCloseDate 
                newRec.Actual_Close_Date__c = Date.Today();
            } 
            // Regression CASE-01898 Sync Amount Field with Total_Revenue_Num__c product roll-up.
            // CASE C-00001574 Total Revenue fields on the Opportunity are not in sync with the Product Revenues on the related Products
            // - added a condition which allows to propagate 0 value from 'Product Revenue' to 'Ammount'
            if (newRec.Total_Revenue_Num__c <> oldRec.Total_Revenue_Num__c ||
                (newRec.No_of_Products__c <> oldRec.No_of_Products__c && newRec.Total_Revenue_Num__c == 0)){
                    newRec.Amount = newRec.Total_Revenue_Num__c;
            }
            
            //Check if the Client on the Opportunity will change
            if (newRec.AccountId <> oldRec.AccountId){
                oppId  = newRec.id;
                //Populate the list with all the Opportunity's Products
                listProducts  = [Select id, Client__c, Opportunity__c From SB_Product__c where Opportunity__c =:oppId];
                
                //Loop through all the Opportunity's Products
                for(SB_Product__c prod : listProducts ){
                    //Assign the new Opportunity's Client to the Products Client
                    prod.Client__c = newRec.AccountId;
                    //Add the updated Products to a list
                    listProductsNew.add(prod);
                }
            }
        }
        //Update the Product
       // update listProductsNew;
        if(listProductsNew.size()>0){
      Database.SaveResult[] s = Database.update(listProductsNew, false);
      } 
        system.debug(logginglevel.error, 'closedOpportunityOwnerIdsJanka' + closedOpportunityOwnerIds);
        // Fetch User info for closed opportunities
        if(closedOpportunityOwnerIds.size()>0){
            Map<Id, User> opportunityOwnerUserMap = new Map<Id,User>([SELECT id, User_CIB_Global_Area__c, User_Division__c, Business_Unit__c FROM user WHERE Id in :closedOpportunityOwnerIds]);
        
        
        User opportunityOwner;
        for(Opportunity newRec : newMap.values()){
            Opportunity oldRec = oldMap.get(newRec.Id);
            // Identify updated opportunities that have been closed recently. 
            if ((newRec.createdDate > Date.newInstance(31, 3, 2011)) && !(oldRec.SA_Won__c) && (newRec.StageName=='3 - Closed Won' || newRec.StageName=='4 - Closed Lost')){
                //check if user is from SA Global Markets Commodoties, Corporates and Buy-Side
                opportunityOwner = opportunityOwnerUserMap.get(newRec.ownerId);
                if ((opportunityOwner.User_CIB_Global_Area__c == 'CIBSA') && (opportunityOwner.User_Division__c == 'Global Markets') && (opportunityOwner.Business_Unit__c=='Commodities' || opportunityOwner.Business_Unit__c=='Corporates' || opportunityOwner.Business_Unit__c=='Buy-Side')){
                    newRec.SA_Won__c = true;
                }
            }
        }
       }
    }

    static Boolean runafteronce = false;
    
    /**
     * @description This flag will be set to true whenever the condition is met and the flag is not set already.

	 * @param oldMap
	 * @param newMap
    */
    public static void handleOpportunityAfterUpdateTrigger(Map<Id, Opportunity> oldMap, Map<Id, Opportunity> newMap){
        for(Opportunity newRec : newMap.values()) {
            Opportunity oldRec = oldMap.get(newRec.Id);
            //SFP-18038 : Adding opportunity stage to overide the flag for probability validation rule
            if (!runafteronce &&
                    (!oldRec.IsClosed && newRec.IsClosed) ||
                    ((!oldRec.IsClosed && !newRec.IsClosed) && ((oldRec.StageName=='1 - Lead' && newRec.StageName=='2 - Develop') || (oldRec.StageName=='2 - Develop' && newRec.StageName=='1 - Lead'))) ||
                	(oldRec.IsClosed && !newRec.IsClosed)
               )
            {
                update new Opportunity(id = newRec.Id, OverrideOnClose__c = false);
                runafteronce=true;
            }
        }
    }

    /**
     * @description Sync Client Team Opportunity Products

	 * @param newOppList
	 * @param oldOppList
    */
    public static void syncClientTeamOpportunityProducts(List<Opportunity> newOppList, List<Opportunity> oldOppList){
        Set<String> OppAccSetOld= new Set<String>();
        Set<String> OppAccSetNew= new Set<String>();
        List<Id> id_opp=new List<Id>();
        List<Id> id_acc=new List<Id>();
        List<Id> id_oppNew=new List<Id>();
        List<Id> id_accNew=new List<Id>();
        //Creating a unique string with Trigger.old Ids and Account Ids
        for(Opportunity OppOld:oldOppList){            
            OppAccSetOld.add(OppOld.AccountId+'#'+OppOld.Id);            
        }
        //Creating a unique string with Trigger.new Ids and Account Ids        
        for(Opportunity OppNew:newOppList){            
            OppAccSetNew.add(OppNew.AccountId+'#'+OppNew.Id);             
        }       
         if(oldOppList.size()>0 && !(OppAccSetOld.containsAll(OppAccSetNew))){           
            for(Opportunity opp_obj:oldOppList){               
                id_acc.add(opp_obj.AccountId);               
                id_opp.add(opp_obj.Id);               
            }
            for(Opportunity opp_obj:newOppList){               
                id_accNew.add(opp_obj.AccountId);               
                id_oppNew.add(opp_obj.Id);               
            }       
        }

        List<SB_Product__c> prod_to_add_list = new List<SB_Product__c>();
        if(id_opp.size()>0){
            List<ClientTeamOpportunity_Products__c> ctop_to_del=[select Id,Opportunity__c,Product__c,Custom_Client_Team__c from ClientTeamOpportunity_Products__c where Opportunity__c in:id_opp];   
            
            //Deleting CTO Products
            if(ctop_to_del.size()>0){
              //  delete ctop_to_del;
              Database.DeleteResult[] delRs = Database.delete(ctop_to_del, false);
            }
            prod_to_add_list =[
                SELECT Opportunity__c
                FROM SB_Product__c
                WHERE Opportunity__c IN :id_opp
            ];
        }

       Map<Id,List<SB_Product__c>> prodOppMap=new Map<Id,List<SB_Product__c>>();
       List<SB_Product__c> prod_list=new List<SB_Product__c>();       
       for(Id opId:id_opp){
           prod_list=new List<SB_Product__c>();
           for(SB_Product__c sp:prod_to_add_list){
               
               if(opId==sp.Opportunity__c){
                   prod_list.add(sp);
               }    
           }
           prodOppMap.put(opId,prod_list);
       }

       List<Custom_Client_Team__c> cct_to_add_list = new List<Custom_Client_Team__c>();
        if (!id_accNew.isEmpty()) {
            cct_to_add_list = [
                SELECT Account__c
                FROM Custom_Client_Team__c
                WHERE Account__c IN :id_accNew
            ];
        }
       Map<Id,List<Custom_Client_Team__c>> cctOppMap=new Map<Id,List<Custom_Client_Team__c>>();
       List<Custom_Client_Team__c> cct_listNew=new List<Custom_Client_Team__c>();       
       for(Opportunity opp:newOppList){
           cct_listNew=new List<Custom_Client_Team__c>();
           for(Custom_Client_Team__c cct_obj:cct_to_add_list){
               
               if(opp.AccountId==cct_obj.Account__c){
                   cct_listNew.add(cct_obj);
               }    
           }
           cctOppMap.put(opp.Id,cct_listNew);
       }        
       
       List<ClientTeamOpportunity_Products__c> ctopList=new List<ClientTeamOpportunity_Products__c>();
       for(Id opp_to_add:id_opp){
           for(Custom_Client_Team__c cct_to_add:cctOppMap.get(opp_to_add)){           
               for(SB_Product__c prod_to_add: prodOppMap.get(opp_to_add)){           
                   ClientTeamOpportunity_Products__c ctop=new ClientTeamOpportunity_Products__c(Product__c=prod_to_add.Id,Opportunity__c=opp_to_add,Custom_Client_Team__c=cct_to_add.Id);                            
                   ctopList.add(ctop);
               }
           }
       
       }
       // Insert Client Team Opportunity records
       if(ctopList.size()>0){
           //insert ctopList;
           Database.SaveResult[] s = Database.insert(ctopList, false);
       }
       
       List<Id> opp_id_list=new List<Id>();
            for(Opportunity opp:newOppList){
                if(opp.IsPrivate==True){
                    opp_id_list.add(opp.Id);
                }
            }
            
        /*if(opp_id_list.size()>0){
            List<Custom_Sales_Team__c> cst=[select Id,Name from Custom_Sales_Team__c where Opportunity__c in:opp_id_list];
            System.debug('************size'+cst.size());
            if(cst.size()>0){
              //  Delete cst;
              Database.DeleteResult[] delRs = Database.delete(cst, false);
            }
        }*/
    }

    /**
     * @description Retrieve Opportunity - Record Type Id by passing the name of recordtypeName

	 * @param recordTypeName
	 
     * @return Id
    */
    public static Id retrieveRecordTypeId(String recordTypeName) {
       Schema.DescribeSObjectResult d = Schema.SObjectType.Opportunity;
       return d.getRecordTypeInfosByName().get(recordTypeName).getRecordTypeId();
    }
    
    
    /**
     * @description send email for private opportunity

	 * @param newOppMap
     * @param oldOppMap
    */
    public static void SendEmailforPrivateOpp (Map<Id, Opportunity> newOppMap, Map<Id, Opportunity> oldOppMap){ 
             
             set <Id> Opp_Ids = new set<Id> ();
             for (Opportunity Opp : newOppMap.values()){
               if( oldOppMap.get(Opp.Id).Isprivate == false && newOppMap.get(Opp.Id).Isprivate == true){
                          Opp_Ids.add(Opp.Id);                  
                 }
             }  
             if(Opp_Ids.size()>0){
              List <Opportunity> opp_lst = [select id,name,lastmodifiedby.Name from Opportunity where Id IN : Opp_Ids]; 
              if(opp_lst.size() > 0) {
              
                   string emailbody =  '<body style=\'font ="normal 12px Verdana, Arial, sans-serif"\'> Hi there,  <br/><br/>  Below records has been made private recently . Please delete all the queued email for these records.' + '<br/><br/>' + '<table border="1" style=\'border-collapse:"collapse"\'>';
                   emailbody = emailbody + '<tr>  <th bgcolor="#F0F0F0"> Opp. ID </th> <th bgcolor="#F0F0F0">Opp Name</th> <th bgcolor="#A2A7AB">Modified by</th> </tr>';
                   for (Opportunity Opp : opp_lst){
                          emailbody =  emailbody + '<tr><td>'+ Opp.Id + '</td><td>' + Opp.Name  + '</td><td>' + Opp.LastModifiedBy.Name  + '</td></tr>';
                       }
                   emailbody = emailbody+ '</table><br/>' ;
                   emailbody = emailbody + 'Go to Time based workflow . Search based on Record Name and then delete all the queued mail for that record. </body>' ;                                               
                   Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                   mail.setToAddresses(new String[] {'CIBSACRMITPS.CIBCRMITProductionSupport@standardbank.co.za'});
                   String subject ='Delete Queued mail for Private Opp. if any';
                   mail.setHtmlBody(emailbody); 
                   mail.setSubject(subject);
                   Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail }); 
             }
           }  
         }
         
    /**
     * @description Set the Role to the Owner based on the event. Owner should always be present

	 * @param mapNewVersion
     * @param mapOldVersion
     * @param triggerParameter
    */
    public static void addOwnerAsTeamMember(map<Id,Opportunity> mapNewVersion, map<Id,Opportunity> mapOldVersion,boolean triggerParameter){
        List<OpportunityTeamMember> lstOppTeam = new List<OpportunityTeamMember>();
        map<Id,Set<Id>> mapOppIdVsUserIds = new map<Id,Set<Id>>();
        for(OpportunityTeamMember oppTMem : [SELECT id,OpportunityId, UserId, Opportunity.OwnerId, Opportunity.Owner.User_CIB_Global_Area__c FROM OpportunityTeamMember WHERE OpportunityId IN: mapNewVersion.keySet()]){
            Set<Id> userSet = new Set<Id>();
            if(mapOppIdVsUserIds!=null && mapOppIdVsUserIds.containsKey(oppTMem.OpportunityId)){
                userSet = mapOppIdVsUserIds.get(oppTMem.OpportunityId);
                userSet.add(oppTMem.UserId);
                mapOppIdVsUserIds.put(oppTMem.OpportunityId,userSet);
            }
            else if(mapOppIdVsUserIds!=null && !mapOppIdVsUserIds.containsKey(oppTMem.OpportunityId)){
                userSet.add(oppTMem.UserId);
                mapOppIdVsUserIds.put(oppTMem.OpportunityId,userSet);
            }
        }
        
        for(Opportunity opp : mapNewVersion.values()){
            if((!opp.IsPrivate && opp.OwnerId!=null) && (Trigger.isInsert || 
                (mapOldVersion!=null && mapOldVersion.containsKey(opp.Id) && opp.OwnerId != mapOldVersion.get(opp.Id).OwnerId) ||
                (mapOppIdVsUserIds!=null && !mapOppIdVsUserIds.containsKey(opp.Id)) || 
                (mapOppIdVsUserIds!=null && mapOppIdVsUserIds.containsKey(opp.Id) && !mapOppIdVsUserIds.get(opp.Id).contains(opp.OwnerId)))){
                    
                OpportunityTeamMember oppTeamMember = new OpportunityTeamMember();
                oppTeamMember.OpportunityId = opp.Id;
                oppTeamMember.UserId = opp.OwnerId;

                //EN-0947 CST - dependency between Opp team role and user global area
                if(opp.Owner_CIB_Global_Area__c == 'CommB')
                    oppTeamMember.TeamMemberRole = Trigger.isUpdate ? 'CommB Product Specialist' : 'Originator - Primary';
                else
                    oppTeamMember.TeamMemberRole = Trigger.isUpdate ? 'Product Specialist' : 'Originator - Primary';

                if(Trigger.isInsert || (!triggerParameter && mapOldVersion.get(opp.Id).isPrivate==opp.isPrivate) || 
                  (Trigger.isUpdate && triggerParameter && mapOldVersion.get(opp.Id).isPrivate && !opp.isPrivate))
                lstOppTeam.add(oppTeamMember);
            }
        }
        // Insert Owner as Team Member
        if(lstOppTeam.size()>0){
            Database.saveresult[] sr = Database.insert(lstOppTeam, false);
            
        }
    }
    
    /**
     * @description Send the email to Opp Owner is owner is changed on Update event.

	 * @param newOppMap
     * @param oldOppMap
    */
    public static void SendEmailforOwnerChanged (Map<Id, Opportunity> newOppMap, Map<Id, Opportunity> oldOppMap){ 
             
             set <Id> UserIds = new set<Id> ();
             List<Opportunity> lstOpp = new List<Opportunity>();
             List<Messaging.SingleEmailMessage> lstEmails = new List<Messaging.SingleEmailMessage>();
             Environment_Variable__c env = Environment_Variable__c.getInstance();
             
             for (Opportunity Opp : newOppMap.values()){
               if( oldOppMap.get(Opp.Id).OwnerId != newOppMap.get(Opp.Id).OwnerId){
                          UserIds.add(Opp.OwnerId); 
                          lstOpp.add(opp);              
                 }
             }  
             if(UserIds.size()>0){
              map<Id,User> user_lst = new map<Id,User>([SELECT Id, Username, LastName, FirstName, Name, Email from User where Id IN : UserIds]); 
              for(Opportunity opp : lstOpp){
              
                   string emailbody =  '<body style=\'font ="normal 10px Arial, sans-serif"\'> <br/><br/>';
                   
                   emailbody =  emailbody + 'Opportunity ' + opp.Name + ' has been assigned to you. Please click on the link below to view the record.';
                   
                   emailbody = emailbody+ '<br/><br/>' + env.serverURL__c + '/' + opp.Id + '</body>';
                   if(user_lst!=null && user_lst.containsKey(opp.OwnerId)){
                    Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                    mail.setToAddresses(new String[] {user_lst.get(opp.ownerId).email});
                    String subject ='Opportunity transferred to you.';
                    mail.setHtmlBody(emailbody); 
                    mail.setSubject(subject);
                    lstEmails.add(mail); 
                   }
             }
            Messaging.sendEmail(lstEmails);
         }
    }

}