public class UTL_LookupField_Ctrl  {

	public static final Integer QUERY_LIMIT		= 10;

	private static final Map<String, String> sObjectType2QueriedField = new Map<String, String>{
		'Case' => 'Subject'
		, 'Event' => 'Subject'
	};

    @AuraEnabled(Cacheable = true)
    public static String getIconName(String sObjectName) {
        String iconName;
        List<Schema.DescribeTabSetResult> tabSetDesc = Schema.describeTabs();
        List<Schema.DescribeTabResult> tabDesc = new List<Schema.DescribeTabResult>();
        List<Schema.DescribeIconResult> iconDesc = new List<Schema.DescribeIconResult>();

        for(Schema.DescribeTabSetResult tsr : tabSetDesc) { tabDesc.addAll(tsr.getTabs()); }

        for(Schema.DescribeTabResult tr : tabDesc) {
            if( sObjectName == tr.getSobjectName() ) {
                if( tr.isCustom() == true ) {
                    iconDesc.addAll(tr.getIcons());
                } else {
                    iconName = 'standard:' + sObjectName.toLowerCase();
                }
            }
        }
        for (Schema.DescribeIconResult ir : iconDesc) {
            if (ir.getContentType() == 'image/svg+xml'){
                iconName = 'custom:' + ir.getUrl().substringBetween('custom/','.svg').substringBefore('_');
                break;
            }
        }
        return iconName;
    }

	@AuraEnabled(Cacheable = true)
	public static ResultWrapper getRecord(Id recordId){
		String referencedSObjectName = recordId.getSobjectType().getDescribe().getName();

		String queriedField = getFieldToQuery(referencedSObjectName);
		
		String query ='SELECT Id, ' + queriedField;
		query +=		' FROM ' + referencedSObjectName;
		query +=		' WHERE Id = :recordId';
		
		ResultWrapper chosenRecord = new ResultWrapper(Database.query(query));
		
		return chosenRecord;
	}

	@AuraEnabled(Cacheable=true)
	public static ResultWrapper[] getSuggestedParents(String sObjectName, String fieldName, String name, String whereClause) {
		ResultWrapper[] suggestedParents = new ResultWrapper[]{};
		if (name.length() < 2) {
			return new ResultWrapper[]{};
		}

		Schema.DescribeSobjectResult[] describeSObjectResults = Schema.describeSObjects(new String[]{sObjectName});
		SObjectType[] sObjTypesForSosl = new SObjectType[]{};
		SObjectType[] sObjTypes = describeSObjectResults[0].fields.getMap().get(fieldName).getDescribe().getReferenceTo();
		for (SObjectType sObjType : sObjTypes) {

			Schema.DescribeSObjectResult dsr = sObjType.getDescribe();
			String sObjTypeString = dsr.getName();

			if (!dsr.isAccessible()
					|| !dsr.fields.getMap().containsKey(getFieldToQuery(sObjTypeString))) {
				continue;
			}
			if (sObjTypes.size() > 1) {
				if (!dsr.isSearchable()) {
					continue;
				}
			}

			sObjTypesForSosl.add(sObjType);
		}

		
		if (sObjTypes.size() == 1) {
			suggestedParents = getBySoql(sObjTypes[0], name, whereClause);
		}
		else if (sObjTypes.size() > 1) {
			suggestedParents = getBySosl(sObjTypesForSosl, name);
		}

		return suggestedParents;

	}

	private static ResultWrapper[] getBySoql(SObjectType sObjType, String name, String whereClause) {
		ResultWrapper[] suggestedParents = new ResultWrapper[]{};

		name = String.escapeSingleQuotes(name);
		name += '%';
		
		Schema.DescribeSObjectResult sObjDescribe = sObjType.getDescribe();
		
		String referencedSObjectName =  sObjDescribe.getName();

		String queriedField = getFieldToQuery(referencedSObjectName);

		if (!sObjDescribe.fields.getMap().containsKey(queriedField)) {
			System.debug('No such field: ' + queriedField + ' on SObject ' + referencedSObjectName);
			return suggestedParents;
		}


		String query =	'SELECT Id, ' + queriedField;
		query +=		' FROM ' + referencedSObjectName;
		query +=		' WHERE ' + queriedField + ' LIKE :name';
		if (String.isNotBlank(whereClause)) {
			query +=	' AND (' + whereClause +')';
		}
		query +=		' ORDER BY ' + queriedField + ' ASC';
		query +=		' LIMIT ' + QUERY_LIMIT;

		for (SObject sObj : Database.query(query)) {
			suggestedParents.add(new ResultWrapper(sObj));
		}
		
		return suggestedParents;
	}

	private static ResultWrapper[] getBySosl(SObjectType[] sObjTypes, String name) {
		ResultWrapper[] suggestedParents = new ResultWrapper[]{};

		name = String.escapeSingleQuotes(name);
		name += '*';

		String returningClause = '';
		for (SObjectType sObjType : sObjTypes) {
			Schema.DescribeSobjectResult dsr = sObjType.getDescribe();
			returningClause 	+= sObjType + '(Id,' + getFieldToQuery(dsr.getName());
			if (dsr.fields.getMap().containsKey('LastViewedDate')) {
				returningClause	+= + ' ORDER BY LastViewedDate DESC NULLS LAST';
			}
			returningClause		+= '),';
		}
		returningClause = returningClause.removeEnd(',');

		String searchQuery 	= 'FIND :name'
							+ ' IN ALL FIELDS'
							+ ' RETURNING ' + returningClause;
		List<List<SObject>> searchList = search.query(searchQuery);

		for (List<SObject> sObjs : searchList) {
			for (SObject sObj : sObjs) {
				suggestedParents.add(new ResultWrapper(sObj, true));
			}
		}

		return suggestedParents;
	}

	private static String getFieldToQuery(String referencedSObjectName) {

		String queriedField = 'Name';
		if (sObjectType2QueriedField.containsKey(referencedSObjectName)) {
			queriedField = sObjectType2QueriedField.get(referencedSObjectName);
		}

		return queriedField;

	}

	public class ResultWrapper {

		@AuraEnabled public Id recordId;
		@AuraEnabled public String queriedField;
		@AuraEnabled public String sObjectType;
        @AuraEnabled public String iconName;

		public ResultWrapper(SObject sObj) {
			this(sObj, false);
			//this = new UTL_LookupField_Ctrl.ResultWrapper(sObj, false);
		}

		public ResultWrapper(SObject sObj, Boolean addSObjectType) {
			this.recordId = sObj.Id;

			String referencedSObjectName = String.valueOf(sObj.getSObjectType());
			this.queriedField = String.valueOf(sObj.get(getFieldToQuery(referencedSObjectName)));

			if (addSObjectType) {
				this.sObjectType = String.valueOf(sObj.getSObjectType());
			}
            this.iconName = getIconName(referencedSObjectName);
		}

	}
}