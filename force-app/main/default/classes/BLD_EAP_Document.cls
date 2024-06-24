/**
 * @description       : Builder class for EAP_Document__c SObject
 * @author            : TCK
 * @group             : 
 * @last modified on  : 06-23-2022
 * @last modified by  : TCK
 * Modifications Log 
 * Ver   Date         Author   Modification
 * 1.0   07-28-2021   TCK   Initial Version
**/
public without sharing class BLD_EAP_Document extends ABS_ObjectBuilderBase {

    public static final String DEF_NAME = 'testEAP_Event';
    public static final String DEF_TYPE = 'Documentation';
    public static final String TYPE_TICKET = 'Ticket';
    public static final String TYPE_FLIGHT_TICKET = 'Flight Ticket';
    public static final String TYPE_PRESENTATION = 'Presentation';
    public static final String TYPE_PICTURE = 'Picture';
    public static final String TYPE_DOCUMENTATION = 'Documentation';

    private static Integer counter = 0;
    
    /**
    * @description 
    * @author TCK | 06-14-2022 
    **/
    public BLD_EAP_Document() {
        this(getNewUnitOfWork());
    }

    /**
    * @description 
    * @author TCK | 06-14-2022 
    * @param uow 
    **/
    public BLD_EAP_Document(fflib_SObjectUnitOfWork uow) {
        super(EAP_Document__c.SObjectType, uow);
    }

    /**
    * @description 
    * @author TCK | 06-14-2022 
    * @param sObj 
    * @param workUnit 
    **/
    public BLD_EAP_Document(EAP_Document__c sObj, fflib_SObjectUnitOfWork workUnit) {
        super(sObj, workUnit);
    }

    /**
    * @description 
    * @author TCK | 06-14-2022 
    **/
    protected override void setDefaultData() {
        setField(EAP_Document__c.Name, counter + DEF_NAME + counter)
        .setField(EAP_Document__c.EAP_Type__c,DEF_TYPE);

        counter++;
    }

    /**
    * @description 
    * @author TCK | 06-14-2022 
    * @return BLD_EAP_Document 
    **/
    public BLD_EAP_Document ticketDocument() {
		return(BLD_EAP_Document) setField(EAP_Document__c.EAP_Type__c, TYPE_TICKET);
	}

    /**
    * @description 
    * @author TCK | 06-14-2022 
    * @return BLD_EAP_Document 
    **/
    public BLD_EAP_Document flightTicketDocument() {
		return(BLD_EAP_Document) setField(EAP_Document__c.EAP_Type__c, TYPE_FLIGHT_TICKET);
	}

    /**
    * @description 
    * @author TCK | 06-14-2022 
    * @return BLD_EAP_Document 
    **/
    public BLD_EAP_Document presentationDocument() {
		return(BLD_EAP_Document) setField(EAP_Document__c.EAP_Type__c, TYPE_PRESENTATION);
	}

    /**
    * @description 
    * @author TCK | 06-14-2022 
    * @return BLD_EAP_Document 
    **/
    public BLD_EAP_Document documentation() {
		return(BLD_EAP_Document) setField(EAP_Document__c.EAP_Type__c, TYPE_DOCUMENTATION);
	}

    /**
    * @description 
    * @author TCK | 06-14-2022 
    * @return BLD_EAP_Document 
    **/
    public BLD_EAP_Document pictureDocument() {
		return(BLD_EAP_Document) setField(EAP_Document__c.EAP_Type__c, TYPE_PICTURE)
        .setField(EAP_Document__c.EAP_AppEventPhoto__c, 'Main Photo');
	}

    /**
    * @description 
    * @author TCK | 06-14-2022 
    * @param eventBuilder 
    * @return BLD_EAP_Document 
    **/
    public BLD_EAP_Document event(BLD_EAP_AppEvent eventBuilder) {
        return (BLD_EAP_Document) setRelation(EAP_Document__c.EAP_AppEvent__c, eventBuilder);
    }

    /**
    * @description 
    * @author TCK | 06-14-2022 
    * @param eventBuilder 
    * @return BLD_EAP_Document 
    **/
    public BLD_EAP_Document meeting(BLD_EAP_Meeting eventBuilder) {
        return (BLD_EAP_Document) setRelation(EAP_Document__c.EAP_Meeting__c, eventBuilder);
    }

    /**
    * @description 
    * @author TCK | 06-14-2022 
    * @param eventBuilder 
    * @return BLD_EAP_Document 
    **/
    public BLD_EAP_Document travel(BLD_EAP_TravelInformation eventBuilder) {
        return (BLD_EAP_Document) setRelation(EAP_Document__c.EAP_TravelInformation__c, eventBuilder);
    }

    /**
    * @description 
    * @author TCK | 06-14-2022 
    * @param eventBuilder 
    * @return BLD_EAP_Document 
    **/
    public BLD_EAP_Document venue(BLD_EAP_Venue eventBuilder) {
        return (BLD_EAP_Document) setRelation(EAP_Document__c.EAP_Venue__c, eventBuilder);
    }
}