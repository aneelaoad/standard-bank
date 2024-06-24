/*
 * 
 * @description Selector Class for customNotificationType 
 * @author Manasi Londhe
 * @since 
 */
public with sharing class CustomNotificationTypeSelector {
     /**
     * 
     * @description Find customNotificationType
     * @param whereClause String of where Clause
     * @return List of CustomNotificationType
     */
    public List<CustomNotificationType> getCustomNotificationTypeWhere(String whereClause) {
        String query =  'SELECT Id, DeveloperName '
                    +   ' FROM CustomNotificationType ' 
                    +   ' WHERE (' + whereClause + ')';
        List<CustomNotificationType> results = Database.query(query);
        return results;
    }
}