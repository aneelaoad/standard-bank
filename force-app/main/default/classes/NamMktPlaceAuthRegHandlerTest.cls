@IsTest
public class NamMktPlaceAuthRegHandlerTest {
    @IsTest
    public static void verifyAccessSuccess() {

        // setup: create seller/account/contact data
        Atonit_Mktplace__Seller__c seller = NamMktPlaceTestDataFactory.createSeller();

        Contact contact = createSampleContactForSeller(seller);

        NamMktPlaceTestDataFactory.createBasicCommissionRule(seller);

        seller.Atonit_Mktplace__Status__c = 'Approved';

        update seller;

        // when: checking for access
        NamMktPlaceAuthRegHandler regHandler = new NamMktPlaceAuthRegHandler();

        SBN_AuthRegistrationHandler.UserAccessCheckResult result = regHandler.verifyUserAccessForCreate(contact, null);

        // then: should get a successful result
        System.assert(result.success, 'Registration should have been successful but it was not');
    }

    @IsTest
    static void verifyAccessFailNotApproved() {

        // setup: create seller/account/contact data

        Atonit_Mktplace__Seller__c seller = NamMktPlaceTestDataFactory.createSeller();

        Contact contact = createSampleContactForSeller(seller);

        seller.Atonit_Mktplace__Status__c = 'Draft';

        update seller;

        // when: checking for access
        NamMktPlaceAuthRegHandler regHandler = new NamMktPlaceAuthRegHandler();

        SBN_AuthRegistrationHandler.UserAccessCheckResult result = regHandler.verifyUserAccessForCreate(contact, null);

        // then: should fail with seller not approved message
        System.assert(!result.success, 'Registration should have failed');
        System.assert(result.errorMessage.startsWith(NamMktPlaceAuthRegHandler.NO_APPROVED_SELLER), 'incorrect error message, expected: ' + NamMktPlaceAuthRegHandler.NO_APPROVED_SELLER);
    }

    @IsTest
    static void prepareUserDataTest() {
        SBN_AuthRegistrationHandler authRegistrationHandler = new NamMktPlaceAuthRegHandler();

        //given: user response data

        SBN_AuthRegistrationHandler.UserDataWrapper userDataWrapper = new SBN_AuthRegistrationHandler.UserDataWrapper();
        userDataWrapper.firstName = 'John';
        userDataWrapper.lastName = 'Smith';
        userDataWrapper.email = 'john.smith@test.com';

        //and: a User object

        User user = new User();

        //when: preparing user data
        authRegistrationHandler.prepareUserData(user, userDataWrapper);

        //then: currency to be NAD
        System.assertEquals('NAD', user.CurrencyIsoCode);
    }


    /**
     * EXTRA TESTS AWAITING PACKAGE - THESE CAN EVENTUALLY BE REMOVED
     */

    private final static String KEY_NETWORK = SBN_AuthRegistrationHandler.KEY_NETWORK;
    private final static String KEY_CELLPHONE = 'cellphonenumber';
    private final static String KEY_DATE_OF_BIRTH = 'dateofbirth';
    private final static String KEY_FIRST_NAME = 'first_name';
    private final static String KEY_LAST_NAME = 'last_name';
    private final static String KEY_ID = 'id';
    private final static String KEY_SUB = 'email';

    @IsTest
    static void extractUserData() {
        // setup: create Ping user data representation
        // Ping most fields come in user data map

        String identifier = '12345';
        String firstName = 'Walter';
        String lastName = 'White';
        String email = 'ww@gmail.com';
        String network = 'myNetwork';
        String cellphone = '1112223333';
        String dateOfBirth = '17/01/1975';
        Map<String, String> attributes = new Map<String, String>{
                KEY_ID => identifier,
                KEY_FIRST_NAME => firstName,
                KEY_LAST_NAME => lastName,
                KEY_CELLPHONE => cellphone,
                KEY_DATE_OF_BIRTH => dateOfBirth,
                KEY_NETWORK => network
        };

        Auth.UserData userData = new Auth.UserData(
                null,
                null,
                null,
                null,
                email,
                null,
                null,
                null,
                null,
                null,
                attributes
        );

        SBN_AuthRegistrationHandler authRegistrationHandlerPing = new NamMktPlaceAuthRegHandler();

        // when: extracting Ping user data

        SBN_AuthRegistrationHandler.UserDataWrapper userDataWrapper = authRegistrationHandlerPing.extractUserData(
                userData
        );

        // then: expect correct wrapper values

        System.assertEquals(identifier, userDataWrapper.id);
        System.assertEquals(firstName, userDataWrapper.firstName);
        System.assertEquals(lastName, userDataWrapper.lastName);
        System.assertEquals(email, userDataWrapper.email);
        System.assertEquals(cellphone, userDataWrapper.cellphone);
        System.assertEquals(dateOfBirth, userDataWrapper.dateOfBirth);
        System.assertEquals(network, userDataWrapper.networkId);
    }

    @IsTest
    static void findContactForUserFound() {
        SBN_AuthRegistrationHandler authRegistrationHandler = new NamMktPlaceAuthRegHandler();

        //setup: create a user

        String firstName = 'Steve';
        String lastName = 'Jones';
        String email = 'steve.jones@gmail.com';
        String pingId = '1234554321';

        Id recordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('IndustriesBusiness').recordTypeId;
        Contact contact = new Contact(
                FirstName = firstName,
                LastName = lastName,
                Email = email,
                Ping_Id__c = pingId,
                RecordTypeId = recordTypeId
        );
        insert contact;

        //given: user data received
        SBN_AuthRegistrationHandler.UserDataWrapper userDataWrapper = new SBN_AuthRegistrationHandler.UserDataWrapper();
        userDataWrapper.id = pingId;

        //when: searching for a contact by user data with Ping ID
        Contact foundContact = authRegistrationHandler.findContactForUser(null, userDataWrapper);

        //then: expect to find a user with matching email

        System.assertNotEquals(null, foundContact);

        // re-fetching for test purposes
        Contact reFetchedContact = [
                SELECT FirstName, LastName, Email
                FROM Contact
                WHERE Id = :foundContact.Id
        ];

        System.assertEquals(reFetchedContact.FirstName, firstName);
        System.assertEquals(reFetchedContact.LastName, lastName);
        System.assertEquals(reFetchedContact.Email, email);
    }

    @IsTest
    static void findContactForUserNotFound() {
        SBN_AuthRegistrationHandler authRegistrationHandler = new NamMktPlaceAuthRegHandler();

        //given: user data received
        SBN_AuthRegistrationHandler.UserDataWrapper userDataWrapper = new SBN_AuthRegistrationHandler.UserDataWrapper();
        userDataWrapper.email = 'test@test.com';

        //when: searching for a contact by user data
        Contact foundContact = authRegistrationHandler.findContactForUser(null, userDataWrapper);

        //then: expect user to be not found

        System.assertEquals(null, foundContact);
    }

    private static Contact createSampleContactForSeller(Atonit_Mktplace__Seller__c seller) {
        Contact contact = new Contact(
                FirstName = 'Bob',
                LastName = 'Jones',
                Email = 'bob@jones.com',
                AccountId = seller.Atonit_Mktplace__Account__c

        );

        insert contact;
        return contact;
    }

//    class MockRegistrationHandler extends NamMktPlaceAuthRegHandler {
//        public override SBN_AuthRegistrationHandler.UserAccessCheckResult verifyUserAccessForCreate(Contact contact, UserDataWrapper userDataWrapper) {
//            return null;
//        }
//
//        public override SBN_AuthRegistrationHandler.UserAccessCheckResult verifyUserAccessForUpdate(Contact contact) {
//            return null;
//        }
//
//        public override void performAdditionalUserUpdates(User user, Contact contact) {
//        }
//    }
}