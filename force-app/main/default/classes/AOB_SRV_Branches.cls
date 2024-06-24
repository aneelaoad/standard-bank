/**
* This class is used as a service class for all operations related with Open Application
*
* <p>DBP-1279</p>
*
* @author Maryem Bourhi (mbourhi@salesforce.com)
*
* @date Nov 18th 2020
*/
public with sharing class AOB_SRV_Branches {

    private static final sbgplatform.rflib_Logger LOGGER = sbgplatform.rflib_LoggerUtil.getFactory().createLogger('AOB_SRV_Branches');
    
    public static final String FIELD_NAME = 'BRANCH';

    /**
    * @description Calls the get branches API
    * @return List of branches that are active on the card system
    */
    public static List<AOB_API_GetBranches.ETdata8_Multi> callGetBranches(string token) {
        AOB_API_GetBranches customerServiceCall = new AOB_API_GetBranches(token);
        CMN_WebserviceCallQueue__c obj=CMN_DAL_DataFactory.newOutboundWebserviceQueue(AOB_API_GetBranches.SERVICE_NAME);
        customerServiceCall.process(obj);
        insert obj;  
        AOB_API_GetBranches.DTO_Response result = (AOB_API_GetBranches.DTO_Response) customerServiceCall.baseResponseDTO;
        if(result.ETdata8_Detail_Record!=null){
            return result.ETdata8_Detail_Record.ETdata8_Multi;
        }
        return result.ETdata8_Detail_Record.ETdata8_Multi;
    }
    
    /**
    * @description Insert branch list on AOB_ReferencedData_c
    */
    public static void insertBranches(List<AOB_API_GetBranches.ETdata8_Multi> Branches) {

        // Set up list of card branches to insert from the input list of branches 
        List<AOB_ReferencedData__c> allNewData = new List<AOB_ReferencedData__c>();
        AOB_ReferencedData__c data;
        integer i = 0;
        for (AOB_API_GetBranches.ETdata8_Multi branch : branches) {
            if (String.isNotBlank(branch.ETdata8_Code)){
                data = new AOB_ReferencedData__c();
                i++;
                data.AOB_Code__c = branch.ETdata8_Code;
                data.AOB_CountryCode__c = 'ZA';
                data.AOB_Language__c = 'en_US';
                data.Name = branch.ETdata8_Description;
                data.AOB_Sequence__c = i;
                data.AOB_SAPField__c = FIELD_NAME;
                data.AOB_SAPExternalID__c = data.AOB_SAPField__c + data.AOB_Code__c + data.AOB_Language__c;
                allNewData.add(data);
            }
        }
        if (!allNewData.isEmpty()) {
            try {
                insert allNewData;
            } catch (Exception ex) {
                LOGGER.error(ex.getMessage(), new String[] {'AOB_SRV_Branches',ex.getMessage()}, ex);
            }
        }
    }

}