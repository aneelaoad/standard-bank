/**
 * Test class for SEL_KnowledgeExceptions
 *
 * @author Wayde Fagan (wayde.fagan@tetrad.co.za)
 * @date October 2020
 */
@IsTest(IsParallel=true)
public class SEL_KnowledgeExceptions_Test {
    
	@IsTest
    static void shouldGetKnowledgeExceptions() {
        List<Knowledge_Entitlement_Exception__c> result = SEL_KnowledgeExceptions.newInstance().selectByContactIdWoSharing(new Set<Id>());
        System.assertNotEquals(null, result);
    }
}