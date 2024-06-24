public class CI_CardMapModel extends CI_CardModel {

    @AuraEnabled public Map <String, String> cardDataMap;
    public CI_CardMapModel()
    {
        cardDataMap = new Map <String, String>();
    }
}