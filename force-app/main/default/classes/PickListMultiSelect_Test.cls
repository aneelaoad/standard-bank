/******************************************************************************************************************************
* Name        - PickListMultiSelect_Test
* Description - Test Class for PickListMultiSelect Controller
* Modification Log :
* ---------------------------------------------------------------------------
* Developer                   Date                   Description
* ---------------------------------------------------------------------------
* Abhishek                  17/03/1026                 Created
*******************************************************************************************************************************/

@isTest
public class PickListMultiSelect_Test{
    public static testmethod void testMultiselectPicklist_withfieldsSelected(){
         List<Hierarchy_Fields__c> hrlst = new List<Hierarchy_Fields__c>();
         Hierarchy_Fields__c hf1 = new Hierarchy_Fields__c(Name = 'Account::CIF__c', Field_Label__c = 'CIF Number', Object_Name__c = 'Account', Sort_Order__c = 1);
         Hierarchy_Fields__c hf2 = new Hierarchy_Fields__c(Name = 'Account::Client_Sector__c', Field_Label__c = 'Client Sector', Object_Name__c = 'Account', Sort_Order__c = 2);
         hrlst.add(hf1);
         hrlst.add(hf2);
         insert hrlst;
         PickListMultiSelect controller = new PickListMultiSelect();
         controller.describeObject();
         controller.getAvblFields();
         controller.getAvblobjects();
         controller.getFieldsInSelectList();
         List<String> parameters = new List<String>();
         parameters.add('Test Parameter');
         controller.setFieldsSelected(parameters);
         controller.getFieldsSelected();
         controller.addFields();
         controller.getAvblFields();
         controller.getFieldsInSelectList();
         controller.setremoveList(parameters);
         controller.getremoveList();
         controller.removeFields();
         controller.getAvblFields();
         controller.SaveHierarchyColumns();
         System.assertEquals(controller.ObjectSelected, 'Account');
         System.assertEquals(controller.showOrderSort, True);
         System.assertEquals(controller.Selected.size() , 2);
         controller.back();
   }
   public static testmethod void testMultiselectPicklist_withnoneSelected(){
         PickListMultiSelect controller = new PickListMultiSelect();
         controller.describeObject();
         controller.getAvblFields();
         controller.getAvblobjects();
         controller.getFieldsInSelectList();
         List<String> parameters = new List<String>();
         parameters.add('Test Parameter');
         controller.setFieldsSelected(parameters);
         controller.getFieldsSelected();
         controller.addFields();
         controller.getAvblFields();
         controller.getFieldsInSelectList();
         controller.setremoveList(parameters);
         controller.getremoveList();
         controller.removeFields();
         controller.getAvblFields();
         controller.SaveHierarchyColumns();
         System.Debug(controller.showOrderSort);
         System.assertEquals(controller.ObjectSelected, 'Account');
         System.assertEquals(controller.Selected.size() , 0);
         controller.back();
   }
}