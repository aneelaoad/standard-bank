/*************************************************************************\
    @ Author        : Nitish Kumar
    @ Date          : August, 2013
    @ Test File     : SyncCCBatchClass_Test
    @ Description   : EN 212 : Batch Class to handle scenarios happening due to Account Merge

****************************************************************************/
global class SyncCCBatchClass implements Schedulable, Database.Batchable < SObject > {

    // Query
    global String strQuery = 'Select ID,OwnerId From Account order by LastModifiedDate desc ';

    global Database.QueryLocator start(Database.BatchableContext ctx) {
        return Database.getQueryLocator(strQuery);
    }

    global void execute(SchedulableContext ctx) {

        //Deleting the old scheduled Jobs 
        List < CronTrigger > oldJobsToClean = [Select Id from CronTrigger where NextFireTime = null and OwnerId = '00520000000lPx5'];
        if (oldJobsToClean.size() > 0) {
            for (CronTrigger cT: oldJobsToClean) {
                System.abortJob(ct.Id);
            }
        }

        Database.executeBatch(new SyncCCBatchClass(), 50); // Start Batch Apex job    
    }


    global void execute(Database.BatchableContext ctx, List < SObject > records) {

        //List/Map to Update the Client Team
        List < Custom_Client_Team__c > cstToUpdate = new List < Custom_Client_Team__c > ();
        Map < Id, Custom_Client_Team__c > cstToDelete = new Map < Id, Custom_Client_Team__c > ();
        map < String, Custom_Client_Team__c > cstToUpdateMap = new map < String, Custom_Client_Team__c > ();

        //Duplicate CC
        map < String, Custom_Client_Team__c > ccNotDuplicateMap = new map < String, Custom_Client_Team__c > ();
        map < String, Custom_Client_Team__c > ccDuplicateMap = new map < String, Custom_Client_Team__c > ();

        //Duplicate Users
        map < String, Custom_Client_Team__c > customClientTeamRecordMap = new map < String, Custom_Client_Team__c > ();
        map < String, Custom_Client_Team__c > customClientDuplicateTeamRecordMap = new map < String, Custom_Client_Team__c > ();

        //Duplicate Core Roles
        map < String, Custom_Client_Team__c > csTCoreRoleMap = new map < String, Custom_Client_Team__c > ();
        map < String, Custom_Client_Team__c > csTDuplicateCoreRoleMap = new map < String, Custom_Client_Team__c > ();

        //Duplicate CC BM
        map < String, Custom_Client_Team__c > ccBMNotDuplicateMap = new map < String, Custom_Client_Team__c > ();
        map < String, Custom_Client_Team__c > ccBMDuplicateMap = new map < String, Custom_Client_Team__c > ();

        //Duplicate CCBM/USER/Core Roles
        Map < String, Custom_Client_Team__c > cstDuplicateToDelete = new Map < String, Custom_Client_Team__c > ();

        //Getting the Salesforce Admin Id
        Environment_Variable__c env = Environment_Variable__c.getInstance();
        Id SalesforceAdminId = env.Salesforce_Administration_Id__c.subString(0, 15);

        List < Id > lstAccId = new List < Id > ();
        Account acc;

        //Getting all the Account Ids
        for (SObject record: records) {
            acc = (Account) record;
            lstAccId.add(acc.Id);
        }

        //Creating a map of all Non Core Roles
        List < CSTManyperRegionTeamRoles__c > manyteamrole = [Select Name from CSTManyperRegionTeamRoles__c];
        Map < String, String > roleMap = new Map < String, String > ();
        for (CSTManyperRegionTeamRoles__c myrole: manyteamrole) {
            roleMap.put(myrole.Name, myrole.Name);
        }

        //Query All the Client Team Records
        List < Custom_Client_Team__c > cstAlllst = [Select Account_Owner__c, AccountUserId__c, Client_Coordinator__c, Client_Coordinator_BM__c, Case_Access__c,
            Account__c, Client_Access__c, Name, Contact_Access__c, Opportunity_Access__c, Id, TeamRoleSortValue__c, User_Division__c,
            Team_Member__c, Client_Role__c, Business_Unit__c FROM Custom_Client_Team__c where Account__c IN: lstAccId order by Client_Coordinator__c desc, CreatedDate desc
        ];


        for (Custom_Client_Team__c Cst: cstAlllst) {

            //Duplicate Core Roles
            if (!roleMap.containsKey(Cst.Client_Role__c)) {
                if (!csTCoreRoleMap.containsKey(String.valueOf(Cst.Account__c).substring(0, 15) + '#' + Cst.Client_Role__c)) {
                    csTCoreRoleMap.put(String.valueOf(Cst.Account__c).substring(0, 15) + '#' + Cst.Client_Role__c, Cst);
                } else {
                    csTDuplicateCoreRoleMap.put(String.valueOf(Cst.Account__c).substring(0, 15) + '#' + Cst.Client_Role__c, Cst);
                    cstDuplicateToDelete.put(String.ValueOf(Cst.id).SubString(0, 15), Cst);
                }
            }
            // Duplicate Users 
            if (!customClientTeamRecordMap.containsKey(Cst.AccountUserId__c)) {
                customClientTeamRecordMap.put((String.valueOf(Cst.Account__c)).substring(0, 15) + '#' + (String.valueOf(Cst.Team_Member__c)).substring(0, 15), Cst);
            } else {
                customClientDuplicateTeamRecordMap.put((String.valueOf(Cst.Account__c)).substring(0, 15) + '#' + (String.valueOf(Cst.Team_Member__c)).substring(0, 15), Cst);
                cstDuplicateToDelete.put(String.ValueOf(Cst.id).SubString(0, 15), Cst);
            }
            // Duplicate CC 
            if (Cst.Client_Coordinator__c == true) {
                if (!ccNotDuplicateMap.containsKey(String.ValueOf(Cst.Account__c).Substring(0, 15))) {
                    ccNotDuplicateMap.put(String.ValueOf(Cst.Account__c).subString(0, 15), Cst);
                } else {
                    ccDuplicateMap.put(String.ValueOf(Cst.Account__c).subString(0, 15), Cst);
                }
            }

            // Duplicate CC BM
            if (Cst.Client_Coordinator_BM__c == true) {
                if (!ccBMNotDuplicateMap.containsKey(String.valueOf(Cst.Account__c).SubString(0, 15))) {
                    ccBMNotDuplicateMap.put(String.ValueOf(Cst.Account__c).subString(0, 15), Cst);
                } else {
                    ccBMDuplicateMap.put(String.ValueOf(Cst.Account__c).subString(0, 15), Cst);
                    cstDuplicateToDelete.put(String.ValueOf(Cst.id).SubString(0, 15), Cst);
                }
            }
        }

        // Querying all the account records
        list < Account > lstAccount = [Select Id, OwnerId from Account where Id In: lstAccId order by LastModifiedDate desc];

        for (Account acct: lstAccount) {

            //Checking if the Owner is Salesforce Adminstration
            if (String.ValueOf(acct.OwnerId).Substring(0, 15) != SalesforceAdminId) {

                //CC Check
                if (ccNotDuplicateMap.containsKey(String.ValueOf(acct.Id).SubString(0, 15)) && ccDuplicateMap.containsKey(String.valueOf(acct.Id).SubString(0, 15))) {
                    if (String.ValueOf(ccNotDuplicateMap.get(String.ValueOf(acct.Id).Substring(0, 15)).Team_Member__c).subString(0, 15) == String.ValueOf(acct.OwnerId).subString(0, 15) && String.ValueOf(ccDuplicateMap.get(String.ValueOf(acct.Id).Substring(0, 15)).Team_Member__c).subString(0, 15) != String.ValueOf(acct.OwnerId).subString(0, 15)) {
                        cstToDelete.Put(ccDuplicateMap.get(String.ValueOf(acct.Id).SubString(0, 15)).Id, ccDuplicateMap.get(String.ValueOf(acct.Id).SubString(0, 15)));
                        cstToUpdate.add(ccNotDuplicateMap.get(String.ValueOf(acct.Id).SubString(0, 15)));
                        cstToUpdateMap.put(String.ValueOf(acct.Id).SubString(0, 15), ccNotDuplicateMap.get(String.ValueOf(acct.Id).SubString(0, 15)));
                    } else {
                        if (String.ValueOf((ccDuplicateMap.get(String.ValueOf(acct.Id).Substring(0, 15))).Team_Member__c).subString(0, 15) == String.ValueOf(acct.OwnerId).subString(0, 15) && String.ValueOf(ccNotDuplicateMap.get(String.ValueOf(acct.Id).Substring(0, 15)).Team_Member__c).subString(0, 15) != String.ValueOf(acct.OwnerId).subString(0, 15)) {
                            cstToDelete.put(ccNotDuplicateMap.get(String.ValueOf(acct.Id).SubString(0, 15)).Id, ccNotDuplicateMap.get(String.ValueOf(acct.Id).SubString(0, 15)));
                            cstToUpdate.add(ccDuplicateMap.get(String.ValueOf(acct.Id).SubString(0, 15)));
                            cstToUpdateMap.put(String.ValueOf(acct.Id).subString(0, 15), ccDuplicateMap.get(String.ValueOf(acct.Id).SubString(0, 15)));
                        } else {
                            if (String.ValueOf((ccDuplicateMap.get(String.ValueOf(acct.Id).Substring(0, 15))).Team_Member__c).subString(0, 15) == String.ValueOf(acct.OwnerId).subString(0, 15) && String.ValueOf(ccNotDuplicateMap.get(String.ValueOf(acct.Id).Substring(0, 15)).Team_Member__c).subString(0, 15) == String.ValueOf(acct.OwnerId).subString(0, 15)) {
                                System.debug('I AM HERE');
                                cstToDelete.Put(ccDuplicateMap.get(String.ValueOf(acct.Id).SubString(0, 15)).Id, ccDuplicateMap.get(String.ValueOf(acct.Id).SubString(0, 15)));
                                cstToUpdate.add(ccNotDuplicateMap.get(String.ValueOf(acct.Id).SubString(0, 15)));
                                cstToUpdateMap.put(String.ValueOf(acct.Id).SubString(0, 15), ccNotDuplicateMap.get(String.ValueOf(acct.Id).SubString(0, 15)));
                            }
                        }
                    }
                }
            }

            //Remove all the CC records from CST if the owner is Salesforce Adminstration
            else {
                if (ccDuplicateMap.containsKey(String.ValueOf(acct.Id).Substring(0, 15))) {
                    cstToDelete.put(ccDuplicateMap.get(String.ValueOf(acct.Id).SubString(0, 15)).Id, ccDuplicateMap.get(String.ValueOf(acct.Id).SubString(0, 15)));
                    cstDuplicateToDelete.Put(ccDuplicateMap.get(String.ValueOf(acct.Id).SubString(0, 15)).Id, ccDuplicateMap.get(String.ValueOf(acct.Id).SubString(0, 15)));
                    cstToUpdateMap.put(String.ValueOf(acct.Id).subString(0, 15), ccNotDuplicateMap.get(String.ValueOf(acct.Id).SubString(0, 15)));
                } else {
                    if (ccNotDuplicateMap.containsKey(String.ValueOf(acct.Id).Substring(0, 15))) {
                        cstToDelete.put(ccNotDuplicateMap.get(String.ValueOf(acct.Id).SubString(0, 15)).Id, ccNotDuplicateMap.get(String.ValueOf(acct.Id).SubString(0, 15)));
                        cstDuplicateToDelete.Put(ccNotDuplicateMap.get(String.ValueOf(acct.Id).SubString(0, 15)).Id, ccNotDuplicateMap.get(String.ValueOf(acct.Id).SubString(0, 15)));
                        cstToUpdateMap.put(String.ValueOf(acct.Id).subString(0, 15), ccDuplicateMap.get(String.ValueOf(acct.Id).SubString(0, 15)));
                    }
                }
            }

            If(cstToUpdateMap.values().size() > 0) {
                If(cstToUpdateMap.ContainsKey(String.ValueOf(acct.Id).SubString(0, 15))) {

                    // Duplicate CC BM
                    if (ccBMDuplicateMap.Values().Size() > 0) {
                        If(ccBMNotDuplicateMap.ContainsKey(String.valueOf(acct.Id).substring(0, 15)) && ccBMDuplicateMap.ContainsKey(String.valueOf(acct.Id).substring(0, 15))) {
                            if (String.ValueOf(cstToUpdateMap.get(String.ValueOf(acct.Id).SubString(0, 15)).Id).SubString(0, 15) != String.ValueOf(ccBMNotDuplicateMap.get(String.valueOf(acct.Id).Substring(0, 15)).Id).SubString(0, 15) && String.ValueOf(cstToUpdateMap.get(String.ValueOf(acct.Id).SubString(0, 15)).Id).SubString(0, 15) == String.ValueOf(ccBMDuplicateMap.get(String.valueOf(acct.Id).Substring(0, 15)).Id).SubString(0, 15))
                                cstToDelete.Put(ccBMNotDuplicateMap.get(String.ValueOf(acct.Id).SubString(0, 15)).Id, ccBMNotDuplicateMap.get(String.ValueOf(acct.Id).SubString(0, 15)));
                            else
                            if (String.ValueOf(cstToUpdateMap.get(String.ValueOf(acct.Id).SubString(0, 15)).Id).SubString(0, 15) != String.ValueOf(ccBMDuplicateMap.get(String.valueOf(acct.Id).Substring(0, 15)).Id).Substring(0, 15) && String.ValueOf(cstToUpdateMap.get(String.ValueOf(acct.Id).SubString(0, 15)).Id).SubString(0, 15) == String.ValueOf(ccBMNotDuplicateMap.get(String.valueOf(acct.Id).Substring(0, 15)).Id).SubString(0, 15))
                                cstToDelete.put(ccBMDuplicateMap.get(String.ValueOf(acct.Id).SubString(0, 15)).Id, ccBMDuplicateMap.get(String.ValueOf(acct.Id).SubString(0, 15)));
                        }

                        If(ccBMNotDuplicateMap.ContainsKey(String.valueOf(acct.Id).substring(0, 15)) && ccBMDuplicateMap.ContainsKey(String.valueOf(acct.Id).substring(0, 15)) &&
                            String.ValueOf(cstToUpdateMap.get(String.ValueOf(acct.Id).SubString(0, 15)).Id).SubString(0, 15) != String.ValueOf(ccBMNotDuplicateMap.get(String.valueOf(acct.Id).Substring(0, 15)).Id).SubString(0, 15) && String.ValueOf(cstToUpdateMap.get(String.ValueOf(acct.Id).SubString(0, 15)).Id).SubString(0, 15) != String.ValueOf(ccBMDuplicateMap.get(String.valueOf(acct.Id).Substring(0, 15)).Id).Substring(0, 15)) {
                            cstToDelete.put(ccBMDuplicateMap.get(String.ValueOf(acct.Id).SubString(0, 15)).Id, ccBMDuplicateMap.get(String.ValueOf(acct.Id).SubString(0, 15)));
                        }
                    }


                    //Core Role Check   
                    if (csTDuplicateCoreRoleMap.Values().Size() > 0) {
                        if (csTCoreRoleMap.ContainsKey(String.Valueof(acct.Id).SubString(0, 15) + '#' + cstToUpdateMap.get(String.ValueOf(acct.Id).SubString(0, 15)).Client_Role__c) &&
                            csTDuplicateCoreRoleMap.ContainsKey(String.Valueof(acct.Id).substring(0, 15) + '#' + cstToUpdateMap.get(String.ValueOf(acct.Id).SubString(0, 15)).Client_Role__c)) {
                            if (String.ValueOf(cstToUpdateMap.get(String.ValueOf(acct.Id).SubString(0, 15)).AccountUserId__c).SubString(0, 15) == String.ValueOf(csTCoreRoleMap.get(String.Valueof(String.ValueOf(acct.Id).SubString(0, 15)).substring(0, 15) + '#' + cstToUpdateMap.get(String.ValueOf(acct.Id).SubString(0, 15)).Client_Role__c).AccountUserId__c).SubString(0, 15)) {
                                cstToDelete.put(csTCoreRoleMap.get(String.Valueof(acct.Id).substring(0, 15) + '#' + cstToUpdateMap.get(String.ValueOf(acct.Id).SubString(0, 15)).Client_Role__c).Id, csTCoreRoleMap.get(String.Valueof(acct.Id).substring(0, 15) + '#' + cstToUpdateMap.get(String.ValueOf(acct.Id).SubString(0, 15)).Client_Role__c));
                            } else
                            if (String.ValueOf(cstToUpdateMap.get(String.ValueOf(acct.Id).SubString(0, 15)).AccountUserId__c).SubString(0, 15) == String.ValueOf(csTDuplicateCoreRoleMap.get(String.Valueof(String.ValueOf(acct.Id).SubString(0, 15)).substring(0, 15) + '#' + cstToUpdateMap.get(String.ValueOf(acct.Id).SubString(0, 15)).Client_Role__c).AccountUserId__c).SubString(0, 15)) {
                                cstToDelete.put(csTDuplicateCoreRoleMap.get(String.Valueof(acct.Id).substring(0, 15) + '#' + cstToUpdateMap.get(String.ValueOf(acct.Id).SUbString(0, 15)).Client_Role__c).Id, csTDuplicateCoreRoleMap.get(String.Valueof(acct.Id).substring(0, 15) + '#' + cstToUpdateMap.get(String.ValueOf(acct.Id).SUbString(0, 15)).Client_Role__c));
                            }
                        }

                        if (csTCoreRoleMap.ContainsKey(String.Valueof(acct.Id).substring(0, 15) + '#' + cstToUpdateMap.get(String.ValueOf(acct.Id).SubString(0, 15)).Client_Role__c) &&
                            csTDuplicateCoreRoleMap.ContainsKey(String.Valueof(acct.Id).substring(0, 15) + '#' + cstToUpdateMap.get(String.ValueOf(acct.Id).SubString(0, 15)).Client_Role__c) &&
                            String.ValueOf(cstToUpdateMap.get(String.ValueOf(acct.Id).SubString(0, 15)).AccountUserId__c).SubString(0, 15) != String.ValueOf(csTCoreRoleMap.get(String.Valueof(String.ValueOf(acct.Id).SubString(0, 15)).substring(0, 15) + '#' + cstToUpdateMap.get(String.ValueOf(acct.Id).SubString(0, 15)).Client_Role__c).AccountUserId__c).SubString(0, 15) &&
                            String.ValueOf(cstToUpdateMap.get(String.ValueOf(acct.Id).SubString(0, 15)).AccountUserId__c).SubString(0, 15) != String.ValueOf(csTDuplicateCoreRoleMap.get(String.Valueof(String.ValueOf(acct.Id).SubString(0, 15)).substring(0, 15) + '#' + cstToUpdateMap.get(String.ValueOf(acct.Id).SubString(0, 15)).Client_Role__c).AccountUserId__c).SubString(0, 15)) {
                            cstToDelete.Put(csTCoreRoleMap.get(String.Valueof(acct.Id).substring(0, 15) + '#' + cstToUpdateMap.get(String.ValueOf(acct.Id).SUbString(0, 15)).Client_Role__c).Id, csTCoreRoleMap.get(String.Valueof(acct.Id).substring(0, 15) + '#' + cstToUpdateMap.get(String.ValueOf(acct.Id).SUbString(0, 15)).Client_Role__c));
                        }
                    }

                    //Duplicate Users Check
                    if (customClientDuplicateTeamRecordMap.Values().Size() > 0) {
                        if (customClientTeamRecordMap.ContainsKey(cstToUpdateMap.get(String.ValueOf(acct.Id).SubString(0, 15)).AccountUserId__c) && customClientDuplicateTeamRecordMap.ContainsKey(cstToUpdateMap.get(String.ValueOf(acct.Id).SubString(0, 15)).AccountUserId__c)) {
                            if (cstToUpdateMap.get(String.ValueOf(acct.Id).SubString(0, 15)).AccountUserId__c == customClientTeamRecordMap.get(cstToUpdateMap.get(String.ValueOf(acct.Id).SubString(0, 15)).AccountUserId__c).AccountUserId__c)
                                cstToDelete.put(customClientTeamRecordMap.get(cstToUpdateMap.get(String.ValueOf(acct.Id).SubString(0, 15)).AccountUserId__c).Id, customClientTeamRecordMap.get(cstToUpdateMap.get(String.ValueOf(acct.Id).SubString(0, 15)).AccountUserId__c));
                            else
                            if (cstToUpdateMap.get(String.ValueOf(acct.Id).SubString(0, 15)).AccountUserId__c == customClientDuplicateTeamRecordMap.get(cstToUpdateMap.get(String.ValueOf(acct.Id).SubString(0, 15)).AccountUserId__c).AccountUserId__c)
                                cstToDelete.put(customClientDuplicateTeamRecordMap.get(cstToUpdateMap.get(String.ValueOf(acct.Id).SubString(0, 15)).AccountUserId__c).Id, customClientDuplicateTeamRecordMap.get(cstToUpdateMap.get(String.ValueOf(acct.Id).SubString(0, 15)).AccountUserId__c));
                        }

                        if (customClientTeamRecordMap.ContainsKey(cstToUpdateMap.get(String.ValueOf(acct.Id).SubString(0, 15)).AccountUserId__c) && customClientDuplicateTeamRecordMap.ContainsKey(cstToUpdateMap.get(String.ValueOf(acct.Id).SubString(0, 15)).AccountUserId__c) && cstToUpdateMap.get(String.ValueOf(acct.Id).SubString(0, 15)).AccountUserId__c != customClientTeamRecordMap.get(cstToUpdateMap.get(String.ValueOf(acct.Id).SubString(0, 15)).AccountUserId__c).AccountUserId__c &&
                            cstToUpdateMap.get(String.ValueOf(acct.Id).SubString(0, 15)).AccountUserId__c != customClientDuplicateTeamRecordMap.get(cstToUpdateMap.get(String.ValueOf(acct.Id).SubString(0, 15)).AccountUserId__c).AccountUserId__c) {
                            cstToDelete.put(customClientTeamRecordMap.get(cstToUpdateMap.get(String.ValueOf(acct.Id).SubString(0, 15)).AccountUserId__c).Id, customClientTeamRecordMap.get(cstToUpdateMap.get(String.ValueOf(acct.Id).SubString(0, 15)).AccountUserId__c));
                        }
                    }


                }

            }
        }

        cstToDelete.putAll(cstDuplicateToDelete.values());

        /*If(cstDuplicateToDelete.values().size()>0) {
            Delete cstDuplicateToDelete.values();
        }*/

        if (cstToDelete.values().size() > 0)
            Delete cstToDelete.values();

        if (cstToUpdate.Size() > 0)
            Update cstToUpdate;

    }

    global void finish(Database.BatchableContext BC) {

        AsyncApexJob a = [Select Id, Status, NumberOfErrors, JobItemsProcessed, TotalJobItems, CreatedBy.Email from AsyncApexJob where Id = : BC.getJobId()];
        // Send an email to the Apex job's submitter notifying of job completion.
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        Environment_Variable__c env = Environment_Variable__c.getInstance();
        String onErrorEmail = env.BatchErrorEmails__c;
        String[] toAddresses = new String[] {
            onErrorEmail
        };
        mail.setToAddresses(toAddresses);
        mail.setSubject('Client Team Batch>> SyncCCBatchClass ' + a.Status);
        mail.setPlainTextBody('The batch Apex job processed ' + a.TotalJobItems +
            ' batches with ' + a.NumberOfErrors + ' failures.');
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { 
            mail
        });


        //Build the system time of now + 30 seconds to schedule the batch apex.
        Datetime sysTime = System.now();
        sysTime = sysTime.addSeconds(30);
        String chron_exp = '' + sysTime.second() + ' ' + sysTime.minute() + ' ' + sysTime.hour() + ' ' + sysTime.day() + ' ' + sysTime.month() + ' ? ' + sysTime.year();
        system.debug(chron_exp);

        //Schedule the next job, and give it the system time so name is unique
        System.schedule('Runs SyncCustClientTeamforDelete' + System.Today(), chron_exp, new SyncCustClientTeamforDelete());


    }

}