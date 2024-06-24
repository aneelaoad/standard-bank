/*****************************************************************************************************\
    @ Func Area     : Opportunity
    @ Author        : Shubham Khilauria
    @ Date          : 26/05/2014
    @ Test File     : Test Method: OpportunityNewRedirect_Vf_Ext_Test
    @ Description   : EN-386 :
                      This controller class is used by the VF page "OpportunityNewRedirect_Vf".
                      The controller ensures that whenever a user clicks on New Opportunity than the
                      user should land on Lead Opportunity edit page to create new Opportunity. User is 
                      not allowed to create any other type of opportunity then Lead.  
                      
    @ Last Modified By  : Vishnu Vundavalli
    @ Last Modified On  : 28 April 2015
    @ Modification Description : EN-713 : To pre populate Event Report field value on opportunity edit
    
    @ Last Modified By  : Manoj Gupta
    @ Last Modified On  : 13 April 2016
    @ Modification Description : US-1218 : Pre populate Game Changer details on Opportunity
    
    @ Last Modified By  : Abhishek V
    @ Last Modified On  : 07 Dec 2016
    @ Modification Description : US-1558 : Pre populate Campaign details on Opportunity

	@ Last Modified By  : Jakub Oracki
    @ Last Modified On  : 27 March 2017
    @ Modification Description : US-1793 :	Redirect to Opportunity_New_LDS page from
											Contact QuickAction pre populated form.
    -------------------------------------------------------------------------------------
**/
public class OpportunityNewRedirect_Vf_Ext {

    public String retUrlStr;
    public String saveNewStr;
    public String acctId;
    public String campId;
    public String conId;
    public string OppAccID;
    public string OppId;
    public string OpplkId;
    
    //@vishnu(28/05/2015) : EN 713
    public string eventReportValue ;
    public string eventReportId ;
    
    //@Manoj(12/4/2016) : US-1218
     public string gameChangerValue ;
     public string gameChangerId ;
     public string OppLeadSource;
     public string OppStage;
     public string OppDesc; 
     public string OppComments; 
     public String saveUrlStr;  
     public String urlStr {get;set;} 
     public String urlStrSF1 {get;set;}

    private Id parentId;
    private String sObjType;

    public OpportunityNewRedirect_Vf_Ext (ApexPages.StandardController controller) {
		
		Contact contactRecord;
		if(controller.getRecord().getSObjectType() == Schema.Contact.getSObjectType()){			
			contactRecord = (Contact) controller.getRecord();
		}

        parentId = ApexPages.currentPage().getParameters().get('parentId');
        sObjType = String.isBlank(parentId) ? '' : String.valueOf(parentId.getSobjectType());

        retUrlStr = ApexPages.currentPage().getParameters().get('retURL');
        saveNewStr = ApexPages.currentPage().getParameters().get('save_new');
        saveUrlStr = ApexPages.currentPage().getParameters().get('saveURL');
        acctId = '';
        if(ApexPages.currentPage().getParameters().containsKey('accid'))
            acctId = ApexPages.currentPage().getParameters().get('accid');
		else if(contactRecord != null && String.isNotBlank(contactRecord.AccountId)){
			acctId = contactRecord.AccountId;
		}
            
        campId = '';
        if(ApexPages.currentPage().getParameters().containsKey('campid'))
            campId = ApexPages.currentPage().getParameters().get('campid');
            
        conId = '';
        if(ApexPages.currentPage().getParameters().containsKey('conid'))
            conId = ApexPages.currentPage().getParameters().get('conid');
		else if(contactRecord != null) {
			conId = contactRecord.Id;
		}
            
        if(ApexPages.currentPage().getParameters().containsKey('opp4'))
           OppAccID = ApexPages.currentPage().getParameters().get('opp4');
        
       if(ApexPages.currentPage().getParameters().containsKey(Label.Cross_Sell_Opportunity))
           OppId = ApexPages.currentPage().getParameters().get(Label.Cross_Sell_Opportunity);
           
       if(ApexPages.currentPage().getParameters().containsKey(Label.Cross_Sell_Opportunity + '_lkid'))
           OpplkId = ApexPages.currentPage().getParameters().get(Label.Cross_Sell_Opportunity + '_lkid');
           
       //@vishnu(28/05/2015) : EN 713
       if(ApexPages.currentPage().getParameters().containsKey(Label.PrimaryEventReportCustomFieldId)){
           eventReportValue = ApexPages.currentPage().getParameters().get(Label.PrimaryEventReportCustomFieldId);
       }
       
       if(ApexPages.currentPage().getParameters().containsKey(Label.PrimaryEventReportCustomFieldId + '_lkid')){
           eventReportId = ApexPages.currentPage().getParameters().get(Label.PrimaryEventReportCustomFieldId + '_lkid');
       }
       
       //@manoj(12/04/2016) : US-1218
       if(ApexPages.currentPage().getParameters().containsKey(Label.GameChangerCustomFieldId)){
           gameChangerValue = ApexPages.currentPage().getParameters().get(Label.GameChangerCustomFieldId);
       }
       
       if(ApexPages.currentPage().getParameters().containsKey(Label.GameChangerCustomFieldId + '_lkid')){
           gameChangerId = ApexPages.currentPage().getParameters().get(Label.GameChangerCustomFieldId + '_lkid');
         
        if(ApexPages.currentPage().getParameters().containsKey('opp11'))
           OppStage = ApexPages.currentPage().getParameters().get('opp11'); 

        if(ApexPages.currentPage().getParameters().containsKey(Label.GameChangerLeadSourceId))
           OppLeadSource = ApexPages.currentPage().getParameters().get(Label.GameChangerLeadSourceId);  

        if(ApexPages.currentPage().getParameters().containsKey('opp14'))
           OppDesc = ApexPages.currentPage().getParameters().get('opp14');   

        if(ApexPages.currentPage().getParameters().containsKey(Label.GameChangerCommentsId))
           OppComments = ApexPages.currentPage().getParameters().get(Label.GameChangerCommentsId);    
       
   
       }       
       
       
    }
    
    
   
    //This method is used in the action property of the VF page "OpportunityNewRedirect_Vf" and runs
    //on page load. It navigate the user to the edit page of a lead opportunity always when New button is clicked for an opportunity.
    public void redirect(){
        
        urlStr = '';
        urlStrSF1 = '';
        
        Schema.DescribeSObjectResult d = Schema.SObjectType.Opportunity;
        String recordTypeId = d.getRecordTypeInfosByName().get(Label.Opportunity_Create_Type).getRecordTypeId();
        String keyPrefix = d.getKeyPrefix();
        
        //urlStr = urlStr + '/' + keyPrefix + '/e?retURL=' + retUrlStr + '&RecordType=' + recordTypeId + '&nooverride=1';
        
        if(acctId!=null && acctId!='')
            urlStr = urlStr + '&accid=' + acctId;
        
        if(campId!=null && campId!='')
            urlStr = urlStr + '&campid=' + campId;
        
        if(conId!=null && conId!='')
            urlStr = urlStr + '&conid=' + conId;
         
        if(OppAccID !=null && OppAccID !='')
            urlStr = urlStr + '&opp4=' + OppAccID;
             
        if(OppID !=null && OppID !='')
           urlStr = urlStr + '&' + Label.Cross_Sell_Opportunity + '=' + OppId;
           
        if(OpplkID !=null && OpplkID !='')
           urlStr = urlStr + '&' + Label.Cross_Sell_Opportunity + '_lkid=' + OpplkId;
        
        //@vishnu(28/05/2015) : EN 713
        if(eventReportValue !=null && eventReportValue !=''){
           urlStr = urlStr + '&' + Label.PrimaryEventReportCustomFieldId + '=' + eventReportValue;
        }
        
        if(eventReportId !=null && eventReportId !=''){
           urlStr = urlStr + '&' + Label.PrimaryEventReportCustomFieldId + '_lkid=' + eventReportId;
        }
        
        //@manoj(12/04/2016) : EN-1218
        if(gameChangerValue !=null && gameChangerValue !=''){
           urlStr = urlStr + '&' + Label.GameChangerCustomFieldId + '=' + gameChangerValue;
        }
        
        if(gameChangerId !=null && gameChangerId !=''){
           urlStr = urlStr + '&' + Label.GameChangerCustomFieldId + '_lkid=' + gameChangerId + '&saveURL=' +saveUrlStr;
        }

        if(OppStage !=null && OppStage !='')
           urlStr = urlStr + '&' + '&opp11=' + OppStage;

        if(OppLeadSource !=null && OppLeadSource !='')
           urlStr = urlStr + '&' + Label.GameChangerLeadSourceId + '=' + OppLeadSource;

        if(OppDesc !=null && OppDesc !='')
           urlStr = urlStr + '&' + '&opp14=' + OppDesc;

        if(OppComments !=null && OppComments !='')
           urlStr = urlStr + '&' + Label.GameChangerCommentsId + '=' + OppComments;    

        urlStr = '/' + keyPrefix + '/e?retURL=' + retUrlStr + '&RecordType=' + recordTypeId + '&nooverride=1' + urlStr;

        JSONGenerator generator = JSON.createGenerator(false);
        generator.writeStartObject();
            generator.writeStringField('componentDef', 'c:Modal');
            generator.writeFieldName('attributes');
            generator.writeStartObject();
                generator.writeStringField('component', 'c:NewOpportunity');
                generator.writeFieldName('attributes');
                generator.writeStartObject();
                    generator.writeStringField('recordId', String.isBlank(parentId) ? '' : parentId);
                    generator.writeStringField('sObjectName', sObjType);
                    generator.writeBooleanField('isQuickAction', false);
        generator.close();
        System.debug(generator.getAsString());
        Blob base64Component = Blob.valueOf(generator.getAsString());
        urlStrSF1 = '/one/one.app?source=aloha#' + EncodingUtil.base64Encode(base64Component);

        /*Pagereference pageRef = new PageReference(urlStr);
        pageRef.setRedirect(true);
        return pageRef;*/
    }

 }