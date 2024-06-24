/**
 * Test class for SEL_Contacts
 *
 * @author		Dyllan Higgins (dyhiggins@deloitte.co.za)
 * @date		March 2021
*/

@IsTest
private class SEL_ClientPlan_TEST{

    @IsTest
    static void ShouldSelectByNoCondition(){
        SEL_ClientPlans.newInstance().selectNoCondition();
        fflib_QueryFactory result = fflib_QueryFactory.lastQueryFactory;
        System.assert(result.getSelectedFields().contains('Id'));
    }
}