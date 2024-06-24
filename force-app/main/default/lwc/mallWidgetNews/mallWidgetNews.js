import { LightningElement } from 'lwc';
import { NavigationMixin } from "lightning/navigation";
import { navigateToWebPage } from "c/mallNavigation";
import getNews from '@salesforce/apex/CTRL_MallDashboardWidgets.getNews';
const MALL_WIDGET_NEWS_HEADING = "Breaking News";
const TAB_CLASS = "tab";

export default class MallWidgetNews extends NavigationMixin (LightningElement) {
    //Need to remove this check when we have data that passes through here.
    resultData = true;
    heading = MALL_WIDGET_NEWS_HEADING;
    headingStart = MALL_WIDGET_NEWS_HEADING.trim().split(' ')[0];
    headingEnd = MALL_WIDGET_NEWS_HEADING.split(' ').pop();
    selectedTabName = '';
    navigateToWebPage = navigateToWebPage.bind(this);
    tabList = [
        {
            name: "Top Stories",
            tabClass: TAB_CLASS + " active",
            filter: {'country' : '', 'category':'', 'sources':'google-news'}
        },
        {
            name: "Business",
            tabClass: TAB_CLASS,
            filter: {'country' : 'za', 'category':'business', 'sources':''}
        },
        {
            name: "SA News",
            tabClass: TAB_CLASS,
            filter: {'country' : 'za', 'category':'', 'sources':''}
        }
    ]

    list = [];

    connectedCallback() {
        if(!this.selectedTabName) {
            let selectedTab = (this.tabList && this.tabList.length > 0) ? this.tabList[0] : {};
            if(JSON.stringify(selectedTab) != '{}') {
                this.selectedTabName = selectedTab.name;
                this.getNewsByCategory(selectedTab.filter);
            }
        }
    }

    handleTabChange(event) {
        let elem = event.target;
        this.template.querySelectorAll(".tab").forEach((item) => {
            item.classList.remove("active");
        })
        elem.classList.toggle("active");
        let categoryName = elem.textContent;
        this.selectedTabName = categoryName;
        let tabDetails = this.tabList.find(elem => elem.name === categoryName);
        if(tabDetails) {
            this.getNewsByCategory(tabDetails.filter);
        }
    }

    async getNewsByCategory(filterObject) {
        try {
            let newsResults =  await getNews(filterObject);
            if(newsResults.statusCode == 200) {
                let data = newsResults.message;
                this.list = [];
                let list = [];
                data.articles.forEach((article,index) => {
                    let listObj = {};
                    listObj.id = 1 + index;
                    listObj.description = article.title;
                    listObj.imageUrl = article.urlToImage;
                    listObj.url = article.url;
                    listObj.timeStamp = this.calculateTimeAgo(article.publishedAt);
                    listObj.publishedAt = this.calculateTimeAgo(article.publishedAt);
                    list.push(listObj);
                });
                list = this.sortData("publishedAt", "asc", list, "datetime");
                this.list = [...list];
            } else {
                this.list = [];
            }
        } catch(error) {
            this.error = error;
            this.list = [];
        }
    }

    calculateTimeAgo(publishedAt) {
        var now = new Date();
        var publishedDate = new Date(publishedAt);
        var timeDifference = now - publishedDate;
        var minutesDifference = Math.floor(timeDifference / (1000 * 60));
        if(minutesDifference) {
            return this.formatTimeAgo(minutesDifference);
        }
    }

    formatTimeAgo(minutesDifference) {
        const minutesInDay = 24 * 60;
        const minutesInHour = 60;
      
        const days = Math.floor(minutesDifference / minutesInDay);
        const hours = Math.floor((minutesDifference % minutesInDay) / minutesInHour);
        const minutes = minutesDifference % minutesInHour;
      
        let result = "";
      
        if (days > 0) {
          result += days + " day" + (days === 1 ? "" : "s");
        }
      
        if (hours > 0) {
          if (result !== "") {
            result += ", ";
          }
          result += hours + " hour" + (hours === 1 ? "" : "s");
        }
      
        if (minutes > 0) {
          if (result !== "") {
            result += ", ";
          }
          result += minutes + " minute" + (minutes === 1 ? "" : "s");
        }
      
        return result === "" ? "just now" : result + " ago";
    }

    handleNavigateToNewsSource(event) {
        event.preventDefault();
        event.stopPropagation();
        const url = event.currentTarget.dataset.url;
        window.open(url,"_blank");
    }

    sortData(fieldName, sortDirection, array, type) {
        let sortResult = [...array];
        let parser = (v) => v;
        if(type==='date' || type==='datetime') {
          parser = (v) => (v && new Date(v));
        }
        let sortMult = sortDirection === 'asc'? 1: -1;
        array = sortResult.sort((a,b) => {
          let a1 = parser(a[fieldName]), b1 = parser(b[fieldName]);
          let r1 = a1 < b1, r2 = a1 === b1;
          return r2? 0: r1? -sortMult: sortMult;
        });
        return array;
    }
}