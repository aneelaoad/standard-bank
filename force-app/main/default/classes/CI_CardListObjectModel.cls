public class CI_CardListObjectModel extends CI_CardModel {

    @AuraEnabled public List <Object> cardObjectList;
    @AuraEnabled public Object cardObject;
    public CI_CardListObjectModel()
    {   
        cardObjectList = new List <Object>();
    }
}