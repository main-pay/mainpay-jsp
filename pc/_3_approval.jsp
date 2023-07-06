<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.*, com.mainpay.sdk.security.*,com.mainpay.sdk.net.*,com.mainpay.sdk.utils.*" %>
<%
	/*=================================================================================================	
	 인증이 완료될 경우 PG사에서 호출하는 페이지 입니다. 	     
	 PG로 부터 전달 받은 인증값을 받아 PG로 승인요청을 합니다.	
	 =================================================================================================*/
	String aid = request.getParameter("aid");
	String authToken = request.getParameter("authToken");
	String merchantData = request.getParameter("merchantData");
	String payType = request.getParameter("payType");
	System.out.println(String.format("인증토큰 수신 aid: %s , authToken: %s ", aid, authToken));

	/*=================================================================================================
     *	reay에서 DB에 저장한 요청정보 값 조회해서 사용하세요.
     *=================================================================================================*/ 
	Map<String, String> parameters = new HashMap<String, String>();
	String API_BASE = "https://test-api-std.mainpay.co.kr";
	String apiKey = "U1FVQVJFLTEwMDAxMTIwMTgwNDA2MDkyNTMyMTA1MjM0";
	
	parameters.put("version", "V001");
	parameters.put("mbrNo", "100011");
	parameters.put("mbrRefNo", "P000000001");    		 	
	parameters.put("paymethod", "CARD"); 
	parameters.put("amount", "1004");
	parameters.put("goodsName", "카약-슬라이더406"); 
	parameters.put("goodsCode", "GOOD0001");
	parameters.put("approvalUrl", "https://상점도메인/pc/_3_approval.jsp"); 
	parameters.put("closeUrl", "https://상점도메인/pc/_3_close.jsp"); 
	parameters.put("customerName", "고객명");
	parameters.put("customerEmail", "test@spc.co.kr");
	
	if(parameters == null) {
		System.err.println("이미 결제가 완료 되었거나, 만료된 요청입니다.");
		out.println("<script>alert('이미 결제가 완료 되었거나, 만료된 요청입니다.')</script>");
		return;
	}

	/*승인요청 파라미터 세팅*/
	parameters.put("aid", aid);
	parameters.put("authToken", authToken);
	parameters.put("merchantData", merchantData);
	parameters.put("payType", payType);	

	/*=================================================================================================
	 *** PG서버로 승인요청    	
	 =================================================================================================*/
	
	 String responseJson = "";     
	 Map responseMap = null;
     String resultCode = "";        
     String resultMessage = "";
     try{
     	/* 결제준비 API 호출   */
     	String payUrl = API_BASE + "/v1/payment/pay";
     	responseJson = HttpSendTemplate.post(payUrl, parameters, apiKey);
     } catch(Exception e) {
     	/* 망취소 처리(승인API 호출 도중 응답수신에 실패한 경우) */
     	String netCancelUrl = API_BASE + "/v1/payment/net-cancel"; 
     	HttpSendTemplate.post(netCancelUrl, parameters, apiKey);
     	resultCode="C300";
     	resultMessage = String.format("승인 API 결과 수신 실패 : %s", e.getMessage());
     	out.println("<script>alert('"+resultMessage+"')</script>");
     	return;
     } 
	 
	 responseMap = ParseUtils.fromJson(responseJson, Map.class);             
     resultCode = (String) responseMap.get("resultCode");        
     resultMessage = (String) responseMap.get("resultMessage");
     out.println("[승인API 호출결과]  \n " + responseJson);
     
     //승인API 호출 실패
     if( ! "200".equals(resultCode)) {
     	System.err.println(responseJson);
     	out.println("<script>alert('"+resultMessage+"')</script>");
     	return;
     }            
    
	String refNo = (String) responseMap.get("refNo");
	String tranDate = (String) responseMap.get("tranDate");
	String mbrRefNo = (String) responseMap.get("mbrRefNo");
	String applNo = (String) responseMap.get("applNo");
	payType = (String) responseMap.get("payType");
	//상점 주문성공 처리 (DB처리) ===>>

	
%>
<!DOCTYPE html>
<html>
<head>
<title>상점 도착페이지</title>
</head>
<body>
<script>
/* 결제 완료 페이지 처리 */
var resultCode = "<%=resultCode %>";
var resultMessage = "<%=resultMessage %>";
alert("resultCode:" + resultCode + ": " + resultMessage);

/* 현재 팝업 닫기*/
//Mainpay.close(true);
</script> 
</body>
</html>