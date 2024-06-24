/*************************************************************************
    @ Author        : Abhishek V
    @ Date          : Nov 3, 2016
    @ TestClass     : StdBank_Ltn_ClientHelperTest
    @ Description   : US-1664
****************************************************************************/
public class StdBank_Ltn_ClientHelper {
  
    @AuraEnabled
    public static String getuitheme() {
    
        return userinfo.getUiTheme();
    }
    
    @AuraEnabled
    public static Account getRecord(Id recordId) {
        return [SELECT Id, Primary_Relationship_Holder__c, RecordType.Name FROM Account WHERE Id = :recordId];
    }
    
    @AuraEnabled
    public static String getRT(Id recordId) {
        return [SELECT Id, Primary_Relationship_Holder__c, RecordType.Name FROM Account WHERE Id = :recordId].Primary_Relationship_Holder__c;
    }
    
}