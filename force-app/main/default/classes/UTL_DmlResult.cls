/***
    @ Func Area         : Developer Tool
    @ Author            : Artur Kępczynski 
    @ Date              : 03.2017
    @ Test File         : 
    @ Specification     : Provide logic to execute simple DML operations
***/
public without sharing class UTL_DmlResult {

	public static GenericResult[] insertRecords(Sobject[] records){
		return insertRecords(records, false, true);
	}

	public static GenericResult[] insertRecords(Sobject[] records, Boolean allOrNone){
		return insertRecords(records, allOrNone, true);
	}

	public static GenericResult[] insertRecords(Sobject[] records, Boolean allOrNone, Boolean addErrors){
		Database.SaveResult[] sResults = Database.insert(records, allOrNone);
		GenericResult[] genericResults = convert(sResults, records);
		processResults(records, genericResults, addErrors);
		return genericResults;
	}

	public static GenericResult[] updateRecords(Sobject[] records){
		return updateRecords(records, false, true);
	}

	public static GenericResult[] updateRecords(Sobject[] records, Boolean allOrNone){
		return updateRecords(records, allOrNone, true);
	}

	public static GenericResult[] updateRecords(Sobject[] records, Boolean allOrNone, Boolean addErrors){
		Database.SaveResult[] sResults = Database.update(records, allOrNone);
		GenericResult[] genericResults = convert(sResults, records);
		processResults(records, genericResults, addErrors);
		return genericResults;
	}

	public static GenericResult[] deleteRecords(Sobject[] records){
		return deleteRecords(records, false, true);
	}

	public static GenericResult[] deleteRecords(Sobject[] records, Boolean allOrNone){
		return deleteRecords(records, allOrNone, true);
	}

	public static GenericResult[] deleteRecords(Sobject[] records, Boolean allOrNone, Boolean addErrors){
		Database.DeleteResult[] sResults = Database.delete(records, allOrNone);
		GenericResult[] genericResults = convert(sResults, records);
		processResults(records, genericResults, addErrors);
		return genericResults;
	}

	private static GenericResult[] convert(Object[] results, Sobject[] records){
		GenericResult[] genericResult = new GenericResult[]{};

		for (integer i = 0; i < results.size(); i++) {
			genericResult.add(new GenericResult(results[i], records[i]));
		}

		return genericResult;
	}

	public static void processResults(Sobject[] records, GenericResult[] sResults, Boolean addErrors){

		for (integer i = 0; i < sResults.size(); i++) {
			GenericResult sr = sResults[i];

			if (!sr.isSuccess()) {
				String errorMessage = '';
				for(Database.Error err : sr.getErrors()) {
					errorMessage += err.getMessage();
				}
				if(addErrors && Trigger.isExecuting){
					records[i].addError(errorMessage);
				}
			}
		}
	}

	public static GenericResult[] fetchFails(GenericResult[] results){
		GenericResult[] failed = new GenericResult[]{};

		for(GenericResult gr : results){
			if(!gr.isSuccess()){
				failed.add(gr);
			}
		}

		return failed;
	}

	/***
	    @ Func Area         : Developer Tool
	    @ Author            : Artur Kępczynski 
	    @ Date              : 03.2017
	    @ Test File         : 
	    @ Specification     : Allow use same logic for different Database result classes
	***/
	public class GenericResult {

		private final Id recordId;
		private Sobject record;
		private final Database.Error[] errors;
		private final Boolean isSuccess;

		private GenericResult(Id recordId, Sobject record, List<Database.Error> errors, Boolean isSuccess){
			this.recordId 	= recordId;
			this.errors 	= (errors != null) ? errors : new List<Database.Error>();
			this.isSuccess 	= isSuccess;
			this.record 	= record;

			if(recordId == null && record != null && record.Id != null){
				this.recordId = record.Id;
			}
		}
		public GenericResult(Database.SaveResult result, Sobject record){
			this(result.getId(), record, result.getErrors(), result.isSuccess());
		}
		public GenericResult(Database.UpsertResult result, Sobject record){
			this(result.getId(), record, result.getErrors(), result.isSuccess());
		}
		public GenericResult(Database.DeleteResult result, Sobject record){
			this(result.getId(), record, result.getErrors(), result.isSuccess());
		}
		public GenericResult(Database.UndeleteResult result, Sobject record){
			this(result.getId(), record, result.getErrors(), result.isSuccess());
		}

		public GenericResult(Object obj, Sobject record){
			if(obj instanceOf Database.SaveResult){
				this((Database.SaveResult) obj, record);
			}
			else if(obj instanceOf Database.UpsertResult){
				this((Database.UpsertResult) obj, record);
			}
			else if(obj instanceOf Database.DeleteResult){
				this((Database.DeleteResult) obj, record);
			}
			else if(obj instanceOf Database.UndeleteResult){
				this((Database.UndeleteResult) obj, record);
			}
		}

		public Id getId() {
			return recordId;
		}

		public List<Database.Error> getErrors() {
			return errors;
		}

		public String getErrorMessage() {
			String errorMessage = '';

			for(Database.Error err : errors){
				errorMessage += err.getMessage();
			}

			return errorMessage;
		}



		public Boolean isSuccess() {
			return isSuccess;
		}

		public Sobject getRecord(){
			return record;
		}

		public void addError(){
			String[] errorMessages = new String[]{};
			for(Database.Error error : errors){
				errorMessages.add(error.getMessage());
			}
			addError(errorMessages);
		}

		public void addError(String[] errorMessages){
			for(String error : errorMessages){
				record.addError(error);
			}
		}
	}

	public class UTL_DmlResultException extends Exception {}
}