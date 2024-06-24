/**
 * Created by tsobota on 06.12.2018.
 */

public without sharing class SHR_CallReport extends ABS_Sharing {
    //private static List<Id> userOrGroupIds = new List<Id>();
    public SHR_CallReport() {
        sharingType = Call_Report__Share.SobjectType;
    }

    public override Map<Id, Sobject[]> fetchRecords(Set<Id> parentIds) {
        Map<Id, Call_Report__c[]> parentId2ChildCallReport = new Map<Id, Call_Report__c[]>();
        for (Call_Report__c callReport : [
                SELECT OwnerId
                FROM Call_Report__c
                WHERE Id IN :parentIds
        ]) {
            if (!parentId2ChildCallReport.containsKey(callReport.Id)) {
                parentId2ChildCallReport.put(callReport.Id, new Call_Report__c[]{
                });
            }
            parentId2ChildCallReport.get(callReport.Id).add(callReport);
        }
        return parentId2ChildCallReport;
    }

    protected override SObject[] createShares(User[] users, Sobject[] records, Sobject[] team) {
        List<Call_Report_Attendees__c> callReportAttendees = (List<Call_Report_Attendees__c>) team;
        List<Call_Report__Share> shares = new List<Call_Report__Share>();
        List<Call_Report__c> callReports = (List<Call_Report__c>) records;



        for (Call_Report__c callReport : callReports) {
            for (Call_Report_Attendees__c callReportAttendee : callReportAttendees) {
                if (callReportAttendee.Contact_Type__c != 'External') {
                    shares.addAll(DMN_CallReport.shareCallReports(new Set<Id>{
                            callReport.Id
                    },
                            new Set<Id>{
                                    callReportAttendee.Contact_id__r.OwnerId
                            }, 'Call_Event_Attendee__c', DMN_CallReport.ACCESS_LEVEL_READ_WRITE));
                }
            }
        }
        return shares;
    }

    protected override SObject[] deleteShares(User[] users, Sobject[] records, Sobject[] team) {

        Call_Report_Attendees__c[] callReportAttendees = (Call_Report_Attendees__c[]) team;
        Call_Report__c[] callReports = (Call_Report__c[]) records;
        Map<Id, Call_Report__c> id2CallReports = new Map<Id, Call_Report__c>(callReports);
        Set<Id> attendeeUserIds = new Set<Id>();
        for(Call_Report_Attendees__c cra : callReportAttendees) {
            attendeeUserIds.add(cra.Contact_Owner_Id__c);
        }
        List<Call_Report__Share> callReportShares =
        [SELECT
                RowCause,
                ParentId,
                UserOrGroupId
        FROM Call_Report__Share
        WHERE
            ParentId IN :id2CallReports.keySet()
        AND
            UserOrGroupId IN :attendeeUserIds
        AND
            RowCause = 'Call_Event_Attendee__c'
        ];
        return callReportShares;
    }

    public static void manageSharing(Call_Report__c[] newCallReports, Map<Id, Call_Report__c> id2OldCallReports) {
        List <Id> confidentialCallReportIds = new List<Id>();
        Map <String, List<Id>> field2CallReportIds = new Map<String, List<Id>>();
        fflib_SObjectUnitOfWork uow = new fflib_SObjectUnitOfWork(new List<Schema.SObjectType>{
                Call_Report__Share.SObjectType
        });

        if (newCallReports != null && id2OldCallReports == null) {
            for (Call_Report__c cr : newCallReports) {
                if (!cr.Visible_to_Internal_Attendees_only__c) {
                    for (String objectField : DMN_CallReport.relateField2SobjectType.keySet()) {
                        if (cr.get(objectField) != null) {
                            if (!field2CallReportIds.containsKey(objectField)) {
                                field2CallReportIds.put(objectField, new List<Id>());
                            }
                            field2CallReportIds.get(objectField).add(cr.Id);

                        }
                    }
                }
            }
        }

        if (newCallReports != null && id2OldCallReports != null) {
            for (Call_Report__c cr : newCallReports) {
                if (cr.Visible_to_Internal_Attendees_only__c != id2OldCallReports.get(cr.Id).Visible_to_Internal_Attendees_only__c) {
                    if (cr.Visible_to_Internal_Attendees_only__c) {
                        confidentialCallReportIds.add(cr.Id);
                    } else {
                        for (String objectField : DMN_CallReport.relateField2SobjectType.keySet()) {
                            if (cr.get(objectField) != null) {
                                if (!field2CallReportIds.containsKey(objectField)) {
                                    field2CallReportIds.put(objectField, new List<Id>());
                                }
                                field2CallReportIds.get(objectField).add(cr.Id);

                            }
                        }
                    }
                }
            }
            if (confidentialCallReportIds.size() > 0) {
                deleteParentShares(confidentialCallReportIds, uow);
            }
        }

        Map<String, List<SObject>> operationType2Shares = new Map<String, List<SObject>>{'new' => new List<SObject>(),'delete' => new List<SObject>()};
        for (String objectField : field2CallReportIds.keySet()) {
            copySharesFromParent(field2CallReportIds.get(objectField), objectField, operationType2Shares);
        }
        if (operationType2Shares.get('delete').size() > 0) {
            uow.registerDeleted(operationType2Shares.get('delete'));
        }
        uow.commitWork();
        if(operationType2Shares.get('new').size() > 0) {
            List<SObject> newShares = operationType2Shares.get('new');
            Map<Id,User> inactiveUsers = new Map<Id,User>([SELECT Id FROM User WHERE IsActive = false]);
            for(SObject newShare : newShares) {
                Id userOrGroupId = (Id) newShare.get('UserOrGroupId');
                if(!inactiveUsers.containsKey(userOrGroupId)) {
                    uow.registerNew(newShare);
                }
            }
           /* Map<Id,User> activeUsers = new Map<Id,User>([SELECT Id FROM User WHERE Id IN :userIds AND IsActive = true]);
            for(Id userId : activeUsers.keySet()) {
                uow.registerNew(userId2NewShares.get(userId));
            }*/
        }

        uow.commitWork();

    }

    public static void copySharesFromParent (List<Id> sObjectIds, String objectFieldName, Map<String, List<SObject>> operationType2Shares) {
        String callReportFieldsToQuery = String.valueOf(DMN_CallReport.relateField2SobjectType.keySet());
        String objectTypeName = DMN_CallReport.relateField2SobjectType.get(objectFieldName).getDescribe().getName();
        callReportFieldsToQuery = callReportFieldsToQuery.remove('{').remove('}');
        String query = 'SELECT ' + callReportFieldsToQuery + ' , (SELECT UserOrGroupId FROM Shares WHERE RowCause = \'Parent_Sharing__c\' and UserOrGroupId NOT IN (SELECT Id FROM User WHERE isActive = false)) FROM Call_Report__c WHERE Id IN :sObjectIds';
        List<SObject> sObjectsWithShares = Database.query(query);
        List<Id> idsToQuery = new List<Id>();
        for (SObject sobj : sObjectsWithShares) {
            idsToQuery.add((Id)sobj.get(objectFieldName));
        }
        String accessLevelShareFieldName = objectTypeName.endsWithIgnoreCase('__c') ? '' : objectTypeName;
        accessLevelShareFieldName += 'AccessLevel';
        List<SObject> parentObjects = Database.query('SELECT (SELECT ' +
                (objectTypeName.endsWithIgnoreCase('__c') ? 'Parent' : objectTypeName) +
                'Id, UserOrGroupId, RowCause, ' + accessLevelShareFieldName + ' FROM Shares ORDER BY ' +accessLevelShareFieldName + ' DESC) FROM ' + objectTypeName +
                ' WHERE Id IN :idsToQuery');
        Map<Id, SObject> id2ParentRecord = new Map<Id, SObject>(parentObjects);

        for (SObject callReport : sObjectsWithShares) {
            copySharesFromParent(id2ParentRecord.get((Id) callReport.get(objectFieldName)), callReport, 'Parent_Sharing__c', operationType2Shares);
        }
    }

    public static void copySharesFromParent (SObject parentObjectWithShares, SObject targetObjectWithShares, String sharingReason, Map<String, List<SObject>> operationType2Shares) {
        List<SObject> parentShares = new List<SObject>();
        for(SObject share : parentObjectWithShares.getSObjects('Shares')) {
            parentShares.add(share);
        }
        List<SObject> targetShares = new List<SObject>();
        for(SObject share : targetObjectWithShares.getSObjects('Shares')) {
            targetShares.add(share);
        }
        String parentShareAccessLevelFieldName = parentObjectWithShares.getSObjectType().getDescribe().isCustom() ? '' : parentObjectWithShares.getSObjectType().getDescribe().getName();
        parentShareAccessLevelFieldName += 'AccessLevel';
        String targetShareAccessLevelFieldName = targetObjectWithShares.getSObjectType().getDescribe().isCustom() ? '' : targetObjectWithShares.getSObjectType().getDescribe().getName();
        targetShareAccessLevelFieldName += 'AccessLevel';

        //Map<String, SObject> userId2ShareToDelete = new Map<String, SObject>();
        Set<Id> usersProcessed = new Set<Id>();
        Map<String,SObject> targetUserAccess2Share = new Map<String,SObject>();
        List<SObject> sharesToDelete = operationType2Shares.get('delete');
        List<SObject> sharesToCreate = operationType2Shares.get('new');

        for (SObject targetShare : targetShares) {
            Id userId = (Id) targetShare.get('UserOrGroupId');

            String userAccessKey = String.valueOf(userId) + String.valueOf(targetShare.get(targetShareAccessLevelFieldName));
            targetUserAccess2Share.put(userAccessKey, targetShare);
        }

        String shareObjectName = targetObjectWithShares.getSObjectType().getDescribe().getName();
        String shareParentIdName;
        if (shareObjectName.endsWithIgnoreCase('__c')) {
            shareObjectName = shareObjectName.removeEndIgnoreCase('__c');
            shareObjectName += '__Share';
            shareParentIdName = 'ParentId';
        } else {
            shareParentIdName = shareObjectName + 'Id';
            shareObjectName += 'Share';
        }
        Type t = Type.forName(shareObjectName);

        String objectTypeName = parentObjectWithShares.getSObjectType().getDescribe().getName();
        String accessLevelShareFieldName = objectTypeName.endsWithIgnoreCase('__c') ? '' : objectTypeName;
        accessLevelShareFieldName += 'AccessLevel';
        for (SObject parentShare : parentShares) {

            //SObject parentShare = shareId2Share.get(parentShareId);
            Id parentShareUserId = (Id) parentShare.get('UserOrGroupId');

            if(usersProcessed.contains(parentShareUserId)){
                continue;
            }else{
                usersProcessed.add(parentShareUserId);
            }

            String parentShareAccessLevel = (String) parentShare.get(parentShareAccessLevelFieldName);
            parentShareAccessLevel = parentShareAccessLevel.equals(DMN_CallReport.ACCESS_LEVEL_OWNER) ? DMN_CallReport.ACCESS_LEVEL_READ_WRITE : parentShareAccessLevel;
            String userAccessKey = String.valueOf(parentShareUserId) + parentShareAccessLevel;

            if(targetUserAccess2Share.containsKey(userAccessKey)){
                targetUserAccess2Share.remove(userAccessKey);
            }else{
                SObject newShare = (SObject) t.newInstance();
                newShare.put(shareParentIdName, targetObjectWithShares.Id);
                //Id userId = (Id) shareId2Share.get(parentShareId).get('UserOrGroupId');
                //userOrGroupIds.add(parentShareUserId);
                newShare.put('UserOrGroupId', parentShareUserId);
                newShare.put('RowCause', sharingReason);
                //newShare.put('AccessLevel', DMN_CallReport.ACCESS_LEVEL_OWNER.equals(shareId2Share.get(parentShareId).get(accessLevelShareFieldName)) ? DMN_CallReport.ACCESS_LEVEL_READ_WRITE : shareId2Share.get(parentShareId).get(accessLevelShareFieldName));
                newShare.put('AccessLevel', parentShareAccessLevel);
                sharesToCreate.add(newShare);

            }



        }

        sharesToDelete.addAll(targetUserAccess2Share.values());
    }

    public static void manageSharing(Call_Report_Attendees__c[] newCallReportAttendees, Map<Id, Call_Report_Attendees__c> id2OldCallReportAttendees) {
        SRV_CallReportSharing shr = new SRV_CallReportSharing();

        if (newCallReportAttendees != null && id2OldCallReportAttendees == null) {
            for (Call_Report_Attendees__c cra : newCallReportAttendees) {
                shr.share(cra.Call_Report__c, cra);
            }
        }
        if (newCallReportAttendees == null && id2OldCallReportAttendees != null) {
            for (Call_Report_Attendees__c cra : id2OldCallReportAttendees.values()) {

                shr.remove(cra.Call_Report__c, cra);
            }
        }
        shr.run();
    }

    private static void deleteParentShares (List<Id> callReportIds, fflib_SObjectUnitOfWork uow) {

        List <Call_Report__c> callReportsWithShares = [SELECT (SELECT id FROM Shares WHERE RowCause = 'Parent_Sharing__c') FROM Call_Report__c WHERE Id IN :callReportIds]; //select by share
        List <SObject> callReportSharesToDelete = new List<SObject>();
        for (Call_Report__c cr : callReportsWithShares) {
            for (SObject share : cr.getSObjects('Shares')) {
                callReportSharesToDelete.add(share);
            }
        }
        uow.registerDeleted(callReportSharesToDelete);
    }


}