const prepareEventPayload = (payload) => { return JSON.stringify(payload); };
const getEventPayload = (event) => { return JSON.parse(event.detail); };
const isInBuilder = () => { return (document.location.hostname.includes('builder.salesforce')); };

export {
  prepareEventPayload,
  getEventPayload,
  isInBuilder
};