/*****************************************************************************************************\
    @ Func Area     : Draw_Down_Profile__c
    @ Author        : Nikhita Reddy
    @ Date          : 06/02/2014
    @ Test File     : Test Method DrawDownProfileTriggerFunctions_Class
    @ Description   : Test class for DrawDownProfileTriggerFunctions_Class class
******************************************************************************************************/
@IsTest
public class DrawDownProfileTriggerFunctions_C_Test{

    static testMethod void DrawDownProfileTriggerFunctions_C_Test() {

        //Create User
        fflib_SObjectUnitOfWork uow = ABS_ObjectBuilderBase.getNewUnitOfWork();

        User userBld = (User) new BLD_USER(uow)
                .profile(DCN_Profile.SYS_ADMIN)
                .getRecord();

        System.runAs(new User(Id = UserInfo.getUserId())){
            uow.commitWork();
        }

        //create hierarchy custom setting
        Environment_Variable__c stdEnVariable= TEST_DataFactory.getEnvironmentVariable();

        insert stdEnVariable;



        Test.startTest();

        System.runAs(userBld) {

            BLD_Account accBld = new BLD_Account(uow).useChild();

            BLD_Opportunity oppBld= new BLD_Opportunity(uow).client(accBld);

            BLD_Product productBld = new BLD_Product(uow).linkToOpp(oppBld);

            BLD_DrawDownProfile drawDownProfileBld = new BLD_DrawDownProfile(uow)
                    .linkToProduct(productBld)
                    .drawDate(Date.today())
                    .drawDownNumber(10)
                    .funding(10.0);

            uow.commitWork();

            //Call reorderSequenceNumbers(), as we have updated Draw_Down_Number__c
            DrawDownProfileTriggerFunctions_Class.reorderSequenceNumbers(productBld.getRecordId());

            //Statement to check success of update operation
            System.assertEquals(10,((Draw_Down_Profile__c)drawDownProfileBld.getRecord()).Draw_Down_Number__c);
        }

        Test.stopTest();

    }
}