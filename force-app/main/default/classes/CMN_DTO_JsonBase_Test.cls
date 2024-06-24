@IsTest
public class CMN_DTO_JsonBase_Test {
    
    @IsTest
    static void getObjectTypeTest() {
        Test.startTest();
        CMN_DTO_JsonBase dto = new CMN_DTO_JsonBase();
        String retVlaue= dto.serialize();
        Test.stopTest();
        System.assertNotEquals(null, retVlaue);
    }

    @IsTest
    static void deserializeTest(){
        Test.startTest();
        CMN_DTO_JsonBase dto = new CMN_DTO_JsonBase();
        CMN_DTO_Base stringval;
        CMN_DTO_Base retVlaue = dto.deserialize(JSON.serialize(stringval));
        Test.stopTest(); 
        System.assertEquals(null, retVlaue);
    }

    @IsTest
    static void serializeTest(){
        Test.startTest();
        CMN_DTO_JsonBase dto = new CMN_DTO_JsonBase();
        dto.serialize();
        Test.stopTest(); 
    }
}