import {
    ShowToastEvent
} from 'lightning/platformShowToastEvent'

export function showToast(aError, aType = 'error', aMode = 'sticky') {
    /*Show Error in Toast Event*/
    let errorName = aError.name || aError.statusText;
    let concatTitle = errorName;
    let errorMessage = aError.message;
    let errorStack = aError.stack;
    if (Array.isArray(aError.body)) {
        errorMessage = aError.body.map(e => e.message).join(', ');
    } else if (aError.body && aError.body.message) {
        errorMessage = aError.body.message;
        errorStack = aError.body.stack || aError.body.stackTrace;
    }
    if (errorName && errorMessage) {
        concatTitle = errorName + ': ' + errorMessage;
    }
    this.dispatchEvent(
        new ShowToastEvent({
            title: concatTitle,
            message: errorStack,
            variant: aType,
            mode: aMode
        })
    );
}

export function getErrorMessage(aError, aType = 'error', aMode = 'sticky') {
    /*Show Error in Toast Event*/
    let errorName = 'Error description'
    let concatTitle = errorName;
    let errorMessage = aError.message;
    let errorStack = aError.stack;
    if (Array.isArray(aError.body)) {
        errorMessage = aError.body.map(e => e.message).join(', ');
    } else if (aError.body && aError.body.message) {
        errorMessage = aError.body.message;
        errorStack = aError.body.stack || aError.body.stackTrace;
    }
    if (errorName && errorMessage) {
        concatTitle = errorName + ': ' + errorMessage;
    }
    return concatTitle;
}

export function numFrenchFormatting(text) {
    if (typeof text === 'string') {
        if (!isNaN(text)) {
            text = Number(text);
        }
    }
    text = text.toLocaleString('fr-CA', {
        minimumFractionDigits: 2,
        maximumFractionDigits: 2
    });
    return text;
}

export function format(stringToFormat, ...formattingArguments) {
    if (typeof stringToFormat !== 'string') throw new Error('\'stringToFormat\' must be a String');
    return stringToFormat.replace(/{(\d+)}/gm, (match, index) =>
        (formattingArguments[index] === undefined ? '' : `${formattingArguments[index]}`));
}