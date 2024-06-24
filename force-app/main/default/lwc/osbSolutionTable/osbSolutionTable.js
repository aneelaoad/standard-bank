import { LightningElement, api } from 'lwc';
import OSB_SolutionAssests from '@salesforce/resourceUrl/OSB_SolutionAssests';

export default class OsbSolutionTable extends LightningElement {
    @api ColumnOneTitle;
    @api ContentColumn_1_Title;
    @api contentColumn_1;
    @api ColumnTwoTitle;
    @api ColumnThreeTitle;
    @api backgroundColor;
    @api NumberOfColumns;
    @api NumberOfRows;
    @api ContentRow_1_Title;
    @api contentRow_1_Column_2 = false;
    @api contentRow_1_Column_3 = false;
    @api contentRow_1_Column_2_view_only = false;
    @api contentRow_1_Column_3_view_only = false;
    @api ContentRow_2_Title;
    @api contentRow_2_Column_2 = false;
    @api contentRow_2_Column_3 = false;
    @api contentRow_2_Column_2_view_only = false;
    @api contentRow_2_Column_3_view_only = false;
    @api ContentRow_3_Title;
    @api contentRow_3_Column_2 = false;
    @api contentRow_3_Column_2_view_only = false;
    @api contentRow_3_Column_3 = false;
    @api contentRow_3_Column_3_view_only = false;
    @api ContentRow_4_Title;
    @api contentRow_4_Column_2 = false;
    @api contentRow_4_Column_2_view_only = false;
    @api contentRow_4_Column_3 = false;
    @api contentRow_4_Column_3_view_only = false;
    @api ContentRow_5_Title;
    @api contentRow_5_Column_2 = false;
    @api contentRow_5_Column_3 = false;
    @api contentRow_5_Column_2_view_only = false;
    @api contentRow_5_Column_3_view_only = false;
    @api ContentRow_6_Title;
    @api contentRow_6_Column_2 = false;
    @api contentRow_6_Column_3 = false;
    @api contentRow_6_Column_2_view_only = false;
    @api contentRow_6_Column_3_view_only = false;
    @api ContentRow_7_Title;
    @api contentRow_7_Column_2 = false;
    @api contentRow_7_Column_3 = false;
    @api contentRow_7_Column_2_view_only = false;
    @api contentRow_7_Column_3_view_only = false;
    @api ContentRow_8_Title;
    @api contentRow_8_Column_2 = false;
    @api contentRow_8_Column_3 = false;
    @api contentRow_8_Column_2_view_only = false;
    @api contentRow_8_Column_3_view_only = false;
    @api ContentRow_9_Title;
    @api contentRow_9_Column_2 = false;
    @api contentRow_9_Column_3 = false;
    @api contentRow_9_Column_2_view_only = false;
    @api contentRow_9_Column_3_view_only = false;
    @api ContentRow_10_Title;
    @api contentRow_10_Column_2 = false;
    @api contentRow_10_Column_3 = false;
    @api contentRow_10_Column_2_view_only = false;
    @api contentRow_10_Column_3_view_only = false;
    @api ContentRow_11_Title;
    @api contentRow_11_Column_2 = false;
    @api contentRow_11_Column_3 = false;
    @api contentRow_11_Column_2_view_only = false;
    @api contentRow_11_Column_3_view_only = false;
    @api ContentRow_12_Title;
    @api contentRow_12_Column_2 = false;
    @api contentRow_12_Column_3 = false;
    @api contentRow_12_Column_2_view_only = false;
    @api contentRow_12_Column_3_view_only = false;
    @api contentRow_1 = false;
    @api contentRow_2 = false;
    @api contentRow_3 = false;
    @api contentRow_4 = false;
    @api contentRow_5 = false;
    @api contentRow_6 = false;
    @api contentRow_7 = false;
    @api contentRow_8 = false;
    @api contentRow_9 = false;
    @api contentRow_10 = false;
    @api contentRow_11 = false;
    @api contentRow_12 = false;

    emtTick = OSB_SolutionAssests + '/emtTick.png';
    ShowOneColumn = false;
    ShowTwoColumns = false;
    showThreeColumns = false;
    column_1 = true;
    column_2 = true;
    column_3 = true;

    connectedCallback() {
        if (this.NumberOfRows == 1) {
            this.contentRow_1 = true;
        }
        if (this.NumberOfRows == 2) {
            this.contentRow_1 = true;
            this.contentRow_2 = true;
        }
        if (this.NumberOfRows == 3) {
            this.contentRow_1 = true;
            this.contentRow_2 = true;
            this.contentRow_3 = true;
        }
        if (this.NumberOfRows == 4) {

            this.contentRow_1 = true;
            this.contentRow_2 = true;
            this.contentRow_3 = true;
            this.contentRow_4 = true;
        }
        if (this.NumberOfRows == 5) {
            this.contentRow_1 = true;
            this.contentRow_2 = true;
            this.contentRow_3 = true;
            this.contentRow_4 = true;
            this.contentRow_5 = true;
        }
        if (this.NumberOfRows == 6) {
            this.contentRow_1 = true;
            this.contentRow_2 = true;
            this.contentRow_3 = true;
            this.contentRow_4 = true;
            this.contentRow_5 = true;
            this.contentRow_6 = true;
        }
        if (this.NumberOfRows == 7) {
            this.contentRow_1 = true;
            this.contentRow_2 = true;
            this.contentRow_3 = true;
            this.contentRow_4 = true;
            this.contentRow_5 = true;
            this.contentRow_6 = true;
            this.contentRow_7 = true;
        }
        if (this.NumberOfRows == 8) {
            this.contentRow_1 = true;
            this.contentRow_2 = true;
            this.contentRow_3 = true;
            this.contentRow_4 = true;
            this.contentRow_5 = true;
            this.contentRow_6 = true;
            this.contentRow_7 = true;
            this.contentRow_8 = true;
        }
        if (this.NumberOfRows == 9) {
            this.contentRow_1 = true;
            this.contentRow_2 = true;
            this.contentRow_3 = true;
            this.contentRow_4 = true;
            this.contentRow_5 = true;
            this.contentRow_6 = true;
            this.contentRow_7 = true;
            this.contentRow_8 = true;
            this.contentRow_9 = true;
        }
        if (this.NumberOfRows == 9) {
            this.contentRow_1 = true;
            this.contentRow_2 = true;
            this.contentRow_3 = true;
            this.contentRow_4 = true;
            this.contentRow_5 = true;
            this.contentRow_6 = true;
            this.contentRow_7 = true;
            this.contentRow_8 = true;
            this.contentRow_9 = true;
        }
        if (this.NumberOfRows == 10) {
            this.contentRow_1 = true;
            this.contentRow_2 = true;
            this.contentRow_3 = true;
            this.contentRow_4 = true;
            this.contentRow_5 = true;
            this.contentRow_6 = true;
            this.contentRow_7 = true;
            this.contentRow_8 = true;
            this.contentRow_9 = true;
            this.contentRow_10 = true;
        }
        if (this.NumberOfRows == 11) {
            this.contentRow_1 = true;
            this.contentRow_2 = true;
            this.contentRow_3 = true;
            this.contentRow_4 = true;
            this.contentRow_5 = true;
            this.contentRow_6 = true;
            this.contentRow_7 = true;
            this.contentRow_8 = true;
            this.contentRow_9 = true;
            this.contentRow_10 = true;
            this.contentRow_11 = true;
        }
        if (this.NumberOfRows == 12) {
            this.contentRow_1 = true;
            this.contentRow_2 = true;
            this.contentRow_3 = true;
            this.contentRow_4 = true;
            this.contentRow_5 = true;
            this.contentRow_6 = true;
            this.contentRow_7 = true;
            this.contentRow_8 = true;
            this.contentRow_9 = true;
            this.contentRow_10 = true;
            this.contentRow_11 = true;
            this.contentRow_12 = true;
        }
    }
}