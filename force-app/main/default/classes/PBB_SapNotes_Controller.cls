/***
    @ Func Area     	:  PBB Lifestyle
    @ Author        	:  Mykhailo Reznyk
    @ Date          	:  10.02.2020
    @ User Story    	:  US-4570, US-4572
    @ Description 	    :  APEX Controller for PBB_SapNotes component.
***/
public class PBB_SapNotes_Controller {
	private static final PBB_SRV_GatewayAPI_GetNotes.IService notesService = PBB_SRV_GatewayAPI_GetNotes.newInstance();
	private static final SRV_Logger.IService LOGGER = SRV_Logger.newInstance();

/***
    @ param  	    :  Id accountId, Integer pageNumber, Integer pageSize, List<String> selectedCategories
    @ return   	    :  PBB_SRV_GatewayAPI_GetNotes.Response response
    @ Description 	:  Invokes PBB_SRV_GatewayAPI_GetNotes getNotes(accountId, pageNumber, pageSize, selectedCategories) method which makes an API GET callout to retrieve notes with provided parameters and returns PBB_SRV_GatewayAPI_GetNotes.Response object, which is modified by  GMTtoLocalTime() and mapEmpNumberToName() methods before being returned.
***/
	@AuraEnabled
	public static PBB_SRV_GatewayAPI_GetNotes.Response getNotes(Id accId, Integer pageNumber, Integer pageSize, List<String> selectedCategories) {
		try {

			return mapEmpNumberToName(GMTtoLocalTime(notesService.getNotes(accId, pageNumber, pageSize, selectedCategories)));
		}
		catch(Exception e) {
			LOGGER.log(e, PBB_SapNotes_Controller.class.getName(), DMN_Log.AREA_PBB_GATEWAY);
			throw e;
		}
	}

/***
    @ param  	    :  Id accountId, String body, String category
    @ return   	    :  Integer Response's StatusCode
    @ Description 	:  Invokes PBB_SRV_GatewayAPI_GetNotes createNote(accountId, body, category) method which makes an API POST callout to create a new note and returns Response's StatusCode.
***/
	@AuraEnabled
	public static Integer createNewNote(Id recordId, String body, String category) {
		try {
			return notesService.createNote(recordId, body, category);
		} catch (Exception e) {
			LOGGER.log(e, PBB_SapNotes_Controller.class.getName(), DMN_Log.AREA_PBB_GATEWAY);
			throw e;
		}

	}

/***
    @ param  	    :  No params
    @ return   	    :  List<PBB_Note_Types__c> allNoteTypes
    @ Description 	:  Returns all values from PBB_Note_Types__c Custom Settings, where Customer Notepad checkbox is set true.
***/
	@AuraEnabled
	public static List<PBB_Note_Types__c> getAllCustomerNotepadCategories() {
		List<PBB_Note_Types__c> allNoteTypes = PBB_Note_Types__c.getAll().values();
		List<PBB_Note_Types__c> customerNotepadCategories = new List<PBB_Note_Types__c>();
		for(PBB_Note_Types__c noteCategory : allNoteTypes){
			if(noteCategory.Customer_Notepad__c == true){
				customerNotepadCategories.add(noteCategory);
			}
		}
		return customerNotepadCategories;
	}

/***
    @ param  	    :  PBB_SRV_GatewayAPI_GetNotes.Response response
    @ return   	    :  PBB_SRV_GatewayAPI_GetNotes.Response response
    @ Description 	:  Modifies PBB_SRV_GatewayAPI_GetNotes.Response object. Converts each note creation DateTime value from GMT time zone to Local Time. If Response is null, returns null.
***/
	public static PBB_SRV_GatewayAPI_GetNotes.Response GMTtoLocalTime(PBB_SRV_GatewayAPI_GetNotes.Response response) {
		if(response == null){
			return null;
		}
		for(Integer i = 0; i < response.notes.size(); i++){
			Datetime timeGMT = Datetime.valueOfGmt(response.notes[i].noteDatedOn.replace('T', ' '));
			Integer offset = UserInfo.getTimeZone().getOffset(timeGMT) / 1000;
			Datetime localTime = timeGMT.addSeconds(offset);
			String[] localDateTimeParts = localTime.formatGmt('yyyy-MM-dd HH:mm:ss').split(' ');
			response.notes[i].noteDate = localDateTimeParts[0];
			response.notes[i].noteTime = localDateTimeParts[1];
		}

		return response;
	}

/***
    @ param  	    :  PBB_SRV_GatewayAPI_GetNotes.Response response
    @ return   	    :  PBB_SRV_GatewayAPI_GetNotes.Response response
    @ Description 	:  Modifies PBB_SRV_GatewayAPI_GetNotes.Response object. Replaces User's EmployeeNumber value with User's Name for each note in note_created_by field, if User with such EmployeeNumber was found. If Response is null, returns null.
***/
	public static PBB_SRV_GatewayAPI_GetNotes.Response mapEmpNumberToName(PBB_SRV_GatewayAPI_GetNotes.Response response) {
		if(response == null){
			return null;
		}
		List<String> empNumbers = new List<String> ();
		for (PBB_SRV_GatewayAPI_GetNotes.SapNote note : response.notes) {
			empNumbers.add(note.noteCreatedBy);
		}
		Map<String, String> empNumberToNameMap = new Map<String, String> ();
		for (User user :[SELECT Id, Name, EmployeeNumber FROM User WHERE EmployeeNumber IN :empNumbers]) {
			empNumberToNameMap.put(user.EmployeeNumber.toUpperCase(), user.Name);
		}
		for (Integer i = 0; i<response.notes.size(); i++) {
			if (empNumberToNameMap.get(response.notes[i].noteCreatedBy) != null) {
				response.notes[i].noteCreatedBy = empNumberToNameMap.get(response.notes[i].noteCreatedBy);
			}
		}
		return response;
	}
}