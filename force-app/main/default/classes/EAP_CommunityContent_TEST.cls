/**
 * @description       : 
 * @author            : TCK
 * @group             : 
 * @last modified on  : 06-27-2022
 * @last modified by  : TCK
**/
@IsTest(IsParallel=true)
public class EAP_CommunityContent_TEST {
    @IsTest
    static void testRedirectToPing() {
        EAP_CommunityContent myCommunityCtrl = new EAP_CommunityContent();
        object pingPageReference = myCommunityCtrl.doRedirectToPing();
        System.assert(pingPageReference instanceof PageReference, 'It doesn\'t return a PageReference');
        
    }
}