/**
* Test class for OSB_DeviceManagement_CTRL
* 
* @author Rasmi Panthangi (rasmi.panthangi@tetrad.co.za)
* @date April 2021
* 
*/
@isTest
public class OSB_DeviceManagement_CTRL_TEST {
    
    @isTest
    static void shouldCheckLoginStatus(){
        Test.startTest();
        Boolean isLoggedIn = OSB_DeviceManagement_CTRL.isUserLoggedIn();
        Test.stopTest();
        System.assert(isLoggedIn);
    }
    
    @isTest
    static void shouldGetDeviceDetails(){
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        OSB_SRV_NoknokIntegration serviceMock = ( OSB_SRV_NoknokIntegration) mocks.mock(OSB_SRV_NoknokIntegration.class);
        ORG_Application.service.setMock( OSB_SRV_NoknokIntegration.IService.class, serviceMock);
        Test.startTest();	
        Map<String,Map<String, Object>> responseMap = OSB_DeviceManagement_CTRL.getDeviceDetails();
        Test.stopTest();
        ((OSB_SRV_NoknokIntegration) mocks.verify(serviceMock,1)).getDeviceList();
    }
    
    @isTest
    static void shouldFailGetDeviceDetails(){
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        OSB_SRV_NoknokIntegration serviceMock = ( OSB_SRV_NoknokIntegration) mocks.mock(OSB_SRV_NoknokIntegration.class);
        Exception actualException;
        Test.startTest();	
        try {
            Map<String,Map<String, Object>> responseMap = OSB_DeviceManagement_CTRL.getDeviceDetails();
        } catch (Exception e) {
            actualException = e;
        }
        Test.stopTest();
        System.assertEquals(true, actualException.getMessage().contains('Attempt'), 'failed to get a device list');
    }
    
    @isTest
    static void shouldDeleteDevices(){
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        OSB_SRV_NoknokIntegration serviceMock = ( OSB_SRV_NoknokIntegration) mocks.mock(OSB_SRV_NoknokIntegration.class);
        ORG_Application.service.setMock( OSB_SRV_NoknokIntegration.IService.class, serviceMock);
        List<String> authList = new List<String>{'authHandle1','authHandle2'};
            Test.startTest();
        List<Map<String,String>> responseMap = OSB_DeviceManagement_CTRL.deleteDevices(authList );
        Test.stopTest();
        ((OSB_SRV_NoknokIntegration) mocks.verify(serviceMock, 1)).
            deleteRegisteredDevice(authList[0]);
    }
}