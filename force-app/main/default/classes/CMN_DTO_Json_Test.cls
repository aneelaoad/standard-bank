@isTest
private class CMN_DTO_Json_Test {
  
     @isTest
    public static void serialize(){
        Test.startTest();
        CMN_DTO_Json dto = new CMN_DTO_Json();
        dto.serialize();
        Test.stopTest();
    }
    @isTest
    public static void serialize_2(){
        Test.startTest();
        CMN_DTO_Json dto = new CMN_DTO_Json();
        dto.serialize(true);
        dto.serialize(false);
        Test.stopTest();
        
    }

}