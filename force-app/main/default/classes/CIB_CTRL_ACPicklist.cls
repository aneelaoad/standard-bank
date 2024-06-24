/***************************************************************************************
@ Author            : silva.macaneta@standardbank.co.za
@ Date              : 10-03-2023
@ Name of the Class : CIB_CTRL_ACPicklist
@ Description       : A class that loads picklist values for a given object and field name.
@ Last Modified By  : silva.macaneta@standardbank.co.za
@ Last Modified On  : 10-03-2023
@ Modification Description : SFP-24811
***************************************************************************************/
public without sharing class CIB_CTRL_ACPicklist {
  /**
   * @description A method that loads picklist values for a given object and field name.
   * @param sObjectName The API name of the object that contains the picklist field.
   * @param sFieldName The API name of the picklist field.
   * @return A list of PickListWrapper objects that contain the label and value of each picklist value.
   */
  @AuraEnabled
  public static List<PickListWrapper> loadData(
    String sObjectName,
    String sFieldName
  ) {
    List<PickListWrapper> pickListOptions = new List<PickListWrapper>();
    Schema.DescribeFieldResult field = Schema.getGlobalDescribe()
      .get(sObjectName)
      .getDescribe()
      .fields.getMap()
      .get(sFieldName)
      .getDescribe();
    List<Schema.PicklistEntry> picklistValues = field.getPicklistValues();
    for (Schema.PicklistEntry picklistValue : picklistValues) {
      PickListWrapper picklist = new PickListWrapper();
      picklist.value = picklistValue.getValue();
      picklist.label = picklistValue.getLabel();
      pickListOptions.add(picklist);
    }
    return pickListOptions;
  }

  /**
   * @description A wrapper class that contains the label and value of a picklist value.
   */
  public class PickListWrapper {
    /**
     * @description The label of the picklist item.
     */
    @AuraEnabled
    public String label { get; set; }

    /**
     * @description The value of the picklist item.
     */
    @AuraEnabled
    public String value { get; set; }
  }
}