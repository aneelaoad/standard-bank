public class CI_ResponseDto {
        @AuraEnabled public Boolean IsSuccess { get; set; }
        @AuraEnabled public String Message { get; set; }
        @AuraEnabled public Object Data { get; set; }
         
        public CI_ResponseDto(Boolean isSuccess, String msg){
            this.IsSuccess = isSuccess;
            this.Message = msg;
            this.Data = null;
        }

        public CI_ResponseDto(Object data){
            this.IsSuccess = true;
            this.Message = null;
            this.Data = data;
        }
}