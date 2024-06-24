public with sharing class emailBirthdayUsers {
    public Integer Month;
    public Integer Day;
    public String TemplateName;
    
    public emailBirthdayUsers(){
        this.Day = date.today().day();
        this.Month = date.today().month();
        this.TemplateName = 'Happy_Birthday_User';
    }
    
    public Integer sendMail(){
        Integer totalBirthdayEmails = 0;
        //Set the template
        EmailTemplate birthdayTemplate = [select Id,Name,Subject,body from EmailTemplate where DeveloperName like :TemplateName+'%'];
        //String[] toAddresses;
        List<Id> theHappyPeople = new List<Id>();
        //Find the birthday boys and girls
        System.debug('###: The Birth Day: '+Day.format());
        System.debug('###: The Birth Month: '+Month.format());
        for (User theHappyUser :[SELECT Id FROM User WHERE DAY_IN_MONTH(User.Birthday_Date_Format__c ) = :Day AND CALENDAR_MONTH(User.Birthday_Date_Format__c ) = :Month]){
            theHappyPeople.add(theHappyUser.Id);
        }
        
        if(birthdayTemplate != null && theHappyPeople.size() > 0){
            
            Messaging.MassEmailMessage birthdayMail = new Messaging.MassEmailMessage();
            birthdayMail.setTargetObjectIds(theHappyPeople);
            birthdayMail.setTemplateId(birthdayTemplate.Id);
            birthdayMail.setUseSignature(false);
            birthdayMail.setSaveAsActivity(false);
            birthdayMail.setSenderDisplayName('CRM Salesforce');

            // Send the email
            Messaging.SendEmailResult[] results = Messaging.sendEmail(new Messaging.MassEmailMessage[] { birthdayMail }, false);
            for (Messaging.SendEmailResult currentResult : results ){
                if (currentResult.isSuccess()) totalBirthdayEmails++;
            }
        }
        return totalBirthdayEmails;
    }
    
    static testMethod void testemailBirthdayUsers() {
            
    }
}