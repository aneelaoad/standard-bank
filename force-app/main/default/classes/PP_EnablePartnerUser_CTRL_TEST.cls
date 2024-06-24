/**
* @description  : Test Class for PP_EnablePartnerUser_CTRL
*
* @author Syed Ovais Ali (syed.ali@standardbank.co.za)
* @date Sept 2021
*/
@IsTest
public class PP_EnablePartnerUser_CTRL_TEST {
    
    @IsTest
    static void enablePartnerUser() {
        
        UserRole userrole = [Select Id, DeveloperName From UserRole Where DeveloperName = 'Corporate_Investment_Banking' Limit 1];
        User adminUser = [Select Id, UserRoleId From User Where Profile.Name='System Administrator' AND isActive = true Limit 1];
        adminUser.UserRoleId = userRole.Id;
        update adminUser;
                    
        System.runAs(adminUser) {
            
            fflib_SObjectUnitOfWork uow = ABS_ObjectBuilderBase.getNewUnitOfWork();
            Account acc = (Account) new BLD_Account(uow).
                recordTypeId(UTL_RecordType.getRecordTypeId(DMN_Account.OBJ_NAME,DMN_Account.RT_ONBOARDED_PARTNER))
                .getRecord();
            uow.commitwork();  
            
            Contact contact = (Contact) new BLD_Contact(uow).name('Test','Test').getRecord();
            contact.AccountId = acc.Id;
            uow.commitwork();   
            
            PP_PartnershipOpportunity__c partnershipOppty = (PP_PartnershipOpportunity__c) new BLD_PartnershipOpportunities(uow)
                .setPartnershipOpptyData().getRecord();
            uow.commitwork();       
            
            PP_PartnerApplication__c partner = (PP_PartnerApplication__c) new BLD_PartnerApplication(uow)
                .setPartnerData()
                .setAccount(acc.Id)
                .setPrimaryContact(contact.Id).getRecord();
            uow.commitwork();
            
            partner.PP_ApplicationStatus__c = DMN_PP_PartnerApplication.STATUS_APPROVED;
            uow.registerDirty(partner);
            uow.commitwork();
            
            SEL_PartnerApplication.newInstance().selectByPrimaryContactId(new Set<Id>{contact.id});
            
            Test.startTest();
            User result = PP_EnablePartnerUser_CTRL.checkPartnerUser(partner.Id);
            Contact result2 = PP_EnablePartnerUser_CTRL.getPartnerContact(partner.Id);
            PP_EnablePartnerUser_CTRL.enablePartnerUser(partner.Id);
            system.assertEquals(result.username, null);
            system.assertEquals(result2.LastName, 'Test');
            Test.stopTest();
        }
    }
}