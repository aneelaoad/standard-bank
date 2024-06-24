@isTest(SeeAllData=false)
public class CI_ClientListControllerTest{
    private static User user;
    //test method
    private static testMethod void ClientListTest(){

        //Create Manager user
           System.runAs(new User(ID = UserInfo.getUserID())){
               user = (User) new BLD_USER().useSysAdmin().getRecord();
               insert user;
           }
        
         system.runAs(user){
         
            //create account
            RecordType parentRecordType = [select Id from RecordType where Name = 'Ultimate Group Parent' and SobjectType = 'Account' limit 1];
             List<Account> clients = new List<Account>();
            clients.add(new Account(Name ='Google EMEA CICLTest000001', billingCountry='South Africa', CIF__c = 'CICLTest000001', RecordTypeId = parentRecordType.Id));
            clients.add(new Account(Name ='Apple EMEA CICLTest000002', billingCountry='China', CIF__c = 'CICLTest000002', RecordTypeId = parentRecordType.Id));
            insert clients;            
            
            //Create Global Client Revenue record & link client
            RecordType revRT = [select Id from RecordType where Name = 'Current & Previous Year' and SobjectType = 'Global_Client_Revenue__c' limit 1];         
            List<Global_Client_Revenue__c> revenue = new List<Global_Client_Revenue__c>();
            revenue.add(New Global_Client_Revenue__c(Budget_ZAR_Next_Year__c = 1000000, Client_Value_ZAR_Current_Year__c=7000000, RecordTypeId = revRT.id, Client_CIF_Number__c='CIF123', Client__c = clients[0].id));
            revenue.add(New Global_Client_Revenue__c(Budget_ZAR_Next_Year__c = 9000000, Client_Value_ZAR_Current_Year__c=7000000, RecordTypeId = revRT.id, Client_CIF_Number__c='CIF456', Client__c = clients[0].id)); 
            revenue.add(New Global_Client_Revenue__c(Budget_ZAR_Next_Year__c = 1000000, Client_Value_ZAR_Current_Year__c=1000000, RecordTypeId = revRT.id, Client_CIF_Number__c='CIF789', Client__c = clients[1].id));
            revenue.add(New Global_Client_Revenue__c(Budget_ZAR_Next_Year__c = 4000000, Client_Value_ZAR_Current_Year__c=1000000, RecordTypeId = revRT.id, Client_CIF_Number__c='CIF901', Client__c = clients[1].id));
            insert revenue;    
            
            //Link user to client team.
            
            List<Custom_Client_Team__c> addMember = new List<Custom_Client_Team__c>();
            addMember.add(New Custom_Client_Team__c(Account__c = clients[0].id,Team_Member__c = user.id,Client_Role__c = 'Analyst',Client_Access__c = 'Full Access'));
            addMember.add(New Custom_Client_Team__c(Account__c = clients[1].id,Team_Member__c = user.id,Client_Role__c = 'Analyst',Client_Access__c = 'Full Access'));
            insert addMember;
                        
            CI_CardListObjectModel result = (CI_CardListObjectModel)CI_ClientListController.getClientList(null, 'CICLTest000001').Data;

            //Assert that a list of 1 accounts is returned.
            System.assertEquals(1 ,result.cardObjectList.size());  

        }
    }
}