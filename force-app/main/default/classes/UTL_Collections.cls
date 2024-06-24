public without sharing class UTL_Collections {   	
	public static SObject[] getSobjectList(Map<Id, SObject[]> dataSource){
		return joinLists(dataSource.values(), true);
	}

	public static SObject[] getSobjectList(Map<SobjectType, SObject[]> dataSource){
		return joinLists(dataSource.values(), true);
	}

	public static Sobject[] joinLists(List<Sobject[]> recordLists, Boolean isSkipNull){
		SObject[] records = new SObject[]{};
		for(Sobject[] recList : recordLists){
			for(Sobject rec : recList){
				if(rec != null || !isSkipNull){
					records.add(rec);
				}
			}
		}
		return records; 
	}

	public static void addToMap(Map<Id, Sobject[]> dataMap, Id parentId, Sobject[] data){
		if(!dataMap.containsKey(parentId)){
			dataMap.put(parentId, new Sobject[]{});
		}

		Set<Id> recordIds = new Set<Id>();

		for(Sobject sObj : dataMap.get(parentId)){
			Id recId = (Id)sObj.get('Id');
			if(recId != null){
				recordIds.add(recId);
			}
		}

		for(Sobject sObj : data){
			Id recId = (Id)sObj.get('Id');
			if(!recordIds.contains(recId)){
				dataMap.get(parentId).add(sObj);
			}
		}
	} 

	public static Map<Id, Sobject> builMap(SObject[] recods, Schema.SobjectField field){
		return builMap(recods, field, true, true);
	}

	public static Map<Id, Sobject> builMap(SObject[] recods, Schema.SobjectField field, Boolean isSkipNull, Boolean isAllowDuplicates){
		Map<Id, SObject> key2Sobject = new Map<Id, SObject>();
		for(Sobject rec : recods){
			Id key = (Id)rec.get(field);

			if(isSkipNull && key == null){
				continue;
			}

			if(!key2Sobject.containsKey(key)){
				key2Sobject.put(key, rec);
			}
			else if(!isAllowDuplicates){ 
				throw new UTL_CollectionsException('Key \'' + field + '\' is not unique for collection of records');
			}
		}
		return key2Sobject;
	}

	public static Map<Id, Sobject[]> builListMap(SObject[] recods, Schema.SobjectField field){
		return builListMap(recods, field, true);
	}

	public static Map<Id, Sobject[]> builListMap(SObject[] recods, Schema.SobjectField field, Boolean isSkipNull){
		Map<Id, SObject[]> key2Sobject = new Map<Id, SObject[]>();
		for(Sobject rec : recods){
			Id key = (Id)rec.get(field);

			if(isSkipNull && key == null){
				continue;
			}

			if(!key2Sobject.containsKey(key)){
				key2Sobject.put(key, new Sobject[]{});
			}
			key2Sobject.get(key).add(rec);
		}
		return key2Sobject;
	}

	public static Map<String, Sobject> buildMap(SObject[] recods, Schema.SobjectField[] fields){
		return buildMap(recods, fields, true, true);
	} 

	public static Map<String, Sobject> buildMap(SObject[] recods, Schema.SobjectField[] fields, Boolean isSkipNull, Boolean isAllowDuplicates){
		Map<String, SObject> key2Sobject = new Map<String, SObject>();

		for(Sobject rec : recods){
			String[] keys = new String[]{};

			for(Schema.SobjectField field : fields){
				String val = (String)rec.get(field);
				if(isSkipNull && val == null){
					continue;
				}
				keys.add((String)val);
			}

			String key = concatenate(keys);

			if(isSkipNull && (key == null || String.isBlank(key))){
				continue;
			}

			if(!key2Sobject.containsKey(key)){
				key2Sobject.put(key, rec);
			}
			else if(!isAllowDuplicates){ 
				throw new UTL_CollectionsException('Key \'' + key + '\' is not unique for collection of records');
			}
		}
		return key2Sobject;
	}

	public static String concatenate(String[] values){
		return concatenate(values, ';');
	}

	public static String concatenate(String[] values, String concatenator){
		return String.join(values, concatenator);
	}

	public static String generateCode(String[] values){
		String result = String.join(values, '_');
		return result.replace(' ', '_').toUpperCase();

	}

	public static List<SObject> getChildrenFromParents(List<SObject> parentRecords, ChildRelationship reletionToChildren){
	  List<SObject> joined = new List<SObject> ();
	  for (SObject record : parentRecords) {
		  SObject[] children = record.getSObjects(reletionToChildren.getRelationshipName());
		  if (children != null) { joined.addAll(children); }
	  }
	  return joined;
	}
	
	public static Id[] getIdList(SObject[] records, SObjectField field, Set<Schema.SObjectType> types){
		Id[] recIds = new Id[]{};
		Object[] values = getValuesList(records, field);
		for(Integer i = 0, j = values.size(); i < j; i++){
			if(types != null && !types.contains(((Id)values[i]).getSobjectType())){
				continue;
			}
			recIds.add((Id)values[i]);
		}
		 
		return recIds;
	}
	
	public static Object[] getValuesList(SObject[] records, SObjectField field){
		Object[] data = new Object[]{};
		
		for(Integer i = 0, j = records.size(); i < j; i++){
			data.add(records[i].get(field));
		}
		
		return data;
	}

	public class UTL_CollectionsException extends Exception {}
}