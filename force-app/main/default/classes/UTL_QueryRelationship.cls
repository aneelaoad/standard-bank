public class UTL_QueryRelationship {
	public Set<Id> immediateParents {
		private Set;
		get;
	}
	public SObjectType immediateParentsType {
		private Set;
		get;
	}
	public SObjectType childrenType {
		private Set;
		get;
	}
	private ChildRelationship relImParent2Childs;
	public String[] fieldsOnChild {
		private Set;
		get;
	}


	public UTL_QueryRelationship(Id recordId, String relationToChildren, String pathToIMparrents) {

		if (String.isBlank(pathToIMparrents)) {
			immediateParentsType = recordId.getSobjectType();
			relImParent2Childs = UTL_Schema.getRelationshipByName(immediateParentsType, relationToChildren);
			childrenType = relImParent2Childs.getChildSObject();
			immediateParents = new Set<Id> { recordId };
			return;
		}
		List<String> splitedRelationString = pathToIMparrents.split(',');
		SObjectType currentType = recordId.getSobjectType();
		List<SObjectType> refCurrentType = new List<SObjectType> { currentType };
		RelationContainer container = buildContainer(splitedRelationString, refCurrentType);
		currentType = refCurrentType[0];
		immediateParentsType = currentType;
		relImParent2Childs = UTL_Schema.getRelationshipByName(immediateParentsType, relationToChildren);
		childrenType = relImParent2Childs.getChildSObject();
		Set<Id> recordIds = new Set<Id> { recordId };

		System.debug(buildQueryString(container, recordId));
		List<SObject> allmostIMParents = Database.query(buildQueryString(container, recordId));
		System.debug(container.getMainQueryField());
		immediateParents = fetchIMParentIds(allmostIMParents, container.getMainQueryField());
	}

	public Boolean hasMultipleParents() {
		return immediateParents.size() > 1;
	}

	public SObjectField getLookupFieldOnChild() {
		return relImParent2Childs.getField();
	}

	private static RelationContainer buildContainer(List<String> fieldsOrRelationships, List<SObjectType> currentType) {
		RelationContainer container = new RelationContainer();

		for (Integer i = 0; i<fieldsOrRelationships.size(); i++) {
			ChildRelationship currentRel;
			SObjectField currentField;
			String relation = fieldsOrRelationships[i];
			if ((currentField = currentType[0].getDescribe().fields.getMap().get(relation)) != null) { // field /\
				container.add(currentField);
				if (currentField.getDescribe().isNamePointing()) { throw new UTL_QueryRelationshipException('Unable to solve multitype relation:' + relation); }
				currentType[0] = currentField.getDescribe().getReferenceTo() [0];
			} else if ((currentRel = UTL_Schema.getRelationshipByName(currentType[0], relation)) != null) { //relation \/
				container.add(currentRel);
				currentType[0] = currentRel.getChildSObject();
			} else {
				throw new UTL_QueryRelationshipException('Unable to solve :' + relation);
			}
		}
		System.debug(currentType[0].getDescribe().getName());
		return container;
	}

	private static String buildQueryString(RelationContainer container, Id recordId) {
		if (container.hasDownRelation()) {
			return String.format(
			                     'SELECT {0} FROM {1} WHERE {2} IN ( SELECT {3} FROM {4} WHERE Id in :recordIds )', new List<String> {
				                    container.getMainQueryField(),
				                    container.getMainQueryType(),
				                    container.getMainQuerySelector(),
				                    container.getSubQueryField(),
				                    recordId.getSobjectType().getDescribe().getName()
			                     });
		} else {
			return String.format(
			                     'SELECT {0} FROM {1} WHERE Id in :recordIds ', new List<String> {
				                    container.getMainQueryField(),
				                    recordId.getSobjectType().getDescribe().getName()
			                     });

		}
	}

	private static Set<Id> fetchIMParentIds(List<Sobject> almostIMParents, String pathToId) {
		List<String> splitedPath = pathToId.split('\\.');
		Set<Id> collectedIds = new Set<Id> ();
		for (SObject record : almostIMParents) {
			SObject cur = record;
			for (Integer i = 0; i<splitedPath.size() - 1; i++) {
				cur = cur.getSObject(splitedPath[i]);

			}
			collectedIds.add((Id) cur.get(splitedPath[splitedPath.size() - 1]));
		}
		return collectedIds;
	}

	public List<SObject> getRecords(String fieldSetName, String filters, String parrentFilters) {
		List<String> fieldsToQuery = getFieldApiNames(childrenType, fieldSetName);
		if (fieldsToQuery == null) {
			fieldsToQuery = getFieldsFromString(fieldSetName, ',', childrenType);
		}


		return getRecords(fieldsToQuery, parseFilter(filters), parseParentFilter(parrentFilters));
	}


	public List<SObject> getRecords(String fieldSetName) {
		return getRecords(fieldSetName, '', '');
	}

	private List<SObject> getRecords(List<String> fieldsApiNames, String parsedFilters, String parrentFilters) {
		List<SObject> parentWithChildren = Database.query(
		                                                  String.format('SELECT Id, (SELECT {0} FROM {1} {2} ) FROM {3} WHERE {4} ',
		                                                                new List<String> { String.join(fieldsApiNames, ' , '), relImParent2Childs.getRelationshipName(), parsedFilters, immediateParentsType.getDescribe().getName(), parrentFilters
		                                                                })
		);
		return UTL_Collections.getChildrenFromParents(parentWIthChildren, relImParent2Childs);
	}

	private static String parseFilter(String filters) {
		if (String.isNotBlank(filters)) {
			if (!filters.containsIgnoreCase('WHERE')) {
				return ' WHERE ' + filters;
			}
		}
		return '';
	}

	private static String parseParentFilter(String parentFilters) {
		if (String.isBlank(parentFilters)) {
			return ' Id = :immediateParents ';
		} else return parentFilters;
	}

	private List<String> getFieldsFromString(String fieldString, String separator, SObjectType sObjType) {
		List<String> fieldsApiNames = fieldString.split(separator);
		fieldsOnChild = new List<String> ();
		Set<String> fieldsToReturn = new Set<String> ();
		for (Integer i = 0; i<fieldsApiNames.size(); i++) {
			SObjectField fieldCandidate = sObjType.getDescribe().fields.getMap().get(fieldsApiNames[i]);
			if (fieldCandidate != null) {
				fieldsToReturn.add(fieldsApiNames[i]);
				fieldsOnChild.add(fieldsApiNames[i]);
				if (fieldCandidate.getDescribe().getType() == Schema.DisplayType.Reference) {
					fieldsToReturn.add(fieldsApiNames[i].replace('__c', '__r').replace('Id', '') + '.Name');
				}
			}
		}
		fieldsToReturn.add('Id');
		return new List<String> (fieldsToReturn);
	}

	private List<String> getFieldApiNames(SObjectType sObjType, String fieldSetName) {
		List<String> fieldsToReturn = new List<String> ();
		fieldsOnChild = new List<String> ();
		List<FieldSetMember> fieldSetMembers = UTL_Schema.getFieldSetMembers(sObjType, fieldSetName);
		if (fieldSetMembers == null) { return null; }
		for (FieldSetMember fsm : fieldSetMembers) {
			fieldsOnChild.add(UTL_Schema.getFieldApiName(fsm));
			fieldsToReturn.add(UTL_Schema.getFieldApiName(fsm));
			if (fsm.getType() == Schema.DisplayType.Reference) {
				fieldsToReturn.add(UTL_Schema.getFieldApiName(fsm).replace('__c', '__r').replace('Id', '') + '.Name');
			}
		}
		return fieldsToReturn;

	}


	public class RelationContainer {
		private List<SObjectField> fieldsPreUp;
		private List<ChildRelationship> relDown;
		private List<SObjectField> fieldsPostUp;

		public RelationContainer() {
			fieldsPreUp = new List<SobjectField> ();
			relDown = new List<ChildRelationship> ();
			fieldsPostUp = new List<SobjectField> ();
		}

		public void add(SObjectField field) {
			if (relDown.isEmpty()) {
				fieldsPreUp.add(field);
			} else {
				fieldsPostUp.add(field);
			}
		}
		public void add(ChildRelationship relationship) {
			if (fieldsPostUp.isEmpty()) {
				relDown.add(relationship);
			} else {
				throw new RelationContainerException('Cannot insert relation that is not part of chain of down relations.');
			}
		}
		public String getMainQueryType() {
			if (hasDownRelation()) { return relDown[relDown.size() - 1].getChildSObject().getDescribe().getName(); }
			return null;
		}
		public String getSubQueryField() {
			List<String> fieldPath = new List<String> ();
			for (Integer i = 0; i<fieldsPreUp.size() - 1; i++) {
				fieldPath.add(fieldsPreUp[i].getDescribe().getRelationshipName());
			}
			fieldPath.add(fieldsPreUp[fieldsPreUp.size() - 1].getDescribe().getName());
			return String.join(fieldPath, '.');
		}
		public String getMainQueryField() {
			if (!hasDownRelation()) { return getSubQueryField(); }
			List<String> fieldPath = new List<String> ();
			if (fieldsPostUp.isEmpty()) {
				return 'Id';
			}
			for (Integer i = 0; i<fieldsPostUp.size() - 1; i++) {
				fieldPath.add(fieldsPostUp[i].getDescribe().getRelationshipName());
			}
			fieldPath.add(fieldsPostUp[fieldsPostUp.size() - 1].getDescribe().getName());
			return String.join(fieldPath, '.');
		}
		public String getMainQuerySelector() {
			List<String> fieldPath = new List<String> ();
			for (Integer i = relDown.size() - 2; i >= 0; i--) {
				fieldPath.add(relDown[i].getField().getDescribe().getRelationshipName());
			}
			fieldPath.add(relDown[0].getField().getDescribe().getName());
			return String.join(fieldPath, '.');
		}

		public Boolean hasDownRelation() {
			return !relDown.isEmpty();
		}

	}
	public virtual class UTL_QueryRelationshipException extends Exception { }
	public class RelationContainerException extends UTL_QueryRelationshipException { }
}