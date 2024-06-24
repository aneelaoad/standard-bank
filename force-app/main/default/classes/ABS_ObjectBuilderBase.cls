/**
 * Object builder base utility class.
 *
 * @author		Artur Kepczynski (akepczynski@deloittece.com)
 * @date		2017-05-25
 */
public inherited sharing abstract class ABS_ObjectBuilderBase {

	static {
		if (!Test.isRunningTest()) {
			throw new ABS_ObjectBuilderBaseException('Class ABS_ObjectBuilderBase can only be used in tests');
		}
	}
	
	private SObject record;
	protected fflib_SObjectUnitOfWork workUnit;

	private Map<SObjectField, List<ABS_ObjectBuilderBase>> registeredChildren = new Map<SObjectField, List<ABS_ObjectBuilderBase>>();
	private Map<SObjectField, ABS_ObjectBuilderBase> registeredParents = new Map<SObjectField, ABS_ObjectBuilderBase>();
	private Boolean isMocked = false;

	protected ABS_ObjectBuilderBase(Schema.SObjectType objType) {
		record = objType.newSObject();
	}

	protected ABS_ObjectBuilderBase(SObject sObj) {
		this.record = sObj;
	}

	protected ABS_ObjectBuilderBase(Schema.SObjectType objType, fflib_SObjectUnitOfWork workUnit) {
		record = objType.newSObject();
		this.workUnit = workUnit;
		registerStandalone(record);
		setDefaultData();
	}

	protected ABS_ObjectBuilderBase(SObject sObj, fflib_SObjectUnitOfWork workUnit) {
		record = sObj;
		this.workUnit = workUnit;
		registerStandalone(record);
	}

	/**
	 * Override in BLD_ class to set default data (e.g. required fields)
	 * on builder initialization.
	 */
	@SuppressWarnings('PMD.EmptyStatementBlock')
	protected virtual void setDefaultData() {}

	/**
	 * Registers record for update.
	 */
	public void registerDirty(){
		workUnit.registerDirty(this);
	}

	/**
	 * Puts given value to SObject's Field
	 *
	 * @param field Target field
	 * @param value New value
	 *
	 * @return Current instance of builder
	 */
	public ABS_ObjectBuilderBase setField(Schema.SObjectField field, Object value) {
		record.put(field,value);
		return this;
	}

	/**
	 * Verifies if record is already in database
	 *
	 * @return True if record is inserted
	 */
	public Boolean isInserted() {
		return !String.isBlank(record.Id);
	}

	/**
	 * Returns instance of related record
	 *
	 * @return Instance of related record
	 */
	public SObject getRecord() {
		return record;
	}

	/**
	 * Mocks record with all relations and Ids.
	 *
	 * @return Mocked SObject record
	 */
	public SObject mock() {
		if (isMocked) {
			return record;
		}
		mockChildRelations();
		mockParentRelations();
		record.Id = fflib_IDGenerator.generate(record.getSObjectType());
		isMocked = true;
		return record;
	}

	private void mockChildRelations() {
		String sObjectName = record.getSObjectType().getDescribe().getName();
		Type recordsListType = Type.forName('List<' + sObjectName + '>');
		List<SObject> recordsList = ((List<SObject>) recordsListType.newInstance());
		recordsList.add(record);

		for (SObjectField childField : registeredChildren.keySet()) {
			List<ABS_ObjectBuilderBase> childBuilders = registeredChildren.get(childField);
			List<SObject> childRecords = new List<SObject>();
			for (Integer i = 0, j = childBuilders.size(); i < j; i++) {
				ABS_ObjectBuilderBase childBuilder = childBuilders[i];
				childRecords.add(childBuilder.mock());
			}
			recordsList[0] = ((List<SObject>) fflib_ApexMocksUtils.makeRelationship(
				recordsListType,
				recordsList,
				childField,
				new List<List<SObject>> {
					childRecords
				}
			))[0];
		}
		record = recordsList[0];
	}

	private void mockParentRelations() {
		for (SObjectField parentRelationField : registeredParents.keySet()) {
			ABS_ObjectBuilderBase parentBuilder = registeredParents.get(parentRelationField);
			SObject parentRecord = parentBuilder.mock();
			record.put(parentRelationField, parentRecord.Id);
			record.putSObject(parentRelationField.getDescribe().getRelationshipName(), parentRecord);
		}
	}

	/**
	 *  Returns Id of related record
	 *
	 * @return Id of related record
	 */
	public Id getRecordId() {
		return (Id)record.get('Id');
	}

	/**
	 * Fetches latest data for fields populated on related record
	 *
	 * @return Current instance of builder
	 */
	public ABS_ObjectBuilderBase refreshFromDB(){
		refreshFromDB(new Set<String>());
		return this;
	}

	/**
	 * Fetches latest data for all available fields on related record
	 *
	 * @return Current instance of builder
	 */
	public ABS_ObjectBuilderBase refreshFullFromDB(){
		String objectName = String.valueOf(getRecordId().getSobjectType());
		Set<String> allFields = Schema.getGlobalDescribe().get(objectName).getDescribe().fields.getMap().keySet();
		refreshFromDB(allFields);
		return this;
	}

	/**
	 * Fetches latest data for fields populated on related record
	 *
	 * @param additionalFields Adds additional fields to list of currently populated ones
	 *
	 * @return Current instance of builder
	 */
	public ABS_ObjectBuilderBase refreshFromDB(Set<String> additionalFields){ 
		if(isInserted()){
			record = fetchSObject(additionalFields);
		}  
		return this; 
	}

	private SObject fetchSObject(Set<String> additionalFields){
		Set<String> queryFields = new Set<String>(record.getPopulatedFieldsAsMap().keySet());
		queryFields.addAll(additionalFields);
		Set<String> uniqueFields = new Set<String>();
		for(String field : queryFields){
			uniqueFields.add(field.toUpperCase());
		}
		List<String> fields = new List<String>(uniqueFields); 
           
		return Database.query(	'SELECT ' + String.join(fields, ',') + ' FROM ' 
								+ String.valueOf(record.getSObjectType()) + ' WHERE Id =\''
								+ String.valueOf(record.get('Id')) + '\'' );   
	}

	private void registerStandalone(SObject sObj) {
		String sObjectType = sObj.getSObjectType().getDescribe().getName();
		if (sObjectType.length() > 3 && sObjectType.right(3) == '__e') {
			workUnit.registerPublishBeforeTransaction(sObj);
		} else if (record.Id == null) {
			workUnit.registerNew(sObj);
		} else {
			workUnit.registerDirty(sObj);
		}
	}

	/**
	 * Registers given builder as child record for current builder.
	 * Enables relationship mocking as well
	 *
	 * @param childRelationshipField Relationship field from child SObject
	 * @param childObjBuilder Instance of child builder
	 *
	 * @return Current instance of builder
	 */
	public ABS_ObjectBuilderBase addChild(Schema.SObjectField childRelationshipField, ABS_ObjectBuilderBase childObjBuilder) {
		workUnit.registerRelationship(childObjBuilder.getRecord(), childRelationshipField, record);
		if (!registeredChildren.containsKey(childRelationshipField)) {
			registeredChildren.put(childRelationshipField, new List<ABS_ObjectBuilderBase>());
		}
		registeredChildren.get(childRelationshipField).add(childObjBuilder);
		return this;
	}

	/**
	 * Registers given builder as parent for current builder.
	 * Enables relationship mocking as well
	 *
	 * @param relationshipField Relationship field from current SObject
	 * @param parentObjBuilder Instance of parent builder
	 *
	 * @return Current instance of builder
	 */
	public ABS_ObjectBuilderBase setRelation(Schema.SObjectField relationshipField, ABS_ObjectBuilderBase parentObjBuilder) {
		if(!parentObjBuilder.isInserted()) {
			workUnit.registerRelationship(record, relationshipField, parentObjBuilder.getRecord());
		} else {
			setField(relationshipField,parentObjBuilder.getRecord().Id);
		}
		registeredParents.put(relationshipField, parentObjBuilder);
		return this;
	}

	/**
	 * Saves all work registered under current Unit of Work to database
	 *
	 * @return Current instance of builder
	 */
	public virtual ABS_ObjectBuilderBase commitWork() {
		workUnit.commitWork();
		return this;
	}

	/**
	 * Creates new instance of Unit of Work.
	 * See <b>ORG_Application</b> for list of registered SObjects
	 *
	 * @return New Unit of Work
	 */
	public static fflib_SObjectUnitOfWork getNewUnitOfWork() {
		return getNewUnitOfWork(new List<SObjectType>());
	}

	/**
	 * Is used to include additional SObject types, which cannot be added permanently
	 * due to 'Entity is not API accessible' error.
	 *
	 * @param additionalTypes list of SObject types to be added to base list
	 * @return fflib_SObjectUnitOfWork
	 */
	public static fflib_SObjectUnitOfWork getNewUnitOfWork(List<Schema.SObjectType> additionalTypes) {
		List<Schema.SObjectType> registeredTypes = ORG_Application.unitOfWorkRegisteredTypes;
		registeredTypes.addAll(additionalTypes);
		return new fflib_SObjectUnitOfWork(registeredTypes);
	}

	/**
	 * Is used to include Knowledge__kav.SObjectType only, when needed
	 *
	 * @return fflib_SObjectUnitOfWork
	 */
	public static fflib_SObjectUnitOfWork getNewUnitOfWorkWithKnowledge() {
		return getNewUnitOfWork(new List<SObjectType>{Knowledge__kav.SObjectType});
	}

	public class ABS_ObjectBuilderBaseException extends Exception {} 
}