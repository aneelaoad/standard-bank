/**
 * @description SFP-3882 Added syncDrawdownDatesToOppEstClosedDate to update draw down dates n relaton to the opp est closed date.
 * @author Wayne Solomon
 * @date Feb 2021
 */
@SuppressWarnings('PMD.CyclomaticComplexity,PMD.StdCyclomaticComplexity')
public class DMN_DrawDownProfile {
    public static final String FREQUENCIES_PICKLIST_CATEGORY = 'Frequency in months';

    /**
     * SGPRT-4189Keep opportunity product drawdowns in sync with changes to opportunity estimated closed date
     * @param id2NewRecords map of Trigger.new
     * @param id2OldRecords map of Trigger.old
     */
    public static void syncDrawdownDatesToOppEstClosedDate(Map<Id, Opportunity> id2NewRecords, Map<Id, Opportunity> id2OldRecords) {
        Map<Id, Draw_Down_Profile__c> oppProdDrawdownsMap = new Map<Id, Draw_Down_Profile__c>(
                SEL_DrawdownProfiles.newInstance().selectByIdsAndParentProduct(id2NewRecords.keySet())
        );
        List<Draw_Down_Profile__c> updDrawDownProfiles = new List<Draw_Down_Profile__c>();
        for (Opportunity opp : id2NewRecords.values()) {
            Date newDate = id2NewRecords.get(opp.Id).CloseDate;
            Date oldDate = id2OldRecords.get(opp.Id).CloseDate;
            Boolean closeDateChanged = newDate != oldDate;
            if (closeDateChanged) {
                for (Draw_Down_Profile__c d : oppProdDrawdownsMap.values()) {
                    Date firstDrawDate = d.Product__r.Earliest_Draw_Date_Rollup__c;
                    Boolean validDateMove = newDate > firstDrawDate;
                    if (validDateMove) {
                        Integer difference = firstDrawDate.daysBetween(newDate);
                        Date drawDate = d.Draw_Date__c;
                        updDrawDownProfiles.add(new Draw_Down_Profile__c(
                                Id = d.Id,
                                Draw_Date__c = (drawDate == firstDrawDate) ? newDate : drawDate.addDays(difference)));
                    }
                }
            }
        }
        if (!updDrawDownProfiles.isEmpty()) {
            fflib_ISObjectUnitOfWork uow = ORG_Application.unitOfWork.newInstance();
            uow.registerDirty(updDrawDownProfiles);
            uow.commitWork();
        }
    }
}