/*****************************************************************************************************\
    @ Author        : Rudolf Niehaus
    @ Date          : 12/2010
    @description   : Test Class for trigger User_BankContact_Sync
    
    
    @ Last Modified By  :   Anand Nancharla
    @ Last Modified On  :   17th Aug 2011
    @ Modified Reason   :   Code comments whereever Domain_UserName__c is no longer used.
                            Case C-00000178
                            
    @ Last Modified By: Charles Mutsu
    @ Last Modified Date: 01/02/2013
    @ Description:  Implemented TestDataUtilityClass for generating Test Data
    				Changed the version from 20 to 27.
******************************************************************************************************/
@IsTest
private class Test_User_BankContact_SyncTrigger {

    @IsTest
    static void testTrigger() {
        try {
            User testUser = (User) new BLD_USER().useSysAdmin().getRecord();
            testUser.Department = 'BLA';
            testUser.Email = 'gunsNroses@sweetOmine.com';
            testUser.Fax = '34534534';
            testUser.FirstName = 'Axel';
            testUser.LastName = 'Rose';
            testUser.Alias = 'arose1';
            testUser.Street = '10 perth';
            testUser.State = 'gauteng';
            testUser.PostalCode = '121';
            testUser.Country = 'SA';
            testUser.City = 'Jhb';
            testUser.MobilePhone = '4242342';
            testUser.Phone = '2345345345';
            testUser.Title = 'Rock Star';
            testUser.Birth_Day_Month__c = '11/12';
            testUser.Business_Unit__c = 'Unknown';
            testUser.User_Division__c = 'Unknown';
            testUser.User_CIB_Global_Area__c = 'CIBI';
            testUser.User_Team__c = 'FRC';
            testUser.LanguageLocaleKey = 'en_US';
            testUser.LocaleSidKey = 'en_GB';
            testUser.Username = 'axlerose7311@test12345.com';
            testUser.CommunityNickname = 'RUDIx';
            testUser.isActive = true;
            testUser.TimeZoneSidKey = 'GMT';
            testUser.CurrencyIsoCode = 'USD';
            testUser.EmailEncodingKey = 'ISO-8859-1';

            insert testUser;

            testUser.Department = 'BLA1';
            testUser.Email = 'gunsNroses1@sweetOmine.com';
            testUser.Fax = '345345341';
            testUser.FirstName = 'Axel1';
            testUser.LastName = 'Rose1';
            testUser.Street = '10 perth1';
            testUser.State = 'gauteng1';
            testUser.PostalCode = '1211';
            testUser.Country = 'SA1';
            testUser.City = 'Jhb1';
            testUser.MobilePhone = '42423421';
            testUser.Phone = '23453453451';
            testUser.Title = 'Rock Star1';
            testUser.Birth_Day_Month__c = '12/12';
            testUser.Business_Unit__c = 'Unknown';
            testUser.User_Division__c = 'Unknown';
            testUser.User_CIB_Global_Area__c = 'CIBI';
            testUser.User_Team__c = 'FRC';
            testUser.LanguageLocaleKey = 'en_US';

            update testUser;
        }
        catch (Exception ex) {
            System.assert(false, ex.getMessage());
        }
    }

}