/**
 * @description       : 
 * @author            : TCK
 * @group             : 
 * @last modified on  : 06-27-2022
 * @last modified by  : TCK
**/
@IsTest
private class SEL_ContentNote_TEST {
    @TestSetup
    static void setup() {
        ContentNote testContentNote = new ContentNote();
        testContentNote.Title = 'TestTitle';
        testContentNote.Content = Blob.valueOf('Testing Content');
        insert testContentNote;
    }

    @IsTest
    static void shouldSelectById() {
        ContentNote cn = [SELECT Id FROM ContentNote LIMIT 1];
        Test.startTest();
        SEL_ContentNote.newInstance().selectById(cn.Id);
        Test.stopTest();
        fflib_QueryFactory result = fflib_QueryFactory.lastQueryFactory;
        System.assert(result.getCondition().containsIgnoreCase('Id =: noteId'), 'Is not doing the right condition');
    }


    @IsTest
    static void shouldSelectByIdAndCreator() {
        Test.startTest();
        SEL_ContentNote.newInstance().selectByIdAndCreator(new Set<Id>(), '');
        Test.stopTest();
        fflib_QueryFactory result = fflib_QueryFactory.lastQueryFactory;
        System.assert(result.getCondition().containsIgnoreCase('CreatedById =: creatorId AND Id IN: notesId'), 'Is not doing the right condition');
    }
}