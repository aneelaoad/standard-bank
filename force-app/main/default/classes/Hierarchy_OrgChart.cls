/**
        @author         :     Abhishek V
        @date           :     02/02/2016
        @name           :     Hierarchy_OrgChart
        @Description    :     Resusable component for Hierarchy Chart for all Sobject with both standard and custom self lookups. 
**/ 

public with sharing class Hierarchy_OrgChart{
    private final Integer MAXDEPTH = 6;
    public Id recId{get;set;}
    public Id recIdforpage{get;set;}
    string NameField;
    ID rootId = null;
    public boolean hasParent {get; set;}
    public String selectedAccountId {get; set;}
    public String hierarchyDataString {get; set;}
    string queryString;
    Map<String,String> mSelfLookupFields ;
    Map<String,String> fieldRelationMap;
    Map<Id,String> mSmallPhotoUrl;
    Map<string,Set<string>> parentToChildsIds;
    set<String> dupcheckId;
    public enum iconOptions {Expanded,LoopBreaker,None}
    Public string objectName{get;private set;}
    Public string recordName{get;private set;}
    Public List<selectoption> sRelationshipOptions{get;private set;}
    Public string sRelationshipSelected {get;set;}
    String sTabUrl; 
    Set<string> sDuplicatesInLoopSign;
    Set<string> sExpandAll;
    Map<String,String> mImageRoots;
    integer iMaxDrillTimes;
    Public List<String> RTcheck{get;set;}
    Public List<String> RTfinal{get;set;}
    public boolean renderchart{get;set;}
    public List<Account> acc{get;set;}

/**
     *  Constructor name:   Hierarchy_OrgChart
     *  @description        Generates the initial chart string and invokes all the draw methods (Constructor)
     *  @param              none        
**/   
    public Hierarchy_OrgChart() {
      try{
          //Variable initialization
          renderchart = true;
          RTcheck = new List<string>();
          RTfinal = new List<string>();
          hasParent =false;
          sRelationshipOptions = new List<selectoption>();
          sRelationshipOptions.add(new selectoption('All','All'));
          sRelationshipSelected = 'All';
          LoadStaticImages();
          acc = new List<Account>();
          iMaxDrillTimes = 0;
          //Chart Generation start
          recIdforpage = ApexPages.currentPage().getParameters().get('id');
          recordName = ApexPages.currentPage().getParameters().get('name');

          if(ApexPages.currentPage().getParameters().get('id') != null)
            rootId = getRootID(ApexPages.currentPage().getParameters().get('id'), 0);
          recId = rootId;
          if(recId==null)
             recId = userinfo.getuserid(); 
          sTabUrl = getCurrentObjectUrl();
          getObjectNameField();         
          if(initialHierarchyString()){
            renderchart = true;
          }else{
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.INFO,Label.HierarchyRegexError);
            ApexPages.addMessage(myMsg);
            renderchart = false;
          }
        }catch(Exception e) {
            ApexPages.addMessages(e);
        }         
    } 


/**
     *  Method name:    getObjectNameField
     *  @description    Gets the current Tab URL using the describe method
     *  @param          none
     *  @return         String
**/     
    Public string getObjectNameField(){
        if (recId.getSObjectType() == case.sObjectType)
              NameField = 'CaseNumber';   
        else if (recId.getSObjectType() == Contract.sObjectType)
              NameField = 'ContractNumber';  
        else if (recId.getSObjectType() == Solution.sObjectType)
              NameField = 'SolutionNumber';       
        else
              NameField = 'Name';
        return NameField;
    }
    
/**
     *  Method name:    getCurrentObjectUrl
     *  @description    Gets the current Tab URL using the describe method
     *  @param          none
     *  @return         String
**/    
    public string getCurrentObjectUrl(){
        string sTabURL;
        if (!Test.isRunningTest())
            for(DescribeTabSetResult tsr : Schema.describeTabs()) 
                for(Schema.DescribeTabResult tr : tsr.getTabs()) 
                    if(tr.getSobjectName() == recId.getSObjectType().getDescribe().getName())
                        sTabURL = tr.getIconUrl();
                    
        if(sTabURL==null)
            sTabURL = '/img/icon/bigtop32.png';   
        
        return sTabURL;
    }

/**
     *  Method name:    initialHierarchyString
     *  @description    Generates the string with the current focus record and parent records. This will be called only once from the constructor
     *  @param          none
     *  @return         void
**/        
    public boolean initialHierarchyString(){
        dupcheckId = new set<string>();
        string datastr = '';
        hierarchyDataString ='';
        mSelfLookupFields= new Map<String,String>(); 
        sDuplicatesInLoopSign = new Set<string>();   
        parentToChildsIds =   new Map<string,set<string>>();  
        fieldRelationMap = new Map<String,String>();
        mSelfLookupFields = new Map<String,String>(); 
        fieldRelationMap = new Map<String,String>();
        mSmallPhotoUrl = new Map<Id,String>();
        sExpandAll = new Set<string>();
        iMaxDrillTimes = 0;
        
        datastr = makeInitialChartString(recId);
        
        //Continue generating chart only if self lookups are present
        if(mSelfLookupFields.size()>0){
            datastr += makeChildOrgChartString(recId);
        }
        hierarchyDataString = datastr;
        System.Debug('+++++'+hierarchyDataString.length());
        RTcheck = null;
        RTfinal = null;
        RTcheck = new List<String>();
        RTfinal = new List<String>();
        if(hierarchyDataString.length() < 490095){
            RTcheck = hierarchyDataString.split('],');
            for(String rt: RTcheck){
                System.Debug('+++++'+rt.substringBetween('<!--', ' -->'));
                if(rt.substringBetween('<!--', ' -->') != null){
                    RTfinal.add(rt.substringBetween('<!--', ' -->'));
                }else
                    RTfinal.add('Neglect');
            }
        }else{
            return false;
        }
        system.debug('++++++RTfinal'+RTfinal.size()+'++++'+RTfinal);
        system.debug('@@@@@@@@'+hierarchyDataString);
        return true;
    }
    
    public pagereference collapseall(){
        if(initialHierarchyString()){
            return null;
        }else{
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.INFO,Label.HierarchyRegexError);
            ApexPages.addMessage(myMsg);
            renderchart = false;
            return null;
        }
    }

/**
     *  Method name:    makeInitialChartString
     *  @description    Generates the string with the current focus record and parent records. This will be called only once from the initialHierarchyString method
     *  @param          ID (current focus recordid)
     *  @return         String
**/        
     public string makeInitialChartString(Id recId){
        // Initialise isparent boolean to false before starting algorithm
        hasParent=false;
        queryString='SELECT Id, RecordTypeId, Parent.RecordTypeID,'+string.escapeSingleQuotes(NameField)+',';
        //system.debug('***********************************'+queryString+'**************************');
        string datastr ='';
        Schema.sobjectType obj = recId.getSObjectType();
        SObjectType objToken = Schema.getGlobalDescribe().get(obj.getDescribe().getName());
        DescribeSObjectResult objDef = objToken.getDescribe();
        Map<String, SObjectField> fields = objDef.fields.getMap(); 
        Map<String,String> mParentRelationship = new Map<String,String>();
        Set<String> fieldSet = fields.keySet();
                
        if(obj == User.sobjectType)
            queryString += 'SmallPhotoUrl,'; 
        
        for(String sobjectFieldLabels : fieldSet)
        {
            SObjectField fieldToken = fields.get(sobjectFieldLabels);
            DescribeFieldResult selectedField = fieldToken.getDescribe();
            if(selectedField.getType() ==Schema.DisplayType.Reference && !selectedField.isNamePointing() && selectedField.getName()!='MasterRecordId' && selectedField.getName()!='CreatedById' && selectedField.getName()!='LastModifiedById'){
                List <Schema.sObjectType> lLookupFields = selectedField.getReferenceTo();
                if(lLookupFields[0] == objToken){
                    if(sRelationshipSelected == 'All'  || sRelationshipSelected == null ||(sRelationshipSelected!=null && selectedField.getRelationshipName() == sRelationshipSelected)){
                        queryString += string.escapeSingleQuotes(selectedField.getName())+','+string.escapeSingleQuotes(selectedField.getRelationshipName())+'.'+string.escapeSingleQuotes(NameField)+',';
                        if(selectedField.getName() == 'ParentID'){
                            mParentRelationship.put(selectedField.getName(),selectedField.getRelationshipName());
                            mSelfLookupFields.put(selectedField.getName(),selectedField.getlabel().replace(' ','.'));
                            sRelationshipOptions.add(new selectoption(string.escapeSingleQuotes(selectedField.getRelationshipName()),string.escapeSingleQuotes(selectedField.getName())));
                        }
                    }
                }
            }
        }
        
        queryString = queryString.subString(0, queryString.length() - 1);
        objectName = objDef.getName();
        queryString+= ' FROM ' + string.escapeSingleQuotes(objectName)+' Where ';
        //System.Debug('+++++queryString : '+queryString);
        sObject currentObj = Database.query(queryString+'Id=\''+string.escapeSingleQuotes(recId)+'\'');
        //System.Debug('++++'+currentObj);
        if(obj == User.sobjectType)
            mSmallPhotoUrl.put((id)currentObj.get('id'),(string)currentObj.get('smallphotourl'));
        
        if(mSelfLookupFields.size()>0){
            // Creating map of all parent records of current on focus record. There can multiple parent records and are displayed as array in parent block of current on focus record.
            Map<string,string> mParentRecords = new Map<string,string>();
            //System.Debug('++++ Self Lookup'+mSelfLookupFields);
            //System.Debug('++++ Self Lookup'+mParentRelationship.keyset());
            for(string sFieldLabel : mParentRelationship.keyset()){
                    if(currentObj.getSObject(mParentRelationship.get(sFieldLabel))!=null && currentObj.getsobject(mParentRelationship.get(sFieldLabel)).get(NameField)!=null){
                    mParentRecords.put((string)currentObj.get(sFieldLabel),(string)currentObj.getsobject(mParentRelationship.get(sFieldLabel)).get(NameField));
                    dupcheckId.add((string)currentObj.get('Id'));
                    dupcheckId.add((string)currentObj.get(sFieldLabel));
                    }
            }
            
            
            
            if(mParentRecords.size()>0){
                if(objectName=='User'){
                    for(user uParent :[select id,smallphotourl from user where id in : mParentRecords.keyset()])
                        mSmallPhotoUrl.put(uParent.id,uParent.smallphotourl);
                }   
                hasParent=true;
                datastr = parentFrameLookupString(mParentRecords,currentObj);
            }    
            else{
                String parentrrtID = (String)getFieldValue((Sobject)currentObj, 'Parent.RecordTypeID');
                datastr = frameChartString (new accountHierarchyWrapper(currentObj.get('Id'),currentObj.get(NameField),currentObj.get('RecordTypeID'),parentrrtID,null,null,null,iconOptions.None,null,null));
            }
        }
        else{
            String parentrrtID = (String)getFieldValue((Sobject)currentObj, 'Parent.RecordTypeID');
            datastr = frameChartString (new accountHierarchyWrapper(currentObj.get('Id'),currentObj.get(NameField),currentObj.get('RecordTypeID'),parentrrtID,null,null,null,iconOptions.None,null,null));
       }
        
        
        return datastr;
      
    }

/**
     *  Method name:    parentFrameLookupString
     *  @description    Generates the string with the current focus record and parent records. This will be called only once from the initialHierarchyString method
     *  @param          none
     *  @return         String
**/    
    public string parentFrameLookupString(Map<string,String> parentGroupMap,sobject currentObj){
        string sParentRecrdId;
        Map<Id, Account> accparentRT = new Map<ID, Account>([Select ID, RecordTypeID from Account where ID in :parentGroupMap.keyset()]);
        
        string datastr = '[\'';
        if(mSmallPhotoUrl.size()>0){
            for(Id parentRecrd : parentGroupMap.keyset()){  
                datastr += '<img src="'+mSmallPhotoUrl.get(parentRecrd)+'" width="20" height="20"><br/>';
                sParentRecrdId = parentRecrd;
                break;
            }
        }else
            datastr += '<img src="'+sTabUrl+'" width="20" height="20"><br/>';
            
        for(Id parentRecrd : parentGroupMap.keyset()){
            string sParentRecName='';
            if(parentGroupMap.containskey(parentRecrd))
                sParentRecName = string.escapeSingleQuotes(parentGroupMap.get(parentRecrd)) ;
            datastr += '<a href="/'+parentRecrd +'" style="color:#0000A0;font-size:15px" target="_blank" id="lookup'+parentRecrd+'" onblur="LookupHoverDetail.getHover(\\\'lookup'+parentRecrd+'\\\').hide();" onfocus="LookupHoverDetail.getHover(\\\'lookup'+parentRecrd+'\\\', \\\'/'+parentRecrd+'/m?retURL=%2Fapex%2FHierarchy_OrgChart%3Fid%3D'+recId+'&amp;isAjaxRequest=1&amp;nocache=1362495267529\\\').show();" onmouseout="LookupHoverDetail.getHover(\\\'lookup'+parentRecrd+'\\\').hide();" onmouseover="LookupHoverDetail.getHover(\\\'lookup'+parentRecrd+'\\\', \\\'/'+parentRecrd+'/m?retURL=%2Fapex%2FHierarchy_OrgChart%3Fid%3D'+recId+'&amp;isAjaxRequest=1&amp;nocache=1362495267529\\\').show();">'+sParentRecName+'</a><br/><div style="color:red; font-style:italic;font-size:13px">'+Account.sObjectType.getDescribe().getRecordTypeInfosById().get((ID)accparentRT.get(parentRecrd).RecordTypeID).getname()+'</div>';
            datastr += '<!--'+Account.sObjectType.getDescribe().getRecordTypeInfosById().get((ID)accparentRT.get(parentRecrd).RecordTypeID).getname()+' Record Type -->';
        }   
        datastr+= '\',\'';                  
        datastr+='\',\'\'],';
        
        datastr += '[\'';
        if(mSmallPhotoUrl.containskey((id)currentObj.get('Id')))
            datastr += '<img src="'+mSmallPhotoUrl.get((id)currentObj.get('Id'))+'" width="20" height="20"><br/>';
        else
            datastr += '<img src="'+sTabUrl+'" width="20" height="20"><br/>';
        datastr += '<a href="/'+currentObj.get('Id') +'" style="color:#0000A0;font-size:15px" target="_blank" nodeId="null:'+currentObj.get('Id')+':null" id="lookup'+currentObj.get('Id')+'" onblur="LookupHoverDetail.getHover(\\\'lookup'+currentObj.get('Id')+'\\\').hide();" onfocus="LookupHoverDetail.getHover(\\\'lookup'+currentObj.get('Id')+'\\\', \\\'/'+currentObj.get('Id')+'/m?retURL=%2Fapex%2FHierarchy_OrgChart%3Fid%3D'+recId+'&amp;isAjaxRequest=1&amp;nocache=1362495267529\\\').show();" onmouseout="LookupHoverDetail.getHover(\\\'lookup'+currentObj.get('Id')+'\\\').hide();" onmouseover="LookupHoverDetail.getHover(\\\'lookup'+currentObj.get('Id')+'\\\', \\\'/'+currentObj.get('Id')+'/m?retURL=%2Fapex%2FHierarchy_OrgChart%3Fid%3D'+recId+'&amp;isAjaxRequest=1&amp;nocache=1362495267529\\\').show();">'+string.escapeSingleQuotes((string)currentObj.get(NameField))+'</a><br/><div style="color:red; font-style:italic;font-size:13px">'+Account.sObjectType.getDescribe().getRecordTypeInfosById().get((ID)currentObj.get('RecordTypeId')).getname()+'</div>';
        datastr += '<!--'+Account.sObjectType.getDescribe().getRecordTypeInfosById().get((ID)currentObj.get('RecordTypeId')).getname()+' Record Type -->';
        datastr+= '\',\'';                  
        
        
        if(mSmallPhotoUrl.size()>0){
            datastr += '<img src="'+mSmallPhotoUrl.get(sParentRecrdId)+'" width="20" height="20"><br/>';
        }else
            datastr += '<img src="'+sTabUrl+'" width="20" height="20"><br/>';
        
        
        for(Id parentRecrd : parentGroupMap.keyset()){
            string sParentRecName='';
            if(parentGroupMap.containskey(parentRecrd))
                sParentRecName = string.escapeSingleQuotes(parentGroupMap.get(parentRecrd)) ;
            datastr += '<a href="/'+parentRecrd +'" style="color:#0000A0;font-size:15px" target="_blank" id="lookup'+parentRecrd+'" onblur="LookupHoverDetail.getHover(\\\'lookup'+parentRecrd+'\\\').hide();" onfocus="LookupHoverDetail.getHover(\\\'lookup'+parentRecrd+'\\\', \\\'/'+parentRecrd+'/m?retURL=%2Fapex%2FHierarchy_OrgChart%3Fid%3D'+recId+'&amp;isAjaxRequest=1&amp;nocache=1362495267529\\\').show();" onmouseout="LookupHoverDetail.getHover(\\\'lookup'+parentRecrd+'\\\').hide();" onmouseover="LookupHoverDetail.getHover(\\\'lookup'+parentRecrd+'\\\', \\\'/'+parentRecrd+'/m?retURL=%2Fapex%2FHierarchy_OrgChart%3Fid%3D'+recId+'&amp;isAjaxRequest=1&amp;nocache=1362495267529\\\').show();">'+sParentRecName+'</a><br/><div style="color:red; font-style:italic;font-size:13px">'+Account.sObjectType.getDescribe().getRecordTypeInfosById().get((ID)accparentRT.get(parentRecrd).RecordTypeID).getname()+'</div>';
            datastr += '<!--'+Account.sObjectType.getDescribe().getRecordTypeInfosById().get((ID)accparentRT.get(parentRecrd).RecordTypeID).getname()+' Record Type -->';
        } 
                     
        datastr+= '\',\'';
        datastr+='\'],';
        return datastr; 
    }
    
/**
     *  Method name:    makeChildOrgChartString
     *  @description    Generates the string of the all the child records with the current recordid passed as parameter
     *  @param          ID ( The child records of the current Id being passed will be generated for charting)
     *  @return         String
**/     
    public string makeChildOrgChartString(string objIds){
        Id objId;
        Id grandparentId;
        string parentRelationname;
        
        if(objIds.contains(':')){
            objId = objIds.split(':', 0)[1] ;
            grandparentId = objIds.split(':', 0)[0] ;
            parentRelationname = objIds.split(':', 0)[2];
        }
        else
            objId = objIds;
        
        string objName = (string)database.query('select '+string.escapeSingleQuotes(namefield)+' from '+string.escapeSingleQuotes(objectName)+' where Id=\''+string.escapeSingleQuotes(objId)+'\'')[0].get(NameField);
        string childObjQueryString ='';

        for(string fieldname : mSelfLookupFields.keyset()){
                childObjQueryString +=  string.escapeSingleQuotes(fieldname)+'='+'\''+ObjId+'\''+' Or ';
        }   
        //childObjQueryString = queryString+childObjQueryString.subString(0, childObjQueryString.length() - 4);
        List<sObject> childObjList = Database.query(string.escapeSingleQuotes(queryString)+childObjQueryString.subString(0, childObjQueryString.length() - 4));
        Set<id> childRecrdIds = new Set<id>();
        Set<string> childRecrdIdsWithCheck = new Set<string>();
        Map<String,Integer> accountMap = new  Map<String,Integer>();
        
        for(sObject child : childObjList){
            childRecrdIds.add((Id)child.get('Id'));
            if(objectName=='User')
                mSmallPhotoUrl.put((id)child.get('id'),(string)child.get('smallphotourl'));
            for(string fieldname : mSelfLookupFields.keyset()){
                if((String)child.get(fieldname) ==objId){
                    string relationShipName = mSelfLookupFields.get(fieldname);
                    if(fieldRelationMap.containskey((string)child.get('Id'))){
                        fieldRelationMap.put(objId+':'+(string)child.get('Id'),relationShipName);
                    }   
                    else
                        fieldRelationMap.put((string)child.get('Id'),relationShipName);
                    childRecrdIdsWithCheck.add(objId+':'+(string)child.get('Id')+':'+relationShipName);
                }
            } 
        }
        
        parentToChildsIds.put(grandparentId+':'+objId+':'+parentRelationname,childRecrdIdsWithCheck);
        set<String> sLookupfieldsForRollUp = new set<String>();
        if(mSelfLookupFields.size()<=3){
            accountMap.putAll(rollUpQueryMethod(mSelfLookupFields.keyset(),childRecrdIds));
        }
        else{
            for(string fieldname : mSelfLookupFields.keyset()){
                sLookupfieldsForRollUp.add(fieldname);
                if(sLookupfieldsForRollUp.size()==3){
                    accountMap.putAll(rollUpQueryMethod(sLookupfieldsForRollUp,childRecrdIds));
                    sLookupfieldsForRollUp.clear();
                }
            }
            accountMap.putAll(rollUpQueryMethod(sLookupfieldsForRollUp,childRecrdIds));
        }
        
        string datastr='';
        
        for(integer i=0;i<childObjList.size() ; i++){
            iconOptions e ;
            string parentRelationshipName;
            
            if(recid!=objId){
                if(parentRelationname!=null)
                    parentRelationshipName = parentRelationname;
                else if(fieldRelationMap.containskey(objId))
                    parentRelationshipName = fieldRelationMap.get(objId);
            }

            for(string fieldname : mSelfLookupFields.keyset()){
                    if((String)childObjList[i].get(fieldname) ==objId){
                        if(accountMap.containskey((string)childObjList[i].get('id')) && accountMap.get((String)childObjList[i].get('id'))>0){
                            if(dupcheckId.contains((string)childObjList[i].get('id'))){
                                e = iconOptions.Loopbreaker;
                                sDuplicatesInLoopSign.add(objId+':'+(string)childObjList[i].get('id')+':'+mSelfLookupFields.get(fieldname));
                                String parentrrtID = (String)getFieldValue((Sobject)childObjList[i], 'Parent.RecordTypeID');
                                datastr += frameChartString (new accountHierarchyWrapper((string)childObjList[i].get('id'),childObjList[i].get(NameField),(string)childObjList[i].get('RecordTypeid'),parentrrtID,mSelfLookupFields.get(fieldname),objId,objName,e,parentRelationshipName,grandparentId));
                            //system.debug('***********************************'+(string)childObjList[i].get('RecordTypeid')+'****************');
                            }
                            else if(!dupcheckId.contains((string)childObjList[i].get('id'))){
                                e = iconOptions.expanded;
                                String parentrrtID = (String)getFieldValue((Sobject)childObjList[i], 'Parent.RecordTypeID');
                                datastr += frameChartString (new accountHierarchyWrapper(childObjList[i].get('id'),childObjList[i].get(NameField),(string)childObjList[i].get('RecordTypeid'),parentrrtID,mSelfLookupFields.get(fieldname),objId,objName,e,parentRelationshipName,grandparentId));
                                //System.debug('+++++'+datastr);
                                //system.debug('@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@'+(string)childObjList[i].get('RecordTypeid')+'@@@@@@@@@@@@@@@@@@@@@@@@@@@@');
                                dupcheckId.add((string)childObjList[i].get('id'));
                                sExpandAll.add(ObjId+':'+childObjList[i].get('id')+':'+mSelfLookupFields.get(fieldname));
                            }
                        }
                        else{
                            e = iconOptions.None;
                            String parentrrtID = (String)getFieldValue((Sobject)childObjList[i], 'Parent.RecordTypeID');
                            datastr += frameChartString (new accountHierarchyWrapper(childObjList[i].get('id'),childObjList[i].get(NameField),(string)childObjList[i].get('RecordTypeid'),parentrrtID,mSelfLookupFields.get(fieldname),objId,objName,e,parentRelationshipName,grandparentId));
                        //system.debug('###########################################'+(string)childObjList[i].get('RecordTypeid')+'#################################');
                        }
                        dupcheckId.add((string)childObjList[i].get('id'));
                    } 
                }
        }
        
        return datastr;
    }
    
/**
   *  Method name:   rollUpQueryMethod
   *  @description   Utility method for the roll query for child objects
   *  @param         (Set<string> AllLookupFields, Set<id> AllChildrecords)
   *  @return        map<string,integer>[A map of the count of records with the particular fields]
**/

    public map<string,integer> rollUpQueryMethod(Set<string> sLookupFields,set<id> childRecrdIds){
        
        string rollUpQueryString = 'Select count(Id) total,'; 
        string rollLocalQueryString1='';
        string rollLocalQueryString2=' Group By Rollup(';
        string rollLocalQueryString;
        Map<string,integer> mCountRecords = new Map<string,integer>();
        for(string fieldname : sLookupFields){
            rollUpQueryString+=string.escapeSingleQuotes(fieldname)+',';
            rollLocalQueryString1+=  string.escapeSingleQuotes(fieldname)+' IN: childRecrdIds Or ';
            rollLocalQueryString2+=string.escapeSingleQuotes(fieldname)+',';
         }
        
        rollLocalQueryString= rollUpQueryString.removeEnd(',')+' from '+string.escapeSingleQuotes(objectName)+' where '+rollLocalQueryString1.removeEnd(' Or ')+rollLocalQueryString2.removeEnd(',')+')';
       
        for (AggregateResult ar : database.query(rollLocalQueryString)){
            for(string fieldname : sLookupFields){
                if(ar.get(fieldname)!=null)
                    mCountRecords.put((String) ar.get(fieldname), (Integer) ar.get('total'));
            }   
        }
        
        return mCountRecords;
        
    }
   
/**
   *  Method name:   frameChartString
   *  @description   Utility method for making the json string
   *  @param         accountHierarchyWrapper (Wrapper class containing all the details of the chart object)
   *  @return        string
**/
    public string frameChartString(accountHierarchyWrapper Obj){
        String datastr = '[\'';
        
        if(mSmallPhotoUrl.size()>0 && mSmallPhotoUrl.containskey((string)Obj.childAccountId))
            datastr += '<img src="'+mSmallPhotoUrl.get((string)Obj.childAccountId)+'" width="20" height="20"><br/>';
        else if(Obj.childAccountId==recId){
            datastr += '<img src="'+sTabUrl+'" width="20" height="20"><br/>';
        }    
                
        datastr += '<a href="/'+Obj.childAccountId +'" style="color:#0000A0;font-size:15px" target="_blank" nodeId="'+Obj.parentAccountId+':'+Obj.childAccountId+':'+Obj.childRelationshipName+'" id="lookup'+Obj.childAccountId+'" onblur="LookupHoverDetail.getHover(\\\'lookup'+Obj.childAccountId+'\\\').hide();" onfocus="LookupHoverDetail.getHover(\\\'lookup'+Obj.childAccountId+'\\\', \\\'/'+Obj.childAccountId+'/m?retURL=%2Fapex%2FHierarchy_OrgChart%3Fid%3D'+recId+'&amp;isAjaxRequest=1&amp;nocache=1362495267529\\\').show();" onmouseout="LookupHoverDetail.getHover(\\\'lookup'+Obj.childAccountId+'\\\').hide();" onmouseover="LookupHoverDetail.getHover(\\\'lookup'+Obj.childAccountId+'\\\', \\\'/'+Obj.childAccountId+'/m?retURL=%2Fapex%2FHierarchy_OrgChart%3Fid%3D'+recId+'&amp;isAjaxRequest=1&amp;nocache=1362495267529\\\').show();">'+obj.childAccountName+'</a>';
        
        //if(Obj.childRelationshipName!=null)
            datastr += '<br/><div style="color:red; font-style:italic;font-size:13px">'+Account.sObjectType.getDescribe().getRecordTypeInfosById().get((ID)obj.childAccountRT).getname()+'</div>';
        
            datastr += '<!--'+Account.sObjectType.getDescribe().getRecordTypeInfosById().get((ID)obj.childAccountRT).getname()+' Record Type -->';
            
        if(Obj.childAccountId!=recId ){
            if(Obj.drilldownOption==iconOptions.expanded){
                //datastr += '<img src="'+mImageRoots.get('Plus')+'" width="10" height="10" onclick="loadmore(\\\''+Obj.parentAccountId+':'+Obj.childAccountId+':'+Obj.childRelationshipName+'\\\');" title="Click to Drill down">';
            }else if(Obj.drilldownOption==iconOptions.Loopbreaker){
                datastr += '<img src="/img/func_icons/ispan12.gif" width="10" height="10" nodeId="'+Obj.parentAccountId+':'+Obj.childAccountId+':'+Obj.childRelationshipName+'" id="lookup'+Obj.childAccountId+'" onclick="alert(\\\'Record is already displayed and cannot be drilled down due to looping\\\');" title="Loop breaker">';
            }
        }  
        datastr+= '\',\'';
        
        if(obj.parentAccountId!=null){
            if(mSmallPhotoUrl.containskey((id)obj.parentAccountId))
                datastr += '<img src="'+mSmallPhotoUrl.get((id)obj.parentAccountId)+'" width="20" height="20"><br/>';
            else if(obj.parentAccountId == recid)
                datastr += '<img src="'+sTabUrl+'" width="20" height="20"><br/>';
            datastr += '<a href="/'+obj.parentAccountId +'" style="color:#0000A0;font-size:15px" target="_blank" nodeId="'+Obj.grandparentid+':'+Obj.parentAccountId+':'+Obj.parentRelationshipName+'" id="lookup'+Obj.parentAccountId+'" onblur="LookupHoverDetail.getHover(\\\'lookup'+Obj.parentAccountId+'\\\').hide();" onfocus="LookupHoverDetail.getHover(\\\'lookup'+obj.parentAccountId+'\\\', \\\'/'+obj.parentAccountId+'/m?retURL=%2Fapex%2FHierarchy_OrgChart%3Fid%3D'+recId+'&amp;isAjaxRequest=1&amp;nocache=1362495267529\\\').show();" onmouseout="LookupHoverDetail.getHover(\\\'lookup'+obj.parentAccountId+'\\\').hide();" onmouseover="LookupHoverDetail.getHover(\\\'lookup'+obj.parentAccountId+'\\\', \\\'/'+obj.parentAccountId+'/m?retURL=%2Fapex%2FHierarchy_OrgChart%3Fid%3D'+recId+'&amp;isAjaxRequest=1&amp;nocache=1362495267529\\\').show();">'+obj.parentAccountName+'</a>';
            //if(Obj.parentRelationshipName!=null){
                datastr += '<br/><div style="color:red; font-style:italic;font-size:13px">'+Account.sObjectType.getDescribe().getRecordTypeInfosById().get((ID)obj.parentAccountRT).getname()+'</div>';
                datastr += '<!--'+Account.sObjectType.getDescribe().getRecordTypeInfosById().get((ID)obj.parentAccountRT).getname()+' Record Type -->';
            //}
            if(obj.parentAccountId!=recId && Obj.childAccountId!=recId){
                //datastr += '<img src="'+mImageRoots.get('Minus')+'" width="10" height="10" onclick="collapseNode(\\\''+Obj.grandparentid+':'+Obj.parentAccountId+':'+Obj.parentRelationshipName+'\\\');" title="Click to collapse">';
            }
       }
        else
            datastr+= '';
            
        datastr+='\',\'\'],';
        
        return datastr;
        
    }

/**
   *  Method name:   loadmore
   *  @description   Action method which will be invoke if a particular node needs to be expanded
   *  @param         None 
   *  @return        Void
**/     
    public PageReference loadmore(){
        //hierarchyDataString = hierarchyDataString.replace('<img src="'+mImageRoots.get('Plus')+'" width="10" height="10" onclick="loadmore(\\\''+selectedAccountId+'\\\');" title="Click to Drill down">','<img src="'+mImageRoots.get('Minus')+'" width="10" height="10" onclick="collapseNode(\\\''+selectedAccountId+'\\\');" title="Click to collapse">');
        hierarchyDataString += makeChildOrgChartString(string.escapeSingleQuotes(selectedAccountId));
        RTcheck = null;
        RTfinal = null;
        RTcheck = new List<String>();
        RTfinal = new List<String>();
        if(hierarchyDataString.length() < 490095){
            RTcheck = hierarchyDataString.split('],');
            for(String rt: RTcheck){
                System.Debug('+++++'+rt.substringBetween('<!--', ' -->'));
                if(rt.substringBetween('<!--', ' -->') != null){
                    RTfinal.add(rt.substringBetween('<!--', ' -->'));
                }else
                    RTfinal.add('Neglect');
            }
            renderchart = true;
        }else{
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.INFO,Label.HierarchyRegexError);
            ApexPages.addMessage(myMsg);
            renderchart = false;
            return null;
        }
        system.debug('++++++RTfinal'+RTfinal.size()+'++++'+RTfinal);
        system.debug('@@@@@@@@'+hierarchyDataString);
        return null;
    }

/**
   *  Method name:   collapseNode
   *  @description   Action method which will be invoke if a particular node needs to be Collapsed
   *  @param         None 
   *  @return        Void
**/     
    public PageReference collapseNode(){
        //hierarchyDataString = hierarchyDataString.replace('<img src="'+mImageRoots.get('Minus')+'" width="10" height="10" onclick="collapseNode(\\\''+selectedAccountId+'\\\');" title="Click to collapse">','<img src="'+mImageRoots.get('Plus')+'" width="10" height="10" onclick="loadmore(\\\''+selectedAccountId+'\\\');" title="Click to Drill down">');
        if(removeString(selectedAccountId)){
            renderchart = true;
            return null;
        }else{
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.INFO,Label.HierarchyRegexError);
            ApexPages.addMessage(myMsg);
            renderchart = false;
            return null;
        }
        
    }

/**
   *  Method name:   removeString
   *  @description   Action method which will be invoke if a particular node needs to be Collapsed
   *  @param         Id (all the current record + all of its child record will be removed) 
   *  @return        Void
**/    
    public boolean removeString(string passId){
        try{
            if(parentToChildsIds.containskey(passId)){
                for(string childnodes : parentToChildsIds.get(passId)){
                    string schildNodalData='';
                    schildNodalData = hierarchyDataString.substring(hierarchyDataString.lastIndexOf('[',hierarchyDataString.indexOf(childnodes)),hierarchyDataString.IndexOf(']',hierarchyDataString.indexOf(childnodes))+2);
                    hierarchyDataString= hierarchyDataString.remove(schildNodalData);
                        if(!childnodes.contains(':') && dupcheckId.contains(childnodes)){   
                            dupcheckId.remove(childnodes);
                        }
                        else if(childnodes.contains(':') && dupcheckId.contains(childnodes.split(':', 0)[1]) && !sDuplicatesInLoopSign.contains(childnodes)){
                            dupcheckId.remove(childnodes.split(':', 0)[1]);
                        } 
                    removeString(childnodes);
                }
            }
        }catch(Exception e) {
            //ApexPages.addMessages(e);
        }  
        RTcheck = null;
        RTfinal = null;
        RTcheck = new List<String>();
        RTfinal = new List<String>();
        if(hierarchyDataString.length() < 490095){
            RTcheck = hierarchyDataString.split('],');
            for(String rt: RTcheck){
                System.Debug('+++++'+rt.substringBetween('<!--', ' -->'));
                if(rt.substringBetween('<!--', ' -->') != null){
                    RTfinal.add(rt.substringBetween('<!--', ' -->'));
                }else
                    RTfinal.add('Neglect');
            }
        }else{
            return false;
        }
        system.debug('++++++RTfinal'+RTfinal.size()+'++++'+RTfinal);
        system.debug('@@@@@@@@'+hierarchyDataString);
        return true;
    }  
    
/**
   *  Method name:   expandAll
   *  @description   Action method to expand all the nodes in one shot
   *  @param         No Param [All processing in done in the method taking in the current Rec Id]
   *  @return        Void
**/ 
    Public pagereference expandAll(){
    try{
        hierarchyDataString ='';
        initialHierarchyString();
        if(expandAllNodes()){
            renderchart = true;
            return null;
        }else{
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.INFO,Label.HierarchyRegexError);
            ApexPages.addMessage(myMsg);
            renderchart = false;
            return null;
        }
    }catch(Exception e) {
            ApexPages.addMessages(e);
            return null;
        }   
    }

/**
   *  Method name:   expandAll Utility
   *  @description   Action method to expand all the nodes in one shot
   *  @param         No Param [All processing in done in the method taking in the current Rec Id]
   *  @return        Void
**/    public boolean expandAllNodes(){
        try{
            set<string> sExpandBfrCalc = new set<string>();
            sExpandBfrCalc.addall(sExpandAll);
            for(string ids : sExpandAll){
                //hierarchyDataString = hierarchyDataString.replace('<img src="'+mImageRoots.get('Plus')+'" width="10" height="10" onclick="loadmore(\\\''+ids+'\\\');" title="Click to Drill down">','<img src="'+mImageRoots.get('Minus')+'" width="10" height="10" onclick="collapseNode(\\\''+ids+'\\\');" title="Click to collapse">');
                hierarchyDataString += makeChildOrgChartString(ids);
            }
            sExpandAll.removeall(sExpandBfrCalc);
            iMaxDrillTimes++;
            if(sExpandAll.size()>0 && iMaxDrillTimes<=30){
                expandAllNodes();
            }
        }catch(Exception e) {
            ApexPages.addMessages(e);
        } 
        RTcheck = null;
        RTfinal = null;
        RTcheck = new List<String>();
        RTfinal = new List<String>();
        if(hierarchyDataString.length() < 490095){
            RTcheck = hierarchyDataString.split('],');
            for(String rt: RTcheck){
                System.Debug('+++++'+rt.substringBetween('<!--', ' -->'));
                if(rt.substringBetween('<!--', ' -->') != null){
                    RTfinal.add(rt.substringBetween('<!--', ' -->'));
                }else
                    RTfinal.add('Neglect');
            }
        }else{
            return false;
        }
        system.debug('++++++RTfinal'+RTfinal.size()+'++++'+RTfinal);
        system.debug('@@@@@@@@'+hierarchyDataString);
        return true;
    }

/**
   *  Method name:   LoadStaticImages
   *  @description   Action method to Load all the images static images
   *  @param         No Param 
   *  @return        Void
**/      
    Public void LoadStaticImages(){
        mImageRoots = new Map<String,String>();
        StaticResource sResource = [SELECT Name, NamespacePrefix, SystemModStamp FROM StaticResource WHERE Name = : 'EasyDrill'];
        mImageRoots.put('Logo','/resource/'+sResource.SystemModStamp.getTime()+'/'+(sResource.NamespacePrefix != null && sResource.NamespacePrefix != '' ? sResource.NamespacePrefix + '__' : '')+sResource.Name+'/EasyDrill_StaticResource/EasyDrill__EasyDrill_Logo.png');    
        mImageRoots.put('Minus','/resource/'+sResource.SystemModStamp.getTime()+'/'+(sResource.NamespacePrefix != null && sResource.NamespacePrefix != '' ? sResource.NamespacePrefix + '__' : '')+sResource.Name+'/EasyDrill_StaticResource/EasyDrill__EasyDrill_Minus.png');  
        mImageRoots.put('Plus','/resource/'+sResource.SystemModStamp.getTime()+'/'+(sResource.NamespacePrefix != null && sResource.NamespacePrefix != '' ? sResource.NamespacePrefix + '__' : '')+sResource.Name+'/EasyDrill_StaticResource/EasyDrill__EasyDrill_Plus.png');
        mImageRoots.put('RightArrow','/resource/'+sResource.SystemModStamp.getTime()+'/'+(sResource.NamespacePrefix != null && sResource.NamespacePrefix != '' ? sResource.NamespacePrefix + '__' : '')+sResource.Name+'/EasyDrill_StaticResource/EasyDrill__EasyDrill_RightArrow.png');    
    }
    
    
   //Wrapper class 
    public class accountHierarchyWrapper {
    public object childAccountId {get; set;}
    public object childAccountName {get; set;}
    public object childAccountRT {get; set;}
    public object parentAccountRT {get; set;}
    public string childRelationshipName {get; set;}
    public object parentAccountId {get; set;}
    public object parentAccountName {get; set;}
    public string parentRelationshipName {get; set;}
    public string grandparentid{get;set;}
    public Hierarchy_OrgChart.iconOptions drilldownOption {get; set;}
    
        public  accountHierarchyWrapper(object childAccountId,object childAccountName,object childAccountRT,object parentAccountRT, string childRelationshipName,object parentAccountId,object parentAccountName,Hierarchy_OrgChart.iconOptions drilldownOption,string parentRelationshipName,string grandparentid){
            this.childAccountId = childAccountId;
            this.childAccountRT = childAccountRT;
            this.parentAccountRT = parentAccountRT;
            if(childAccountName!=null)
                this.childAccountName = string.escapeSingleQuotes((string)childAccountName);
            this.parentAccountId = parentAccountId;
            if(parentAccountName!=null)
                this.parentAccountName = string.escapeSingleQuotes((string)parentAccountName);
            this.drilldownOption = drilldownOption;
            this.childRelationshipName = childRelationshipName;
            this.parentRelationshipName = parentRelationshipName;
            this.grandparentid = grandparentid;
        }
    
    }
    
    public static Object getFieldValue(SObject o,String field){

        if(o == null){
            return null;
        }
        if(field.contains('.')){
            String nextField = field.substringAfter('.');
            String relation = field.substringBefore('.');
            return getFieldValue((SObject)o.getSObject(relation),nextField);
        }else{
            return o.get(field);
        }
        
    }
    
    Public ID getRootID( String objId, Integer level ){
        // get parent for this account
        Account a = [Select Id, ParentId From Account where Id = :objId limit 1];

        // if no parent then this is the Ultimate Parent else recurse
        if( a.parentID == NULL || level == MAXDEPTH  )
            return a.ID;
        else 
            return getRootID(a.parentID, level+1);
    }
   
}