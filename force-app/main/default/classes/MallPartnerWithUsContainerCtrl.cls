/**
 * @description MallPartnerWithUsContainerCtrl
 * @author Ankit Kumar
 * @since 
 */
public with sharing class MallPartnerWithUsContainerCtrl {
    //global instance of rf lib logger
    private static final sbgplatform.rflib_Logger LOGGER = sbgplatform.rflib_LoggerUtil.getFactory().createLogger('MallPartnerWithUsContainerCtrl');

    /**
     * 
     * @description : getContentsByCountryNamesAndRecordTypes 
     *  @return : List of DenormalizedContent
     */
    @AuraEnabled(Cacheable = true)
    public static List <DenormalizedContent> getContentsByCountryNamesAndRecordTypes(String mallContext, List<String> countries, List<String> recordTypes) {
        try {
            return new MallDataServiceHandler(mallContext).getContentsByCountryNamesAndRecordTypes(countries, recordTypes);
        } catch (Exception e) {
            throw throwAuraException('getContentsByCountryNamesAndRecordTypes', e);
        }
    }

    /**
     * 
     * @description Method to return Exception for each catch block
     * @param message String 
     * @param e Exception
     * @return  Aura Handled Exception
     */
    private static AuraHandledException throwAuraException(String message, Exception e) {
        LOGGER.error(message, e);
        AuraHandledException auraException = new AuraHandledException(e.getMessage());
        auraException.setMessage(e.getMessage());
        return auraException;
    }
}