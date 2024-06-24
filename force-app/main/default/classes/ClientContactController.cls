/*****************************************************************************************************
    @ Func Area     : Client Plan
    @ Author        : Navin Rai
    @ Date          : 09/2013
    @ Test File     : TestClientContactController.cls
    @ Description   : This controller is used for creating the ClientContactCP VF componnet which is used in the client contact section of the client plan.       
    
    @ Last Modified By  :   Manoj Gupta       
    @ Last Modified On  :   Dec 2015
    @ Last Modified Reason  : EN:0838 - Replacing Corporate Banking references to Client Coverage

    @ Last Modified By  :   Petr Svestka
    @ Last Modified On  :   Dec 11, 2015
    @ Last Modified Reason  : EN-928 - Added clientHolder property and changed return pages based accordingly
    
    @ Last Modified By  :   Jana Cechova
    @ Last Modified On  :   Oct 6,2016
    @ Last Modified Reason  : US-1486 - Duplicate Contact Clean-up - (1) Remove Inactive Client Contacts from Lookup Searches, Client Plan and Campaigns
    
    @ Last Modified By  : Abhishek V
    @ Last Modified Date : Nov 08, 2016
    @ Modification Description : US - 1662 : Commented page reference to same page on save/cancel methods
******************************************************************************************************/
    public  class ClientContactController {
        public List<Contact> ClientContactList = new List<Contact> ();
        public List<Contact> cctList {get;set;} 
        Public List<wrapper> wrap {get;set;}
        Public List<DeleteWrapper> Delete_Wrap {get;set;}
        Public List<Key_Client_Contact__c> kcc_list = new List<Key_Client_Contact__c> ();
        Public List<Key_Client_Contact__c> KccDataList = new List<Key_Client_Contact__c> ();
        public list<Key_Client_Contact__c> duplicateKCC = new list<Key_Client_Contact__c>();
        public Boolean lightning{get;set;}

        public String clientHolder { get; set; }
        
        public Map<id,String> CBmap {get;set;}
        public Map<id,String> TPSmap {get;set;}
        public Map<id,String> IBmap {get;set;}
        public Map<id,String> GMmap {get;set;}
        public Map<id,String> REmap {get;set;}
        public Map<id,String> Othermap {get;set;}
        
        //NK 
        public Map<id,id> ContactKeyCCmap {get;set;}
        public String ClientContactId{get;set;}
        
        public boolean scroll {get;set;}
        public id clientid;
        public Integer rowsize;
        public boolean showwindow {get;set;}
        public boolean showEditwindow {get;set;}
        
         public ClientContactController(ApexPages.StandardController controller){
            
            cctList = new List<Contact> ();
            
            wrap = new List<Wrapper>();
            
            Delete_Wrap = new List<DeleteWrapper> ();
            
            showwindow = false;
            showEditwindow = false;
            scroll = false;
            rowsize = 0;
            
            clientid = ApexPages.currentPage().getParameters().get('id');
                    
            ClientContactList = [SELECT id,Name, Title, Influence__c, Relationship_Type__c, AccountId,
                                        (SELECT id, SA_User__c,SA_Contact__c, SA_User__r.Name ,User_Division__c FROM Contact_Team_Members__r) r
                                 FROM   Contact
                                 WHERE  Account.id    = :ApexPages.currentPage().getParameters().get('id')
                                 AND    RecordType.DeveloperName  = 'SA_Client_Contact_Record_Type' // Client Contact Record type
                                 AND    Inactive__c   = False];
            
            for(Contact c   :ClientContactList){
                
                wrap.add(new Wrapper(c));
            }
            
            KCCData ();
            
         }
        
        //Constructor-custom controller
        public ClientContactController(){
            cctList = new List<Contact> ();
            
            wrap = new List<Wrapper>();
            
            Delete_Wrap = new List<DeleteWrapper> ();
            
            showwindow = false;
            showEditwindow = false;
            scroll = false;
            rowsize = 0;
            
            clientid = ApexPages.currentPage().getParameters().get('id');
                    
            ClientContactList = [SELECT id,Name, Title, Influence__c, Relationship_Type__c, AccountId,
                                        (SELECT id, SA_User__c,SA_Contact__c, SA_User__r.Name ,User_Division__c FROM Contact_Team_Members__r) r
                                 FROM   Contact
                                 WHERE  Account.id    = :ApexPages.currentPage().getParameters().get('id')
                                 AND    RecordType.DeveloperName  = 'SA_Client_Contact_Record_Type' // Client Contact Record type
                                 AND    Inactive__c   = False];
            
            for(Contact c   :ClientContactList){
                
                wrap.add(new Wrapper(c));
            }
            
            KCCData ();
            
        } //End of controller  
        
        
        //Nk : Storing the information for delete link
        public map<Id,Id> getContactKeyCCmap (){
            
            ContactKeyCCmap = new map<Id,Id>();
            
            list<Key_Client_Contact__c> keyCCList = [SELECT  id, Contact_Name__c , Client_Plan__c
                                                         FROM    Key_Client_Contact__c 
                                                         WHERE client__c =  :clientid
                                                         AND Contact_Name__r.Inactive__c = false] ;
                                                        
              for(Contact cont   :ClientContactList){
             
                 for (Key_Client_Contact__c kcc : keyCCList){
                   
                   if(kcc.Contact_Name__c == cont.Id){
                     ContactKeyCCmap.put(cont.Id,kcc.Id);
                   }    
                    
                 }
              }
              
              return ContactKeyCCmap;
        }

        public class Wrapper{
            public Boolean ischeck{get;set;}
            public Contact con   {get;set;}
            
            //Wrapper Class Constructor
            public Wrapper( Contact con){
                this.ischeck = false;
                this.con   = con;
            }// End of wrapper constructor
        }// End of wrapper class
        
        
       
       public void AddContacts(){
           
           showwindow = true;
           //deletekcc();
       }// End of AddContacts
       
       public void EditContacts(){
           
           showEditwindow = true;
           //deletekcc();
       }// End of EditContacts

       private PageReference returnPage() {
           PageReference pageref;
           if (clientHolder == 'Commercial Banking') {
               pageref = new PageReference ('/apex/ClientPlanCommB?id='+ clientid);
           } else {
               pageref = new PageReference ('/apex/ClientPlan?id='+ clientid+'&Lightning='+lightning);
           }

           return pageref; 
       }

       public PageReference SaveRecord(){
        
        Boolean DontInsert  = true;
        List<Key_Client_Contact__c> kcc_existing_data = new List<Key_Client_Contact__c> ();
        List<Key_Client_Contact__c> kcc_add_list = new List<Key_Client_Contact__c> ();
        
        for(Wrapper w :wrap){
            
            if(w.ischeck == true){
                
                
                Key_Client_Contact__c kcc = new Key_Client_Contact__c ();
                
                kcc.Client__c = w.con.AccountId;
                kcc.Contact_Name__c = w.con.id;
                
                kcc_list.add(kcc);
                
           } //end of if block      
        }//end of for loop
        
        
        kcc_existing_data = [SELECT client__c, Contact_Name__c FROM Key_Client_Contact__c WHERE client__c =  :clientid AND Contact_Name__r.Inactive__c = false];
        
        for(Key_Client_Contact__c klist :kcc_list){
            for(Key_Client_Contact__c ked  :kcc_existing_data){
                if(klist.client__c == ked.client__c && klist.Contact_Name__c == ked.Contact_Name__c){
                    DontInsert = false;
                }
            }
            
            if(DontInsert == true){
                kcc_add_list.add(klist);
            }
            DontInsert = true;
        }
                                       
        if(!kcc_add_list.isEmpty()){
            
            //try{
                INSERT kcc_add_list;
           // }    
        }

        //refresh logic
        PageReference pageref = returnPage();
        pageref.setRedirect(true);
        showwindow = false;
        showEditwindow = false;
        KCCData ();
        return pageref;
        
       }// End of SaveRecord
       
      public Pagereference CancelPop(){
        
         if(duplicateKCC.size()>0){
            delete duplicateKCC ;
         }
           
            PageReference pageref = returnPage();
                pageref.setRedirect(true);
                showwindow = false;
                showEditwindow = false;
            return pageref;
           
       }// End of CancelPop
       
       public void KCCData(){
           List<String> CBList = new List<String> ();
           List<String> TPSList = new List<String> ();
           List<String> IBList = new List<String> ();
           List<String> GMList = new List<String> ();
           List<String> REList = new List<String> ();
           List<String> OtherList = new List<String> ();
           
           List<Id> contactIds = new List<Id> ();
           
           CBmap = new Map<id,String> ();
           TPSmap = new Map<id,String> ();
           IBmap = new Map<id,String> ();
           GMmap = new Map<id,String> ();
           REmap = new Map<id,String> ();
           Othermap = new Map<id,String> ();
           
           
           String CB = '';
           String TPS = '';
           String IB = '';
           String GM = '';
           String RE = '';
           String Other = '' ;
           
           
           
        KccDataList = [SELECT  id, Contact_Name__c  
                         FROM    Key_Client_Contact__c 
                         WHERE client__c =  :clientid
                         AND Contact_Name__r.Inactive__c = false]; 
                         
          for(Key_Client_Contact__c kcc  :KccDataList){
              contactIds.add(kcc.Contact_Name__c);
          }    
                       
          cctList = [SELECT id,Name, Title, Influence__c, Relationship_Type__c, AccountId,
                                (SELECT id, SA_User__c,SA_Contact__c, SA_User__r.Name ,User_Division__c,Primary_Contact_Person__c FROM Contact_Team_Members__r) r
                         FROM   Contact
                         WHERE  Accountid =  :clientid
                         AND    Inactive__c   = False  
                         AND    id IN :contactIds
                         ORDER BY Name];
           
           rowsize = cctList.size();
           
           cctlist.sort();
                       
           for(Contact  c  :cctList){
               for(SA_Contact_Team_Member__c  t  :c.Contact_Team_Members__r){
                       if(t.User_Division__c == 'Client Coverage'){
                           if(t.Primary_Contact_Person__c){
                               CB = CB + ',' + '<b>'+t.SA_User__r.Name+'</b>';
                           }                           
                           else{
                               CB = CB + ',' + t.SA_User__r.Name;
                           }  
                       } 
                       if(t.User_Division__c == 'Transactional Products and Services'){
                           if(t.Primary_Contact_Person__c){
                               TPS = TPS + ',' + '<b>'+t.SA_User__r.Name+'</b>';
                           }
                           else{
                               TPS = TPS + ',' + t.SA_User__r.Name;
                           }
                       }   
                       if(t.User_Division__c == 'Investment Banking'){
                           if(t.Primary_Contact_Person__c){
                               IB = IB + ',' + '<b>'+t.SA_User__r.Name+'</b>';
                           }
                           else{
                               IB = IB + ',' + t.SA_User__r.Name ;
                           }
                       } 
                       if(t.User_Division__c == 'Global Markets'){
                           if(t.Primary_Contact_Person__c){
                               GM = GM + ',' + '<b>'+t.SA_User__r.Name+'</b>';
                           }
                           else{
                               GM = GM + ',' + t.SA_User__r.Name ;
                           }
                       } 
                       if(t.User_Division__c == 'Real Estate'){
                           if(t.Primary_Contact_Person__c){
                               RE = RE + ',' + '<b>'+t.SA_User__r.Name+'</b>';
                           }
                           else{
                               RE = RE + ',' + t.SA_User__r.Name ;
                           }
                       }
                      if(t.User_Division__c == 'General Management' || t.User_Division__c == 'Business Enablers'){
                                 if(t.Primary_Contact_Person__c){
                                       Other = Other + ',' + '<b>'+t.SA_User__r.Name+'</b>';
                                   }
                                   else{
                                       Other = Other + ',' + t.SA_User__r.Name ;
                                   }
                        
                      }   
                   // if block for business enablers exclusion
               } //inner for loop
               
               CB = CB.substringAfter(',');
               if(CB != ''){
                   CBmap.put(c.id,CB);
               }
               CB = '';
               
               TPS = TPS.substringAfter(',');
               if(TPS != ''){
                   TPSmap.put(c.id,TPS);
               }
               TPS = '';
               
               IB = IB.substringAfter(',');
               if(IB != ''){
                   IBmap.put(c.id,IB);
               }       
               IB = '';
               
               GM = GM.substringAfter(',');
               if(GM != ''){
                   GMmap.put(c.id,GM);
               }
               GM = '';
               
               RE = RE.substringAfter(',');
               if(RE != ''){
                   REmap.put(c.id,RE);
               }
               RE = '';
               
               Other = Other.substringAfter(',');
               if(Other != ''){
                   Othermap.put(c.id,Other);
               }
               Other = '';
               
          }//outer for loop
          
          
          
          system.debug('CBMAP-------------->'+CBmap);
          system.debug('TPSMAP-------------->'+TPSmap);
          system.debug('IBMAP-------------->'+IBmap);
          system.debug('GMMAP-------------->'+GMmap);
          system.debug('REMAP-------------->'+REmap);
          system.debug('OtherMAP-------------->'+Othermap);
        scrollbar();
        EditKCC();
      }// End of KccData
       
       
       
       public void scrollbar(){ 
           if(rowsize <= 4){
                   scroll = false;
           }    
           else{
               scroll = true;
           }
       }//End of scrollbar 
       
        public void EditKCC(){
         List<Key_Client_Contact__c> kcc_delete = new List<Key_Client_Contact__c> ();
         
         Set<Id> contactExist = new Set<Id>();
         
         kcc_delete = [SELECT id, Client__c, Contact_Name__c, Contact_Name__r.Inactive__c, Contact_Name__r.Name, Contact_Name__r.Title, Contact_Name__r.Influence__c, Contact_Name__r.Relationship_Type__c
                       FROM Key_Client_Contact__c
                       WHERE client__c =  :clientid
                       AND Contact_Name__r.Inactive__c = false];
                       
         if(!kcc_delete.isempty()){
            for(Key_Client_Contact__c k :kcc_delete){
                if(!contactExist.contains(k.Contact_Name__c)){
                    contactExist.add(k.Contact_Name__c);
                    Delete_Wrap.add(new DeleteWrapper(k));
                }
                else{
                    duplicateKCC.add(k);
                }
                
            }
         }
       }//End of EditKCC
        
        public class DeleteWrapper{
            public Boolean ischeck {get;set;}
            public Key_Client_Contact__c kcc {get;set;}
            
            //Wrapper Class Constructor
            public DeleteWrapper( Key_Client_Contact__c kcc){
                this.ischeck = false;
                this.kcc   = kcc;
            }// End of wrapper constructor
        }// End of DeleteWrapper class
        
        public PageReference deleteKCC(){
            List<Key_Client_Contact__c> kccList_delete = new  List<Key_Client_Contact__c> ();
            
            for(DeleteWrapper w :Delete_Wrap){
            if(w.ischeck == true){
                Key_Client_Contact__c kcc_rec = new Key_Client_Contact__c ();
                
                kcc_rec.id = w.kcc.id;
                kcc_rec.Client__c = w.kcc.Client__c;
                kcc_rec.Contact_Name__c = w.kcc.Contact_Name__c;
                
                kccList_delete.add(kcc_rec);
            }
         }
         
         if(!kccList_delete.isEmpty()){
            try{
                DELETE kccList_delete ;
            }catch (DMLexception e){
                system.debug('Error while deleting key client contact(s)');
            }
         }
         
         if(duplicateKCC.size()>0){
            delete duplicateKCC ;
         }
         
         //Refresh logic
         
        PageReference pageref = returnPage();
        pageref.setRedirect(true);
        showwindow = false;
        showEditwindow = false;
        KCCData ();
        return pageref;
        
        }//End of deletekcc
        
        
            
    }//End of ClientContactController