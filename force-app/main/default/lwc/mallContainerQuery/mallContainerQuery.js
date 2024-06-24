import { LightningElement, api } from 'lwc';

export default class ContainerQuery extends LightningElement {


    static checkContainerBreakpoint(componentHost, breakpoint) {
        const mobileBreakpoint = 768;
        let width = componentHost.getBoundingClientRect().width;
        if (width > breakpoint) {
            return "LARGE";
        }
        if(width > mobileBreakpoint) {
            return "MEDIUM";
        }
        return "SMALL";
    }
}