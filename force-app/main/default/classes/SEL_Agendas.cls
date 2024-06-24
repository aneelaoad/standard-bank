/**
 *
 * @author Nikita Haruk
 * @date 14-09-2023
 * @description Description: Agenda Selector Layer class.
 * 
 */

/*************************************************************************
	@ Last Modified By  : Augustine Chirombo
    @ Last Modified On  : October 25, 2023
    @ Modification Description : adding select fields to select by event report id
****************************************************************************/
@SuppressWarnings('PMD.CognitiveComplexity')
public inherited sharing class SEL_Agendas extends fflib_SObjectSelector {

    /**
     * @description getSObjectFieldList
     * @return List<Schema.SObjectField>
     */
    public List<Schema.SObjectField> getSObjectFieldList() {

        return new List<Schema.SObjectField> {
            Agenda__c.Name,
            Agenda__c.Id,
            Agenda__c.OwnerId,
            Agenda__c.Chairperson__c,
            Agenda__c.Event_Report__c,
            Agenda__c.NBAC_Status__c,
            Agenda__c.NBAC_Id__c,
            Agenda__c.NBAC_Name__c,
            Agenda__c.NBAC_Secretary__c,
            Agenda__c.Related_NBAC__c
        };
    }

    /**
     * @description selectById
     * @return Schema.SObjectType
     */
    public Schema.SObjectType getSObjectType() {
        return Agenda__c.sObjectType;
    }

	/**
	 * @description Creates a new instance of the selector via the application class. This is here to allow unit tests to override
	 * and inject a mock instead of this class or to switch out this class for a new version.
	 * @return SEL_Agendas
	 */
	public static SEL_Agendas newInstance() {
		return(SEL_Agendas) ORG_Application.selector.newInstance(Agenda__c.SObjectType);
	}

    /**
     * @description Select agenda records by Event Report Ids 
     *
     * @param ids Set of Ids of Event Reports
     *
     * @return List of Agendas
     */
    public List<Agenda__c> selectByEventReportIds (Set<Id> eventReportIds) {
        return (List<Agenda__c>) Database.query(
            newQueryFactory()
                .selectField('Related_NBAC__r.Group_Parent_Client_Coordinator__c')
                .selectField('Related_NBAC__r.Group_Parent_Client_Name__c')
                .selectField('Related_NBAC__r.MNPI__c')
                .selectField('Related_NBAC__r.Submission_Type__c')
            	.selectField('Related_NBAC__r.Id')
                .selectField('Related_NBAC__r.Name')
                .selectField('Related_NBAC__r.Milestone__c')
            	.selectField('Related_NBAC__r.Approval_Status__c')
                .selectField('Related_NBAC__r.Committee_Commentary__c')
                .setCondition('Event_Report__c IN :eventReportIds')
                .toSOQL()
        );
    }

    /**
     * @description Select agenda records by NBAC Ids 
     *
     * @param ids Set of Ids of NBACs(Business Assessment records)
     *
     * @return List of Agendas
     */
    public List<Agenda__c> selectByNBACIds (Set<Id> nbacIds) {
        return (List<Agenda__c>) Database.query(
            newQueryFactory()
                .selectField('Event_Report__r.Id')
                .selectField('Event_Report__r.NBAC_Committee__c')
                .selectField('Event_Report__r.Location__c')
                .selectField('Event_Report__r.Start__c')
                .selectField('Event_Report__r.End__c')
                .selectField('Event_Report__r.Subject__c')
                .selectField('Event_Report__r.Chairperson__r.Name')
                .selectField('Event_Report__r.NBAC_Secretary__r.Name')
                .selectField('Related_NBAC__r.Id')
                .selectField('Related_NBAC__r.Name')
                .selectField('Related_NBAC__r.Committee_Commentary__c')
                .selectField('Related_NBAC__r.MNPI__c')
                .selectField('Related_NBAC__r.NBAC_Meeting_Date__c')
                .selectField('Related_NBAC__r.Submission_Type__c')
                .selectField('Related_NBAC__r.Milestone__c')
                .selectField('Related_NBAC__r.Approval_Status__c')
                .setCondition('Related_NBAC__c IN :nbacIds')
                .toSOQL()
        );
    }
}