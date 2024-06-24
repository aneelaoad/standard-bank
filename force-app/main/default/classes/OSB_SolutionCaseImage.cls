/**
 * OSB_SolutionCaseImage class for converting image urls to src
 *
 * @author Milica Milicevic(milica@ignitesolutions.co.za)
 * @date February 2022
 **/
public without sharing class OSB_SolutionCaseImage {
    
    /**
     * Returns the src of of an image stored in a rich text field
     *
	 * @param url String of image from rich text field
	 * 
     * @return string of src of the image
     **/
    @AuraEnabled(cacheable=true)
    public static string getImageURL(string url)
    {
        String imageURL='';
        Matcher imgMatcher = Pattern.compile( '<img(.+?)>').matcher(url);
        if (imgMatcher.find()) {
            String imageTag = imgMatcher.group();
            imageURL= imageTag.substringBetween(' src="', '"' );
        }
        return imageURL.unescapeHtml4();
        
    }

}