const getUiSettings = () => {

    var navigationConfig = [
        {
            label: "Registration",
            completed : false,
            sequence: 1,
            status : '',
            steps: [
                { 
                    sequence: 1,
                    key: 'registration-submit-application', 
                    label: 'Submit Application', 
                    completed: false,
                    default: false
                },
                { 
                    sequence: 2,
                    key: 'registration-verification-by-standard-bank', 
                    label: 'Verification by Standard Bank', 
                    completed: false,
                    default: false
                }
            ]
        },
        {
            label: "Discovery",
            completed : false,
            sequence: 2,
            status : '',
            steps: [
                { 
                    sequence: 2,
                    key: 'discovery-nda-signed', 
                    label: 'NDA Signed', 
                    completed: false,
                    default: false
                },
                { 
                    sequence: 3,
                    key: 'discovery-business-engagement', 
                    label: 'Business Engagement', 
                    completed: false,
                    default: false
                },
                { 
                    sequence: 4,
                    key: 'discovery-risk-review', 
                    label: 'Risk Review', 
                    completed: false,
                    default: false                    
                }
            ]
        },
        {
            label: "Onboarding",
            completed : false,
            sequence: 3,
            status : '',
            steps: [
                { 
                    sequence: 5,
                    key: 'onboarding-follow-up-risk-questions', 
                    label: 'Follow Up Risk Questions', 
                    completed: false,
                    default: false
                },
                { 
                    sequence: 6,
                    key: 'onboarding-commercials-and-contracting', 
                    label: 'Commercials & Contracting', 
                    completed: false,
                    default: false
                },
                { 
                    sequence: 7,
                    key: 'onboarding-launch', 
                    label: 'Launch', 
                    completed: false,
                    default: false
                }
            ]
        }
    ];
    
    return navigationConfig;
};
export { getUiSettings };