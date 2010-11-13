string strength;
float stuntime;
key target; // AV key of the in range target  
integer movewhiledead;  
string secureKey="";
string securePass;
string myKey = "";
string randCheck;
key me; // key of the owner of the meter
string myName; // name of the owner of the meter
integer status;
integer APITimer; // this is the last time we received a vendor enhanced API call
list APICmd; // the most recent API command
integer APIFlag;
list numbers=[0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0];
integer numCheck;
integer attackstatus=1;

//////////////////////// authentication stuff //////////////////////////
setRandCheck() {
    randCheck=(string)llFrand(9999999999.0)+ (string)llFrand(9999999999.0);
}
createSecurePass() {
  securePass="";   
}
string cryptPass (string str) {
    return llXorBase64StringsCorrect(llStringToBase64(str), llStringToBase64(securePass));
}
string decryptPass (string str) {
    return llBase64ToString(llXorBase64StringsCorrect(str, llStringToBase64(securePass)));
}
receiveChallenge(string msg){
    createSecurePass();
    setRandCheck();
    string message = decryptPass(msg);
    string source = left(message,"|");
    string sourceKey = right(message,"||");
    (securePass = right(left(message,"||"),"|"));
    if (((source == "security") && (sourceKey == secureKey))) {
        string response = ((("melee|" + randCheck) + "||") + myKey);
        llMessageLinked(LINK_THIS,8001,cryptPass(response),NULL_KEY);
    }
}
//////////////////// end authentication /////////////////////////

SetAPICMD(string str) {
	APIFlag=1;
	APICmd=llCSV2List(str);
}
setStatus(integer num){status = num;}

startup(){
    me = llGetOwner();
    myName=llKey2Name(me);
    integer perms;
    perms = llGetPermissions();
	numbers=llListRandomize(numbers, 1);
    if (perms & PERMISSION_TAKE_CONTROLS) {
        doTakeControls();
        llSetTimerEvent(0.0);
    } else {
        llRequestPermissions(me,PERMISSION_TAKE_CONTROLS);
        llSetTimerEvent(1.0);
    }
}
doTakeControls(){
    llTakeControls(CONTROL_ML_LBUTTON | CONTROL_LBUTTON | CONTROL_UP | CONTROL_FWD | CONTROL_BACK | CONTROL_ROT_LEFT | CONTROL_LEFT | CONTROL_RIGHT | CONTROL_ROT_RIGHT | CONTROL_DOWN,TRUE,TRUE);
}
deadControls(){
    llTakeControls(CONTROL_ML_LBUTTON | CONTROL_LBUTTON | CONTROL_UP | CONTROL_FWD | CONTROL_BACK | CONTROL_ROT_LEFT | CONTROL_LEFT | CONTROL_RIGHT | CONTROL_ROT_RIGHT | CONTROL_DOWN,TRUE,FALSE);
}
setstuntime(float s) {stuntime=s;}
setStrength(string s){strength = s;}
setParam(string parameter,string value){
    if (parameter == "MOVEWHILEDEAD") {
        movewhiledead = (integer)value;
    }
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
string str_replace(string src,string from,string to){
    integer len = (~(-llStringLength(from)));
    if ((~len)) {
        string buffer = src;
        integer b_pos = -1;
        integer to_len = (~(-llStringLength(to)));
        @loop;
        integer to_pos = (~llSubStringIndex(buffer,from));
        if (to_pos) {
            (buffer = llGetSubString((src = llInsertString(llDeleteSubString(src,(b_pos -= to_pos),(b_pos + len)),b_pos,to)),(-(~(b_pos += to_len))),32768));
            jump loop;
        }
    }
    return src;
}
default {
    state_entry() {
        startup();
    }
    run_time_permissions(integer nMyPerms) {
        doTakeControls();
    }
    control(key id,integer held,integer change) {
        if (((held & CONTROL_LBUTTON) || (held & CONTROL_ML_LBUTTON)) && status == 0) {
            if ((((change & held) & CONTROL_ROT_LEFT) | ((change & (~held)) & CONTROL_LEFT))) {
                llSensor("","",(AGENT | ACTIVE),4.0,PI_BY_TWO);
            }
            if ((((change & held) & CONTROL_ROT_RIGHT) | ((change & (~held)) & CONTROL_RIGHT))) {
                llSensor("","",(AGENT | ACTIVE),4.0,PI_BY_TWO);
            }
            if (((change & held) & CONTROL_FWD)) {
                llSensor("","",(AGENT | ACTIVE),4.0,PI_BY_TWO);
            }
            if (((change & held) & CONTROL_BACK)) {
                llSensor("","",(AGENT | ACTIVE),4.0,PI_BY_TWO);
            }
            if ((((change & (~held)) & CONTROL_BACK) && ((change & (~held)) & CONTROL_FWD))) {
                llSensor("","",(AGENT | ACTIVE),4.0,PI_BY_TWO);
            }
            if ((((change & (~held)) & CONTROL_FWD) && (((change & (~held)) & CONTROL_LEFT) || ((change & (~held)) & CONTROL_ROT_LEFT)))) {
                llSensor("","",(AGENT | ACTIVE),4.0,PI_BY_TWO);
            }
            if ((((change & (~held)) & CONTROL_FWD) && (((change & (~held)) & CONTROL_RIGHT) || ((change & (~held)) & CONTROL_ROT_RIGHT)))) {
                llSensor("","",(AGENT | ACTIVE),4.0,PI_BY_TWO);
            }
            if (((((change & (~held)) & CONTROL_LEFT) || ((change & (~held)) & CONTROL_ROT_LEFT)) && (((change & (~held)) & CONTROL_RIGHT) || ((change & (~held)) & CONTROL_ROT_RIGHT)))) {
                llSensor("","",(AGENT | ACTIVE),4.0,PI_BY_TWO);
            }
        }
    }
    sensor(integer num) {
    	if (attackstatus==1) {
    		
	        integer i;
	            for ((i = 0); (i < num); ++i) {
	                if ((llDetectedType(i) & AGENT)) {
	                    llMessageLinked(LINK_THIS,9997,((((string)llDetectedKey(0)) + "|m||") + strength),NULL_KEY); //9997 - melee fighting system announcements
						if (APIFlag==1 && llGetUnixTime() > APITimer) {
							numCheck++;
							if (numCheck >= llGetListLength(numbers)) {numCheck=0; numbers=llListRandomize(numbers, 1);}
							//llOwnerSay((string)llList2Integer(numbers, numCheck));
							if (llList2Integer(numbers, numCheck)==1) {
								
								APITimer=llGetUnixTime()+2;
								if (llList2String(APICmd, 3) != "NULL") {
									string say = str_replace(llList2String(APICmd, 3),"%a",myName);
	    							say = str_replace(say,"%d",llKey2Name(llDetectedKey(0)));
	    							llSay(0,say);								
								}
								if (llList2String(APICmd, 5) != "0") {
									llMessageLinked(LINK_SET,10,llList2String(APICmd, 5) + "|" + llList2String(APICmd, 6),NULL_KEY);
								}
								string hit = (string)llDetectedKey(0) + "|P||2|-20|15|0|0|0|0|NULL|" + llList2String(APICmd, 7) + "|" + llList2String(APICmd, 8) + "|0|" + llList2String(APICmd, 4) + "|API|D^" + (string)llGetOwner();
								llMessageLinked(-4,6,hit,llDetectedKey(0));
								
								
								
							}
						}
	                }
	            }
	            attackstatus=0;
	            llSetTimerEvent(0.2);
    	}
    }
    timer() {
        attackstatus=1;
    }
    link_message(integer sender_num,integer num,string str,key id) {
        if (num == 7) { // 7 - status messages from main (i.e. wounded, noncombative, whatever)
        	setStatus((integer)str);
            if (((((integer)str) == 5) && (movewhiledead == 0))) state dead;
        } else  if (num == 1) { // 1 - messages from dataloader
            if (left(str,"|") == "MOVEWHILEDEAD") {
                setParam(left(str,"|"),right(str,"|"));
            }
        } else if (num==7500) { //7500 is an incoming API weapon
        	SetAPICMD(str);
        } else if (num==7501) { //7501 clears API
        	APIFlag=0;
        	APICmd=[];
        } else if (num==6300) { //6300 - statistics announcements
            if ((left(str,"|") == "S")) {
                setStrength(right(str,"|"));
            }
        } else if (num==8000) {receiveChallenge(str);} //8000 - challenge/authentication
        else if (num==9955) {
            setstuntime((float)str);
            state stunned;
		}
		else if (num==9936) {
			setstuntime(0);
			state meditate;	
		}
    }
}
state dead {
    state_entry() {
        deadControls();
    }
    link_message(integer sender_num,integer num,string str,key id) {
        if ((num == 7)) {
            if ((((integer)str) != 5)) state default; // 7 - status messages from main (i.e. wounded, noncombative, whatever)
        }
    }
}
state stunned
{
    state_entry()
    {
    	deadControls();
        if (stuntime==0) {stuntime=1;}
		if (stuntime>20) {stuntime=20;}
        llSetTimerEvent(stuntime);
    }
    timer()
    {
    setstuntime(0);
    state default;
    }
}
state meditate {
	// need to finish this... on incoming linked message from skills, will
	// go to this state, must exit it on second linked msg
	state_entry()
    {
    	deadControls();
    }
    timer()
    {
    setstuntime(0);
    }
    link_message(integer sender_num,integer num,string str,key id) {
    	if (num==9937) {
			setstuntime(0);
			state default;	
		}
    }
}
