//this tracks all of the information that we have or need about the various 
//transforms. 

function Info() {

    this.root = document.getElementById('InfoPanel');

    this.panels = new Array();

    return this;
};



Info.prototype.draw = function () {

    var configs = this.discoverAvailableConfigs();

    for (var i=0; i<= configs.length -1 ; i++) {
	
	var list = document.createElement('ul');

	var mine = configs[i];
	
	
	
	if (mine['link'] == 1) {
	    var link = document.createElement('a');
	    link.setAttribute('href', mine.artifact);
	    var text = document.createTextNode(mine.name + ":" + mine.status);
	    link.appendChild(text);
	    this.root.appendChild(link);
	}

	for (var key in configs[i]) {
	    
	    if (key.match(/^..\s/)) {
		if (key.match(/completed/)) {
		    continue;
		}
		var item = document.createElement('li');
		
		var text = document.createTextNode(key);
		
		item.appendChild(text);
		list.appendChild(item);
	    }
	    
	}
	

	this.root.appendChild(list);
	
	var button = document.createElement('input');
	button.type = 'button';
	button.value = mine.name + ' regenerate';

	button.onclick = this.createStartSemaphore;
	button.setAttribute('id', mine.name); 
	if (mine['link'] == 1) {
	    this.root.appendChild(button);
	}
	this.panels.push(configs[i]);
    }

    
    
};

Info.prototype.createStartSemaphore = function() {
    var target = findRoot + "/" + "workingArea/php/basic.php?command=createSemaphore&state="  + this.id;

    xmlhttp=getRequestObject();

    xmlhttp.open("GET",target,false);
    
    xmlhttp.send();

    

}

Info.prototype.discoverAvailableConfigs = function(root) {

    var block = 1;
    var configs = new Array();
    configs.pop;

    xmlhttp=getRequestObject();

    var target = findRoot + "/" + "workingArea/php/basic.php?command=readConfigFiles&state="  + '..' + window.location.pathname;

    xmlhttp.open("GET",target,false)
    
    xmlhttp.send();
        
    var lines = xmlhttp.responseText.split(/\n/);



    var care = '';

    for(i =1; i< lines.length -1; i++) {
	if (lines[i].match(/^----/)) {
	    var currentCfg = new configObj(care);
	    configs.push(currentCfg);
	   
	    continue;
	}
	
	care = care + lines[i] + "|";

	
	
    }

	
    return configs;


};

Info.prototype.generatePanels = function() {

    


};


//putting this here as it should be private to the info obects

function configObj (lines) {
    var array = lines.split('|');
    
    for(var i=0; i< array.length -1; i++) {

	var line = array[i];
	
	var stuff = line.split(/=/);
	
	var prop = stuff[0];
	
	this[prop] = stuff[1]; 
	
		
    }
    
};
