/*************************************************************************\
    @ Author        :     Caro Reinecke
    @ Date          :     2010/09
    @ Test File     :     This Class
    @ Description   :     Allows for the Birthday Alerts to be scheduled 
                          
    @ Last Modified By  : Caro Reinecke
    @ Last Modified On  : 20 June 2011  
    @ Last Modified Reason  : Regression - Test was failing due to contact team member records inserted ouside the code block 
                                and test users had no province set.
    
    @ Last Modified By  : Caro Reinecke
    @ Last Modified On  : 15 August 2011
    @ Last Modified Reason  : Regression - New Role Hierarchy Implementation: Replace roles "Oil, Gas & Renewables User" with
                                 "Mining & Metals IBC SA Team" and "CDR Management" with "Compliance"
                                 
    @ Last Modified By  : Caro Reinecke
    @ Last Modified On  : 21 December 2011
    @ Last Modified Reason  : Case#548 Regression Remove redundant fields - Remove Auto Share Functionality
      
    @ Last Modified By  : Wayne Gray
    @ Last Modified On  : June 2012
    @ Last Modified Reason  :  Move test methods into external class  
                               Case #6521- Change contact to use TestFatcory    
                               API Version moved from 19 to 25               
****************************************************************************/ 
global class BirthdayCronJob implements Schedulable{
    // Run the scheduled job at midnight Sept. 3rd. 2022
    public static String CRON_EXP = '0 0 0 3 9 ? 2022';
    
    global void execute(SchedulableContext SC) {
        //Add birthday reminders for contact members 
        /*batchContactTeamBirthdayReminders bTeam = new batchContactTeamBirthdayReminders();
        ID batchprocessid = Database.executeBatch(bTeam);*/
        //Add birthday reminders for contact and client owners
        batchContactClientOwnerBirthdayReminders bOwners = new batchContactClientOwnerBirthdayReminders();
        Id batchprocessid = Database.executeBatch(bOwners);
        //Send birthday email to todays birthday Users
        emailBirthdayUsers e = new emailBirthdayUsers();
        e.sendMail();  
    }
}