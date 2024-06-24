public class UTL_Picklist {

    private static final String NOT_DEPENDENT_PICKLIST = '{0} is not a dependent picklist.';

    public static Map<PicklistEntry, List<PicklistEntry>> getDependentToControllingMap(SObjectField parentPicklistField, SObjectField dependentPicklistField) {
        if (!dependentPicklistField.getDescribe().isDependentPicklist()) {
            throw new UTL_PicklistException(String.format(NOT_DEPENDENT_PICKLIST, new String[]{
                dependentPicklistField.getDescribe().getName()
            }));
        } else {
            return generateDependentPicklistMap(parentPicklistField, dependentPicklistField);
        }
    }

    public static Map<PicklistEntry, List<PicklistEntry>> getControllingToDependentMap(SObjectField parentPicklistField, SObjectField dependentPicklistField) {
        if (!dependentPicklistField.getDescribe().isDependentPicklist()) {
            throw new UTL_PicklistException(String.format(NOT_DEPENDENT_PICKLIST, new String[]{
                dependentPicklistField.getDescribe().getName()
            }));
        } else {
            return generateControllingPicklistMap(parentPicklistField, dependentPicklistField);
        }
    }

	public static Map<String, List<DTO_SelectOption>> getControllingApiToDependentWrapperMap(SObjectField parentPicklistField, SObjectField dependentPicklistField) {
		Map<String, List<DTO_SelectOption>> wrappers = new Map<String, List<DTO_SelectOption>> ();
		Map<PicklistEntry, List<PicklistEntry>> picklistsDep = getControllingToDependentMap(parentPicklistField, dependentPicklistField);
		for (PicklistEntry pe : picklistsDep.keySet()) {
			wrappers.put(pe.getValue(), DTO_SelectOption.convert(picklistsDep.get(pe)));
		}
		return wrappers;
	}

    private static Map<PicklistEntry, List<PicklistEntry>> generateFullMap(SObjectField parentPicklist, SObjectField dependentPicklist) {
        Map<PicklistEntry, List<PicklistEntry>> dependent2parent = new Map<PicklistEntry, List<PicklistEntry>> ();
        for (PicklistEntry dependentEntry : dependentPicklist.getDescribe().getPicklistValues()) {
            dependent2parent.put(dependentEntry, parentPicklist.getDescribe().getPicklistValues());
        }
        return dependent2parent;
    }

    private static Map<PicklistEntry, List<PicklistEntry>> generateControllingPicklistMap(SObjectField parentPicklist, SObjectField dependentPicklist) {
        Map<PicklistEntry, List<PicklistEntry>> parent2Dependent = new Map<PicklistEntry, List<PicklistEntry>> ();
        List<PicklistEntry> parentPicklistValues = parentPicklist.getDescribe().getPicklistValues();
        List<PicklistEntry> dependentPicklistValues = dependentPicklist.getDescribe().getPicklistValues();
        List<PicklistEntryWrapper> wrapped = wrapPicklistEntries(dependentPicklistValues);

        for(PicklistEntry entry : parentPicklistValues){
            parent2Dependent.put(entry,new List<PicklistEntry>());
        }

        for (Integer i = 0; i<dependentPicklistValues.size(); i++) {
            for (Integer j : wrapped[i].getValidForIndexes()) {
                parent2Dependent.get( parentPicklistValues[j] ).add(dependentPicklistValues[i]);
            }
        }
        return parent2Dependent;
    }

    private static Map<PicklistEntry, List<PicklistEntry>> generateDependentPicklistMap(SObjectField parentPicklist, SObjectField dependentPicklist) {
        Map<PicklistEntry, List<PicklistEntry>> dependent2parent = new Map<PicklistEntry, List<PicklistEntry>>();
        List<PicklistEntry> parentPicklistValues = parentPicklist.getDescribe().getPicklistValues();
        List<PicklistEntry> dependentPicklistValues = dependentPicklist.getDescribe().getPicklistValues();
        List<PicklistEntryWrapper> wrapped = wrapPicklistEntries(dependentPicklistValues);

        for (Integer i = 0; i < dependentPicklistValues.size(); i++) {
            List<PicklistEntry> validFor = new List<PicklistEntry>();
            for (Integer j : wrapped[i].getValidForIndexes()) {
                validFor.add(parentPicklistValues[j]);
            }
            dependent2parent.put(dependentPicklistValues[i], validFor);
        }
        return dependent2parent;
    }

    private static List<PicklistEntryWrapper> wrapPicklistEntries(List<Schema.PicklistEntry> picklistEntries) {
        return(List<PicklistEntryWrapper>)
            JSON.deserialize(JSON.serialize(picklistEntries), List<PicklistEntryWrapper>.class);
    }

    public static List<Schema.PicklistEntry> getPicklistValues(SObjectField picklistField) {
        List<Schema.PicklistEntry> pickListEntries = picklistField.getDescribe().getPicklistValues();
        return pickListEntries;
    }


    public class PicklistEntryWrapper {
        public String active { get; set; }
        public String defaultValue { get; set; }
        public String label { get; set; }
        public String value { get; set; }
        public String validFor { get; set; }

        public List<Integer> getValidForIndexes() {
            List<Integer> indexes = new List<Integer> ();
            String parsed = '';
            for (Integer i = 0; i<validFor.length(); i++) {
                parsed += UTL_Encoder.encodeBase64ToByte(validFor.mid(i, 1)).right(6);
            }
            for (Integer i = 0; i<parsed.length(); i++) {
                if (parsed.mid(i, 1) == '1') {
                    indexes.add(i);
                }
            }
            return indexes;
        }
    }

    public class UTL_PicklistException extends Exception { }

}