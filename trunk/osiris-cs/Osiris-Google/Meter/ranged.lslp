integer rangedDamage;
float rangedrate;
integer status=1;
integer dam_vel=10;
key 	owner;
integer lastbulletannouncement; // this is the time we got the last announcement of an enhanced ranged weapon
list bullets; // this is the list of enhanced bullet names in the area
integer blockRanged; // if this is set to 1, disable extra damage from enhanced bullets


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
    return (string)llFrand(9999999999.0)+ (string)llFrand(9999999999.0);
}
receiveChallenge(string msg) {
    createSecurePass(); 
    string message=decryptPass(msg);
    string source=left(message, "|");
    string sourceKey=right(message, "||");
    securePass=right(left(message,"||"),"|"); // this line changes the initial password to the one received from security
    if (source=="security" && sourceKey==secureKey) {
		string response="ranged|"+ randCheck() + "||" + myKey; // randCheck() sets a random string of numbers in the middle of the message to jump things up
		llMessageLinked(LINK_THIS, 8001, cryptPass(response), NULL_KEY);   
	}
}
setRangedDamage(integer amount) {// set ranged damage
    rangedDamage=amount;   
}
setRangedRate(float sec) { //set range rate
    rangedrate=sec;   
}
setStatus(integer stat) {
    status=stat;   
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
    state_entry() {
    	owner = llGetOwner();
    	setStatus(1);    
    }
    collision_start(integer num_detected) {
        //llOwnerSay("Got collision: " + (string)llVecMag(llDetectedVel(0)));
        if (llDetectedType(0) & SCRIPTED && llVecMag(llDetectedVel(0)) >= dam_vel) {
            if (status==1) {
                key shooter=llDetectedOwner(0);
                if (shooter != owner) {
                	status=0;
                	integer dmg=rangedDamage;
                	if (~llListFindList(bullets, [llDetectedName(0)])) {dmg=dmg+2;} // if bullet name is found on the list of enhanced bullets, add + 2 dmg
                	//llOwnerSay((string)dmg);
                	llMessageLinked(LINK_THIS, 9996,(string)dmg,shooter); //9996 - ranged fighting system announcements
                	llMessageLinked(LINK_THIS, 9910,"",shooter); //9910 - announces last person who hit me
                	llMessageLinked(LINK_THIS, 9920, "",NULL_KEY); // Sending only null_key to channel 9920?? this signals API to tick RAGE type special up by 1
					llSetTimerEvent(rangedrate);
                }
            }   
        }
    }
    link_message(integer sender_num, integer num, string str, key id) {
        if (num==1) { //input is coming from dataloader on chan 1
            if (left(str, "|") == "RANGED") {
               integer dmg=(integer)right(str,"|");
               setRangedDamage(dmg); 
            } else if (left(str, "|") == "RANGEDRATE") {
                float rate=(float)right(str,"|");
                setRangedRate(rate);
            } else if (left(str, "|")=="BLOCKAPI") {
	        	list blockAPI=llCSV2List(right(str,"|"));
	        	if (llListFindList(blockAPI, ["R"]) != -1) {
	    				blockRanged=1;
	    				
		    	}
	        }
        } else if (num==8000) {
        	receiveChallenge(str);
        } else if (num==7503 && blockRanged==0) {	
        	if (llGetListLength(bullets) < 20) {
        		if (llListFindList(bullets, [str]) == -1) {
		        	bullets=bullets+[str];
		        	//llOwnerSay(llList2CSV(bullets));
        		}
        	}	
        }
    }
    timer() {
        status=1;
        llSetTimerEvent(0.0);
    }
}