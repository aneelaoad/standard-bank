/***************************************************************************************
@ Author            : silva.macaneta@standardbank.co.za
@ Date              : 10-03-2023
@ Name of the Class : CIB_CTRL_ApplicationLineItem
@ Description       : This class is used to store the checkbox label and value
@ Last Modified By  : 10-03-2023
@ Last Modified On  : silva.macaneta@standardbank.co.za
@ Modification Description : SFP-21988
***************************************************************************************/
public class CIB_VF_ItemList {
  /**
   * @description : This class is used to get the picklist values from a given object and field
   */
  public string value { get; set; }

  /**
   * @description : This class is used to get the picklist values from a given object and field
   */
  public List<String> options {
    get {
      if (value == null) {
        return new List<String>();
      }

      return value.split(';');
    }
    set;
  }
}