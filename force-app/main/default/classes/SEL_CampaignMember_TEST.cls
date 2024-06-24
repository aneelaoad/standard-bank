/**
 * Test class for SEL_CampaignMember
 *
 * @author Sergio Moradas (The Cocktail)
 * @date October 2021
 */
@IsTest (IsParallel = true)
private class SEL_CampaignMember_TEST {
    @TestSetup
    private static void createTestData() {
        fflib_SObjectUnitOfWork uow = ABS_ObjectBuilderBase.getNewUnitOfWork();
        
        Account ac1 = new Account();
        ac1.Name ='First Account';
        Account ac2 = new Account();
        ac2.Name ='Second Account';
        
		Contact c1 = new Contact();
        c1.LastName = 'l1';
        c1.FirstName = 'F1';
        c1.Email = 'a1@test.com';  
        c1.HasOptedOutOfEmail = true;

        Contact c2 = new Contact();
        c2.LastName = 'l1';
        c2.FirstName = 'F2';
        c2.Email = 'a2@test.com';
        c2.HasOptedOutOfEmail = true;
        
        
        Contact c3 = new Contact();
        c3.LastName = 'l3';
        c3.FirstName = 'F3';
        c3.Email = 'a3@test.com';
        c2.HasOptedOutOfEmail = false;
        
        Individual i1 = new Individual();
        i1.FirstName = 'Wendy';
        i1.LastName = 'Jones'; 
        i1.Email_Address__c = 'i1@test.com';
        
        Individual i2 = new Individual();
        i2.FirstName = 'Wendy';
        i2.LastName = 'Jones'; 
        i2.Email_Address__c = 'i2@test.com';                               
        
        DataUsePurpose dup= new DataUsePurpose();
        dup.Name = 'Direct Marketing';
        dup.IsActive = false;
        uow.registerNew(dup);
        
        ContactPointTypeConsent cpt1 = new ContactPointTypeConsent();
        cpt1.Name = 'Wendy1';
        cpt1.PrivacyConsentStatus= 'Optin';        
        cpt1.EffectiveFrom= date.today()-10;
        cpt1.EffectiveTo=date.today()+2;
        
        ContactPointTypeConsent cpt2 = new ContactPointTypeConsent();
        cpt2.Name = 'Wendy2';
        cpt2.PrivacyConsentStatus= 'OptOut';        
        cpt2.EffectiveFrom= date.today()-10;
        cpt2.EffectiveTo=date.today()+2;
        
        Campaign campaing = new Campaign();
        campaing.Name = 'Test cmp';
        campaing.isActive = true;
        campaing.Campaign_Category__c = DMN_Campaign.CATEGORY_GROUP_EVENT;
        campaing.Type = 'Direct Marketing';
        
        CampaignMember cmpMember1 = new CampaignMember();
        CampaignMember cmpMember2 = new CampaignMember();
        
        uow.registerNew(ac1);
        uow.registerNew(ac2);
		uow.registerNew(c1, Contact.AccountId, ac1);
        uow.registerNew(c2, Contact.AccountId, ac1);
        uow.registerNew(c3, Contact.AccountId, ac2);
        uow.registerNew(i1);
        uow.registerNew(i2); 
        uow.registerNew(cpt1, ContactPointTypeConsent.PartyId, i1);        
        uow.registerNew(cpt2, ContactPointTypeConsent.PartyId, i2);
        uow.registerNew(campaing);

        uow.commitWork();		//insert all
        
        new BLD_CampaignMember(UOW)
            .campaign(String.valueOf(campaing.Id))
            .contact(String.valueOf(c1.Id))
            .invitationResponseAccepted();
        
        new BLD_CampaignMember(UOW)
            .campaign(String.valueOf(campaing.Id))
            .contact(String.valueOf(c2.Id))
            .invitationResponseAccepted();

        c1.IndividualId = i1.Id;
        c2.IndividualId = i2.Id;
        
        uow.registerDirty(c1);
        uow.registerDirty(c2);
        uow.registerDirty(cpt1, ContactPointTypeConsent.DataUsePurposeId, dup);
        uow.registerDirty(cpt2, ContactPointTypeConsent.DataUsePurposeId, dup);
        uow.commitWork();
    }

    @IsTest
    static void selectByCampaign() {
        SEL_CampaignMember.newInstance().selectByCampaign(new Set<Id>());
        fflib_QueryFactory result = fflib_QueryFactory.lastQueryFactory;
        System.assert(result.getCondition().containsIgnoreCase('CampaignId IN :campaignIds'));
    }    
}