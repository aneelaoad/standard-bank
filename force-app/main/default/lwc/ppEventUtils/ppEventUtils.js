const trackLink = (event) => {    
    
    document.dispatchEvent(
        new CustomEvent('triggerInteraction', {
            'detail': {
                eventName: 'flexiLinkTracking',
                userInteraction: event.currentTarget.dataset.intent+' | '+event.currentTarget.dataset.text,
                interactionIntent: event.currentTarget.dataset.intent
            }
        })
    );
};

export { trackLink };