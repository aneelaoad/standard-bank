import { LightningElement, track, api } from 'lwc';
import customIcons from '@salesforce/resourceUrl/EapCustomResourcers';
import getNotes from '@salesforce/apex/EAP_CTRL_MeetingInformationPage.getNotes';
import insertNote from '@salesforce/apex/EAP_CTRL_MeetingInformationPage.insertNote';
import updateNote from '@salesforce/apex/EAP_CTRL_MeetingInformationPage.updateNote';
import ADD_NOTES_LABEL from '@salesforce/label/c.Eap_AddNotes_Label';
import NOTES_LABEL from '@salesforce/label/c.Eap_Notes_Label';
import TITLE_LABEL from '@salesforce/label/c.Eap_Title_Label';
import TYPE_HERE_LABEL from '@salesforce/label/c.Eap_TypeHere_Label';
import CANCEL_LABEL from '@salesforce/label/c.Eap_Cancel_Label';
import SAVE_LABEL from '@salesforce/label/c.Eap_Save_Label';

export default class EapMeetingInformationNotes extends LightningElement {
    labels = {AddNotes: ADD_NOTES_LABEL, Notes: NOTES_LABEL, Title: TITLE_LABEL, TypeHere: TYPE_HERE_LABEL, Cancel: CANCEL_LABEL, Save: SAVE_LABEL};
    iconArrow = customIcons + '/arrowRight.svg';

    @track error = {Title: false, Content: false};
    @track showNotes = true;
    @track notes = [];
    newNote = {};

    @track _meetingId;

    @api 
    get meetingId(){
        return this._meetingId;
    }
    set meetingId(value) {
        this.setAttribute('v', value);
        this._meetingId = value;
        this.loadNotes();
    }

    loadNotes(){
        getNotes({meetingId: this.meetingId})
        .then((data) => {
            if(data) {
                for(let i=0; i<data.length; i++){
                    this.notes.push({
                        Id: data[i].Id,
                        Title: data[i].Title,
                        Subtitle: this.formatDate(data[i].LastModifiedDate),
                        Content: data[i].Content,
                        IconEnd: this.iconArrow
                    });
                }      
                
                const loadedEvent = new CustomEvent('loaded', {});
                this.dispatchEvent(loadedEvent);          
            }
            const loadedEvent = new CustomEvent('loaded', {});
            this.dispatchEvent(loadedEvent);
        })
        .catch((error) => {});
    }

    formatDate(passDate) {
        let date = new Date(passDate);
        let formatDay = date.toLocaleString('default', { day: '2-digit', month: 'short', year: 'numeric'});
        let formatTime = date.toLocaleString('default', { hour12: true, minute: '2-digit', hour: '2-digit' });

        return formatDay + " - " + formatTime;
    }

    renderedCallback() {
        if (!this.showNotes && this.newNote.Id !== undefined)
        {
            this.template.querySelector("lightning-input").value = this.newNote.Title;
            this.template.querySelector("lightning-textarea").value = this.newNote.Content;
        }
    }

    /* Method to edit the selected note */
    editNote(e) {
        let currentNoteId = e.currentTarget.getAttribute("data-item");
        let tempNote = this.getNoteById(currentNoteId);
        this.newNote.Id = tempNote.Id;
        this.newNote.Title = tempNote.Title;
        this.newNote.Content = tempNote.Content;

        this.showNotes = false;
    }

    getNoteById(noteId){
        let finded = false;
        let i = 0;
        do{
            if (this.notes[i].Id === noteId){
                finded = true;
            }
            else{
                i++;
            }
        }while(!finded && i < this.notes.length)

        if (finded)
            return this.notes[i];
        else
            return null;
    }

    /* Method that show how to create a note */
    addNotes() {
        this.showNotes = false;
    }

    /* This returns to show you the list of notes */
    cancelNote() {
        this.newNote = {};
        this.showNotes = true;
    }

    /* This will save or update the note and return to the list */
    saveNote() {
        let error = false;
        let currentNoteId = this.newNote.Id;

        if (this.newNote.Title === "" || this.newNote.Title === undefined)
        {
            this.error.Title = true;
            error = true;
        }

        if (this.newNote.Content === "" || this.newNote.Content === undefined)
        {
            this.error.Content = true;
            error = true;
        }

        if (!error)
        {
            const loadedEvent = new CustomEvent('reload', {});
            this.dispatchEvent(loadedEvent);

            if (currentNoteId === undefined)
            {
                insertNote({meetingId: this.meetingId, title: this.newNote.Title, body: this.newNote.Content})
                .then(data => {
                    this.notes = [];
                    this.loadNotes();
                    this.showNotes = true;
                    const loadedEvent = new CustomEvent('loaded', {});
                    this.dispatchEvent(loadedEvent);
                })
                .catch(error => {
                    this.loadNotes();
                    this.showNotes = true;
                });
            
            }else
            {
                updateNote({noteId: currentNoteId, title: this.newNote.Title, body: this.newNote.Content})
                .then(data => {
                    this.notes = [];
                    this.loadNotes();
                    this.showNotes = true;
                    const loadedEvent = new CustomEvent('loaded', {});
                    this.dispatchEvent(loadedEvent);
                })
                .catch(error => {
                    this.loadNotes();
                    this.showNotes = true;
                });
            }
            this.newNote = {};
            this.showNotes = true;
        }
    }

    handleInputChange(e) {
        let name = e.target.name;
        if (name === "titleNote")
        {
            this.newNote.Title = e.target.value;
            this.error.Title = false;
        
        }else if (name === "contentNote")
        {
            this.newNote.Content = e.target.value
            this.error.Content = false;
        }
    }

    get haveNotes() {
        if (this.notes.length > 0)
            return true;
        else
            return false;
    }
}