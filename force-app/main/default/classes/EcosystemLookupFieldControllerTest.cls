/**
 * Created by Chibuye Kunda on 2019/08/12.
 */

@IsTest
private with sharing class EcosystemLookupFieldControllerTest {

    /**this variable will hold the CommB user variable
     */
    private static final String M_COMMB_USERNAME = 'commb_user@standardbank.co.za';

    /**this is the Group number
     */
    private static final String M_GROUP_NUMBER = '12345';

    /**this will hold the name of our parent client
     */
    private static final String M_PARENT_CLIENT_NAME = 'Parent Account';

    /**this will hold a list of account names for unbanked entities
     */
    private static final List< String > M_UNBANKED_CLIENT_NAMES = new List< String >{ 'alpha', 'beta', 'charlie' };

    /**this will hold a list of account names for banked entities
     */
    private static final List< String > M_BANKED_CLIENT_NAMES = new List< String >{ 'delta', 'echo', 'foxtrot' };


    /**this will hold commB user object
     */
    private static User m_commb_user{

        get{
            //only query if variable is null
            if( m_commb_user == null )
                //only interested in user SF ID
                m_commb_user = [ SELECT Id
                                 FROM User
                                 WHERE Username =: M_COMMB_USERNAME ];

            return m_commb_user;

        }

        set{}

    }


    /**this will hold ecosystem record
     */
    private static Ecosystem__c m_ecosystem{

        get{
            //only query if variable is null
            if( m_ecosystem == null )
                //only interested in record SF ID
                m_ecosystem = [ SELECT Id
                                FROM Ecosystem__c
                                WHERE Relationship_Group_Number__c =: M_GROUP_NUMBER ];

            return m_ecosystem;

        }

        set{}

    }


    /**this will hold the parent account record
     */
    private static Account m_parent_client{

        get{
            //only query if variable is null
            if( m_parent_client == null )
                //only interested in record SF ID
                m_parent_client = [ SELECT Id
                                    FROM Account
                                    WHERE Name =: M_PARENT_CLIENT_NAME ];

            return m_parent_client;

        }

        set{}

    }


    /**this function will setup our test data
     */
    @TestSetup
    private static void createTestData(){

        new BLD_USER( m_commb_username ).useCommB().commitWork();           //create commB user

        //run as commB user
        System.runAs( m_commb_user ){

            createEcosystem();
            createAccounts( true );                 //these accounts will be used to create banked entities
            createAccounts( false );                //these accounts will be used to create unbanked entities
            updateBankedClientStatus();                        //update the banked client status to CIF Allocated
            createEntities();

        }

    }





    /**this function will test search for banked clients
     */
    @IsTest
    private static void testFindMatchingBankedAccounts(){

        String target_account_name = M_BANKED_CLIENT_NAMES[ M_BANKED_CLIENT_NAMES.size()-1 ];       //get the last element( this has no related entity )
        List< Account > matching_accounts;

        //test for client record that doesnt have entoty and search on name
        System.runAs( m_commb_user ){
            matching_accounts = EcosystemLookupFieldController.findMatchingBankedAccounts( target_account_name.substring( 0, 2 ), m_ecosystem.Id );
        }

        //test for client record that doesnt have entity and search on CIF ---> only one record is returned
        System.runAs( m_commb_user ){
            matching_accounts = EcosystemLookupFieldController.findMatchingBankedAccounts( '12', m_ecosystem.Id );
        }

        target_account_name = M_BANKED_CLIENT_NAMES[0];                             //get first element( this has a related entity so no records expected )

        //test for client that has entity attached to it
        System.runAs( m_commb_user ){
            matching_accounts = EcosystemLookupFieldController.findMatchingBankedAccounts( target_account_name.substring( 0, 2 ), m_ecosystem.Id );
        }

    }




    /** this function will test search for unbanked clients
     */
    @IsTest
    private static void testFindMatchingUnbankedAccounts(){

        String target_account_name = M_UNBANKED_CLIENT_NAMES[ M_UNBANKED_CLIENT_NAMES.size()-1 ];               //get the last element( this has no related entity )
        List< Account > matching_accounts;

        //test for client record that doesnt have entity ---> only one record is returned
        System.runAs( m_commb_user ) {
            matching_accounts = EcosystemLookupFieldController.findMatchingUnbankedAccounts( target_account_name.substring(0, 2), m_ecosystem.Id );
        }

        target_account_name = M_UNBANKED_CLIENT_NAMES[0];                   //get first element( this has a related entity so no records expected )

        //test for client record that has entity ---> no records should be returned
        System.runAs( m_commb_user ){
            matching_accounts = EcosystemLookupFieldController.findMatchingUnbankedAccounts( target_account_name.substring( 0, 2 ), m_ecosystem.Id );
        }

    }





    /**this function will create an ecosystem along with a parent client for that
     * ecosystem
     */
    private static void createEcosystem(){

        fflib_SObjectUnitOfWork unit_of_work = ABS_ObjectBuilderBase.getNewUnitOfWork();

        new BLD_Ecosystem( unit_of_work ).groupNumber( M_GROUP_NUMBER );
        new BLD_Account( unit_of_work ).name( M_PARENT_CLIENT_NAME ).groupNumber( M_GROUP_NUMBER ).useCommB().useGroupParent();

        unit_of_work.commitWork();

    }





    /**this function will create a banked account records for banked entity
     * @param is_bankedP if true will indicate that the clients we are creating banked records
     */
    private static void createAccounts( Boolean is_bankedP ){

        fflib_SObjectUnitOfWork unit_of_work = ABS_ObjectBuilderBase.getNewUnitOfWork();
        List< String >client_names = ( is_bankedP )? M_BANKED_CLIENT_NAMES:M_UNBANKED_CLIENT_NAMES;
        BLD_Account new_account;
        Integer count = 0;

        //loop through the client names list and create record
        for( String current_name : client_names ){

            new_account = new BLD_Account( unit_of_work );

            new_account.setField( Account.Name, current_name )
                       .setField( Account.Primary_Relationship_Holder__c, 'Commercial Banking' )
                       .setField( Account.OwnerId, m_commb_user.Id );

            //check if we creating banked
            if( is_bankedP ){

                new_account.setField( Account.Status__c, 'CIF Allocated' );
                new_account.setField( Account.CIF__c, '1234' + count );

                ++count;

            }
            else
                new_account.setField( Account.Status__c, 'Prospect' );

        }

        unit_of_work.commitWork();

    }





    /**this function will update the status picklist for banked clients
     */
    private static void updateBankedClientStatus(){

        List< Account > accounts_to_update = [ SELECT Status__c
                                               FROM Account
                                               WHERE CIF__c != null ];

        //loop through the list and update the status
        for( Integer i=0; i<accounts_to_update.size(); ++i )
            accounts_to_update[i].Status__c = 'CIF Allocated';

        update accounts_to_update;

    }




    /**this function will create some ecosystem entities
     */
    private static void createEntities(){

        fflib_SObjectUnitOfWork unit_of_work = ABS_ObjectBuilderBase.getNewUnitOfWork();
        List< Account > banked_clients = getClientRecords( true );           //this list of clients will be used to created banked entity
        List< Account > unbanked_clients = getClientRecords( false );              //this list of clients will be used to create unbanked entity

        BLD_EcosystemEntity new_entity;

        //create banked entities
        for( Integer i=0; i<banked_clients.size()-1; ++i )
            new_entity = new BLD_EcosystemEntity( unit_of_work ).ecosystem( m_ecosystem.Id )
                                                                .client( banked_clients[i].Id )
                                                                .entityType( DMN_Ecosystem.SHAREHOLDER_DIRECTOR );

        //create unbanked entities
        for( Integer i=0; i<unbanked_clients.size()-1; ++i )
            new_entity = new BLD_EcosystemEntity( unit_of_work ).ecosystem( m_ecosystem.Id )
                                                                .client( unbanked_clients[i].Id )
                                                                .entityType( DMN_Ecosystem.SHAREHOLDER_DIRECTOR );

        unit_of_work.commitWork();

    }





    /**this function will select appropriate records
     * @param is_bankedP if true we are selecting records with CIF
     * @return list of account records
     */
    private static List< Account > getClientRecords( Boolean is_bankedP ){

        String account_query = 'SELECT Id, Name FROM Account WHERE ';

        //check if cif is null
        if( is_bankedP )
            account_query += 'CIF__c LIKE \'12%\'';         //we want records with CIF numbers
        else
            account_query += 'Status__c = \'Prospect\' AND CIF__c = null';

        return Database.query( account_query );

    }





    /**this function will return map with banked and unbanked client set
     * @return map of set values which hold variables
     */
    private static Map< String, Set< String > > getRecordsWithEntities(){

        Map< String, Set< String > > return_map = new Map< String, Set< String > >();
        return_map.put( 'banked', new Set< String >() );                //add set for banked clients
        return_map.put( 'unbanked', new Set< String >() );              //add set for unbanked clients


        List< Account > account_list = [ SELECT Name
                                         FROM Account
                                         WHERE ( CIF__c LIKE '12%' ) AND
                                               Id IN( SELECT Entity__c FROM Ecosystem_Entity__c WHERE Ecosystem__c =: m_ecosystem.Id ) ];


        for( Account current_account : account_list )
            return_map.get( 'banked' ).add( current_account.Name );


        account_list = [ SELECT Name
                         FROM Account
                         WHERE ( Status__c = 'Prospect' ) AND ( CIF__c = null ) AND
                         Id IN( SELECT Entity__c FROM Ecosystem_Entity__c WHERE Ecosystem__c =: m_ecosystem.Id ) ];


        for( Account current_account : account_list )
            return_map.get( 'unbanked' ).add( current_account.Name );

        return return_map;

    }

}