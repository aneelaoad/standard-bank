/**
 * @description MallChatPreUIController for chat bot
 * @author Maham Hassan
 * @since 
 */
public with sharing class MallChatPreUIController {

    @TestVisible
    private static String testUserId;

    /**
     * 
     * @description getCurrentUser
     * @return String
     */
    @AuraEnabled
    public static String getCurrentUser()
    {
        Map<String,Object> output = new Map<String,Object>();
        try
        {
            String userId = Test.isRunningTest() ? testUserId : UserInfo.getUserId();
            List<User> users = SEL_Users.newInstance().selectById(new Set<Id>{(Id)userId});
            if(users.size() > 0)
            {
                output.put('userId', users.get(0).UserName);
                output.put('firstName', users.get(0).FirstName);
                output.put('lastName', users.get(0).LastName);
                output.put('email', users.get(0).Email);
            } 
            else 
            {
                output.put('userId', '');
            }
        } 
        catch(Exception e) 
        {
            MallExceptionUtil.LOGGER.error('MallChatPreUIController.getCurrentUser', e);
            throw MallExceptionUtil.throwAuraException('MallChatPreUIController.getCurrentUser', e);
        }
        return JSON.serialize(output);
    }
}