@isTest(SeeAllData=false)
public class CI_ClientInfoControllerTest {
        private static User user;
        public static Environment_Variable__c oEnvironmentVariable;
       private static void setupTestData() {

            //////Sys admin user
           System.runAs(new User(ID = UserInfo.getUserID())){
               user = (User) new BLD_USER().useSysAdmin().getRecord();
               insert user;
           }
           
           
             
            ////Clients
            RecordType parentRecordType = [select Id from RecordType where Name = 'Ultimate Group Parent' and SobjectType = 'Account' limit 1];      
            Account parentClient = new Account(Name ='Google Africa', CIF__c = 'CI_TEST_123',RecordTypeId = parentRecordType.Id);                    
            insert parentClient;  
            
            RecordType childRecordType = [select Id from RecordType where Name = 'Child' and SobjectType = 'Account' limit 1];  
            Account childClient1 = new Account(Name ='Google SA', ParentId  =ParentClient.id ,RecordTypeId = childRecordType.id, Group_Parent__c = ParentClient.id);                    
            insert childClient1;  
            
            Account childClient2 = new Account(Name ='Google Nigeria', ParentId  =ParentClient.id ,RecordTypeId = childRecordType.id, Group_Parent__c = ParentClient.id);                    
            insert childClient2;

            ////Contacts
            RecordType rt = [select Id from RecordType where Name = 'Client Contact Record Type' and SobjectType = 'Contact' limit 1];         
            Contact contact1 = new Contact(AccountId = parentClient.Id, firstName = 'Thandi', lastname='Newton', email='thandi@abinbev.com', Contact_Category__c ='CEO', Phone='0119284734', recordTypeId= rt.id);
            insert contact1;

            ////Opportunity
            List<Opportunity> oppList = new List<Opportunity>();
            oppList.add(new Opportunity(Name = 'Test lead', StageName = 'Lead', Amount = 120000, CloseDate = System.today(), 
                                        AccountID = parentClient.Id, LeadSource = 'Service', Description = 'Description', 
                                        Probability = 10, CurrencyIsoCode = 'ZAR', Start_Date__c = System.today()));
            oppList.add(new Opportunity(Name = 'Test develop', StageName = 'Develop', Amount = 450000, CloseDate = System.today(), 
                                        AccountID = parentClient.Id, LeadSource = 'Service', Description = 'Description', 
                                        Probability = 10, CurrencyIsoCode = 'ZAR', Start_Date__c = System.today())); 
            insert oppList;

           oEnvironmentVariable = TEST_DataFactory.getEnvironmentVariable();
           insert oEnvironmentVariable;

            ////Call reports
            //Related to client
            Call_Report__c callRep1 = new Call_Report__c();
            callRep1.Relate_to_Client__c = parentClient.Id;
            callRep1.Meeting_Audience__c = 'External';
            callRep1.End__c = Date.newInstance(2017, 12, 31);
            callRep1.Report_Client_Contact__c = contact1.Id; 
            callRep1.Subject__c = 'Test Subject';
            callRep1.Description__c = 'Test Descrition';
            callRep1.Outcomes__c = 'Test outcomes';
            insert callRep1;

            //Related to opportunity
            Call_Report__c callRep2 = new Call_Report__c();
            callRep2.Relate_to_Opp__c = oppList[0].Id;
            callRep2.Meeting_Audience__c = 'Internal';
            callRep2.End__c = Date.newInstance(2017, 12, 31);
            //callRep2.Report_Client_Contact__c = contact1.Id; 
            callRep2.Subject__c = 'Test Subject';
            callRep2.Description__c = 'Test Descrition';
            callRep2.Outcomes__c = 'Test outcomes';
            insert callRep2;

            ////Client service team
            Custom_Client_Team__c cst = new Custom_Client_Team__c(Team_Member__c = user.Id, Account__c = parentClient.Id, Client_Role__c = DMN_ClientTeam.ROLE_ANALYST);
            insert cst;

            ////KYC
            KYC_Status__c kycN2 = new KYC_Status__c();
            kycN2.Client__c = parentClient.Id;
            kycN2.Client_Contact_Date__c = Date.newInstance(2017, 7, 1);
            kycN2.Status__c = 'N';//Not complete
            insert kycN2;

            KYC_Status__c kycNChild = new KYC_Status__c();
            kycNChild.Client__c = childClient1.Id;
            kycNChild.Client_Contact_Date__c = Date.newInstance(2017, 4, 25);
            kycNChild.Status__c = 'N';//Not complete
            insert kycNChild;
        }

        private static testMethod void getEngagementsTest(){
            setupTestData();

            List<Account> acc = [SELECT Id FROM Account WHERE Name = 'Google Africa'];
            
            CI_CardListObjectModel resultInternal = (CI_CardListObjectModel)CI_ClientInfoController.getEngagements(acc[0].Id, 'Internal').Data;
            System.assertEquals(1, resultInternal.cardObjectList.size());

            CI_CardListObjectModel resultExternal = (CI_CardListObjectModel)CI_ClientInfoController.getEngagements(acc[0].Id, 'External').Data;
            System.assertEquals(1, resultExternal.cardObjectList.size());
        }

        private static testMethod void getClientContactsTest(){
            setupTestData();

            List<Account> acc = [SELECT Id FROM Account WHERE Name = 'Google Africa'];
            
            CI_CardListObjectModel results = (CI_CardListObjectModel)CI_ClientInfoController.getClientContacts(acc[0].Id).Data;
            System.assertEquals(1, results.cardObjectList.size());
        }

        private static testMethod void getClientServiceTeamTest(){
            setupTestData();

            List<Account> acc = [SELECT Id FROM Account WHERE Name = 'Google Africa'];
            System.runAs(user) {
                CI_CardListObjectModel results = (CI_CardListObjectModel)CI_ClientInfoController.getClientServiceTeam(acc[0].Id).Data;
                System.assertEquals(1, results.cardObjectList.size());
            }
        }

        private static testMethod void getKYCAtRiskTest(){
            setupTestData();

            List<Account> acc = [SELECT Id FROM Account WHERE Name = 'Google Africa'];
            
            System.runAs(user) {
                CI_CardListObjectModel results = (CI_CardListObjectModel)CI_ClientInfoController.getKYCAtRisk(acc[0].Id).Data;
                
                System.assertEquals(1, results.cardObjectList.size());
                //90 days after client contacted date
                String suspensionDate = ((Map<String, String>)results.cardObjectList[0]).get('suspensionDate');
                System.assertEquals(String.valueOf(Date.newInstance(2017, 9, 29)) + ' 00:00:00', suspensionDate);
                System.assertEquals('0', ((Map<String, String>)results.cardObjectList[0]).get('revenue'));
            }
        }
}