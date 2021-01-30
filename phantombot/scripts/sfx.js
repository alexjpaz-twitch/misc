(function() {
  function shuffle(array) {
	  var currentIndex = array.length, temporaryValue, randomIndex;

	  // While there remain elements to shuffle...
	  while (0 !== currentIndex) {

		  // Pick a remaining element...
		  randomIndex = Math.floor(Math.random() * currentIndex);
		  currentIndex -= 1;

		  // And swap it with the current element.
		  temporaryValue = array[currentIndex];
		  array[currentIndex] = array[randomIndex];
		  array[randomIndex] = temporaryValue;
	  }

	  return array;
  }

  $.bind('command', function(event) {
    var sender = event.getSender().toLowerCase();
    var command = event.getCommand();
    var args = event.getArgs();

    if (command.equalsIgnoreCase('sfx')) {
	    var keys = $.inidb.GetKeyList('audioCommands', '');

            var filterText = args[0];

	    $.log.error(filterText);

	    if(filterText) {
	      keys = keys.filter(function(k) { return k.indexOf(filterText) >= 0 });
	    } else {
	      keys = shuffle(keys);
	    }

            var selected  = [];

            for(var i=0; i < keys.length; i++) {
	      if(selected.join(", ").length > 300) {
		continue;
	      }

	      selected.push(keys[i]);
	    }

            selected = selected.map(function(i) {
	      return "!"+i;
	    });

            selected.sort();

            var output = "KAPOW " + selected.join(", ");

            output += " ("+selected.length+"/"+keys.length+")";

	    $.log.error(output);
      	    $.say(output);
    }
  });

  $.bind('initReady', function() {
      $.registerChatCommand('./custom/sfx.js', 'sfx', 7);
  });
})();
