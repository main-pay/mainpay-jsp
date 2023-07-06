<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page trimDirectiveWhitespaces="true" %> <%--json response 공백제거 --%> 
<%@ page import="java.util.*, com.mainpay.sdk.security.*,com.mainpay.sdk.net.*,com.mainpay.sdk.utils.*" %>
<%
	
	/*=================================================================================================
 	* 라이브러리 설치     
 	================================================================================================= 
	 매뉴얼을 참조하여 샘플코드에 포함된 SDK(jar파일)를 classpath에 위치 시킨다. 
	 필요한 클래스를 import 한다
	*/

    /*=================================================================================================
     * READY API 호출  (결제창 호출 전처리)    
     =================================================================================================                     
     - API 호출 URL 
     - ## 테스트 완료후 real 서비스용 URL로 변경  ## 
     - 리얼-URL : https://api-std.mainpay.co.kr 
     - 개발-URL : https://test-api-std.mainpay.co.kr     
     */
     String API_BASE = "https://test-api-std.mainpay.co.kr";  
     
	/*
	  API KEY (비밀키)  
	 - 생성 : http://cp.mainpay.co.kr 고객지원>기술지원>암호화키관리
	 - 가맹점번호(mbrNo) 생성시 함께 만들어지는 key (테스트 완료후 real 서비스용 발급필요) */
	String apiKey = "U1FVQVJFLTEwMDAxMTIwMTgwNDA2MDkyNTMyMTA1MjM0"; //테스트용 

	/* Request 파라미터 map 생성 */ 
	Map<String, String> parameters = new HashMap<String, String>();
	
	/*=================================================================================================
	 *	필수 파라미터 
	 *=================================================================================================*/
	/* 가맹점 아이디(테스트 완료후 real 서비스용 발급필요)*/
	String mbrNo = "100011"; // 테스트용
	parameters.put("version", "v1");
	parameters.put("mbrNo", mbrNo);
	/* 가맹점 유니크 주문번호 (가맹점 고유ID 대체가능) 6byte~20byte*/
	parameters.put("mbrRefNo", "P000000011");    		 	
	parameters.put("paymethod", request.getParameter("paymethod")); 
	/* 결제금액 (공급가+부가세)
	(#주의#) 페이지에서 전달 받은 값을 그대로 사용할 경우 금액위변조 시도가 가능합니다.
	 DB에서 조회한 값을 사용 바랍니다. */
	String amount = "1004";
	parameters.put("amount", amount);
	/* 상품명 max 30byte*/
	parameters.put("goodsName", request.getParameter("goodsName")); 
	/* 상품코드 max 8byte*/
	parameters.put("goodsCode", request.getParameter("goodsCode"));
	/*인증완료 시 호출 URL, PG->가맹점*/
	parameters.put("approvalUrl", "https://상점도메인/mobile/_3_approval.jsp"); 
	/*결제창 close시 호출 URL, PG->가맹점*/
	parameters.put("closeUrl", "https://상점도메인/mobile/_3_close.jsp"); 
	
	/*고객명  max 30byte*/
	parameters.put("customerName", "고객명");
	parameters.put("customerEmail", "sample@abc.com");
		
	/*가맹점 전용 데이터, approval호출 시 리턴  max 500byte*/
	parameters.put("merchantData", new String(Base64.getEncoder().encode("가맹점 데이터".getBytes())));
	
	/* timestamp
	  Java 버전은 생략(라이브러리에서 자동 생성됨)
	*/		
	/* signature
		Java 버전은 생략(라이브러리에서 자동 생성됨)
	*/

	/*=================================================================================================
	 *	옵션 파라미터 
	 *=================================================================================================*/
	
	/*사용카능 카드사 (JSON Array Type) 매뉴얼 참조*/
	//List<String> cardList = Arrays.asList("04"); 
	//String availableCards = ParseUtils.toJson(cardList); 
	//parameters.put("availableCards", availableCards);		
	
    /*=================================================================================================
     *	READY API 호출 (**테스트 후 반드시 리얼-URL로 변경해야 합니다.**) 
     *=================================================================================================*/
    /*contentType은 json으로 지정 필요*/
    response.setContentType("application/json");
	String responseJson = "";        
	
	/* READY API 호출   */
	String readyUrl = API_BASE + "/v1/payment/ready"; // 테스트용
	responseJson = HttpSendTemplate.post(readyUrl, parameters, apiKey);	
    		 
	System.out.println("responseJson:"+responseJson);
			
	Map responseMap = ParseUtils.fromJson(responseJson, Map.class);        
	String resultCode = (String) responseMap.get("resultCode");        
	String resultMessage = (String) responseMap.get("resultMessage");

	if( ! "200".equals(resultCode)) { //READY API 호출 실패
		String errMessage = String.format("READY API 호출결과 : resultCode: %s, resultMessge: %s", resultCode, resultMessage);
		System.err.println(errMessage);
		out.println(responseJson); 
		return;
	}
	
	Map dataMap = (Map)responseMap.get("data");
	String nextUrl = (String) dataMap.get("nextMobileUrl");
	String aid = (String) dataMap.get("aid");     
	
	/*=================================================================================================
     *	요청정보 DB에 저장 (parameters, apiKey, aid, API_BASE, amount 등)
     *	브라우저 cross-domain session, cookie 정책 강화로 session 사용 지양
     *=================================================================================================*/    
	

	// JSON TYPE RESPONSE
	
	out.println(responseJson);
%>    
