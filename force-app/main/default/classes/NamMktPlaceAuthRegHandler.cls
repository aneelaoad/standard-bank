global with sharing class NamMktPlaceAuthRegHandler extends SBN_AuthRegistrationHandler {

    public final static String NO_APPROVED_SELLER = 'Seller_Not_Approved';

    /**
     * TEMP FIX - AuthRegistrationHandlerPing PARENT CLASS NEEDS TO DECLARE METHODS AS VIRTUAL
     * FOR TESTING PURPOSES I'M EXTENDING THE TOP LEVEL CLASS DIRECTLY BUT THIS FOLLOWING BLOCK
     * SHOULD BE REMOVED ONCE THE PACKAGE IS UPDATED!
     */
    // Ping data mapping
    protected final String KEY_CELLPHONE = 'cellphonenumber';
    protected final String KEY_DATE_OF_BIRTH = 'dateofbirth';
    protected final String KEY_FIRST_NAME = 'first_name';
    protected final String KEY_LAST_NAME = 'last_name';
    protected final String KEY_ID = 'id';
    protected final String KEY_SUB = 'email';

    global virtual override UserDataWrapper extractUserData(Auth.UserData userData) {
        UserDataWrapper userDataWrapper = super.extractUserData(userData);

        Map<String, String> attributes = userData.attributeMap;
        userDataWrapper.id = attributes.get(KEY_ID);
        userDataWrapper.firstName = attributes.get(KEY_FIRST_NAME);
        userDataWrapper.lastName = attributes.get(KEY_LAST_NAME);
        userDataWrapper.cellphone = attributes.get(KEY_CELLPHONE);
        userDataWrapper.dateOfBirth = attributes.get(KEY_DATE_OF_BIRTH);

        return userDataWrapper;
    }
     // END TEMP FIX!

    /**
     * @param contact
     * @param userDataWrapper
     *
     * @return
     */
    global override UserAccessCheckResult verifyUserAccessForCreate(Contact contact, UserDataWrapper userDataWrapper) {
        return checkContactHasApprovedSeller(contact);
    }

    global override UserAccessCheckResult verifyUserAccessForUpdate(Contact contact) {
        return checkContactHasApprovedSeller(contact);
    }

    /**
     * Overriding here to add condition of record type
     *
     * @param userId User ID if existing user found on creation or update, this parameter
     * might be <code>null</code> and is not used by the default implementation. If planning to use this
     * then implementers should check for <code>null</code> and handle accordingly.
     * @param userDataWrapper User data extracted from the SSO provider
     */
    global override Contact findContactForUser(Id userId, UserDataWrapper userDataWrapper) {
        String email = userDataWrapper.email;
        String pingId = userDataWrapper.id;

        List<Contact> contacts = [
                SELECT Id, FirstName, LastName
                FROM Contact
                WHERE (Email = :email OR Ping_Id__c = :pingId)
                AND RecordType.DeveloperName = 'IndustriesBusiness'
        ];

        if (!contacts.isEmpty()) {
            return contacts.get(0);
        }
        return null;
    }

    global override void prepareUserData(User user, UserDataWrapper userResponseWrapper) {
        super.prepareUserData(user, userResponseWrapper);

        /*
        Hard coding Namibian Dollar. Eventually we might need to make this more dynamic
        although for now and the near future it will only ever be NAD. We will need to do
        many other changes to go multi-country.
         */
        user.CurrencyIsoCode = 'NAD';
    }

    private UserAccessCheckResult checkContactHasApprovedSeller(Contact contact) {
        // re-fetch with necessary fields
        Contact reFetchedContact = [SELECT AccountId FROM Contact WHERE Id = :contact.Id LIMIT 1];

        AggregateResult[] result = [
                SELECT COUNT(Id) cnt
                FROM Atonit_Mktplace__Seller__c
                WHERE Atonit_Mktplace__Account__c = :reFetchedContact.AccountId
                AND Atonit_Mktplace__Status__c = 'Approved'
        ];

        Integer count = (Integer) result[0].get('cnt');

        if (count == 0) {
            return userAccessCheckFailure(NO_APPROVED_SELLER, contact.Id);
        }
        return userAccessCheckSuccess();
    }

    public override void performAdditionalUserUpdates(User user, Contact contact) {
    }
}