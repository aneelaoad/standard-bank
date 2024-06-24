public abstract class ABS_SharingService {
    protected	Map<String, DTO_Records> opr2data{
        get{
            if(opr2data == null){
                opr2data = new Map<String, DTO_Records>{
                    ADD 	=> new DTO_Records(ADD, this.teamType, sObj2Type.keySet()),
                        CHANGE 	=> new DTO_Records(CHANGE, this.teamType, sObj2Type.keySet()),
                        REMOVE 	=> new DTO_Records(REMOVE, this.teamType, sObj2Type.keySet())};
                            }
            return opr2data;
        }
        set;
    }
    public static final String 
        ADD 	= 'ADD',
        CHANGE 	= 'CHANGE',
        REMOVE 	= 'REMOVE';
    
    public static Map<String, Set<String>> action2values{
        get{
            if(action2values == null){
                action2values = new Map<String, Set<String>>{
                    ADD 	=> new Set<String>(),
                        CHANGE 	=> new Set<String>(),
                        REMOVE 	=> new Set<String>()};
                            }
            return action2values;
        }
        set;
    }
    
    private Set<String> sObjTypeLimiter{
        get{
            if(sObjTypeLimiter == null){
                sObjTypeLimiter = new Set<String>();
            }
            return sObjTypeLimiter;
        }
        set;
    }
    
    protected SobjectType teamType{ 
        get{
            if(teamType == null){
                throw new ABS_SharingServiceException('You must define Team Type');
            }
            return teamType;
        }
        set;
    }
    
    protected Map<SobjectType, Type> sObj2Type{
        get{
            if(sObj2Type == null){
                throw new ABS_SharingServiceException('You must define sObj2Type!');
            }
            return sObj2Type;
        }
        set;
    }
    private static Boolean isEnforceSynchronic;
    
    public ABS_SharingService(){ 
        isEnforceSynchronic = false;
    }
    
    @TestVisible
    private static void enforceSynchronic(Boolean isEnforced){
        isEnforceSynchronic = isEnforced;
    }
    
    private Map<Id, Sobject[]> fetchData(Map<Id, Sobject[]> orginalData, Map<Id, Sobject[]> newData, SobjectType sType){
        Map<Id, Sobject[]> parentId2Data = new Map<Id, Sobject[]>(); 
        Set<Id> parentIds = new Set<Id>();
        Map<Id, Sobject[]> contextData = new Map<Id, Sobject[]>();
        
        for(Id key : orginalData.keyset()){
            for(Sobject sObj : orginalData.get(key)){
                if(sType != null 
                   && sObj.getSobjectType() != sType){
                       continue;
                   }
                if(!contextData.containsKey(key)){
                    contextData.put(key, new Sobject[]{});
                }
                contextData.get(key).add(sObj);
            }
        }
        
        parentIds.addAll(contextData.keySet()); 
        parentIds.addAll(newData.keySet());
        
        for(Id parentId : parentIds){  
            
            if(contextData.containsKey(parentId)
               && !newData.containsKey(parentId)){
                   parentId2Data.put(parentId, contextData.get(parentId));
               }
            else if (!contextData.containsKey(parentId)
                     && newData.containsKey(parentId)) {
                         parentId2Data.put(parentId, newData.get(parentId));
                     }
            else if(!contextData.containsKey(parentId)
                    && !newData.containsKey(parentId)){
                        throw new ABS_SharingServiceException('Unexpected Parent Id ' + parentId + '!');
                    }
            else{
                Sobject[] records = newData.get(parentId);
                Map<Id, Sobject> recId2Rec = new Map<Id, Sobject>(records);
                
                Sobject[] orginalRecords = contextData.get(parentId);
                Map<Id, Sobject> recId2OldRec = new Map<Id, Sobject>(orginalRecords);
                
                Set<Id> ids = new Set<Id>();
                if(recId2OldRec.containsKey(parentId)){
                    ids.addAll(recId2Rec.keySet());
                } 
                ids.addAll(recId2OldRec.keySet());
                
                for(Id recId : ids){
                    if(!parentId2Data.containsKey(parentId)){
                        parentId2Data.put(parentId, new Sobject[]{});
                    }
                    if(recId2Rec.containsKey(recId)
                       && recId2OldRec.containsKey(recId)){
                           parentId2Data.get(parentId).add(recId2Rec.get(recId));
                       }
                    else if(!recId2Rec.containsKey(recId)
                            && recId2OldRec.containsKey(recId)){
                                parentId2Data.get(parentId).add(recId2OldRec.get(recId));
                            }
                    else if(recId2Rec.containsKey(recId)
                            && !recId2OldRec.containsKey(recId)){
                                parentId2Data.get(parentId).add(recId2Rec.get(recId));
                            }
                }
            }
        }   
        return parentId2Data;
    }
    
    protected virtual Map<Id, Sobject[]> fetchTeam(Set<Id> parentIds){
        throw new  ABS_SharingServiceException('You must define team collecting logic!');
    }
    
    public void share(Id parentId, Sobject record){
        share(parentId, new Sobject[]{record});
    }
    public void share(Id parentId, Sobject[] records){
        apply(ADD, parentId, records);
    }
    
    public void change(Id parentId, Sobject record){
        change(parentId, new Sobject[]{record});
    }
    public void change(Id parentId, Sobject[] records){
        apply(CHANGE, parentId, records);
    }
    
    public void remove(Id parentId, Sobject record){
        remove(parentId, new Sobject[]{record});
    }
    public void remove(Id parentId, Sobject[] records){
        apply(REMOVE, parentId, records);
    }
    
    public void apply(String action, Id parentId, SObject[] record){
        
        if(action==null || parentId==null || record==null)
            return;
        
        DTO_Records data = opr2data.get(action);
        Sobject[] filteredRecords = new Sobject[]{};
            
            for(SObject sobj : record){
                String recordId = ((String)sobj.get('Id')) + parentId;
                if(!action2values.get(action).contains(recordId)){
                    filteredRecords.add(sobj);
                    action2values.get(action).add(recordId);
                }
            } 
        if(!filteredRecords.isEmpty()){
            data.apply(parentId, filteredRecords);
        }
    }  
    
    public void run(){
        run(true);
    }  
    
    private void run(Boolean isUseAsync){
        if(getParentIds().isEmpty()){
            return;
        }
        else if(isUseAsync && !System.isBatch() && !System.isFuture()){
            String className =  String.valueOf(this).split(':')[0];
            runAsync(JSON.serialize(opr2data), className);
        }
        else{
            execute();
        }
    } 
    
    @future
    private static void runAsync(String data, String className){
        Type customType = Type.forName(className);
        ABS_SharingService shr = (ABS_SharingService)customType.newInstance();
        shr.setContext(data);
        shr.execute();
    }
    
    protected void setContext(String context){
        this.opr2data = (Map<String, DTO_Records>)JSON.deserialize(context, Map<String, DTO_Records>.class);
    } 
    
    private Set<Id> getParentIds(){
        Set<Id> parentIds = new Set<Id>();
        for(DTO_Records data : opr2data.values()){
            parentIds.addAll(data.getparentIds() );
        }
        return parentIds;
    }
    
    private void execute(){
        Set<Id> parentIds = getParentIds();
        Map<SobjectType, ABS_Sharing> sObj2Strategy = buildSharingMap(); 
        Map<Id, Sobject[]> parentId2FullTeam = fetchTeam(parentIds);
        UTL_DmlResult.GenericResult[] shareDmlREsults = new UTL_DmlResult.GenericResult[]{};
            
            for(SobjectType sType : sObj2Strategy.keyset()){
                ABS_Sharing share = sObj2Strategy.get(sType);
                Map<Id, Sobject[]> existingData = null; 
                for(String opr : new String[]{REMOVE, CHANGE, ADD}){ 
                    DTO_Records data = opr2data.get(opr);
                    if(!data.hasData(sType)){
                        continue;
                    }
                    if(existingData == null){ 
                        existingData = share.fetchRecords(parentIds);
                    }
                    
                    Map<Id, Sobject[]> id2oprData = filterContextData(existingData, data.getparentIds());
                    Map<Id, Sobject[]> id2oprteam = filterContextData(parentId2FullTeam, data.getparentIds());
                    
                    Map<Id, Sobject[]> parentId2TeamData = fetchData(data.parentId2Team, id2oprteam, teamType);
                    Map<Id, Sobject[]> parentId2RecordData = fetchData(	data.parentId2Records, 
                                                                       id2oprData, 
                                                                       sType);
                    
                    if(parentId2TeamData.isEmpty() || parentId2RecordData.isEmpty()){
                        continue;
                    }
                    share.init(data.parentId2Users, parentId2TeamData, parentId2RecordData);
                    
                    if(opr == ADD){
                        share.share();
                    }
                    if(opr == CHANGE){
                        share.shareUpdate();
                    }
                    if(opr == REMOVE){
                        share.removeShare();
                    } 
                }
                
                shareDmlREsults.addAll(share.getResults());
                //Added to fix a production issue SFP-13012 - START
                UTL_DmlResult.GenericResult[] fails = UTL_DmlResult.fetchFails(shareDmlREsults);
                if(!fails.isEmpty()){
                    List<Id> errorIds = new List<Id>();
                    List<Id> errorUserIds = new List<Id>();
                    map<Id, String> erroredRecordMap = new Map<Id, String>();
                    map<Id, String> erroredUserMap = new Map<Id, String>();
                    for(UTL_DmlResult.GenericResult fail : fails){
                        String parField = getSharingParentlink(fail.getRecord().getSobjectType());     
                    	errorIds.add((Id)fail.getRecord().get(parField));
                       	errorUserIds.add((Id)fail.getRecord().get('UserOrGroupId'));
                    } 
                    for(Account acc :[SELECT Id, Name FROM Account WHERE Id =:errorIds] ){
                        erroredRecordMap.put(acc.Id, acc.Name);
                    }
                    for(Opportunity opp :[SELECT Id, Name FROM Opportunity WHERE Id =:errorIds] ){
                        erroredRecordMap.put(opp.Id, opp.Name);
                    }
                    for(User u :[SELECT Id, FirstName, LastName FROM User WHERE Id =:errorUserIds] ){
                        erroredUserMap.put(u.Id, u.LastName + ',' + u.FirstName);
                    }
                    
                    for(UTL_DmlResult.GenericResult fail : fails){
                        String parentField = getSharingParentlink(fail.getRecord().getSobjectType());                        
                        String errorMessage = 'Access was not granted for ' + 'the user ' + '"' + erroredUserMap.get((Id)fail.getRecord().get('UserOrGroupId')) + '"' + ' with Id ' + '"' + fail.getRecord().get('UserOrGroupId') + ' on ' + '"' + erroredRecordMap.get((id)fail.getRecord().get(parentField)) + '"' + ' with Id ' + '"' + fail.getRecord().get(parentField) + '"' + ', due to an error: "' + fail.getErrorMessage() +'"';
                        SRV_Logger.newInstance().log(errorMessage, DMN_Log.TYPE_ERROR, ABS_SharingService.class.getName());    
                    }
                }
                if(test.isRunningTest()){
                    notifyInCaseOfError(shareDmlREsults);                
                }//Added to fix a production issue SFP-13012 - END
            }
    }
    
    private void notifyInCaseOfError(UTL_DmlResult.GenericResult[] shareDmlREsults){
        UTL_DmlResult.GenericResult[] fails = UTL_DmlResult.fetchFails(shareDmlREsults);
        
        if(fails.isEmpty() && !test.isRunningTest()){
            return;
        }
        String subject = 'Errors when Sharing Records on ' + URL.getSalesforceBaseUrl().getHost();
        String[] toAdresses = new String[]{}; // here  put email adress to send error notification
            String[] errorMessages = new String[]{};
                for(UTL_DmlResult.GenericResult fail : fails){
                    String parentField = getSharingParentlink(fail.getRecord().getSobjectType());
                    String errorMessage = 'access was not granted on ' + fail.getRecord().get(parentField) + ' for ' + fail.getRecord().get('UserOrGroupId') + ', error:" ' + fail.getErrorMessage()  + '"<br/>';
                    errorMessages.add(errorMessage);
                }
        
        Messaging.SingleEmailMessage[] emails = new Messaging.SingleEmailMessage[]{ 
            UTL_Email.createEmails(subject, String.join(errorMessages, ' '), toAdresses)
                };
                    if(!test.isRunningTest()){
                        Messaging.sendEmail(emails);                                
                    }
    }
    
    /**
    * @description getSharingParentlink Method fetches id of the parent
    *
    * @param sharingType SobjectType
    *
    * @return Id of the parent record
    */
    
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
    
    private Map<Id, Sobject[]> filterContextData(Map<Id, Sobject[]> fullData, Set<Id> filter){
        Map<Id, Sobject[]> id2oprData = new Map<Id, Sobject[]>();
        for(Id key : fullData.keyset()){
            if(filter.contains(key)){
                id2oprData.put(key, fullData.get(key));
            }
        }
        return id2oprData;
    }
    
    private Map<SobjectType,ABS_Sharing> buildSharingMap(){
        Map<SobjectType, ABS_Sharing> sObj2Strategy = new Map<SobjectType,  ABS_Sharing>();
        Set<SobjectType> types = sObj2Type != null ? sObj2Type.keySet() : new Set<SobjectType>();
        
        if(types.isEmpty()){
            for(Id parentId : getParentIds()){
                types.add(parentId.getSobjectType());
            }
        }
        
        for(SobjectType sobjType : sObj2Type.keySet()){
            sObj2Strategy.put(sobjType, fetchSharingClassType(sobjType));
        }
        
        return sObj2Strategy; 
    } 
    
    private ABS_Sharing fetchSharingClassType(SobjectType sobjType){
        if(!sObj2Type.containsKey(sobjType)){
            throw new ABS_SharingServiceException('There is no logic for Sharing Sobject: ' + String.valueOf(sobjType));
        }
        return (ABS_Sharing)sObj2Type.get(sobjType).newInstance(); 
    } 
    
    /**
    * @description DTO_Records method assigns the records for sharing 
    */
    
    public class DTO_Records{
        
        public String teamType;
        public Set<String> recordStypes;
        public String name;
        
        public Map<Id, User[]> parentId2Users;
        public Map<Id, Sobject[]> parentId2Team;
        public Map<Id, Sobject[]> parentId2Records; 
        
    /**
    * @description DTO_Records method assigns the records for sharing 
    *
    * @param name string
    * @param teamType Sobject Type
    * @param recordStypes set of Sobject Types
    */
        public DTO_Records(String name, SobjectType teamType, Set<SobjectType> recordStypes){
            this.name = name;
            this.teamType = String.valueOf(teamType);
            this.recordStypes = new Set<String>();
            for(SobjectType st : recordStypes){
                this.recordStypes.add(String.valueOf(st));
            }
            parentId2Users 		= new Map<Id, User[]>();
            parentId2Team 		= new Map<Id, Sobject[]>();
            parentId2Records 	= new Map<Id, Sobject[]>();
        }
        
    /**
    * @description apply method applies the sharing 
    *
    * @param record sobject record
    * @param parentId id of the parent record
    */
        
        public void apply(Id parentId, Sobject record){
            apply(parentId, new Sobject[]{record});
        }
        
    /**
    * @description apply method applies the sharing 
    *
    * @param records sobject records
    * @param parentId id of the parent record
    */
        
        public void apply(Id parentId, Sobject[] records){
            for(Sobject rec  : records){
                if(String.valueOf(rec.getSobjectType()) == String.valueOf(User.SobjectType)){
                    UTL_Collections.addToMap(parentId2Users, parentId, records);
                }
                else if(String.valueOf(rec.getSobjectType()) == teamType){
                    UTL_Collections.addToMap(parentId2Team, parentId, records);
                }
                else if(recordStypes.contains(String.valueOf(rec.getSobjectType()))){
                    UTL_Collections.addToMap(parentId2Records, parentId, records);
                }
                else { 
                    throw new DTO_Exception('Error while adding record to share. Unable to process Type: ' + rec.getSobjectType());
                } 
            }
        }
        
    /**
    * @description getparentIds Method fetches the Id of the parent records
    *
    * @return set of parent ID
    */
        
        public Set<Id> getparentIds(){
            Set<Id> parentIds = new Set<Id>();
            parentIds.addAll(parentId2Records.keyset());
            parentIds.addAll(parentId2Team.keyset());
            parentIds.addAll(parentId2Users.keyset()); 
            
            return parentIds;  
        }
    /**
    * @description hasData Method fetches the records
    *
    * @param sType SobjectType
    *
    * @return yes or no
    */
        
        public Boolean hasData(SobjectType sType){ 
            if(!parentId2Team.isEmpty()){
                return true;
            } 
            
            for(Sobject[] sObjlist : parentId2Records.values()){
                for(Sobject sObj : sObjlist){
                    if(sObj.getSobjectType() == sType){
                        return true;
                    }
                }
            }
            
            return false;
        } 
    }
    
    /**
	* @description DTO_Exception extension for exception class
	*/
    
    public class DTO_Exception extends Exception{}
    
    /**
	* @description ABS_SharingServiceException extension for exception class
    */
    
    public class ABS_SharingServiceException extends Exception{}
}