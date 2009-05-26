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

/*
+-+-+-+-+-+-+-+-+-+ +-+-+-+-+-+ +-+-+-+-+-+-+-+-+-+-+
|P|r|o|t|o|t|y|p|e| |A|r|r|a|y| |E|x|t|e|n|s|i|o|n|s|
+-+-+-+-+-+-+-+-+-+ +-+-+-+-+-+ +-+-+-+-+-+-+-+-+-+-+ 
*/
                
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



// Variables for Credit Card Functions
var CreditCardTypes = new Array(
														["^4", "visa", true],
														["^(34|37)", "american_express", true],
														["^5[1-5]", "master", true],
														["^(6304[89])[0-9]{11}", "laser", false],
														["^(6304[89])[0-9]{14}", "laser", false]
													);
													
CreditCardOptions = new Array();
CreditCardOptions['field'] = "creditcard_type";
CreditCardOptions['number_field'] = "creditcard_number";
CreditCardOptions['image'] = "creditcard_image";
CreditCardOptions['image_path'] = "../images/";
CreditCardOptions['cvv_field'] = 'creditcard_verification_value';
CreditCardOptions['available'] = new Array("visa", "american_express", "master", "laser");

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
