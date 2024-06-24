/**
   @ Author : Marko Dvečko
   @ Description : Controller for lightning send email functionality
 */
public class StdBank_Ltn_SendEmail {
    /**
     * Container for from addresses
     */
    public class FromAddress {
        @AuraEnabled
        public String orgWideEmailAddressId;
        @AuraEnabled
        public String name;
        @AuraEnabled
        public String email;

        public FromAddress(String orgWideEmailAddressId, String name, String email) {
            this.orgWideEmailAddressId = orgWideEmailAddressId;
            this.name = name;
            this.email = email;
        }
    }

    /**
     * Container for suggestion
     */
    public class Suggestion implements Comparable {
    	@AuraEnabled
    	public String name;
    	@AuraEnabled
    	public String email;
    	@AuraEnabled
    	public String entityType;

    	public Suggestion(String entityType, String name, String email) {
    		this.entityType = entityType;
    		this.name = name;
    		this.email = email;
    	}

    	public Integer compareTo(Object compareto) {
    		Suggestion to = (Suggestion)compareTo;

    		if (this.name == to.name) {
    			return 0;
    		}
    		else if (this.name > to.name) {
    			return 1;
    		}
    		else {
    			return -1;
    		}
    	}
    }

    /**
     * Container for tempalate preview
     */
    public class EmailTemplate {
        @AuraEnabled
        public String subject;
        @AuraEnabled
        public String body;

        public EmailTemplate(String subject, String body) {
            this.subject = subject;
            this.body = body;
        }
    }

	/**
	 * Get contacts that satisfies filter
	 */
	public static Contact[] getContacts(String filter) {
		String likeFilter = filter + '%';
		return [ SELECT Id, Name, Email 
				 FROM Contact 
				 WHERE FirstName LIKE :likeFilter
				 OR LastName LIKE :likeFilter
				 OR Name LIKE :likeFilter
				 OR Email LIKE :likeFilter
                 ORDER BY Name 
                 LIMIT 50 ];
	}

    /**
     * Get users that satisfies filter
     */
    public static User[] getUsers(String filter) {
        String likeFilter = filter + '%';
        return [ SELECT Id, Name, Email 
                 FROM User
                 WHERE FirstName LIKE :likeFilter
                 OR LastName LIKE :likeFilter
                 OR Name LIKE :likeFilter
                 OR Email LIKE :likeFilter
                 ORDER BY Name 
                 LIMIT 50 ];
    }

    /**
     * Get suggestions with users contacts that match filter
     */
    @AuraEnabled
    public static Suggestion[] getSuggestions(String filter) {
    	Suggestion[] result = new List<Suggestion>();
    	Contact[] contacts = getContacts(filter);
    	User[] users = getUsers(filter);

    	for (Contact c : contacts) {
    	 	result.add(new Suggestion('Contact', c.Name, c.Email));
    	}

    	for (User u : users) {
    		result.add(new Suggestion('User', u.Name, u.Email));
    	}

    	result.sort();

    	return result;
    }

    /**
     * Get all possible from addresses
     */
     @AuraEnabled
     public static FromAddress[] getFromAddresses() {
        FromAddress[] result = new List<FromAddress>();
        result.add(new FromAddress(null, UserInfo.getName(), UserInfo.getUserEmail()));
        OrgWideEmailAddress[] addresses = 
            [ SELECT Id, DisplayName, Address
              FROM OrgWideEmailAddress
              ORDER BY DisplayName ];
        for (OrgWideEmailAddress address : addresses) {
            result.add(new FromAddress(address.Id, address.DisplayName, address.Address));
        }
        return result;
     }

	/**
	 * Sends email with all parameters
	 */
	@AuraEnabled
	public static void sendEmail(
			String orgWideEmailAddressId,
			String[] toAddresses, 
			String[] ccAddresses, 
			String[] bccAddresses,
			String subject,
			String objectId,
			String templateId,
            String[] fileNames,
            String[] contentTypes,
			String[] bodies) {
        System.debug('We were here!');
		//
		// Reserve email capacity
		//
		Messaging.reserveSingleEmailCapacity(1);
		//
		// Create message
		//
		Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
		if (String.isNotBlank(orgWideEmailAddressId)) {
			email.setOrgWideEmailAddressId(orgWideEmailAddressId);
		}
		email.setToAddresses(toAddresses);
        email.setCCAddresses(ccAddresses);
		email.setBccAddresses(bccAddresses);
		email.setSubject(subject);
        Messaging.SingleEmailMessage templateEmail = Messaging.renderStoredEmailTemplate(templateId, null, objectId);
        email.setHtmlBody(templateEmail.getHtmlBody());
        email.setPlainTextBody(templateEmail.getPlainTextBody());
        email.setWhatId(objectId);

		//
		// Email attachments
		//
		Messaging.EmailFileAttachment[] emailAttachments = new List<Messaging.EmailFileAttachment>();

        Iterator<String> fileNameIt = fileNames.iterator();
        Iterator<String> contentTypeIt = contentTypes.iterator();
        Iterator<String> bodyIt = bodies.iterator();
        System.debug('We are before loop');
		while (fileNameIt.hasNext() && contentTypeIt.hasNext() && bodyIt.hasNext()) {
            System.debug('We are in the loop!');
			Messaging.EmailFileAttachment emailAttachment = new Messaging.EmailFileAttachment();
			emailAttachment.setBody(EncodingUtil.base64Decode(bodyIt.next()));
			emailAttachment.setContentType(contentTypeIt.next());
			emailAttachment.setFileName(fileNameIt.next());
			emailAttachment.setInline(true);
			emailAttachments.add(emailAttachment);
		}

		email.setFileAttachments(emailAttachments);

		//
		// Send email
		//
		Messaging.sendEmail(new Messaging.Email[] { email });
	}

	/**
	 * Render email template without sending email
	 */
	@AuraEnabled
	public static EmailTemplate renderEmailTemplate(
			String templateId,
			String whoId,
			String whatId) {
		Messaging.SingleEmailMessage email = Messaging.renderStoredEmailTemplate(templateId, whoId, whatId);
        String subject = email.getSubject();
		String htmlBody = email.getHtmlBody();
		if (String.isNotBlank(htmlBody)) {
			return new EmailTemplate(subject, htmlBody);
		}
		return new EmailTemplate(subject, email.getPlainTextBody());
	}

    /**
     * Get current user suggestion
     */
    @AuraEnabled
    public static Suggestion getUserAddress() {
        return new Suggestion('User', UserInfo.getName(), UserInfo.getUserEmail());
    }
}