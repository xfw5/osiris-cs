string pwdurl="";
key http_password_request;

// security stuff
// **************************************************

// CHALLENGE/AUTHENTICATION
string secureKey="";
string securePass;
string myKey="";
createSecurePass() {
  securePass="";   
}
string cryptPass (string str) {
    return llXorBase64StringsCorrect(llStringToBase64(str), llStringToBase64(securePass));
}
string decryptPass (string str) {
    return llBase64ToString(llXorBase64StringsCorrect(str, llStringToBase64(securePass)));
}
string randCheck() {
    return (string)llFrand(9999999999.0)+(string)llFrand(9999999999.0);
}
receiveChallenge(string msg) {
    createSecurePass();
    string message=decryptPass(msg);
    string source=left(message, "|");
    string sourceKey=right(message, "||");
    securePass=right(left(message,"||"),"|"); // this line changes the initial password to the one received from security
    if (source=="security" && sourceKey==secureKey) {
		string response="password|"+ randCheck() + "||" + myKey; // randCheck(); sets a random string of numbers in the middle of the message to jump things up
        llMessageLinked(LINK_THIS, 8001, cryptPass(response), NULL_KEY);   
	}
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

default {
    link_message(integer sender_num, integer num, string str, key id) {
        if (num==2 & id==llGetOwner()) { // because this script only listens to chan 2
			http_password_request=llHTTPRequest(pwdurl,[],"");
            llOwnerSay("Requesting a new password from the server.");   
        } else if (num==8000) { //8000 - challenge/authentication
        	receiveChallenge(str);
        } 
    }
    http_response(key request_id, integer status, list metadata, string body) {
        if (request_id==http_password_request) {
             llOwnerSay("Your new password is " + body + ". You can change this password and modify your character at http://www.rpcombat.com");
             llResetScript();
        }   
    }
}
