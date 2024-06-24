import { LightningElement, api, track } from 'lwc';

export default class MallGenericTableComponent extends LightningElement {
    @api columns;
    @api set records(records) {
        this.formattedRecords = this.processedRecords(records);
    }

    get records() {
        return this. formattedRecords;
    }

    @api pageSize = 5;
    get renderPagination() {
        return this.formattedRecords.length > this.pageSize;
    }

    @track formattedRecords =[];

    currentPage = 1;

    get displayedData() {
        if(this.formattedRecords) {
            const currentPage = Number(this.currentPage);
            const pageSize = Number(this.pageSize);
            const startIndex = (currentPage - 1) * (pageSize);
            const endIndex = startIndex + pageSize;
            const slicedRecords = this.formattedRecords.slice(startIndex, endIndex);
            return slicedRecords;
        }
    }

    processedRecords(records) {
        if(records && records.length > 0) {
            return records.map((record) => {
                const id = record.Id;
                const columns = this.columns.map((column) => ({
                  name: column.label,
                  value: record[column.fieldName]
                }));
                return { id : id, columns : columns };
              });
        } else {
            return [];
        }
    }

    get totalPages() {
        return Math.ceil(this.formattedRecords.length / this.pageSize);
    }

    handlePaginationChange(event) {
        event.preventDefault();
        event.stopPropagation();
        this.currentPage = event.detail.selectedPage;
    }
}