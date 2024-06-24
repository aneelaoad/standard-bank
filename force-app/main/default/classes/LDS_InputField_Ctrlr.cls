public with sharing class LDS_InputField_Ctrlr {
    public SObject inputObject { get; set; }
    public String fieldName { get; set; }
    public Boolean layoutRequired { get; set; }
    public Boolean layoutReadOnly { get; set; }


    public Boolean isRequired {
        get {
            return !getFieldDescribe().isNillable() || layoutRequired;
        }
    }

    public Boolean isReadOnly {
        get {
            if (inputObject.id != null) {
                return !getFieldDescribe().isUpdateable() || layoutReadOnly;
            }
            else {
                return !getFieldDescribe().isCreateable() || layoutReadOnly;
            }
        }
    }


    public Boolean isInput {
        get {
            DisplayType dispType = getFieldDescribe().getType();
            return (dispType == Schema.DisplayType.String ||
                dispType == Schema.DisplayType.Currency ||
                dispType == Schema.DisplayType.Email ||
                dispType == Schema.DisplayType.Double ||
                dispType == Schema.DisplayType.Integer ||
                dispType == Schema.DisplayType.Percent ||
                dispType == Schema.DisplayType.URL ||
                dispType == Schema.DisplayType.Phone);
        }
    }

    /**
     * There's an "internal server error" when rendering fields in apex:inputField
     * where Default Value depends on "$RecordType".
     */
    public Boolean renderInputText {
        get {
            return (getFieldDescribe().getDefaultValueFormula() != null &&
                getFieldDescribe().getDefaultValueFormula().contains('$RecordType'));
        }
    }

    public Boolean isTextarea {
        get {
            DisplayType dispType = getFieldDescribe().getType();
            return (dispType == Schema.DisplayType.TextArea);
        }
    }

    public Boolean isPicklist {
        get {
            DisplayType dispType = getFieldDescribe().getType();
            return (dispType == Schema.DisplayType.Picklist);
        }
    }

    public Boolean isDependentPicklist {
        get {
            return getFieldDescribe().isDependentPicklist();
        }
    }


    public Boolean isMultiPicklist {
        get {
            DisplayType dispType = getFieldDescribe().getType();
            return (dispType == Schema.DisplayType.MultiPicklist);
        }
    }

    public Boolean isCheckbox {
        get {
            DisplayType dispType = getFieldDescribe().getType();
            return (dispType == Schema.DisplayType.Boolean);
        }
    }

    public Boolean isDatetime {
        get {
            DisplayType dispType = getFieldDescribe().getType();
            return (dispType == Schema.DisplayType.Date ||
                dispType == Schema.DisplayType.Datetime);
        }
    }

    public String objectName {
        get {
            if (inputObject != null) {
                return inputObject.getSObjectType().getDescribe().getName();
            }
            else {
                return '';
            }
        }
    }

    public Boolean isLookup {
        get {
            DisplayType dispType = getFieldDescribe().getType();
            return (dispType == Schema.DisplayType.reference);
        }
    }

    private SObjectField getSField() {
        if (inputObject != null) {
            return inputObject.getSObjectType().getDescribe().fields.getMap().get(fieldName);
        } else {
            return null;
        }
    }

    private DescribeFieldResult getFieldDescribe() {
        SObjectField sf = getSField();
        if (sf != null) {
            return sf.getDescribe();
        }
        else {
            return null;
        }
    }
}