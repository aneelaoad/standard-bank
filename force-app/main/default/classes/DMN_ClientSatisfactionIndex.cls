public class DMN_ClientSatisfactionIndex {

	public static Client_Satisfaction_Index__share[] shareCsi(Set<Id> csiIds, Set<Id> userIds, String sharingReson, String accessLvl){

		Client_Satisfaction_Index__share[] sharingRecords = new Client_Satisfaction_Index__share[]{};
		for(Id csiId : csiIds){
			for(Id usrId : userIds){
				Client_Satisfaction_Index__share cls = new Client_Satisfaction_Index__share(ParentId  = csiId,
																UserOrGroupId = usrId,
																AccessLevel = accessLvl);
				if(String.isNotBlank(sharingReson)){
					cls.RowCause = sharingReson;
				}
				sharingRecords.add(cls); 
			}  
		} 
		return sharingRecords;
	}  
}