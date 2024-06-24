@isTest
private class TriggerManager_Test {
	
	@isTest
	private static void executeNotTriggerContext (){
		Boolean isExceptionThrown = false;
		Boolean properExceptionThrown = false;
		
		Test.startTest();
			try{
				TriggerManager.instance.execute();
			}
			catch (TriggerManager.TriggerManagerException e){
				isExceptionThrown = true;
				properExceptionThrown = true;			
			}
			catch(Exception e){
				isExceptionThrown = true;
			}
		Test.stopTest();

		System.assert(isExceptionThrown, 'Expected Exception');
		System.assert(properExceptionThrown, 'Expected TriggerManagerException ');
	}



}