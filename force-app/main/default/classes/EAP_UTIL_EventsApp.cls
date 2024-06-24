/**
 * @description Utility class for Events App
 * <br/>SFP-4690
 *
 * @author The Cocktail
 * @date June 2021
 */
public without sharing class EAP_UTIL_EventsApp {

    private static Map<String,ContentDocumentLink> mapCdlDoc;
    private static Map<String,ContentVersion> mapCdlCv;
    private static Map<Id,String> mapCvUrl;

    /**
    * @description 
    * @author TCK | 06-14-2022 
    * @param docImageList 
    * @return Map<String, String> 
    **/
    @AuraEnabled
    public static Map<String,String> getDocImages(String docImageList){

        ImageDocParam_Wrapper[] wrDocImgList = (ImageDocParam_Wrapper[])JSON.deserialize(docImageList, ImageDocParam_Wrapper[].class);

        List<String> docIdList = new List<String>();
        for(ImageDocParam_Wrapper ew:wrDocImgList){
            if(ew.docId != null){
                docIdList.add(ew.docId);
            }
        }

        Map<String,String> mapDocIdUrl = new Map<String,String>();
        if(!docIdList.isEmpty()){
            Map<Id,String> mapDocUrl = getImages(docIdList);

            for(ImageDocParam_Wrapper imgDoc:wrDocImgList){
                String imgUrl = (mapDocUrl.get(imgDoc.docId)!=null)?mapDocUrl.get(imgDoc.docId):null;

                mapDocIdUrl.put(imgDoc.objId,imgUrl);
            }
        }

        return mapDocIdUrl;
    }

    /**
    * @description 
    * @author TCK | 06-14-2022 
    * @param docsId 
    * @return Map<Id, String> 
    **/
    public static Map<Id,String> getImages(List<Id> docsId){
        Set<Id> docsIds = new Set<Id>(docsId);
        List<ContentDocumentLink> mainPhotoList = SEL_ContentDocumentLink.newInstance().selectByLinkedEntityId(docsIds);

        Set<Id> cdlIdsList = new Set<Id>();
        mapCdlDoc = new Map<String,ContentDocumentLink>(); 

        for(ContentDocumentLink cdl: mainPhotoList){

            cdlIdsList.add(cdl.ContentDocumentId);
            mapCdlDoc.put(cdl.LinkedEntityId,cdl);

        }
        List<ContentVersion> cvList = SEL_ContentVersion.newInstance().selectByContentDocumentId(cdlIdsList);
        
        List<String> contentVersionList = new List<String>();  
        mapCdlCv = new Map<String,ContentVersion>(); 
        for(ContentVersion cv:cvList){
            contentVersionList.add(cv.ContentDocument.LatestPublishedVersionId);
            mapCdlCv.put(cv.ContentDocumentId,cv);
        }

        Map<Id,String> mapDocUrl = getContentDritributionLinkDoc(docsId,contentVersionList);

        return mapDocUrl;
    }

    /**
    * @description 
    * @author TCK | 06-14-2022 
    * @param docsId 
    * @param contentVersionList 
    * @return Map<Id, String> 
    **/
    public static Map<Id,String> getContentDritributionLinkDoc(List<String> docsId, List<Id> contentVersionList){

        Set<Id> contentVersionSet = new Set<Id>(contentVersionList);
        List<ContentDistribution> contentDistributionList = SEL_ContentDistribution.newInstance().selectByContentVersionId(contentVersionSet);

        mapCvUrl = new Map<Id,String>(); 
        for(ContentDistribution cd:contentDistributionList){
            mapCvUrl.put(cd.ContentVersionId,cd.ContentDownloadUrl);
        }
        Map<Id,String> mapDocUrl = new Map<Id,String>(); 
        for(Id docId:docsId){
            ContentDocumentLink cdl = mapCdlDoc.get(docId);
            if(cdl != null){
                ContentVersion cv = mapCdlCv.get(cdl.ContentDocumentId);
                if(cv != null && mapCvUrl.get(cv.Id) != null){
                    String cd = mapCvUrl.get(cv.Id);
                    mapDocUrl.put(docId, cd);
                }
            }
        }
        

        return mapDocUrl;
    }

    /**
    * @description 
    * @author TCK | 06-14-2022 
    * @param cVersion 
    * @param cDist 
    * @return String 
    **/
    @TestVisible private static String buildPublicUrl(ContentVersion cVersion, String cDist) {
        String fileType = cVersion.FileType.toLowerCase().capitalize();
        String cVersionId = cVersion.Id;
        String cBodyId = cVersion.ContentBodyId;
        String originalUrl = cDist;
        String cDistParam = originalUrl.substring(originalUrl.indexOf('/a/'));
        String orgId = '';
        if (!Test.isRunningTest()) { 
            //If not this conditional: System.UnsupportedOperationException: ConnectApi methods are not supported in data siloed tests. Please use @IsTest(SeeAllData=true).
            orgId = ConnectApi.Organization.getSettings().orgId;
        }
        String baseDomain = Url.getOrgDomainUrl().toExternalForm();
        baseDomain = baseDomain.substringBefore('.') + '--c.documentforce.com';
        String theUrl = baseDomain + '/sfc/dist/version/renditionDownload?rendition=ORIGINAL_' +
                fileType + '&versionId=' + cVersionId + '&operationContext=DELIVERY&contentId=' + cBodyId +
                '&page=0&d=' + cDistParam + '&oid=' + orgId + '&dpt=null&viewId=';
        return theUrl;
    }

    /**
    * @description 
    * @author TCK | 06-14-2022 
    **/
    public class ImageDocParam_Wrapper{
        @AuraEnabled
        /**
         * @author TCK
         * @date 06-14-2022 
         * @description Function to get or set 
         */
        public String objId {get;set;}
        @AuraEnabled
        /**
         * @author TCK
         * @date 06-14-2022 
         * @description Function to get or set
         */
        public String  docId {get;set;}

        /**
        * @description 
        * @author TCK | 06-14-2022 
        * @param objId
        * @param docId
        **/
        public ImageDocParam_Wrapper(String objId,String docId){
            this.objId = objId;
            this.docId = docId;
        }
    }
}