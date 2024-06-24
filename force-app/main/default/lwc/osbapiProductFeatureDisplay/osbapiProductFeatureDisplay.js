import { api, LightningElement, wire } from "lwc";
import getProductFeatures from "@salesforce/apex/OSB_OD_ProductDetails_CTRL.getProductFeatures";
import OSB_pagination from '@salesforce/resourceUrl/OSB_pagination';

export default class OsbapiProductFeatureDisplay extends LightningElement {

    FirstPageChevronDisabled = OSB_pagination + '/FirstPagePaginatorIconDisabled.svg';
    PreviousPageChevronDisabled = OSB_pagination + '/PreviousPagePaginatorIconDisabled.svg';
    FirstPageChevronActive = OSB_pagination + '/FirstPagePaginatorIconActive.svg';
    PreviousPageChevronActive = OSB_pagination + '/PreviousPagePaginatorIconActive.svg';
    LastPageChevronDisabled = OSB_pagination + '/LastPagePaginatorIconDisabled.svg';
    NextPageChevronDisabled = OSB_pagination + '/NextPagePaginatorIconDisabled.svg';
    LastPageChevronActive = OSB_pagination + '/LastPagePaginatorIconActive.svg';
    NextPageChevronActive = OSB_pagination + '/NextPagePaginatorIconActive.svg';

    @api recordId;

    displayedData = [];
    pages;
    disableLeft = false;
    disableRight = false;

    fullList;
    fullListLength;
    pageSize = 6;
    currentPage = 1;
    pagesTotal;
    displayPagination = false;
    blankPageItem = [];
    featureContainerClasses = "feature-display-container";

    @wire(getProductFeatures, { productId: "$recordId" })
    WiredGetProductFeatures({ data }) {
        if (data) {
            this.fullList = data;
            this.fullListLength = this.fullList.length;
            this.initializePageNavigation(this.fullList);
        }
    }

    initializePageNavigation(data) {
        let pageSize = this.pageSize;
        let pagesTotal = Math.ceil(data.length / pageSize);
        let pages = [];
        for (let page = 1; page <= pagesTotal; page++) {
            pages.push(page);
        }
        this.pages = pages;
        this.pagesTotal = pagesTotal;
        this.initializePages();
        this.changePage();
    }

    initializePages() {
        let totalSlots = this.pageSize * this.pagesTotal;
        if (this.fullListLength % totalSlots !== 0 && this.fullListLength > 6) {
            this.featureContainerClasses += " last-page-has-empty";
        } else {
            this.featureContainerClasses = "feature-display-container";
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
        let data = this.fullList;
        let i = (currentPage - 1) * pageSize;
        for (; i < currentPage * pageSize; i++) {
            if (data[i]) {
                displayedData.push(data[i]);
            }
        }
        this.displayedData = displayedData;
        this.styleButtons();
        this.generatePageList();
    }

    generatePageList() {
        let pageNumber = parseInt(this.currentPage, 10);
        let pageList = [];
        let totalPages = this.pagesTotal;
        this.displayPagination = true;

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
            this.displayPagination = false;
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