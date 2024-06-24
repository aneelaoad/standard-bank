/**
 * @author Michal Lipinski
 * @description Service class for sending HTTPRequests. Provides retry mechanism that can be used when timeout is exeeded. ORG_Application is used. Can be mocked with fflib_ApexMocks
*/
public class SRV_HttpRequestSender implements IService {
	/**
	 * @description Service interface for sending HTTPRequests. Provides retry mechanism that can be used when timeout is exeeded. 
	 */
	public interface IService {
		/**
		 * @description Sends one HTTPRequest. Can throw Exception
		 * @param request request that needs to be send
		 * @return HttpResonse response
		 */
		HttpResponse send(HttpRequest request);
		/**
		 * @description Sends many HTTPRequests. If exception occured durring the call (timeout etc), request will be resend.
		 * @param request HttpRequest to be send
		 * @param retryOnTimeOut No of retries if exception occured
		 * @return HttpResponse object
		 */
		HttpResponse send(HttpRequest request, Integer retryCounter);
	}
	public static IService newInstance() {
		return(IService) ORG_Application.service.newInstance(IService.class);
	}

	/**
	 * @description Sends one HTTPRequest. Can throw Exception
	 * @param request request that needs to be send
	 * @return HttpResonse response
	 */
	public HttpResponse send(HttpRequest request) {
		return sendRequest(request, 1);

	}
	/**
	 * @description Sends many HTTPRequests. If exception occured durring the call (timeout etc), request will be resend.
	 * @param request HttpRequest to be send
	 * @param retryOnTimeOut No of retries if exception occured
	 * @return HttpResponse object
	 */
	public HttpResponse send(HttpRequest request, Integer retryOnTimeOut) {
		return sendRequest(request, retryOnTimeOut);
	}

	private HttpResponse sendRequest(HttpRequest req, Integer tries) {
		Http httpObj = new Http();
		HttpResponse res;
		while (tries > 0) {
			try {
				res = httpObj.send(req);
				break;
			} catch(System.CalloutException ex) {
				tries--;
			}
		}
		return res;
	}
}