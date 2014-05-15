test('Info Panel Operational', function() {

    var info = new Info(configFile);

    ok(info.panels.length == 0, info.panels.length);

    info.draw();

    ok(info.panels.length == 2);
    

});

test('can read all available config files', function() {

    var info = new Info();

    //this should find the test configuration files
    // rather than the root configuration files.

    //this test is reflecting an unclean state.
    var configurationInfo = info.discoverAvailableConfigs('.');

    ok(configurationInfo.length == 2);

    ok(configurationInfo[0]["name"] == 'Raw Qwipu Test', "not right" + configurationInfo[0]["name"]);
    ok(configurationInfo[0].order == 0, configurationInfo[0].order + ' not equal to 0');
    ok(configurationInfo[0].status == 'Complete',configurationInfo[0].status );
    ok(configurationInfo[0].errors == 'Error: FA:', configurationInfo[0].errors);
    ok(configurationInfo[0].artifact == 'http://mlabrecq.org/masterCap/test/data/raw/merged.csv.gz');
    ok(configurationInfo[0].link == 1, configurationInfo[0].link);

    ok(configurationInfo[1].name == 'Emp only Qwipu Test', configurationInfo[1].name);
    ok(configurationInfo[1].order == 1);
    ok(configurationInfo[1].status == 'Not Started');
    ok(configurationInfo[1].errors == 'Not Applicable');
    ok(configurationInfo[1].artifact == 'http://mlabrecq.org/masterCap/test/data/reduce/reduced.csv.gz',  configurationInfo[1].artifact );
    ok(configurationInfo[1].link == 0);


});

