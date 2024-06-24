/**
 * @description Schedulable class for weekly resourcing email notification [SFP-4977]
 *
 * @author Konrad Bruszewski
 * @date October 2021
 */
public with sharing class ResourcingEmailNotification implements Schedulable {

    private static final String TEMPLATE_NAME = 'IB_Timesheet_Reminder';
    private static final String DUE_DATE_TOKEN = '\\{\\{dueDate\\}\\}';
    private static final String LIST_VIEW_URL_TOKEN = '\\{\\{listViewURL\\}\\}';
    private static final String SENDER_EMAIL_ADDRESS = 'crmsalesforce.com@standardbank.co.za';
    private static final String DUE_DATE_FORMAT = 'HH:mm \'on\' EEEE dd MMMM yyyy';
    private static final String LIST_VIEW_URL_TEMPLATE = '{0}/lightning/o/{1}/list?filterName={2}';
    private static final String LANDING_LIST_VIEW_NAME = 'My_Last_week_Resourcing';

    //Cron to schedule execution for every monday at 07:00
    public static final String CRON_EXPR = '0 0 7 ? * MON *';
    //Job name to be used when scheduling a job
    public static final String JOB_NAME = 'Weekly_Resourcing_Remainder_For_Corporate_Finance';

    private Set<String> roleNames;
    private Integer dueHour;
    private Integer dueDayOfTheWeek;

    /**
     * Class constructor
     *
     * @param roleNames - Set<String> roles developer names for which notification should be sent
     * @param dueHour - Integer resourcing records complete due hour which will be displayed in the emails
     * @param dueDayOfTheWeek - Integer resourcing records complete due day of week which will be displayed in the emails (1 for Monday)
     */
    public ResourcingEmailNotification(Set<String> roleNames, Integer dueHour, Integer dueDayOfTheWeek) {
        this.roleNames = roleNames;
        this.dueHour = dueHour;
        this.dueDayOfTheWeek = dueDayOfTheWeek;
    }

    /**
    * Overridden execute Schedulable method
    *
    * @param context default reference to SchedulableContext
    */
    public void execute(SchedulableContext context) {
        sendEmails();
    }
	
    /*temp method for testing */
    public static void executeForTesting() {
        Set<String> roleNames = new Set<String> { 'CIB_Global_IB_Division' };
        ResourcingEmailNotification  scheduleInstance= new ResourcingEmailNotification(roleNames, 16, 1);
        scheduleInstance.sendEmails();
    }
    
    private void sendEmails() {
        SEL_Resourcing resourcingSelector = (SEL_Resourcing) ORG_Application.selector.newInstance(Resourcing__c.SObjectType);
        
        List<SEL_Resourcing.AggregateResultWrapper> queryResult = resourcingSelector.selectByWeekEndDateAndRolesGroupByResource(UTL_Resourcing.getLastWeekFridayDate(), UTL_Role.getInternalSubordinateRolesIds(roleNames));
        List<Id> userIds = new List<Id>();
        for (SEL_Resourcing.AggregateResultWrapper ar : queryResult) {
            userIds.add((Id) ar.populatedFields.get('Resource__c'));
        }
        List<Messaging.SingleEmailMessage> emailMessages = new List<Messaging.SingleEmailMessage>();
        createEmailMessages(emailMessages, userIds);
        if (emailMessages.isEmpty()) {
            return;
        }
        Messaging.sendEmail(emailMessages, false);
    }

    private void createEmailMessages(List<Messaging.SingleEmailMessage> emailMessages, List<Id> userIds) {
        EmailTemplate templateRecord = UTL_EmailTemplate.getTemplate(TEMPLATE_NAME);
        String emailBody = templateRecord.HtmlValue.replaceAll(DUE_DATE_TOKEN, getDueDateFormatted());
        emailBody = emailBody.replaceAll(LIST_VIEW_URL_TOKEN, getListViewURL());
        for (Id userId : userIds) {
            Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
            email.setSaveAsActivity(false);
            email.setOrgWideEmailAddressId(UTL_OrgWideEmailAddress.getAddressId(SENDER_EMAIL_ADDRESS));
            email.setTargetObjectId(userId);
            email.setHtmlBody(emailBody);
            email.setSubject(templateRecord.Subject);
            emailMessages.add(email);
        }
    }

    private String getDueDateFormatted() {
        Date dueDate = UTL_Resourcing.getWeekDayDate(dueDayOfTheWeek);
        Datetime dueDatetime = Datetime.newInstance(dueDate.year(), dueDate.month(), dueDate.day(), dueHour, 0, 0);
        return dueDatetime.format(DUE_DATE_FORMAT);
    }

    private String getListViewURL() {
        return String.format(LIST_VIEW_URL_TEMPLATE, new List<String> {
            URL.getOrgDomainUrl().toExternalForm(),
            Resourcing__c.SObjectType.getDescribe().getName(),
            LANDING_LIST_VIEW_NAME
        });
    }
}