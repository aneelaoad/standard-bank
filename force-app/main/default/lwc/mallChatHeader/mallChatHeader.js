import BaseChatHeader from 'lightningsnapin/baseChatHeader';
import mallChatStyles from "@salesforce/resourceUrl/MallChatStyles";

export default class MallChatHeader extends BaseChatHeader {

    text;
    minimizeIcon = mallChatStyles +  '/minimizeIcon.svg';
    crossIcon = mallChatStyles +  '/crossIcon.svg';

    connectedCallback() {
        
        this.assignHandler("prechatState", (data) => {
            this.setText(data.label);
        });
        this.assignHandler("offlineSupportState", (data) => {
            this.setText(data.label);
        });
        this.assignHandler("waitingState", (data) => {
            this.setText(data.label);
        });
        this.assignHandler("waitingEndedState", (data) => {
            this.setText(data.label);
        });
        this.assignHandler("chatState", (data) => {
            this.setText(data.label);
        });
        this.assignHandler("chatTimeoutUpdate", (data) => {
            this.setText("You will time out soon.");
        });
        this.assignHandler("chatTimeoutClear", (data) => {
            this.setText(data.label);
        });
        this.assignHandler("chatEndedState", (data) => {
            this.setText(data.label);
        });
        this.assignHandler("reconnectingState", (data) => {
            this.setText(data.label);
        });
        this.assignHandler("postchatState", (data) => {
            this.setText(data.label);
        });
        this.assignHandler("chatConferenceState", (data) => {
            this.setText(data.label);
        });
    }

    setText(str) {
        if (typeof str !== "string") {
            throw new Error("Expected text value to be a `String` but received: " + str + ".");
        }
        this.text = str;
    }
}