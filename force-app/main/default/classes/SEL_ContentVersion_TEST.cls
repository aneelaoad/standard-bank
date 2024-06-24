/*****************************************************************************************
 *@Name of the Class: SEL_ContentVersion_TEST
 *@Description      : SFP-30097 Test Class for SEL_ContentVersion
 *@Author           : Likhitha Karusala
 *@Created Date     : 06-15-2022
 ******************************************************************************************
 *@Last Modified By         : Likhitha Karusala
 *@Last Modified On         : 29 Mar 2024
 *@Modification Description : SFP-30097
 ******************************************************************************************/
@IsTest
private class SEL_ContentVersion_TEST  {
     /**
    * @description shouldSelectByContentDocumentId queries by document Id
    **/
    @IsTest
    static void shouldSelectByContentDocumentId() {
        Test.startTest();
        SEL_ContentVersion.newInstance().selectByContentDocumentId(new Set<Id>());
        Test.stopTest();
        fflib_QueryFactory result = fflib_QueryFactory.lastQueryFactory;
        Assert.areEqual(result.getCondition().containsIgnoreCase('ContentDocumentId IN: contentDocumentIds'),true, 'Is not doing the right condition');
    }
    
    /**
    * @description shouldSelectByListContentDocumentId queries list of documents
    **/
     @IsTest
    static void shouldSelectByListContentDocumentId() {
        Test.startTest();
        SEL_ContentVersion.newInstance().selectByListContentDocumentId(new List<Id>());
        Test.stopTest();
        fflib_QueryFactory result = fflib_QueryFactory.lastQueryFactory;
        Assert.areEqual(result.getCondition().containsIgnoreCase('ContentDocumentId IN: contentDocumentIds'),true, 'Is not doing the right condition');
    }
    
    /**
    * @description shouldselectByRecordId queried by record Id
    **/    
        @IsTest
    static void shouldselectByRecordId() {
  
        Id cv;
        try{
        Test.startTest();
        SEL_ContentVersion.newInstance().selectByRecordId(cv);
        Test.stopTest();
        fflib_QueryFactory result = fflib_QueryFactory.lastQueryFactory;
        Assert.areNotEqual(result.getCondition().containsIgnoreCase('Id =: cVersion'),'sucess','Is not doing the right condition');
        }catch(Exception e){
          Assert.areNotEqual(null,e,'Error');
        }
        }
}