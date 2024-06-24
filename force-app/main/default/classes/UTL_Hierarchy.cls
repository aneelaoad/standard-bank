/**
* ─────────────────────────────────────────────────────────────────────────────────────────────────┐
*
* Generic hierarchy class that given an array of sobjects and an identifying hierarchy field
* builds an in memory representation of the hierarchy
*
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @author         Unknown author
* @version        1.0
* @created        in the beginning
* @systemLayer    Utility ( Choose from: Invocation | Service | Utility | Selector | Domain | Test )
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @changes
* v1.1            Caro Reinecke
* 2018-01-08      Digitization Client Onboarding - Account Opening US-2668 - Added method getImmediateChildRecords.
*
* ─────────────────────────────────────────────────────────────────────────────────────────────────┘
*/
public without sharing class UTL_Hierarchy {
	

	public class Hierarchy{

		private String parentField;
		private Map<Id, Sobject> id2Record;
		private Map<String, Sobject[]> parentId2Children;
		private Set<Id> topLvl;

		public Hierarchy(Sobject[] records){
			this(records, null);
		}

		public Hierarchy(Sobject[] records, String parentField){
			topLvl 		= new Set<Id>();
			parentId2Children 	= new Map<String, Sobject[]>();
			id2Record 			= new Map<Id, Sobject>();
			this.parentField 	= parentField;
			add(records);
		}

		public void add(Sobject[] records){
			for(Sobject rec : records){
				id2Record.put(rec.Id, rec);
				parentId2Children.put(rec.Id, new Sobject[]{});
			}

			if(parentField == null){
				topLvl = id2Record.keySet();
				return;
			}

			for(Sobject rec : records){

				Id parentId = (Id)rec.get(parentField);

				if(parentId != null
					&& parentId2Children.containsKey(parentId)){
					parentId2Children.get(parentId).add(rec);
				}
			}

			topLvl 		= new Set<Id>();

			for(Sobject rec : id2Record.values()){

				Id parentId = (Id)rec.get(parentField);
				if(parentId == null 
					|| !parentId2Children.containsKey(parentId)){
					topLvl.add(rec.Id);
				}
			}
		}

		public Sobject get(Id recordId){
			return id2Record.get(recordId);
		}

		public Sobject[] getTopRecord(){

			Sobject[] parents = new Sobject[]{};

			for(Id recId : topLvl){
				parents.add(id2Record.get(recId));
			}

			return parents;
		}

		public Sobject[] getChildRecords(Id recordId){
			Sobject[] children = new Sobject[]{};
			if(parentId2Children.containsKey(recordId)){
				children.addAll(parentId2Children.get(recordId));
				for(Sobject rec : parentId2Children.get(recordId)){
					children.addAll(getChildRecords(rec.Id)); 
				}
			}
			return children;
		}

		public Sobject[] getImmediateChildRecords(Id recordId){
			Sobject[] children = new Sobject[]{};
			if(parentId2Children.containsKey(recordId)){
				children.addAll(parentId2Children.get(recordId));
			}
			return children;
		}

		public Sobject[] getHierarchy(Id recordId){
			Sobject record = get(recordId);
			Sobject[] childRecords = getChildRecords(recordId);
			Sobject[] records = new Sobject[]{};

			if(record != null){
				records.add(record);
			}
			if(childRecords != null){
				records.addAll(childRecords);
			}
			
			return records;
		}

		public Sobject[] getParentPath(Id recordId){
			Sobject record = id2Record.get(recordId);
			Sobject[] parents = new Sobject[]{record};

			
			if(parentField == null){	
				return parents;		
			}

			while(record != null){
				System.debug('record 1 ' + record);

				Id parentId = (Id)record.get(parentField);
				record = id2Record.get(parentId);
				System.debug('parentId ' + parentId);
				System.debug('record 2 ' + record);
				if(record != null){
					parents.add(record);
				}
				System.debug('parents ' + parents.size());
			}
		
			return parents;
		}
	}
}