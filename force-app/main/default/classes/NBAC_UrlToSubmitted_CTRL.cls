public without sharing class NBAC_UrlToSubmitted_CTRL {
    public String recID {get; set;}

    public String urlToPdf{
        get
        {
            return createURL(recID);
        }
    }

    @TestVisible
    private static String createURL(String recordID){

        String url = 'https://' + System.URL.getSalesforceBaseUrl().getHost();

       List<ContentDocumentLink> cdLinks = [
                SELECT ContentDocumentId
                FROM ContentDocumentLink
                WHERE LinkedEntityId = :recordID
                ORDER BY ContentDocument.CreatedDate DESC
                LIMIT 1];
        if(!cdLinks.isEmpty()) {
            url += '/lightning/cmp/c__NBAC_FileOpener?c__recId=' + cdLinks[0].ContentDocumentId;

        } else {

            List<Attachment> attachments = [
                    SELECT Id
                    FROM Attachment
                    WHERE ParentId = :recordID
                    ORDER BY CreatedDate DESC
                    LIMIT 1];
            if(!attachments.isEmpty()) {
                url += '/servlet/servlet.FileDownload?file=' + attachments[0].id;
            }
        }

        return url;
    }
}