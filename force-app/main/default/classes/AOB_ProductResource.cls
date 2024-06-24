/*****************************************************************************************************
    @ Author        : Denys Nienaber.
    @ Date          : 2017-11-09
    @ Description   : Retrieves a list of all active products
*****************************************************************************************************/
@RestResource(urlMapping='/Product/*')
global with sharing class AOB_ProductResource {
	
    @HttpGet
    global static List<AOB_Products__c> doGet() {

        return new SEL_AOB_Products().selectAllActive();
    }
   
}