/**
* Class used as Wrapper Class to display select options
*
* <p>DBP-1279</p>
*
* @author Maryem BOURHI (mbourhi@salesforce.com)
*
* @date Nov 23th 2020
*/
public class AOB_DTO_SelectOption {
    @AuraEnabled
    public String value { get; set; }
    @AuraEnabled
    public String label { get; set; }
    @AuraEnabled
    public Boolean isDefault { get; set; }
    
    /**
    * @description constructor
    */
    public AOB_DTO_SelectOption() {
        this.value = '';
        this.label = '';
        this.isDefault = false;
    }
    /**
    * @description constructor
    * @param   a  String value
    * @param   b  String label
    */
    public AOB_DTO_SelectOption(String a, String b) {
        this.value = a;
        this.label = b;
    }
    
    /**
    * @description constructor
    * @param   a String a value
    * @param   b String a label
    * @param   isDefault Boolean isDefault 
    */
    public AOB_DTO_SelectOption(String a, String b, Boolean isDefault) {
        this.value = a;
        this.label = b;
        this.isDefault = isDefault;
    }
}