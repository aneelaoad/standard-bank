public without sharing class NBACMeetingAgendaVFComController {
public id callreport{get;set;}

public String otmString{get;set;}
public String otmLocation{get;set;}
public String omtNBACCommite{get;set;}
public Id outputId{get;set;}
public string startDateOutput{get;set;}
public list<Business_Assessment__c> NBACs {get;set;}

public string startTimeOutput{get;set;}
public string endTimeOutput{get;set;}
public string timeZoneFullName{get;set;}

public string chairpersonOutput{get;set;}
public string nbacSecretaryoutput{get;set;}

public date agendaMeetingDate{get;set;}

public string outputSubject{get;set;}
public string meetingNotes{get;set;}

public list<wrapperAgenda> datas{
    get {
            if(datas != null) {
                return datas;
            }
            else {
                datas = getData();
                return datas;
            }
        }
    set;
}

    private Map<String, String> value2TimeZones {
        get {
            if(value2TimeZones != null) {
                return value2TimeZones;
            } else {
                List<Schema.PicklistEntry> entries = User.TimeZoneSidKey.getDescribe().getPicklistValues();
                value2TimeZones = new Map<String, String>();
                for(Schema.PicklistEntry entry : entries) {
                    value2TimeZones.put(entry.getValue(), entry.getLabel());
                }
                return value2TimeZones;
            }
        } private set;
    }

    public String timeZone {get;set;}

    list<Business_Assessment__c> listOppMembers {get;set;}
    public list<Call_Report__c> listCallReports {get;set;}
    public list<wrapperAgenda> lstAgendas {get;set;}
    private final Set<String> submissionForNoting = new Set<String> {'Type 1: For noting purposes'};

     public class wrapperAgenda{
          public Agenda__c agenda{get;set;}
          public String oppTeamMembers{get;set;}
          public String attId{get;set;}

          public wrapperAgenda(Agenda__c thisAgenda){
              agenda = thisAgenda;
              oppTeamMembers = '';
          }
     }

    public list<wrapperAgenda> getNBACSforApproval() {
        list<wrapperAgenda> NBACSforApproval = new list<wrapperAgenda> ();
        for(WrapperAgenda nbac : datas)  {
            if(!submissionForNoting.contains(nbac.agenda.Related_NBAC__r.Submission_Type__c)) {
                NBACSforApproval.add(nbac);
            }
        }
        return NBACSforApproval;
    }

    public list<wrapperAgenda> getNBACSforNoting() {
        list<wrapperAgenda> NBACSforNoting = new list<wrapperAgenda> ();
        for(WrapperAgenda nbac : datas) {
            if(submissionForNoting.contains(nbac.agenda.Related_NBAC__r.Submission_Type__c)) {
                NBACSforNoting.add(nbac);
            }
        }
        return NBACSforNoting;
    }

    @TestVisible
    private list<wrapperAgenda> getData(){
    if(callreport==null){
        return null;
    }else{
        Map<Id, wrapperAgenda> mapOfAgendsByOppIds;
     
        listCallReports = [SELECT NBAC_Committee__c,
                                  Location__c,  
                                  Start__c, 
                                  End__c,
                                  Subject__c,
                                  Meeting_Notes__c,
                                  Chairperson__r.Name,
                                      (Select Name, 
                                              Related_NBAC__r.Name,
                                              Related_NBAC__r.Id,
                                              Related_NBAC__r.MNPI__c,
                                              Related_NBAC__r.NBAC_Meeting_Date__c,
                                              Related_NBAC__r.Submission_Type__c,
                                              Related_NBAC__r.Milestone__c
                                                  FROM Agenda__r
                                                      WHERE Event_Report__c =: callreport AND (Related_NBAC__r.Milestone__c = 'Submitted' or Related_NBAC__r.Milestone__c = 'Supported' or Related_NBAC__r.Milestone__c = 'Approval'))
                                  FROM Call_Report__c WHERE id =:callreport];

        omtNBACCommite = listCallReports[0].NBAC_Committee__c;
        list<Id>relatedOppId = new list<Id>();
        otmLocation = listCallReports[0].Location__c;
        DateTime otmStart = listCallReports[0].Start__c;
        
        chairpersonOutput = listCallReports[0].Chairperson__r.Name;
        
        startDateOutput = otmStart.format('EEEEE, dd MMM yyyy');
        startTimeOutput = otmStart.format('hh:mm a');
        
        DateTime otmEnd = listCallReports[0].End__c;
        endTimeOutput = otmEnd.format('hh:mm a');

        timeZone = value2TimeZones.get(UserInfo.getTimeZone().toString());
        
        outputSubject = listCallReports[0].Subject__c;
        meetingNotes = listCallReports[0].Meeting_Notes__c;
        
        mapOfAgendsByOppIds = new Map<Id, wrapperAgenda>(); 
        for(Agenda__c objAgenda :listCallReports[0].Agenda__r){
            mapOfAgendsByOppIds.put(objAgenda.Related_NBAC__r.Id,new wrapperAgenda(objAgenda));
            relatedOppId.add(objAgenda.Related_NBAC__r.Id);
            
        }
        if(relatedOppId == null){
            return null;
        }else{
            listOppMembers = [Select Id, (Select Id From Attachments Order By lastModifiedDate DESC LIMIT 1),
                                        (Select UserOrGroup.Name, UserOrGroup.Id, ParentId From Shares)
                            From Business_Assessment__c
                            Where Id IN :mapOfAgendsByOppIds.keySet()];
            Map<Id ,contentDocumentLink > mappedConDoc = new Map<Id ,contentDocumentLink >();
            Map<Id ,String > mappedEntityIdConvsionId = new Map<Id ,String>();
            List<ContentDocumentLink> contentDocumentLink = [SELECT ContentDocumentId ,LinkedEntityId FROM ContentDocumentLink
                                                        WHERE LinkedEntityId IN:mapOfAgendsByOppIds.keySet()];
            for (ContentDocumentLink conDoc :contentDocumentLink){
                mappedConDoc.put(conDoc.ContentDocumentId,conDoc);

            }
            List<Contentversion> conVersionList = [Select id,ContentDocumentId, lastModifiedDate from Contentversion
                                                    where ContentDocumentId IN:mappedConDoc.keySet() AND IsLatest=true Order By lastModifiedDate DESC ];
            for (Contentversion convsion :conVersionList){
                ContentDocumentLink conDocLink =  mappedConDoc.get(convsion.ContentDocumentId);
                if(mappedEntityIdConvsionId.get(conDocLink.LinkedEntityId)==null) {
                    mappedEntityIdConvsionId.put(conDocLink.LinkedEntityId,convsion.id);
                }
            }
            //atts = [SELECT id, name, parentId, owner.name, ownerId, createdBy.name, lastModifiedBy.name, lastModifiedDate FROM Attachment WHERE parentId IN :mapOfAgendsByOppIds.keySet() ORDER BY lastModifiedDate DESC];
            otmString = '';
                wrapperAgenda temp;
                for(Business_Assessment__c otm : listOppMembers){
                    temp = mapOfAgendsByOppIds.get(otm.Id);
                    if(temp !=null){
                        //temp.oppTeamMembers +=  otm.UserOrGroup.Name+ ', ';
                        if(String.isBlank(mappedEntityIdConvsionId.get(otm.Id))) {
                            for (Attachment att : otm.Attachments) {
                                temp.attId = '/servlet/servlet.FileDownload?file='+ att.Id;
                            }
                        }
                        else {
                            temp.attId = '/sfc/servlet.shepherd/version/download/'+mappedEntityIdConvsionId.get(otm.Id);
                        }
                        Set<Id> nbacTeamIds = new Set<Id>();
                        for(Business_Assessment__Share baShare : otm.Shares) {
                            if(!nbacTeamIds.contains(baShare.UserOrGroup.Id)) {
                                nbacTeamIds.add(baShare.UserOrGroup.Id);
                                if(String.isNotBlank(baShare.UserOrGroup.Name))
                                    temp.oppTeamMembers += baShare.UserOrGroup.Name + ', ';
                            }
                        }
                    }

                }
                for(wrapperAgenda resultMembers: mapOfAgendsByOppIds.values()){
                    resultMembers.oppTeamMembers = resultMembers.oppTeamMembers.removeEnd(', ');
                
                }
               
                return mapOfAgendsByOppIds.values();
          }
        }
    }  
}