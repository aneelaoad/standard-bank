/*****************************************************************************************************\
    @ Author        : Rudolf Niehaus
    @ Date          : November 2011
    @ Description   : Test Class For ContactWrapper.cls         
                  
    @ Last Modified By  : Wayne Gray
    @ Last Modified On  : June 2012
    @ Modification Description : Move test methods into external class  
                                 Case #6521- Change contact to use TestFatcory
******************************************************************************************************/

@isTest()
public class ContactWrapper_Test{

    @IsTest
    private static void shouldConstructNewContact() {
        ContactWrapper cw = new ContactWrapper();
        System.assertNotEquals(null, cw.con);
    }

    @IsTest
    private static void shouldAcceptExistingRecordAsContact() {
        Contact con = (Contact) new BLD_Contact().name('John', 'Smith').getRecord();
        ContactWrapper cw = new ContactWrapper(con);
        System.assertEquals(con, cw.con);
    }
  

}