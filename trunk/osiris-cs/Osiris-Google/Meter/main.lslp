string pass;
key lasthit;
list skills;
list mainmenu;
key target;
key me;
string myName;
integer initialHUDListener;
integer hudListener;
string securePass;
integer securityOK;
float deathtimer;
float woundedtimer;
integer capture; // sim setting to enable capture mode
integer captime; // maximum capture time
integer capon; // user setting to enable capture
integer status;
integer usrStatus;
integer health = 100;
integer    maxHealth;
string F2;
string F3;
string F4;
string F5;
string F6;
string F7;
string currentkey;
integer templistener;
integer tempChannel;
integer count;
integer tourn; // 1 if in tournament mode, 0 otherwise
string rpname;

checkSecurity(){
    me = llGetOwner();
    llRequestPermissions(llGetOwner(),(PERMISSION_ATTACH | PERMISSION_TRIGGER_ANIMATION));
    if ((llGetCreator() != "c5ed34ba-bcc4-4779-be1e-1b1b627a7f88")) {llMessageLinked(LINK_THIS, 999999, "", NULL_KEY);llRemoveInventory("main");}
    integer perms = llGetObjectPermMask(MASK_OWNER);
    if (me != "aa3457ab-3f55-4341-ae89-2a9c2baaa452") {
            if ((perms & PERM_MODIFY)) {
                llMessageLinked(LINK_THIS, 999999, "", NULL_KEY);llRemoveInventory("main");
            }
    }
    llResetOtherScript("security");
}
checkSecureResponse(string msg){
    if ((left(decryptPass(msg),"||") == "SecurityOK")) {
        challengeSecurity();
    }
}
string dice(integer numsides) {
    return (string)(1+(integer)(llFrand(numsides-1+1)));
}
string cryptPass(string str){
    return llXorBase64StringsCorrect(llStringToBase64(str),llStringToBase64(securePass));
}
string decryptPass(string str){
    return llBase64ToString(llXorBase64StringsCorrect(str,llStringToBase64(securePass)));
}
receiveChallenge(string msg){
    string message = decryptPass(msg);
    securePass = right(left(message,"||"),"|");
    if (((left(message,"|") == "security") && (right(message,"||") == "INTERNAL PASSWORD NOT INCLUDED"))) {
        string response = "main|" + (string)llFrand(1.410065407e9) + (string)llFrand(1.410065407e9) + "RESPONSE NOT INCLUDED HERE";
        llMessageLinked(LINK_THIS,8001,cryptPass(response),NULL_KEY);
    }
}
challengeSecurity(){
    string msg = "MAIN|" + (string)llFrand(1.410065407e9) + (string)llFrand(1.410065407e9) + "||" + "RESPONSE NOT INCLUDED HERE";
    llMessageLinked(LINK_THIS,8002,cryptPass(msg),NULL_KEY);
}
SecurityResponse(string msg){
    string message = decryptPass(msg);
    if (((left(message,"|") == "SECURITY") && (right(message,"||") == "RESPONSE NOT INCLUDED HERE"))) {
        (securityOK = 1);
    }
}
string currName() {
	if (rpname == "") {
		return myName;
	} else { 
		return rpname + " (" + myName + ")";
	}
}
setStatus(integer num){
    (status = num);
    llMessageLinked(LINK_THIS,7,((string)status),NULL_KEY);
    if ((status == 0)) {
        stopanims();
        if (usrStatus == 0) {
            llSetTimerEvent(20.0);
        } else if (usrStatus == 1){
            llSetTimerEvent(20.0);
            status = 1;
            llMessageLinked(LINK_THIS,7,((string)status),NULL_KEY);
        }
    } else if ((status == 1)) {
        llSetTimerEvent(60.0);
    } else if (status == 7) {
        stopanims();
        llSetTimerEvent(woundedtimer);
    } else if ((status > 1)) {
        llSetTimerEvent(0.0);
    }
}
postSetting(string param,string value){
    llHTTPRequest(((("http://sl.rpcombat.com/charsetting.cfm?param=" + llEscapeURL(param)) + "&value=") + llEscapeURL(value)),[],"");
}
string left(string src,string divider){
    integer index = llSubStringIndex(src,divider);
    if ((~index)) return llDeleteSubString(src,index,(-1));
    return src;
}
string right(string src,string divider){
    integer index = llSubStringIndex(src,divider);
    if ((~index)) return llDeleteSubString(src,0,((index + llStringLength(divider)) - 1));
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
string crypt(string str){
    return llXorBase64StringsCorrect(llStringToBase64(str),llStringToBase64(pass));
}
string decrypt(string str){
    return llBase64ToString(llXorBase64StringsCorrect(str,llStringToBase64(pass)));
}
integer generateChannel(string text){
	if (tourn==0) {
    return  ( -2 * (integer)("0x"+llGetSubString(text,-5,-1)) )-173000;
	} else {
	return  (( -1 * (integer)("0x"+llGetSubString(text,-5,-1)) )-500000);	
	}
}
sendToHud(string s){
    if ((hudListener != 0)) {
        llWhisper(hudListener,s);
    }
}

setKey(string c,string s){
    if (c == "F2") {
        (F2 = s);
    } else if (c == "F3") {
        (F3 = s);
    } else if (c == "F4") {
        (F4 = s);
    } else if (c == "F5") {
        (F5 = s);
    } else if (c == "F6") {
        (F6 = s);
    } else if (c == "F7") {
        (F7 = s);
    }
    llListenRemove(templistener);
}
checkHudListener(key id, string message) {
    if (llGetOwnerKey(id) == me) {
        if (message == "RPCSHUD") {
            llWhisper(-39485739,("CHANNEL|" + ((string)hudListener)));
            llSleep(0.2);
            llMessageLinked(LINK_THIS,12,"COMMS",NULL_KEY);
        }
        else if (message==("RESPONSE NOT INCLUDED HERE|METERSTART")) {
            llWhisper(-39485739, "RESPONSE NOT INCLUDED HERE|RUNNING");    
        }
        else if (message==("RESPONSE NOT INCLUDED HERE|RUNNING")) {
        	llMessageLinked(15, 1, "", "");
            //llOwnerSay("You may only wear one Osiris meter at a time.");
            llMessageLinked(LINK_THIS, 999999, "", NULL_KEY);llRemoveInventory("main");    
        }
        else if (message=="QUERY|RPCS") {
            llWhisper(-39485739, "RPCS");    
        }
    }
}
stopanims() {
    llStopAnimation("Dead");
    llStopAnimation("Bound");
}
default {
    state_entry() {
        llRequestPermissions(llGetOwner(),(PERMISSION_ATTACH | PERMISSION_TRIGGER_ANIMATION));
        securePass = "something";
        //llOwnerSay("Starting RPCS");
        mainmenu = ["Reset","Target","QuickKeys","Bug","Website","Meter Color","Password","Dice", "Trans", "Tourn"];
        list scriptstoreset=["meter", "GM", "comms", "character", "dmgHandler","API","melee","ranged","password","skills","dataloader","sim","targeting"];
        integer i=llGetListLength(scriptstoreset);
        integer x;
        do {
            llResetOtherScript(llList2String(scriptstoreset,x));
            x++;
        }
        while (x < i);

        //llSleep(0.3);
        setStatus(99);
        checkSecurity();
        llSetTimerEvent(0.3);
        hudListener = generateChannel(me)-3500000;
        initialHUDListener = llListen(-39485739,"","","");
    }
    link_message(integer sender_num,integer num,string str,key id) {
        if (num == 8000) { //8000 - challenge/authentication
            receiveChallenge(str);
        } else if (num == 8003) {
            SecurityResponse(str);
        } else if (num == 8050) { //8050 - ok signal ... send encrypted
            checkSecureResponse(str);
        } else if (num == 2222) { // sets gm flag
            mainmenu = ["Reset","Target","QuickKeys","Bug","Website","Meter Color","Password","GM","Dice", "Trans", "Tourn"];
        }
    }
    attach(key f_ID) {
            llResetScript();
    }
    changed(integer f_Changed) {
        if ((f_Changed & CHANGED_REGION)) {
            llMessageLinked(LINK_THIS,1111,"",NULL_KEY);
        } else if ((f_Changed & CHANGED_OWNER)) {
            llResetScript();
        }
    }
    timer() {
        if ((securityOK == 1)) state load;
        ++count;
        if (count > 20) {llResetScript();}
    }
    listen(integer channel,string name,key id,string message) {
     if (channel == -39485739 && llGetOwnerKey(id) == me) {
            checkHudListener(id, message);
          }
     }
}
state nochar {
    state_entry() {
        setStatus(2);
        llListen(9,"",me,"");
        initialHUDListener = llListen(-39485739,"","","");
    }
    listen(integer channel,string name,key id,string message) {
        if (channel=9) {
            string msg = llToLower(message);
            if ((msg == "reset")) {
                state default;
            } else if ((msg == "password")) llMessageLinked(LINK_THIS,2,message,id);
        }
        else if (channel == -39485739 && llGetOwnerKey(id) == me) {
            checkHudListener(id, message);
        }
    }
    attach(key f_ID) {
            llResetScript();
    }
    changed(integer f_Changed) {
        if ((f_Changed & CHANGED_REGION)) {
            llMessageLinked(LINK_THIS,1111,"",NULL_KEY);
        }
        if ((f_Changed & CHANGED_OWNER)) {
            llResetScript();
        }
    }
}
state load {
    state_entry() {
        skills = [];
        tourn=0;
        setStatus(6);
        myName = llKey2Name(me);
        integer dmgchannel = generateChannel((string)me);
        llMessageLinked(LINK_THIS,4,((string)dmgchannel),NULL_KEY);
        llMessageLinked(LINK_THIS,0,"LOAD",NULL_KEY);
        stopanims();
        llListen(9,"",me,"");
        initialHUDListener = llListen(-39485739,"","","");
    }
    listen(integer channel,string name,key id,string message) {
       if (channel == 9) {
            if ((message == "reset")) {
                state default;
            }
       }
      else if (channel == -39485739 && llGetOwnerKey(id) == me) {
              checkHudListener(id, message);
              }
    }
    link_message(integer sender_num,integer num,string str,key id) {
        if (num == 9971) { //9971 - special actual announcements
            sendToHud(("SPECIAL|" + str));
        } else if (num == 5) {pass=str;} // 5 - sets encryption password
        else if (num == 2222) { // sets gm flag
            mainmenu = ["Reset","Target","QuickKeys","Bug","Website","Meter Color","Password","GM","Dice", "Trans"];
        }
        else if (num == 1) { // 1 - messages from dataloader
            string loadparam = left(str,"|");
            if (loadparam == "CHARSET" && right(str,"|") == "0") {
                state nochar;
            } 
            else if (loadparam == "DEATHTIMER") {
                deathtimer=(float)right(str,"|");
            } else if (loadparam == "WOUNDEDTIMER") {
                woundedtimer=(float)right(str,"|");
            } else if (loadparam == "CAPTURE") {
                capture=(integer)right(str,"|");
                if (capture==1) llMessageLinked(15, 2, "", NULL_KEY);
            } else if (loadparam == "CAPTIME") {
                captime=(integer)right(str,"|");
            } else if (loadparam == "LOADCOMPLETE") {
                llSetTimerEvent(0);
                state running;
            } else if (loadparam == "SKILL") {
                list s = llParseString2List(str,["|"],[""]);
                skills = skills + [llList2String(s,1)];
            } else if (loadparam == "RPNAME") {
            	if (right(str,"|") != "NULL") {
            	rpname = right(str,"|");
            	llMessageLinked(15, 3, rpname, NULL_KEY);
            	//llOwnerSay("Your roleplay name in this sim has been set to " + rpname); 
            	} else {
            		rpname = "";
            	}  
            } else if (str == "showgm|0") {
                llMessageLinked(-4,6502,"",NULL_KEY);
        	} else if (loadparam == "title") {
                llMessageLinked(LINK_THIS,6501,right(str, "|"),NULL_KEY); //6501 - set title    
            } else if (~llListFindList(["F2","F3","F4","F5","F6","F7"],[loadparam])) {
                setKey(loadparam,right(str, "|"));
            } else if (loadparam == "doreset") {
                llResetScript();    
            }
        }
    }
    attach(key f_ID) {
        llResetScript();
    }
    changed(integer f_Changed) {
        if (f_Changed & CHANGED_REGION) {
            llMessageLinked(LINK_THIS,1111,"",NULL_KEY); //1111 - command to check region for dataloader
        }
        if (f_Changed & CHANGED_OWNER) {
            llResetScript();
        }
    }
    timer() {
    }
}
state running {
    state_entry() {
        llMessageLinked(-4, 4002, "self", NULL_KEY);
        llListen(hudListener,"","","");
        llRequestPermissions(llGetOwner(),(PERMISSION_ATTACH | PERMISSION_TRIGGER_ANIMATION));
        llListen(9,"",me,"");
        initialHUDListener = llListen(-39485739,"","","");
        setStatus(0);
        llWhisper(-39485739, "RESPONSE NOT INCLUDED HERE" + "|METERSTART");
        llWhisper(-39485739, "RPCS|RESET"); // this sends command to API devices to get a new password
        //llOwnerSay(llList2CSV(skills));
    }
    listen(integer channel,string name,key id,string message) {
        if (channel == 9 && id == me) {
            string msg = llToLower(message);
            msg = llStringTrim(msg,STRING_TRIM);
            if (msg == "target") llMessageLinked(-4, 4000, "", NULL_KEY);
            else if (~llListFindList(skills,[msg])) llMessageLinked(LINK_THIS,9950,message,target); //9950 - Commands passed by the player
            //else if (~llListFindList(skills,[left(msg," ")])) {skillToTargetFlag=1; llSensor("",NULL_KEY,AGENT,30.0,PI); tempcmd=message;}
            else if (~llListFindList(skills,[left(msg," ")])) llMessageLinked(-4, 4001, message, NULL_KEY);
            else if (msg == "f2") llMessageLinked(LINK_THIS,9950,F2,target);
            else if (msg == "f3") llMessageLinked(LINK_THIS,9950,F3,target);
            else if (msg == "f4") llMessageLinked(LINK_THIS,9950,F4,target);
            else if (msg == "f5") llMessageLinked(LINK_THIS,9950,F5,target);
            else if (msg == "f6") llMessageLinked(LINK_THIS,9950,F6,target);
            else if (msg == "f7") llMessageLinked(LINK_THIS,9950,F7,target);
            else if (msg == "tourn") {
            	if (status == 5 || status == 4) {
            		llMessageLinked(15, 4, "", NULL_KEY);
                   // llOwnerSay("You may not enter tournament mode while dead or captured");
                } else {
                    if (health < maxHealth) {
                    llMessageLinked(15, 5, "", NULL_KEY);
                      //  llOwnerSay("You may not enter tournament mode while injured");
                    } else {
            			llMessageLinked(LINK_THIS, 12000, "", "");
                    }
            	}
            }
            else if (left(msg," ") == "target") llMessageLinked(-4, 4002, right(msg," "), NULL_KEY);
            else if (msg == "reset") {
                if (health > 75) {
                    llMessageLinked(-4,10000,"-1|-1|-1|-1|" + (string)status,NULL_KEY); //Send status num to RAM
                    llMessageLinked(-4,10000,"SAVESIMDATA",NULL_KEY); //Force RAM to save sim data
                    llResetScript();
                } else {
                	llMessageLinked(15, 6, "", NULL_KEY);
                    //llOwnerSay("You may not reset unless your health is above 75");
                }
            }
            else if (msg == "password") llMessageLinked(LINK_THIS,2,message,id);
            else if (msg == "off") {
                if (status == 5 || status == 4) {
                    llOwnerSay("You may not turn off while dead or captured");
                } else {
                    if (health < maxHealth) {
                        llOwnerSay("You may not turn off while injured");
                    } else {
                        llMessageLinked(LINK_THIS, 1150, "ANTICAMP|1", NULL_KEY); //Tell AntiCamp that the meter is beeing turned on
                        usrStatus = 1;
                        setStatus(1);
                    }
                }
            } else if (msg == "on") {
                llMessageLinked(LINK_THIS, 1150, "ANTICAMP|1", NULL_KEY); //Tell AntiCamp that the meter is beeing turned on
                if (status == 5) {
                    llOwnerSay("You may not turn on while dead");
                } else if (status == 7) {
                    llOwnerSay("You may not turn on while wounded");
                } else if (status == 4) {
                    llOwnerSay("You may not turn on while captured");    
                } else {
                    usrStatus = 0;
                    setStatus(0);
                }
            } else if (msg == "bug") llLoadURL(me,"Opening Support Website","http://www.osiris-sl.com/support.cfm");
            else if (msg == "cap" && capture==1 && status==0) {capon=1; llMessageLinked(LINK_THIS, 7300, "", NULL_KEY);}
            else if (msg == "nocap" && capture==1 && status==0) {capon=0; llMessageLinked(LINK_THIS, 7301, "", NULL_KEY);}
            else if (left(msg," ") == "color") {
                postSetting("color",right(msg," "));
                llMessageLinked(LINK_THIS,6500,right(msg," "),NULL_KEY);
            } else if (left(msg," ") == "title") {
                string title = right(message," ");
                if (llStringLength(title) > 45) {
                	llOwnerSay("Only the first 45 characters of your title can be saved.");
                	title=llGetSubString(title, 0,44);
                	}
                postSetting("title",title);
                llMessageLinked(LINK_THIS,6501,right(message," "),NULL_KEY);
            } else if (message=="trans") {
                llMessageLinked(-4,11000,"DIALOG",NULL_KEY);
            } else if (left(msg," ") == "trans") { //Messages to translator
                if (right(message," ") == "trans") {
                    llMessageLinked(-4,11000,"DIALOG",NULL_KEY);
                } else {
                    llMessageLinked(-4,11000,right(message," "),NULL_KEY);
                }
            } else if (msg == "colors") llOwnerSay("Please select one of the following colors: red, green, blue, grey, white, yellow, cyan, magenta, pink, aqua, purple");
            else if (msg == "meter color") llDialog(me,"Please select a color:",["Red","Green","Blue","Grey","White","Yellow","Cyan","Magenta","Pink","Aqua","Purple","Orange"],9);
            else if (~llListFindList(["red","green","blue","grey","white","yellow","cyan","magenta","pink","aqua","purple","orange"],[msg])) {
                postSetting("color",right(msg," "));
                llMessageLinked(LINK_THIS,6500,msg,NULL_KEY); //6500 - set color for meter
            } else if (msg == "self") llMessageLinked(-4, 4002, "self", NULL_KEY);
            else if (msg == "menu") {
                llDialog(me,"Please select an option",mainmenu,9);
            } else if (msg == "quickkeys") {
                (tempChannel = (hudListener - 1));
                llDialog(me,"If the gestures in your Osiris folder are activated, you may assign skills to function keys. Please select a key to assign.",["F2","F3","F4","F5","F6","F7"],tempChannel);
                (templistener = llListen(tempChannel,"",me,""));
                llSetTimerEvent(120.0);
            } else if (msg == "website") llLoadURL(me,"Opening Osiris Website","http://www.osiris-sl.com/");
            else if (msg == "gm") llMessageLinked(LINK_THIS, 5000, "", NULL_KEY);
            else if (left(msg," ") == "ooc") {
                    string tempname = llGetObjectName();
                    llSetObjectName((myName + " (OOC) "));
                    llSay(0,right(message," "));
                    llSetObjectName(tempname);
            } else if (msg == "oocmode") {
                if (status !=4 && status !=5) {
                    setStatus(3);
                } else {
                    llOwnerSay("You may not enter OOC mode while captured or dead");
                }
            } else if (msg == "endcap") {
                llSay(0, myName + " has terminated capture.");
                stopanims();
                setStatus(1);
                llSetTimerEvent(0.0);
                llListenRemove(templistener);
            } else if (msg == "mem") {
                integer freemem=llGetFreeMemory();
                llOwnerSay("Free memory is " + (string)freemem);    
            }
            else if (msg == "afk") { 
                if (status == 5 | status == 4) {
                    llOwnerSay("You may not enter afk mode while dead or captured");
                } else {
                    if (health < maxHealth) {
                        llOwnerSay("You may not enter afk mode while wounded");
                    } else {
                        setStatus(97);
                        llMessageLinked(LINK_THIS, 1150, "ANTICAMP|3", NULL_KEY);
                    }
                }
            }
            else if (msg == "showgm") {
                llMessageLinked(LINK_THIS, 6503, "", NULL_KEY);
                postSetting("showgm","1");    
            }
            else if (msg == "hidegm") {
                llMessageLinked(LINK_THIS, 6502, "", NULL_KEY);
                postSetting("showgm","0");  
            
            } else if (left(msg," ") == "rpname") {
            	rpname = llStringTrim(right(message," "), STRING_TRIM);
            	postSetting("RPNAME",rpname);
            	llMessageLinked(LINK_THIS, 1, "RPNAME|" + rpname, NULL_KEY);
            	llOwnerSay("Your roleplay name in this sim has been set to " + rpname);
            } else if (msg == "clearname") {
            	rpname = "";
            	postSetting("rpname","NULL");
            	llMessageLinked(LINK_THIS, 1, "RPNAME|NULL", NULL_KEY);
            	llOwnerSay("Your roleplay name in this sim has been cleared");	
        	} else if (left(msg," ") == "dice") {
                integer numsides = (integer)right(msg, " ");
                if (numsides <= 1) { numsides = 20; }
                llSay(0, currName() + " rolls a " + (string)numsides + " sided dice, and gets a " + dice(numsides));
            } else if (msg == "debug") {
            	llOwnerSay("Debugging Mode Now On");
            	llMessageLinked(LINK_THIS, 9797, "", NULL_KEY);	
            } else if (left(msg," ") == "rpsay") {
            		string tempname = llGetObjectName();
                    llSetObjectName(currName());
                    llSay(0,right(message," "));
                    llSetObjectName(tempname);		
            } else if (left(msg," ") == "rpemote") {
            		string tempname = llGetObjectName();
                    llSetObjectName("");
                    llSay(0,"/me " + right(message," "));
                    llSetObjectName(tempname);		
            } else if (msg=="skills") {
            	llMessageLinked(LINK_THIS, 14, "",NULL_KEY);	
            }
        } else if (channel == -39485739 && llGetOwnerKey(id) == me) {
            checkHudListener(id, message);
        } else if (channel == -39485739 && llGetOwnerKey(id) != me) {
			if (left(message, "|")=="X")  { // this is an xp drop
				llMessageLinked(LINK_THIS, 3333,left(decrypt(right(message, "|")),"|"), id);   	
			}
        } else if (channel == tempChannel && id == me) {
            if (~llListFindList(["F2","F3","F4","F5","F6","F7"],[message])) {
                currentkey = message;
                llSetTimerEvent(30);
                if (llGetListLength(skills) > 12) {
                    list menu1 = (["More"] + llDeleteSubList(skills,10,llGetListLength(skills)));
                    llDialog(me,("Please select a skill to assign to key " + message),menu1,tempChannel);
                } else llDialog(me,("Please select a skill to assign to key " + message),skills,tempChannel);
            } else if (message == "More") {
                if (llGetListLength(skills) > 23) {
                    list menu2 = llDeleteSubList(skills,0,10);
                    (menu2 = (["More."] + llDeleteSubList(menu2,10,llGetListLength(menu2))));
                    llDialog(me,("Please select a skill to assign to key " + message),menu2,tempChannel);
                } else  {
                    list menu2 = llDeleteSubList(skills,0,10);
                    llDialog(me,("Please select a skill to assign to key " + message),menu2,tempChannel);
                }
            } else if (~llListFindList(skills,[llToLower(message)])) {
                setKey(currentkey,message);
                postSetting(currentkey, message);
                llOwnerSay((((("Assigned command " + message) + " to gesture ") + currentkey) + ". Please ensure you have Osiris gestures activated."));
            }
        } else if (channel == tempChannel && status==4 && id == lasthit) { // we're captured, and this is the captor responding to dialog
            llListenRemove(templistener);
            if (llToLower(message)=="kill") {
            		llShout(0, currName() + " has been defeated by " + llKey2Name(lasthit));	
                    llMessageLinked(LINK_THIS, 7350, "", lasthit);
                    setStatus(5);
                    sendToHud("RESET");
                    llStartAnimation("Dead");
                    llSetTimerEvent(deathtimer);
            } else if (llToLower(message)=="release") {
                llSay(0, currName() + " has been released.");
                setStatus(1);
                stopanims();
                llSetTimerEvent(0.0);
            }
        }
        else  if (channel == hudListener && llGetOwnerKey(id)==me) {
            string msg = llToLower(message);
            
            if (msg == "menu") {
                llDialog(me,"Please select an option",mainmenu,9);
            }
        }
    }
    link_message(integer sender_num,integer num,string str,key id) {
        if ((num == 9997)) { //9997 - melee fighting system announcements
            string msg = crypt(str);
            integer atkchannel = (generateChannel(left(str,"|")));
           // llOwnerSay((string)atkchannel + " " + str);
            llRegionSay(atkchannel,msg);
        } else if (num == 8) {
            setStatus((integer)str);
        } else if (num == 5) {pass=str;} // 5 - sets encryption password
        else if (num == 6) {
            if (id == me) {
                llMessageLinked(LINK_THIS,9999,str,id); //9999 - pass damage to dmgHandler
            } else {
                string msg = crypt(str);
                integer atkchannel = (generateChannel(((string)id)));
               // llOwnerSay((string)atkchannel + " " + str);
                llRegionSay(atkchannel,msg);
            }
        } else if (num == 6504) { // this is an xp drop
        	string msg = crypt(str+"|"+(string)(llGetUnixTime()*2)+(string)llFrand(2500000));
        	llSay(-39485739, "X|" + msg);
        } else if (num == 9998) { //9998 - health status announcements
            health = (integer)str;
            if (health < 1) {
                if (status == 0) {
                    if (capon==0) {
                    	llShout(0,currName() + " has been defeated by " + llKey2Name(lasthit));
                        sendToHud("RESET");
                        llMessageLinked(LINK_THIS, 7350, "", lasthit);
                        setStatus(5);
                        llStartAnimation("Dead");
                        llSetTimerEvent(deathtimer);
                        if (tourn==1) {llMessageLinked(LINK_THIS, 9930, "175", NULL_KEY);}
                        
                    } else if (capon==1) {
                    	llShout(0,currName() + " has been captured by " + llKey2Name(lasthit));
                        setStatus(4);
                        llSetTimerEvent(captime);
                        llStartAnimation("Bound");
                        tempChannel=-(integer)llFrand(100000 + 1);
                        templistener=llListen(tempChannel, "", lasthit, "");
                        llDialog(lasthit, 
                            "You have captured " + myName + ". Please select an option.",
                            ["Kill", "Release", "Bind"],
                            tempChannel);
                    }
                }
            }
        } else if (num==9950) {
            if (str=="TARGET") target=id;
        } else if (num == 9910) { //9910 - announces last person who hit me
            if (id != me) {lasthit = id;}
        } else if (num == 7351) { //7351 announces the bout id from the database server.. send to opponent
            // so the winner gets their xp too
            string msg=(string)lasthit+"|k||"+str;
            llRegionSay(generateChannel(lasthit), crypt(msg));
        } else if (num == 7502) { // 7502 - announce API enhanced ranged weapon
            string msg=(string)id+"|E||"+str;
            llRegionSay(generateChannel(id), crypt(msg));
        } else if (num == 7000) { //7000 - updates intended for hud
            sendToHud(str);
        } else if (num == 9960) { //9960 - API script - list of available skills
            skills=skills+[str];
        } else if (num == 8000) { //8000 - challenge/authentication
            receiveChallenge(str);
        } else if (num == 8003) {
            SecurityResponse(str);
        } else if (num == 2222) { // sets GM flag
            mainmenu = ["Reset","Target","QuickKeys","Bug","Website","Meter Color","Password","GM", "Dice", "Trans"];
        } else if (num == 1) {
            if (str == "doreset") {llResetScript();}
        } else if (num == 9990) {
            maxHealth = (integer)str;
        } else if (num == 10001) {
            list check = llParseString2List(str,["|"],[]);
            setStatus(llList2Integer(check,4));
        } else if (num == 12001) {
            tourn=1; 
            deathtimer=15; 
            woundedtimer=15; 
            integer dmgchannel = generateChannel((string)me);
            //llOwnerSay("main sending" +  (string)dmgchannel);
            llMessageLinked(LINK_THIS,4,((string)dmgchannel),NULL_KEY);
        }
    }
    attach(key id) {
        llResetScript();
    }
    changed(integer f_Changed) {
        if (f_Changed & CHANGED_REGION | f_Changed & CHANGED_TELEPORT ) {
            llMessageLinked(LINK_THIS,1111,"",NULL_KEY);
        }
        if (f_Changed & CHANGED_OWNER) {
            llResetScript();
        }
        
    }
    timer() {
        stopanims();
        if (templistener != 0) {
            llListenRemove(templistener);
            llSetTimerEvent(0.0);
        }
        if (status == 5) {
            llOwnerSay("Death timer reached.");
            llSetTimerEvent(woundedtimer);
            setStatus(7);
        } else if (status == 7) {
            llOwnerSay("You are no longer wounded, you may now /9on");
            setStatus(1); // status 1==noncombative
        } else if (status == 4) {
            llOwnerSay("Capture timer timed out. You may now /9on");
            setStatus(1); // status 1==noncombative    
        }
    }

}