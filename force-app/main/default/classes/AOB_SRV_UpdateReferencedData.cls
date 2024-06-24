/**
* @description This class used to deactivate parent industry codes in ReferencedData.
*
* @author Narendra Teja
*
* @date April 13th 2023
*/
public with sharing class AOB_SRV_UpdateReferencedData {

    private static final sbgplatform.rflib_Logger LOGGER = sbgplatform.rflib_LoggerUtil.getFactory().createLogger('AOB_SRV_UpdateReferencedData');
    private static final String INSTY_PREFIX_UNSPECIFIED 	= 'A'; 
    private static final String INSTY_PREFIX_NA          	= 'B';  
    private static final String INSTY_CODE_NA            	= '00000';  
    public static final String INDUSTRY 					= 'INSTY';

    /**
    * @description this method deactivates parent industry codes in AOB_ReferencedData__c 
    */
    public static void updateIndustryPicklistValues() {

       try{
            List<AOB_ReferencedData__c> refList=[Select id,AOB_Code__c,Name,  AOB_CountryCode__c,AOB_SAPField__c,AOB_Parent__r.Name,AOB_Value__c,  AOB_isActive__c from AOB_ReferencedData__c where AOB_SAPField__c =: INDUSTRY AND AOB_isActive__c = true];
            if(refList.Size()>0){
                Set<String> aobValues=new Set<String>();
                
                for(AOB_ReferencedData__c ref:refList){
                    aobValues.add(ref.AOB_Value__c);
                }
                List<AOB_ReferencedData__c> refRecordsToUpdate=new List<AOB_ReferencedData__c>();
                for(AOB_ReferencedData__c ref:refList){
                    if(aobValues.contains(ref.AOB_Code__c) || ref.AOB_Code__c.substring(0,1) == INSTY_PREFIX_UNSPECIFIED || ref.AOB_Code__c.substring(0,1) == INSTY_PREFIX_NA || ref.AOB_Code__c == INSTY_CODE_NA || ref.AOB_Value__c.substring(0,1) == INSTY_PREFIX_UNSPECIFIED || ref.AOB_Value__c.substring(0,1) == INSTY_PREFIX_NA || ref.AOB_Value__c == INSTY_CODE_NA){
                        ref.AOB_isActive__c=false;
                        refRecordsToUpdate.add(ref);
                    }
                }
                Update refRecordsToUpdate;
            }
        }catch(Exception ex){
            LOGGER.error(ex.getMessage(), new String[] {'AOB_SRV_UpdateReferencedData',ex.getMessage()}, ex);
        }   
        
    }

}