import { LightningElement, api } from "lwc";
import OSB_pagination from '@salesforce/resourceUrl/OSB_pagination';

export default class OsbapiProductCataloguePagination extends LightningElement {

    FirstPageChevronDisabled = OSB_pagination + '/FirstPagePaginatorIconDisabled.svg';
    PreviousPageChevronDisabled = OSB_pagination + '/PreviousPagePaginatorIconDisabled.svg';
    FirstPageChevronActive = OSB_pagination + '/FirstPagePaginatorIconActive.svg';
    PreviousPageChevronActive = OSB_pagination + '/PreviousPagePaginatorIconActive.svg';
    LastPageChevronDisabled = OSB_pagination + '/LastPagePaginatorIconDisabled.svg';
    NextPageChevronDisabled = OSB_pagination + '/NextPagePaginatorIconDisabled.svg';
    LastPageChevronActive = OSB_pagination + '/LastPagePaginatorIconActive.svg';
    NextPageChevronActive = OSB_pagination + '/NextPagePaginatorIconActive.svg';

    @api full;
    @api contentComponent;
    @api pageSize = 9;
    @api isSearched = false;
    @api fulllist;
    @api shownotification = false;

    displayedData = [];
    pages;
    ersatz_v_pages_length_greaterThan_number_1 = true;
    DisableLeft = false;
    DisableRight = false;

    currentPage = 1;
    pagesTotal;
    firstVisible = false;
    lasVisible = false;

    @api
    handleChanges(updatedList, searchedFor) {
        this.fulllist = updatedList;
        if (searchedFor) {
            if (searchedFor === true) {
                this.isSearched = true;
            } else {
                this.isSearched = false;
            }
        }
        this.connectedCallback();
    }

    connectedCallback() {
        if (this.fulllist) {
            let data = this.fulllist;
            let pageSize = this.pageSize;
            let pagesTotal = Math.ceil(data.length / pageSize);
            let pages = [];
            for (let page = 1; page <= pagesTotal; page++) {
                pages.push(page);
            }

            this.pages = pages;
            this.pagesTotal = pagesTotal;
            if (this.isSearched) {
                this.currentPage = 1;
                this.changePage();
            } else {
                this.changePage();
            }
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
        this.displayedData = displayedData;
        this.styleButtons();
        this.generatePageList();
    }

    generatePageList() {
        let pageNumber = parseInt(this.currentPage, 10);
        let pageList = [];
        let totalPages = this.pagesTotal;
        this.ersatz_v_pages_length_greaterThan_number_1 = true;

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
            this.ersatz_v_pages_length_greaterThan_number_1 = false;
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