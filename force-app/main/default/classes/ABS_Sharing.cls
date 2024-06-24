public abstract class ABS_Sharing {

	public SobjectType getSobjectType(){
		return sharingType; 
	}

	private Map<Id, User[]> parentId2Users;
		private Map<Id, Sobject[]> parentId2Team;
		protected Map<Id, Sobject[]> parentId2Records; 
		private Set<Id> parentIds;
		private Map<String, Sobject> key2Sharing{
													get{
														if(key2Sharing == null){
															key2Sharing = fetchSharing();
														}
														return key2Sharing;
													}
													set;
												}

	protected SobjectType sharingType{	get{ 
												if(sharingType == null){
													throw new ABS_SharingException('sharingType must be implemented!');
												}
												if(!String.valueof(sharingType).tolowerCase().contains('share')){
													throw new ABS_SharingException('sharingType must be share object!');
												}
												return sharingType;
											}
										set;
										} 

	protected Sharing_Settings__c defaultSharing{
													get{
														if(defaultSharing == null){
															defaultSharing = new Sharing_Settings__c(	
																						Access_Level__c 	= 'Read',
																						Sharing_Reason__c 	= 'Manual'); 
														}
														return defaultSharing; 
													}
													set;
												}
 
	private static Map<String, Sharing_Settings__c> code2ShareSetting{
				get{
					if(code2ShareSetting == null){
						code2ShareSetting = new Map<String, Sharing_Settings__c>();
						for(Sharing_Settings__c ss : Sharing_Settings__c.getAll().values()){
							String mapKey = buildSharingSetKey(ss.Sharing_Sobject_Type__c, ss.Sobject_Type__c, ss.Key_Value__c);
							code2ShareSetting.put(mapKey, ss);
						}
					}
					return code2ShareSetting;
				}
				set; 
			}

	private UTL_DmlResult.GenericResult[] shareDmlREsults{
															get{
																if(shareDmlREsults == null){
																	shareDmlREsults = new UTL_DmlResult.GenericResult[]{};
																}
																return shareDmlREsults;
															}
															set;
														}

	public void init(Map<Id, User[]> parentId2Users, Map<Id, Sobject[]> parentId2Team, Map<Id, Sobject[]> parentId2Records){
		this.parentId2Users		= parentId2Users;
		this.parentId2Team		= parentId2Team;
		this.parentId2Records 	= parentId2Records;
		this.parentIds = new Set<Id>();
		parentIds.addAll(parentId2Users.keySet());
		parentIds.addAll(parentId2Team.keySet());
		parentIds.addAll(parentId2Records.keySet());
	}

	public void share(){
		Sobject[] shares = new Sobject[]{};
		for(Id parentId : parentId2Records.keySet()){
			User[] users 		= parentId2Users.containsKey(parentId) 	 ? parentId2Users.get(parentId) : new User[]{};
			Sobject[] records 	= parentId2Records.containsKey(parentId) ? parentId2Records.get(parentId) : new Sobject[]{};
			Sobject[] team 		= parentId2Team.containsKey(parentId)    ? parentId2Team.get(parentId) : new Sobject[]{};
			shares.addAll(createShares(users, records, team));
		}

		if(!shares.isEmpty()){
			processRecords(shares, null, null);
		}
	}

	public void shareUpdate(){
		Map<String, Sobject[]> tempShares = new Map<String, Sobject[]>{	ABS_SharingService.ADD => new Sobject[]{},
																		ABS_SharingService.REMOVE => new Sobject[]{}};
		for(Id parentId : parentId2Records.keySet()){
			User[] users 		= parentId2Users.containsKey(parentId) 	 ? parentId2Users.get(parentId) : new User[]{};
			Sobject[] records 	= parentId2Records.containsKey(parentId) ? parentId2Records.get(parentId) : new Sobject[]{};
			Sobject[] team 		= parentId2Team.containsKey(parentId)    ? parentId2Team.get(parentId) : new Sobject[]{};
			Map<String, Sobject[]> tempMap = updateShares(users, records, team);

			if(tempMap.keySet().size() != 2 
				|| !tempMap.containsKey(ABS_SharingService.ADD)
				|| !tempMap.containsKey(ABS_SharingService.REMOVE)){
				throw new ABS_SharingException('update share must retun map with only 2 keys "' + 
												ABS_SharingService.ADD + '" & "' + ABS_SharingService.REMOVE +'"!'); 
			}

			if(!tempMap.get(ABS_SharingService.ADD).isEmpty()){
				tempShares.get(ABS_SharingService.ADD).addAll(tempMap.get(ABS_SharingService.ADD));
			}
			if(!tempMap.get(ABS_SharingService.REMOVE).isEmpty()){ 
				tempShares.get(ABS_SharingService.REMOVE).addAll(tempMap.get(ABS_SharingService.REMOVE));
			}
		}

		processRecords(tempShares.get(ABS_SharingService.ADD), null, tempShares.get(ABS_SharingService.REMOVE));
	}  

	public void removeShare(){
		Sobject[] shares = new Sobject[]{};
		for(Id parentId : parentId2Records.keySet()){
			User[] users 		= parentId2Users.containsKey(parentId) 	 ? parentId2Users.get(parentId) : new User[]{};
			Sobject[] records 	= parentId2Records.containsKey(parentId) ? parentId2Records.get(parentId) : new Sobject[]{};
			Sobject[] team 		= parentId2Team.containsKey(parentId)    ? parentId2Team.get(parentId) : new Sobject[]{};
			shares.addAll(deleteShares(users, records, team));
		}

		if(!shares.isEmpty()){
			processRecords(null, null, shares);
		}
	}

	protected virtual SObject[] createShares(User[] users, Sobject[] records, Sobject[] team){
		throw new ABS_SharingException('You must define creation logic!'); 		
	} 

	protected virtual Map<String, SObject[]> updateShares(User[] users, Sobject[] records, Sobject[] team){
		return new Map<String, Sobject[]>{	ABS_SharingService.ADD => new Sobject[]{},
											ABS_SharingService.REMOVE => new Sobject[]{}};
		//throw new ABS_SharingException('You must define update logic!'); 		
	} 

	protected virtual SObject[] deleteShares(User[] users, Sobject[] records, Sobject[] team){
		throw new ABS_SharingException('You must define remove logic!'); 		
	} 

	private Map<String, Sobject> fetchSharing(){
		Set<Id> recordIds = new Set<Id>();
		String parentId = getSharingParentlink(sharingType);
		String fields 	= getSharingFields(sharingType);

		for(Sobject[] records : parentId2Records.values()){
			for(Sobject sObj : records){
				recordIds.add((Id)sObj.get('Id'));
			}
		}

		Sobject[] sharings =  Database.query(	' SELECT ' + fields +
												' FROM  ' + String.valueOf(sharingType) + ' ' + 
												' WHERE ' + parentId + ' IN: recordIds ' +
												' AND RowCause NOT IN (\'Rule\', \'Team\', \'Owner\', \'ImplicitParent\')');

		Map<String, Sobject> key2Sharing = new Map<String, Sobject>();
		for(Sobject share : sharings){
			String recordId = (String)share.get(parentId);
			String userId = (String)share.get('UserOrGroupId'); 

			key2Sharing.put(concate(userId, recordId), share);
		}
		return key2Sharing;
	}

	public String getSharingFields(SobjectType sharingType){

		String[] fields = new String[]{};
		for(SobjectField sf : sharingType.getDescribe().fields.getMap().values()){
			fields.add(sf.getDescribe().getName());
		}
		return String.join(fields, ', ');
	}

	public String getSharingParentlink(SobjectType sharingType){
		for(SobjectField sf : sharingType.getDescribe().fields.getMap().values()){
			Set<sObjectType> sTypes = new Set<sObjectType>(sf.getDescribe().getReferenceTo());

			if(sTypes != null 
				&& !sTypes.contains(User.SobjectType)
				&& sf.getDescribe().getName() != 'Id'){
				return sf.getDescribe().getName();
			}
		}
		return 'ParentId';
	}

	public virtual Map<Id, Sobject[]> fetchRecords(Set<Id> parentIds){
		throw new ABS_SharingException('You must define data query!'); 
	}

	protected Sobject getSharing(Id userId, Id recordId){ 

		return key2Sharing.get(concate(userId, recordId));
	}

	private String concate(String userId, String recordId){ 

		if(((Id)userId).getSobjectType() != User.SobjectType && ((Id)userId).getSobjectType() != Group.SobjectType){
			throw new ABS_SharingException('UserId paramteher must belong to User Sobject or Group. Wrong Id Type. Id: ' + userId);
		} 

		return userId + recordId; 
	}

	protected Sharing_Settings__c getSharingOptions(SobjectType sobjType, String codeValue){
		
		String mapKey = buildSharingSetKey(String.valueOf(sharingType), String.valueOf(sobjType), codeValue);

		if(String.isNotBlank(mapKey) 
			&& code2ShareSetting.containsKey(mapKey)){
			return code2ShareSetting.get(mapKey);
		}
		return defaultSharing; 
	}

	private static String buildSharingSetKey(String shrType,  String sobjType, String codeValue){
		String mapKey = shrType + sobjType + codeValue;
		mapKey = mapKey.remove('null');
		mapKey = mapKey.remove(' ');
		mapKey = mapKey.tolowerCase();

		return mapKey;
	} 

	private void processRecords(Sobject[] recToInsert, Sobject[] recToUpdate, Sobject[] recToDelete){
		if(recToDelete != null && !recToDelete.isEmpty()){
			shareDmlREsults.addAll(UTL_DmlResult.deleteRecords(recToDelete, false, false));
		} 
		if(recToInsert != null && !recToInsert.isEmpty()){
			shareDmlREsults.addAll(UTL_DmlResult.insertRecords(recToInsert, false, false));
		}
		if(recToUpdate != null && !recToUpdate.isEmpty()){
			shareDmlREsults.addAll(UTL_DmlResult.updateRecords(recToUpdate, false, false));
		}
	}

	public UTL_DmlResult.GenericResult[] getResults(){
		return shareDmlREsults;
	}

	public class ABS_SharingException extends Exception {}
}