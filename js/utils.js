function getRequestObject() {

    if (window.XMLHttpRequest)
    {// code for IE7+, Firefox, Chrome, Opera, Safari
	xmlhttp=new XMLHttpRequest();
    }
    else
    {// code for IE6, IE5
	xmlhttp=new ActiveXObject("Microsoft.XMLHTTP");
    }

    return xmlhttp;

}

//creates a custom event that we can catch and throw.
function getCustomEvent(name) {
   
    var event = new CustomEvent(
	name, 
	{
	    detail: {
		message: "Hello World!",
		time: new Date(),
	    },
	    bubbles: true,
	    cancelable: false
	}
    );

    return event;

}