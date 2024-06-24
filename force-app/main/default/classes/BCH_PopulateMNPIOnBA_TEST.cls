/**
 * Test class for BCH_PopulateMNPIOnBA class
 *
 * @author		Youssef Ibrahim (yibrahim@deloittece.com)
 * @date		December 2020
 */
@IsTest
public class BCH_PopulateMNPIOnBA_TEST {
    static User testUser;
    static Assessment_Opportunity__c assessmentOpportunity;

    @TestSetup
    static void setup() {
        TEST_DataFactory.generateConfiguration();
        fflib_SObjectUnitOfWork uow;
        System.runAs(new User(Id = UserInfo.getUserId())) {
            uow = ABS_ObjectBuilderBase.getNewUnitOfWork();
            testUser = (User) new BLD_USER(uow).userName('testMNPIBA@test.com').useCib().division('Transactional Products and Services').syncContact().getRecord();
            uow.commitWork();
        }
        System.runAs(testUser) {
             BLD_Opportunity bldOpp = new BLD_Opportunity(uow)
                    .priceSensitive(true)
                    .name('Test populate MNPI')
                    .addAssessmentOpportunity(
                            new BLD_Assessment_Opportunity(uow)
                            .businessAssessment(new BLD_BusinessAssessment(uow).mnpi(false))
                    );
            uow.commitWork();
        }

    }

    static void getData() {
        testUser = [
                SELECT Username, Division, IsActive
                FROM User
                WHERE Username = 'testMNPIBA@test.com'
                LIMIT 1];

        assessmentOpportunity = [
                SELECT Id, Opportunity__r.Price_Sensitive__c,
                        Business_Assessment__r.MNPI__c
                FROM Assessment_Opportunity__c
                WHERE Opportunity__r.Name = 'Test populate MNPI'
                LIMIT 1
        ];
    }


    @IsTest
    static void shouldUpdateBaWithMnpi() {
        getData();
        System.runAs(testUser) {

            System.assert(!assessmentOpportunity.Business_Assessment__r.MNPI__c);

            Test.startTest();
            BCH_PopulateMNPIOnBA populateMNPIonBA = new BCH_PopulateMNPIOnBA(new List<String>{'testMNPIBA@test.com'});
            Database.executeBatch(populateMNPIonBA);
            Test.stopTest();
            Assessment_Opportunity__c resultingAO = [
                    SELECT Id, Opportunity__r.Price_Sensitive__c,
                            Business_Assessment__r.MNPI__c
                    FROM Assessment_Opportunity__c
                    WHERE Id = :assessmentOpportunity.Id
            ];
            System.assert(resultingAO.Business_Assessment__r.MNPI__c);

        }
    }
}