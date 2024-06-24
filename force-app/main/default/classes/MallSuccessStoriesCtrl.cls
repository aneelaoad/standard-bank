/**
 * 
 * @description MallSuccessStoriesCtrl
 * @author Ankit Kumar
 * @since 
*/
public with sharing class MallSuccessStoriesCtrl {

    public static final String DEFAULT_CONTENT_LANGUAGE_ISO = 'en';


    /**
     * 
     * @description This method queries the Tag/Success Stories by Country
     * @param countries List of Country Names
     * @return  List<DenormalizedSuccessStory>
     */
    @TestVisible
    public List<DenormalizedSuccessStory> getSuccessStoriesByCountryNames(List<String> countries) {
        Set<String> countriesSet = new Set<String>();
        countriesSet.addAll(countries);
        List<Tag_Success_Story__c> tagSuccessStories = SEL_TagSuccessStories.newInstance().selectByTagNames(countriesSet);

        SuccessStoriesTranslation mapStoryIdVsStory = new MallSuccessStoriesCtrl().prepareSuccessStoriesForLanguage(tagSuccessStories);   
        return new MallSuccessStoriesCtrl().denormalizeSuccessStory(tagSuccessStories, mapStoryIdVsStory);
    } 

    /**
     * 
     * @description This method queries the Tag/Success Stories by Country
     * @param successStoryIds List<String>
     * @return  List<DenormalizedSuccessStory>
     */
    public List<DenormalizedSuccessStory> getSuccessStoriesByIds(List<String> successStoryIds) {
        String whereClause = ' Success_Story__c IN (\'' + String.join(successStoryIds, '\',\'') + '\') AND Tag__r.Root_Name__c = \'Country\'';
        List<Tag_Success_Story__c> tagSuccessStories = SEL_TagSuccessStories.newInstance().selectByCustomFilterCondition(whereClause);

        SuccessStoriesTranslation mapStoryIdVsStory = new MallSuccessStoriesCtrl().prepareSuccessStoriesForLanguage(tagSuccessStories);   
        return new MallSuccessStoriesCtrl().denormalizeSuccessStory(tagSuccessStories, mapStoryIdVsStory);
    } 


    /**
	 * @description This method returns the content unit translation for Events for the user selected languages 
     * @param tagSuccessStories List<Tag_Success_Story__c>
     * @return SuccessStoriesTranslation
	*/
    public SuccessStoriesTranslation prepareSuccessStoriesForLanguage(List<Tag_Success_Story__c> tagSuccessStories) {
        Set<String> successStoryIds = new Set<String>();
        List<String> successStoryIdsLst = new List<String>();
        Set<String> imageContentUnitIds = new Set<String>();
        List<String> imageContentUnitIdslst = new List<String>();

        String userLanguage = new MallSuccessStoriesCtrl().getUserLanguage();

        for(Tag_Success_Story__c tagSuccessStory : tagSuccessStories) {
            successStoryIds.add(tagSuccessStory.Success_Story__c);
            imageContentUnitIds.add(tagSuccessStory.Success_Story__r.Image_Gallery__c);
        } 
        successStoryIdsLst.addAll(successStoryIds);
        imageContentUnitIdslst.addAll(imageContentUnitIds);

        List<Success_Story__c> successStoriesTranslationUnits = new List<Success_Story__c>();
        Map<Id,Success_Story__c> mapSuccessStoryIdAndContentTranslation = new Map<Id,Success_Story__c>();
        String whereClause = '';
        if(userLanguage == DEFAULT_CONTENT_LANGUAGE_ISO) {
            whereClause = 'Id IN (\'' + String.join(successStoryIds, '\',\'') + '\')';
        } else {
            whereClause = 'Parent_Success_Story__c IN (\'' + String.join(successStoryIds, '\',\'') + '\')';
            whereClause += ' AND Language__r.Name IN (\'' + String.join(new List<String>{userLanguage}, '\',\'') + '\')';
        }

        successStoriesTranslationUnits = SEL_SuccessStories.newInstance().selectByCustomFilterCondition(whereClause);

        Map<String, List<Content_Unit_Translation__c>> mapContentIdAndContentTranslation = new Map<String, List<Content_Unit_Translation__c>>();

        whereClause = ' Content_Unit__c IN (\'' + String.join(imageContentUnitIdslst, '\',\'') + '\')' + ' AND Content_Unit__r.hasImage__c = TRUE ';

        List<Content_Unit_Translation__c> contentUnitTranslationsForTags = SEL_ContentUnitTranslations.newInstance().selectByCustomFilterCondition(whereClause);
        
        for(Content_Unit_Translation__c cut : contentUnitTranslationsForTags) {
            if(mapContentIdAndContentTranslation.containsKey(cut.Content_Unit__c)) {
                List<Content_Unit_Translation__c> tempTranslations = mapContentIdAndContentTranslation.get(cut.Content_Unit__c);
                tempTranslations.add(cut);
                mapContentIdAndContentTranslation.put(cut.Content_Unit__c, tempTranslations);
            } else {
                mapContentIdAndContentTranslation.put(cut.Content_Unit__c, new List<Content_Unit_Translation__c>{cut});
            }
        }

        for(Success_Story__c successStoriesTranslationUnit: successStoriesTranslationUnits) {
            String key = (userLanguage == DEFAULT_CONTENT_LANGUAGE_ISO) ? successStoriesTranslationUnit.Id : successStoriesTranslationUnit.Parent_Success_Story__c;
            if(!mapSuccessStoryIdAndContentTranslation.containsKey(key)) {
                mapSuccessStoryIdAndContentTranslation.put(key, successStoriesTranslationUnit);  
            }
        }

        SuccessStoriesTranslation successStoriesTranslation = new SuccessStoriesTranslation();
        successStoriesTranslation.translatedContentMap = mapSuccessStoryIdAndContentTranslation;
        successStoriesTranslation.imageGalleryMap = mapContentIdAndContentTranslation;

        return successStoriesTranslation;
    }

    /**
     * 
     * @description SuccessStoriesTranslation
     */
    public class SuccessStoriesTranslation {
        public Map<Id,Success_Story__c> translatedContentMap;
        public Map<String, List<Content_Unit_Translation__c>> imageGalleryMap;
    }

    /**
     * 
     * @description This method denormalizes the Event based on tagSuccessStoriess and content and icon from CUT
     * @param tagSuccessStories List<Tag_Success_Story__c>
     * @param mapSuccessStoryIdAndContentTranslation SuccessStoriesTranslation
     * @return  List<DenormalizedSuccessStory>
     */
    public List<DenormalizedSuccessStory> denormalizeSuccessStory(List<Tag_Success_Story__c> tagSuccessStories, SuccessStoriesTranslation mapSuccessStoryIdAndContentTranslation) {
        List<DenormalizedSuccessStory> successStoriesDenormalized = new List<DenormalizedSuccessStory>();
        for(Tag_Success_Story__c tagSuccessStory: tagSuccessStories) {
            DenormalizedSuccessStory successStoryDenormalized = new DenormalizedSuccessStory();
            successStoryDenormalized.tagId=tagSuccessStory.Tag__c;
            successStoryDenormalized.tagName=tagSuccessStory.Tag__r.Name;
            successStoryDenormalized.id = tagSuccessStory.Success_Story__r.id;
            successStoryDenormalized.isOnline = tagSuccessStory.Success_Story__r.IsOnline__c;
            successStoryDenormalized.bannerImageUrl = tagSuccessStory.Success_Story__r.Banner_Image__r.Image_Url__c;
            successStoryDenormalized.videoTestimonyUrl = tagSuccessStory.Success_Story__r.Video_Testimony__r.DeskTop_Url__c;
            successStoryDenormalized.customerFeedback = tagSuccessStory.Success_Story__r.Customer_feedback__c;
            successStoryDenormalized.customerFeedbackFullName = tagSuccessStory.Success_Story__r.Customer_Full_Name__c;
            successStoryDenormalized.customerImage = tagSuccessStory.Success_Story__r.Customer_Image_Url__c;
            successStoryDenormalized.publishedFrom = (tagSuccessStory.Success_Story__r.Publishing_Unit__c != NULL) ? tagSuccessStory.Success_Story__r.Publishing_Unit__r.Published_From__c : NULL;
            if(mapSuccessStoryIdAndContentTranslation.translatedContentMap.containsKey(tagSuccessStory.Success_Story__c)) {
                successStoryDenormalized.name = mapSuccessStoryIdAndContentTranslation.translatedContentMap.get(tagSuccessStory.Success_Story__c).Name;
                successStoryDenormalized.summary = mapSuccessStoryIdAndContentTranslation.translatedContentMap.get(tagSuccessStory.Success_Story__c).Summary__c;
                successStoryDenormalized.context = mapSuccessStoryIdAndContentTranslation.translatedContentMap.get(tagSuccessStory.Success_Story__c).Context__c;
                successStoryDenormalized.challenge = mapSuccessStoryIdAndContentTranslation.translatedContentMap.get(tagSuccessStory.Success_Story__c).Challenge__c;
                successStoryDenormalized.solution = mapSuccessStoryIdAndContentTranslation.translatedContentMap.get(tagSuccessStory.Success_Story__c).Solution__c;
                successStoryDenormalized.outcome = mapSuccessStoryIdAndContentTranslation.translatedContentMap.get(tagSuccessStory.Success_Story__c).Outcome__c;
            }

            if(mapSuccessStoryIdAndContentTranslation.imageGalleryMap.containsKey(tagSuccessStory.Success_Story__r.Image_Gallery__c)) {
                successStoryDenormalized.galleryImages = new List<String>();
                List<Content_Unit_Translation__c> contentImages = mapSuccessStoryIdAndContentTranslation.imageGalleryMap.get(tagSuccessStory.Success_Story__r.Image_Gallery__c);
                if(contentImages != NULL && contentImages.size() > 0) {
                    for(Content_Unit_Translation__c cut : contentImages) {
                        successStoryDenormalized.galleryImages.add(cut.Image_Url__c);
                    }
                }
            }


            successStoriesDenormalized.add(successStoryDenormalized);
        }
        return successStoriesDenormalized;
    }

    /**
	 * @description This method returns the languages the user content should be served based on preferences
	 * @return List<String> : languages
	 */
    public String getUserLanguage() {
        String userLanguage = DEFAULT_CONTENT_LANGUAGE_ISO;
        return userLanguage;
    }
}