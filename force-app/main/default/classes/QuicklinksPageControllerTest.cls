/***
  	@ Func Area     	:  Commercial Banking
  	@ Author        	:  Chibuye Kunda
  	@ Date          	:  15/05/2019
  	@User Story    	    :  US-3812
  	@description 	    :  This is class is testing the QuicklinksPageController methods
  	***/
@IsTest
public with sharing class QuicklinksPageControllerTest{

    private static final String M_COMMB_USERNAME = 'commB@sommB.com';
    @SuppressWarnings('PMD.EmptyStatementBlock')
    private static User mCommbUser {
        get{
            if( mCommbUser == null ) {
                mCommbUser = [ SELECT Id
                FROM User
                WHERE Username =:M_COMMB_USERNAME
                ];
            }
            return mCommbUser;

        }
        set{}
    }

    @TestSetup
    private static void setup(){
        new BLD_USER(M_COMMB_USERNAME).useCommB().commitWork();
    }

    @IsTest
    private static void testShowDashboard(){
        Boolean result;
        System.runAs(mCommbUser){
            result = QuicklinksPageController.shouldShowDashboard();
        }
        System.assertEquals( result, false );

    }

    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    @IsTest
    private static void testGetQuickLinksMap(){
        QuicklinksPageController.ServerResponse response;
        Boolean isTiles;
        createQuickLinksCustomSetting();
        System.runAs(mCommbUser){
            isTiles = true;
            response = QuicklinksPageController.getQuickLinksMap( 'Homepage', '', isTiles );

        }
        inspectResultMap( response.quicklinkMap, isTiles );                     //inspect Map
        System.runAs(mCommbUser){
            isTiles = false;
            response = QuicklinksPageController.getQuickLinksMap( 'Homepage', '1,2', isTiles );
        }
        inspectResultMap( response.quicklinkMap, isTiles );
        System.runAs(mCommbUser){
            isTiles = false;
            response = QuicklinksPageController.getQuickLinksMap( 'Homepage', '1', isTiles );
        }
        inspectResultMap( response.quicklinkMap, isTiles );
    }

    /** this function will inspect the returned map, it will compare each key with
     *  either the Column_Id__c or Tile_Column_Id__c, these values must match the given key
     *  @param targetMapP is the map that we will inspect
     *  @param isTileP will determine with we should compare Tile_Column_Id__c( true ) or Column_Id__c( false )
     */
    private static void inspectResultMap( Map< Decimal, List< QuickLinks__c > > targetMapP, Boolean isTileP ){

        List< QuickLinks__c > quickLinkList;              //this will hold the quick link list

        //loop through the map and check vaues
        for( Decimal currentKey : targetMapP.keySet() ){

            quickLinkList = targetMapP.get( currentKey );               //get the current key

            //loop through the lists and check values
            for( QuickLinks__c currentQuickLinks : quickLinkList ){

                //check if we are checking tile ID
                if( isTileP ) {
                    System.assertEquals( currentQuickLinks.Tile_Column_Id__c, currentKey );
                }
                else {
                    System.assertEquals( currentQuickLinks.Column_Id__c, currentKey );
                }
            }
        }
    }

    /** this function will create QuickLinks__c custom settings
     */
    private static void createQuickLinksCustomSetting(){

        insert new QuickLinks__c( Name='test 1', Column_Id__c=1, Icon__c='test icon 1', Label_del__c='test label 1',
                                            Link__c='www.test1.com', Link_Description__c='in column 1',
                                            Object_Visibility__c='Homepage', Open_In_New_Window__c=true, Order__c=2,
                                            Show_for_Division__c='Commercial Banking', Tile_Column_Id__c=1 );

        insert new QuickLinks__c( Name='test 2', Column_Id__c=1, Icon__c='test icon 1', Label_del__c='test label 1',
                                            Link__c='www.test1.com', Link_Description__c='in column 1',
                                            Object_Visibility__c='Homepage', Open_In_New_Window__c=true, Order__c=2,
                                            Show_for_Division__c='Commercial Banking', Tile_Column_Id__c=1 );

        insert new QuickLinks__c( Name='test 3', Column_Id__c=2, Icon__c='test icon 1', Label_del__c='test label 1',
                                            Link__c='www.test1.com', Link_Description__c='in column 2',
                                            Object_Visibility__c='Homepage', Open_In_New_Window__c=true, Order__c=2,
                                            Show_for_Division__c='Commercial Banking', Tile_Column_Id__c=2 );

        insert new QuickLinks__c( Name='Test 4', Column_Id__c=2, Icon__c='test icon 1', Label_del__c='test label 1',
                                            Link__c='www.test1.com', Link_Description__c='in column 2',
                                            Object_Visibility__c='Homepage', Open_In_New_Window__c=true, Order__c=2,
                                            Show_for_Division__c='Commercial Banking', Tile_Column_Id__c=2 );

    }

}