/**
 * Domain class for List Option Item object.
 *
 * @author Joanna Milosz (jmilosz@deloittece.com)
 * @date April 2021
 */
public with sharing class DMN_Option_List_Item {
    /**
	* Method updates Legal Entity of Booking field on Option List Item.
	* <br/>SGPRT-3817
	*
	* @param profitCentres List of updated Option List Item records.
	*/
    public static void populateLegalEntityOfBooking(Option_List_Item__c[] profitCentres) {
        Map<Integer, Set<String>> profitCentreMappings = new Map<Integer, Set<String>>();
        List<ProfitCentreMatrix__c> profitCentre = ProfitCentreMatrix__c.getall().values();
        for (ProfitCentreMatrix__c opi : profitCentre) {
            if (!profitCentreMappings.keySet().contains((Integer)opi.Company_Code__c)) {
                profitCentreMappings.put((Integer)opi.Company_Code__c, new Set<String>());
            }
            profitCentreMappings.get((Integer)opi.Company_Code__c).add(opi.Legal_Entity_of_Booking__c);
        }
        for (Option_List_Item__c oli : profitCentres) {
            if (profitCentreMappings.get((Integer)oli.Company_Code__c) != null) {
                Set<String> legalEntityOfBookings = profitCentreMappings.get((Integer)oli.Company_Code__c);
                oli.Legal_Entity_of_Booking__c = String.join(New List<String>(legalEntityOfBookings), ',');
            } else {
                oli.Legal_Entity_of_Booking__c = null;
            }
        }
    }

}