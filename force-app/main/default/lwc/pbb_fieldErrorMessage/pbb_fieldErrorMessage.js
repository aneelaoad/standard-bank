/**
 * Created by mpszonka on 01.08.2020.
 */

import { LightningElement, api } from 'lwc';

export default class PbbUnableToGetData extends LightningElement {
    @api isEmptyDataError = false;
    @api singleLineText = false;
}