/***
@ Func Area     	:  Commercial Banking
@ Author        	:  Chibuye Kunda
@ Date          	:  15/05/2019
@User Story    	    :  US-3812
@description 	    :  This is the QuicklinksPage.cmp controller
***/
/***
@LastModifiedBy     :  Emmanuel Mulea(Nocks)
@Date           	:  18/10/2021
@UserStory    	    :  SFP-7240
@description 	    :  Enabling the Quicklink records to be able to store multiple User Divisions
and fix static code analysis
***/
public with sharing class QuicklinksPageController {

    /** this is the user division
     */
    private static String mUserDivision ='';





    /** this function will return true if the dashboard heading should be shown
     *  @return will return Response object to client
     */
    @AuraEnabled
    public static Boolean shouldShowDashboard(){

        ServerResponse response = getUserDivision();                //get the server response object

        //check if there is an error
        if( response.isError ) {
            return true;                    //just default to true
        }
        return response.resultMessage != 'Commercial Banking';

    }//end of function definition





    /** this function will return map of objects
     * @param componentContextP this is the context of the component
     * @param columnsP is the columns we want, is a string
     * @param isTileP will indicate if we are rendering as tile
     * @return ServerResponse is the response object we are sending back to  client
     */
    @AuraEnabled
    public static ServerResponse getQuickLinksMap( String componentContextP, String columnsP, Boolean isTileP ) {

        ServerResponse response = getUserDivision();                //this will hold the response

        //check if we have an error
        if (response.isError) {
            return response;                    //terminate and return response to the caller
        }
        mUserDivision = response.resultMessage;              //get the user division

        //check if we are rendering on homepage
        if (isTileP) {
            response = getUserQuickLinks('Label_del__c, Icon__c, Link__c, Link_Description__c, Tile_Column_Id__c,Show_for_Division__c', componentContextP, null);
        }else {
            response = getUserQuickLinks('Icon__c, Label_del__c, Link__c, Order__c, Column_Id__c, Show_for_Division__c, Object_Visibility__c', componentContextP,
                    getColumnList(columnsP));
        }
        //check if we have an error
        if( response.isError ) {
            return response;                    //terminate and return response to the caller
        }
        response.quicklinkMap = generateMap( response.quicklinkList, isTileP );          //generate map

        //clear variables
        response.quicklinkList = null;         //clear the quick links list
        response.resultMessage = '';           //clear the result message

        return response;

    }//end of function definition





    /** this function will generate a QuickLinks map
     *  @param quickLinksListP is the list of quick links we are processing
     *  @param isTileP wil indicate if we are processing a home page link
     * @return will return a map with links
     */
    private static Map< Decimal, List< QuickLinks__c > > generateMap( List< QuickLinks__c > quickLinksListP, Boolean isTileP ){

        Map< Decimal, List< QuickLinks__c > > quickLinksMap = new Map< Decimal, List< QuickLinks__c > >();            //this will hold our quick links list

        //check if we generating the map for our homepage
        if( !isTileP ){

            //loop through the list and add to correct column
            for( QuickLinks__c currentLink : quickLinksListP ){

                //check if the map contains key
                if( quickLinksMap.containsKey( currentLink.Column_Id__c ) ) {
                    quickLinksMap.get(currentLink.Column_Id__c).add(currentLink);           //add to map
                }
                else {
                    quickLinksMap.put(currentLink.Column_Id__c, new List< QuickLinks__c >{
                            currentLink
                    });     //create entry and add
                }
            }//end of for-block

        }
        else{

            //loop through the list and add to correct column
            for( QuickLinks__c currentLink : quickLinksListP ){

                currentLink.Icon__c = currentLink.Icon__c.replace( '#', ':' );          //update value

                //check if current link tile column ID is added
                if( quickLinksMap.containsKey( currentLink.Tile_Column_Id__c ) ) {
                    quickLinksMap.get(currentLink.Tile_Column_Id__c).add(currentLink);          //add the current link
                }
                else {
                    quickLinksMap.put(currentLink.Tile_Column_Id__c, new List< QuickLinks__c >{
                            currentLink
                    });   //create list, add link and add to map
                }
            }//end of for-block

        }//end of if-else block

        return quickLinksMap;             //return the quick links map

    }//end of function definition





    /** this function will select the required quicklinks
     *  @param targetFieldsP is the a string of fields we are querying
     *  @param componentContextP is the component context
     *  @param columnListP is the list of column values that we want
     *  @return will return the list of Quicklinks
     */
    private static ServerResponse getUserQuickLinks( String targetFieldsP, String componentContextP, List< Decimal > columnListP ){

        List< QuickLinks__c > userQuickLinks;                                    //this is the list of user quick links
        List< QuickLinks__c > filteredLinks =  new List<QuickLinks__c>();
        ServerResponse response = new ServerResponse();                            //this is the response object
        String quicklinksQuery = 'SELECT ' + targetFieldsP + ' ' +
                                  'FROM QuickLinks__c ' +
                                  'WHERE Object_Visibility__c LIKE \'%' + componentContextP+ '%\'';

        //check if we have columns to consider
        if( columnListP != null ) {
            quicklinksQuery += ' AND Column_Id__c in :columnListP';           //append the columns being requested
        }
        quicklinksQuery += ' ORDER BY Order__c';

        try{

            userQuickLinks = Database.query( quicklinksQuery );              //execute the query
            for(QuickLinks__c link : userQuickLinks){
                if(String.isNotBlank(link.Show_for_Division__c)) {
                    List<String> showForDivisionList = link.Show_for_Division__c.Split(',');
                    if (showForDivisionList.contains(mUserDivision)) {
                        filteredLinks.add(link);
                    }
                }
            }

        }
        catch(Exception ex ){

            response.isError = true;                                   //indicate we have an error
            response.resultMessage = ex.getMessage();     //store the error message

            return response;                //return the response object

        }//end of try-catch block

        response.quicklinkList = filteredLinks;

        return response;

    }//end of function definition





    /** this function will return the User's division
     *  @return will return ServerResponse object
     */
    private static ServerResponse getUserDivision(){

        ServerResponse response = new ServerResponse();         //this is the server response

        try{

            response.resultMessage = [ SELECT User_Division__c
                                        FROM User
                                        WHERE Id =: UserInfo.getUserId() ][0].User_Division__c;

        }
        catch( QueryException queryException ){

            response.isError = true;               //we have an error
            response.resultMessage = queryException.getMessage();         //store the error message

        }

        return response;

    }//end of function definition





    /** this function will convert the column string to a list of
     *  decimals
     *  @param columnP is the column value
     *  @return will be return list of decimals
     */
    private static List< Decimal > getColumnList( String columnP ){

        List< String > columnStringList;          //this will hold strings after split on , character
        List< Decimal > columnList = new List< Decimal >();

        //check if parameter contains , character
        if( columnP.contains( ',' ) ) {
            columnStringList = columnP.split(',');                  //split on the comma
        }
        else{

            columnStringList = new List< String >();                  //initialise the column string list
            columnStringList.add( columnP );                          //add the column

        }//end of if-else block

        //loop through the string array
        for( String currentString : columnStringList ){

            //check if string is a number
            if( currentString.isNumeric() ) {
                columnList.add(Integer.valueOf(currentString));
            }

        }//end of for-block

        return columnList;                 //return the column list

    }//end of function definition





    /** this class will contain results of operations---> to be sent to
     *  client-side controller
     */
    public class ServerResponse{

        /** this will indicate if we have an error
         */
        @AuraEnabled public Boolean isError{ get; set; }

        /** this will hold the error messasge
         */
        @AuraEnabled public String resultMessage{ get; set; }

        /** this will hold our quicklinks
         */
        @AuraEnabled public List< QuickLinks__c >quicklinkList{ get; set; }

        /** this will hold our map of quicklinks
         */
        @AuraEnabled public Map< Decimal, List< QuickLinks__c > > quicklinkMap{ get; set; }

        /** this is class constructor
         */
        public ServerResponse(){

            //default the class attribute
            this.isError = false;
            this.resultMessage = '';
            this.quicklinkList = null;
            this.quicklinkMap = null;

        }//end of constructor definition

    }//end of class definition

}//end of class definition