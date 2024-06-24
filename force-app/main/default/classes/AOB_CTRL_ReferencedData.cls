/*
*   @ Author            :  Gill Lumley
*   @ Date              :  19 February 2023
*   @ User Story        :  SFP-8703, SFP-8958 
*   @ Description       :  Controller class for referenced data object
*/
public class AOB_CTRL_ReferencedData {
    
    // MRI table name constants
    private static final String TABLE_SOURCE_OF_FUNDS    = 'SOURC_OF_FUNDS';
    private static final String TABLE_INDUSTRY           = 'INSTY';
    private static final String TABLE_MERCHANT_CATEGORY  = 'MRCHT_CAT';
    private static final String TABLE_TAX_TYPE           = 'TAX_TYPE'; 
    
    // Source of funds constants
    private static final String SOF_PROFIT_FROM_BUSINESS = '0010';
    private static final String SOF_BEE_TRANSACTIONS     = '0016';
    private static final String SOF_IRREGULAR_INCOME     = '0018';
    private static final String SOF_DONATION             = '0021';    
    private static final String SOF_DIVIDEND_PAYOUT      = '0024';    
    private static final String SOF_RENTAL               = '0025';
    private static final String SOF_BOARD_FEES           = '0026';
    private static final String SOF_DIRECTOR_FEES        = '0027';
    private static final String SOF_TRUST_DISTRIBUTIONS  = '0029';
    private static final String SOF_INTEREST_RECEIVED    = '0031';
    
    // Industry constants
    private static final String INSTY_PREFIX_UNSPECIFIED = 'A'; 
    private static final String INSTY_PREFIX_NA          = 'B';  
    private static final String INSTY_CODE_NA            = '00000';  
    
    // Merchant category constants
    private static final String MRCHTCAT_UNSPECIFIED     = '1'; 
    private static final String MRCHTCAT_NA              = '0';     
            
    // Tax type constants
    private static final String TAXTYPE_PREFIX_ZA        = 'ZA'; 
    
    // Deactivate referenced data records that should not be shown on drop-downs
    public static void deactivateRecords(List<AOB_ReferencedData__c> newRecords){
        
        for (AOB_ReferencedData__c newRecord : newRecords){
            
            // Deactivate all source of fund codes except those listed below
            if (newRecord.AOB_SAPField__c == TABLE_SOURCE_OF_FUNDS){
                if (newRecord.AOB_Code__c <> SOF_PROFIT_FROM_BUSINESS &&
                    newRecord.AOB_Code__c <> SOF_BEE_TRANSACTIONS &&  
                    newRecord.AOB_Code__c <> SOF_IRREGULAR_INCOME &&     
                    newRecord.AOB_Code__c <> SOF_DONATION &&                
                    newRecord.AOB_Code__c <> SOF_DIVIDEND_PAYOUT &&         
                    newRecord.AOB_Code__c <> SOF_RENTAL &&              
                    newRecord.AOB_Code__c <> SOF_BOARD_FEES &&         
                    newRecord.AOB_Code__c <> SOF_DIRECTOR_FEES &&       
                    newRecord.AOB_Code__c <> SOF_TRUST_DISTRIBUTIONS &&  
                    newRecord.AOB_Code__c <> SOF_INTEREST_RECEIVED){
                        newRecord.AOB_isActive__c = false;
                    }
            }
            
            // Deactivate all unspecified and not applicable industry codes based on prefix
            if (newRecord.AOB_SAPField__c == TABLE_INDUSTRY){
                if (newRecord.AOB_Code__c.substring(0,1) == INSTY_PREFIX_UNSPECIFIED ||
                    newRecord.AOB_Code__c.substring(0,1) == INSTY_PREFIX_NA ||
                    newRecord.AOB_Code__c == INSTY_CODE_NA){
                        newRecord.AOB_isActive__c = false;
                    }
            }  
            
            // Deactivate unspecified and not applicable merchant category codes
            if (newRecord.AOB_SAPField__c == TABLE_MERCHANT_CATEGORY){
                if (newRecord.AOB_Code__c == MRCHTCAT_UNSPECIFIED ||
                    newRecord.AOB_Code__c == MRCHTCAT_NA){                
                        newRecord.AOB_isActive__c = false;
                    }
            }              
            
            // Deactivate South African tax types - only foreign codes must show
            if (newRecord.AOB_SAPField__c == TABLE_TAX_TYPE){
                if (newRecord.AOB_Code__c.substring(0,2) == TAXTYPE_PREFIX_ZA){                
                        newRecord.AOB_isActive__c = false;
                    }
            } 
            
        }
    }
}