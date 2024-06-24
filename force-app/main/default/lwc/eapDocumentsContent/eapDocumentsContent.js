import { LightningElement,track,api,wire } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { CurrentPageReference } from 'lightning/navigation';
import customIcons from '@salesforce/resourceUrl/EapCustomResourcers';
import getEventDocs from '@salesforce/apex/EAP_CTRL_DocumentsPage.getEventDocs';
import getDocImages from '@salesforce/apex/EAP_UTIL_EventsApp.getDocImages';
import NO_DOCUMENTS_LABEL from '@salesforce/label/c.Eap_NoDocuments_Label';

const PDF_FILE = '/profilePdf.svg';
const DEFAULT_FILE = '/profileFile.svg';
const ARROW_RIGHT = 'utility:chevronright';

export default class EapDocumentsContent extends NavigationMixin(LightningElement) {
    labels = {NoDocuments: NO_DOCUMENTS_LABEL};
    @track eventId;
    @track elements = [];

    @wire(CurrentPageReference)
    getStateParameters(currentPageReference) {
        if (currentPageReference) {
            this.urlStateParameters = currentPageReference.state;
            this.setParametersBasedOnUrl();
            this.loadDocuments();
        }
    }

    setParametersBasedOnUrl() {
        this.eventId = this.urlStateParameters.eventId || null;
    }

    loadDocuments(){
        getEventDocs({eventId: this.eventId})
        .then((data) => {
            if(data) {
                let docsList = data;
                let imagesParam = [];
                for(let i=0; i<docsList.length; i++){
                    imagesParam.push(
                        {
                            objId: docsList[i].Id,
                            docId: docsList[i].Id
                        }
                    )
                }
                getDocImages({docImageList: JSON.stringify(imagesParam)})
                .then((data) => {
                    if(data) {
                        let mapEvDoc = data;
                        for(let i=0; i<docsList.length; i++){
                            let doc = docsList[i];
                            let file;
                            if(doc.ContentDocumentLinks !== undefined && doc.ContentDocumentLinks.length > 0){
                                file = doc.ContentDocumentLinks[0];
                            }
                            this.elements.push({
                                Id: i,
                                Title: doc.Name,
                                Subtitle: this.formatDate(doc.LastModifiedDate),
                                IconStart: (file !== undefined)?this.getFileImage(file):customIcons + DEFAULT_FILE,
                                IconEnd: ARROW_RIGHT,
                                openFile: function(){
                                    this[NavigationMixin.Navigate]({
                                        type: 'standard__webPage',
                                        attributes: {
                                            url: mapEvDoc[doc.Id]
                                        }
                                    }, false );
                                }
                            });
                        }                
                    }
                    
                    const loadedEvent = new CustomEvent('loaded', {});
                    this.dispatchEvent(loadedEvent);
                })
                .catch((error) => {}); 

                if(imagesParam.length === 0){
                    const loadedEvent = new CustomEvent('loaded', {});
                    this.dispatchEvent(loadedEvent);
                }
            }
        })
        .catch((error) => {});
    }

    formatDate(dateString){
        let date = new Date(dateString);

        let day = date.getDate();
        let month = new Intl.DateTimeFormat('en', { month: 'short' }).format(date);
        let year = date.getFullYear();

        let strTime = day + ' '+ month +' ' + year;
        return strTime;
    }

    getFileImage(file){
        let fileType = file.ContentDocument.FileType;
        let imgFile;
        if(fileType === 'PDF'){
            imgFile = customIcons + PDF_FILE;
        }else{
            imgFile = customIcons + DEFAULT_FILE;
        }

        return imgFile;
    }

    get haveElements(){
        if (this.elements.length > 0){
            return true;
        
        }else {
            return false;
        }
    }
}