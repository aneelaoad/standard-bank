/***********************************************************    
    @ Author        : Caro Reinecke
    @ Date          : 23/11/2012
    @ Description   : Unknown

    @ Last Modified : Charles Mutsu
    @ Modify Date   : 16/07/2013
    @ Reason        : API Version moved from 26 to 27
                      
*************************************************************/ 
public with sharing virtual class ComponentControllerBase {
  
  public String key{
      get;
      set{
          if(value != null){
              Key  = value;
              if(pageController != null)
                  pageController.setComponentControllerMap(Key, this);
          }
      }
  }

  public PageControllerBase pageController { 
      get; 
      set {
          if (value != null) {
            pageController = value;
            pageController.setComponentController(this);
          }
      }
  }
  public static TestMethod void testAll() {
    ComponentControllerBase testComponentControllerBase = new ComponentControllerBase();
    PageControllerBase testPageControllerBase = new PageControllerBase();
    testPageControllerBase.getThis();   
  }
}