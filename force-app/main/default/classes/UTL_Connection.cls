public without sharing class UTL_Connection {
	
	private static Map<String, Id> name2ConnectionId{get{
														if(name2ConnectionId == null){
															populateMaps();
														}
														return name2ConnectionId;
													}
													set;
												}

	private static Map<Id, String> id2ConnectionName{get{
														if(id2ConnectionName == null){
															populateMaps();
														}
														return id2ConnectionName;
													}
													set;
												}

	private static void populateMaps(){
		name2ConnectionId = new Map<String, Id>();
		id2ConnectionName = new Map<Id, String>();

		for(PartnerNetworkConnection con : [SELECT ConnectionStatus, ConnectionName 
						        			FROM PartnerNetworkConnection 
						        			WHERE Connectionstatus = 'Accepted']){
			name2ConnectionId.put(con.ConnectionName, con.Id);
			id2ConnectionName.put(con.Id, con.ConnectionName);
		}
	}

	public static Id getConnectionId(String connectionName){
		if(!name2ConnectionId.containsKey(connectionName)){
			throw new UTL_ConnectionException('There is no active connection with name "' + connectionName + '"');
		}
		return name2ConnectionId.get(connectionName);
	}

	public static String getConnectionName(String connectionId){
		if(!id2ConnectionName.containsKey(connectionId)){
			throw new UTL_ConnectionException('There is no active connection with Id "' + connectionId + '"');
		}
		return id2ConnectionName.get(connectionId);
	}

	public class UTL_ConnectionException extends Exception{}

}