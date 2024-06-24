/**
 * @description Apex custom controller NBACpdfForm visualforce component
 */
public without sharing class NBACPdfFromController {

    public Id nbacRecId {get;set;}

    public Business_Assessment__c nbac{
        get {
            if(nbac != null) {
                return nbac;
            }
            else {
                nbac = getData();
                return nbac;
            }
        }
        set;
    }
    @TestVisible
    private Business_Assessment__c getData() {
        if (nbacRecId == null) {
            return null;
        }
        else {
            nbac = [
                    SELECT Id, Account__c, Name, YTD_Group_Parent_Client_CROC__c, Economic_Group_Client_Risk_Rating__c, Entities_Risk_Rating__c,
                            Economic_Group_Client_Sector_Temp__c, Submission_Type__c, Economic_Group_Client_Country_of_Risk__c,
                            Economic_Group_Sector_Risk_Appetite__c, Risk_Classification__c, Complexity__c, Decision_Emphasis__c,
                            Client_LGD__c, Ultimate_Shareholders__c, Group_Directors__c, Account__r.Name, Gearing_Metric__c,
                            Client_Gearing_PreTransaction__c, Client_Gearing_PostTransaction__c, Nature_of_Business__c,
                            Guarantor_Name__r.name, Guarantor_Gearing_PreTransaction__c, Guarantor_Gearing_PostTransaction__c,
                            Advisor__c, Mandated_Lead_Arranger__c, Other_Lenders__c, Transaction_Description__c, Strategic_Rationale__c,
                            Global_Markets_PY_Revenue__c, Global_Markets_CY_Revenue__c, Investment_Banking_PY_Revenue__c, Investment_Banking_CY_Revenue__c,
                            TPS_PY_Revenue__c, TPS_CY_Revenue__c, Anticipated_Ancillary_Business_GM__c, Anticipated_Ancillary_Business_IB__c,
                            Anticipated_Ancillary_Business_TPS__c, GM_Share_of_Wallet_Existing_Total__c, GM_Share_of_Wallet_Existing_SBG__c,
                            IB_Share_of_Wallet_Existing_Total__c, IB_Share_of_Wallet_Existing_SBG__c, TPS_Share_of_Wallet_Existing_Total__c,
                            TPS_Share_of_Wallet_Existing_SBG__c, SB_Gross_Participation__c, Bank_Role__c, SB_Hold__c, SB_Sell_Down__c, Transaction_Type__c, (
                            SELECT Indicator__c, ValueIndicator__c, Metric__c,
                                    Date__c, Metric_Year_1__c, Metric_Year_2__c, Metric_Year_3__c, Metric_Year_4__c, ValueYear1__c,
                                    ValueYear2__c, ValueYear3__c, ValueYear4__c
                            FROM NBAC_Financial_Analysis__r
                            WHERE Business_Assessment__c = :nbacRecId
                    ),
                            TCM_Details__c, TCM_Commentary__c, Underwrite_Amount__c, Amount_Held__c, SBSA_Role__c, Transaction_Profile__c,
                            Credit_Requirement__c, Listed_Instruments__c, Distribution_Price__c, Potential_Investors__c, Distribution_Commentary__c,
                            Risk_Commentary__c, GCCR_Status__c, KYC_Status__c, EDD_PEP__c, Sanctions__c, Transaction_Risk__c, Client_Risk__c,
                            Reference_Number__c, ES_Risk_Commentary__c, Business_Sponsor__r.name, Additional_Transaction_Description__c,
                            Additional_Strategic_Rationale__c
                    FROM Business_Assessment__c
                    WHERE Id = :nbacRecId
            ];
        }
        return nbac;
    }

    /**
     * Get Task record marked as NBAC Action Item associated with NBAC's Acoount record
     *
     * @return List<Task>
     */
    public List <Task> getActionItems(){
            List <Task> actionList = new List <Task> ();
            if(nbac!=null) {
                List<Account> clients = [
                        SELECT Id, (
                                SELECT Account.Name,Subject, Owner.Name, ActivityDate
                                FROM Tasks
                                WHERE
                                IsClosed = false AND Type = 'NBAC Action Item'
                        )
                        FROM Account
                        WHERE
                        Id = :nbac.Account__c OR ParentID = :nbac.Account__c OR Parent.ParentID = :nbac.Account__c
                ];
                for (Account acc : clients) {
                    actionList.addAll(acc.Tasks);
                }
            }
            return actionList;
        }

        /**
         * Get Client Team (Custom_Client_Team__c) associated with NBAC's Acoount record
         *
         * @return List<Custom_Client_Team__c>
         */
        public List<Custom_Client_Team__c> getTeam(){
            List <Custom_Client_Team__c> teamList = new List <Custom_Client_Team__c>();
            if(nbac!=null) {
                teamList = [SELECT Team_Member__r.Name, Client_Role__c FROM Custom_Client_Team__c
                            WHERE Account__c = :nbac.Account__c AND (Core__c = true OR Client_Coordinator_BM__c = true)];
            }
            return teamList;
        }

        /**
         * Get Opportunities with Opportunity Team Members for Opportunities linked to NBAC record
         *
         * @return List <Opportunity>
         */
        public List <Opportunity> getOpportunityTeam(){
            List<Opportunity> oppMembersInfo = new List<Opportunity>();
            if(nbac != null) {
                oppMembersInfo = DMN_Opportunity.getOpportunitiesWithTeamMembers(nbac.Id);
            }
            return oppMembersInfo;
        }
}