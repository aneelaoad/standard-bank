/*****************************************************************************************************\
    @ Author        : Rudolf Niehaus
    @ Date          : September 2011
    @ Description   : Test Class For CampaigHostsWrapper.cls         
                  
    @ Last Modified By  : Wayne Gray
    @ Last Modified On  : June 2012
    @ Modification Description : Move test methods into external class  
                                 Case #6521- Change contact to use TestFatcory
                                 
    @ Last Modified By  : Nitish Kumar
    @ Last Modified On  : Feb 2013
    @ Modification Description : Added best practices to the test class  
                                 EN : 31 - Used TestDataUtility Class
                                 API Version moved from 25 to 27

 	@ Last Modified By  : Vipeen Keshavrao
    @ Last Modified On  : AUG 2023
    @ Modification Description : Test Class updated to increse code coverage
                                 API Version moved from 27 to 58
******************************************************************************************************/

@isTest(SeeAllData = False)
public class CampaigHostsWrapper_Test{     

       /**
         * @author Nitish Kumar
         * @date 19/02/2013
         * @description Tests the functionality
         */

    public static testMethod void testCampaignHostWrapper() {

        CampaigHostsWrapper cw = new CampaigHostsWrapper(
            new Campaign_Member_Host__c(),
            new Set<String>{'a host'},
            new List<Campaign_Hosts__c> {new Campaign_Hosts__c()}
        );
        System.assertEquals(cw.checked,false);
        cw.checked = true;
        System.assertEquals(cw.checked,true);

        CampaigHostsWrapper cw2 = new CampaigHostsWrapper();
        System.assertEquals(cw2.checked,false);
        cw2.checked = true;
        System.assertEquals(cw2.checked,true);

    }
  
    public static testMethod void testCampaignHostWrapper1() {
        
        List<SObject> objects = new List<SObject>{new Account(Name = 'TEST_FIRST_NAME_ONE')};
        insert objects;
        
        Contact con = (Contact) new BLD_Contact().useClientContact().accountId(objects[0].Id).name('test','name').userDivisionSync('Business Enablers').userBusinessUnitSync('CRM').getRecord();
        insert con;
        
        Campaign campaign = new Campaign();
        campaign.Name = 'campaignOnes';
        insert campaign;

        Campaign_Member_Host__c campaignMemberHost = new Campaign_Member_Host__c();
        campaignMemberHost.Campaign__c = campaign.Id;
        campaignMemberHost.Member__c = con.Id;
        insert campaignMemberHost;

        Campaign_Hosts__c campaignHosts = new Campaign_Hosts__c();
        campaignHosts.Campaign_Member_Host__c = campaignMemberHost.Id;
        campaignHosts.Bank_Contact__c = con.Id;
        insert campaignHosts;
        
        
        CampaigHostsWrapper cw = new CampaigHostsWrapper(
            new Campaign_Member_Host__c(),
            new Set<String>{'a host'},
            new List<Campaign_Hosts__c> {campaignHosts}
        );
        System.assertEquals(cw.checked,false);
        cw.checked = true;
        System.assertEquals(cw.checked,true);

        CampaigHostsWrapper cw2 = new CampaigHostsWrapper();
        System.assertEquals(cw2.checked,false);
        cw2.checked = true;
        System.assertEquals(cw2.checked,true);

    }
}