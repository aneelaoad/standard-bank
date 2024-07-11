@isTest
public with sharing class CTRL_MallAuthSolutionsTest  {   
    
    @isTest
    static void testGetMySolutions() {
        List<CTRL_MallAuthSolutions.MySolution> solution1 = new List<CTRL_MallAuthSolutions.MySolution>();
        CTRL_MallAuthSolutions.MySolution mySolution1 = new CTRL_MallAuthSolutions.MySolution('U-Count rewards', 'You are on tier', '/sfsites/c/resource/sbgIcons/OTHER/icn_u-counticon.svg', 'Reward Points', '45,000', 'https://ucount.standardbank.co.za/business/', 'Get Details', false, true);
		   
        
        solution1.Add(mySolution1);
			

        Test.startTest();
        
        List<CTRL_MallAuthSolutions.MySolution> lstOfMySolution = CTRL_MallAuthSolutions.getMySolutions();  
       
        Test.stopTest();
    }



  

   

  
  
    
  
}