/*****************************************************************************************************\ 
    @ Last Modified by : Nitish Kumar
    @ Last Modified on : 6 March 2013
    @ Modification Description : Removed the Test Method from the class as this is not needed
                                 Class already being covered from StdBank_OpptyProdRedirect_Vf_Ext_Test
                                 Changed the API version from 15 to 27
******************************************************************************************************/

public class StdBank_SystemParams {
    
    // The current system (production, sandbox etc)
    private static String CURRENT_SYSTEM;
    
    // Set of needed parameters
    private static Map<String,String> PARAMETERS;
    
    // For throwing an exception if the admin has not set up the Environment parameter
    
    public class ConfigException extends Exception {}
    
    // Initialise once only (hence static)
    static {
        
        // Read in the system name - will only be 1 but do as a list to prevent a crash
        // if config is not correct - in which case throw an exception
        List<System_Parameter__c> sysNames = [Select Value__c From System_Parameter__c Where Name = 'Environment' Limit 1];
        if (sysNames.size() != 1) {
            throw new ConfigException('No "Environment" parameter in System Parameters!');
        }
        CURRENT_SYSTEM = sysNames[0].value__c;
        
        // Pull in all parameters for this system or All systems !  Shift them into the static list of parameters
        List<System_Parameter__c> params = [Select Name, Value__c From System_Parameter__c Where Environment__c in ('Same for All',:CURRENT_SYSTEM)];
        PARAMETERS = new Map<String,String>();
        for (System_Parameter__c param : params) {
            PARAMETERS.put(param.Name, param.Value__c);
        } // end loop through parameters
    } // end of static block
    
    // Return the requested parameter
    public static String getParam(String pName) {
        return PARAMETERS.get(pName);
    } // end getParam
   
} // end of class