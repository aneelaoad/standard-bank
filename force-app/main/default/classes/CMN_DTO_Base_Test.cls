@isTest
public class CMN_DTO_Base_Test {
    private static CMN_DTO_Base dto;

    @testSetup
    public static void setup(){
        dto = new CMN_DTO_Base();
    }

    @isTest
    public static void testSerialize(){
        Test.startTest();
        CMN_DTO_Base dto = new CMN_DTO_Base();
        dto.serialize();
        Test.stopTest();
    }

    @isTest
    public static void testDeserialize(){
        
        Test.startTest();
        CMN_DTO_Base dto = new CMN_DTO_Base();
		dto.deserialize('test');
        Test.stopTest();
    }

    @isTest
    public static void testPopulate(){
        Id expected = 'a6h3N0000001IaOQAU';
        Test.startTest();
        CMN_DTO_Base dto = new CMN_DTO_Base();
        dto.populate(expected);
        Test.stopTest();
    }

    
}