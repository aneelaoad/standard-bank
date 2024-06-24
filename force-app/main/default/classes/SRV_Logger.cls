/**
 * Service class for publishing Log_Event__e platform events.
 * <br/> US-4824
 *
 * @author Wojciech Kowalczyk (wkowalczyk@deloittece.com)
 * @date June 2020
 */
public without sharing class SRV_Logger implements IService {
	fflib_ISObjectUnitOfWork uow = ORG_Application.unitOfWork.newInstance();
	private static final sbgplatform.rflib_Logger LOGGER 		= sbgplatform.rflib_LoggerUtil.getFactory().createLogger('SRV_Logger');
	private static final sbgplatform.rflib_Logger BATCHLOGGER 	= sbgplatform.rflib_LoggerUtil.getFactory().createBatchedLogger('SRV_Logger');

	public interface IService {
		void log(Exception ex, String area);
		void log(Exception ex, String area, String source);
		void log(String ex, String area, String source);
		void log(Exception ex, String area, String source, List<String> additionalMessages);
		void log(List<Database.SaveResult> results, String area);
		void log(List<Database.SaveResult> results, String area, String source);
		void log(List<Database.UpsertResult> results, String area);
		void log(List<Database.UpsertResult> results, String area, String source);
		void log(List<Database.DeleteResult> results, String area);
		void log(List<Database.DeleteResult> results, String area, String source);
	}

	public static IService newInstance() {
		return (IService) ORG_Application.service.newInstance(IService.class);
	}

	public void log(Object ex, String area) {
		log((Exception) ex, area, null);
	}

	public void log(Object ex, String area, String source) {
		log((Exception) ex, area, source, new List<String>());
	}

	public void log(Object ex, String area, String source, List<String> additionalMessages) {
		Exception caughtException = (Exception) ex;
		/*Log_Event__e event = new Log_Event__e(
				Area__c = area,
				Context_User__c = UserInfo.getUserId(),
				Message__c = caughtException.getTypeName() + ': ' + caughtException.getMessage(),
				Source__c = source,
				Stack_trace__c = caughtException.getStackTraceString(),
				Type__c = DMN_Log.TYPE_ERROR
		);
		for (String message : additionalMessages) {
			event.Message__c += '\n' + message;
		}
		uow.registerPublishBeforeTransaction(event);
		uow.commitWork();*/
		LOGGER.error(area + '|' + source + String.valueOf((additionalMessages.isEmpty() ? '' : ('|'+String.join(additionalMessages, ',')))) , caughtException);
	}

    public void log(String error, String area, String source) {
		/*Log_Event__e event = new Log_Event__e(
				Area__c = area,
				Context_User__c = UserInfo.getUserId(),
				Message__c = error,
				Source__c = source,
				Type__c = DMN_Log.TYPE_ERROR
		);
		uow.registerPublishBeforeTransaction(event);
		uow.commitWork();*/
		LOGGER.error(area + '|' + source + error);
	}

	public void log(List<Database.SaveResult> results, String area) {
		log(results, area, null);
	}

	public void log(List<Database.SaveResult> results, String area, String source) {
		for(Integer i = 0, j = results.size(); i<j; i++) {
			if (!results[i].isSuccess()) {
				// uow.registerPublishBeforeTransaction(
				// 		createDmlLog(area, source, results[i].getErrors())
				// );
				BATCHLOGGER.error(area + '|' + source + '|' + generateDmlMessageCore(results[i].getErrors()));					
			}
		}
		// uow.commitWork();
		BATCHLOGGER.publishBatchedLogEvents();
	}

	public void log(List<Database.UpsertResult> results, String area) {
		log(results, area, null);
	}

	public void log(List<Database.UpsertResult> results, String area, String source) {
		for(Integer i = 0, j = results.size(); i<j; i++) {
			if(!results[i].isSuccess()) {
				// uow.registerPublishBeforeTransaction(
				// 		createDmlLog(area, source, results[i].getErrors())
				// );
				BATCHLOGGER.error(area + '|' + source + '|' + generateDmlMessageCore(results[i].getErrors()));
			}
		}
		//uow.commitWork();
		BATCHLOGGER.publishBatchedLogEvents();
	}

	public void log(List<Database.DeleteResult> results, String area) {
		log(results, area, null);
	}

	public void log(List<Database.DeleteResult> results, String area, String source) {
		for (Integer i = 0, j = results.size(); i<j; i++) {
			if(!results[i].isSuccess()) {
				// uow.registerPublishBeforeTransaction(
				// 		createDmlLog(area, source, results[i].getErrors())
				// );
				BATCHLOGGER.error(area + '|' + source + '|' + generateDmlMessageCore(results[i].getErrors()));
			}
		}
		//uow.commitWork();
		BATCHLOGGER.publishBatchedLogEvents();
	}

	/*private Log_Event__e createDmlLog(String area, String source, List<Database.Error> errors) {
		return new Log_Event__e(
				Area__c = area,
				Context_User__c = UserInfo.getUserId(),
				Message__c = generateDmlMessageCore(errors),
				Source__c = source,
				Type__c = DMN_Log.TYPE_ERROR
		);
	}*/

	private String generateDmlMessageCore(List<Database.Error> errors) {
		String messageCore = '';
		for(Integer i = 0, l = errors.size(); i<l; i++) {
			Database.Error err = errors[i];
			messageCore += '\nError ' + (i + 1) + ' details:';
			messageCore += '\nFields that affected the error condition: ';
			messageCore += err.getFields().size()> 0 ? err.getFields() + '\n' : 'N/A';
			messageCore += '\nError message: ' + err.getMessage() + '\n';
			messageCore += '\nError status code: ' + err.getStatusCode();
		}
		return messageCore;
	}
}