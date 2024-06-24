/*************************************************************************\
    @ Author        :     Nitish Kumar
    @ Date          :     July,2013
    @ Test File     :     Createactivities Class
    @description   :     Createactivities to be tested
    
    @ Last Modified By  :   Charles Mutsu    
    @ Last Modified On  :   05-Aug-2013
    @description   :       Updated API version from 26 to 28
    
****************************************************************************/

@IsTest
Public class Createactivities_test {

    @IsTest
    static void testCreateActivitiesController() {
        Createactivities cont = new Createactivities();
        PageReference p1 = cont.logevent();
        PageReference p2 = cont.logtask();
        PageReference p3 = cont.newopp();
        System.assertNotEquals(null, p1);
        System.assertNotEquals(null, p2);
        System.assertNotEquals(null, p3);
    }
}