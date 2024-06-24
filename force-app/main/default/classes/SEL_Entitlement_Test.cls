/**
 * Test class for SEL_Entitlement
 *
 * @author Syed Ovais Ali (syed.ali@standardbank.co.za)
 * @date Sep 2021
*/
@IsTest
public class SEL_Entitlement_Test {
    
    @IsTest
    static void selectByName() {
        SEL_Entitlement.newInstance().selectByNameWithoutSharing(DMN_Entitlement.DEFAULT_ENTITLEMENT_NAME);
        fflib_QueryFactory result = fflib_QueryFactory.lastQueryFactory;
        System.assert(result.getCondition().containsIgnoreCase('name =: entitlementName'));
    }

}