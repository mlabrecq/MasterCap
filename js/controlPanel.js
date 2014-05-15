window.onload = initPage;

//evil global state.
// this should live in its own javascript class.

// too bad for now.
var button; //Needs ID set to rawdata
var findRoot; //
var configFile;
var log; // used in tests.... //Needs ID set to log

// id of root with loc attribute. Value is path to the root area.
// for test it is ..
// for main is it . or empty.

// id of configfile attribute of file;
// this is the name of the configuration file in the local directory.

function initPage() {

    findRoot = document.getElementById('root').getAttribute('loc');
    configFile = document.getElementById('configfile').getAttribute('file');

    var info = new Info();
    info.draw();
    
}
