/*************************************************************************
	@ Author 		: psvestka
	@ Date 		    : 15. 10. 2015
	@ Test File 	: CsiComponentControllerTest.cls
	@ Description	: EN-692

	@ Last Modified By  : Petr Roubal
    @ Last Modified On  : Nov 24, 2015
    @ Modification Description : EN-939 : CSI - Client Plan PDF and Attach version

    @ Last Modified By  : Petr Roubal
    @ Last Modified On  : Feb 2, 2016
    @ Modification Description : EN-1018 : 	CSI - Client Plan & PDF default values
****************************************************************************/

public with sharing class CsiComponentController {
    public CsiWrapper cwUGP { get; private set; } {
        cwUGP = new CsiWrapper();
    }
    public Map<Id, CsiWrapper> cwsImPMap { get; private set; } {
        cwsImPMap = new Map<Id, CsiWrapper>();
    }
    public Map<Id, CsiWrapper> cwsChildMap { get; private set; } {
        cwsChildMap = new Map<Id, CsiWrapper>();
    }

    private boolean initializationDone = false;
    private static string EmptyValue = 'None';

    public Boolean renderUGP { get { return cwUGP != null && cwUGP.csi_client_name != null; } private set;}
    public Boolean renderImP { get { return cwsImPMap != null && cwsImPMap.size() > 0; } private set;}
    public Boolean renderChild { get { return cwsChildMap != null && cwsChildMap.size() > 0; } private set;}

    public Id accId {
        get;
        set {
            accId = value;
            runOnlyIfBoth();
        }
    }

    public ClientPlanClass pageController {
        get;

        set {
            //set component controller on page controller
            if (value != null) {
                pageController = value;
                pageController.setComponentController(this);
                runOnlyIfBoth();
            }

        }
    }
    // constructor for ClientPlan page
    public CsiComponentController(){

    }

    // constructor for ClientPlanPDF page
    public CsiComponentController(Id accId, ClientPlanClass cpc){
        pageController = cpc;
        this.accId = accId;
    }

    private static final String ULTIMATE_GROUP_PARENT = 'Ultimate Group Parent';
    private static final String IMMEDIATE_PARENT = 'Immediate Parent';
    private static final String CHILD = 'Child';
    private static final string DEFAUL_VALUE = 'None';

        @TestVisible private static final string CLIENT_TYPE_UGP = ' (Group Parent)';
    @TestVisible private static final string CLIENT_TYPE_IMMP = ' (Imm Parent)';
    @TestVisible private static final string CLIENT_TYPE_CHILD = ' (Child)';

    private void runOnlyIfBoth() {
        if (accId != null && pageController != null && !initializationDone) {
            fetchValues();
        }
    }


    private void fetchValues() {
        

        if (accId == null) {
            return;
        }

        // re-initialize
        cwUGP = new CsiWrapper();
        cwsImPMap.clear();
        cwsChildMap.clear();

        List<Account> accs = [SELECT id, name, recordType.name
                                FROM Account
                               WHERE id = :accId
                                  OR parentId = :accId
                                  OR parent.parentId = :accId];

        Map<Id, Account> accMap = new Map<Id, Account>(accs);

        Set<Id> accSet = new Set<Id>();
        for (Id i: accMap.keySet()) {
            accSet.add(i);
        }

        Set<String> latestCsiPerClientSet = new Set<String>();
        Map<Id, CsiWrapper> clientToLatestCsi = new Map<Id, CsiWrapper>();

        Set<Id> selected = new Set<Id>(pageController.getCsiSelecton());

        for (Client_Satisfaction_Index__c csi: [SELECT id
                                                      ,client__c
                                                      ,survey_Year__c
                                                      ,Overall_CIB_CSI_Rating_Number__c
                                                      ,client__r.recordType.name
                                                      ,lastModifiedDate
                                                      ,csi_client_name__c
                                                      ,csi_project_country__c
                                                      ,csi_project_name__c
                                                      ,csi_survey_contact__r.name
                                                      ,contact_job_title__c
                                                      ,TPS_CSI_Rating_Number__c
                                                      ,GM_CSI_Rating_Number__c
                                                      ,IB_CSI_Rating_Number__c
                                                      ,csi_credit_turnaround__c
                                                      ,csi_wallet_share_opportunity__c
                                                      ,csi_tps_comment__c
                                                      ,csi_gm_comment__c
                                                      ,csi_ib_comment__c
                                                  FROM Client_Satisfaction_Index__c
                                                 WHERE client__c IN :accSet
                                                 ORDER BY client__c DESC
                                                         ,lastModifiedDate DESC]) { // picklist survey_Year__c would be sorted in the order of the values in the picklist, not normally

            if (!clientToLatestCsi.containsKey(csi.client__c)
                || (clientToLatestCsi.containsKey(csi.client__c) && clientToLatestCsi.get(csi.client__c).survey_Year < csi.survey_Year__c)) {

                CsiWrapper cw = new CsiWrapper(csi.csi_client_name__c, csi.client__r.recordType.name);
                cw.csi_id = csi.id;
                cw.csi_selected = selected.contains(csi.id);
                cw.survey_Year = csi.survey_Year__c;
                cw.overall_CIB_CSI_Rating = csi.Overall_CIB_CSI_Rating_Number__c;
                cw.csi_project_country = csi.csi_project_country__c;
                cw.csi_project_name = csi.csi_project_name__c;
                cw.csi_survey_contact = csi.csi_survey_contact__r.name;
                cw.csi_contact_position = csi.contact_job_title__c;
                cw.tps_csi_rating = csi.TPS_CSI_Rating_Number__c;
                cw.gm_csi_rating = csi.GM_CSI_Rating_Number__c;
                cw.ib_csi_rating = csi.IB_CSI_Rating_Number__c;
                cw.csi_credit = csi.csi_credit_turnaround__c == null ? null : String.valueOf(csi.csi_credit_turnaround__c);
                cw.csi_wallet_share_opportunity = csi.csi_wallet_share_opportunity__c;
                cw.csi_tps_comment = csi.csi_tps_comment__c;
                cw.csi_gm_comment = csi.csi_gm_comment__c;
                cw.csi_ib_comment = csi.csi_ib_comment__c;

                clientToLatestCsi.put(csi.client__c, cw); // rewrite
            }
        }

        for (Id i: clientToLatestCsi.keySet()) {
            // rewrite the map with CSI info
            if (clientToLatestCsi.get(i).clientRecordTypeName == ULTIMATE_GROUP_PARENT) {
                cwUGP = clientToLatestCsi.get(i);
            } else if (clientToLatestCsi.get(i).clientRecordTypeName == IMMEDIATE_PARENT) {
                cwsImpMap.put(i, clientToLatestCsi.get(i));
            } else if (clientToLatestCsi.get(i).clientRecordTypeName == CHILD) {
                cwsChildMap.put(i, clientToLatestCsi.get(i));
            }
        }
        initializationDone = true;
    }

    public void updateSelection(){
    }

    public List<Id> saveSelectedCSI(){
        List<Id> retIds = new List<Id>();

        if(cwUGP.csi_selected != null && cwUGP.csi_selected){
            retIds.add(cwUGP.csi_id);
        }

        for(CsiWrapper cw : cwsImPMap.values())
        {
            if(cw.csi_selected){
                retIds.add(cw.csi_id);
            }
        }

        for(CsiWrapper cw : cwsChildMap.values())
        {
            if(cw.csi_selected){
                retIds.add(cw.csi_id);
            }
        }
        return retIds;
    }

    public class CsiWrapper implements Comparable {

        public CsiWrapper() { }

        // EN-1018 : CSI - Client Plan & PDF default values
        public CsiWrapper(String clientName, String recordTypeName) {
            if(recordTypeName == ULTIMATE_GROUP_PARENT){
                this.csi_client_name = clientName + CLIENT_TYPE_UGP;
            }else if(recordTypeName == IMMEDIATE_PARENT){
                this.csi_client_name = clientName + CLIENT_TYPE_IMMP;
            }else if(recordTypeName == CHILD){
                this.csi_client_name = clientName + CLIENT_TYPE_CHILD;
            }else {
                this.csi_client_name = clientName;
            }
            this.clientRecordTypeName = recordTypeName;
        }
        public Id csi_id { get; set; }
        public String clientRecordTypeName { get; private set; }
        public boolean csi_selected { get; set; }
        public String survey_Year { get; private set; }
        public Decimal overall_CIB_CSI_Rating { get; private set; }
        public String csi_client_name { get; private set; }


        public String csi_project_country { get{
                                                return (csi_project_country == null || String.IsEmpty(csi_project_country)) ? DEFAUL_VALUE : csi_project_country;
                                            }
                                            private set; }
        public String csi_project_name { get; private set; }
        public String csi_survey_contact { get{
                                                return (csi_survey_contact == null || String.IsEmpty(csi_survey_contact)) ? DEFAUL_VALUE : csi_survey_contact;
                                            }
                                            private set; }
        public String csi_contact_position { get; private set; }
        //EN-1018 : CSI - Client Plan & PDF default values
        public Decimal tps_csi_rating { get{
                                            return (tps_csi_rating == null)  ? null : tps_csi_rating;
                                    } private set; }
        //EN-1018 : CSI - Client Plan & PDF default values
        public Decimal gm_csi_rating { get{
                                            return (gm_csi_rating == null)  ? null : gm_csi_rating;
                                    }  private set; }
        //EN-1018 : CSI - Client Plan & PDF default values
        public Decimal ib_csi_rating {  get{
                                        return (ib_csi_rating == null ) ? null : ib_csi_rating;
                                    }  private set; }
        //EN-1018 : CSI - Client Plan & PDF default values
        public String csi_credit { get{
                                    return (csi_credit == null || String.IsEmpty(csi_credit)) ? DEFAUL_VALUE : csi_credit;
                                } private set; }

        public String csi_wallet_share_opportunity {
            get;
            private set {
                csi_wallet_share_opportunity = value;
                csi_wallet_share_opportunity_trunc = truncateToTwoLines(value);
            }
        }

        public String csi_tps_comment {
            get;
            private set {
                csi_tps_comment = value;
                csi_tps_comment_trunc = truncateToTwoLines(value);
            }
        }

        public String csi_gm_comment {
            get;
            private set {
                csi_gm_comment = value;
                csi_gm_comment_trunc = truncateToTwoLines(value);
            }
        }

        public String csi_ib_comment {
            get;
            private set {
                csi_ib_comment = value;
                csi_ib_comment_trunc = truncateToTwoLines(value);
            }
        }

        public String csi_wallet_share_opportunity_trunc { get; private set; }
        public String csi_mcc_recommendation_trunc { get; private set; }
        public String csi_tps_comment_trunc { get; private set; }
        public String csi_gm_comment_trunc { get; private set; }
        public String csi_ib_comment_trunc { get; private set; }

        public String overallRatingCssClass {
            get {
                return getRatingCssStyle(String.valueOf(overall_CIB_CSI_Rating));
            }
            private set;
        }

        public String gmRatingCssClass {
            get {
                return getRatingCssStyle(String.valueOf(gm_csi_rating));
            }
            private set;
        }

        public String ibRatingCssClass {
            get {
                return getRatingCssStyle(String.valueOf(ib_csi_rating));
            }
            private set;
        }

        public String tpsRatingCssClass {
            get {
                return getRatingCssStyle(String.valueOf(tps_csi_rating));
            }
            private set;
        }

        public String creditRatingCssClass {
            get {
                return getRatingCssStyle(csi_credit);
            }
            private set;
        }

        private String getRatingCssStyle(String rating) {
            if (rating == null || !rating.containsOnly('0123456789.-eE')) {
                return 'leftAligned';
            }

            Integer val;
            try {
                val = Integer.valueOf(rating);
            } catch (Exception e) {
                return 'leftAligned';
            }

            if (val <= 6) {
                return 'red';
            } else if (val <= 7) {
                return 'amber';
            } else {
                return 'green';
            }
        }

        private String truncateToTwoLines(String text) {
            if (text == null || text == '') {
                return '';
            }
            return text.abbreviate(170);
        }

        private String truncateToOneLine(String text) {
            if (text == null || text == '') {
                return '';
            }
            return text.abbreviate(90);
        }

        public Integer compareTo(Object compareTo) {
            CsiWrapper compareToCsi = (CsiWrapper) compareTo;

            if (this.csi_client_name == null || this.csi_client_name == ''
                || compareToCsi.csi_client_name == null || compareToCsi.csi_client_name == '') {
                return 0;
            }

            if (this.csi_client_name < compareToCsi.csi_client_name) {
                return -1;
            }
            else if (this.csi_client_name.equals(compareToCsi.csi_client_name)) { // case sensitive
                return 0;
            }
            else {
                return 1;
            }
        }
    }
}