/**
 * @description Selector class for Individual SObject
 *
 * @author Atul Sharma
 * @date March 2023
 */
@SuppressWarnings('PMD.ExcessivePublicCount')
public inherited sharing class SEL_Individuals extends fflib_SObjectSelector {
  /**
   * @description Creates a new instance of the selector via the application class. This is here to allow unit tests to override
   * and inject a mock instead of this class or to switch out this class for a new version.
   *
   * @return SEL_Individuals
   */
  public static SEL_Individuals newInstance() {
    return (SEL_Individuals) ORG_Application.selector.newInstance(
      Individual.SObjectType
    );
  }

  /**
   * @description Returns the SObject type for the selector. This is used to retrieve the sObject name when building the SOQL
   * queries.
   *
   * @return SObjectType
   */
  public SObjectType getSObjectType() {
    return Individual.SObjectType;
  }

  /**
   * @description Returns list of User fields
   *
   * @return list of SObjectField
   */
  public List<SObjectField> getSObjectFieldList() {
    return new List<Schema.SObjectField>{
      Individual.Id
      //add other fields
    };
  }

  /**
   * @description Selects Individual by Id
   *
   * @param ids list of Individual's Ids
   *
   * @return list of Individual
   */
  public List<Individual> selectById(Set<Id> ids) {
    return Database.query(
      newQueryFactory(false, false, true)
        .selectFields(
          new List<String>{
            'Id',
            'Name',
            'Email_Address__c',
            'HasOptedOutSolicit'
          }
        )
        .setCondition('Id IN :ids')
        .toSOQL()
    );
  }

  /**
   * @description Selects Individual ids from Contact
   *
   * @param cons list of Contact
   *
   * @return list of Individual ids
   */
  public Set<Id> getIdsFromContactList(Contact[] cons) {
    Set<Id> indIds = new Set<id>();
    for (Contact c : cons) {
      indIds.add(c.IndividualId);
    }
    return indIds;
  }

  /**
   * @description Selects Individual by Contact Id
   * @param conIds list of Contact Ids
   * @return list of Individual
   */
  public List<Individual> selectByIndividualIdOrFirstNameLastNameEmail(
    String individualId,
    String firstName,
    String lastName,
    String email
  ) {
    return Database.query(
      newQueryFactory(false, false, true)
        .selectFields(new List<String>{ 'Id', 'HasOptedOutSolicit', 'FirstName', 'LastName', 'Email_Address__c' })
        .setCondition(
          'Id = :individualId OR (FirstName = :firstName AND LastName = :lastName AND Email_Address__c = :email)'
        )
        .toSOQL()
    );
  } 
}