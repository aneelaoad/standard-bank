/**
 * @author Emmanuel Mulea Nocks
 * @date March 2023
 * @description  This class will the allocation of parent rrecords to AOB_ReferencedData__c childs   
 */
public without sharing class AOB_SAP_ReferenceData {
	/**
    * @description - global instance of rf lib logger 
    **/
    private static final sbgplatform.rflib_Logger LOGGER = sbgplatform.rflib_LoggerUtil.getFactory().createLogger('AOB_SAP_ReferenceData');
    
    
    /**
    * @description Method to allocate parents to childs
    *
    * @param refDataList List<AOB_ReferencedData__c>
    */
    public static void allocateParents(List<AOB_ReferencedData__c> refDataList){

        List<AOB_ReferencedData__c> refDataUpdateList = new List<AOB_ReferencedData__c>();
        try {
            
            for (AOB_ReferencedData__c  refData: refDataList) {
                
                if(String.isNotBlank(refData.AOB_Value__c)){
                    AOB_ReferencedData__c ref = new AOB_ReferencedData__c(Id=refData.Id);
                    AOB_ReferencedData__c parentRef = new AOB_ReferencedData__c(AOB_SAPExternalID__c = refData.AOB_SAPField__c+refData.AOB_Value__c+refData.AOB_Language__c);
                    ref.AOB_Parent__r = parentRef;
                    refDataUpdateList.add(ref);
                }
            }
            
            if(refDataUpdateList.size()>0){
                    Database.update(refDataUpdateList,false);
            }
            
        } catch (Exception ex) {
            LOGGER.error('AOB_SAP_ReferenceData.allocateParents : ', ex);
        }
    }
}