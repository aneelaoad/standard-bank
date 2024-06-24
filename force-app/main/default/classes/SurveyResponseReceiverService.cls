/***
@ Func Area     	:  CTI Softphone Integration
@ Author        	:  Created by Mykhailo
@ Date          	:  10.09.2019
@ User Story        :  US-4200 IVR Client survey responses
@ Description 	    :  Store survey data when invoked by external system into Survey_Response__c
@Modified           : Emmanuel Mulea (Nocks)
***/

global with sharing class SurveyResponseReceiverService {

/*
*@Decription : this web service works together with thinkConnect , it store a survey data when invoked by external system into Survey_Response__c
*
*@param :question this is a string
*@param :npsAnswer this is an integer from 1 to 9
*@param :WhatID this is a Case ID
*@param :WhoID this is Account ID
*/
    webservice static String createSurveyResponse(String question, Integer npsAnswer, Id WhatID, Id WhoID){
        //Auxiliary variables
        String npsAnswerString;
        Case[] givenCase;
        Account[] givenClient;
        
        // the reason we concatinating the IDs this string ,Mykhailo Reznyk said the service sometimes sends different dataTypes
        String WhatIdString = '' + WhatID;
        String WhoIdString = '' + WhoID;
		string entityType = '';
        /*
         * Checking if the WhatID is empty.
         * if so give it a null value to make sure the data types are consistant 
         *
		*/
        if(WhatIdString == ''){
            WhatID = null;
        }

        /*
         * Checking if the WhoID is empty
         *if so give it a null value to make sure the data types are consistant 
        */
        if(WhoIdString == ''){
            WhoID = null;
        }

        /*
         * If WhatID is not empty then Query Case Object to make sure that the ID exist
         *
        */
        if(WhatID != null){
            try{
                
                //check if the whatId passed by IVR is Case or Account , if is Case then run the if block
                entityType =  String.ValueOf(WhatId.getSobjectType());
                
                if(entityType!='Account'){
               		 givenCase = [SELECT Id FROM Case WHERE ID=:WhatID];
                }
            }
            catch(Exception e){
                /*
                 * If WhatID is not in SF then return error message
                 *
                */
                return 'Error during WhatID existence verification: ' + e.getMessage();
            }
        }

        /*
         * If WhoID is not empty then Query Account Object to make sure that the ID exist
         *
        */
        if(WhoID != null){
            try{
                
                Contact[] givenClientContact = [SELECT AccountId FROM Contact WHERE Id =:WhoID];
                if(givenClientContact.size()==0){
                    return 'Contact with such Id (' + WhoID + ') doesn\'t exist';
                }
                
                //check if The WhoId passed from IVR system has Account
                if(String.isBlank(givenClientContact[0].AccountId) || String.isEmpty(givenClientContact[0].AccountId)){
                    return 'Error during WhoID existence verification: The WhoId (contactId) is not linked to any Client';
                }
                
                givenClient = [SELECT Id FROM Account WHERE Id =:givenClientContact[0].AccountId];
                //swap contact to Account
                WhoID = givenClientContact[0].AccountId;
            }
            catch (Exception e){
               /*
                * If WhatID is not in SF then return error message
                *
               */
                return 'Error during WhoID existence verification: ' + e.getMessage();
            }
        }
        if(npsAnswer != null){
            npsAnswerString = npsAnswer+'';
        }

        /*
         * Inappropriate arguments validation to make sure if all varrables are set correctly ,if not then return error message to the end user
        */
        if(String.isBlank(question)){
            return 'Question field can not be empty or null';
        }
        else if(npsAnswerString!=null && npsAnswerString.length() > 1)
        {
            return 'NPS Answer max length is 1 character';
        }
        else if(npsAnswer == null){
            return 'NPS Answer field can not be null';
        }
        else if(givenCase != null && givenCase.size() == 0){
            return 'Case with such Id (' + WhatID + ') doesn\'t exist';
        }
        else if(givenClient != null && givenClient.size() == 0){
            return 'Account with such Id (' + WhoID + ') doesn\'t exist';
        }
        else{

            try{
             
                 /*
                  *	all data is set ,create Survey and return success message with survey name
                  * you will notice inline statement entityType=='Case'? WhatID:null , if the entity is Account then Ignore
                  *
                  */
                Survey_Response__c newResponse = new Survey_Response__c(Question__c = question, NPS_Answer__c = npsAnswer, WhatID__c = entityType=='Case'? WhatID:null, WhoID__c = WhoID);
                insert newResponse;
                newResponse = [SELECT Id, Name FROM Survey_Response__c WHERE Id=:newResponse.Id];
                return 'New Survey Response was successfully added: ' + newResponse.Name;
            }catch(Exception e){
                /*
                 * the error occured when creating a survey , returns an error message to the end user
                 *
                 */
                return 'Error during SurveyResponse object creation: ' + e.getMessage();
            }
        }
    }

}