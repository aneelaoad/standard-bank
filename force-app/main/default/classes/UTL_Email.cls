public without sharing class UTL_Email { 

	//Cache contact for email sending
	private static Contact dummyContact{
										get{
											if(dummyContact == null){

												Contact[] conts = [	SELECT Id
																	FROM Contact 
																	WHERE Email =: DMN_Contact.DUMMY_EMAIL
																	LIMIT 1];
												if(conts.size() == 1){
													dummyContact = conts[0];
												}					
											}
											if(dummyContact == null){
												dummyContact = new Contact(
        																	FirstName = DMN_Contact.DUMMY_FIRSTNAME,
																	        LastName = DMN_Contact.DUMMY_LASTNAME,
																	        Email = DMN_Contact.DUMMY_EMAIL,
																	        RecordTypeId = UTL_RecordType.getRecordTypeId(DMN_Contact.OBJ_NAME,
																	        											  DMN_Contact.RTD_INACTIVE) );
												insert dummyContact;  
											}
											if(dummyContact == null){
												throw new UTL_EmailException('No Dummy Contact in the system');
											}
											return dummyContact; 
										}	
										set;
							}
	public static Messaging.SingleEmailMessage createEmails(Id templateId, Id recordId, Set<String> emails){
		return createEmails(templateId, recordId, emails, dummyContact.Id);
	}

	public static Messaging.SingleEmailMessage createEmails(Id templateId, Id recordId, Id reciverId){
		return createEmails(templateId, recordId, new Set<String>(), reciverId);
	}

	public static Messaging.SingleEmailMessage createEmails(Id templateId, Id recordId, Set<String> emails, Id reciverId){
		
		if(reciverId == null){
			reciverId = dummyContact.Id; 
		}

		if(	reciverId.getSobjectType() != Lead.SobjectType
			&& reciverId.getSobjectType() != User.SobjectType
			&& reciverId.getSobjectType() != Contact.SobjectType){
			throw new UTL_EmailException('Unsupported Id Type "' + String.valueOf(reciverId.getSobjectType()) + '"');
		}

		Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
		if(!emails.isEmpty()){
			String[] adresses = new List<String>(emails);
			email.setToAddresses(adresses); 
		}
        email.setTemplateId(templateId);
        email.setTreatTargetObjectAsRecipient(emails.isEmpty());
        email.setTargetObjectId(reciverId);
        if(User.SobjectType != reciverId.getSobjectType()){
        	email.setWhatId(recordId); 
        }
        email.setSaveAsActivity(false); 
        return email; 
	}

	public static Messaging.SingleEmailMessage createEmails(String subject, String body, String[] emails){
		Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();

		email.setToAddresses(emails);
		email.setHtmlBody(body);
		email.setSubject(subject);

        return email; 
	}

	public class UTL_EmailException extends Exception  {
		
	}
}