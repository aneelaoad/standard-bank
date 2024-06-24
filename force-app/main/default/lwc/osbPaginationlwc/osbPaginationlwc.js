import { LightningElement, api } from "lwc";
import OSB_pagination from '@salesforce/resourceUrl/OSB_pagination';

export default class OSBPaginationlwc extends LightningElement {

    FirstPageChevronDisabled = OSB_pagination + '/FirstPagePaginatorIconDisabled.svg';
    PreviousPageChevronDisabled = OSB_pagination + '/PreviousPagePaginatorIconDisabled.svg';
    FirstPageChevronActive = OSB_pagination + '/FirstPagePaginatorIconActive.svg';
    PreviousPageChevronActive = OSB_pagination + '/PreviousPagePaginatorIconActive.svg';
    LastPageChevronDisabled = OSB_pagination + '/LastPagePaginatorIconDisabled.svg';
    NextPageChevronDisabled = OSB_pagination + '/NextPagePaginatorIconDisabled.svg';
    LastPageChevronActive = OSB_pagination + '/LastPagePaginatorIconActive.svg';
    NextPageChevronActive = OSB_pagination + '/NextPagePaginatorIconActive.svg';

    @api
    get fullListValue() {
        return this.fulllist;
    }

    set fullListValue(value) {
        this.fulllist = value;
        this.connectedCallback();
    }

    @api showapplication = false;
    @api shownotification = false;
    @api pageSize = 9;

    fulllist = [];
    currentPage = 1;
    pagesTotal;
    firstVisible = false;
    lasVisible = false;
    pageTotalGreaterThanOne = false;
    displayedList = [];
    DisableLeft = true;
    DisableRight = false;
    isLoading = false;

    connectedCallback() {
        if (this.fulllist) {
            let receivedList = this.fulllist;
            let pageSize = this.pageSize;
            let pagesTotal = Math.ceil(receivedList.length / pageSize);
            let pages = [];
            for (let page = 1; page <= pagesTotal; page++) {
                pages.push(page);
            }

            this.pages = pages;
            this.pagesTotal = pagesTotal;
        }
        this.currentPage = 1;
        this.changePage();

    }

    renderedCallback() {
        let pageCheck = 1;
        let pageSize = this.pageSize;
        let pagesTotal = Math.ceil(this.fulllist.length / pageSize);
        if (pageCheck <= pagesTotal && this.shownotification) {
            this.template
                .querySelector('[data-id="notifcations-container"]')
                .classList.remove("notifications__container");
        }
    }

    onNextPage() {
        let pageNumber = this.currentPage;
        this.currentPage = parseInt(pageNumber, 10) + 1;
        this.changePage();
    }

    onPrevPage() {
        let pageNumber = this.currentPage;
        this.currentPage = parseInt(pageNumber, 10) - 1;
        this.changePage();
    }

    onFirstPage() {
        this.currentPage = 1;
        this.changePage();
    }

    onLastPage() {
        this.currentPage = this.pagesTotal;
        this.changePage();
    }

    onPageButtonClick(event) {
        let pageNumField = event.target.dataset.id;
        let pageNumber = pageNumField ? pageNumField : "";
        this.currentPage = pageNumber;
        this.changePage();
    }

    changePage() {
        let displayedData = [];
        let currentPage = this.currentPage;
        let pageSize = this.pageSize;
        let data = this.fulllist;
        let x = (currentPage - 1) * pageSize;
        for (; x < currentPage * pageSize; x++) {
            if (data[x]) {
                displayedData.push(data[x]);
            }
        }
        this.displayedList = displayedData;
        document.body.scrollTop = 0;
        document.documentElement.scrollTop = 0;

        this.styleButtons();
        this.generatePageList();
    }

    generatePageList() {
        let pageNumber = parseInt(this.currentPage, 10);
        let pageList = [];
        let totalPages = this.pagesTotal;
        this.pageTotalGreaterThanOne = true;

        if (totalPages > 2) {
            if (pageNumber === 1) {
                pageList.push(
                    { pgNum: pageNumber, pgCurr: true },
                    { pgNum: pageNumber + 1, pgCurr: false },
                    { pgNum: pageNumber + 2, pgCurr: false }
                );
            } else if (pageNumber === totalPages) {
                pageList.push(
                    { pgNum: pageNumber - 2, pgCurr: false },
                    { pgNum: pageNumber - 1, pgCurr: false },
                    { pgNum: pageNumber, pgCurr: true }
                );
            } else if (pageNumber > 1 && pageNumber < totalPages) {
                pageList.push(
                    { pgNum: pageNumber - 1, pgCurr: false },
                    { pgNum: pageNumber, pgCurr: true },
                    { pgNum: pageNumber + 1, pgCurr: false }
                );
            }
        } else if (totalPages > 1) {
            if (pageNumber === 1) {
                pageList.push(
                    { pgNum: pageNumber, pgCurr: true },
                    { pgNum: pageNumber + 1, pgCurr: false }
                );
            } else if (pageNumber === totalPages) {
                pageList.push(
                    { pgNum: pageNumber - 1, pgCurr: false },
                    { pgNum: pageNumber, pgCurr: true }
                );
            }
        } else {
            this.pageTotalGreaterThanOne = false;
        }
        this.pages = pageList;
    }

    styleButtons() {

        if (this.pages.length > 1) {
            let pageNumber = parseInt(this.currentPage, 10);
            let totalPages = this.pagesTotal;
            if (pageNumber === 1) {
                this.DisableLeft = true;
                this.DisableRight = false;
            } else if (pageNumber === totalPages) {
                this.DisableLeft = false;
                this.DisableRight = true;
            } else {
                this.DisableLeft = false;
                this.DisableRight = false;
            }
        }
    }
}