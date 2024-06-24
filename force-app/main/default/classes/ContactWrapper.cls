/*************************************************************************\
    @ Func Area     : Campaign Members, Contacts and Campaign Hosts 
    @ Author        : Rudolf Niehaus
    @ Date          : 11/2011
    @ Test File     : Test Method in this class : testMe()
    @ Description   : Case#1168
                      Campaign members (Contact) wrapper class to keep track of check box 
                      selection on members (Contacts)  
    @ Last Modified By  : Caro Reinecke
    @ Last Modified On  : 12/04/2012
    @ Modified Reason   : Case 4296 Event Report Enhancements
    
    @ Last Modified By  : Wayne Gray
    @ Last Modified On  : June 2012
    @ Last Modified Reason  :  Move test methods into external class  
                               Case #6521- Change contact to use TestFatcory    
                               API Version moved from 22 to 25               
****************************************************************************/

public class ContactWrapper {
    
    public Boolean checked{ get; set; }
    public Contact con { get; set;}
    public String status {get;set;}
    public String sendMail {get;set;}
 
    public ContactWrapper(){
        con = new Contact();
        checked = false;
        status = 'Invited';
        sendMail = 'Yes';
    }
 
    public ContactWrapper(Contact c){
        con = c;
        checked = false;
        status = 'Invited';
        sendMail = 'Yes';
    }    
}