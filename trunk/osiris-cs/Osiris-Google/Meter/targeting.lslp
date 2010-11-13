list people;
list peoplenames;
integer targetFlag;
integer skillToTargetFlag;
key me;
string myName;
key target;
string tempcmd;
integer listTime;
integer templistener;


// CHALLENGE/AUTHENTICATION
string secureKey="blah";
string securePass;
string myKey="more blah";
createSecurePass()
{
  securePass="something";   
}
string cryptPass (string str)
{
    return llXorBase64StringsCorrect(llStringToBase64(str), llStringToBase64(securePass));
}
string decryptPass (string str)
{
    return llBase64ToString(llXorBase64StringsCorrect(str, llStringToBase64(securePass)));
}
string randCheck;
setRandCheck()
{
    randCheck=(string)llFrand(9999999999.0)+ (string)llFrand(9999999999.0);
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
            string response="targeting|"+ randCheck + "||" + myKey;
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
integer like(string value,string mask){
    integer tmpy = ((llGetSubString(mask,0,0) == "%") | ((llGetSubString(mask,(-1),(-1)) == "%") << 1));
    if (tmpy) (mask = llDeleteSubString(mask,(tmpy / (-2)),(-(tmpy == 2))));
    integer tmpx = llSubStringIndex(value,mask);
    if ((~tmpx)) {
        integer diff = (llStringLength(value) - llStringLength(mask));
        return (((((!tmpy) && (!diff)) || ((tmpy == 1) && (tmpx == diff))) || ((tmpy == 2) && (!tmpx))) || (tmpy == 3));
    }
    return FALSE;
}
clearpeople() {
	people = [];
	peoplenames = [];
}
checkPeople(key n){
	llSensor("",NULL_KEY,AGENT,30.0,PI);
    string name;
    if (llStringLength(llKey2Name(n)) > 23) {
        name = llGetSubString(llKey2Name(n),0,23);
    } else {
        name = llKey2Name(n);
    }
    people += [n];
    peoplenames += [name];
}
setTargetByName(string n){
	llSensor("",NULL_KEY,AGENT,30.0,PI);
	llSleep(0.5);
    target = NULL_KEY;
    integer l = llGetListLength(people);
    integer x;
    if (llToLower(n) == "self") {
        target = me;
    } else {
        while (x < l) {
            if (like(llToLower(llKey2Name(llList2String(people,x))),llToLower((n + "%")))) {
                (target = llList2String(people,x));
            }
            ++x;
        }
    }
    if (target) {
        llMessageLinked(LINK_THIS,9950,"TARGET",target);
    } else {
        llOwnerSay("Unable to set target name: " + n);
    }
}
setTarget() {
    list menulist = peoplenames;
    if (llGetListLength(peoplenames) > 12) {
        menulist = llDeleteSubList(peoplenames,12,llGetListLength(peoplenames));
    }
    llDialog(me,"\nPlease select your target:",menulist,-94832638);
}
setTargetName(string n){
	llSensor("",NULL_KEY,AGENT,30.0,PI);
	llSleep(0.5);
	if (llToLower(n) == llToLower("self")) {
        llMessageLinked(LINK_THIS,9950,"TARGET",me);
        target = me;
    } else {
    	integer l = llGetListLength(people);
    	integer x;
    	while ((x < l)) {
	        if ((llKey2Name(llList2String(people,x)) == n)) {
            	(target = llList2String(people,x));
        	}
        	++x;
    	}
    	if (target) {
	        llMessageLinked(LINK_THIS,9950,"TARGET",target); //9950 - Commands passed by the player
	    }
	}
}

default {
    state_entry() {
        me=llGetOwner();
        myName=llKey2Name(me);
    }
    link_message(integer sender_num, integer num, string str, key id) { 
		if (num==8000) {
			receiveChallenge(str);
		}
		else if (num==4000) {
			templistener=llListen(-94832638,"",me,"");
		    targetFlag=1;
            llSensor("",NULL_KEY,AGENT,30.0,PI);
		}
		else if (num==4001) {
			skillToTargetFlag=1; llSensor("",NULL_KEY,AGENT,30.0,PI); tempcmd=str;	
		}
		else if (num==4002) {
			setTargetByName(str);	
		}
    }
    listen(integer channel,string name,key id,string message) { 
    	if (channel == -94832638 && id == me) {
        	llSensor("",NULL_KEY,AGENT,45.0,PI);
        	llSleep(0.5);
            if (~llListFindList(peoplenames,[message])) setTargetName(message);
            llListenRemove(templistener);
        }
    }
    sensor(integer num_detected) {
    	if (skillToTargetFlag==0) {
	    	listTime = llGetUnixTime();
	        clearpeople();
	        integer x;
	        while (x < num_detected) {
	            checkPeople(llDetectedKey(x));
	            ++x;
	        }
	        peoplenames += "SELF";
	        if (targetFlag==1) {
	        	targetFlag=0;
	        	setTarget();
	        }
    	} else if (skillToTargetFlag==1) {
    		listTime = llGetUnixTime();
	        clearpeople();
	        integer x;
	        while (x < num_detected) {
	            checkPeople(llDetectedKey(x));
	            ++x;
	        }
    		string cmd = left(tempcmd," ");
			string name = right(tempcmd," ");
			key newtarget;
		    if (llToLower(name) == "self") {
		        newtarget=me;
		    } else {
		        integer l = llGetListLength(people);
		        x=0;
		        while ((x < l)) {
		            if (like(llToLower(llKey2Name(llList2String(people,x))),llToLower((name + "%")))) {
		                (newtarget = llList2String(people,x));
		            }
		            ++x;
		        }
		    }
		    if (newtarget) {
		        llMessageLinked(LINK_THIS,9950,cmd,newtarget);
		    } else {
		        llOwnerSay(("Unable to set target name " + name));
		    }
		    skillToTargetFlag=0;
		    tempcmd="";
		    clearpeople();
    	}
    }
    no_sensor() {
    	if (skillToTargetFlag==0) {
	        clearpeople();
	        peoplenames += "SELF";
			if (targetFlag==1) {
	        	targetFlag=0;        
	        	setTarget();
			}
    	}
		else if (skillToTargetFlag==1) {
			clearpeople();
			if (llToLower(right(tempcmd," ")) == "self") {
				llMessageLinked(LINK_THIS,9950,left(tempcmd," "),me);
			}
			skillToTargetFlag=0;	
		}
    }
}
