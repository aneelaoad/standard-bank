/**
* Class used as Wrapper Class to display field info
*
* @author Salesforce
*
* @date Oct 28th 2021
*/
public class AOB_DTO_Field implements Comparable{
    @AuraEnabled
    public String helpTxt { get; set;}
    @AuraEnabled
    public String mriTable { get; set;}
    @AuraEnabled
    public String value { get; set;}
    @AuraEnabled
    public String placeholder { get; set;}
    @AuraEnabled
    public String pattern { get; set;}
    @AuraEnabled
    public Decimal sequence { get; set; }
    @AuraEnabled
    public String id { get; set; }
    @AuraEnabled
    public String name { get; set; }
    @AuraEnabled
    public String errorMessage { get; set; }
    @AuraEnabled
    public String label { get; set; }
    @AuraEnabled
    public String image { get; set; }
    @AuraEnabled
    public Boolean isRequired { get; set; }
    @AuraEnabled 
    public Boolean isCheckbox { get; set; } 
    @AuraEnabled 
    public Boolean isImageCheckbox { get; set; } 
    @AuraEnabled 
    public Boolean isFuzzyDropdown { get; set; }     
    @AuraEnabled
    public Boolean isInput { get; set; }
    @AuraEnabled
    public Boolean isNumber { get; set; }
    @AuraEnabled
    public Boolean isHelpText { get; set;}
    @AuraEnabled
    public Boolean isEmail { get; set; }
    @AuraEnabled
    public Boolean isCombobox { get; set; }
    @AuraEnabled
    public Boolean isRadio { get; set; }
    @AuraEnabled
    public Boolean isNFIRadio { get; set; }
    @AuraEnabled
    public Boolean isTax { get; set; }
    @AuraEnabled
    public Boolean isOutput { get; set; }
    @AuraEnabled
    public Boolean isCurrency { get; set; }
    @AuraEnabled
    public Boolean isResAddress { get; set; }
    @AuraEnabled
    public Boolean isCompanyAddress { get; set; }
    @AuraEnabled
    public Boolean isMultiselect { get; set; }
    @AuraEnabled
    public Boolean isPrivateaddress { get; set; }
     @AuraEnabled
    public Boolean isConsentBox { get; set; }
     @AuraEnabled
    public Boolean isDataPrivacy { get; set; }
    @AuraEnabled
    public String parent { get; set; }
    @AuraEnabled
    public Boolean showError { get; set; }
    @AuraEnabled
    public Boolean isHidden { get; set; }
    @AuraEnabled
    public List<AOB_DTO_SelectOption> options { get; set; }
    @AuraEnabled
    public String childShowingValue { get; set; }
    @AuraEnabled
    public String parentControllingValue { get; set; }
    @AuraEnabled
    public Double maxSelected { get; set; }
    @AuraEnabled
    public Double minLength { get; set; }
    @AuraEnabled
    public Double maxLength { get; set; }
    @AuraEnabled	
    public String compTradingValue { get; set; }
    
    /**
    * constructs a jsField based on AOB_Field__c record
    * @param    field AOB_Field__c  
    * @param    apps List<AOB_Application__c>  
    */
    public AOB_DTO_Field(AOB_Field__c field,List<AOB_Application__c> apps) {
        // setting field type
        this.isRequired=field.AOB_Required__c;
        if(String.isNotBlank(field.AOB_Parent__c)){
            this.parent=field.AOB_Parent__c;
            this.isHidden=!field.AOB_ShowAtScreenLoad__c;
        }
        else {
            this.isHidden=false;
        }
        this.image=field.AOB_Image__c;
        this.maxSelected=field.AOB_MaxSelected__c;
        this.pattern=field.AOB_pattern__c;
        this.errorMessage=field.AOB_ErrorMessage__c;
        this.id=field.id;
        this.label=field.AOB_Label__c;
        this.sequence=field.AOB_sequence__c;
        this.name=field.name;
        this.parentControllingValue=field.AOB_parentControllingValue__c;
        this.childShowingValue=field.AOB_childShowingValue__c;
        this.mriTable=field.AOB_MRITable__c;
        this.helpTxt=field.AOB_HelpText__c;
        this.placeholder=field.AOB_Placeholder__c;
        this.minLength=field.AOB_MinLength__c;
        this.maxLength=field.AOB_MaxLength__c;
        
        this.setFieldType(field,apps);
        
    }
    
    /**
    * sets object fields and returns field
    * @param    field AOB_Field__c 
    * @param    apps List<AOB_Application__c> 
    */
    private void setFieldType(AOB_Field__c field, List<AOB_Application__c> apps){
        switch on field.AOB_Type__c  {
            when 'Combobox' {
                this.isCombobox = true;
            }	
            when 'NFIRadio' {
                this.isNFIRadio = true;
            }
            when 'Radio' {
                this.isRadio = true;
            }
            when 'Text' {	
                this.isInput = true;
            }
            when 'Number' {	
                this.isNumber = true;
            }
            when 'Tax' {	
                this.isTax = true;
            }
            when 'Email' {	
                this.isEmail = true;
            }
            when 'Currency' {	
                this.isCurrency = true;
            }
            when 'MultiSelectSearch' {	
                this.isMultiselect = true;
            }
            when 'Checkbox' {	
                this.isCheckbox = true;
            }
            when 'Private address' {	
                this.isPrivateaddress = true;
                if(!apps.isEmpty() && field.AOB_SFField__c!=null){
                    this.value = String.valueOf(apps[0].get(field.AOB_SFField__c));
                    if(String.isNotBlank(apps[0].AOB_TECH_Company_Address__c)){
                        this.compTradingValue=String.valueOf(apps[0].AOB_TECH_Company_Address__c);
                    }
                    else{
                        this.compTradingValue=String.valueOf(apps[0].get(field.AOB_SFField__c));
                    }
                }
            }
            when 'Residential Address' {
                this.isResAddress = true;
                if(!apps.isEmpty() && field.AOB_SFField__c!=null){
                    this.value = String.valueOf(apps[0].get(field.AOB_SFField__c));
                }
            }
            when 'isCompanyAddress'{
                this.isCompanyAddress = true;
                if(!apps.isEmpty() && field.AOB_SFField__c!=null){
                    this.value = String.valueOf(apps[0].get(field.AOB_SFField__c));
                }
            }
            when 'helpText' {
                this.isHelpText = true;
            } 
            when 'fuzzy dropdown' {
                this.isFuzzyDropdown=true;
            }
            when 'ImageCheckbox' {
                this.isImageCheckbox=true;
            }
            when 'DataPrivacy' {
                this.isDataPrivacy=true;
            }
             when 'consentBox' {
                this.isConsentBox=true;
            }
            
            when 'Output' {	
                this.isOutput = true;
                if(!apps.isEmpty() && field.AOB_SFField__c!=null){
                    this.value = String.valueOf(apps[0].get(field.AOB_SFField__c));
                }
            }
        }
    }
    
    /**
    * Compare fields based on the sequence amount
    * @param    compareTo Object 
    * @return    Integer
    */
    public Integer compareTo(Object compareTo) {
        AOB_DTO_Field field = (AOB_DTO_Field)compareTo;
        
        Integer returnValue = 0;
        if (this.sequence > field.sequence) {
            // Set return value to a positive value.
            returnValue = 1;
        } else if (this.sequence < field.sequence) {
            // Set return value to a negative value.
            returnValue = -1;
        } else if ((this.sequence == null) && (field.sequence != null)){
            // nulls-first implementation
            returnValue = -1;
        } else if ((this.sequence != null) && (field.sequence == null)){
            // nulls-first implementation
            returnValue = 1;
        }        
        return returnValue;       
    }
}