<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.*, com.mainpay.sdk.security.*,com.mainpay.sdk.net.*,com.mainpay.sdk.utils.*" %>
<%
	/*
     CANCEL API를 호출하는 페이지 입니다. (가맹점 인증, 파라미터 전달)     
     <사전작업>
	 1. 첨부된 jar 파일을 classpath에 위치 시켜, 필요한 클래스를 import 한다
	*/

    /*=================================================================================================
     * CANCEL API 호출  
     ================================================================================================= */ 
     
	/*
	  API KEY (비밀키)  
	 - 생성 : http://biz.mainpay.co.kr 고객지원>기술지원>암호화키관리
	 - 가맹점번호(mbrNo) 생성시 함께 만들어지는 key (테스트 완료후 real 서비스용 발급필요) */
	String apiKey = "U1FVQVJFLTEwMDAxMTIwMTgwNDA2MDkyNTMyMTA1MjM0"; // <===테스트 API_KEY입니다.

	/* Request 파라미터 map 생성 */ 
	Map<String, String> parameters = new HashMap<String, String>();
	
	/*=================================================================================================
	 *	필수 파라미터 
	 *=================================================================================================*/
	/* 가맹점 아이디(테스트 완료후 real 서비스용 발급필요)*/
	String mbrNo = "100011";  // <<===테스트 가맹점 번호 입니다.
	parameters.put("version", "1.0");
	parameters.put("mbrNo", mbrNo);
	/* 가맹점 주문번호 (결제시에 사용한 값) 6byte~20byte*/
	parameters.put("mbrRefNo", "12345678901234567890"); 
	
	/* 원거래번호 (결제완료시에 수신한 값), 망취소시 생략 가능 */
	parameters.put("orgRefNo", "123456789012");
	
	/* 원거래일자(결제완료시에 수신한 값) YYMMDD, 망취소시 승인요청일 설정*/
	parameters.put("orgTranDate", "180912");
	
	/* 지불수단 (CARD:신용카드|VACCT:가상계좌|ACCT:계좌이체|HPP:휴대폰소액)*/
	parameters.put("paymethod", "CARD"); 
	/* 결제된금액 */
	parameters.put("amount", "500");
	
	/* 결제된금액 ( 결제완로시에 받은 값) */
	parameters.put("payType", "I");
	
	/* 망취소 유무(Y:망취소, N:일반취소) (주문번호를 이용한 망취소시에 사용)*/
	parameters.put("isNetCancel", "N");
		
	/*고객명  max 30byte*/
	parameters.put("customerName", "고객명");
	parameters.put("customerEmail", "amudog@facenote.com");
	
	/* timestamp
	  Java 버전은 생략(라이브러리에서 자동 생성됨)
	*/		
	/* signature
		Java 버전은 생략(라이브러리에서 자동 생성됨)
	*/
	
    /*=================================================================================================
     *	CANCEL API 호출 (**테스트 후 반드시 리얼-URL로 변경해야 합니다.**) 
     *=================================================================================================*/
	String responseJson = "";        
	try{
		/* CANCEL API 호출        	
		리얼-URL : String CANCELUrl = "https://relay.mainpay.co.kr/v1/api/payments/payment/cancel";
		개발-URL : String CANCELUrl = "https://dev-relay.mainpay.co.kr/v1/api/payments/payment/cancel";
		*/
		String cancelUrl = "https://dev-relay.mainpay.co.kr/v1/api/payments/payment/cancel"; // 테스트용, 변경 필수
		responseJson = HttpSendTemplate.post(cancelUrl, parameters, apiKey);	
	} catch(Exception e) {
		System.err.println(String.format("CANCEL API 호출결과 수신실패 : %s", e.getMessage()));
		e.printStackTrace();
		out.println("ERROR");
		return;		
	} 
			
	Map responseMap = ParseUtils.fromJson(responseJson, Map.class);        
	String resultCode = (String) responseMap.get("resultCode");        
	String resultMessage = (String) responseMap.get("resultMessage");

	if( ! "200".equals(resultCode)) { //CANCEL API 호출 실패
		String errMessage = String.format("CANCEL API 호출결과 : resultCode: %s, resultMessge: %s", resultCode, resultMessage);
		System.err.println(errMessage);
		out.println(responseJson); 
		return;
	}
	
	Map dataMap = (Map)responseMap.get("data");
	String refNo = (String) dataMap.get("refNo");
	String tranDate = (String) dataMap.get("tranDate");     
	String tranTime = (String) dataMap.get("tranTime");     		
	
	
	out.println(responseJson); 

	//	상점 주문취소 처리 진행

	// JSON TYPE RESPONSE (JSON 응답 리턴시에 사용)
	response.setContentType("application/json");
	out.println(responseJson);
%>    
