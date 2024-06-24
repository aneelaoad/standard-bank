/**
 * Created by akepczynski on 18.04.2018.
 */

public without sharing class UTL_Queue {
    
    private static  Map<Id, String> id2DevName {
                                        get{
                                            if(id2DevName == null){
                                                collectData();
                                            }
                                            return id2DevName;
                                        }
                                        set;
                                    }
    private static  Map<String, Id> name2Id {
                                        get{
                                            if(name2Id == null){
                                                collectData();
                                            }
                                            return name2Id;
                                        }
                                        set;
                                    }
    
    public static Id getQueueId(String queueName){
        if(!name2Id.containsKey(queueName)){
            throw new UTL_QueueException('There is no Queue named ' + queueName);
        }
        return name2Id.get(queueName);
    }
    
    public static String getQueueDevName(Id queueId){
        if(queueId.getSobjectType() != Group.sobjectType ){
            throw new UTL_QueueException(queueId + ' is not proper Queue Id');
        }
        if(!id2DevName.containsKey(queueId)){
            throw new UTL_QueueException('There is no Queue with Id ' + queueId);
        }
        
        return id2DevName.get(queueId);
    }
    
    private static void collectData(){
        name2Id = new Map<String, Id>();
        id2DevName = new Map<Id, String>();
        
        for(Group que : [   SELECT DeveloperName
                            FROM Group
                            WHERE Type = 'Queue']){
            name2Id.put(que.DeveloperName, que.Id);
            id2DevName.put(que.Id, que.DeveloperName);
        }
    }
   
    public class UTL_QueueException extends Exception{}
    
}