/****************************************************************************  
* @author       Maham Hassan
* @date         15/03/2022
* @description  Trigger Handler for Financial Accounts. It is calculating 
*               DTF(DTB) ratio on the client record.
*               
****************************************************************************/
public with sharing class TRH_finserv_FinancialAccount extends ABS_TriggerHandlerBase {

    private finserv__FinancialAccount__c[] records {
        get { return (finserv__FinancialAccount__c[])Trigger.new; }
    }
    
    private finserv__FinancialAccount__c[] oldRecords {
        get { return (finserv__FinancialAccount__c[])Trigger.old; }
    }

    public override void handleAfterInsert(){ 
        DMN_finserv_FinancialAccount.CalculateDTFRatio(records);
    }

    public override void handleAfterUpdate() {
        DMN_finserv_FinancialAccount.CalculateDTFRatio(records);
    }

    public override void handleAfterDelete() {
        DMN_finserv_FinancialAccount.CalculateDTFRatio(oldRecords);
    }


}