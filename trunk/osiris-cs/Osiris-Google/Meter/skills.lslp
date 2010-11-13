// LSL script generated: Sat May 16 15:24:54 EDT 2009
list skill;
string SCMD;
string CSAY;
integer CSND;
integer DMG;
integer HIDE;
string PARTDUR;
string POOL;
integer POOLAMT;
integer RANGE;
integer RDYCONSENT;
string SANIM;
string SDEF;
string SNAME;
string SOFF;
string SPART;
string STAT;
integer STATAMT;
float STATDUR;
integer STYPE;
string VANIM;
integer VPART;
float VPARTDUR;
string VSAY;
string VSND;
integer stamina;
integer special;
integer health;
integer maxhealth;
string SPECIAL_TYPE;
integer SP_REGEN;
integer SP_BASE;
key target;
string targetname;
key me;
string myName="NULL";
string rpname;
integer targetID;
integer status;
string secureKey = "";
string securePass;
string myKey = "";
string randCheck;
string 	strength;
string 	intelligence;
string 	constitution;
string 	dexterity;
string 	wisdom;
integer lastskilltime;
setRandCheck(){
    (randCheck = (((string)llFrand(1.410065407e9)) + ((string)llFrand(1.410065407e9))));
}
createSecurePass(){
    securePass = "";
}

string cryptPass(string str){
    return llXorBase64StringsCorrect(llStringToBase64(str),llStringToBase64(securePass));
}
string decryptPass(string str){
    return llBase64ToString(llXorBase64StringsCorrect(str,llStringToBase64(securePass)));
}
receiveChallenge(string msg){
    createSecurePass();
    setRandCheck();
    string message = decryptPass(msg);
    string source = left(message,"|");
    string sourceKey = right(message,"||");
    (securePass = right(left(message,"||"),"|"));
    if (((source == "security") && (sourceKey == secureKey))) {
        string response = ((("skills|" + randCheck) + "||") + myKey);
        llMessageLinked(-4,8001,cryptPass(response),NULL_KEY);
    }
}
setStatus(integer num){
    (status = num);
}
string right(string src,string divider){
    integer index = llSubStringIndex(src,divider);
    if ((~index)) return llDeleteSubString(src,0,((index + llStringLength(divider)) - 1));
    return src;
}
string left(string src,string divider){
    integer index = llSubStringIndex(src,divider);
    if ((~index)) return llDeleteSubString(src,index,-1);
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
setStam(string s){
    (stamina = ((integer)s));
}
setSP(integer s){
    special = s;
}
tickSP(integer s){
	special = special + SP_REGEN;
	if (special > SP_BASE) {
		special = SP_BASE;
	}
}
setHealth(integer s) {
    (health = s);    
}
setMaxHealth(integer s) {
	(maxhealth = s);
	//llOwnerSay("maxhealth: " + (string)maxhealth);	
}
changeHealth(integer amount)
{
	health=health+amount;	
}
setSpecialType(string s){
    (SPECIAL_TYPE = s);
}
setSpecialRegen(string s){
    (SP_REGEN = ((integer)s));
}
setSkill(string s){
    (skill = llCSV2List(s));
    (SCMD = llList2String(skill,0));
    (CSAY = llList2String(skill,1));
    (CSND = llList2Integer(skill,2));
    (DMG = llList2Integer(skill,3));
    (HIDE = llList2Integer(skill,4));
    (PARTDUR = llList2String(skill,5));
    (POOL = llList2String(skill,6));
    (POOLAMT = (-llList2Integer(skill,7)));
    (RANGE = llList2Integer(skill,8));
    (RDYCONSENT = llList2Integer(skill,9));
    (SANIM = llList2String(skill,10));
    if ((SANIM == "0")) {
        (SANIM = "NULL");
    }
    (SDEF = llList2String(skill,11));
    (SNAME = llList2String(skill,12));
    (SOFF = llList2String(skill,13));
    (SPART = llList2String(skill,14));
    (STAT = llList2String(skill,15));
    (STATAMT = llList2Integer(skill,16));
    (STATDUR = llList2Float(skill,17));
    (STYPE = llList2Integer(skill,18));
    (VANIM = llList2String(skill,19));
    if ((VANIM == "0")) {
        (VANIM = "NULL");
    }
    (VPART = llList2Integer(skill,20));
    (VPARTDUR = llList2Float(skill,21));
    (VSAY = llList2String(skill,22));
    (VSND = llList2String(skill,23));
}
clearSkill(){
    (skill = []);
    (SCMD = "");
    (CSAY = "");
    (CSND = 0);
    (DMG = 0);
    (HIDE = 0);
    (PARTDUR = "");
    (POOL = "");
    (POOLAMT = 0);
    (RANGE = 0);
    (RDYCONSENT = 0);
    (SANIM = "");
    (SDEF = "");
    (SNAME = "");
    (SOFF = "");
    (SPART = "");
    (STAT = "");
    (STATAMT = 0);
    (STATDUR = 0.0);
    (STYPE = 0);
    (VANIM = "");
    (VPART = 0);
    (VPARTDUR = 0.0);
    (VSAY = "");
    (VSND = "");
}
setTarget(key id){
    (target = id);
    if ((id != me)) {
        (targetname = llKey2Name(id));
    }
    else  {
        (targetname = "SELF");
    }
}
setName(key o){
    (myName = llKey2Name(o));
}
string currName() {
	if (rpname == "NULL" | rpname == "") {
		return myName;
	} else { 
		return rpname + " (" + myName + ")";
	}
}
playSound(integer s){
    key sound;
    if ((s == 1)) {
        (sound = "ddd3ca16-df93-dca9-f378-a001541bfade");
    }
    else  if ((s == 2)) {
        (sound = "c931f1b9-3a16-0b18-e690-d57dca779847");
    }
    else  if ((s == 3)) {
        (sound = "7e8ba214-7a57-d585-80d8-f1527493f4be");
    }
    else  if ((s == 4)) {
        (sound = "5b3537a9-ba4b-70e4-a409-42f061347735");
    }
    else  if ((s == 5)) {
        (sound = "7ec2b6f9-c22e-10a0-2e03-034f852629ec");
    }
    else  if ((s == 6)) {
        (sound = "cf964179-92e5-9988-718c-24a877f69a7f");
    }
    else  if ((s == 7)) {
        (sound = "8f032124-7076-1092-0268-4f63b0b18aaf");
    }
    else  if ((s == 8)) {
        (sound = "06f8e838-38f3-6274-c81e-ca575778d777");
    }
    else  if ((s == 9)) {
        (sound = "9827d4b9-2d4a-28dc-3e62-7fc9f54ab109");
    }
    else  if ((s == 10)) {
        (sound = "47a0aafd-9017-b5f9-f319-aa46be3a76b1");
    }
    else  if ((s == 11)) {
        (sound = "35b968f0-8cef-502b-508c-02a52b41eb8e");
    }
    else  if ((s == 12)) {
        (sound = "259bac73-e155-6107-9b36-5e4402c58e7c");
    }
    else  if ((s == 13)) {
        (sound = "76e5be3b-8674-43b9-e65d-edc611e30be4");
    }
    else  if ((s == 14)) {
        (sound = "6fd513f1-b133-7a37-e4b8-f435afd44f8d");
    }
    else  if ((s == 15)) {
        (sound = "24050764-ab87-6f8d-7f10-d11df1a192f0");
    }
    else  if ((s == 16)) {
        (sound = "d401237c-0ea2-f77f-cd5f-17c938a851c0");
    }
    else  if ((s == 17)) {
        (sound = "0fd75abd-9a5f-4e12-38a2-e47083c4e4c0");
    }
    else  if ((s == 18)) {
        (sound = "408ba8a5-880e-eb86-cb3d-67f8744672dc");
    }
    else  if ((s == 19)) {
        (sound = "91edeea0-b1c1-0ebd-67e2-7f141b675581");
    }
    else  if ((s == 20)) {
        (sound = "7d1cd126-7b4d-e7c9-4d14-500dc801f172");
    }
    else  if ((s == 21)) {
        (sound = "b968b224-8829-656c-b12d-3d3c48454023");
    }
    else  if ((s == 22)) {
        (sound = "e63dfdf9-92eb-4eb6-8e24-6f1f0fb9fb1a");
    }
    else  if ((s == 23)) {
        (sound = "512e5127-2978-4462-a8e5-abc749b3d737");
    }
    else  if ((s == 24)) {
        (sound = "4439f80c-9042-e89b-35eb-63146e5f3d54");
    }
    else  if ((s == 25)) {
        (sound = "3cbdccbb-ef54-c326-e10f-90bc1091c99a");
    }
    else  if ((s == 26)) {
        (sound = "c45335bf-b8c9-99a7-534f-6baf0cdcd573");
    }
    else  if ((s == 27)) {
        (sound = "c45335bf-b8c9-99a7-534f-6baf0cdcd573");
    }
    llPlaySound(sound,1.0);
}
integer checkPool(){
    if ((POOL == "H")) {
        if ((health+POOLAMT) > -1) {
            llMessageLinked(-4,9980,(string)POOLAMT,NULL_KEY);
            setHealth((integer)(POOLAMT+health));
            return 1;
        }
        else {
            llOwnerSay("You do not have enough health to perform this skill");
            return 0;
            }    
        
    }
    else  if ((POOL == "S")) {
        if (((stamina + POOLAMT) > -1)) {
            llMessageLinked(-4,9931,((string)POOLAMT),NULL_KEY);
            setStam((string)(stamina + POOLAMT));
            return 1;
        }
        else  {
            llOwnerSay("You do not have enough stamina to perform this skill");
            return 0;
        }
    }
    else  if ((POOL == "T")) {
        if (((special + POOLAMT) > -1)) {
            llMessageLinked(-4,9932,((string)POOLAMT),NULL_KEY);
            setSP(special + POOLAMT);
            return 1;
        }
        else  {
            llOwnerSay("You do not have enough points to perform this skill");
            return 0;
        }
    }
    else  return 0;
}
string setCMD(){
	if (SOFF=="S") SOFF=strength;
	else if (SOFF=="I") SOFF=intelligence;
	else if (SOFF=="W") SOFF=wisdom;
	else if (SOFF=="C") SOFF=constitution;
	else if (SOFF=="D") SOFF=dexterity;
    string newCMD = (string)target + "|A||" + (string)STYPE + "|" + (string)DMG + "|" + (string)RANGE + "|" + (string)RDYCONSENT + "|" + STAT + "|" + (string)STATAMT + "|" + (string)STATDUR + "|" + (string)VANIM + "|" + (string)VPART + "|" + (string)VPARTDUR + "|" + (string)VSND + "|" + VSAY + "|" + SNAME + "|ALL|" + SDEF + "|" + SOFF + "^" + (string)llGetOwner();
    return newCMD;
}
string setCMDatTarget(key x){
	if (SOFF=="S") SOFF=strength;
	else if (SOFF=="I") SOFF=intelligence;
	else if (SOFF=="W") SOFF=wisdom;
	else if (SOFF=="C") SOFF=constitution;
	else if (SOFF=="D") SOFF=dexterity;
    string newCMD = (string)x + "|A||" + (string)STYPE + "|" + (string)DMG + "|" + (string)RANGE + "|" + (string)RDYCONSENT + "|" + STAT + "|" + (string)STATAMT + "|" + (string)STATDUR + "|" + (string)VANIM + "|" + (string)VPART + "|" + (string)VPARTDUR + "|" + (string)VSND + "|" + VSAY + "|" + SNAME + "|ALL|" + SDEF + "|" + SOFF + "^" + (string)llGetOwner();
    return newCMD;
}
doEmote(){
    string say = str_replace(CSAY,"%a",currName());
    (say = str_replace(say,"%d",targetname));
    if ((say != "NULL")) {
        llSay(0,say);
    }
    if ((SANIM != "NULL" && SANIM != "")) {
        llStartAnimation(SANIM);
    }
    if ((CSND != 0)) {
        playSound(CSND);
    }
    {
        llMessageLinked(LINK_SET,10,((SPART + "|") + PARTDUR + "|" + (string)target),NULL_KEY);
    }
}
default {
    state_entry() {
        (me = llGetOwner());
        setName(me);
        clearSkill();
        integer perm = llGetPermissions();
        if ((perm & 16)) {
        }
        else  {
            llRequestPermissions(me,16);
        }
    }
    link_message(integer sender_num,integer num,string str,key id) {
        if ((num == 7)) {
            setStatus(((integer)str));
        }
        else if (num == 9940) {
        	if (lastskilltime < llGetUnixTime()) { 
        	lastskilltime = llGetUnixTime()+1;
            setSkill(str);
            setTarget(id);
            if (STYPE == 12) state revive;
            else if (status==0) {
            	if ((STYPE == 1)) state rp;
	            else if (((STYPE > 1) && (STYPE < 4))) state heal;
	            else if ((STYPE == 5)) state heal;
	            else if ((STYPE == 6)) state ae;
	            else if ((STYPE == 7)) state feed;
	            else if ((STYPE == 8)) state heal;
	            else if ((STYPE == 10)) state ae;
	            else if ((STYPE == 11)) state regen;
	            else if ((STYPE == 13)) state reflect;
	            else if ((STYPE == 14)) state reflect;
	            else if ((STYPE == 15)) state heal;
	            else if ((STYPE == 16)) state meditate;
	            else if ((STYPE == 17)) state detect; // not impelemented yet
	            else if ((STYPE == 19)) state lockpick; // not implemented yet
	            else if ((STYPE == 20)) state resistmagic; // not implemented yet
	            else if ((STYPE == 21)) state reflect; // reflect magic
	            else if ((STYPE == 22)) state heal; // stun
            }
            }
        }
        else if (num==6300) {
        	string param=left(str, "|");
        	string value=right(str, "|");
        	if (param=="S") strength=value;
        	else if (param=="I") intelligence=value;
        	else if (param=="W") wisdom=value;
        	else if (param=="D") dexterity=value;
        	else if (param=="C") constitution=value;
        }
        else if (num==9998) {
            setHealth((integer)str);
        }
        else if ((num == 9990)) {
        	setMaxHealth((integer)str);	
        }
        else if ((num == 9985)) {
            setStam(str);
        }
        else if ((num == 9939)) {
            if ((str == "PULL")) {
                setTarget(id);
                state pull;
            }
        }
        else if ((num == 9971)) {
            setSP(((integer)str));
        }
        else if ((num == 8000)) {
            receiveChallenge(str);
        }
        else if ((num == 1)) {
        	string loadparam = left(str,"|");
            if (loadparam == "SPECIAL_TYPE") {
                setSpecialType(right(str,"|"));
            } else if (loadparam == "SP_REGEN") {
                setSpecialRegen(right(str,"|"));
            } else if (loadparam == "SP_BASE")  {
                SP_BASE=(integer)right(str, "|");
            } else if (loadparam == "RPNAME") {
            	rpname = right(str,"|");
            }
        }
    }
}
state rp {
    state_entry() {
        if ((target == me)) {
            llOwnerSay("This skill requires a target other than yourself.");
            state default;
        }
        vector targetPos = llList2Vector(llGetObjectDetails(target,[3]),0);
        vector myPos = llGetPos();
        if ((((integer)llVecDist(myPos,targetPos)) < RANGE)) {
            if ((checkPool() != 1)) {
                state default;
            }
            llMessageLinked(-4,6,setCMD(),target);
        }
        doEmote();
        state default;
    }
}
state heal {
    state_entry() {
        if (((STYPE != 3) && (target == me))) {
            llOwnerSay("This skill requires a target other than yourself.");
            state default;
        }
        vector targetPos = llList2Vector(llGetObjectDetails(target,[3]),0);
        vector myPos = llGetPos();
        if ((((integer)llVecDist(myPos,targetPos)) < RANGE)) {
            if ((checkPool() != 1)) {
                state default;
            }
            llMessageLinked(-4,6,setCMD(),target);
        }
        doEmote();
        state default;
    }
}
state revive {
    state_entry() {
        vector targetPos = llList2Vector(llGetObjectDetails(target,[3]),0);
        vector myPos = llGetPos();
        if ((((integer)llVecDist(myPos,targetPos)) < RANGE)) {
            if ((checkPool() != 1)) {
                state default;
            }
            llMessageLinked(-4,6,setCMD(),target);
        }
        doEmote();
        state default;
    }
}
state feed {
    state_entry() {
        if ((target == me)) {
            llOwnerSay("This skill requires a target other than yourself.");
            state default;
        } else {
        	vector targetPos = llList2Vector(llGetObjectDetails(target,[3]),0);
        	vector myPos = llGetPos();
        	if ((checkPool() != 1)) {
            	state default;
        	} else	if ((((integer)llVecDist(myPos,targetPos)) < RANGE)) {
	            (targetID = llTarget(targetPos,4.0));
            	llMoveToTarget(targetPos,0.2);
        	}
        	llSetTimerEvent(0.6);
        }
    }
    at_target(integer tnum,vector targetpos,vector ourpos) {
    	llSetTimerEvent(0);
        llMessageLinked(-4,6,setCMD(),target);
        llStopMoveToTarget();
        if ((SPECIAL_TYPE == "F")) {
            llMessageLinked(-4,9932,((string)SP_REGEN),NULL_KEY);
            tickSP(SP_REGEN);
        }
        doEmote();
        state default;
    }
    timer() {
        llTargetRemove(targetID);
        llStopMoveToTarget();
        llSetTimerEvent(0);
        state default;
    }
}
state ae {
    state_entry() {
        llSensor("",NULL_KEY,1,RANGE,3.14159274);
    }
    sensor(integer num_detected) {
        if ((checkPool() != 1)) {
            state default;
        } else {
        	doEmote();
        	integer i;
        	do  {
	            vector targetPos = llDetectedPos(i);
            	vector myPos = llGetPos();
            	if ((((integer)llVecDist(myPos,targetPos)) < RANGE)) {
	                llMessageLinked(-4,6,setCMDatTarget(llDetectedKey(i)),llDetectedKey(i));
            	}
            	++i;
        	}
        	while ((i < num_detected));
        	state default;
        }
    }
    no_sensor()
    {
    	if ((checkPool() != 1)) {
    		state default;	
    	}
    	else {
    		llOwnerSay("No targets in range.");
    		state default;	
    	}
    }
}
state regen {
    state_entry() {
        doEmote();
        if ((stamina > POOLAMT)) {
            integer temp = stamina;
            do  {
            	//llOwnerSay("health/maxhealth: " + (string)health + "/" + (string)maxhealth);
            	if (health > maxhealth) {temp=0; health=maxhealth; state default;}
            	if ((checkPool() != 1)) {state default;}
            	if (stamina < 1) {temp=0; state default;}
                llMessageLinked(-4,9931,((string)POOLAMT),NULL_KEY);
                llMessageLinked(-4,9930,((string)DMG),NULL_KEY);
                changeHealth(DMG);
                (temp = (temp - POOLAMT));
                llSleep(1);
            }
            while ((temp > 0));
        }
        state default;
    }
}
state meditate {
    state_entry() {
    if (checkPool()) {
    doEmote();
    llMessageLinked(LINK_THIS, 9936,"",NULL_KEY);
    llSetTimerEvent(SP_REGEN);
    }
    }
    timer()
    {
    	 llMessageLinked(-4,9932,((string)1),NULL_KEY);
         setSP(special + 1);
    }
    link_message(integer sender_num,integer num,string str,key id) {
        if ((num == 7)) {
            setStatus(((integer)str));
        } else if (num==9998) {
            setHealth((integer)str);
        } else if ((num == 9990)) {
        	setMaxHealth((integer)str);	
        } else if ((num == 9985)) {
            setStam(str);
        } else if ((num == 8000)) {
            receiveChallenge(str);
        } else if (num == 9940) {
            setSkill(str);
            setTarget(id);
            if ((STYPE == 16)){
            	 llSetTimerEvent(0.0);
            	 if (SANIM != "NULL") {
            	 	llStopAnimation(SANIM);
            	 }
            	 llMessageLinked(LINK_THIS, 9937,"",NULL_KEY);
            	 state default;
            	 }
        }
    }
}
state detect {
    state_entry() {
    }
}
state lockpick {
    state_entry() {
    }
}
state resistmagic {
    state_entry() {
    	if ((checkPool() != 1)) {
            state default;
        }
        llMessageLinked(-4,6,setCMD(),me);
        doEmote();
        state default;
    }
}
state reflect {
    state_entry() {
        if ((checkPool() != 1)) {
            state default;
        }
        llMessageLinked(-4,6,setCMD(),me);
        doEmote();
        state default;
    }
}
state pull {
    state_entry() {
        vector targetPos = llList2Vector(llGetObjectDetails(target,[3]),0);
        (targetID = llTarget(targetPos,1.0));
        llMoveToTarget(targetPos,0.2);
        llSetTimerEvent(0.4);
    }
    at_target(integer tnum,vector targetpos,vector ourpos) {
        llStopMoveToTarget();
        state default;
    }
    timer() {
        llStopMoveToTarget();
        state default;
    }
}
