/**
 * Domain layer class for User SObject
 *
 * @author Unknown
 * @date Unknown
*/
@SuppressWarnings('PMD.ExcessiveClassLength, PMD.StdCyclomaticComplexity, PMD.CyclomaticComplexity, PMD.ExcessivePublicCount')
public inherited sharing class DMN_User {
    public static final String BU_BRANCH = 'Branch';
    public static final String BU_BUY_SIDE = 'Buy-Side';
    public static final String BU_CRM_IT = 'CRM IT';
    public static final String CIB_GA_COMMB = 'BCC';
    public static final String CIB_GA_CIBI = 'CIBI';
    public static final String CIB_GA_CIBSA = 'CIBSA';
    public static final String CLIENT_COVERAGE_DIVISION = 'Client Coverage';
    public static final String COMMB_DIVISION = 'Commercial Banking';
    public static final String BB_DIVISION = 'Business Banking';
    public static final String ENTREPRENEUR_DIVISION = 'Entrepreneur';
    public static final String TPS_DIVISION = 'Transactional Products and Services';
    public static final String IB_DIVISION = 'Investment Banking';
    public static final String GM_DIVISION = 'Global Markets';
    public static final String RE_DIVISION = 'Real Estate';
    public static final String TEAM_BELAS = 'Belas';
    public static final String TYPE_AUTOMATED_PROCESS = 'AutomatedProcess';
    public static final String VAF_DIVISION = 'Vehicle and Asset Finance';
    public static final String GUEST_USER_TYPE = 'Guest';
    public static final String ARCHIVED_OWNER_ALIAS = 'Archived';
    public static final String BUSINESS_UNIT_DISTRIBUTION = 'Distribution';
    public static final Set<String> INSURANCE_ROLES = new Set<String>{
            'CIB_Angola_Insurance_Team','CIB_Botswana_Insurance_Team','CIB_Eastern_Cape_Insurance_Team',
            'CIB_e_Swatini_Insurance_Team','CIB_Free_State_Insurance_Team','CIB_Gauteng_Insurance_Team',
            'CIB_Ghana_Insurance_Team','CIB_Global_Insurance','CIB_Global_Insurance_East_Africa_Region',
            'CIB_Global_Insurance_South_Africa_Region','CIB_Global_Insurance_South_Central_Africa_Region',
            'CIB_Global_Insurance_West_Africa_Region','CIB_Kenya_Insurance_Team','CIB_Kwa_Zulu_Natal_Insurance_Team',
            'CIB_Lesotho_Insurance_Team','CIB_Limpopo_Insurance_Team','CIB_Malawi_Insurance_Team',
            'CIB_Mozambique_Insurance_Team','CIB_Mpumalanga_Insurance_Team','CIB_Namibia_Insurance_Team',
            'CIB_Nigeria_Insurance_Team','CIB_Northern_Cape_Insurance_Team','CIB_North_West_Insurance_Team',
            'CIB_Tanzania_Insurance_Team','CIB_Uganda_Insurance_Team','CIB_Western_Cape_Insurance_Team',
            'CIB_Zambia_Insurance_Team','CIB_Zimbabwe_Insurance_Team'};

    /**
	* handleWelcomeNotificationInsert
	* @param newUserIdSet Set of user ids.
	*/
    @future
    public static void handleWelcomeNotificationInsert(Set<Id> newUserIdSet){
        List<Notification__c> notificationsList=new List<Notification__c>();
        for(User u : [Select Id,Name,FirstName from User where Id In :newUserIdSet]){
                Notification__c notification = new Notification__c();
                notification.Content__c = String.format(Label.OSB_Notification_Content, new String[]{u.FirstName});
                notification.Name = System.Label.OSB_Notification_Title;
                notification.OwnerId = u.Id;
                notification.Users__c = u.Id;
                notification.Selected_Users__c = u.Name;
                notification.Title__c = System.Label.OSB_Notification_Title;
                notificationsList.add(notification);
        }
        if(notificationsList.size()>0){
            insert notificationsList;
        }
    }
}