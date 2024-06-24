@IsTest
private class SBN_AuthRegistrationHandlerTest {

    private final static String KEY_NETWORK = SBN_AuthRegistrationHandler.KEY_NETWORK;

    private final static Id TEST_NETWORK_ID = '000000000000000000';

    @IsTest
    static void createUser() {
        //setup: create handler
        SBN_AuthRegistrationHandler authRegistrationHandler = new MockRegistrationHandler();

        //and: create contact
        insert new Contact(
                LastName = 'White',
                Email = 'ww@gmail.com'
        );

        //and: setup profile
        setupMockProfile(authRegistrationHandler);

        //given: User auth data object
        String identifier = '12345';
        String firstName = 'Walter';
        String lastName = 'White';
        String email = 'ww@gmail.com';

        Map<String, String> attributes = new Map<String, String> {KEY_NETWORK => TEST_NETWORK_ID};

        Auth.UserData userData = new Auth.UserData(identifier, firstName, lastName, null, email,
                null, null, null, null, null, attributes);

        // when: creating a new
        User userResult = authRegistrationHandler.createUser(TEST_NETWORK_ID, userData);

        // then: expect a user to be created
        System.assertNotEquals(null, userResult);

        System.assertEquals(firstName, userResult.FirstName);
        System.assertEquals(lastName, userResult.LastName);
        System.assertEquals(email, userResult.Email);
        System.assertEquals(email, userResult.Username);
        System.assertEquals('wwhite', userResult.Alias);
    }

    @IsTest
    static void updateUser() {
        //setup: create handler
        SBN_AuthRegistrationHandler authRegistrationHandler = new MockRegistrationHandler();

        //and: create contact
        insert new Contact(
                LastName = 'White',
                Email = 'ww@gmail.com'
        );

        //and: setup profile
        setupMockProfile(authRegistrationHandler);

        //given: User auth data object
        String identifier = '12345';
        String firstName = 'Steve';
        String lastName = 'Smith';
        String email = 'ww@gmail.com';

        Map<String, String> attributes = new Map<String, String> {KEY_NETWORK => TEST_NETWORK_ID};

        Auth.UserData userData = new Auth.UserData(identifier, firstName, lastName, null, email,
                null, null, null, null, null, attributes);

        // when: updating a user
        String userId = UserInfo.getUserId();
        authRegistrationHandler.updateUser(userId, TEST_NETWORK_ID, userData);

        User userResult = [SELECT FirstName, LastName, Email FROM User WHERE Id = :userId];

        // then: expect a user
        System.assertNotEquals(null, userResult);

        System.assertEquals(firstName, userResult.FirstName);
        System.assertEquals(lastName, userResult.LastName);
        System.assertEquals(email, userResult.Email);
    }

    @IsTest
    static void createUserContactNotFound() {
        //setup: create handler
        SBN_AuthRegistrationHandler authRegistrationHandler = new MockRegistrationHandler();

        //and: dummy auth data
        Auth.UserData userData = getDummyAuthData();

        // given: no contact created
        // when: creating user
        try {
            authRegistrationHandler.createUser(TEST_NETWORK_ID, userData);

            System.assert(false, 'Should have failed!');

            // then: should fail with exception
        } catch (Auth.AuthProviderPluginException e) {
            System.assertEquals(authRegistrationHandler.CONTACT_NOT_FOUND, e.getMessage());
        }
    }

    private static Auth.UserData getDummyAuthData() {
        return new Auth.UserData('test', 'test', 'test', null, 'test@test.com',
                null, null, null, null, null, new Map<String, String>{});
    }

    @IsTest
    static void extractUserData() {
        SBN_AuthRegistrationHandler authRegistrationHandler = new MockRegistrationHandler();

        //given: User auth data object

        String identifier = '12345';
        String firstName = 'Walter';
        String lastName = 'White';
        String email = 'ww@gmail.com';
        String network = 'myNetwork';
        Map<String, String> attributes = new Map<String, String> {KEY_NETWORK => network};

        Auth.UserData userData = new Auth.UserData(identifier, firstName, lastName, null, email,
                null, null, null, null, null, attributes);

        //when: extracting user data
        SBN_AuthRegistrationHandler.UserDataWrapper userDataWrapper = authRegistrationHandler.extractUserData(userData);

        //then: expect wrapper object with matching values

        System.assertEquals(identifier, userDataWrapper.id);
        System.assertEquals(firstName, userDataWrapper.firstName);
        System.assertEquals(lastName, userDataWrapper.lastName);
        System.assertEquals(email, userDataWrapper.email);
        System.assertEquals(network, userDataWrapper.networkId);

    }

    @IsTest
    static void findContactForUserFound() {
        SBN_AuthRegistrationHandler authRegistrationHandler = new MockRegistrationHandler();

        //setup: create a user

        String firstName = 'Steve';
        String lastName = 'Jones';
        String email = 'steve.jones@gmail.com';
        Contact contact = new Contact(
                FirstName = firstName, LastName = lastName, Email = email
        );
        insert contact;

        //given: user data received
        SBN_AuthRegistrationHandler.UserDataWrapper userDataWrapper = new SBN_AuthRegistrationHandler.UserDataWrapper();
        userDataWrapper.email = email;

        //when: searching for a contact by user data
        Contact foundContact = authRegistrationHandler.findContactForUser(null, userDataWrapper);

        //then: expect to find a user with matching email

        System.assertNotEquals(null, foundContact);

        // re-fetching for test purposes
        Contact reFetchedContact = [SELECT FirstName, LastName, Email FROM Contact WHERE Id = :foundContact.Id];

        System.assertEquals(reFetchedContact.FirstName, firstName);
        System.assertEquals(reFetchedContact.LastName, lastName);
        System.assertEquals(reFetchedContact.Email, email);
    }

    @IsTest
    static void findContactForUserNotFound() {
        SBN_AuthRegistrationHandler authRegistrationHandler = new MockRegistrationHandler();

        //given: user data received
        SBN_AuthRegistrationHandler.UserDataWrapper userDataWrapper = new SBN_AuthRegistrationHandler.UserDataWrapper();
        userDataWrapper.email = 'test@test.com';

        //when: searching for a contact by user data
        Contact foundContact = authRegistrationHandler.findContactForUser(null, userDataWrapper);

        //then: expect user to be not found

        System.assertEquals(null, foundContact);
    }

    @IsTest
    static void findProfileForUserFound() {
        SBN_AuthRegistrationHandler authRegistrationHandler = new MockRegistrationHandler();

        //setup: create and inject test metadata

        // find any profile
        String profile = setupMockProfile(authRegistrationHandler);

        //given: user data received for a specific network
        SBN_AuthRegistrationHandler.UserDataWrapper userDataWrapper = new SBN_AuthRegistrationHandler.UserDataWrapper();
        userDataWrapper.networkId = TEST_NETWORK_ID;

        //when: finding profile for user
        Id profileId = authRegistrationHandler.findProfileForUser(null, userDataWrapper);

        //then: expect to find the configured profile from metadata

        System.assertNotEquals(null, profileId);

        Profile reFetchedProfile = [SELECT Id, Name FROM Profile WHERE Id = :profileId];

        System.assertEquals(profile, reFetchedProfile.Name);

    }

    private static String setupMockProfile(SBN_AuthRegistrationHandler authRegistrationHandler) {
        String profile = [SELECT Name FROM Profile LIMIT 1].Name;

        Ping_Registration_Site__mdt pingRegistrationSite = new Ping_Registration_Site__mdt();
        pingRegistrationSite.Network_Id__c = TEST_NETWORK_ID;
        pingRegistrationSite.Profile__c = profile;

        authRegistrationHandler.pingRegistrationSiteTestData = pingRegistrationSite;
        return profile;
    }

    @IsTest
    static void findProfileForUserNotFound() {
        SBN_AuthRegistrationHandler authRegistrationHandler = new MockRegistrationHandler();

        //setup: create and inject test metadata
        // just setting an empty one should be enough for the test
        authRegistrationHandler.pingRegistrationSiteTestData = new Ping_Registration_Site__mdt();

        //given: user data received for a specific network
        SBN_AuthRegistrationHandler.UserDataWrapper userDataWrapper = new SBN_AuthRegistrationHandler.UserDataWrapper();
        userDataWrapper.networkId = TEST_NETWORK_ID;

        //when: finding profile for user
        try {
            Id profileId = authRegistrationHandler.findProfileForUser(null, userDataWrapper);

            System.assert(false, 'Exception should have been thrown!');
            //then: expect an exception to be thrown
        } catch (Auth.AuthProviderPluginException e) {
            System.assert(true);
        }
    }

    @IsTest
    static void buildAliasTest() {
        SBN_AuthRegistrationHandler authRegistrationHandler = new MockRegistrationHandler();

        String [] sampleData = new String []{
                //    'first name | last name | expected alias',
                'Bob        | Jones     | bjones',
                '           | Jones     | jones',
                'Arthur     | Moonlight | amoonlig',
                'Augustine  | Smith     | asmith'
        };

        Integer iteration = 1;
        for (String dataLine : sampleData) {
            String [] parsedLine = dataLine.replaceAll('\\s', '').split('\\|');
            String firstName = String.isEmpty(parsedLine[0]) ? null : parsedLine[0];
            String lastName = parsedLine[1];
            String expected = parsedLine[2];

            String result = authRegistrationHandler.buildAlias(firstName, lastName);

            System.assertEquals(expected, result, 'Failed on iteration #' + iteration);

            iteration++;
        }
    }

    @IsTest
    static void prepareUserDataTest() {
        SBN_AuthRegistrationHandler authRegistrationHandler = new MockRegistrationHandler();

        //given: user response data

        SBN_AuthRegistrationHandler.UserDataWrapper userDataWrapper = new SBN_AuthRegistrationHandler.UserDataWrapper();
        userDataWrapper.firstName = 'John';
        userDataWrapper.lastName = 'Smith';
        userDataWrapper.email = 'john.smith@test.com';

        //and: a User object

        User user = new User();

        //when: preparing user data
        authRegistrationHandler.prepareUserData(user, userDataWrapper);

        //then: expect fields to be populated
        //and: alias and username to be correct
        System.assertEquals(userDataWrapper.firstName, user.FirstName);
        System.assertEquals(userDataWrapper.lastName, user.LastName);
        System.assertEquals(userDataWrapper.email, user.Email);
        System.assertEquals('jsmith', user.Alias);
        System.assertEquals('john.smith@test.com', user.Username);

    }

    class MockRegistrationHandler extends SBN_AuthRegistrationHandler {

        final Boolean success;
        final String errorMessage;
        final Boolean unexpectedError;

        MockRegistrationHandler() {
            this.success = true;
            this.unexpectedError = false;
        }

        MockRegistrationHandler(Boolean success, String errorMessage) {
            this.success = success;
            this.errorMessage = errorMessage;
            this.unexpectedError = false;
        }

        MockRegistrationHandler(Boolean success, String errorMessage, Boolean unexpectedError) {
            this.success = success;
            this.errorMessage = errorMessage;
            this.unexpectedError = unexpectedError;
        }

        public override SBN_AuthRegistrationHandler.UserAccessCheckResult verifyUserAccessForCreate(Contact contact, SBN_AuthRegistrationHandler.UserDataWrapper userDataWrapper) {
            if (unexpectedError) {
                String dummyString = null;
                // intentional NullPointerException
                dummyString.substring(0);
            }
            if (success && !unexpectedError) {
                return userAccessCheckSuccess();
            }
            return null;
        }

        public override SBN_AuthRegistrationHandler.UserAccessCheckResult verifyUserAccessForUpdate(Contact contact) {
            return userAccessCheckSuccess();
        }


        public override void performAdditionalUserUpdates(User user, Contact contact) {
        }
    }
}