public with sharing class TagSuccessStoriesSelector {
    /**
     * @description getTagSuccessStoriesWhere
     * @param whereClause 
     * @return  `List<Tag_Success_Story__c>`
     */
    public List<Tag_Success_Story__c> getTagSuccessStoriesWhere(String whereClause) {
        String whereClauseString=String.IsEmpty(whereClause)?'':'( ' + whereClause + ' )'+' AND';
        String query = 'SELECT Id, Name, Tag__c, Success_Story__c,Success_Story__r.Customer_feedback__c,Success_Story__r.Customer_Full_Name__c,Success_Story__r.Customer_Image_Url__c, Success_Story__r.Banner_Image__r.Image_Url__c, Success_Story__r.Challenge__c, ' 
        + 'Success_Story__r.isOnline__c, Success_Story__r.Context__c, Success_Story__r.Image_Gallery__c, Success_Story__r.Language__c, Success_Story__r.Language__r.Name, '
        + 'Success_Story__r.Id, Success_Story__r.Name, Success_Story__r.Outcome__c, Success_Story__r.Parent_Success_Story__c, Success_Story__r.Solution__c, ' 
        + 'Success_Story__r.Summary__c, Success_Story__r.RecordTypeId, Success_Story__r.RecordType.Name, '
        + 'Tag__r.Id, Tag__r.Name,Tag__r.Parent_Name__c, Tag__r.Root_Name__c, Tag__r.Root__c, Success_Story__r.Publishing_Unit__c, '
        + 'Success_Story__r.Video_Testimony__r.DeskTop_Url__c, Success_Story__r.Video_Testimony__r.Mobile_Url__c, Success_Story__r.Video_Testimony__r.Guest_url__c, '
        + 'Success_Story__r.Publishing_Unit__r.isPublished__c, Success_Story__r.Publishing_Unit__r.Published_From__c,Success_Story__r.Publishing_Unit__r.Published_Until__c, '
        + 'Success_Story__r.CreatedDate,Tag__r.Parent__r.Name '
        + 'FROM Tag_Success_Story__c ' 
        + 'WHERE '
        + whereClauseString 
        + ' Success_Story__r.isOnline__c = TRUE ';
        List<Tag_Success_Story__c> results = Database.query(String.valueof(query));
        return results;
    }
}