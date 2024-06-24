public without sharing class SRV_ExternalDataSynchronizer {
	private static final Map<String, Type> changeType2Strategy = new Map<String, Type> {
		DMN_ChangeRequest.CUSTOMER1_CLIENT => SRV_Customer1ClientSynchronizer.IService.class
	};

	public static void execute(Change_Request__e dataSyncRequest) {
		ISyncStrategy strategy = pickStrategy(dataSyncRequest);
		strategy.execute(dataSyncRequest);
	}

	private static ISyncStrategy pickStrategy(Change_Request__e dataSyncRequest) {
		Type pickedStrategy = changeType2Strategy.get(dataSyncRequest.EntityType__c);
		if (pickedStrategy == null) {
			throw new SyncStrategyException('Unknown entity type provided. Got ' + dataSyncRequest.EntityType__c + ', expected ' + changeType2Strategy.keySet());
		}
		return(ISyncStrategy) ORG_Application.service.newInstance(pickedStrategy);
	}

	public interface ISyncStrategy {
		void execute(Change_Request__e dataSyncRequest);
	}

	public class SyncStrategyException extends Exception { }
}