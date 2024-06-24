public with sharing class NGeniusInvoice {

    public NGeniusInvoice(){
        String transactionType = 'AUTH'; //AUTH
        List<Invoice_Item> items = new List<Invoice_Item>(); //list of item from invoice
        Invoice_totalPrice total = new Invoice_totalPrice();
    }

    public String firstName; //Customer first name
    public String lastName; //Customer last name
    public String email; //Customer email
    public String transactionType = 'AUTH';
    public String emailSubject;
    public String invoiceExpiryDate; //expiration date of link
    public List<Invoice_Item> items = new List<Invoice_Item>(); //list of items
    public Invoice_totalPrice total = new Invoice_totalPrice();
    public String message;	//message for customer

    public class Invoice_Item {
        public String description; //Item description
        public Item_totalPrice totalPrice = new Item_totalPrice(); //Item total price
        public Integer quantity; //Item quantity
    }
    public class Item_totalPrice {
        public String currencyCode; //Item currency code example : NAD
        public Integer value; //Item total Price
    }
    public class Invoice_totalPrice {
        public String currencyCode;	//Invoice currency NAD
        public Integer value; //Total invoice value
    }
}