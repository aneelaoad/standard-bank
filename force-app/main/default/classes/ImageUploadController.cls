public with sharing class ImageUploadController {
    @AuraEnabled
    public static void uploadImage(String imageDataURL) {
      // Convert the data URL to Blob
      Blob imageBlob = EncodingUtil.base64Decode(getImageDataFromDataURL(imageDataURL));
  
   
  
      // Save the Blob as an attachment or custom object record (implement your logic here)
      // Example: Save as an attachment to the current record (you may modify this as per your use case)
      Attachment attachment = new Attachment();
      attachment.ParentId = '0013M00001FxybgQAB'; // Replace <RecordId> with the actual record ID where you want to attach the image.
      attachment.Name = 'Compressed_Image.jpg';
      attachment.Body = imageBlob;
      insert attachment;
    }
  
   
  
    private static String getImageDataFromDataURL(String dataURL) {
      // Extract base64 image data from the data URL
      return dataURL.substring(dataURL.indexOf(',') + 1);
    }
  }