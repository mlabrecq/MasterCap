asyncTest( "Admin Page Exists", function() {
    
    var xmlhttp=getRequestObject()
    
    xmlhttp.open("GET","../admin.html",true);
    xmlhttp.onreadystatechange = testResponse(xmlhttp);
    xmlhttp.send();
 

  
});