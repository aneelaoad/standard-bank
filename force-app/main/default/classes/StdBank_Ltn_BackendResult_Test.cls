@isTest
private class StdBank_Ltn_BackendResult_Test {
    @isTest
    static void testConstructors() {
        System.assertEquals('{"success":null,"message":""}', new StdBank_Ltn_BackendResult().toJSON());
        System.assertEquals('{"success":true,"message":""}', new StdBank_Ltn_BackendResult(true).toJSON());
        System.assertEquals('{"success":false,"message":"true"}', new StdBank_Ltn_BackendResult(false, 'true').toJSON());
    }
}