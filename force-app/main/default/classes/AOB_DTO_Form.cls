/**
* Class used as Wrapper Class to display form info
*
* @author Salesforce
*
* @date Oct 28th 2021
*/
public class AOB_DTO_Form{
    @AuraEnabled
    public String title { get; set; }
    @AuraEnabled
    public String subtitle { get; set; }
    @AuraEnabled
    public List<AOB_DTO_Section> sections { get; set; }
}