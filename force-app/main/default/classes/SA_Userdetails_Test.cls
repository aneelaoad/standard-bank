/*************************************************************************\
    @ Author        :     Nikhita Reddy
    @ Date          :     3 July 2013
    @ Apex Class    :     SA_Userdetails
    @description   :     Test class for the above class
                          
****************************************************************************/
@isTest(SeeAllData = false)
public class SA_Userdetails_Test{

    @IsTest
    public static void testGetUserDetails() {
        User testUser = (User) new BLD_USER()
                .useCib()
                .firstName('test')
                .division('Agriculture')
                .businessUnit('Business Enablers')
                .getRecord();
        insert testUser;
        
        Test.startTest();
        System.runAs(testUser){
            Test.setCurrentPage(Page.SA_Welcome);
            ApexPages.currentPage().getParameters().put('Id', testUser.Id);
            SA_Userdetails controller = new SA_Userdetails();
            List<User> users = controller.getUserDetails();
            System.assertEquals(1, users.size());
        
        }
        Test.stopTest();
    }    
}