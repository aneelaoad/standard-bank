public class CI_CardListModel extends CI_CardModel {

    @AuraEnabled public List <CI_CardMapModel> cardDataList;
    public CI_CardListModel()
    {
        cardDataList = new List <CI_CardMapModel>();
    }
}