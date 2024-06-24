import { LightningElement, wire, track } from 'lwc';
import { CurrentPageReference, NavigationMixin } from 'lightning/navigation';
import customIcons from '@salesforce/resourceUrl/EapCustomResourcers';
import getEventById from '@salesforce/apex/EAP_CTRL_EventDetailPage.getEventById';
import getDocImages from '@salesforce/apex/EAP_UTIL_EventsApp.getDocImages';
import getMatchmakingExecuted from '@salesforce/apex/EAP_CTRL_AvailabilityPage.getMatchmakingExecuted';
import getRoleEvent from '@salesforce/apex/EAP_CTRL_AvailabilityPage.getRoleEvent';
import getCorporates from '@salesforce/apex/EAP_CTRL_AvailabilityPage.getCorporates';
import getAvailability from '@salesforce/apex/EAP_CTRL_AvailabilityPage.getAvailability';
import saveAvailability from '@salesforce/apex/EAP_CTRL_AvailabilityPage.saveAvailability';
import ALL_DAY_LABEL from '@salesforce/label/c.Eap_AllDay_Label';
import NO_ONE_LABEL from '@salesforce/label/c.Eap_NoOne_Label';
import FORM_UPDATED_LABEL from '@salesforce/label/c.Eap_FormUpdated_Label';
import MORNING_LABEL from '@salesforce/label/c.Eap_Morning_Label';
import NO_AVAILABILITY_LABEL from '@salesforce/label/c.Eap_NoAvailibility_Label';
import NO_FORM_LABEL from '@salesforce/label/c.Eap_NoFormUpdated_Label';
import AFTERNOON_LABEL from '@salesforce/label/c.Eap_Afternoon_Label';
import ACCEPT_LABEL from '@salesforce/label/c.Eap_Accept_Label';
import GO_BACK_LABEL from '@salesforce/label/c.Eap_GoBack_Label';
import NEXT_LABEL from '@salesforce/label/c.Eap_Next_Label';
import SELECTED_CORPORATE_LABEL from '@salesforce/label/c.Eap_SelectedCorporate_Label';
import SELECT_AVAILABILITY_LABEL from '@salesforce/label/c.Eap_SelectAvailability_Label';
import SELECT_CORPORATES_LABEL from '@salesforce/label/c.Eap_SelectCorporates_Label';

const DEFAULT_IMG = '/StandardBankLogo.png';

export default class EapAvailabilityDetailContent extends NavigationMixin(LightningElement) {
    labels = {None: NO_ONE_LABEL, AllDay: ALL_DAY_LABEL, FormUpdated: FORM_UPDATED_LABEL, Morning:MORNING_LABEL,
            NoAvailability: NO_AVAILABILITY_LABEL, NoFormUpdated: NO_FORM_LABEL, Afternoon:AFTERNOON_LABEL,
            Accept: ACCEPT_LABEL, GoBack: GO_BACK_LABEL, Next: NEXT_LABEL, SelectedCorporates: SELECTED_CORPORATE_LABEL,
            SelectAvailability: SELECT_AVAILABILITY_LABEL, SelectCorporates: SELECT_CORPORATES_LABEL};
    addIcon = customIcons + '/addButton.svg';
    removeIcon = customIcons + '/trashcan.svg';

    @track matchmakingExecuted;
    @track event = {};                //Object with data about the event
    @track daysOfEvent = [];          //Days of event. use to print slot-Selects
    @track isInvestor = false;        //If is investor the form has 2 steps
    @track firstStep = true;          //if is the first or second step
    @track originalCorporates = [{id: 0, name: '-- ' + this.labels.None + ' --'}];   //List with info of all corporates
    @track picklistCorporates =[];    //List of corporates picklists
    @track selectedCorporates = [];   //List of selected corporates
    @track availabilityOptions = [];

    /* Receive event Id */
    @wire(CurrentPageReference)
    getStateParameters(currentPageReference) {
        if (currentPageReference) {
            this.urlStateParameters = currentPageReference.state;
            this.setParametersBasedOnUrl();
        }
    }

    setParametersBasedOnUrl() {
        this.event.Id = this.urlStateParameters.eventId || null;
        getMatchmakingExecuted({eventId: this.event.Id})
        .then( dataMatchmaking => {
            this.matchmakingExecuted = dataMatchmaking;
            this.loadEvent();
        }).catch (error => {});
    }

    loadEvent(){
        getEventById({eventId: this.event.Id})
        .then((data) => {
            let eventData = data.event;
            let dates = this.getDates(eventData.EAP_StartDate__c, eventData.EAP_EndDate__c);
            this.event = {
                Id: this.event.Id,
                Name: eventData.Name,
                Location: eventData.EAP_Location__c,
                Date: dates.Start + ' - ' + dates.End,
                StartDate: eventData.EAP_StartDate__c,
                EndDate: eventData.EAP_EndDate__c
            };

            let imagesParam = [];
            if(eventData !== undefined){
                imagesParam.push({ objId: eventData.Id, docId: data.mainPhoto } )
            }

            getDocImages({docImageList: JSON.stringify(imagesParam)})
            .then((dataImg) => {
                if(dataImg) {
                    let mapEvDoc = dataImg;
                    let docPhoto = mapEvDoc[eventData.Id];
                    this.event.Img = (docPhoto !== undefined) ? docPhoto:customIcons + DEFAULT_IMG;
                }
            })
            .catch((error) => {});

            getRoleEvent({eventId: this.event.Id})
            .then(roleData => {
                if (roleData === 'Investor') {
                    this.isInvestor = true;
                }

                getAvailability({eventId: this.event.Id})
                .then(avData =>{
                    let datesList = Object.keys(avData);
                    this.getFilledAvailability(datesList, avData);
                })
                .catch(error => {})
            })
            .catch(error => {})
        })
        .catch((error) => {})
    }

    getFilledAvailability(dates, infoDates){
        let dayOfEvent = new Date(this.event.StartDate);
        let endDate = new Date(this.event.EndDate);
        let idDay = 0;
        let countMeetAv = 0;
        let dayMeetAv;
        let timeMorningStart;
        let timeNoon;
        let timeAfternoonEnd;
        if (dates.length > 0) {
            timeMorningStart = this.formatAMPM(infoDates[dates[0]].timeMorningStart);
            timeNoon = this.formatAMPM(infoDates[dates[0]].timeNoon);
            timeAfternoonEnd = this.formatAMPM(infoDates[dates[0]].timeAfternoonEnd);
        }

        let options = [{ value: 'none', label: this.labels.NoAvailability},
                        { value: 'allDay', label: this.labels.AllDay},
                        { value: 'morning', label: this.labels.Morning +' (' + timeMorningStart + ' - ' + timeNoon + ')'},
                        { value: 'afternoon', label: this.labels.Afternoon +' (' + timeNoon + ' - ' + timeAfternoonEnd + ')'}];
        this.availabilityOptions = JSON.parse(JSON.stringify(options));

        do {
            if (countMeetAv < dates.length) {
                let dt1 = dates[countMeetAv].substring(dates[countMeetAv].indexOf('time=')+5);
                dayMeetAv = new Date(parseInt(dt1.substring(0, dt1.indexOf(','))));

                if (dayOfEvent.getDate() ===  dayMeetAv.getDate() && dayOfEvent.getMonth() ===  dayMeetAv.getMonth()){
                    if (infoDates[dates[countMeetAv]].onAfternoon && infoDates[dates[countMeetAv]].onMorning) {
                        options[1].isSelected = true;
                    
                    } else if (infoDates[dates[countMeetAv]].onMorning === true) {
                        options[2].isSelected = true;
    
                    } else if (infoDates[dates[countMeetAv]].onAfternoon === true) {
                        options[3].isSelected = true;
                    }
                    countMeetAv++;
                }
            }

            this.daysOfEvent.push({id: idDay,
                                    Date: dayOfEvent.getDate() + '/' + (dayOfEvent.getMonth()+1) + '/' + dayOfEvent.getFullYear(),
                                    availibilityOptions: options});
            
            idDay++;
            options = JSON.parse(JSON.stringify(this.availabilityOptions));
            dayOfEvent.setDate(dayOfEvent.getDate()+1);
        }while (dayOfEvent <= endDate);

        getCorporates({eventId: this.event.Id})
        .then(data => {
            data.forEach((item) => {
                let corporateToInsert = {id: item.id,
                                        name: item.name,
                                        contactPhoto: item.contactPhoto,
                                        clientName: item.clientName,
                                        isSelected: false};

                if (corporateToInsert.contactPhoto === null){
                    corporateToInsert.initials = this.getInitials(corporateToInsert.name);
                }
                this.originalCorporates.push(corporateToInsert);

                if (item.isSelected) {
                    corporateToInsert.preference = item.preference;
                    this.selectedCorporates.push(corporateToInsert);
                }
            });

            this.selectedCorporates.sort(this.comparePreference);
            this.selectedCorporates.forEach((item, index) => {
                let corpsList = JSON.parse(JSON.stringify(this.originalCorporates));
                let indexCorp = corpsList.indexOf(corpsList.find(({id}) => id === item.id));
                corpsList[indexCorp].isSelected = true;

                this.picklistCorporates.push({Id: (index+1), corporatesList: corpsList});
            });

            if (this.picklistCorporates.length < 1) {
                this.picklistCorporates.push({Id: 1, corporatesList: JSON.parse(JSON.stringify(this.originalCorporates))});
            }

            this.updatePicklistCorp();
        })
        .catch((error) => {})


        const loadedEvent = new CustomEvent('loaded', {});
        this.dispatchEvent(loadedEvent);
    }

    comparePreference(corporateA, corporateB){
        if ( corporateA.preference < corporateB.preference )
            return -1;
        else if ( corporateA.preference > corporateB.preference )
            return 1;
        else
            return 0;
    }

    getDates(start, end = ""){
        let dates = {};
        let startDate = new Date(start);
        let startMonth = new Intl.DateTimeFormat('en', { month: 'short' }).format(startDate);
        let endDate = new Date(end);
        let endMonth = new Intl.DateTimeFormat('en', { month: 'short' }).format(endDate);
        dates = {End: endDate.getDate() + " " + endMonth + " " + endDate.getFullYear()};

        if (startMonth !== endMonth)
        {
            if (startDate.getFullYear() !== endDate.getFullYear())
                dates.Start = startDate.getDate() + " " + startMonth + " " + startDate.getFullYear();
            else
                dates.Start = startDate.getDate() + " " + startMonth;
        }else
        {
            dates.Start = startDate.getDate();
        }

        return dates;
    }

    formatAMPM(date) {
        let data = date.toString().split(':');
        let hours = data[0];
        let minutes = 0;
        if (data[1]) {
            minutes = data[1];
        }
        let ampm = hours >= 12 ? 'pm' : 'am';
        hours = hours % 12;
        hours = hours ? hours : 12; 
        minutes = minutes < 10 ? '0'+minutes : minutes;
        let strTime = hours + ':' + minutes + ' ' + ampm;
        return strTime;
    }

    getInitials(fullName){
        let fullNameArray = fullName.split(" ");
        let initials = '';

        fullNameArray.forEach(name => {
            initials += name[0];
        })

        return initials;
    }

    handleInputChange(e) {
        let options = JSON.parse(JSON.stringify(this.availabilityOptions));
        let countOptions = 0;
        let finded = false;
        do {
            if (options[countOptions].value === e.target.value) {
                options[countOptions].isSelected = true;
                finded = true;
            
            } else {
                countOptions++;
            }

        } while (!finded && countOptions < options.length);

        let countDay = 0;
        finded = false;
        do {
            if (this.daysOfEvent[countDay].Date === e.target.name) {
                finded = true;
                this.daysOfEvent[countDay].availibilityOptions = options;

            } else {
                countDay++;
            }

        } while (!finded && countDay < this.daysOfEvent.length);
    }

    handleSelect(e) {
        let idPicklist = e.target.dataset.id;
        let idCorporate = e.target.value;
        this.picklistCorporates[idPicklist].corporatesList.forEach( item => {
            if (item.id === idCorporate) {
                item.isSelected = true;
            
            } else {
                item.isSelected = false;
            }
        })

        this.selectedCorporates = [];
        this.picklistCorporates.forEach( (item, index)  => {
            let selectedFinded = false;
            let i = 0;
            do{
                if ((item.corporatesList[i].isSelected) && (item.corporatesList[i].id !== 0)) {
                    selectedFinded = true;
                    
                } else {
                    i++;
                }

            } while (!selectedFinded && i < item.corporatesList.length);

            if (selectedFinded) {
                item.corporatesList[i].preference = index+1;
                this.selectedCorporates.push(item.corporatesList[i]);
            }
        });

        this.updatePicklistCorp();
    }

    get hasReachedLimit() {
        if (this.picklistCorporates.length < this.originalCorporates.length) {
            return false;
        
        } else {
            return true;
        }
    }

    addCorporate() {
        this.picklistCorporates.push({Id: (this.picklistCorporates.length+1), corporatesList: JSON.parse(JSON.stringify(this.originalCorporates))});
        this.updatePicklistCorp();
    }

    removeCorporate(e) {
        let idPicklist = e.target.dataset.id;

        let corpToRemove = this.picklistCorporates[idPicklist].corporatesList.find(({isSelected}) => isSelected === true);
        corpToRemove = this.selectedCorporates.find(({id}) => id === corpToRemove.id);
        let indexToRemove = this.selectedCorporates.indexOf(corpToRemove);
        this.selectedCorporates.splice(indexToRemove, 1);
        this.selectedCorporates.forEach((item, index) => { item.preference = index});

        this.picklistCorporates.splice(idPicklist, 1);
        this.picklistCorporates.forEach( (item, index) => { item.Id = index+1; });
        this.updatePicklistCorp();
    }

    updatePicklistCorp() {
        this.picklistCorporates.forEach( item => {
            item.corporatesList.forEach( corp => {
                if ( !corp.isSelected && (this.selectedCorporates.find(({id}) => id === corp.id) !== undefined) ){
                    corp.isInList = true;
                
                } else {
                    corp.isInList = false;
                }
            })
        });

        this.selectedCorporates.sort(this.comparePreference);
    }

    changeStep() {
        this.firstStep = !this.firstStep;
    }

    saveChanges() {
        const loadedEvent = new CustomEvent('reload', {});
        this.dispatchEvent(loadedEvent);

        let availabilityToSend = [];
        this.daysOfEvent.forEach(item => {
            let dateList = item.Date.split('/');
            let date = new Date (dateList[2], (dateList[1]-1), (parseInt(dateList[0])+1));
            let offset = date.getTimezoneOffset() / 60;
            date.setHours(date.getHours() + offset);
            date = date.getTime(); //Return time in miliseconds

            let availability;
            let countOptions = 0;
            let finded = false;
            do {
                if (item.availibilityOptions[countOptions].isSelected) {
                    finded = true;
                    availability = item.availibilityOptions[countOptions].value;
                
                } else {
                    countOptions++;
                }

            } while(!finded && countOptions < item.availibilityOptions.length);

            if (finded) {
                availabilityToSend.push({DateToInsert: date, Availability: availability});
            }
        });

        saveAvailability({eventId: this.event.Id, meetingAvailability: JSON.stringify(availabilityToSend), corporatesToMeet: JSON.stringify(this.selectedCorporates)})
        .then(data => {
            this[NavigationMixin.Navigate]({
                type: "comm__namedPage",
                attributes: {
                    name: 'Confirmation__c'
                },state: {
                    message: this.labels.FormUpdated,
                    destination: 'Event_Detail__c',
                    type: 'Success',
                    eventId:  this.event.Id
                }
            });
        
        }).catch(error => {
            this[NavigationMixin.Navigate]({
                type: "comm__namedPage",
                attributes: {
                    name: 'Confirmation__c'
                },state: {
                    message: this.labels.NoFormUpdated,
                    destination: 'Event_Detail__c',
                    type: 'Error',
                    eventId:  this.event.Id
                }
            });
        });
    }
}