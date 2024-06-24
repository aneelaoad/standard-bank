public class WRP_User extends WRP_SObject{

    public WRP_User(User record) {
        super(record);
    }

    public User getRecord(){
        return (User)record;
    }

    public Boolean isCommB(){
        return  (getRecord().Profile.Name == DCN_Profile.COMMB_STD)||
                (getRecord().Profile.Name == DCN_Profile.COMMB_STD_MOBILE)||
                (getRecord().Profile.Name == DCN_Profile.COMMB_COMMUNITIES);
    }
}