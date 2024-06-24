/**
 * 
 * @description MallCustomLabelsController
 * @author Ankit Kumar
 * @since 
*/
public with sharing class MallCustomLabelsController {
    
    //global instance of rf lib logger
    private static final sbgplatform.rflib_Logger LOGGER = sbgplatform.rflib_LoggerUtil.getFactory().createLogger('MallCustomLabelsController');

    /**
	 * @description : getCustomLabels
	 * @return List of Custom Labelmdt 
	*/ 
    @AuraEnabled
    public static List<Unsupported_Language_Translation__mdt> getCustomLabels(){
        return Unsupported_Language_Translation__mdt.getAll().values();
    }
}