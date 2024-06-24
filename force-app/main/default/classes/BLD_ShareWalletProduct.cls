/**
 * Builder class for Share_of_Wallet_Product__c SObject
 *
 * @author Bartosz Sliwinski (bsliwinski@deloittece.com)
 * @date April 2020
 */
@IsTest
public without sharing class BLD_ShareWalletProduct extends ABS_ObjectBuilderBase {

    public BLD_ShareWalletProduct(fflib_SObjectUnitOfWork workUnit) {
        super(Share_of_Wallet_Product__c.SObjectType, workUnit);
    }

    public BLD_ShareWalletProduct currencyCode(String currencyCode) {
        return (BLD_ShareWalletProduct) setField(Share_of_Wallet_Product__c.CurrencyIsoCode, currencyCode);
    }

    public BLD_ShareWalletProduct productSubset(String productSubset) {
        return (BLD_ShareWalletProduct) setField(Share_of_Wallet_Product__c.Product_Subset__c, productSubset);
    }
}