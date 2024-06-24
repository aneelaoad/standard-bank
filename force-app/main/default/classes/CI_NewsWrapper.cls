public with sharing class CI_NewsWrapper {
    @AuraEnabled
    public String An { get; set; }
    @AuraEnabled
    public DateTime Publication_Date { get; set; }
    @AuraEnabled
    public String Publisher_Name { get; set; }
    @AuraEnabled
    public String Title { get; set; }
    @AuraEnabled
    public String Snippet { get; set; }
    @AuraEnabled
    public Integer Pred { get; set; }
    @AuraEnabled
    public String High_Prob_Clients { get; set; }
    @AuraEnabled
    public String Medium_Prob_Clients { get; set; }
    @AuraEnabled
    public String Low_Prob_Clients { get; set; }
    @AuraEnabled
    public String Regions { get; set; }
    @AuraEnabled
    public String Sb_Group_Sectors { get; set; }
    @AuraEnabled
    public String Sb_Sub_Sectors { get; set; }
    @AuraEnabled
    public Integer Index { get; set; }
    @AuraEnabled
    public IsChinaAfrica Is_china_africa { get; set; }
    @AuraEnabled
    public IsTop100 Is_top_100 { get; set; }
    @AuraEnabled
    public IsNbfi Is_nbfi { get; set; }
    @AuraEnabled
    public String China_africa_clients_in_article { get; set; }
    @AuraEnabled
    public String Top_100_clients_in_article { get; set; }

    public class IsChinaAfrica {
        @AuraEnabled
        public Integer m_value { get; set; }
    }

    public class IsTop100 {
        @AuraEnabled
        public Integer m_value { get; set; }
    }

    public class IsNbfi {
        @AuraEnabled
        public Integer m_value { get; set; }
    }
}