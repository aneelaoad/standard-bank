public class StdBank_MultiCashflowCreation_Vf_Ext {
// Created: 22-Apr-2009
// By: Manu Erwin
// SOW: EMEA_SOW_StandardBank_013

// ======User Story======
// Requirement - After a user creates child products for an Opportunity,
// they need to be able to enter multiple Cashflow records at one time,
// i.e. like the "Add Client Team" button.
// A System Parameter controls the number of records that can be entered at one
// time with a 'Save and More' button providing the ability to add further records if needed.

// When the User clicks the ‘Save’ button the cashflow details that have been entered
// (up to a maximum of five) will be saved as new child ‘Cashflow’ records for the Opportunity Product.
// The User will then be redirected to view the original Opportunity Product record.

// If the User clicks the ‘Save & More’ button the records will be saved
// as detailed above, then the page will be refreshed to allow them to enter further records.
// This process can be continued as often as needed.

    private static final String strPARAM_NAME = 'Multiple Cashflow Creation - Number of Rows';
    // Set up the default number of rows
    private static Integer intNUMBER_OF_ROWS = 5;
    private Id currentRecordId = ApexPages.currentPage().getParameters().get('id');
    private SB_Product__c opptyProduct;

    public StdBank_MultiCashflowCreation_Vf_Ext(ApexPages.StandardSetController setCon) {
        System.Debug('## >>> StdBank_MultiCashflowCreation_Vf_Ext <<< run by ' + UserInfo.getName());

        System.Debug('## Obtain the System Parameter for the number of rows - using default if not existing ##');
        try {
            Integer intSysParam = integer.valueOf(StdBank_SystemParams.getParam(strPARAM_NAME));
            if (intSysParam != null) {
                intNUMBER_OF_ROWS = intSysParam;
            }
        } catch (Exception e) {
            System.Debug('## getTypeName/getMessage: ' + e.getTypeName() +'/'+ e.getMessage());
        }

        System.Debug('## currentRecordId / intNUMBER_OF_ROWS: ' + currentRecordId +' / '+ intNUMBER_OF_ROWS);

        System.Debug('## Obtain the Opportunity Product record');
        opptyProduct = [select Id,
            Client__c,
            Opportunity__c
            from SB_Product__c
            where Id = :currentRecordId limit 1];
        //System.Debug('## DEV ONLY - opptyProduct: ' + opptyProduct);

        System.Debug('## Build the list of Cashflow records');
        list<Cashflow__c> initialListCashflows = new list<Cashflow__c>();
        System.Debug('## Building list of ' + intNUMBER_OF_ROWS + ' cashflows');
        for (Integer intCount = 0; intCount < intNUMBER_OF_ROWS; intCount++) {
            //System.Debug('## DEV ONLY: building list of cashflows: intCount: ' + intCount);
            Cashflow__c singleCashflow = new Cashflow__c();
            singleCashflow.Client__c = opptyProduct.Client__c;
            singleCashflow.Opportunity__c = opptyProduct.Opportunity__c;
            singleCashflow.Product__c = opptyProduct.Id;
            initialListCashflows.add(singleCashflow);
        }
        cashflows = initialListCashflows;
        //System.Debug('## DEV ONLY - cashflows: ' + cashflows);
    }
    
    public list<Cashflow__c> cashflows {
        get { return cashflows;}
        set { cashflows = value; }
    }

    private void insertRecords() {
        System.debug('## STARTING - insertRecords');
        // Pre-process records prior to save - remove records with both cashflow and date fields empty
        // ASSUMPTION: Records with only one field populated are user error and validation rule will catch

        list<Cashflow__c> privateListCashflows = new list<Cashflow__c>();

        for (Cashflow__c cashflow : cashflows) {
            System.debug('## cashflow: ' + cashflow);
            if (cashflow.Cashflow__c == null && cashflow.Date__c == null) {
                System.debug('## cashflow__c and date__c are both null - no action');
            } else {
                System.debug('## cashflow__c and date__c either have both (or have individually) values - add to private list');
                privateListCashflows.add(cashflow);
            }
        }
        cashflows = privatelistCashflows;

        if (!cashflows.isEmpty()) {
            System.debug('## About to insert ' + cashflows.size() + ' child cashflow records.');
            try {
                insert cashflows;
            } catch (DMLException DMLe) {
                System.debug('## Insert NOT successful: ' + DMLe.getMessage());
                // Create an error to display for the VisualForce page
                ApexPages.Message apexPageMsg = new ApexPages.Message(ApexPages.Severity.ERROR,
                                                                'An error has occured: ' + 
                                                                DMLe.getMessage());
                ApexPages.addMessage(apexPageMsg);
            }
        }
        
        System.debug('## ENDING - insertRecords');
    }

    public PageReference saveAll() {
        System.debug('## STARTING - saveAll');

        PageReference pageRef = null;

        // Invoke the private method insertRecords to perform the insert
        insertRecords();

        System.debug('## ApexPages.Messages:' + ApexPages.getMessages());
        // If there are no PageMessages (i.e., no problems) navigate the user to the original Opportunity Product record.
        if (!ApexPages.hasMessages()) {
            System.debug('## No errors: Redirect the user back to the original record');
            pageRef = new PageReference('/' + currentRecordId);
            pageRef.setRedirect(true);
        }

        System.debug('## ENDING - saveAll');
        return pageRef;
    }

    public PageReference saveAndMore() {
        System.debug('## STARTING - saveAndMore');

        PageReference pageRef = null;
        
        // Invoke the insertRecords method to perform the insert
        insertRecords();

        System.debug('## ApexPages.Messages:' + ApexPages.getMessages());
        // If there are no PageMessages (i.e., no problems) return a page reference for the same Visualforce Page.
        if (!ApexPages.hasMessages()) {
            System.debug('## No errors: Redirect the user back to this VF page');
            pageRef = Page.StdBank_MultiCashflowCreation_Vf;
            pageRef.getParameters().put('id', currentRecordId);
            pageRef.setRedirect(true);
        }

        System.debug('## ENDING - saveAndMore');
        return pageRef;
    }
}