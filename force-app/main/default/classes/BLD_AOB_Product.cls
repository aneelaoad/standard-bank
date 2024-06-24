/**
 * Created by Caro on 2018/02/26.
 */

@IsTest
public without sharing class BLD_AOB_Product extends ABS_ObjectBuilderBase {

        public static final String DEF_NAME = 'Business Current Account';

        public BLD_AOB_Product() {
            this(getNewUnitOfWork());
        }

        public BLD_AOB_Product(fflib_SObjectUnitOfWork workUnit) {
            super(AOB_Products__c.SObjectType, workUnit);
        }

        protected override void setDefaultData() {
            setField(AOB_Products__c.Name, DEF_NAME);
            setField(AOB_Products__c.Access__c, 'Anytime');
            setField(AOB_Products__c.Active__c, true);
            setField(AOB_Products__c.OpeningDeposit__c, 'R500');
            setField(AOB_Products__c.ProductDescription__c, 'Enjoy a secure means of paying and collecting funds.');
            setField(AOB_Products__c.ProductLogoName__c, 'BA.png');
            setField(AOB_Products__c.TermsURL__c, 'http://www.standardbank.co.za/standardbank/Business/Banking/Business-account/Business-current-account');
        }
    }