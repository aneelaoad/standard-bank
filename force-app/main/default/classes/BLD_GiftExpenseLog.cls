/**
 * Builder class for Gift_Expense_Log__c SObject
 *
 * @author Bartosz Sliwinski (bsliwinski@deloittece.com)
 * @date April 2020
 */
@IsTest
public without sharing class BLD_GiftExpenseLog extends ABS_ObjectBuilderBase {

    private static final String DEF_DESCRIPTION = 'Awesome Gift';
    private static final String DEF_GIFT_REASON = 'Easter Gift';
    private static final Decimal DEF_GIFT_VALUE = 1000;

    public BLD_GiftExpenseLog(fflib_SObjectUnitOfWork uow) {
        super(Gift_Expense_Log__c.SObjectType, uow);
    }

    protected override void setDefaultData() {
        setField(Gift_Expense_Log__c.Description__c, DEF_DESCRIPTION);
        setField(Gift_Expense_Log__c.Gift_Expense_Reason__c, DEF_GIFT_REASON);
        setField(Gift_Expense_Log__c.Gift_Expense_Value__c, DEF_GIFT_VALUE);
    }

    public BLD_GiftExpenseLog approverId(Id approverId) {
        return (BLD_GiftExpenseLog) setField(Gift_Expense_Log__c.Approver__c, approverId);
    }

    public BLD_GiftExpenseLog bankContact(BLD_Contact conBld) {
        return (BLD_GiftExpenseLog) setRelation(Gift_Expense_Log__c.Bank_Contact_Name__c, conBld);
    }

    public BLD_GiftExpenseLog clientContact(BLD_Contact conBld) {
        return (BLD_GiftExpenseLog) setRelation(Gift_Expense_Log__c.Client_Contact_Name__c, conBld);
    }

}