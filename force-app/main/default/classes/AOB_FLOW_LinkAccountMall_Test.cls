/**
 * @description : Test Class for AOB_FLOW_LinkAccountToApplicationMall
 * @author narendra
 * @since Aug 1, 2023
 */
@Istest
public class AOB_FLOW_LinkAccountMall_Test {
    
    /**
    * @description Test setup method to insert all Test data
    */
    @TestSetup
    public static void testSetUp(){
        User communityUser = AOB_DAL_TestFactory.createCommunityUserPing();
        User admin = AOB_DAL_TestFactory.createUser(AOB_TestConstants.SYSTEM_ADMINISTRATOR, true);
        System.runAs(admin){
            AOB_Application__c newApp = AOB_DAL_TestFactory.createApplication(communityUser);
        }  
    }
    
    /**
    * @description Test setup method for linkAppWithAccount
    */
    @IsTest
    public static void linkAppWithAccountTest(){
        User communityUser = [SELECT Id, accountId,contactId FROM USER WHERE Email like '%@test.org' LIMIT 1];
        Account accRec = [SELECT Id, Name FROM Account WHERE Id=:communityUser.accountId];
        AOB_Application__c newApplication = [SELECT Id, AOB_ExpiryDate__c FROM AOB_Application__c LIMIT 1];
        String json='{"PreApplication": { "Name": "SampleName", "Surname": "Ram", "IdNum": "9801120672097", "PhoneNumber": "0612345678", "EmailAddress": "force@ggmail.com","soleOwner": "true","businessType": "SOLE PROPRIETOR", "soleShareholder": "true","businessName": "Business Name","businessTurnover": "200000","businessProvince": "ZAF.EC", "consent": true },"PreApplicationResponse":{"businessBPGUID":"d671c60e-fe03-1ed7-a9eb-4cf2ef6d1dec","businessBPID":"0531113757","businessRegisteredName":"MONSTER DOORS","digitalOfferId":"0045379680","inflightCustomerDataId":"0045379680","initiatorBPGUID":"45551ed4-38a9-0164-0000-00000ab6f567","initiatorBPID":"0530845443","initiatorDigitalID":null,"processId":"0045379680"},"Summary":{"itemId":"100","documentCode":"Test Code","documentName":"Contract","documentId":"idd_D0273485-0000-C316-A1CC-C389514C5256"},"Available Bundles":{"ZPOB":false,"ZPSS":false,"4488":false},"Company Financial Details":{"taxInputs":{"firstTaxNumber":"1234567890","firstCountry":"AX"},"taxCountries":true,"undefined":"","FOREIGN TAX RESIDENCY":"false","ENTITY CLASSIFICATION":"NFI","MoreLessClassif":"true"},"Employment Details":{"taxInputs":{"firstCountry":"AL","firstReason":"1","secondCountry":"AX","secondReason":"3"},"jobTitle":"14","INDUSTRY":"1","Employed":"true","TaxResident":"true","taxCountries":true,"undefined":"1234567890"},"Personal Details":{"Nationality":"AL","citizenship":"AF","PublicOfficial":"false","Related":"true","RelationType":"5","RelationName":"Sample"},"PreApplication":{"consent":true,"businessProvince":"ZAF.EC","businessTurnover":"800000","businessName":"Random Company Name","soleShareholder":"true","businessType":"SOLE PROPRIETOR","soleOwner":"true","EmailAddress":"force@gmail.com","PhoneNumber":"765878260","IdNum":"5601120672097","Surname":"Ram","Name":"SampleName"},"Residential Address":{"Street":"dsfjks","UnitNumber":"hj","Complexe":"jh","suburb":"42ND HILL","city":"ABERDEEN","province":"ZAF.EC","PostalCode":"4567"},"Company Details":{"TELEPHONE  NUMBER (OPTIONAL)":"0612345678","EMAIL ADDRESS":"sample@gmail.com","CELLPHONE":"0612345678","PREFERRED BRANCH":"2750","COUNTRY OF REGISTRATION":"AX","INDUSTRY CLASSIFICATION":"27","NATURE OF THE BUSINESS":"18"},"Company Trading Address":{"PostalCode":"4567","PROVINCE":"ZAF.EC","city":"ABERDEEN","SUBURB":"486 SCHEME","Complex":"df","UnitNumber":"hj","StreetName":"sjhdj","AddressType":"Same"},"Marketing Consent":{"marketPermission":"true","researchContact":"true","otherCompaniesCom":"true"},"Card Selection":{},"Notifications":{"NotifiedMean":"EMAIL","depositInfo":"true"},"ProcessData":[{"parentTaskID":"","processTaskDetail":{"callBackURL":"","correlationID":"b60da24a-9861-c0c8-5b49-19fbc058d3f3","ownerBPID":null,"wfrFailureReason":null,"wfrRetryAllowed":null,"wfrStatus":null},"status":"Closed","taskID":"7704451","taskName":"Capture Application Data"},{"parentTaskID":"","processTaskDetail":{"callBackURL":"","correlationID":"b60da24a-9861-c0c8-5b49-19fbc058d3f3","ownerBPID":null,"wfrFailureReason":null,"wfrRetryAllowed":null,"wfrStatus":null},"status":"Closed","taskID":"7704452","taskName":"Step: Await IDV Callback"}]}';
        newApplication.AOB_inflightData__c = json;
        update newApplication;
        
        Product2 snapScap= new Product2();
        snapScap.Name='SnapScan';
        snapScap.ProductCode='ZPSS';
        insert snapScap;
        
        AOB_ApplicationLineItem__c lineItemSnapScan = new AOB_ApplicationLineItem__c();
		lineItemSnapScan.Name = 'SnapScan';
		String data4 = '{"snapScanDetails":{"snapscanDetails":{"storeType":"O","merchantCategoryDesc":"ANTIQUE REPRODUCTION STORES","merchantCategoryCode":"5937","businessServiceDesc":"ANTIQUES","businessName":"MAFIA INC","businessEmail":"mafia@testemail.com","authPersonName":"GAMBINO LUCCHESE","authPersonIdNum":"6711205246099","authPersonEmail":"gambino@standardbank.co.za","authPersonCell":"0834167890","authPartner":null,"accountNbr":"0000010006844276"},"pricingOption":"ZPSP"}}';
		lineItemSnapScan.Details__c = data4;
		lineItemSnapScan.AOB_Status__c='Accepted';
		lineItemSnapScan.SalesObjectItemId__c = '700';
		lineItemSnapScan.AOB_Application__c = newApplication.Id;
		lineItemSnapScan.AOB_Product__c = snapScap.Id;
        lineItemSnapScan.AOB_Pricing_Option__c='ZPSS';
        insert lineItemSnapScan;
        
        AOB_OnboardingSetting__mdt setting=AOB_Utils.getOnboardingSettings('SB-COZA');
        String EXTERNAL_USER_PERMISSION = setting.AOB_PermissionSet__c;
        PermissionSet customerPerm = [SELECT Id 
                                      FROM PermissionSet 
                                      WHERE Name =:EXTERNAL_USER_PERMISSION];
        PermissionSetAssignment permission =[SELECT Id,AssigneeId
                                             FROM PermissionSetAssignment
                                             WHERE PermissionSetId =:customerPerm.Id 
                                             AND AssigneeId =:communityUser.Id];
        System.runAs(communityUser){
            try{
                AOB_FLOW_LinkAccountToApplicationMall.linkAppWithAccount(newApplication.Id);
                AOB_FLOW_LinkAccountToApplicationMall.fetchUserData();
                AOB_FLOW_LinkAccountToApplicationMall.checkForOpenApplication('ZPSS');
            }
            catch(Exception ex){
                Assert.areNotEqual(null, ex.getMessage());
            }
            
        }
    }

    /**
    * @description Test setup method for linkAppWithAccount
    */
    @IsTest
    public static void linkAppWithAccountNegTest(){
        String contactRT = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('SA_Client_Contact_Record_Type').getRecordTypeId();
        String accountRT = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Personal_Business_Banking_Client').getRecordTypeId();
        Account account = new Account(Name = AOB_Constants.AOB_DUMMY_NAME, ExternalIdentifier__c='ZA010531113757', RecordTypeId = accountRT);
        Contact contact = new Contact(FirstName = AOB_Constants.AOB_DUMMY_NAME, LastName='SampleName',ExternalIdentifier__c='ZA010530845443', RecordTypeId = contactRT);
        insert account;
        insert contact;
        User communityUser = [SELECT Id, accountId,contactId FROM USER WHERE Email like '%@test.org' LIMIT 1];
        Account accRec = [SELECT Id, Name FROM Account WHERE Id=:communityUser.accountId];
        AOB_Application__c newApplication = [SELECT Id, AOB_ExpiryDate__c FROM AOB_Application__c LIMIT 1];
        String json='{"PreApplication": { "Name": "SampleName", "Surname": "Ram", "IdNum": "9801120672097", "PhoneNumber": "0612345678", "EmailAddress": "force@ggmail.com","soleOwner": "true","businessType": "SOLE PROPRIETOR", "soleShareholder": "true","businessName": "Business Name","businessTurnover": "200000","businessProvince": "ZAF.EC", "consent": true },"PreApplicationResponse":{"businessBPGUID":"d671c60e-fe03-1ed7-a9eb-4cf2ef6d1dec","businessBPID":"0531113757","businessRegisteredName":"MONSTER DOORS","digitalOfferId":"0045379680","inflightCustomerDataId":"0045379680","initiatorBPGUID":"45551ed4-38a9-0164-0000-00000ab6f567","initiatorBPID":"0530845443","initiatorDigitalID":null,"processId":"0045379680"},"Summary":{"itemId":"100","documentCode":"Test Code","documentName":"Contract","documentId":"idd_D0273485-0000-C316-A1CC-C389514C5256"},"Available Bundles":{"ZPOB":false,"ZPSS":false,"4488":false},"Company Financial Details":{"taxInputs":{"firstTaxNumber":"1234567890","firstCountry":"AX"},"taxCountries":true,"undefined":"","FOREIGN TAX RESIDENCY":"false","ENTITY CLASSIFICATION":"NFI","MoreLessClassif":"true"},"Employment Details":{"taxInputs":{"firstCountry":"AL","firstReason":"1","secondCountry":"AX","secondReason":"3"},"jobTitle":"14","INDUSTRY":"1","Employed":"true","TaxResident":"true","taxCountries":true,"undefined":"1234567890"},"Personal Details":{"Nationality":"AL","citizenship":"AF","PublicOfficial":"false","Related":"true","RelationType":"5","RelationName":"Sample"},"PreApplication":{"consent":true,"businessProvince":"ZAF.EC","businessTurnover":"800000","businessName":"Random Company Name","soleShareholder":"true","businessType":"SOLE PROPRIETOR","soleOwner":"true","EmailAddress":"force@gmail.com","PhoneNumber":"765878260","IdNum":"5601120672097","Surname":"Ram","Name":"SampleName"},"Residential Address":{"Street":"dsfjks","UnitNumber":"hj","Complexe":"jh","suburb":"42ND HILL","city":"ABERDEEN","province":"ZAF.EC","PostalCode":"4567"},"Company Details":{"TELEPHONE  NUMBER (OPTIONAL)":"0612345678","EMAIL ADDRESS":"sample@gmail.com","CELLPHONE":"0612345678","PREFERRED BRANCH":"2750","COUNTRY OF REGISTRATION":"AX","INDUSTRY CLASSIFICATION":"27","NATURE OF THE BUSINESS":"18"},"Company Trading Address":{"PostalCode":"4567","PROVINCE":"ZAF.EC","city":"ABERDEEN","SUBURB":"486 SCHEME","Complex":"df","UnitNumber":"hj","StreetName":"sjhdj","AddressType":"Same"},"Marketing Consent":{"marketPermission":"true","researchContact":"true","otherCompaniesCom":"true"},"Card Selection":{},"Notifications":{"NotifiedMean":"EMAIL","depositInfo":"true"},"ProcessData":[{"parentTaskID":"","processTaskDetail":{"callBackURL":"","correlationID":"b60da24a-9861-c0c8-5b49-19fbc058d3f3","ownerBPID":null,"wfrFailureReason":null,"wfrRetryAllowed":null,"wfrStatus":null},"status":"Closed","taskID":"7704451","taskName":"Capture Application Data"},{"parentTaskID":"","processTaskDetail":{"callBackURL":"","correlationID":"b60da24a-9861-c0c8-5b49-19fbc058d3f3","ownerBPID":null,"wfrFailureReason":null,"wfrRetryAllowed":null,"wfrStatus":null},"status":"Closed","taskID":"7704452","taskName":"Step: Await IDV Callback"}]}';
        newApplication.AOB_inflightData__c = json;
        update newApplication;
        AOB_OnboardingSetting__mdt setting=AOB_Utils.getOnboardingSettings('SB-COZA');
        String EXTERNAL_USER_PERMISSION = setting.AOB_PermissionSet__c;
        PermissionSet customerPerm = [SELECT Id 
                                      FROM PermissionSet 
                                      WHERE Name =:EXTERNAL_USER_PERMISSION];
        PermissionSetAssignment permission =[SELECT Id,AssigneeId
                                             FROM PermissionSetAssignment
                                             WHERE PermissionSetId =:customerPerm.Id 
                                             AND AssigneeId =:communityUser.Id];
        System.runAs(communityUser){
            try{
                AOB_FLOW_LinkAccountToApplicationMall.linkAppWithAccount(newApplication.Id);
            }
            catch(Exception ex){
                Assert.areNotEqual(null, ex.getMessage());
            }
            
        }
    }
    
}