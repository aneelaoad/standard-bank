public class StdBank_MultiDistClientCreation_Vf_Ext {
// Created: 23-Apr-2009
// By: Manu Erwin
// SOW: EMEA_SOW_StandardBank_013

// ======User Story======
// Requirement - After a user creates child products for an Opportunity,
// they need to be able to enter multiple Distribution Client records at one time,
// i.e. like the "Add Client Team" button.
// A System Parameter controls the number of records that can be entered at one
// time with a 'Save and More' button providing the ability to add further records if needed.

// If the User clicks the ‘Save’ button the Distribution Client details that have been entered
// (up to a maximum of five) will be saved as new child ‘Distribution Client’ records for the Opportunity Product.
// The User will then be redirected to view the original Opportunity Product record.

// If the User clicks the ‘Save & More’ button the records will be saved
// as detailed above, then the page will be refreshed to allow them to enter further records.
// This process can be continued as often as needed.

// If the User clicks the ‘Cancel’ button they will be redirected back to the original Opportunity Product record.

    private static final String strPARAM_NAME = 'Multiple Distribution Client Creation - Number of Rows';
    // Set up the default number of rows
    private static Integer intNUMBER_OF_ROWS = 5;
    private Id currentRecordId = ApexPages.currentPage().getParameters().get('id');
    private SB_Product__c opptyProduct;

    public StdBank_MultiDistClientCreation_Vf_Ext(ApexPages.StandardSetController controller) {
        System.Debug('## >>> StdBank_MultiDistClientCreation_Vf_Ext <<< run by ' + UserInfo.getName());

        System.Debug('## Obtain the System Parameter for the number of rows');
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

        System.Debug('## Build the list of Distribution Client records');
        list<Distribution_Client__c> initialListDistClients = new list<Distribution_Client__c>();
        System.Debug('## Building list of ' + intNUMBER_OF_ROWS + ' Distribution Clients');
        for (Integer intCount = 0; intCount < intNUMBER_OF_ROWS; intCount++) {
            //System.Debug('## DEV ONLY: building list of Distribution Clients: intCount: ' + intCount);
            Distribution_Client__c singleDistClient = new Distribution_Client__c();
            singleDistClient.Client__c = opptyProduct.Client__c;
            singleDistClient.Opportunity__c = opptyProduct.Opportunity__c;
            singleDistClient.Product__c = opptyProduct.Id;
            initialListDistClients.add(singleDistClient);
        }
        distClients = initialListDistClients;
        //System.Debug('## DEV ONLY - cashflows: ' + cashflows);
    }

    public list<Distribution_Client__c> distClients {
        get { return distClients; }
        set { distClients = value; }
    }

    private void insertRecords() {
        System.debug('## STARTING - insertRecords');
        // Pre-process records prior to save - remove records with both distClient and date fields empty
        // ASSUMPTION: Records with only one field populated are user error and validation rule will catch

        list<Distribution_Client__c> privateListDistClients = new list<Distribution_Client__c>();

        for (Distribution_Client__c distClient : distClients) {
            System.debug('## distClient: ' + distClient);
            if (distClient.Distribution_Client__c == null &&
                    distClient.Margin_Points__c == null &&
                    distClient.Amount__c == null ) {
                System.debug('## DistClient and Amount and Margin Points are all null - no action');
            } else {
                System.debug('## DistClient or Amount or Margin Points either all have values or individually - add to private list');
                privateListDistClients.add(distClient);
            }
        }
        
        distClients = privateListDistClients;
        if (!distClients.isEmpty()) {
            System.debug('## About to insert ' + distClients.size() + ' child distClient records.');
            try {
                insert distClients;
            } catch (DMLException DMLe) {
                System.debug('## Insert NOT successful: ' + DMLe.getMessage());
                // Create an error to display for the VisualForce page
                ApexPages.Message apexPageMsg = new ApexPages.Message(ApexPages.Severity.ERROR,
                                                                'An error has occured: ' + 
                                                                DMLe.getMessage());
                ApexPages.addMessage(apexPageMsg);
            }
        }
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
            pageRef = Page.StdBank_MultiDistClientCreation_Vf;
            pageRef.getParameters().put('id', currentRecordId);
            pageRef.setRedirect(true);
        }

        return pageRef;
    }
}