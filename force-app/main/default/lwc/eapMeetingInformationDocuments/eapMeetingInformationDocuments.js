import { LightningElement, track, api } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import customIcons from '@salesforce/resourceUrl/EapCustomResourcers';
import getDocuments from '@salesforce/apex/EAP_CTRL_MeetingInformationPage.getDocuments';
import getDocImages from '@salesforce/apex/EAP_UTIL_EventsApp.getDocImages';
import NO_DOCUMENTS_LABEL from '@salesforce/label/c.Eap_NoDocuments_Label';

const PDF_FILE = '/profilePdf.svg';
const DEFAULT_FILE = '/profileFile.svg';
const ARROW_RIGHT = 'utility:chevronright';

export default class EapMeetingInformationDocuments extends NavigationMixin(LightningElement) {
    labels = {NoDocuments: NO_DOCUMENTS_LABEL};
    @track _meetingId;
    @track elements = [];
    @api 
    get meetingId(){
        return this._meetingId;
    }
    set meetingId(value) {
        this.setAttribute('v', value);
        this._meetingId = value;
        this.loadDocuments();
    }

    loadDocuments(){
        getDocuments({meetingId: this.meetingId})
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
                                ExtraInfo: this.fileSizeToString(doc.ContentDocumentLinks[0].ContentDocument.ContentSize),
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

    fileSizeToString(value){
        let sizes = ['bytes', 'kb', 'mb', 'gb', 'tb'];
        if (value === 0) return '0 Byte';
        let i = parseInt(Math.floor(Math.log(value) / Math.log(1024)));

        return Math.round(value / Math.pow(1024, i), 2) + ' ' + sizes[i];
    }

    get haveElements(){
        if (this.elements.length > 0){
            return true;
        
        }else {
            return false;
        }
    }
}