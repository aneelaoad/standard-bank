@isTest
private class StdBank_Ltn_SendEmail_Test {

	@isTest static void sendEmail() {
        User thisUser =  [SELECT Id FROM User WHERE Id = :UserInfo.getUserId() ];
        System.runAs (thisUser) {
			//
			// Prepare test data
			//
			EmailTemplate emailTemplate = new EmailTemplate(
					isActive = true,
					developerName = 'test_unit_test', 
					FolderId = UserInfo.getUserId(), 
					TemplateType= 'text', 
					Name = 'test'
			);
			insert emailTemplate;

			fflib_SObjectUnitOfWork uow = ABS_ObjectBuilderBase.getNewUnitOfWork();
	        BLD_Account accBuilder = new BLD_Account(uow).useGroupParent()
				.name('Standard Bank Employees');
			Account acc = (Account) accBuilder.getRecord();

	        BLD_Contact conBuilder = new BLD_Contact(uow).useBankContact()
				.account(accBuilder);
			Contact con = (Contact) conBuilder.getRecord();

			uow.commitWork();

			StdBank_Ltn_SendEmail.FromAddress[] fromAddresses = StdBank_Ltn_SendEmail.getFromAddresses();
			String orgWideEmailAddressId = fromAddresses[fromAddresses.size() - 1].orgWideEmailAddressId;
			StdBank_Ltn_SendEmail.getSuggestions(con.FirstName);
			StdBank_Ltn_SendEmail.getUserAddress();
			StdBank_Ltn_SendEmail.sendEmail(
					orgWideEmailAddressId, 
					new String[] { 'mdvecko@deloittece.com' },
					new String[] {},
					new String[] {},
					'Test',
					acc.Id,
					emailTemplate.Id,
					new String[] { 'test.txt' },
					new String[] { 'text/plain' },
					new String[] { 'abcd' }
			);
            StdBank_Ltn_SendEmail.EmailTemplate template =
                    StdBank_Ltn_SendEmail.renderEmailTemplate(emailTemplate.Id, null, acc.Id);
            System.assertNotEquals(null, template);
		}
	}
}