/**
 * @description Controller class for osbMiniMallFilter,osbCategoriesLwc  component
 *
 * @author Litha Nosekeleza (litha.nosekeleza@standardbank.co.za)
 * @date October 2021
 * 
 * @LastModified March 2023
 * @author Milica Milicevic (milica.milicevic@standardbank.co.za)
 * @UserStory SFP-21025
 * @LastModifiedReason updated the method to retrieve the categories when a knowledge article is linked to more than one
 */
public class OSB_MiniMallCustomMetadata_CTRL {
    private static final sbgplatform.rflib_Logger LOGGER = sbgplatform.rflib_LoggerUtil.getFactory().createLogger('OSB_MiniMallCustomMetadata_CTRL');

    /**
     * @description Returns a list of categories from metadata of available categories
     *
	 * @param userId String of user ID
	 * 
     * @return List of OSB_MiniMall__mdt
     **/
    @AuraEnabled( cacheable=true )
    public static List<OSB_MiniMall__mdt> fetchMetaListLwc(Id userId) {       
        List<OSB_MiniMall__mdt> fetchMeta = OSB_MiniMall__mdt.getAll().values();
        List<OSB_MiniMall__mdt> result;
        try{
            List<Knowledge__kav> solutionsAvailable = OSB_SolutionShowcase_CTRL.getSolutionShowcase(userId);
            Set<OSB_MiniMall__mdt> availableCategories = new Set<OSB_MiniMall__mdt>();
            LOGGER.info('OSB_MiniMallCustomMetadata_CTRL : fetchMetaListLwc Successful Categories retrieved');
            if((fetchMeta.size() > 0) && (solutionsAvailable != null)){
                for(OSB_MiniMall__mdt metaCategory : fetchMeta ){
                    for(Knowledge__kav solutions : solutionsAvailable){
                        if((solutions.Is_coming_soon__c == false) && (String.isNotBlank(solutions.Categories__c))){
                            List<String> categoriesInSolution = solutions.Categories__c.split(';');
                            if(categoriesInSolution.contains(metaCategory.MasterLabel)){
                                availableCategories.add(metaCategory);
                            }  
                        }
                    }
                }
                result  = new List<OSB_MiniMall__mdt>();
                result.addAll(availableCategories); 
            } 
            LOGGER.debug('OSB_MiniMallCustomMetadata_CTRL : fetchMetaListLwc category size: '+ result.size());
            LOGGER.info('OSB_MiniMallCustomMetadata_CTRL : fetchMetaListLwc Successful Categories retrieved');
            return result;
            
        }catch(Exception e){
            LOGGER.error('OSB_MiniMallCustomMetadata_CTRL : fetchMetaListLwc Retrieveing categories Exception logged: ',e);
            return null;
        }
  
        
    }

}