/**
*
* @author Chandrasekhar Mokkala (chandrasekhar.mokkala@standardbank.co.za)
* @date 14 Sep 2023
* @description SFP-30019 - To create or update Insight Sharing records as a admin.
* ==============================================================
* ModifiedBy       			ModifiedDate   	Story Number    Description
*/
public without sharing class Insight_Sharing {
    
    private static final sbgplatform.rflib_Logger LOGGER = sbgplatform.rflib_LoggerUtil.getFactory().createLogger('Insight_Sharing');
    
    public static void deleteInsightShareedRecords(String parentId,String rowCause){
        LOGGER.info('Insight_Sharing:deleteInsightShareedRecords - initiated for :'+parentId);
        try{
            List<Insight__Share> deleteSharing = new List<Insight__Share>(); 
            for(Insight__Share insightShare : [Select Id,UserOrGroupId from Insight__Share where ParentId =: parentId and RowCause =:rowCause ]){
                deleteSharing.add(insightShare);
            }
            LOGGER.debug('Insight_Sharing:deleteInsightShareedRecords delete shared records count :'+deleteSharing.size());
            delete deleteSharing;
            LOGGER.info('Insight_Sharing:deleteInsightShareedRecords successfully removed access');
        }
        catch(Exception exp){
            LOGGER.error('Insight_Sharing:deleteInsightShareedRecords Exception logged :',exp);
        }
    }
}