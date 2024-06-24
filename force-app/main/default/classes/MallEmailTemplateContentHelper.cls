/**
 * 
 * @description MallEmailTemplateContentHelper
 * @author Ankit Kumar
 * @since 
 */
public with sharing class MallEmailTemplateContentHelper {
    /*number of columns of content*/
    private Integer columnCount = 3;

    /**
     * 
     * @description formatContentForRows
     * @param newContents List<MallEmailTemplateContent.MallNewContent>
     * @return List<MallEmailTemplateContent>
     */
    public List<MallEmailTemplateContent> formatContentForRows(List<MallEmailTemplateContent.MallNewContent> newContents) {
        Integer newContentLength = newContents.size();
        Integer rowCount = (Integer)Math.ceil(newContentLength/(Decimal)columnCount);
        List<MallEmailTemplateContent> mallNewContentRows = new List<MallEmailTemplateContent>();

        for(Integer row=1; row <= rowCount; row++) {
            MallEmailTemplateContent mallNewContentRow = new MallEmailTemplateContent();
            mallNewContentRow.rowNumber = row;
            mallNewContentRow.newContents = new List<MallEmailTemplateContent.MallNewContent>();
            for(Integer i=(row-1)*columnCount; i < row*columnCount ; i++) {
                if(i >= newContentLength) {
                    break;
                }
                mallNewContentRow.newContents.add(newContents[i]);
            }
            mallNewContentRows.add(mallNewContentRow);
        }
        return mallNewContentRows;
    }

    /**
     * 
     * @description getBaseUrl for the mall site
     * @return String 
     */
    public String getBaseUrl() {
        String baseUrl = System.Url.getSalesforceBaseUrl().toExternalForm();
        if(baseUrl.endsWith('my.salesforce.com')) {
            List<string> parts = baseUrl.split('my.salesforce.com');
            baseUrl = parts[0] + 'my.site.com';
        } 
        return baseUrl;
    }

}