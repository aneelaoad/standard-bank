public without sharing class Angola_StatusPicklistController {
        @AuraEnabled public String  label { get;set; }
    @AuraEnabled public String  value { get;set; }
    @AuraEnabled public Boolean disabled { get;set; }
    public Angola_StatusPicklistController(SelectOption selectOption) {
        this.value = selectOption.getLabel();
        this.label = selectOption.getValue();
        this.disabled = selectOption.getDisabled();
    }
    
    /**
* @description Converts list of System.SelectOption to List of Angola_StatusPicklistController
* @param options list to be converted
* @return list of converted Angola_StatusPicklistController objects
*/ 
    public static Angola_StatusPicklistController[] convert(SelectOption[] options){
        Angola_StatusPicklistController[] statusOption = new List<Angola_StatusPicklistController>();
        for(SelectOption option : options){
            statusOption.add(new Angola_StatusPicklistController(option));
        }
        return statusOption;
    }
 
    
        /**
    * @description Provides list of select options with close only statuses
    * @return List of closed statuses
    */ 
    public static SelectOption[] getCloseStatus(){
      List<CaseStatus> closeStatuses = [SELECT ApiName, IsClosed,MasterLabel, SortOrder From CaseStatus];
      List<SelectOption> picklistValues = new List<SelectOption> ();
      for(CaseStatus status : closeStatuses){
        picklistValues.add(new SelectOption(status.ApiName, status.MasterLabel));
      }
      return picklistValues;
    }
    

}