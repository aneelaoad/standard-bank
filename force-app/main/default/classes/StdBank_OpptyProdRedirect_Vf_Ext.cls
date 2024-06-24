public class StdBank_OpptyProdRedirect_Vf_Ext {
// Created: 20-Feb-2009
// By: Manu Erwin
// SOW: EMEA_SOW_StandardBank_009

// ======User Story======
// Requirement - Navigate Owner To Create Product After Opportunity Creation
// After a user creates an Opportunity they should be navigated to create
// a Product for that Opportunity.
// The system will enforce the creation of at least one child Product at all times,
// i.e., when attempting to view a Opportunity with no child Product(s) the owner
// will be redirected to create a child Product.

// Note: The automatic redirection will continue for the owner until a child Product is created.

/*
  @ Last Modified By  :  Tracy Roberts
  @ Last Modified On  :  12-July-2012
  @ Description  : If the Opportunity Stage is Lead with/without Products, page redirects to Standard Oppertunity View
  
  @ Last Modified By  :  Rudolf Niehaus
  @ Functional Area   :  Opportunity, SB_Product_c and Draw_Down_Profile__c
  @ Last Modified On  :  20/08/2012
  @ Description       : If there is products linked to the oppo check that the estimated close date of the opportunity is not before the earliest draw date 
  						of all the prodcuts linked to this Oppo and if true navigate the user to the mass draw down update VF 
  						page for the relevant product to give the user the ability to fix and line up the dates. 
  						This validation excludes system admins and closed opportunities and anu Oppo update on close date validation.
*/
    Opportunity opp;
    Id oppId;
    String strOppName;
    String strOppNameEncoded;
    String strAccName;
    String strAccNameEncoded;
    String accId;
    Private String strStageName = '';
	private Id userProfileId = null;
	private String adminIds = '';
	private Boolean userIsAdmin = false;
	private Environment_Variable__c settings = null;
	
    public StdBank_OpptyProdRedirect_Vf_Ext (ApexPages.StandardController controller) {
        System.Debug('## >>> StdBank_OpptyProdRedirect_Vf_Ext <<< run by ' + UserInfo.getName());
        System.Debug('## >>> Starting the constructor <<<');
       
        // Get the current record's id from the page
        oppId = controller.getId();
        System.Debug('## DEBUG: oppId: ' + oppId);
        opp = [select Name,
                    OwnerId,Earliest_Draw_Date_Rollup__c,CloseDate,
                    Owner.Force_Owner_to_Add_Opportunity_Product__c,
                    Account.Name,IsClosed,
                    Account.Id,
                    StageName
                    from Opportunity
                    where Id =: oppId limit 1];
        strOppName = opp.Name;
        strStageName = opp.StageName;
        strOppNameEncoded = EncodingUtil.urlEncode(strOppName, 'UTF-8');
        System.Debug('## oppId/strOppName/strOppNameEncoded: ' + oppId +'/'+ strOppName +'/'+ strOppNameEncoded);
        strAccName = opp.Account.Name;
        strAccNameEncoded = EncodingUtil.urlEncode(strAccName, 'UTF-8');
        accId = opp.Account.Id;
        System.Debug('## accId/strAccName/strAccNameEncoded: ' + accId +'/'+ strAccName +'/'+ strAccNameEncoded);
        System.Debug('## >>> Ending the constructor <<<');
        
        //get user profile id and check is he is a admin user
         this.settings = Environment_Variable__c.getInstance();
         adminIds = settings.Admin_Profile_IDs__c;
         userProfileId = System.Userinfo.getProfileId();
         if(adminIds.contains(userProfileId)){
         	userIsAdmin = true;
         }
        
    }
   
    public PageReference redirect(){
         
        System.Debug('## >>> Starting redirect <<<');
        // The no-action redirect is to the standard page so that standard functionality is available (e.g., inline editing)
        PageReference pageRef = new PageReference('/' + oppId + '?nooverride=1');

            // Obtain the number of child Product records for the current opportunity
            Integer intChildProducts = [select count() from SB_Product__c where Opportunity__c = :oppId];
                                        
           if ((strStageName != '1 - Lead') && (strStageName != '4 - Closed Lost') && (strStageName != 'Cancel')){
               System.debug('BIG5 DO NOT skip page redirect');
            // Proceed if the current user is the Opportunity owner AND the User should be redirected to create Products
            if ((UserInfo.getUserId() == opp.OwnerId) && (opp.Owner.Force_Owner_to_Add_Opportunity_Product__c == true)) {
               
                if (intChildProducts == 0) {
                                         /*System.Debug('## There are zero child products so need to navigate owner to add one');
                    //String strBeginURL = '/setup/ui/recordtypeselect.jsp?ent=01I200000009wOe&save_new_url=/a0g/e';             
                    String strBeginURL = '/setup/ui/recordtypeselect.jsp?ent=' + StdBank_SystemParams.getParam('Product Object Id') + '&save_new_url=' + StdBank_SystemParams.getParam('Product Object Edit Url');           
                    // This string has a '?' at the start because it will be the first parameter after the record type selection has occured.
                    //String strOppIdField = '?CF00N20000001bfJa_lkid=';              
                    String strOppIdField = '?' + StdBank_SystemParams.getParam('Product Opportunity Field Id') + '_lkid=';                
                    //String strOppNameField = '&CF00N20000001bfJa=';                
                    String strOppNameField = '&' + StdBank_SystemParams.getParam('Product Opportunity Field Id') + '=';                
                    //String strAccIdField = '&CF00N20000001bfK9_lkid=';               
                    String strAccIdField = '&' + StdBank_SystemParams.getParam('Product Account Field Id') + '_lkid=';                
                    //String strAccNameField = '&CF00N20000001bfK9=';               
                    String strAccNameField = '&' + StdBank_SystemParams.getParam('Product Account Field Id') + '=';                
                    String strRetUrl = '&retURL=/';
                    String strSaveUrl = '&saveURL=/';
                    // The OppIdField needs to be set first because if the OppName has special characters they corrupt the URL
                    pageRef = new PageReference(strBeginURL +
                                                strOppIdField + oppId +
                                                strOppNameField + strOppNameEncoded +
                                                strAccIdField + accId +
                                                strAccNameField + strAccNameEncoded +
                                                strRetUrl + oppId +
                                                strSaveUrl + oppId);    */
                    pageRef = new PageReference('/apex/ProductSearchPage?oppId='+oppId);                                     
                    }
                }         
              }
              
              //there is products, now check the close date of the opportunity is not before the erliest draw date and if true navigate 
              //the user to the mass draw down update page for the relevant product in order to fix.
              if((intChildProducts != 0) && (!opp.IsClosed)){
              		Id prodId = null;
                	Id randomId = null;
                	Boolean hasDrawDowns = true;
                	//get custom settings that will determine only certain products must addhear to the business rules
                	String productRecordTypes = settings.Draw_Down_Product_Record_Types__c;
        		    String gppPickListValues = settings.Draw_Down_Grand_Parent_Products__c;
        
        					
              		for(SB_Product__c p : [select Earliest_Draw_Date_Rollup__c, RecordType.Name, Grand_Parent_Product__c from SB_Product__c where Opportunity__c =: opp.Id]){
                    		
                		if( (productRecordTypes.contains(p.RecordType.Name)) && (gppPickListValues.contains(p.Grand_Parent_Product__c))){
	                		if(p.Earliest_Draw_Date_Rollup__c == null){
	                			prodId = p.Id;
	                			hasDrawDowns = false;
	                		}
            			}
                    		
                    }
                    
                    //All products have draw down records. Now check the dates
                    if(hasDrawDowns){ 
              			//exclude admin users
	              		if(!userIsAdmin){
		              		//check if the estimated close date is before any draw down date for all related products
		              		if(opp.CloseDate > opp.Earliest_Draw_Date_Rollup__c){
		                    		
		                    	//get the correct product id from this early draw date
		                    	for(SB_Product__c p : [select Id, Earliest_Draw_Date_Rollup__c from SB_Product__c where Opportunity__c =: opp.Id order by Earliest_Draw_Date_Rollup__c desc]){
		                    		//Compare the rollup summary field on the Oppo (The field rollup all the product rollup's to the min date)
		                    		//To the Rollups summary for each product (The fiels rollup the draw dates to the min date) 
		                    		//linked to the opp
		                    		if(opp.Earliest_Draw_Date_Rollup__c == p.Earliest_Draw_Date_Rollup__c){
		                    			prodId = p.Id;
		                    		}
		                    		//If the to rollup's do not match then we simply take the product with the smalles date. 
		                    		if(opp.CloseDate > p.Earliest_Draw_Date_Rollup__c){
		                    			randomId = p.Id;
		                    		}
		                    			
		                    	}
		                		//Product ID cannot be null it would generate an error on the mass update VF page for draw down records
		                		if(prodId == null){
		                			//add id of smalles draw down date
		                			prodId = randomId;
		                		}
		                		//navigate to the VF page DrawDownProfileMassEdit_Vf and pass the correct product id through.
		                		//return URL is the current Oppo and we use the parameter 'source' so that the VF page controller
		                		//knows where from the user was navigated in order to populate the selected list that needs to be displyed on the page
		                		 pageRef = new PageReference('/apex/DrawDownProfileMassEdit_Vf?id=' + prodId + '&retURL=/' + opp.Id + '&source=oppval');
		                   }
	              	  }
                  }else{
                  		
                  		list<SB_Product__c> lstProd = [select Id, RecordType.Name, Grand_Parent_Product__c, Opportunity__c from SB_product__c where Id =: prodId limit 1];
                  		
                  		//If this product record type and parent product name falls into the rule category, enforce rule.
                  		if( (productRecordTypes.contains(lstProd[0].RecordType.Name)) && 
            				(gppPickListValues.contains(lstProd[0].Grand_Parent_Product__c))){
	                  		//there is no draw down records for this product, navigate user to the add draw down VF page
	                  		pageRef = new PageReference('/apex/DrawDownProfile_Vf?id=' + prodId + '&retURL=/' + opp.Id + 'recs=-1');
            			}
                  }
              }
        System.Debug('## pageRef: ' + pageRef);
        System.Debug('## >>> Ending redirect <<<');
        return pageRef;
    }

 }