/**
 * @description       :
 * @author            : silva.macaneta@standardbank.co.za
 * @group             :
 * @last modified on  : 11-15-2023
 * @last modified by  : silva.macaneta@standardbank.co.za
 **/
@isTest
public class CIB_CTRL_DocumentContainer_Test {
  @isTest
  static void testGetContainerDocuments() {
    // Create test data
    Application__c app = new Application__c(
      CIB_BAI_EntityType__c = 'Locally Incorporated Companies'
    );
    insert app;

    Application_Section__c section = new Application_Section__c(
      Application__c = app.Id,
      ScreenApiName__c = 'cib_comp_basicInformation',
      Screen_Type__c = 'Pre-Application',
      Order__c = 3,
      Status__c = 'Not Started',
      Title__c = 'Basic Information Screen'
    );
    insert section;

    // Call the method being tested
    List<CIB_CTRL_DocumentContainer.GetDocumentOutputWrapper> result = CIB_CTRL_DocumentContainer.getContainerDocuments(
      app.Id,
      section.Id,
      false
    );

    // Verify the results
    Assert.areNotEqual(null, result, 'Expected documents to be returned');
  }
}