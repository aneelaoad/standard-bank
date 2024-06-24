/**
* @description  : OneHub - Knowledge Tab related component
* User Story : SFP-7228
*
* @author Sharath Chandra (sharath.chintalapati@standardbank.co.za)
* @date October 2021
*/
import LightningDatatable from "lightning/datatable";
import richTextColumnType from "./cbRichTextColType.html";

/**
 * Custom component that extends LightningDatatable
 * and adds a new column type 'richText'
 */
export default class cbCustomDataType extends LightningDatatable {
    static customTypes={
        // custom type definition
        richText: {
            template: richTextColumnType,
            standardCellLayout: true
        }
    }
}