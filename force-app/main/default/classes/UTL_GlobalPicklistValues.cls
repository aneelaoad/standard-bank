public without sharing class UTL_GlobalPicklistValues {

    private static Map<String, SelectOption[]> category2SelectOptions;

    public static SelectOption[] getPicklist(String category) {
        collectPicklists();

        if (!category2SelectOptions.containsKey(category)) {
            throw new UTL_GlobalPicklistValuesException(
                String.format(
                    'There is no category {0} in Global Picklist Values Custom Metadata',
                    new String[]{category}
                ));
        }

        return category2SelectOptions.get(category);
    }

    private static void collectPicklists() {
        if (category2SelectOptions == null) {
            category2SelectOptions = new Map<String, SelectOption[]>();
            for (Global_Picklist_Value__mdt pv : [
                SELECT Category__c,
                    Picklist_Label__c,
                    Picklist_Value__c,
                    Order__c
                FROM Global_Picklist_Value__mdt
                ORDER BY Order__c
            ]) {
                if (!category2SelectOptions.containsKey(pv.Category__c)) {
                    category2SelectOptions.put(pv.Category__c, new SelectOption[]{});
                }
                category2SelectOptions.get(pv.Category__c)
                    .add(new SelectOption(pv.Picklist_Value__c, pv.Picklist_Label__c));
            }
        }
    }

    public class UTL_GlobalPicklistValuesException extends Exception {}
}