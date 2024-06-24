import { LightningElement, api, wire, track } from 'lwc';
import { CloseActionScreenEvent } from 'lightning/actions';
import getAttendees from '@salesforce/apex/EAP_CTRL_ModalAttendance.getAttendees';
import insertAttendees from '@salesforce/apex/EAP_CTRL_ModalAttendance.insertAttendees';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

import ADD_ATTENDANCE_LABEL from '@salesforce/label/c.Eap_AddAttendance_Label';
import SELECT_ATTENDEES_LABEL from '@salesforce/label/c.Eap_SelectAttendees_Label';
import CANCEL_LABEL from '@salesforce/label/c.Eap_Cancel_Label';
import SAVE_LABEL from '@salesforce/label/c.Eap_Save_Label';

const columns = [{ label: 'Attendee', fieldName: 'Name', type: 'text' }];

export default class EapModalAttendance extends LightningElement {
    labels = {AddAttendance: ADD_ATTENDANCE_LABEL, Select: SELECT_ATTENDEES_LABEL, Cancel: CANCEL_LABEL, Save: SAVE_LABEL};
    @track hasLoaded = false;
    @track attData = [];
    @track columns = columns;
    attIds = [];
    attList = [];

    @api 
    get recordId(){
       return this._recordId;
    }
    set recordId(value) {
       this.setAttribute('v', value);
       this._recordId = value;
       this.loadAttendees();
    }

    handleCancel() {
        this.dispatchEvent(new CloseActionScreenEvent());
    }

    handleSuccess(e) {
        this.hasLoaded = false;

        for (let i = 0; i < this.attIds.length; i++) {
            this.attList.push(this.attIds[i].Id);
        }

        insertAttendees({meetingId: this.recordId,
                                attendeeList: this.attList})
        .then(() => {
            this.hasLoaded = true;
            // Close the modal window and display a success toast
            this.dispatchEvent(new CloseActionScreenEvent());
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Success',
                    message: 'Attendance created!',
                    variant: 'success'
                })
            );
            eval("$A.get('e.force:refreshView').fire();")
        })
        .catch(err => {
            this.hasLoaded = true;
            this.dispatchEvent(new CloseActionScreenEvent());
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error',
                    message: err,
                    variant: 'error'
                })
            );
        })
    }

    loadAttendees() {
        getAttendees({meetingId: this.recordId})
            .then(att => {
                let attendeeList = []
                for(let i = 0; i < att.length; i++){
                    let attendee = att[i];
                    let attendeeToInsert = {
                        Id: attendee.Id,
                        Name: attendee.EAP_ContactName__c
                    };
                    attendeeList.push(attendeeToInsert);
                }

                attendeeList.sort(this.compareName);
                this.attData = attendeeList;
                this.hasLoaded = true;
            })
    }

    getSelectedAttendee(event) {
        const el = this.template.querySelector('lightning-datatable');
        const selected = el.getSelectedRows();
        this.attIds = selected;
    }

    compareName(attendeeA, attendeeB){
        if ( attendeeA.Name < attendeeB.Name )
            return -1;
        else if ( attendeeA.Name > attendeeB.Name )
            return 1;
        else
            return 0;
    }
}