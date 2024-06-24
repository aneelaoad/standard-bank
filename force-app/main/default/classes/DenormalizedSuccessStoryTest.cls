@isTest
public with sharing class DenormalizedSuccessStoryTest {
    @IsTest
    static void testDenormalizedSuccessStory(){
        Test.startTest();
        DenormalizedSuccessStory denormalizedStory = new DenormalizedSuccessStory();
        DenormalizedSuccessStory denormalizedStoryCopy = DenormalizedSuccessStory.parse(System.JSON.serialize(denormalizedStory));
        Test.stopTest();
        Assert.areNotEqual(null, denormalizedStory, 'Expected denormalized success story');
        Assert.areNotEqual(null, denormalizedStoryCopy, 'Expected denormalized success story copy');
    }
}