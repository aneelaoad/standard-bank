@isTest
public class CI_ClientSearchControllerTest {

       private static void setupTestData() {   

            RecordType parentRecordType = [select Id from RecordType where Name = 'Ultimate Group Parent' and SobjectType = 'Account' limit 1];      
            Account ParentClient = new Account(Name ='Google Africa', CIF__c = 'CI123',RecordTypeId = parentRecordType.Id);                    
            insert ParentClient;  
            
            RecordType childRecordType = [select Id from RecordType where Name = 'Child' and SobjectType = 'Account' limit 1];  
            Account childClient1 = new Account(Name ='Google SA', ParentId  =ParentClient.id ,RecordTypeId = childRecordType.id, Group_Parent__c = ParentClient.id);                    
            insert childClient1;  
            
            Account childClient2 = new Account(Name ='Google Nigeria', ParentId  =ParentClient.id ,RecordTypeId = childRecordType.id, Group_Parent__c = ParentClient.id);                    
            insert childClient2;          
        }
        
        static testMethod void testSearchClients() {
            setupTestData();

            //searchClients Method
            List <Account> clientsReturned = CI_ClientSearchController.searchClients('Google');
            System.assertEquals(3, clientsReturned.size());
            
        }
        
        static testMethod void testGetClientHierarchyJson() {
            setupTestData();

            List<Account> client = [select id, Parentid, Name from Account where name like : '%Google%'];

            //getClientHierarchy Method 
            String returnedJsonString = CI_ClientSearchController.getClientHierarchyJson(client[0].id);  
                               
            String removeFirstBracket = returnedJsonString.removeStart('[');              
            string removeLastBracket= removeFirstBracket.removeEnd(']');

            HierarchyComponentController.AccountNode jsonResults = (HierarchyComponentController.AccountNode ) JSON.deserialize(removeLastBracket , HierarchyComponentController.AccountNode.class);
            
            system.assertEquals('Google Africa', jsonResults.account.name);
            system.assertEquals(2, jsonResults.childAccountsNodes.size());     
           
        }
        
        static testMethod void testGetClientHierarchy() {     
            setupTestData();

            List<Account> client = [select id, Parentid, Name from Account where name like : '%Google%'];
            
            //getClientHierarchy Method 
            HierarchyComponentController.AccountNode resultsList = CI_ClientSearchController.getClientHierarchy(client[0].id);                         
            system.assertEquals('Google Africa', resultsList.account.name);
            system.assertEquals(2, resultsList.childAccountsNodes.size());                                               
        }       
}