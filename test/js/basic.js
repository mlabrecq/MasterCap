
function dotest() {
    while ( log.firstChild ) log.removeChild( log.firstChild );
    xmlhttp=getRequestObject()
    
    xmlhttp.onreadystatechange = writeText;
    xmlhttp.open("GET","php/basic.php",true);
    xmlhttp.send();
    
}

function writeText() {

    var insert = document.createElement('p');
    var log = document.getElementById('log');
    log.innerHTML = '';
    
    if (xmlhttp.readyState==4 && xmlhttp.status==200) {
	var test = document.createElement('pre');

	test.appendChild(document.createTextNode(xmlhttp.responseText));
	log.appendChild(test);
    }
    insert.appendChild(document.createTextNode(xmlhttp.readyState + ' ' + xmlhttp.status));
    log.appendChild(insert);
}