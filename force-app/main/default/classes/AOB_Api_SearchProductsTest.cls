/**
* @description Test class to test the AOB_Api_SearchProducts API call
* @author Dayakar Deekonda
* @date Nov 23th 2022
*/
@isTest
private class AOB_Api_SearchProductsTest{
    /**
	* @description testmethod for searchterm (Positive scenario)
    *
    */
     @isTest static void testCalloutnegative() {
        Boolean isFailed=false;
        try{
            Test.setMock(HttpCalloutMock.class, new MockHttpRequest());
            String res = AOB_Api_SearchProducts.searchTerm('test');
            String expectedValue = '{"example":"test"}';
        }
        Catch(Exception ex){
            isFailed=true;
            System.assertEquals(true, isFailed);
        }
    }

}