@istest
public with sharing class DenormalizedTagTest {

    @IsTest
    static void testDenormalizedtags(){
        Test.startTest();
        DenormalizedTag denormailzdTag = new DenormalizedTag();
        DenormalizedTag denormailzdTagCopy = DenormalizedTag.parse(System.JSON.serialize(denormailzdTag));

        Test.stopTest();
        Assert.areNotEqual(null, denormailzdTag, 'Tags expected');
        Assert.areNotEqual(null, denormailzdTagCopy, 'Tags copy expected');
    }
}