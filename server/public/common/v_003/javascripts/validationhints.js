

// This function checks if the username field
// is at least 6 characters long.
// If so, it attaches class="welldone" to the 
// containing fieldset.

function checkUsernameForLength(whatYouTyped) {
	var p = whatYouTyped.parentNode;
	var txt = whatYouTyped.value;
	if (txt.length > 5) {
		p.className = "welldone";
	}
	else {
		p.className = "";
	}
}

// This function checks if a general text field
// is at least 2 characters long.
// If so, it attaches class="welldone" to the 
// containing fieldset.

function checkTextForLength(whatYouTyped) {
	var p = whatYouTyped.parentNode;
	var txt = whatYouTyped.value;
	if (txt.length > 1) {
		p.className = "welldone";
	}
	else {
		p.className = "";
	}
}

// If the password is at least 4 characters long, the containing 
// fieldset is assigned class="kindagood".
// If it's at least 8 characters long, the containing
// fieldset is assigned class="welldone", to give the user
// the indication that they've selected a harder-to-crack
// password.

function checkPassword(whatYouTyped) {
	var p = whatYouTyped.parentNode;
	var txt = whatYouTyped.value;
	if (txt.length > 3 && txt.length < 8) {
		p.className = "kindagood";
	} else if (txt.length > 7) {
		p.className = "welldone";
	} else {
		p.className = "";
	}
}

// This function checks the email address to be sure
// it follows a certain pattern:
// blah@blah.blah
// If so, it assigns class="welldone" to the containing
// fieldset.

function checkEmail(whatYouTyped) {
	var p = whatYouTyped.parentNode;
	var txt = whatYouTyped.value;
	if (/^\w+([\.-]?\w+)*@\w+([\.-]?\w+)*(\.\w{2,3})+$/.test(txt)) {
		p.className = "welldone";
	} else {
		p.className = "";
	}
}

// This function checks if a checkbox has been checked

function checkCheckbox(checkbox) {
	var p = checkbox.parentNode;
	if (checkbox.checked){
		p.className = "welldone";
	} else {
		p.className = "";
	}
}


// this part is for the form field hints to display
// only on the condition that the text input has focus.
// otherwise, it stays hidden.

function addLoadEvent(func) {
  var oldonload = window.onload;
  if (typeof window.onload != 'function') {
    window.onload = func;
  } else {
    window.onload = function() {
      oldonload();
      func();
    }
  }
}


function prepareInputsForHints() {
  var inputs = document.getElementsByTagName("input");
  for (var i=0; i<inputs.length; i++){
    
	inputs[i].onfocus = function () {		
      if  (this.parentNode.getElementsByTagName("span")[0].className == "hint") 
			this.parentNode.getElementsByTagName("span")[0].style.display = "inline";
	}
	
	inputs[i].onblur = function () {
      this.parentNode.getElementsByTagName("span")[0].style.display = "none";
    }
  }
}
//addLoadEvent(prepareInputsForHints);


function prepareSelectsForHints() {
  var selects = document.getElementsByTagName("select");
  for (var i=0; i<selects.length; i++){
    selects[i].onfocus = function () {
      this.parentNode.getElementsByTagName("span")[0].style.display = "inline";
    }
    selects[i].onblur = function () {
      this.parentNode.getElementsByTagName("span")[0].style.display = "none";
    }
  }
}
//addLoadEvent(prepareSelectsForHints);
