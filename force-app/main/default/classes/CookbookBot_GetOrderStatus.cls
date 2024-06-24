public with sharing class CookbookBot_GetOrderStatus {
  public class OrderOutput {
    @InvocableVariable(required=true)
    public Boolean confirmedEmailStatus;
  }
  public class OrderInput {
    @InvocableVariable(required=true)
    public String emailAddress;
    
    @InvocableVariable(required=true)
    public String confirmEmailAddress;
  }
  @InvocableMethod(label='Get Order Status')
  public static List<OrderOutput> getOrderStatus(List<OrderInput> orderInputs) {
  
    // Build a list of order status values for the output
    List<OrderOutput> orderOutputs = new List<OrderOutput>();
    
   return orderOutputs;
   }  
}