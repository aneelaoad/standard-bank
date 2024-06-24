/**
 * Created by aadrianowska on 20.06.2018.
 */

global class BCH_PopulateMNPIOnBA implements Database.Batchable<sObject>, Database.Stateful {

        private final String[] notifyEmails;
        global Integer successfulRecs, allRecs;

        global BCH_PopulateMNPIOnBA(String[] emails) {
            this.notifyEmails = emails;
            this.successfulRecs = 0;
            this.allRecs = 0;
        }

        global Iterable<sObject> start(Database.BatchableContext BC) {
            return [
                    SELECT Business_Assessment__c, Business_Assessment__r.MNPI__c
                    FROM Assessment_Opportunity__c
                    WHERE Opportunity__c
                        IN (SELECT Id FROM Opportunity WHERE Price_Sensitive__c = true)
            ];
        }

        global void execute(Database.BatchableContext BC, List<sObject> scope) {

            Assessment_Opportunity__c[] oppAssessments = (Assessment_Opportunity__c[]) scope;
            Set<Business_Assessment__c> businessAssessments = new Set<Business_Assessment__c>();
            for(Assessment_Opportunity__c oppAssessment : oppAssessments) {
                if(oppAssessment.Business_Assessment__r.MNPI__c != true) {
                    Business_Assessment__c businessAssessment = new Business_Assessment__c();
                    businessAssessment.MNPI__c = true;
                    businessAssessment.Id = oppAssessment.Business_Assessment__c;
                    businessAssessments.add(businessAssessment);
                }
            }
            if(!businessAssessments.isEmpty()) {
                List<Business_Assessment__c> businessAssessmentsToUpdate = new List<Business_Assessment__c>();
                businessAssessmentsToUpdate.addAll(businessAssessments);
                Database.SaveResult[] srs = Database.update(businessAssessmentsToUpdate, false);
                for (Database.SaveResult sr : srs) {
                    allRecs++;
                    if (sr.isSuccess()) {
                        successfulRecs++;
                    }
                }
            }
        }

        global void finish(Database.BatchableContext BC) {
            Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
            email.setToAddresses(notifyEmails);
            email.setSubject('BCH_PopulateMNPIOnBA completed');
            email.setPlainTextBody('BCH_PopulateMNPIOnBA succesfully processed ' + successfulRecs + ' out of ' + allRecs + ' records.');
            Messaging.sendEmail(new Messaging.Email[]{email});
        }
}