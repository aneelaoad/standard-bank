/*****************************************************************************************************\
    @ Author        : Rudolf Niehaus
    @ Date          : 14 December 2010
    @ Test File     : None - Test Method in this class
    @ Description   : This is a generic Exception handeling class with methods to handle all Apex Exceptions:
    @ Last Modified By  : Rudolf Niehaus 
    @ Last Modified On  : 14/12/2010
    @ Modification Description : Add the method onErrorSendEMail()
    							The method will send an Email when called from an Apex class or Trigger.
    							It takes 4 Arguments:
    							1. String senderDisplayName: The name that will be displayed in the From section of th email
    							2. String toAddresses: The recipient list you would liketo send the email to
    							3. String subject: The subject of the email
    							4. String body: The plain text body of the email
******************************************************************************************************/
public class SA_ExceptionHandlerClass {
	
	public static boolean onErrorSendEMail(String senderDisplayName, String toAddresses, String subject, String body){

		Messaging.Singleemailmessage mail = new Messaging.Singleemailmessage();
		String[] sendToAddresses = new String[] {toAddresses};
		mail.setToAddresses(sendToAddresses);
		mail.setSenderDisplayName(senderDisplayName);
		mail.setSubject(subject);
		mail.setPlainTextBody(body);
		try{
			Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
			return true;
		}catch(EmailException e){
			System.debug('An Email Exception was thrown when trying to send an on Error email from the Class SA_ExceptionHandlerClass ' + e.getMessage());
			return false;
		}
	}
	
	//############### TEST METHODS ########################
    public static testMethod void testMe(){
    	//TEST THE METHOD "onErrorSendEMail()"
    	//Positive test
    	boolean fOk = SA_ExceptionHandlerClass.onErrorSendEMail('TEST THE METHOD','test@test.com','This is a test email','The boby of the test email');
    	System.assertEquals(fOk, true);
    	//Negative test
    	fOk = SA_ExceptionHandlerClass.onErrorSendEMail('TEST THE METHOD','','','');
    	System.assertNotEquals(fOk, true);
    }
	
}