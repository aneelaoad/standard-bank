/*****************************************************************************************************\ 
    @ Author        : Rudolf Niehaus
    @ Date          : 11/09/2012
    @description   : Case#6220 : Test class for CampaignHostsTriggerFunctions.cls
    
    @ Last Modified By  : Nikhita Reddy
    @ Last Modified On  : 17/01/13
    @ Last Modified Reason  : EN - 0008 - Adding best practices to the test class
                              Updated the API version from 24 to 27.
******************************************************************************************************/
@isTest(SeeAllData = False)
private class CampaignHostsTrigger_Test {

    //Static data Member
    public static List < Campaign > olstCampaign;
    public static List < Campaign_Hosts__c > olstCampaignHost;

    /**
     * @author Nikhita Reddy
     * @date 17/01/2013
     * @description Sets up the test data
     */
    static void setupTest() {
        fflib_SObjectUnitOfWork uow = ABS_ObjectBuilderBase.getNewUnitOfWork();

        BLD_Contact conBld = new BLD_Contact(uow)
            .account(new BLD_Account(uow));

        olstCampaign = new List<Campaign>();
        olstCampaignHost = new List<Campaign_Hosts__c>();
        for (Integer i = 0; i < 2; i++) {
            BLD_Campaign campBld = new BLD_Campaign(uow)
                .addMember(
                    new BLD_CampaignMember(uow).contact(conBld)
                )
                .addMemberHost(
                    new BLD_CampaignMemberHost(uow).member(conBld)
                        .addHost(
                            new BLD_CampaignHost(uow).bankContact(conBld)
                        )
                );
            olstCampaign.add((Campaign) campBld.getRecord());

            olstCampaignHost.add((Campaign_Hosts__c) new BLD_CampaignHost(uow)
                .memberHost(
                    new BLD_CampaignMemberHost(uow)
                        .campaign(campBld)
                        .member(conBld)
                )
                .getRecord());
        }

        uow.commitWork();

    }

    /**
     * @author Nikhita Reddy
     * @date 17/01/2013
     * @description Testing the functionality
     */
    @IsTest
    public static void testCampaignHostTrigger() {
        setupTest();
        Test.startTest();
        set < Id > cIds = new set < Id > ();
        for (integer i = 0; i < olstCampaign.size(); i++) {
            cIds.add(olstCampaign[i].id);
        }
        CampaignHostsTriggerFunctions.recalculateHostCount(cIds);
        delete olstCampaignHost[0];
        Test.stopTest();
        List<Campaign> campaigns = [SELECT Id, Number_of_Hosts__c FROM Campaign];
        for(Campaign campaign : campaigns) {
            System.assertNotEquals(null, campaign.Number_of_Hosts__c);
        }
    }
}