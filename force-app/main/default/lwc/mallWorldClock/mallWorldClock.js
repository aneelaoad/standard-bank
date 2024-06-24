import { LightningElement, track } from 'lwc';
const MALL_WIDGET_FOREIGN_EXCHANGE_HEADING = "World Clock";
import getTimeWithLocation from '@salesforce/apex/CTRL_MallDashboardWidgets.getLocationTime';

export default class MallWorldClock extends LightningElement {
    resultData = true;
    heading = MALL_WIDGET_FOREIGN_EXCHANGE_HEADING;
    error;
    @track list = [
        {
            id: 1,
            timezone: "GMT+8",
            timeOfDay: "PM",
            time: "11:45",
            city: "Singapore",
            country: "Singapore",
            day: "Thursday"
        },
        {
            id: 2,
            timezone: "GMT+9",
            timeOfDay: "AM",
            time: "12:45",
            city: "Tokyo",
            country: "Japan",
            day: "Friday"
        },
        {
            id: 3,
            timezone: "EDT",
            timeOfDay: "AM",
            time: "11:45",
            city: "New York",
            country: "United States of America",
            day: "Thursday"
        },
        {
            id: 4,
            timezone: "UCT+4",
            timeOfDay: "PM",
            time: "11:45",
            city: "Cape Town",
            country: "South Africa",
            day: "Thursday"
        }

    ]

    connectedCallback() {
        this.setUpWorldClock();
    }

    async setUpWorldClock() {
        try {
            for(let row=0; row < this.list.length; row++) {
                await this.getTimeByLocation(row, encodeURI(this.list[row].city + ',' + this.list[row].country));
            }
        }catch(error) {
            this.error = error;
        }

    }

    async getTimeByLocation(index, locationName){
        try {
            const result = await getTimeWithLocation({location: locationName});
            let location = {...this.list[index]};
            location.timezone =  result.message.timezone_abbreviation; 
            let formattedDateInfo = this.formatDate(result.message.datetime);
            location.time = formattedDateInfo.formattedTime; 
            location.timeOfDay = formattedDateInfo.timeOfDay; 
            location.day = formattedDateInfo.dayOfWeek; 
            this.list[index] = {...location};
        }catch(error) {
            this.error = error;
        }
    }

    formatDate(dateString) {
        let  dateObject = new Date(dateString);
        let dayInfo = {};
        dayInfo.formattedDate = dateObject.toISOString().split('T')[0];
        let hours = dateObject.getHours();
        let minutes = dateObject.getMinutes();
        dayInfo.formattedTime = this.formatTime12Hours(hours, minutes);
        dayInfo.timeOfDay = dateObject.toLocaleTimeString([], {hour12: true, hour: '2-digit', minute:'2-digit'}).split(' ')[1];
        dayInfo.dayOfWeek = dateObject.toLocaleDateString('en-US', {weekday: 'long'});
        return dayInfo;
    }

    formatTime12Hours(hours, minutes) {
        var formattedHours = hours % 12 || 12; 
        return formattedHours + ":" + (minutes < 10 ? "0" : "") + minutes;
    }

}