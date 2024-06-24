public class DMN_CreditLine {   

	public static Credit_Line__share[] shareCreditLines(Set<Id> creditLineIds, Set<Id> userIds, String sharingReson, String accessLvl){

		Credit_Line__share[] sharingRecords = new Credit_Line__share[]{};
		for(Id clId : creditLineIds){
			for(Id usrId : userIds){
				Credit_Line__share cls = new Credit_Line__share(ParentId  = clId,
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