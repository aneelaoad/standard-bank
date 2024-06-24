import { LightningElement, api, track } from 'lwc';
import customIcons from '@salesforce/resourceUrl/EapCustomResourcers';
import hasMatchmakingRan from '@salesforce/apex/EAP_CTRL_MatchmakingMatrix.hasMatchmakingRan';
import getMatrixData from '@salesforce/apex/EAP_CTRL_MatchmakingMatrix.getMatrixData';
import getInvestorsData from '@salesforce/apex/EAP_CTRL_MatchmakingMatrix.getInvestors';
import publishMeetings from '@salesforce/apex/EAP_CTRL_MatchmakingMatrix.publishMeetings';
import publishCorporateMeetings from '@salesforce/apex/EAP_CTRL_MatchmakingMatrix.publishCorporateMeetings';
import deleteAttendance from '@salesforce/apex/EAP_CTRL_MatchmakingMatrix.deleteAttendance';
import searchAvailability from '@salesforce/apex/EAP_CTRL_MatrixLogic.searchAvailabilityNotice';
import editMeeting from '@salesforce/apex/EAP_CTRL_MatrixLogic.editMeetingAttendance';
import forceMeeting from '@salesforce/apex/EAP_CTRL_MatrixLogic.forceMeeting';
import generateAgenda from '@salesforce/apex/EAP_CTRL_MatrixLogic.generateAgenda';

import ALL_CORPORATES_LABEL from '@salesforce/label/c.Eap_AllCorporates_Label';
import ALL_DAYS_LABEL from '@salesforce/label/c.Eap_AllDays_Label';
import DAY_LABEL from '@salesforce/label/c.Eap_Day_Label';
import CORPORATE_LABEL from '@salesforce/label/c.Eap_Corporate_Label';
import CORPORATE_COUNTRY_LABEL from '@salesforce/label/c.Eap_CorporateCountry_Label';
import MEETING_LABEL from '@salesforce/label/c.Eap_Meeting_Label';
import TIMESLOT_LABEL from '@salesforce/label/c.Eap_Timeslot_Label';
import DEL_ORGANISATION_LABEL from '@salesforce/label/c.Eap_DelegateOrganisation_Label';
import DEL_FULL_NAME_LABEL from '@salesforce/label/c.Eap_DelegateFullName_Label';
import DEL_FIRST_NAME_LABEL from '@salesforce/label/c.Eap_DelegateFirstName_Label';
import DEL_LAST_NAME_LABEL from '@salesforce/label/c.Eap_DelegateLastName_Label';
import DEL_EMAIL_LABEL from '@salesforce/label/c.Eap_DelegateEmail_Label';
import DEL_COUNTRY_LABEL from '@salesforce/label/c.Eap_DelegateCountry_Label';
import RELATIONSHIP_MANAGER_LABEL from '@salesforce/label/c.Eap_RelationshipManager_Label';
import NO_MATRIX_LABEL from '@salesforce/label/c.Eap_NoMatrix_Label';
import RUN_MATRIX_LABEL from '@salesforce/label/c.Eap_PleaseRunMatchmaking_Label';
import SIMPLE_ERROR_LABEL from '@salesforce/label/c.Eap_SimpleError_Label';
import CHECK_LABEL from '@salesforce/label/c.Eap_PleaseCheck_Label';
import CORPORATE_MEETINGS_LABEL from '@salesforce/label/c.Eap_CorporateMeetings_Label';
import MATRIX_MATCHMAKING_LABEL from '@salesforce/label/c.Eap_MatrixMatchmaking_Label';
import FORCE_MEETING_LABEL from '@salesforce/label/c.Eap_ForceMeeting_Label';
import PUBLISH_LABEL from '@salesforce/label/c.Eap_Publish_Label';
import FIND_ISSUES_LABEL from '@salesforce/label/c.Eap_FindIssues_Label';
import SHOW_MENU_LABEL from '@salesforce/label/c.Eap_ShowMenu_Label';
import EXPORT_CSV_LABEL from '@salesforce/label/c.Eap_ExportCSV_Label';
import WARNING_LABEL from '@salesforce/label/c.Eap_Warning_Label';
import ISSUES_LABEL from '@salesforce/label/c.Eap_Issues_Label';
import CLOSE_LABEL from '@salesforce/label/c.Eap_Close_Label';
import NOTES_LABEL from '@salesforce/label/c.Eap_Notes_Label';
import EDIT_LABEL from '@salesforce/label/c.Eap_Edit_Label';
import DELETE_LABEL from '@salesforce/label/c.Eap_Delete_Label';
import SLOT_UNAVAILABLE_LABEL from '@salesforce/label/c.Eap_SlotUnavailable_Label';
import UNAVAILABLE_LABEL from '@salesforce/label/c.Eap_Unavailable_Label';
import FAILED_MEETINGS_LABEL from '@salesforce/label/c.Eap_FailedMeetings_Label';
import NO_FAILED_MEETINGS_LABEL from '@salesforce/label/c.Eap_NoFailedMeetings_Label';
import NEW_NOTE_LABEL from '@salesforce/label/c.Eap_NewNote_Label';
import MEETING_NAME_LABEL from '@salesforce/label/c.Eap_MeetingName_Label';
import ATTENDEE_NAME_LABEL from '@salesforce/label/c.Eap_AttendeeName_Label';
import TITLE_LABEL from '@salesforce/label/c.Eap_Title_Label';
import NOTE_LABEL from '@salesforce/label/c.Eap_Note_Label';
import CANCEL_LABEL from '@salesforce/label/c.Eap_Cancel_Label';
import OK_LABEL from '@salesforce/label/c.Eap_Ok_Label';
import MOVE_INVESTOR_LABEL from '@salesforce/label/c.Eap_MoveInvestor_Label';
import SLOT_LABEL from '@salesforce/label/c.Eap_Slot_Label';
import SELECT_OPTION_LABEL from '@salesforce/label/c.Eap_SelectOption_Label';
import GO_BACK_LABEL from '@salesforce/label/c.Eap_GoBack_Label';
import NO_ISSUES_LABEL from '@salesforce/label/c.Eap_NoIssues_Label';
import ISSUES_FOUNDED_LABEL from '@salesforce/label/c.Eap_IssuesFounded_Label';
import HAS_MEETING_LABEL from '@salesforce/label/c.Eap_HasMeeting_Label';
import HAS_NO_AVAILABILITY_LABEL from '@salesforce/label/c.Eap_HasNoAvailability_Label';
import MEETING_EDITED_LABEL from '@salesforce/label/c.Eap_MeetingEdited_Label';
import ERROR_LABEL from '@salesforce/label/c.Eap_Error_Label';
import NEXT_LABEL from '@salesforce/label/c.Eap_Next_Label';
import DELETE_ATTENDANCE_LABEL from '@salesforce/label/c.Eap_DeleteAttendance_Label';
import PUBLISH_ATTENDANCE_LABEL from '@salesforce/label/c.Eap_PublishAttendance_Label';
import WANT_TO_DELETE_LABEL from '@salesforce/label/c.Eap_WantToDelete_Label';
import WANT_TO_PUBLISH_LABEL from '@salesforce/label/c.Eap_WantToPublish_Label';
import SELECT_CORPORATE_LABEL from '@salesforce/label/c.EAP_SelectACoporate_Label';
import INVESTOR_LABEL from '@salesforce/label/c.Eap_Investor_Label';
import MEETING_FORCED_LABEL from '@salesforce/label/c.Eap_MeetingForced_Label';

const CSV_NAME = 'MatchmakingExport';
const columns = [{ label: 'Corporate', fieldName: 'Name', type: 'text'}, {label: 'Start Date', fieldName: 'StartDate', type: 'Text'}, {label: 'End Date', fieldName: 'EndDate', type: 'Text'}];


export default class EapMatchmakingMatrix extends LightningElement {
    labels = {AllCorporates: ALL_CORPORATES_LABEL, AllDays: ALL_DAYS_LABEL, Day: DAY_LABEL, Corporate: CORPORATE_LABEL, CorporateCountry: CORPORATE_COUNTRY_LABEL,
            Meeting: MEETING_LABEL, TimeSlot: TIMESLOT_LABEL, DelOrganisation:DEL_ORGANISATION_LABEL, DelFullName: DEL_FULL_NAME_LABEL, DelFirstName: DEL_FIRST_NAME_LABEL,
            DelLastName: DEL_LAST_NAME_LABEL, DelEmail: DEL_EMAIL_LABEL, DelCountry: DEL_COUNTRY_LABEL, RelManager: RELATIONSHIP_MANAGER_LABEL, NoMatrix: NO_MATRIX_LABEL,
            CorporateMeetings: CORPORATE_MEETINGS_LABEL, MatrixMatchmaking: MATRIX_MATCHMAKING_LABEL, ForceMeeting: FORCE_MEETING_LABEL, Publish: PUBLISH_LABEL,
            FindIssues: FIND_ISSUES_LABEL, ShowMenu: SHOW_MENU_LABEL, ExportCSV: EXPORT_CSV_LABEL, Warning: WARNING_LABEL, Issues: ISSUES_LABEL, Close: CLOSE_LABEL,
            Notes: NOTES_LABEL, Edit: EDIT_LABEL, Delete: DELETE_LABEL, SlotUnavailable:SLOT_UNAVAILABLE_LABEL, Unavailable: UNAVAILABLE_LABEL, FailedMeetings: FAILED_MEETINGS_LABEL,
            NoFailedMeetings: NO_FAILED_MEETINGS_LABEL, NewNote: NEW_NOTE_LABEL, MeetingName: MEETING_NAME_LABEL, AttendeeName: ATTENDEE_NAME_LABEL, Title: TITLE_LABEL,
            Note: NOTE_LABEL, Cancel: CANCEL_LABEL, Ok: OK_LABEL, MoveInvestor: MOVE_INVESTOR_LABEL, Slot: SLOT_LABEL, SelectOption: SELECT_OPTION_LABEL,
            GoBack: GO_BACK_LABEL, NoIssues: NO_ISSUES_LABEL, IssuesFounded: ISSUES_FOUNDED_LABEL, HasMeeting: HAS_MEETING_LABEL, HasNoAvailability: HAS_NO_AVAILABILITY_LABEL,
            MeetingEdited: MEETING_EDITED_LABEL, Error: ERROR_LABEL, Next: NEXT_LABEL, DeleteAttendance: DELETE_ATTENDANCE_LABEL, PublishAttendance: PUBLISH_ATTENDANCE_LABEL,
            WantToDelete: WANT_TO_DELETE_LABEL, WantToPublish: WANT_TO_PUBLISH_LABEL, SelectCorporate: SELECT_CORPORATE_LABEL, Investor: INVESTOR_LABEL,
            MeetingForced: MEETING_FORCED_LABEL, RunMatrix: RUN_MATRIX_LABEL, SimpleError: SIMPLE_ERROR_LABEL, CheckAgain: CHECK_LABEL};

    @api recordId;
    @track dataInfo = {};
    @track hasMatchmaking = false;
    @track hasRendered = false;
    iconPublished = customIcons+'/published.png';
    iconNotPublished = customIcons+'/pendent.png';

    @track modals = {isNotesOpen: false, isEditOpen: false, isForceOpen: false, isForceEdit:false, isIssuesOpen: false, isConfirmOpen: false, confirmDelete: false, confirmSetMeetings: false, isPublishOpen: false} //Which modal is open
    @track modalDetail = {isFirstStep: true, isLoading: false, showIssues: false, hasFinished: false, hasError: false};
    @track selectedCoorporateId = '';                                    // Id of selected coorporate
    @track selectedMeeting = '';                                         // Id of selected meeting
    @track selectedMeetingName = '';                                     // Name of selected meeting
    @track selectedAttendee = {Id: '', Name: ''};                        // Id of selected attendee
    @track error = {};                                                   // Error modal inputs
    @track result= {};                                                   // Result of search availability

    @track selectedItem = {
        coorporateId: '',
        meetingId: '',
        meetingName:'',
        startDate:'',
        endDate:'',
        selectedAttendee: {Id: '', Name: ''}
    }

    fieldValues = {};                                                    // Modal field values
    listSlots = [];                                                      // List of slots per day with start and end time
    listDays = [];                                                       // List of event days
    @track slotOptions = [];                                             // List of slots group by days
    @track investorsOptions = [];                                        // Select investors to force meetings

    @track originalCorporatesData = [];                                   // Matrix information
    @track corporatesData = [];                                           // Corporates that are displayed
    @track corporatesOptions = [{value: 'all', label: this.labels.AllCorporates}]; // Select corporate to display on matrix
    @track daysOptions = [{value: 'all', label: this.labels.AllDays}];             // Select Day to display on matrix
    filters = {corporates: 'All', days: 'All'};                           // Filters applied on matrix
    @track failedInvestors = [];
    @track publishData = [];
    @track columns = columns;
    @track activeMeetings = [];
    corporatesSelected = [];
    @track expandedRows = [];

    get corporatesByCompany() {
        let companyList = [];
        this.corporatesOptions.forEach(corp => {
            if (companyList.filter(company => company.label === corp.company).length < 1) {
                companyList.push({label: corp.company});

            }
        });

        companyList.forEach(company => {
            company.options = this.corporatesOptions.filter(option => option.company === company.label);
        })

        return companyList;
    }

    renderedCallback() {
        if (!this.hasRendered) {
            this.hasRendered = true;
            this.renderedHasMatchmakingRan();
        }
    }

    renderedHasMatchmakingRan(){ 
        hasMatchmakingRan({ eventId: this.recordId })
        .then(data => {
            this.hasMatchmaking = data;

            if (data) {
                this.getMatrix();
                this.getInvestors();
            
            } else {
                this.dataInfo.hasLoad = true;
            }
        }).catch(error => {
            this.dataInfo.hasLoad = true;
        });
    }
    
    getMatrix() {
        this.listDays = [];
        this.listSlots = [];
        this.slotOptions = [];
        this.corporatesOptions = [{value: 'all', label: this.labels.AllCorporates}];
        this.daysOptions = [{value: 'all', label: this.labels.AllDays}];

        getMatrixData({ eventId: this.recordId })
        .then(data => {
            this.originalCorporatesData = JSON.parse(JSON.stringify(data));
            let maxDays = 0;
            for (let i = 0; i < this.originalCorporatesData.length; i++) {
                this.corporatesOptions.push({value: (i+1), label: this.originalCorporatesData[i].coorporate.EAP_ContactName__c, id: this.originalCorporatesData[i].coorporate.Id, company: this.originalCorporatesData[i].coorporate.EAP_AttendeeCompany__c});
                this.originalCorporatesData[i].coorporate.NameAndCompany = this.originalCorporatesData[i].coorporate.EAP_ContactName__c + ' - ' + this.originalCorporatesData[i].coorporate.EAP_AttendeeCompany__c;

                for (let t = 0; t < this.originalCorporatesData[i].listSlots.length; t++) {
                    let time = this.getDates(this.originalCorporatesData[i].listSlots[t].startDate, this.originalCorporatesData[i].listSlots[t].endDate);
                    this.originalCorporatesData[i].listSlots[t].startDate = time.start;
                    this.originalCorporatesData[i].listSlots[t].fullStartDate = time.fullStartDate;
                    this.originalCorporatesData[i].listSlots[t].endDate = time.end;
                    this.originalCorporatesData[i].listSlots[t].fullEndDate = time.fullEndDate;

                    if (this.originalCorporatesData[i].listSlots[t].meeting) {
                        for (let j = 0; j < this.originalCorporatesData[i].listSlots[t].meeting.listInvestor.length; j++) {
                            if (this.originalCorporatesData[i].listSlots[t].meeting.listInvestor[j].EAP_Attendee__r.EAP_TierLevel__c === '1') {
                                this.originalCorporatesData[i].listSlots[t].meeting.listInvestor[j].isGold = true;
                            
                            } else if (this.originalCorporatesData[i].listSlots[t].meeting.listInvestor[j].EAP_Attendee__r.EAP_TierLevel__c === '2') {
                                this.originalCorporatesData[i].listSlots[t].meeting.listInvestor[j].isSilver = true;
                            
                            } else {
                                this.originalCorporatesData[i].listSlots[t].meeting.listInvestor[j].isBronze = true;
                            }
                        }
                    }

                    if (t === (this.originalCorporatesData[i].listSlots.length-1)) {
                        maxDays = this.originalCorporatesData[i].listSlots[t].numDay;
                    }
                }

                if (this.originalCorporatesData[i].listInvestorNoMeeting) {
                    for (let t = 0; t < this.originalCorporatesData[i].listInvestorNoMeeting.length; t++) {
                        if (this.originalCorporatesData[i].listInvestorNoMeeting[t].EAP_Attendee__r.EAP_TierLevel__c === '1') {
                            this.originalCorporatesData[i].listInvestorNoMeeting[t].isGold = true;
                        
                        } else if (this.originalCorporatesData[i].listInvestorNoMeeting[t].EAP_Attendee__r.EAP_TierLevel__c === '2') {
                            this.originalCorporatesData[i].listInvestorNoMeeting[t].isSilver = true;
                        
                        } else {
                            this.originalCorporatesData[i].listInvestorNoMeeting[t].isBronze = true;
                        }

                        this.failedInvestors.push({corp: this.originalCorporatesData[i].coorporate.EAP_ContactName__c, inv: this.originalCorporatesData[i].listInvestorNoMeeting[t]});
                    }
                }
            }

            this.corporatesData = JSON.parse(JSON.stringify(this.originalCorporatesData));

            for (let i = 1; i <= maxDays; i++) {
                this.daysOptions.push({value: i, label: (this.labels.Day + ' ' + i)});
                this.slotOptions.push({label: (this.labels.Day + ' ' + i), options: JSON.parse(JSON.stringify(this.listSlots))});
            }

            this.dataInfo.hasLoad = true;
            this.dataInfo.hasContent = true;
        })
        .catch(error => {
            this.dataInfo.hasLoad = true;
            this.dataInfo.hasContent = false;
        });
    }

    getInvestors() {
        getInvestorsData({eventId: this.recordId})
        .then(data => {
            for (let i = 0; i < data.length; i++) {
                this.investorsOptions.push({value: data[i].investor.Id, label: data[i].investor.EAP_ContactName__c, selected: false, relationshipManager: data[i].relationshipManager});
            }
        })
        .catch(error => {});
    }

    getDates(start, end = ""){
        let dates = {};
        let startDate = new Date(start);
        let endDate = new Date(end);
        let offset = startDate.getTimezoneOffset() / 60;
        startDate.setHours(startDate.getHours() + offset);
        endDate.setHours(endDate.getHours() + offset);

        let startMinutes = startDate.getMinutes();
        if (startMinutes.toString().length === 1){
            startMinutes = "0" + startMinutes;
        }

        let endMinutes = endDate.getMinutes();
        if (endMinutes.toString().length === 1){
            endMinutes = "0" + endMinutes;
        }

        dates = {
            end: endDate.getHours() + ":" + endMinutes,
            start: startDate.getHours() + ":" + startMinutes,
            fullStartDate: endDate.getFullYear()+'-'+(startDate.getMonth()+1)+'-'+startDate.getDate()+' '+startDate.getHours() + ":" + startMinutes+':00', 
            fullEndDate: endDate.getFullYear()+'-'+(endDate.getMonth()+1)+'-'+endDate.getDate()+' '+endDate.getHours() + ":" + endMinutes+':00' 
        };

        startDate.setHours(0);
        startDate.setMinutes(0);
        startDate.setSeconds(0);
        startDate.setMilliseconds(0);

        if (this.listDays.filter(elem => elem.getMonth() === startDate.getMonth() && elem.getDate() === startDate.getDate() && elem.getFullYear() && startDate.getFullYear()).length === 0) {
            this.listDays.push(startDate);
        }

        if (this.listSlots.filter(elem => elem.start === dates.start && elem.end === dates.end).length === 0) {
            dates.value = this.listSlots.length+1;
            this.listSlots.push(dates);
        }

        return dates;
    }

    handleSelectCorporates(e) {
        if (e.target.value === 'all') {
            this.filters.corporates = 'All';
        
        } else {
            this.filters.corporates = e.target.value-1;
        }

        this.filterMatrix();
    }

    handleSelectDays(e) {
        if (e.target.value === 'all') {
            this.filters.days = 'All';
        
        } else {
            this.filters.days = e.target.value;
        }

        this.filterMatrix();

    }

    handleSelectInvestors(e) {
        this.fieldValues.forceInvestors = e.target.value;
    }

    filterMatrix() {
        let corpIndex = this.filters.corporates;
        let dayValue = this.filters.days;
        let filteredCorporates = JSON.parse(JSON.stringify(this.originalCorporatesData));
        
        if (corpIndex !== 'All') {
            filteredCorporates = [];
            filteredCorporates.push(JSON.parse(JSON.stringify(this.originalCorporatesData[corpIndex])));
        }
        
        if (this.filters.days !== 'All') {
            filteredCorporates.forEach(element => {
                element.listSlots = element.listSlots.filter(slot => slot.numDay === dayValue);
            });
        }
        this.corporatesData = JSON.parse(JSON.stringify(filteredCorporates));
    }

    openModal(e) {
        switch(e.target.name) {
            case 'notes':
                this.modals.isNotesOpen = true;
                this.selectedMeeting = e.target.dataset.meetId;
                this.selectedMeetingName = e.target.dataset.meetName;
                this.selectedAttendee.Id = e.target.dataset.attId;
                this.selectedAttendee.Name = e.target.dataset.attName;
            break;

            case 'forceEdit':
                this.modals.isForceEdit = true;

            case 'edit':
                this.modals.isEditOpen = true;
                this.selectedMeeting = e.target.dataset.meetId;
                this.selectedCoorporateId = e.target.dataset.corpId;
                this.selectedAttendee.Id = e.target.dataset.attId;
                this.selectedAttendee.Name = e.target.dataset.attName;
                
                this.selectedItem = {
                    coorporateId: e.target.dataset.corpId,
                    meetingId: e.target.dataset.meetId,
                    meetingName:'',
                    startDate: e.target.dataset.startDate,
                    endDate: e.target.dataset.endDate,
                    selectedAttendee: {Id: e.target.dataset.attId, Name: e.target.dataset.attName}
                }

                let corpIndex = this.corporatesOptions.findIndex(corporate => corporate.id === e.target.dataset.corpId);
                this.fieldValues.editCorporate = corpIndex;
                this.corporatesOptions[corpIndex].isSelected = true;

            break;

            case 'delete':
                this.modals.isConfirmOpen = true;
                this.modals.confirmDelete = true;
                this.selectedMeeting = e.target.dataset.meetId;
                this.selectedAttendee.Id = e.target.dataset.attId;
                this.selectedAttendee.Name = e.target.dataset.attName;
            break;

            case 'forceMeeting': this.modals.isForceOpen = true;
            break;

            case 'publishMeetings':
                this.publishData = [];
                this.activeMeetings = [];
                this.modals.confirmSetMeetings = true;
                this.modals.isPublishOpen = true;
                const originalData = JSON.parse(JSON.stringify(this.originalCorporatesData));
                for (let i = 0; i < originalData.length; i++) {
                    const corporate = {
                        Id: originalData[i].coorporate.Id,
                        Name: originalData[i].coorporate.EAP_ContactName__c,
                        Corporate: true,
                        _children: []
                    };
                    for (let j = 0; j < originalData[i].listSlots.length; j++) {
                        if (originalData[i].listSlots[j].meeting) { 
                            const meeting = {
                                Id: originalData[i].listSlots[j].meeting.meeting.Id,
                                CorporateId: originalData[i].listSlots[j].meeting.meeting.EAP_CorporateID__c,
                                StartDate: originalData[i].listSlots[j].startDate,
                                EndDate: originalData[i].listSlots[j].endDate,
                                Name: 'Meeting ' + originalData[i].listSlots[j].numSlot,
                                Corporate: false
                            };
                            if (originalData[i].listSlots[j].meeting.meeting.EAP_VisibleOnMobileApp__c) {
                                this.expandedRows.push(originalData[i].coorporate.Id);
                                this.activeMeetings.push(originalData[i].listSlots[j].meeting.meeting.Id);
                            } 
                            corporate._children.push(meeting);
                        }
                    }
                    this.publishData.push(corporate);
                }
            break;
        }
    }

    openFindIssues() {
        this.modals.isIssuesOpen = !this.modals.isIssuesOpen;
    }

    closeModal() {
        Object.entries(this.modals).forEach(([key, value]) => { this.modals[key] = false });
        this.modalDetail = {isFirstStep: true, isLoading: false, showIssues: false, hasFinished: false, hasError: false};
        this.fieldValues = {};
        this.error = {};
        this.corporatesOptions.forEach(option => option.isSelected = false);
        this.slotOptions.forEach(day => {
            day.options.forEach (option => option.isSelected = false);
        });
    }

    handleInput(e) {
        this.fieldValues[e.target.name] = e.target.value;
        
        if (e.target.name === 'forceSlot') {
            let field = this.template.querySelector('select[name="forceSlot"] option:checked').parentElement.label;
            if (field !== '' && field !== undefined) {
                field = field.substring((this.labels.Day + ' ').length);
                this.fieldValues['forceDaySlot'] = field;
            }

        } else if (e.target.name === 'editSlot') {
            let field = this.template.querySelector('select[name="editSlot"] option:checked').parentElement.label;

            if (field !== '' && field !== undefined) {
                field = field.substring((this.labels.Day+' ').length);
                this.fieldValues['editDaySlot'] = field;
            }
        }
    }

    handleErrors (fields) {
        this.error = {};
        fields.forEach( field => {
            if (this.fieldValues[field] === null) {
                this.error[field] = true;
            
            }
        })
    }

    handleBack() {
        let corpIndex = null;
        let slotIndex = null;
        let dayIndex = null;

        if (this.modals.isEditOpen) {
            corpIndex = (this.fieldValues.editCorporate !== null) ? this.fieldValues.editCorporate : 0;
            slotIndex = (this.fieldValues.editSlot !== null) ? this.fieldValues.editSlot-1 : slotIndex;
            dayIndex = (this.fieldValues.editDaySlot !== null) ? this.fieldValues.editDaySlot-1 : dayIndex;
        
        } else if (this.modals.isForceOpen) {
            corpIndex = (this.fieldValues.forceCorporate !== null) ? this.fieldValues.forceCorporate : corpIndex;
            slotIndex = (this.fieldValues.forceSlot !== null) ? this.fieldValues.forceSlot-1 : slotIndex;
            dayIndex = (this.fieldValues.forceDaySlot !== null) ? this.fieldValues.forceDaySlot-1 : dayIndex;

        }

        if (corpIndex !== null) {
            this.corporatesOptions.forEach(item => {item.isSelected = false});
            this.corporatesOptions[corpIndex].isSelected = true;
        }

        if (slotIndex !== null && dayIndex !== null){
            this.slotOptions.forEach(item => {
                item.options.forEach(opt => {opt.isSelected = false});
            });
            this.slotOptions[dayIndex].options[slotIndex].isSelected = true;
        }

        this.modalDetail.showIssues = false;
        this.modalDetail.isFirstStep = true;
    }

    handleNotes() {
        let title = this.fieldValues.noteTitle;
        let content = this.fieldValues.noteContent;
        this.closeModal();
    }

    handleEdit() {
        // If there are no errors
        this.handleErrors(['editSlot', 'editDaySlot', 'editCorporate']);
        if (Object.keys(this.error).length === 0) {
            let isFirstStep = this.modalDetail.isFirstStep;
            this.modalDetail.isFirstStep = false;
            this.modalDetail.showIssues = false;
            this.modalDetail.isLoading = true;
    
            let slot = parseInt(this.fieldValues.editSlot) -1;
            let day = parseInt(this.fieldValues.editDaySlot) -1;
    
            let start = this.listDays[day];
            let end = this.listDays[day];
            let startTime = this.listSlots[slot].start.split(':');
            let endTime = this.listSlots[slot].end.split(':');
            start.setHours(startTime[0]);
            start.setMinutes(startTime[1]);
            end.setHours(endTime[0]);
            end.setMinutes(endTime[1]);
    
            let newStartDate  = start.getFullYear()+'-'+(start.getMonth()+1)+'-'+start.getDate()+' '+this.listSlots[slot].fullStartDate.split(' ')[1];
            let newEndDate  = end.getFullYear()+'-'+(end.getMonth()+1)+'-'+end.getDate()+' '+this.listSlots[slot].fullEndDate.split(' ')[1];

            let pastStartDate  = this.listSlots[slot].fullStartDate.split(' ')[0]+' '+this.selectedItem.startDate +':00';
            let pastEndDate  = this.listSlots[slot].fullEndDate.split(' ')[0]+' '+this.selectedItem.endDate +':00';

            let newCoorporateId;
            if(this.fieldValues.editCorporate === undefined)
            {
                newCoorporateId = this.selectedItem.coorporateId
            }else
            {
                newCoorporateId = this.corporatesOptions[this.fieldValues.editCorporate].id;
            }
    
            let paramsSearch = {
                eventId: this.recordId,
                startDate: newStartDate,
                endDate: newEndDate,
                coorporateId: newCoorporateId,
                investorIds: [(''+this.selectedItem.selectedAttendee.Id)],
            }
    
            let paramsEdit = {
                eventId: this.recordId,
                startDate: newStartDate,
                endDate: newEndDate,
                coorporateId: newCoorporateId,
                investorIds: [(''+this.selectedItem.selectedAttendee.Id)],
                pastStartDate: this.selectedItem.startDate,
                pastEndDate: this.selectedItem.endDate,
                pastCoorporateId: this.selectedItem.coorporateId,
                pastMeetingId: this.selectedItem.meetingId
            }
    
            if (isFirstStep){
                searchAvailability(
                    {
                        searchParam : JSON.stringify(paramsSearch)
                    }
                ).then(data => {
                    this.result = data;
                    this.modalDetail.isLoading = false;
                    this.modalDetail.showIssues = true;
                    
                })
                .catch(error => {
                    this.modalDetail.isFirstStep = true;
                    this.modalDetail.isLoading = false;
                });

            } else {
                if (this.modals.isForceEdit) {
                    this.modalDetail.isLoading = false;
                    this.modalDetail.hasFinished = true;
                
                    forceMeeting(
                        {
                            forceMeetParams : JSON.stringify(paramsSearch)
                        })
                    .then(data => {
                        this.modalDetail.isLoading = false;
                        this.modalDetail.hasFinished = true;

                        this.dataInfo.hasLoad = false;
                        this.getMatrix();
                    })
                    .catch(error => {
                        this.modalDetail.isLoading = false;
                        this.modalDetail.hasFinished = true;
                        this.modalDetail.hasError = true;
                    })
                
                } else {
                    editMeeting(
                        {
                            editMeetParams : JSON.stringify(paramsEdit)
                        }
                    ).then(data => {
                        this.modalDetail.isLoading = false;
                        this.modalDetail.hasFinished = true;
    
                        this.dataInfo.hasLoad = false;
                        this.getMatrix();
                    })
                    .catch(error => {
                        this.modalDetail.isLoading = false;
                        this.modalDetail.hasFinished = true;
                        this.modalDetail.hasError = true;
                    });
                    
                }
            }
        
        } else {
            this.handleBack();
        }
    }

    handleForce() {
        // If there are no errors
        this.handleErrors(['forceCorporate', 'forceSlot', 'forceDaySlot', 'forceInvestors']);
        if (Object.keys(this.error).length === 0) {
            let isFirstStep = this.modalDetail.isFirstStep;
            this.modalDetail.isFirstStep = false;
            this.modalDetail.showIssues = false;
            this.modalDetail.isLoading = true;

            let slot = parseInt(this.fieldValues.forceSlot) -1;
            let day = parseInt(this.fieldValues.forceDaySlot) -1;

            let start = this.listDays[day];
            let end = this.listDays[day];
            let startTime = this.listSlots[slot].start.split(':');
            let endTime = this.listSlots[slot].end.split(':');
            start.setHours(startTime[0]);
            start.setMinutes(startTime[1]);
            end.setHours(endTime[0]);
            end.setMinutes(endTime[1]);

            let newStartDate  = start.getFullYear()+'-'+(start.getMonth()+1)+'-'+start.getDate()+' '+this.listSlots[slot].fullStartDate.split(' ')[1];
            let newEndDate  = end.getFullYear()+'-'+(end.getMonth()+1)+'-'+end.getDate()+' '+this.listSlots[slot].fullEndDate.split(' ')[1];

            let paramsSearch = {
                eventId: this.recordId,
                startDate: newStartDate,
                endDate: newEndDate,
                coorporateId: this.corporatesOptions[this.fieldValues.forceCorporate].id,
                investorIds: this.fieldValues.forceInvestors,
            }

            if (isFirstStep){
                searchAvailability(
                    {
                        searchParam : JSON.stringify(paramsSearch)
                    }
                ).then(data => {
                    this.result = data;
                    this.modalDetail.isLoading = false;
                    this.modalDetail.showIssues = true;
                    
                })
                .catch(error => {
                    this.modalDetail.isFirstStep = true;
                    this.modalDetail.isLoading = false;
                });

            } else {
                this.modalDetail.isLoading = false;
                this.modalDetail.hasFinished = true;

                
                forceMeeting(
                    {
                        forceMeetParams : JSON.stringify(paramsSearch)
                    }
                ).then(data => {
                    this.modalDetail.isLoading = false;
                    this.modalDetail.hasFinished = true;

                    this.dataInfo.hasLoad = false;
                    this.getMatrix();
                })
                .catch(error => {
                    this.modalDetail.isLoading = false;
                    this.modalDetail.hasFinished = true;
                    this.modalDetail.hasError = true;
                })
                
            }

        }else {
            this.handleBack();
        }
    }

    handleDelete() {
        deleteAttendance({attendeeId: this.selectedAttendee.Id, meetingId: this.selectedMeeting})
        .then(data => {;
            this.dataInfo.hasLoad = false;
            this.getMatrix();
        })
        .catch(error => {
            this.dataInfo.hasLoad = false;
            this.getMatrix();
        });

        this.closeModal();
    }

    handlePublish() {
        publishMeetings({eventId: this.recordId})
        .then(data => {
            this.dataInfo.hasLoad = false;
            this.getMatrix();
            
        })
        .catch( error => {
            this.dataInfo.hasLoad = false;
            this.getMatrix();
        });
        this.closeModal();
    }

    async handleCorporatesAndMeetingsToPublish() {
        const el = this.template.querySelector('lightning-tree-grid');
        const selected = el.getSelectedRows();
        this.corporatesSelected = selected;
        const corporateIds = [];
        const meetingIds = [];
        for (let i = 0; i < selected.length; i++) {
            if (selected[i].Corporate) {
                corporateIds.push(selected[i].Id);
            } else {
                meetingIds.push(selected[i].Id);
            }
        }
        for (let i = 0; i < this.activeMeetings.length; i++) {
            if (meetingIds.includes(this.activeMeetings[i])) {
                let index = meetingIds.indexOf(this.activeMeetings[i]);
                meetingIds.splice(index, 1);
            }
        }
        try {
            await publishCorporateMeetings({eventId: this.recordId, corporateIds: corporateIds, meetingIds: meetingIds});
            this.modals.isPublishOpen = false;
            this.dataInfo.hasLoad = false;
            this.getMatrix();
        } catch (err) {}
    }

    handleSelect (event) {
        const selectedItemValue = event.detail.value;
        if(selectedItemValue === 'exportCSV'){
            this.handleExport();
        }else{
            this.handleGenerateAgenda();
        }
    }

    handleExport() {
        let csv = this.labels.Corporate +', ' +this.labels.CorporateCountry+', '+this.labels.Day+', '+this.labels.Meeting+', '+this.labels.TimeSlot+
        ', '+this.labels.DelOrganisation+', '+this.labels.DelFullName+', '+this.labels.DelFirstName+', '+this.labels.DelLastName+', '+this.labels.DelEmail+
        ', '+this.labels.DelCountry+', '+this.labels.RelManager+'\n';
        
        this.corporatesData.forEach(data => {
            let meetings = data.listSlots.filter(slot => slot.meeting !== null);
            meetings = meetings.filter(slot => slot.meeting.listInvestor.length > 0);
            meetings.forEach(slot => {
                slot.meeting.listInvestor.forEach( investor => {
                    csv = csv + data.coorporate.EAP_ContactName__c + ',';
                    csv = csv + ((data.coorporate.EAP_Country__c !== undefined)? data.coorporate.EAP_Country__c : '') + ',';
                    csv = csv + slot.numDay + ',';
                    csv = csv + slot.numSlot +',';
                    csv = csv + slot.startDate + ' - ' + slot.endDate + ',';
                    csv = csv + investor.EAP_Attendee__r.EAP_AttendeeCompany__c + ',';
                    csv = csv + investor.EAP_Attendee__r.EAP_ContactName__c + ',';
                    csv = csv + investor.EAP_Attendee__r.EAP_Contact__r.FirstName + ',';
                    csv = csv + investor.EAP_Attendee__r.EAP_Contact__r.LastName + ',';
                    csv = csv + investor.EAP_Attendee__r.EAP_Contact__r.Email + ',';
                    csv = csv + ((investor.EAP_Attendee__r.EAP_Contact__r.Phone_Country__c !== undefined)? investor.EAP_Attendee__r.EAP_Contact__r.Phone_Country__c : '') + ',';

                    let rlsm = this.investorsOptions.filter(inv => inv.value === investor.EAP_Attendee__c)
                    if (rlsm.length === 1) {
                        rlsm = rlsm[0].relationshipManager;
                    }
                    csv = csv + ((rlsm !== undefined) ? rlsm : '') + '\n';
                })

            })

        });

        let hiddenElement = document.createElement('a');
        hiddenElement.href = 'data:text/csv;charset=utf-8,' + encodeURI(csv);
        hiddenElement.target = '_self';
        hiddenElement.download = CSV_NAME + '.csv';
        document.body.appendChild(hiddenElement);
        hiddenElement.click();
    }

    handleGenerateAgenda() {
        generateAgenda({eventId: this.recordId})
        .then(data => {
            alert('PDF Generated')
        })
        .then( error => {

        });
    }
}