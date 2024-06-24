/***************************************************************************************
@ Author            : silva.macaneta@standardbank.co.za
@ Date              : 10-03-2023
@ Name of the Class : CIB_CTRL_ApplicationLineItem
@ Description       : This class is used to store the checkbox label and value
@ Last Modified By  : 10-03-2023
@ Last Modified On  : silva.macaneta@standardbank.co.za
@ Modification Description : SFP-21988
***************************************************************************************/
public class CIB_VF_MultiPicklistCheckbox {
  /**
   * @description : This class is used to get the picklist values from a given object and field
   */
  public string value { get; set; }

  /**
   * @description : object name of the picklist field
   */
  public string objectApiName { get; set; }

  /**
   * @description : field name of the picklist field
   */
  public string fieldApiName { get; set; }

  /**
   * @description : options to be displayed in the picklist
   * @return List<SelectOption>
   */
  public List<SelectOption> options {
    get {
      List<SelectOption> options = new List<SelectOption>();
      for (
        string option : CIB_VF_MultiPicklistCheckbox.getPicklistValues(
          this.objectApiName,
          this.fieldApiName
        )
      ) {
        SelectOption selectOption = new SelectOption();
        selectOption.label = option;
        if(this.value != null) {
          selectOption.value = value.contains(option);
        } else {
          selectOption.value = false;
        }
        options.add(selectOption);
      }
      return options;
    }
  }

  /**
   * @description : This class is used to store the picklist values
   */
  public class SelectOption {
    /**
     * @description : label of the picklist value
     */
    public string label { get; set; }
    /**
     * @description : value of the picklist value
     */
    public Boolean value { get; set; }
  }

  /**
   * @description : This method is used to get the picklist values from a given object and field
   * @param objectName objectName - object name of the picklist field
   * @param fieldName - field name of the picklist field
   * @return List<String> - list of picklist values
   */
  public static List<String> getPicklistValues(
    String objectName,
    String fieldName
  ) {
    List<String> picklistValues = new List<String>();

    Schema.SObjectType objectType = Schema.getGlobalDescribe().get(objectName);

    if (objectType != null) {
      Schema.DescribeFieldResult fieldResult = objectType.getDescribe()
        .fields.getMap()
        .get(fieldName)
        .getDescribe();

      if (
        fieldResult != null &&
        (fieldResult.getType() == Schema.DisplayType.PICKLIST ||
        fieldResult.getType() == Schema.DisplayType.MULTIPICKLIST)
      ) {
        List<Schema.PicklistEntry> picklistEntries = fieldResult.getPicklistValues();
        for (Schema.PicklistEntry picklistEntry : picklistEntries) {
          picklistValues.add(picklistEntry.getLabel());
        }
      }
    }
    return picklistValues;
  }
}