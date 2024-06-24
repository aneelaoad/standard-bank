import { LightningElement, track } from 'lwc';
import loggedInUserId from '@salesforce/user/Id';
import IS_GUEST from '@salesforce/user/isGuest';
import getUserProfile from '@salesforce/apex/MallProfileManagementController.getUserProfile';
import providerUpdateRequest from '@salesforce/apex/MallStorefrontManagementController.providerUpdateRequest';
import getProviderInfo from '@salesforce/apex/MallStorefrontManagementController.getProviderInfo';
import updateImageRequest from '@salesforce/apex/MallStorefrontManagementController.updateImageRequest';
import deleteImageRequest from '@salesforce/apex/MallStorefrontManagementController.deleteImageRequest';
import updateSObjects from '@salesforce/apex/MallStorefrontManagementController.updateSObjects';
import submitProviderForApproval from '@salesforce/apex/MallStorefrontManagementController.submitProviderForApproval';
import publishProvider from '@salesforce/apex/MallStorefrontManagementController.publishProvider';
import cancelProviderUpdates from '@salesforce/apex/MallStorefrontManagementController.cancelProviderUpdates';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import DEFAULT_MALL_COUNTRY from '@salesforce/label/c.DEFAULT_MALL_COUNTRY';

export default class MallStorefrontManagement extends LightningElement {
    userProfile;
    providerInfo;
    @track accountId = '';
    @track clonedProviderId = '';
    publishedProvider;
    clonedProvider;
    contactId;
    name;
    acceptedImageFormats = ['.png', '.jpg', '.jpeg'];
    imageId;
    imageUploaded;
    imageUrl;
    shortDescription;
    longDescription;
    shortDescriptionPlaceholder = "Provide a brief description of your store...";
    longDescriptionPlaceholder = "Provide a detailed description about your store...";
    error;
    @track cutId;
    @track country;
    @track language;
    cut;
    comment;
    commentPlaceholder = "Add an additional comment for the approver...";
    status;
    disableInput = false;
    disablePublish = true;
    imageGuide = true;
    content = {
        contentVersionId : "",
        documentId : ""
    }
    
    get showRemoveImage() {
        return (this.imageUploaded && (this.status == "" || this.status == "Draft")) ? true : false; 
    }

    imageHelperText = "<p>* The store image must have dimensions <strong> 208x208 </strong></p><p>* Make sure your image appears within the safe zone with a <strong>width of 188px and height of 156px.</strong></p>";
    doNotshowToastBool = false;

    connectedCallback() {
        if (!IS_GUEST) {
            this.fetchUserProfile();
        }
    }

    maxLengthShortDescription = 100;
    lengthShortDescription = 0;
    maxLengthLongDescription = 1000;
    lengthLongDescription = 0;
    maxLengthComment = 200;
    lengthComment = 0;

    async fetchUserProfile() {
        this.userProfile = await getUserProfile({ currentUserId: loggedInUserId });
        this.accountId = this.userProfile.user.AccountId;
        this.contactId = this.userProfile.user.ContactId;
        this.name = this.userProfile.user.Contact.Account.Name;
        this.country = this.userProfile.user.User_Franco__c ? this.userProfile.user.User_Franco__c : DEFAULT_MALL_COUNTRY; 
        this.providerInfo = await getProviderInfo({ accountId: this.accountId });
        if (this.providerInfo && this.providerInfo.clonedProvider) {
            this.clonedProviderId = this.providerInfo.clonedProvider.Id;
            this.clonedProvider = this.providerInfo.clonedProvider;
            this.comment = this.providerInfo.clonedProvider.Approval_Comment__c;
            this.status = this.providerInfo.clonedProvider.Status__c;
        }
        if (this.status) {
            if (this.status == "Submitted" || this.status == "Approved" || this.status == "Published") {
                this.disableInput = true;
            }
            if (this.status == "Approved") {
                this.disablePublish = false;
            }
        } else {
            this.disableInput = false;
            this.disablePublish = true;
        }
        this.publishedProvider = this.providerInfo.publishedProvider;
        if (this.providerInfo && this.providerInfo.cut) {
            this.cutId = this.providerInfo.cut.Id;
            this.cut = this.providerInfo.cut;
            this.imageUrl = this.providerInfo.cut.Image_Url__c;
            this.imageUploaded = true;
            this.shortDescription = this.providerInfo.cut.Text__c;
            this.longDescription = this.providerInfo.cut.RichText__c;
        }
    }

    async handleImageUploadFinished(event) {
        if(!this.clonedProviderId) {
            this.providerInfo = await providerUpdateRequest({ publishedProviderId : this.publishedProvider.Id, clonedProviderId : this.clonedProviderId});
            this.clonedProvider = this.providerInfo.clonedProvider;
            this.clonedProviderId = this.providerInfo.clonedProvider.Id;
            this.cut = this.providerInfo.cut;
            this.cutId = this.providerInfo.cut.Id;
        }        
        const uploadedFiles = event.detail.files;
        let singleFile;
        if (uploadedFiles && uploadedFiles.length > 0) {
            singleFile = uploadedFiles[0];
            this.content.documentId = singleFile.documentId;
            this.content.contentVersionId = singleFile.contentVersionId;
        }
        if (singleFile) {
            try {
                this.providerInfo = await updateImageRequest({ accountId: this.accountId, clonedProviderId: this.clonedProviderId, contentVersionId: singleFile.contentVersionId, cutId: this.cutId });
                this.imageUploaded = true;
                this.imageUrl = this.providerInfo.cut.Image_Url__c;
                this.cut = this.providerInfo.cut;
                this.status = "Draft";
                this.showToast("Success!", "Image uploaded successfully", "success");
            } catch (error) {
                this.error = error;
            }
        }
    }

    handleShortDescriptionChange(event) {
        if(this.shortDescription && this.shortDescription.length >= this.maxLengthShortDescription) {
            return;
        }
        this.shortDescription = event.target.value;
        this.lengthShortDescription = this.shortDescription ? this.shortDescription.length : 0;
    }

    handleLongDescriptionChange(event) {
        if(this.longDescription && this.longDescription.length >= this.maxLengthLongDescription) {
            return;
        }
        this.longDescription = event.target.value;
        this.lengthLongDescription = this.longDescription ? this.longDescription.length : 0;
    }

    handleApprovalComment(event) {
        if(this.comment && this.comment.length >= this.maxLengthComment) {
            return;
        }
        this.comment = event.target.value;
        this.lengthComment = this.comment ? this.comment.length : 0;
    }

    async handleRemoveImage(event) {
        event.preventDefault();
        event.stopPropagation();
        try {
            this.providerInfo = await deleteImageRequest({accountId: this.accountId, clonedProviderId: this.clonedProviderId, documentId: this.content.documentId, cutId: this.cutId });
            this.content.documentId = "";
            this.content.contentVersionId = "";
            this.imageUploaded = false;
            this.imageUrl = "";
            this.cut = this.providerInfo.cut;
            this.showToast("Success!", "Image removed successfully", "success");
        } catch(error) {
            this.error = error;
        }

    }

    async handleCancel(event) {
        this.shortDescription = '';
        this.longDescription = '';
        this.comment = '';
        this.cut.Image_Url__c = '';
        try{
            this.providerInfo = await cancelProviderUpdates({ publishedProviderId: this.publishedProvider.Id });
            this.fetchUserProfile();
            this.showToast("Success!", "Store updates cancelled!", "success");
        }catch(error) {
            this.error = error;
            this.showToast("Failure!", "Store updates cancellation failed!", "error");
        }
    }

    async handleSubmitForApproval(event) {
        try {
            event.preventDefault();
            this.doNotshowToastBool = true;
            this.handleSave(this.doNotshowToastBool);
            let error = this.handleSubmitValidation();
            if(error) {
                this.showToast("Failure!", error, "error");
                return;
            } else {
                let requestSubmitted = await submitProviderForApproval({ clonedProviderId: this.clonedProviderId, comment: this.comment });
                if (requestSubmitted) {
                    this.disableInput = true;
                    this.status = "Submitted";
                    this.disablePublish = true;
                    this.showToast("Success!", "Your request submitted successfully", "success");
                }
            }
        } catch(error) {
            this.error = error;
        }
    }

    handleSubmitValidation() {
        let errors = [];
        if(!this.cutId) {
            errors.push('Please upload an image');
        }
        if(!this.shortDescription) {
            errors.push('Please provide a short description');
        }
        if(!this.longDescription) {
            errors.push('Please provide a long description');  
        }
        return errors.join(', ');
    }

    async handleSave() {
        let error = this.handleSubmitValidation();
        if(error) {
            this.showToast("Failure!", error, "error");
            return;
        }
        if(!this.clonedProviderId) {
            try{
                this.providerInfo = await providerUpdateRequest({ publishedProviderId : this.publishedProvider.Id, clonedProviderId : this.clonedProviderId});
                this.clonedProvider = this.providerInfo.clonedProvider;
                this.clonedProviderId = this.providerInfo.clonedProvider.Id;
                this.cut = this.providerInfo.cut;
                this.cutId = this.providerInfo.cut.Id;
                this.updateProviderDetails();
            } catch(error) {
                this.error = error;
            }
        }
        if (this.clonedProviderId) {
            this.updateProviderDetails();
        }
        if(!this.doNotshowToastBool) {
            this.showToast("Success!", "Saved successfully", "success");
            this.doNotshowToastBool = false;
        }
    }

    async updateProviderDetails() {
        let sObject = {};
        sObject.Title__c = this.publishedProvider.Name;
        if (this.shortDescription) {
            sObject.Text__c = this.shortDescription;
        }
        sObject.RichText__c = this.longDescription;
        if (this.clonedProviderId) {
            sObject.Provider__c = this.clonedProviderId;
        }
        if (this.cutId) {
            sObject.Id = this.cutId;
        }

        if (sObject.Text__c || sObject.Rich_Text__c) {
            try {
                let sObjects = await updateSObjects({ sObjects: [sObject] });
            } catch (error) {
                this.error = error;
            }
        }

        if (this.comment) {
            try {
                let sObjectProvider = {};
                sObjectProvider.Id = this.clonedProviderId;
                sObjectProvider.Approval_Comment__c = this.comment;
                await updateSObjects({ sObjects: [sObjectProvider] });
            } catch (error) {
                this.error = error;
            }
        }
    }

    async handlePublishProvider(event) {
        let providerState = {};
        providerState.clonedProvider = this.clonedProvider;
        providerState.cut = this.cut;
        providerState.publishedProvider = this.publishedProvider;
        let storeStateString = JSON.stringify(providerState);
        try {
            let storePublished = await publishProvider({ storeStateString: storeStateString });
            this.status = 'Published';
            this.disablePublish = true;
            this.showToast("Success!", "Your store published successfully", "success");
        } catch (error) {
            this.error = error;
        }
    }

    showToast(title, message, variant) {
        const event = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant
        });
        this.dispatchEvent(event);
    }

}