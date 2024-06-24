/*****************************************************************************************************\
    @ Func Area     : Draw_Down_Profile__c, Draw Down profile Trigger
    @ Author        : Rudolf Niehaus
    @ Date          : 03/07/2012
    @ Test File     : Test Method DrawDownProfile_Vf_Ext_Test
    @ Description   : case#141:
                    Trigger helper class that makes sure that triggers updating objects
                    visa versa do not run into an endless loop  
    -------------------------------------------------------------------------------------
    @ Func Area         : 
    @ Last Modified By  : 
    @ Last Modified On  : 
    @ Modification Description : 
******************************************************************************************************/
public class DrawDownProfileTrigger_HelperClass {

    private static boolean eventFired = false;
        
    public static boolean hasEventFired(){
        return eventFired;
    }

    public static void setEventFired(){
        eventFired = true;
    }

}