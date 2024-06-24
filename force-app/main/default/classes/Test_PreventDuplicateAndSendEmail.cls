/*************************************************************************\
    @ Author        :     Rambabu Tummagunta
    @ Date          :     1 Sept 2011
    @ Test File     :     N/A
    @description   :     Test Class for PreventDuplicateAndSendEmail Trigger.
    
    @ Last Modified By: Charles Mutsu
    @ Last Modified Date: 01/03/2013
    @ Description:  Implemented TestDataUtilityClass for generating Test Data
                    Changed the version from 20 to 27.
    
    @ Last Modified By  :   Charles Mutsu    
    @ Last Modified On  :   05-Aug-2013
    @ Description   :       Updated API version from 27 to 28
                                           
****************************************************************************/
@isTest
private class Test_PreventDuplicateAndSendEmail {

    @IsTest
    static void preventDuplicateAndSendEmailToNonUserClientTeam() {

        fflib_SObjectUnitOfWork uow = ABS_ObjectBuilderBase.getNewUnitOfWork();

        BLD_Account accBld = new BLD_Account(uow).useChild()
            .name(DMN_Account.STANDARD_BANK_EMPLOYEES);

        BLD_Contact bankConBld1 = new BLD_Contact(uow).useBankContact()
            .account(accBld);
        BLD_Contact bankConBld2 = new BLD_Contact(uow).useBankContact()
            .account(accBld);

        uow.commitWork();

        Test.startTest();
        try {
            new BLD_NonUserClientTeam(uow).client(accBld).contact(bankConBld1);
            new BLD_NonUserClientTeam(uow).client(accBld).contact(bankConBld2);
            uow.commitWork();
        }
        catch(Exception ex) {
            System.assert(false, ex.getMessage());
        }
        Test.stopTest();

    }

}