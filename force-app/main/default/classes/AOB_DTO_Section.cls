/**
* Class used as Wrapper Class to display section info
*
* @author Salesforce
*
* @date Oct 28th 2021
*/
public class AOB_DTO_Section{
    @AuraEnabled 
    public Decimal rank { get; set; }
    @AuraEnabled 
    public Decimal largeDeviceColumns { get; set; }
    @AuraEnabled
    public Decimal mediumDeviceColumns { get; set; }
    @AuraEnabled
    public Decimal smallDeviceColumns { get; set; }
    public Id identifier;
    @AuraEnabled
    public String title { get;set; }
    @AuraEnabled
    public String sectionName { get;set; }
    @AuraEnabled
    public String gridClass { get;set; }
    @AuraEnabled
    public List<AOB_DTO_Field> fields { get; set; } 
}