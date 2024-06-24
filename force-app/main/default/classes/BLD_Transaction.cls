public without sharing class BLD_Transaction extends ABS_ObjectBuilderBase {
    public BLD_Transaction() {
        super(Transaction__c.SobjectType);
        init();
    }

    public BLD_Transaction(fflib_SObjectUnitOfWork workUnit) {
        super(Transaction__c.sObjectType, workUnit);
        init();
    }

    public BLD_Transaction(Transaction__c rap) {
        super(rap);
    }

    private void init() {
        setField(Transaction__c.Period__c, System.today());
    }

    public BLD_Transaction accountBalance(Integer value) {
        return (BLD_Transaction) setField(Transaction__c.Account_Balance__c, value);
    }

    public BLD_Transaction flagPosTransAmt(String value) {
        return (BLD_Transaction) setField(Transaction__c.Flag_Pos_Trans_Amt__c, value);
    }

    public BLD_Transaction period(Date value) {
        return (BLD_Transaction) setField(Transaction__c.Period__c, value);
    }

    public BLD_Transaction accountODLimit(Integer value) {
        return (BLD_Transaction) setField(Transaction__c.Account_OD_Limit__c, value);
    }

    public BLD_Transaction transactionAmount(Integer value) {
        return (BLD_Transaction) setField(Transaction__c.Transaction_Amount__c, value);
    }

    public BLD_Transaction transactionCount(Integer value) {
        return (BLD_Transaction) setField(Transaction__c.Transaction_Count__c, value);
    }

    public BLD_Transaction transactionType(String value) {
        return (BLD_Transaction) setField(Transaction__c.Transaction_Type__c, value);
    }
}