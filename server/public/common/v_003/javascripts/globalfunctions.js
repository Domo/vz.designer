/* File Version: 1.0 */


/* Luhn algorithm number checker - (c) 2005-2008 shaman - www.planzero.org *
 * This code has been released into the public domain, however please      *
 * give credit to the original author where possible.                      */
 
 function luhn_check(number) {
	//<![CDATA[

	// Strip any non-digits (useful for credit card numbers with spaces and hyphens)
	var number=number.replace(/\D/g, '');

	// Set the string length and parity
	var number_length=number.length;
	var parity=number_length % 2;

	// Loop through each digit and do the maths
	var total=0;
	for (i=0; i < number_length; i++) {
		var digit=number.charAt(i);
		// Multiply alternate digits by two
		if (i % 2 == parity) {
		digit=digit * 2;
		// If the sum is two digits, add them together (in effect)
		if (digit > 9) {
			digit=digit - 9;
		}
		}
		// Total up the digits
		total = total + parseInt(digit);
	}
	// If the total mod 10 equals 0, the number is valid
	if (total % 10 == 0) {
		return true;
	} else {
		return false;
	}
//]]>
}

// Prototype Array Extensions
                
Array.prototype.index = function(val) {
  for(var i = 0, l = this.length; i < l; i++) {
    if(this[i] == val) return i;
  }
  return null;
}

Array.prototype.include = function(val) {
  return this.index(val) !== null;
}

Array.prototype.contains = function(searchString){
	for(result=[], x=0; x<this.length; x++){
		if(this[x] == searchString){
			result[result.length]=x;
		}
	}
	return result.length ? result : -1;
};

Array.prototype.delete_at = function(position) {
	for (var x = 0; x < this.length; ++x) {
		if (x >= position) {
			this[x] = this[x + 1];
		}
	} this.pop();
};

Array.prototype.multipush = function(){
	for( i=0; i<arguments.length; i++){
		this[this.length]=arguments[i];
	}
};




//Credit Card Check - Stefan Exner
// Variables for Credit Card Functions
var CreditCardTypes = new Array(
								["^4[0-9]{12}([0-9]{3})?$", "visa", true],
								["^3[47][0-9]{13}$", "american_express", true],
								["^(5[1-5][0-9]{4}|677189)[0-9]{10}$", "master", true],
								["^6011[0-9]{12}$", "discover", true],
								["^3(0[0-5]|[68][0-9])[0-9]{11}$", "diners_club", true],
								["^3528[0-9]{12}$", "jcb", true],
								["^(493698|633311|6759[0-9]{2})[0-9]{10}([0-9]{2,3})?$", "switch", true],
								["^6767[0-9]{12}([0-9]{2,3})?$", "solo", true],
								["^5019[0-9]{12}$", "dankort", true],								
								["^(6771([0-9]{12}|[0-9]{13}|[0-9]{14}|[0-9]{15})|6709([0-9]{12}|[0-9]{13}|[0-9]{14}|[0-9]{15})|6304[89][0-9]{11}([0-9]{2,3})?|670695([0-9]{9}|[0-9]{10}|[0-9]{11}|[0-9]{12}|[0-9]{13}))$", "laser", false]
							);
													
CreditCardOptions = new Array();
CreditCardOptions['field'] = "creditcard_type";
CreditCardOptions['number_field'] = "creditcard_number";
CreditCardOptions['image'] = "creditcard_image";
CreditCardOptions['image_path'] = "../images/";
CreditCardOptions['cvv_field'] = 'creditcard_verification_value';
CreditCardOptions['available'] = new Array("visa", "american_express", "master", "laser", "diners_club");

//Credit Card Functions

function GetCreditCardType(number)
        {            
		var re = new RegExp("1");
		for (var i = 0; i <= CreditCardTypes.length - 1; i++)
			{
				re = new RegExp(CreditCardTypes[i][0]);
				if (number.match(re) != null && luhn_check(number)) {
					var result = new Array(CreditCardTypes[i][1], CreditCardTypes[i][2]);
					return result;
					break;
				}
			}
			return [];
        }

function SetCreditCardType()
	{
		var card_number = $(CreditCardOptions['number_field']).value;
		var typeField = document.getElementById(CreditCardOptions['field']);
		var card = GetCreditCardType(card_number);
		var imageField = document.getElementById(CreditCardOptions['image']);
		if (card.length > 0 && CreditCardOptions['available'].include(card[0])) {
			var image = CreditCardOptions['image_path'] + 'ico_card_' + card[0].toLowerCase().replace(/ /g, "_") + '.png';
			typeField.value = card[0];
			if (card[1] == true) {
				$(CreditCardOptions['cvv_field']).show()
			} else {
					$(CreditCardOptions['cvv_field']).hide()
				}
			imageField.src = image;				
		} else {
				imageField.src = CreditCardOptions['image_path'] + 'ico_card_none.png';			
				typeField.value = ' ';
			}
	}	
	
function CreateCreditCardTypeChecker(_field) {
	CreditCardOptions['number_field'] = _field;
	$(_field).onchange = SetCreditCardType;
	if ($F(_field) != '') {
		SetCreditCardType();
	}
}

function AddClassToElement(_element, _class) {
	var classes = _element.className.split(" ");
	if (classes.contains(_class) == -1) {
		classes.multipush(_class);
	}
	_element.className = classes.join(" ");
	return true;
}

function DeleteClassFromElement(_element, _class) {
	var classes = _element.className.split(" ");
	if (classes.contains(_class) > -1) {
		classes.delete_at(classes.contains(_class));
	}
	_element.className = classes.join(" ");
	return true;
}

function FieldFocusColorChange(_parent, _focus) {
		if (_focus == true) {
			AddClassToElement(_parent, "focusonelement");
		} else  {
			DeleteClassFromElement(_parent, "focusonelement");	
		} 
}

function CreateFieldFocusColorChanges(_form) {
	for (var i = 0; i < $(_form).length; i++) {
		if ($(_form)[i].tagName == "INPUT" || $(_form)[i].tagName == "TEXTAREA" || $(_form)[i].tagName == "SELECT") {
			$(_form)[i].onfocus = function() {FieldFocusColorChange(this.parentNode, true);};
			$(_form)[i].onblur = function() {FieldFocusColorChange(this.parentNode, false);};
		}
	}
}
	
//Function to disable all submit-buttons in a form
function disableAllSubmitButtons(aForm)
     {
	  fForm = document.getElementById(aForm);
	  
	  for (var i = 0; i < fForm.length; i++)
	       {
		    if (fForm[i].type == "submit")
			 {
			      fForm[i].disabled = true;
				  fForm[i].style.backgroundColor = "gray";
				  fForm[i].style.cursor = "pointer";
			 }
	       }	       
		   return true;
     }
     
 //This function is from DHTML Calendar (http://www.dynarch.com/projects/calendar/)
function createElement(type, parent) {
	var el = null;
	if (document.createElementNS) {
		// use the XHTML namespace; IE won't normally get here unless
		// _they_ "fix" the DOM2 implementation.
		el = document.createElementNS("http://www.w3.org/1999/xhtml", type);
	} else {
		el = document.createElement(type);
	}
	if (typeof parent != "undefined") {
		document.getElementById(parent).appendChild(el);
	}
	return el;
};
function destroyElement(element, parent) {
   obj = document.getElementById(element);
   document.getElementById(parent).removeChild(obj);
}



     
// Parameters:
//	sElementID: ID of the element you want to shade
//	bShow: Shade or brighten the element, true = shade, false = brighten
//	sStyleSheet: You can insert the class of your own stylesheet, otherwise a standard style is used. You don´t have
//		to set sStyleSheet when you want to remove the shade.
//	example: shadeElement('testdiv', true, 'superClassName');
function shadeElement(sElementID, bShow, sStyleSheet) {
	if (document.getElementById(sElementID).style.position == "relative") {
		if (bShow == true) {
			if (document.getElementById(sElementID + "_lightbox")) {
				var lightbox = document.getElementById(sElementID + "_lightbox");
			}
			else {
				var lightbox = createElement("div", sElementID);
				lightbox.id = sElementID + "_lightbox";
				lightbox.innerHTML = " ";
			}
			if (typeof sStyleSheet != "undefined") {
				lightbox.className = sStyleSheet;
			}
			else {
				lightbox.style.position = "absolute";
				lightbox.style.top = 0;
				lightbox.style.bottom = 0;
				lightbox.style.left = 0;
				lightbox.style.right = 0;
				lightbox.style.backgroundColor = "#000";
				lightbox.style.opacity = 0.8;
				lightbox.style.zIndex = 2000;
				lightbox.style.display = "block";
				lightbox.style.filter = "alpha(opacity = 80)"; // IE
				lightbox.style.width = "100%"; //Stupid IE
				lightbox.style.height = document.getElementById(sElementID).offsetHeight; // &&&!§&!§"$&!!! IE
				document.getElementById(sElementID).style.zoom = 1; //Force "hasLayout" for containing div in IE
			}
		}
		else {
			if (document.getElementById(sElementID + "_lightbox")) {
				destroyElement(sElementID + "_lightbox", sElementID);
			}
		}
	}
	else {
		alert('The position-attribute of your chosen div is not "relative",  but it has to be relative.');
	}
}



