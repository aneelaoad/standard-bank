/*****************************************************************************************************\
    @ Author        : Tracy Roberts
    @ Date          : 14-08-2012
    @ Description   : This Class gets called by the SA_StdBank_AccountBeforeInsertUpdate_Trigger Trigger and 
                      sends out email to notify Business Support and CRM Support that a Client has been Deleted.
                      Test Class - ClientDeleteEmailAlert_Test 
******************************************************************************************************/

Global class ClientDeleteEmailAlert {
    public static void clientDeleteNotificationEmail(List<Account> clientDeletedList)
    {        
        //Get the current date and time when the Client was deleted and add 2 Hours to get SA Time
        DateTime actionDateTime = System.now();
        String formatActionDateTime = actionDateTime.format('yyyy-MM-dd HH:mm:ss', 'GMT+02:00');

        //Create a String for the Email Body/Content
        String emailBody = 'Hi, \n \nPlease be advised that the following Clients were deleted: \n \n';
        
        //User who deleted the Client
        String userDeleteName = userinfo.getName();        
        
        //Create a String of all the email addresses to whom the email must be sent
        String[] sendToAddress = new String[] {'CIBSACRMITPS.CIBCRMITProductionSupport@standardbank.co.za'};
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        
        //Set the Capacity of the email
        Messaging.reserveSingleEmailCapacity(2);
        
        //Loop each Accont that has bee deleted (Get the Account details through the Trigger)
        for(Account a : clientDeletedList)
        {            
            //Set the Body/Content of the email with the Client Name, Client ID, CIF Number that has been deleted and the User Name who deleted the Client.
            emailBody = emailBody + '   Client Name: ' + a.name + '\n   Client ID: ' + a.Id + '\n   CIF Number: ' + a.CIF__c + '\n   Deleted by: ' + userDeleteName + '\n   Date: ' + formatActionDateTime+ ' \n \n';
        }
           
        //Set the email properties
        mail.setToAddresses(sendToAddress);
        mail.setSubject('Client Delete Alert');
        mail.setSenderDisplayName('Client Delete Alert');
        mail.setPlainTExtBody(emailBody); 
        mail.setBccSender(false);
        mail.setUseSignature(false);
        mail.setSaveAsActivity(false);
       
        //Send the email  
          Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
    }
}