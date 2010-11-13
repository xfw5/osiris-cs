integer     listenHandle;
integer     activityTime; //Last time the script recieved a new key
integer     lastActivity; //Last key pressed
integer     dialogTime; //The time the dialog got activated
integer     status; //0 = rpcs running, 1 = waiting for dialog reply, 2 = user inactive, 3 = anticamp deactivated
integer		baseStatus; //What was the setting on the server
integer     antiCamp; //How many secs the user is allowed to be inactive
float       timeOut; //Timeout in seconds after the dialog is activated
string      timeOutType = "minutes"; //Just cosmetic, to show if its ex 2 minutes, or 1 minute in the timeout


////// AUTHENTICATION JUNK ////////////////
// CHALLENGE/AUTHENTICATION
string secureKey="something";
string securePass;
string myKey="something else";
createSecurePass() {
  securePass="another something";   
}
string cryptPass (string str) {
    return llXorBase64StringsCorrect(llStringToBase64(str), llStringToBase64(securePass));
}
string decryptPass (string str) {
    return llBase64ToString(llXorBase64StringsCorrect(str, llStringToBase64(securePass)));
}
receiveChallenge(string msg) {
    createSecurePass();
    setRandCheck(); // sets a random string of numbers in the middle of the message to jump things up
    string message=decryptPass(msg);
    string source=left(message, "|");
    string sourceKey=right(message, "||");
    securePass=right(left(message,"||"),"|"); // this line changes the initial password to the one received from security
    if (source=="security" && sourceKey==secureKey) {
    	string response="anticamp|"+ randCheck + "||" + myKey;
    	llMessageLinked(LINK_THIS, 8001, cryptPass(response), NULL_KEY);   
    }
}
string randCheck;
setRandCheck() {
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
/////////////////////////////// END AUTHENTICATION ////////////////
sendDialog(integer num) { //Calls to set the status, generates a random negative channel for the dialog, sets the time for when the dialog is opened, opens the dialog
    setStatus(num);
    dialogTime = llGetUnixTime();
    integer tempchan = (integer)(-1*llFrand(2147483645));
    listenHandle = llListen(tempchan,"", llGetOwner(),"");
    llDialog(llGetOwner(), "AntiCamp Activated\n\nInactivity time allowed in this sim is " + (string)(antiCamp/60) + " minutes, you have " + (string)llRound(timeOut/60) + " " + timeOutType + " to reply.\n\n\n       ► Anticamp active, please select 'Active' ◄", llListRandomize(["Active","Inactive","Inactive"], 0), tempchan);
}
setStatus(integer num) { //0 = rpcs running, 1 = waiting for dialog reply, 2 = user inactive, 3 = anticamp deactivated
    status = num;
    if (num == 0 && baseStatus == 1) {
    	llRequestPermissions(llGetOwner(), PERMISSION_TAKE_CONTROLS); //We need to check the controls
    }
}
setTimeOut(integer secs) {
	if (baseStatus == 1) {
		antiCamp = secs*60;
		if (antiCamp < 120) { //2 mins is the shortest timeout avalible, or timeout on the menu will be the same as the inavtivity timeout
	    	antiCamp = 120;
	    }
	    timeOut = (antiCamp/3); //Find 1/3 of the allowed inactivity time
	    if (timeOut > 300) {
    		timeOut = 300;
    	} else if (timeOut <= 60) { //If its less than one minute, bump it up
	    	timeOut = 60;
    		timeOutType = "minute"; //To show '1 minute' instead of '1 minutes' in the dialog
    	}
    	llOwnerSay("AntiCamp is activated in this sim, allowed inactive time is set to " + (string)(antiCamp/60) + " minutes.");
    	llSetTimerEvent(10); //Set timer to check the integers
    } else {
    	llSetTimerEvent(0); //Just to check again if its messed up somewhere, or if santaclaus gave us a 1 instead of 0
	}
}
default {
    run_time_permissions(integer perm) {
    	if ((status == 0 || status == 1) && baseStatus == 1) {
        	if(PERMISSION_TAKE_CONTROLS & perm) { //Take all the controls if we can
	            llTakeControls(CONTROL_FWD | CONTROL_BACK | CONTROL_LEFT | CONTROL_RIGHT | CONTROL_ROT_LEFT | CONTROL_ROT_RIGHT | CONTROL_UP | CONTROL_DOWN | CONTROL_LBUTTON | CONTROL_ML_LBUTTON, TRUE, TRUE);
        	}
    	}
    }
    control(key id, integer level, integer edge) {
    	if (baseStatus == 1) {
        	if (level != lastActivity && status == 0 && level != 0) { //Checking if the key pressed is the last as the previous, status need to be running, and the key must not be 0
	            lastActivity = level; //We got a new keystroke
            	activityTime = llGetUnixTime(); //We got a new keystroke, mark the time
        	} else if (level != lastActivity && status == 1 && level != 0) { //User got back, lets close the listen, set a new activity time, and return to running statys
	            llListenRemove(listenHandle);
            	lastActivity = level;//We got a new keystroke
            	activityTime = llGetUnixTime(); //We got a new keystroke, mark the time
        	} else if (level != lastActivity && status == 2 && level != 0) { //User got back after rpcs got deactivated, lets start it again
            	setStatus(0);
            	activityTime = llGetUnixTime();
            	llSetTimerEvent(10); //Start looking for the timers again
            	llMessageLinked(LINK_SET,8,"0",NULL_KEY); //Change dataloader status to 0
        	}
        }
        llSleep(0.5); //Throttle to not lag too much
    }
    link_message(integer source, integer num, string str, key id) { //Get the config, not done yet...
    	string cmd = left(str, "|");
    	string msg = right(str, "|");
        if (num == 1 && cmd == "ANTICAMP") {
        	if (msg == "1") { //Anticamp on
        		activityTime = llGetUnixTime(); //Set the time for first activity
        		baseStatus = 1; //AntiCamp is activated
        		setStatus(0); //Set the anticamp to running status
        	} else if (msg == "0") { //Anticamp off
        		baseStatus = 0;
        		llSetTimerEvent(0); //No reason to have the timer running
        		setStatus(3); //Set the anticamp to deactivated status
        	}
        } else if (num == 1 && cmd == "CAMPTIMER") {
        	setTimeOut((integer)msg);
        } else if (num == 1150 && cmd == "ANTICAMP" && msg == "0") {
        	setStatus(2); //User activated AFK state, set the anticamp to user inactive status
        	llSetTimerEvent(0);
        } else if (num == 1150 && cmd == "ANTICAMP" && msg == "1" && baseStatus == 1) { //If RPCS is turned on, and the anticamp is activated for this sim, then start it up
        	if (lastActivity != 66545618) { //Checking if its just a macro using a gesture to trigger /9on
        		lastActivity = 66545618;
        		activityTime = llGetUnixTime(); //Set the time for activity
        		llSetTimerEvent(10); //Start looking for the timers again
        	}
        	setStatus(0); //Set the anticamp to running status
        } else if (num == 1150 && cmd == "ANTICAMP" && msg == "3" && baseStatus == 1) { //If RPCS is put into afk mode, stop the anticamp
        	setStatus(3); //Set the anticamp to disabeled so it wont activate on movement
        	llSetTimerEvent(0);
        }
        else if (num==8000) {
        	receiveChallenge(str);
        } 
    }
    listen(integer chan, string name, key id, string message) {
        message = llToLower(message);
        if (message == "active") { //User is here, and pressed the Active button in the dialog
            activityTime = llGetUnixTime(); //Got the right reponse, set a new activity time
            setStatus(0); //User responded, go back to running status
            llOwnerSay("Timer reset.");
        } else if (message == "inactive") { //User hit one of the wrong buttons, maybe a macro?
            setStatus(2); //Wrong button, deactivate RPCS
            llMessageLinked(LINK_SET,8,"98",NULL_KEY); //Change dataloader status to 98
        }
        llListenRemove(listenHandle); //Close the listen, a option was selected
    }
    timer() {
        if (status == 2) { //Just to make sure to shut down and wait for a new input from keys or linked message
            llSetTimerEvent(0);
            llListenRemove(listenHandle);
        } else {
            if ((llGetUnixTime() - activityTime) >= (antiCamp-timeOut) && status == 0) { //Timer reached 1/3 of antiCamp, and status is 0 (running)
                sendDialog(1); //Send the dialog and set status to 1 (waiting for dialog input)
            }
            if ((llGetUnixTime() - dialogTime) >= (llRound(timeOut/60)*60) && status == 1) { //If timeOut is reached, shut down and wait for a new input from keys or linked message
            	if ((llGetUnixTime() - activityTime) >= timeOut) {
	               	llSetTimerEvent(0);
                	llListenRemove(listenHandle);
                	setStatus(2); //Set status to 2 (user inactive)
                	llMessageLinked(LINK_SET,8,"98",NULL_KEY); //Change dataloader status to 98
            	} else {
            		activityTime = llGetUnixTime(); //User moved while the dialog was open, so set a new time
            		setStatus(0); //Change the status back to running so the dialog can be triggered again
            		llListenRemove(listenHandle); //Close the listen, dialog is expired
            	}
            }
        }
    }
    attach(key id) {
        if(id) {
        	activityTime = llGetUnixTime(); //Setting a time for when we logged on
        	llSetTimerEvent(10); //Just making sure its running
        }
    }
}