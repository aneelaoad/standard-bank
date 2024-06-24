/*  Copyright [2018] [salesforce.com]
*
*  Licensed under the Apache License, Version 2.0 (the "License");
*  you may not use this file except in compliance with the License.
*  You may obtain a copy of the License at
*
*  http://www.apache.org/licenses/LICENSE-2.0
*
*  Unless required by applicable law or agreed to in writing, software
*  distributed under the License is distributed on an "AS IS" BASIS,
*  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
*  See the License for the specific language governing permissions and
*  limitations under the License.
*/
/**
* @description
@ Last Modified By  : Sharath
@ Last Modified On  : 21 Sept , 2021
@ Last Modified Reason  : SFP-5036 : Creation of Case from Live Agent/Chat
**/
public with sharing class IBot_LiveChatTranscriptTriggerHelper {
    //SFP-5036 
    private static final String 
        OBJ_NAME                    = 'Case',
        RT_CROSS_BORDER             = 'Cross_Border_CoE_Record_Type',
        PRIORITY_HIGH               = 'High',
        DEFAULT_QUEUE               = 'CIBSA GM TPS&IPS Live Chat Queue',
        STATUS_NEW                  = 'New', 
        CHAT_BUTTON					= 'CIBSA_GM_MySupport';
/**
* Method that handles after insert trigger processing
* @param newRecords
*/      
    public static void handleAfterInsert(List<LiveChatTranscript> newRecords){
        updateCaseIdOnTranscripts(newRecords);       
    }    
/**
* Method that handles after update trigger processing
* @param newRecords
*/          
    //SFP-5036 - START
    public static void handleAfterUpdate(List<LiveChatTranscript> newRecords){
        createCase(newRecords);
    }//SFP-5036 - END
    
/**
* Method that updates case Id on the live chat transcripts
* @param newRecords
*/        
    private static void updateCaseIdOnTranscripts(List<LiveChatTranscript> newRecords){
        List<String> chatKeys = new List<String>();
        Map<String,LiveChatTranscript> tmap = new Map<String,LiveChatTranscript>();
        for(LiveChatTranscript elem : newRecords){
            chatKeys.add(elem.ChatKey);
            tmap.put(elem.ChatKey,elem);
        }
        
        List<Case> caseList = IBot_DynamicQueryUtils.getCasesUsingChatKeys(chatKeys);
        for(Case elem : caseList){
            if(tmap.get(elem.ChatKey__c) != NULL && tmap.get(elem.ChatKey__c).Id != NULL) {
                elem.Live_Chat_Transcript__c = tmap.get(elem.ChatKey__c).Id;
            }
        }
        
        if(!caseList.isEmpty()) {
            Database.update(caseList);
        }
    }
    
/**
* @description - Method Creates a new Case for every live agent chat
* User Story : SFP-5036
* @param newRecords
* 
**/
    private static void createCase(List<LiveChatTranscript> newRecords){
        List<ID> insertedCaseIds = new List<ID>();
        List<Case> casesToBeCreated = new list<Case>();
        Set<LiveChatTranscript> lctSet = new Set<LiveChatTranscript>();
        List<LiveChatTranscript> lctListToUpdate = new List<LiveChatTranscript>();
        list<QueueSobject> defaultQueue = [SELECT QueueId FROM QueueSobject WHERE queue.name =:DEFAULT_QUEUE];
        LiveChatButton mySupportChatButton = [SELECT Id, DeveloperName, MasterLabel FROM LiveChatButton where developerName =:CHAT_BUTTON];
        
        //logic to create a new Case for every liveChatTranscript record
        for(LiveChatTranscript elem : newRecords){
            
            if(elem.LiveChatButtonId == mySupportChatButton.Id && elem.Status == 'Completed' && elem.CaseId == null && elem.owner.name != 'Automated Process'){                
                Case cs = new Case(Subject = elem.Name, 
                                   Description = elem.Body,
                                   Origin = 'Live Chat',
                                   Status = STATUS_NEW,
                                   Priority = PRIORITY_HIGH,
                                   RecordTypeId = UTL_RecordType.getRecordTypeId(OBJ_NAME, RT_CROSS_BORDER),
                                   Live_Chat_Transcript__c = elem.Id,
                                   ContactId = elem.ContactId,
                                   AccountId = elem.Contact.AccountId,
                                   OwnerId = defaultQueue[0].queueId);            
                
                casesToBeCreated.add(cs);
            }
        }
        
        if(!casesToBeCreated.isEmpty()){
            Database.SaveResult[] srList = Database.insert(casesToBeCreated, false);
                        
            // Iterate through each returned result            
            for (Database.SaveResult sr : srList) {
                if (sr.isSuccess()) {
                    insertedCaseIds.add(sr.getId());
                }
                else {
                    // Operation failed, so get all errors                
                    for(Database.Error err : sr.getErrors()) {
                        System.debug('The following error has occurred during Case creation.');                    
                        System.debug(err.getStatusCode() + ': ' + err.getMessage());
                    }
                }
            }  
            
            //Trying to update the caseID field on the chatTranscripts with the new case record ID
            for(LiveChatTranscript elem : newRecords){
                if(elem.caseId == null && elem.status == 'Completed' && insertedCaseIds.size() > 0 ){
                    liveChatTranscript lct = new liveChatTranscript(Id = elem.Id, caseId = insertedCaseIds[0]);
                    lctSet.add(lct);        
                }
            }
        }
        
        lctListToUpdate.addall(lctSet);
        try{
            if(!lctListToUpdate.isEmpty()){
                database.update(lctListToUpdate);    
            }
        }
        catch(Exception ex){
            throw new CaseException(ex.getMessage());
        }
    }
    
    public class CaseException extends Exception{}
}