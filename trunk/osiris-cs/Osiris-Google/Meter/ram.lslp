// CHALLENGE/AUTHENTICATION
string secureKey="";
string securePass;
string myKey="";
string randCheck;

createSecurePass()
{
  securePass="";   
}
string cryptPass (string str)
{
    return llXorBase64StringsCorrect(llStringToBase64(str), llStringToBase64(securePass));
}
string decryptPass (string str)
{
    return llBase64ToString(llXorBase64StringsCorrect(str, llStringToBase64(securePass)));
}
receiveChallenge(string msg)
{
    createSecurePass();
    setRandCheck(); // sets a random string of numbers in the middle of the message to jump things up
    string message=decryptPass(msg);
    string source=left(message, "|");
    string sourceKey=right(message, "||");
    securePass=right(left(message,"||"),"|"); // this line changes the initial password to the one received from security
    if (source=="security" && sourceKey==secureKey)
        {
            string response="ram|"+ randCheck + "||" + myKey;
            llMessageLinked(LINK_THIS, 8001, cryptPass(response), NULL_KEY);   
        }
}
setRandCheck()
{
    randCheck=(string)llFrand(9999999999.0)+ (string)llFrand(9999999999.0);
}
string right(string src, string divider) {
    integer index = llSubStringIndex( src, divider );
    if(~index)
        return llDeleteSubString( src, 0, index + llStringLength(divider) - 1);
    return src;
}
string left(string src, string divider) {
    integer index = llSubStringIndex( src, divider );
    if(~index)
        return llDeleteSubString( src, index, -1);
    return src;
}

integer		simConfigID;
integer		health;
integer		stam;
integer		special;
integer		status;

list		simdata;

getSimdata(integer simID) {
	if (llGetListLength(simdata) != 0) {
		integer found;
		integer index;
		while (index <= (llGetListLength(simdata)-1) && !found) {
			list check = llParseString2List(llList2String(simdata,index),["|"],[]);
			if (llList2Integer(check,0) == simConfigID) {
				health = llList2Integer(check,1);
				stam = llList2Integer(check,2);
				special = llList2Integer(check,3);
				//llOwnerSay("Found saved sim data, will send: " + (string)simConfigID + "|" + (string)health + "|" + (string)stam + "|" + (string)special + "|" + (string)status);
				llMessageLinked(LINK_THIS, 10001, (string)simConfigID + "|" + (string)health + "|" + (string)stam + "|" + (string)special + "|" + (string)status, NULL_KEY);
				found = TRUE;
			}
			index++;
		}
	}
}

saveSimdata() {
	if (simConfigID) {
		integer found;
		integer index;
		while (index < (llGetListLength(simdata)) && !found) {
			list check = llParseString2List(llList2String(simdata,index),["|"],[]);
			if (llList2Integer(check,0) == simConfigID) {
				found = TRUE;
			}
			index++;
		}
		if (status > 5 || status < 0) {
			status = 0;
		}
		if (!found) {
			simdata += [(string)simConfigID + "|" + (string)health + "|" + (string)stam + "|" + (string)special + "|" + (string)status];
		} else {
			simdata = llListReplaceList((simdata = []) + simdata, [(string)simConfigID + "|" + (string)health + "|" + (string)stam + "|" + (string)special + "|" + (string)status], index-1, index-1);
		}
		
		//llOwnerSay("Saved sim data: " + (string)simConfigID + "|" + (string)health + "|" + (string)stam + "|" + (string)special + "|" + (string)status);
		//llOwnerSay("simdata: " + llList2CSV(simdata));
	}
}

setSimdata(string input) { //Save the data to integers, without storing them in a list, faster to load the integers than finding it in the list first.
	if (simConfigID) {
		list check = llParseString2List(input,["|"],[]);
		if (llList2Integer(check,4) != 99) {
			if (llList2Integer(check,1) >= 0) health = llList2Integer(check,1);
			if (llList2Integer(check,2) >= 0) stam = llList2Integer(check,2);
			if (llList2Integer(check,3) >= 0) special = llList2Integer(check,3);
			if (llList2Integer(check,4) >= 0) status = llList2Integer(check,4);
			//llOwnerSay("Saved : " + (string)simConfigID + "|" + (string)health + "|" + (string)stam + "|" + (string)special + "|" + (string)status);
		}
	}
}

//** Translator functions start //**

string      fromLang = "en";    // The language you're speaking in.
string      fromLangNa;         // The name of the language you're speaking in.

string      toLang   = "en";    // Translate to this language.
string      toLangNa;           // The name of the language you're speaking in.

string      temp;               // Store declare of language temp
string		lstMsg;				// Store the last message to llOwnerSay it along with the translation
string		lstName;			// Store the name of the last heard talking

integer     tempchan;           // Chan for the dialog listener
integer     listen_handle;      // Listener for the menu channel
integer		public_listen;		// Listener for public channel... on NULL_KEY :'o(
integer     offset;             // Offset for the items in the dialog
integer     inputChan = 1;      // For user input
integer		transOther = TRUE;	// Translate text said by others
integer		transSelf = TRUE;	// Translate text said by owner

key         translateKey;       // http request for translating
key         detectKey;          // http request for detecting
key			translateOther;		// http request, when translating on channel 0, heard from others
key			translateSelf;		// http request, when translating on channel 0, heard from self

list dB(list buttons) { return llList2List(buttons, -3, -1) + llList2List(buttons, -6, -4) + llList2List(buttons, -9, -7) + llList2List(buttons, -12, -10); }

list        languages   = ["Albanian","Arabic","Bulgarian","Catalan","Chinese","Croatian","Czech","Danish","Dutch","English","Estonian","Filipino","Finnish","French","Galician","German","Greek","Hebrew","Hindi","Hungarian","Indonesian","Italian","Japanese","Korean","Latvian","Lithuanian","Maltese","Norwegian","Persian","Polish","Portuguese","Romanian","Russian","Serbian","Slovak","Slovenian","Spanish","Swedish","Thai","Turkish","Ukrainian","Vietnamese"];

list        declare     = ["sq","ar","bg","ca","zh-CN","hr","cs","da","nl","en","et","tl","fi","fr","gl","de","el","iw","hi","hu","id","it","ja","ko","lv","lt","mt","no","fa","pl","pt","ro","ru","sr","sk","sl","es","sv","th","tr","uk","vi"];

findLang(string input) {
    integer index = llListFindList(languages, [input]);
    if (index != -1) {
        temp = llList2String(declare, index);
        llDialog(llGetOwner(),"\nIs " + llList2String(languages, index) + " what you are converting from or to?",dB(["From","- Cancel -","To"]),tempchan);
    }
}

string convert(string input) {
	input = StringReplace(input, "/ me", "/me");
	input = StringReplace(input, " ...", "... ");
	input = StringReplace(input, "\u0026#39;", "'");
    input = StringReplace(input, "\u0026quot;", "\"");    	
    input = llDeleteSubString(llUnescapeURL(input), 0, 35);
    input = llDeleteSubString(input, llStringLength(input)-51, -1);
    return input;
}

string getLangNa(string input) {
    integer index = llListFindList(declare, [input]);
    if (index != -1) {
        input = llList2String(languages, index);
    }
    return input;
}

string getLang(string input) {
    integer index = llListFindList(languages, [input]);
    if (index != -1) {
        input = llList2String(declare, index);
    }
    return input;
}

string process(string input) {
	input = StringReplace(input, "æ", "ae");
	input = StringReplace(input, "ø", "oe");
	input = StringReplace(input, "å", "aa");
    list temp = llParseString2List(input,[" "],[]);
    return llDumpList2String(temp,"%20");
}

string transWho() {
	string temp = "And i am translating";
    if (transOther && !transSelf) temp += " what others say.";
    if (transSelf && !transOther) temp += " what you say.";
    if (transOther && transSelf) temp += " both what you and others say.";
    if (!transOther && !transSelf) temp = "And i wont translate anything.";
    return temp;
}

listLanguages(string input) {
    if (input == "next") {
        offset += 9;
    } else if (input == "prev") {
        offset -= 9;
    }
    if (llList2List(languages, offset, offset + 9) == []) {
        offset = 0;
    }
    llDialog(llGetOwner(),"\nCurrent settings:\nFrom: " + getLangNa(fromLang) + "\nTo: " + getLangNa(toLang) + "\n\nPlease choose a language:\n",dB(llList2List(languages, offset, offset + 9) + ["< Prev <","- Cancel -","> Next >"]),tempchan);
}

string StringReplace(string Source, string From, string To) { // StringReplace(activetitle, "%nn", llKey2Name(tipkey))
    return llDumpList2String( llParseStringKeepNulls( (Source = "") + Source, [From], [] ), To );
}

//** Translator functions stop //**

default {
	state_entry() {
		tempchan = (integer)(-1*llFrand(2147483645)); // Generate temp chan for dialog
	}
	link_message(integer sender_num, integer num, string str, key id) { 
		if (num==8000) {
			receiveChallenge(str);
		} else if (num==1) {
			if (left(str, "|") == "CONFIGID") {
				llListenRemove(public_listen);
				if ((integer)right(str, "|") != simConfigID) {
					//saveSimdata();
					//llSleep(5);
					//health = 100;
					//stam = 100;
					//special = 0;
        			simConfigID = (integer)right(str, "|");
				}
			} else if (str == "LOADCOMPLETE|1") {
				if (fromLang != toLang) {
					llDialog(llGetOwner(),"\nCurrent settings:\nFrom: " + getLangNa(fromLang) + "\nTo: " + getLangNa(toLang) + " (sim language)\n\nDo you want to activate the translator?:\n",["Activate","- Cancel -"],tempchan);
					listen_handle = llListen(tempchan,"", llGetOwner(),"");
					llSetTimerEvent(120);
				}
				llSleep(5);
				getSimdata(simConfigID);
			} else if (left(str, "|") == "LAN") {
				toLang = getLang(right(str, "|"));
			}
		} else if (num==10000) { //str format = simID|health|stam|special|status
        	if (str == "SAVESIMDATA") {
        		saveSimdata();
        	} else {
        		setSimdata(str);
        	}
		} else if (num==11000) { // Messages to the translator
        	if (str == "DIALOG") {
        		listen_handle = llListen(tempchan,"", llGetOwner(),"");
        		llDialog(llGetOwner(),"\nCurrent settings:\nFrom: " + getLangNa(fromLang) + "\nTo: " + getLangNa(toLang) + " (sim language)\n\n" + transWho(),["Me","Others","Both","Activate","Deactivate","Config"],tempchan);
        		llSetTimerEvent(120);
        	} else {
        		lstMsg = str;
        		translateKey = llHTTPRequest("http://ajax.googleapis.com/ajax/services/language/translate?v=1.0&langpair=" + fromLang + "|" + toLang + "&q=" + process(str), [HTTP_METHOD, "GET", HTTP_MIMETYPE, "application/x-www-form-urlencoded"], "");
        	}
		}
	}
	
    listen( integer chan, string name, key id, string msg) {
        if (chan == tempchan) {
            if (msg == "> Next >") {
                listLanguages("next");
            } else if (msg == "< Prev <") {
                listLanguages("prev");
            } else if (msg == "From") {
                fromLang = temp;
                llOwnerSay("I will now expect that you speak to me in " + getLangNa(fromLang));
            } else if (msg == "To") {
                toLang = temp;
                llOwnerSay("I will now translate into " + getLangNa(toLang));
            } else if (msg == "- Cancel -") {
                temp = "";
                offset = 0;
                llSetTimerEvent(0.1);
            } else if (msg == "Activate") {
            	llOwnerSay("The translator is now active. Remember it is using a public channel listen, which will generate lag for you, and everyone around you, please use it wisely and only have it active when needed. To deactivate the translator, use /9trans");
            	public_listen = llListen(0,"", "","");
            } else if (msg == "Deactivate") {
            	llOwnerSay("The translator is now deactivated. Thank you for being a good neighbor by reducing lag.");
            	llListenRemove(public_listen);
            } else if (msg == "Config") {
            	listLanguages("go");
            } else if (msg == "Me") {
            	if (transSelf) {
            		transSelf = FALSE;
            	} else {
            		transSelf = TRUE;
            	}
            	llDialog(llGetOwner(),"\nCurrent settings:\nFrom: " + getLangNa(fromLang) + "\nTo: " + getLangNa(toLang) + " (sim language)\n\n" + transWho(),["Me","Others","Both","Activate","Deactivate","Config"],tempchan);
        		llSetTimerEvent(120);
            } else if (msg == "Others") {
            	if (transOther) {
            		transOther = FALSE;
            	} else {
            		transOther = TRUE;
            	}
            	llDialog(llGetOwner(),"\nCurrent settings:\nFrom: " + getLangNa(fromLang) + "\nTo: " + getLangNa(toLang) + " (sim language)\n\n" + transWho(),["Me","Others","Both","Activate","Deactivate","Config"],tempchan);
        		llSetTimerEvent(120);
            } else if (msg == "Both") {
           		transOther = TRUE;
           		transSelf = TRUE;
            	llDialog(llGetOwner(),"\nCurrent settings:\nFrom: " + getLangNa(fromLang) + "\nTo: " + getLangNa(toLang) + " (sim language)\n\n" + transWho(),["Me","Others","Both","Activate","Deactivate","Config"],tempchan);
        		llSetTimerEvent(120);
            } else {
                findLang(msg);
            }
        } else if (chan == 0) {
			if (fromLang == toLang) {
				llListenRemove(public_listen); //Just to be fucking sure!
			}
			
        	if (!transOther && !transSelf) {
	        	llListenRemove(public_listen);
        		llOwnerSay("Translator deactivated, no translation options was activated.");
        	}
			
        	if (id != llGetOwner() && transOther) {
        		lstName = llKey2Name(id);
        		lstMsg = msg;
        		translateOther = llHTTPRequest("http://ajax.googleapis.com/ajax/services/language/translate?v=1.0&langpair=" + toLang + "|" + fromLang + "&q=" + process(msg), [HTTP_METHOD, "GET", HTTP_MIMETYPE, "application/x-www-form-urlencoded"], "");
        	} else if (id == llGetOwner() && transSelf) {
        		lstMsg = msg;
        		translateSelf = llHTTPRequest("http://ajax.googleapis.com/ajax/services/language/translate?v=1.0&langpair=" + fromLang + "|" + toLang + "&q=" + process(msg), [HTTP_METHOD, "GET", HTTP_MIMETYPE, "application/x-www-form-urlencoded"], "");
        	}
        }
    }
    
    http_response(key request_id, integer status, list metadata, string body) {
    	if (status == 200) {	
        	if (translateKey == request_id) {
            	string temp = llGetObjectName();
            	llSetObjectName(llKey2Name(llGetOwner()));
            	llSay(0, convert(body));
            	llOwnerSay(lstMsg);
            	llSleep(0.25);
            	llSetObjectName(temp);
            	lstMsg = "";
        	} else if (translateOther == request_id) {
        		if (llStringTrim(lstMsg, STRING_TRIM) != llStringTrim(convert(body), STRING_TRIM)) {
            		string temp = llGetObjectName();
            		llSetObjectName(lstName);
            		llOwnerSay(convert(body));
            		llSleep(0.25);
            		llSetObjectName(temp);
        		}
        	} else if (translateSelf == request_id) {
        		if (llStringTrim(lstMsg, STRING_TRIM) != llStringTrim(convert(body), STRING_TRIM)) {
            		string temp = llGetObjectName();
            		llSetObjectName(llKey2Name(llGetOwner()));
            		llSay(0, convert(body));
            		llSleep(0.25);
            		llSetObjectName(temp);
        		}
        	}
        } else {
        	if (translateSelf == request_id || translateOther == request_id || translateKey == request_id) llOwnerSay("Unable to translate.");
        }
    }
    
    timer() {
        llListenRemove(listen_handle);
        llSetTimerEvent(0);
        if (!transOther && !transSelf) {
        	llListenRemove(public_listen);
        	llOwnerSay("Translator deactivated, no translation options was activated.");
        }
    }
	
    changed(integer f_Changed) {
        if (f_Changed & CHANGED_OWNER) {
            llResetScript(); // Reset so next owner wont get old stats
        }  
    }
}