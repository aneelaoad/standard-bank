/**
 * @description Class allow logging at an instance level
 *
 * @author originally provided by mlockett @ https://github.com/mlockett/ApexLogger
 *
 * @date 2019-01-15
 */
public without sharing class CMN_UTIL_Logger {
	
	public static final String INFO = 'INFO';
	public static final String DEBUG = 'DEBUG';
	public static final String WARN = 'WARN';
	public static final String ERROR = 'ERROR';
    private static final sbgplatform.rflib_Logger LOGGER = sbgplatform.rflib_LoggerUtil.getFactory().createLogger('CMN_UTIL_Logger');
	/**
	 * @description writes log with message data
	 *
	 * @param message message to be logged
	 * @param classMethod <class>.<method> if applicable
	 */
	public static void debug(String message, String classMethod) {
        //SRV_Logger.newInstance().log(DEBUG+message, DMN_Log.AREA_AOB, classMethod);
		LOGGER.debug(classMethod + '|' + DMN_Log.AREA_AOB + '|' + message);
	}

	/**
	 * @description writes log with message data
	 *
	 * @param message message to be logged
	 * @param classMethod <class>.<method> if applicable
	 * @param affectedId record Id(s) related to log event
	 */
	public static void debug(String message, String classMethod, String affectedId) {
        //SRV_Logger.newInstance().log(DEBUG+message, DMN_Log.AREA_ONEHUB, classMethod);
		LOGGER.debug(classMethod + '|' + DMN_Log.AREA_ONEHUB + '|' + affectedId + '|' + message);
	}

	/**
	 * @description writes log with message data
	 *
	 * @param message message to be logged
	 * @param classMethod <class>.<method> if applicable
	 */
	public static void info(String message, String classMethod) {
        //SRV_Logger.newInstance().log(INFO+message, DMN_Log.AREA_ONEHUB, classMethod);
		LOGGER.info(classMethod + '|' + DMN_Log.AREA_ONEHUB + '|' + message);
	}

	/**
	 * @description writes log with message data
	 *
	 * @param message message to be logged
	 * @param classMethod <class>.<method> if applicable
	 */
	public static void warn(String message, String classMethod) {
        //SRV_Logger.newInstance().log(WARN+message, DMN_Log.AREA_ONEHUB, classMethod);
		LOGGER.warn(classMethod + '|' + DMN_Log.AREA_ONEHUB + '|' + message);
	}

	/**
	 * @description writes log with message data
	 *
	 * @param message message to be logged
	 * @param classMethod <class>.<method> if applicable
	 * @param affectedId record Id(s) related to log event
	 */
	public static void warn(String message, String classMethod, String affectedId) {
        //SRV_Logger.newInstance().log(WARN+message, DMN_Log.AREA_ONEHUB, affectedId+'-'+classMethod);
		LOGGER.warn(classMethod + '|' + DMN_Log.AREA_ONEHUB + '|' + affectedId + '|' + message);
	}

	/**
	 * @description Write error with exception data
	 *
	 * @param ex exception to log
	 * @param classMethod <class>.<method> if applicable
	 */
	public static void error(Exception ex, String classMethod) {
        //SRV_Logger.newInstance().log(ex, DMN_Log.AREA_ONEHUB, classMethod);
        LOGGER.error(classMethod+'|'+DMN_Log.AREA_ONEHUB, ex);
	}
    
	/**
	 * @description writes log with message data
	 *
	 * @param message message to be logged
	 * @param classMethod <class>.<method> if applicable
	 */
	public static void error(String message, String classMethod) {
        //SRV_Logger.newInstance().log(ERROR+message, DMN_Log.AREA_ONEHUB, classMethod);
        LOGGER.error(classMethod + '|' + DMN_Log.AREA_ONEHUB + '|' + message);
	}
}