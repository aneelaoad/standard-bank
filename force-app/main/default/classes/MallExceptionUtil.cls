/**
 * 
 * @description MallExceptionUtil
 * @author Ankit Kumar
 * @since 
 */
public with sharing class MallExceptionUtil {

    public static final sbgplatform.rflib_Logger LOGGER = sbgplatform.rflib_LoggerUtil.getFactory().createLogger('MallExceptionUtil');

    /**
     * 
     * @description Method to return Exception for each catch block
     * @param message String 
     * @param e Exception
     * @return  `AuraHandledException`
     */
    public static AuraHandledException throwAuraException(String message, Exception e) {
        LOGGER.error(message, e);
        AuraHandledException auraException = new AuraHandledException(e.getMessage());
        auraException.setMessage(e.getMessage());
        return auraException;
    }
}