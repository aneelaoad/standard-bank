/*****************************************************************************************************\
    @ Func Area     : Opportunities, Products (SB_Product__c) & Draw Down Profile
    @ Author        : Rudolf Niehaus
    @ Date          : 27/06/2012
    @ Test File     : Test Method DrawDownProfile_Vf_Ext_Test
    @ Description   : Case#141
                      This is the controller class for the visualforce page "DrawDownRedirect_Vf".
                      The controller / page redirects a user to the draw down mass edit page when a user clicks
                      on the std edit button.    
    -------------------------------------------------------------------------------------
    @ Func Area         : 
    @ Last Modified By  : 
    @ Last Modified On  : 
    @ Modification Description : Case#
                                
******************************************************************************************************/
public with sharing class DrawDownRedirect_Vf_Ext {	
	private Id drawId;
	private Id prodId;
	private Draw_Down_Profile__c dd;

	//Entry point -> Class constructor 
    public DrawDownRedirect_Vf_Ext(ApexPages.StandardController controller){
    	if(!Test.isRunningTest()){
	    	list<String> addFields = new list<String>();
	    	addFields.add('Product__c');
	    	controller.addFields(addFields);
    	}
    	this.dd = (Draw_Down_Profile__c)controller.getRecord();
    	
        this.drawId = this.dd.Id;
        this.prodId = this.dd.Product__c; 
    }
    
     public PageReference redirect(){
        PageReference pageRef = null;
        
        pageRef = new PageReference( '/apex/DrawDownProfileMassEdit_Vf?id=' + prodId + '&drawid=' + drawId) ;
        
        return pageRef;
     }

}