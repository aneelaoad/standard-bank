/**
 * @description MallContentDataService
 * @author Ankit Kumar
 * @since 
 */
public with sharing class MallContentDataService {
    /**
     * 
     * @description This method queries the Tag/Content by Country
     * @param countries List<String>
     * @param recordTypes List<String>
     * @return List<DenormalizedContent>
     */
    public List<DenormalizedContent> getContentsByCountryNamesAndRecordTypes(List<String> countries, List<String> recordTypes) {
       /*Need to use knowledge object for content*/
       return new List<DenormalizedContent>();
    } 

    /**
     * 
     * @description getContentsByRootTagNames
     * @param rootTagNames List<String>
     * @param tagNames List<String>
     * @param recordTypes List<String>
     * @return  List<DenormalizedContent>
     */
    public List<DenormalizedContent> getContentsByTagsRootTagsAndRecordTypeNames(List<String> rootTagNames, List<String> tagNames, List<String> recordTypes) {
        /*Need to use knowledge object for content*/
        return new List<DenormalizedContent>();
    }
    

    /**
     * 
     * @description getContentsByTagIdsAndRecordTypeNames
     * @param rootTagNames List of String
     * @param tagIds  List of String
     * @param recordTypes  List of String
     * @return  List<DenormalizedContent>
     */
    public List<DenormalizedContent> getContentsByTagIdsRootNamesAndRecordTypeNames (List<String> rootTagNames, List<String> tagIds, List<String> recordTypes) {
        /*Need to use knowledge object for content*/
        return new List<DenormalizedContent>();
    }
}