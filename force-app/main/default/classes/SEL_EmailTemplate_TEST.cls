/*****************************************************************************************
 *@Name of the Class: SEL_EmailTemplate_TEST
 *@Description      : SFP-30097 Test Class for SEL_EmailTemplate
 *@Author           : Likhitha Karusala
 *@Created Date     : 06-13-2022
 ******************************************************************************************
 *@Last Modified By         : Likhitha Karusala
 *@Last Modified On         : 29 Mar 2024
 *@Modification Description : SFP-30097
 ******************************************************************************************/
@IsTest
private class SEL_EmailTemplate_TEST {
    /**
    * @description shouldSelectByName queries email Templates based on names
    */
     @IsTest
    static void shouldSelectByName() {
        String name;
        Test.startTest();
        SEL_EmailTemplate.newInstance().selectByName(name);
        Test.stopTest();
        fflib_QueryFactory result = fflib_QueryFactory.lastQueryFactory;
        Assert.areEqual(result.getCondition().containsIgnoreCase('Name =: name'), true,'Query succesfull based on template name');
    }
    
    /**
    * @description shouldSelectByDeveloperName queries email Templates based on developer names
    */
    @IsTest
    static void shouldSelectByDeveloperName() {
        String name;
        Test.startTest();
        SEL_EmailTemplate.newInstance().selectByDeveloperName(name);
        Test.stopTest();
        fflib_QueryFactory result = fflib_QueryFactory.lastQueryFactory;
        Assert.areEqual(result.getCondition().containsIgnoreCase('DeveloperName =: developerName'), true,'Query succesfull based on developer name');
    }
}