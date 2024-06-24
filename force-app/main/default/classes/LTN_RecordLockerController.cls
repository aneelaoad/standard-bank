/**
 * Created by joracki on 12.06.2019.
 *
 *  @description : created to workaround issue introduced in summer19 release, lightning dataService caused page to refresh upon record save. To be reviewed and deleted when dataService issue is fixed
 */

public with sharing class LTN_RecordLockerController {

    @AuraEnabled
    public static void saveRecord(SObject record) {
        if(record != null && record.Id != null){
            try{
                update record;
            }catch(DmlException ex){
                throw new AuraHandledException(ex.getMessage());
            }
        }
    }
}