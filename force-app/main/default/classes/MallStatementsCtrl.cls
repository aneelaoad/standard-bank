public with sharing class MallStatementsCtrl {

    

    @AuraEnabled(Cacheable=true)
    public static List<Statement> getStatements(){
        
        List<Statement> statements = new List<Statement>();
        try {

            try {
                /*
                MallCustomerAccountListResponse accountListResponse = CTRL_MallDocumentManagement.getCustomerAccountList();
                List<String> accountNumbers = new List<String>();
                for (MallCustomerAccountListResponse.CustomerAccountListDetails accountDetail : accountListResponse.customerAccountListDetails) {
                 accountNumbers.add(accountDetail.accountNumber);
                }

                 System.debug('Account Number Detail List'+accountNumbers);
                 */

                // Sample Account List from EEAPTEST3
                // List<String> AccTestList=new List <String> { '0000010006097209', '0000010006185337', '4515681692410399', '0000000125094561', '0000010006184551', '0000010006318647', '0000010006184810'};
                 List<String> AccTestList = new List <String> {'0000010006185337'};
                 String startDate= String.valueOf(Date.today().addMonths(-24)); //last 24 months
                 String endDate=String.valueOf(Date.today());
                 MallDocumentResponse response = CTRL_MallDocumentManagement.getCustomerPreviousStatementsByAccountNumbers( AccTestList, startDate, endDate );

                 for (Integer i = response.resultSet.size() - 1; i >= 0; i--) {

                    if (statements.size() >= 5) {
                        break; // Exit the loop if we already have 5 elements
                    }                    
                    // Get the current resultSet
                    MallDocumentResponse.ResultSet resultSet = response.resultSet[i];
                    
                    // Log the current resultSet for debugging purposes
                    System.debug('@@@ Result Set ' + resultSet);
                    
                    // Add a new Statement object to the statements list
                    statements.add(new Statement(resultSet.description, resultSet.label, resultSet.uid));
                }

             }   catch(Exception e) {
                 System.debug('Exception in getCustomerAccountList: ' + e.getMessage());
                 throw MallExceptionUtil.throwAuraException('MallStatementsCtrl.getStatements', e);
             }
            
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
        return statements;
    }

  
    /**
     * @description : MallStatementsCtrl class
     */
    public class Statement {
        @AuraEnabled
        public String title { get; set; }
       
        @AuraEnabled
        public String strDate { get; set; }
        
        @AuraEnabled
        public String uid { get; set; }
        
        public Statement(String title, String strDate, String strUid) {
            this.title = title;
            this.strDate = strDate;
            this.uid = strUid;
           
        }
    }
 
}