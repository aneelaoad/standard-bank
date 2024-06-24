public without sharing class DTO_SelectOption {

	@AuraEnabled public String 	label { get;set; }
    @AuraEnabled public String 	value { get;set; }
    @AuraEnabled public Boolean disabled { get;set; }
	
	public DTO_SelectOption(String value, String label) {
        this.value = value;
        this.label = label;
        this.disabled = false;
    }

    public DTO_SelectOption(String value, String label, Boolean isDisabled) {
        this.value = value;
        this.label = label;
        this.disabled = isDisabled;
    }

    public DTO_SelectOption(SelectOption selectOption) {
        this.value = selectOption.getLabel();
        this.label = selectOption.getValue();
        this.disabled = selectOption.getDisabled();
    }

	public DTO_SelectOption(PicklistEntry picklistEntryObject) {
        this.value = picklistEntryObject.getLabel();
        this.label = picklistEntryObject.getValue();
        this.disabled = !picklistEntryObject.isActive();
    }

    /**
    * @description Converts list of System.SelectOption to List of DTO_SelectOption
    * @param options list to be converted
    * @return list of converted DTO_SelectOption objects
    */ 
    public static DTO_SelectOption[] convert(SelectOption[] options){
        DTO_SelectOption[] dtoOptions = new List<DTO_SelectOption>();
        for(SelectOption option : options){
          dtoOptions.add(new DTO_SelectOption(option));
        }
        return dtoOptions;
    }

	public static DTO_SelectOption[] convert(PicklistEntry[] entries){
        DTO_SelectOption[] dtoOptions = new List<DTO_SelectOption>();
        for(PicklistEntry option : entries){
          dtoOptions.add(new DTO_SelectOption(option));
        }
        return dtoOptions;
    }

    public static DTO_SelectOption[] fetchOptions(SobjectField field){
    	DTO_SelectOption[] options = new DTO_SelectOption[]{};

    	for(SelectOption opt : UTL_Schema.fetchOptions(field)){
    		options.add(new DTO_SelectOption(opt));
    	}

    	return options;
    }
}