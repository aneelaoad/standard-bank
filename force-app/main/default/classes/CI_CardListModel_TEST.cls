/**
 * Test class for CI_CardListModel
 *
 * @author Bartosz Sliwinski (bsliwinski@deloittece.com)
 * @date December 2020
 */
@IsTest (IsParallel = true)
private with sharing class CI_CardListModel_TEST {

    @IsTest
    static void shouldConstructorInitiateCardDataList() {
        CI_CardListModel model = new CI_CardListModel();
        System.assertNotEquals(null, model.cardDataList);
    }

}