function testResponse(xmlhttp) {
    return function() {
	if (xmlhttp.readyState==4) {
	    ok(xmlhttp.status==200, "admin page is not available");
	    start();
	}
    }
}