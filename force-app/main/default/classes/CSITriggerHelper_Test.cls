/*****************************************************************************************************\
    @ Author        : Praneeth Indraganti
    @ Date          :  2015/04/08
    @ Description   : Test class for CSITrigger and CSITriggerHelper
    
    @Author         : Manoj Gupta
    @Date           : Nov 2015
    @Description    : Modified the Test class to include the changes of EN:701
    
    @Author         : Manoj Gupta
    @Date           : May 2016
    @Description    : Modified the Test class to include the changes of US:1210
******************************************************************************************************/
@isTest(SeeAllData = False)
public with sharing class CSITriggerHelper_Test {
     static testMethod void TriggerFunctionalityTest() {
        List<CsiProjectCountry__c> csiProjCtrs = new List<CsiProjectCountry__c>();
        User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
         System.runAs (thisUser) {

        for (String ctry: new String[]{'South Africa','Botswana','Malawi','Tanzania','Kenya','Mauritius','Uganda','Namibia','Mozambique','Ghana','Nigeria','Angola','Zimbabwe','Zambia','Lesotho'}) {
            csiProjCtrs.add(new CsiProjectCountry__c(name = ctry));
        }
        insert csiProjCtrs;

        Test.startTest();

             fflib_SObjectUnitOfWork uow = ABS_ObjectBuilderBase.getNewUnitOfWork();

             BLD_Account accBld = new BLD_Account(uow).useChild();
             BLD_Contact conBld = new BLD_Contact(uow).useClientContact()
                 .account(accBld);

             BLD_ClientSatisfactionIndex csiBld = new BLD_ClientSatisfactionIndex(uow)
                 .client(accBld)
                 .contact(conBld)
                 .year(System.today().year())
                 .rating(3);

             BLD_ClientSatisfactionIndex csiBld1 = new BLD_ClientSatisfactionIndex(uow)
                 .client(accBld)
                 .year(System.today().year())
                 .rating(9);

             uow.commitWork();

             csiBld.rating(7);
             uow.registerDirty(csiBld);
             uow.commitWork();


        try {
            new BLD_ClientSatisfactionIndex()
                .client(accBld)
                .rating(5)
                .year(System.today().year())
                .projectCountry('France')
                .commitWork();
        }

         catch (Exception e)
        {
        System.Assert(e.getMessage().contains('FIELD_CUSTOM_VALIDATION_EXCEPTION'));
        System.Assert(e.getMessage().contains('France is a not allowed value for the CSI_Project_Country__c field'));
        }




        List<Client_Satisfaction_Index__c> csi = [SELECT Id,Name,OwnerId FROM Client_Satisfaction_Index__c];
          system.assertEquals(2, csi .size() );
        delete csiBld.getRecord();
        delete csiBld1.getRecord();
        List<Account> acc = [SELECT Id,Name,Overall_CIB_CSI_Rating_Number__c FROM Account WHERE Id = :accBld.getRecordId()];
           system.assertEquals(null,acc[0].Overall_CIB_CSI_Rating_Number__c );


        Test.stopTest();
     }
     }
}