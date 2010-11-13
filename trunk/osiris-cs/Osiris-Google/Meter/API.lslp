//syntax for incoming special stat message: SPECIAL_TYPE|T|SP_NAME|Courage|SP_REGEN|30

//syntax for skills
// CMD|Heal|CSAY|NULL|CSND|0|DMG|10|HIDE|0|PARTDUR|1|POOL|S|POOLAMT|32|RANGE|10|RDYCONSENT|1|SANIM|0|SCMD|Heal|SDEF|W|SNAME|Heal|SOFF|W|SPART|0|STAT|C|STATAMT|1|STATDUR|30|STYPE|3|VANIM|0|VPART|0|VPARTDUR|1|VSAY|%d feels better|VSND|0|

// CHALLENGE/AUTHENTICATION
string secureKey="something";
string securePass;
string myKey="something else";
string randCheck;
integer ragetime;
integer ragedecrementtime;
integer rage_throttle;
integer rage_drain;

setRandCheck()
{
    randCheck=(string)llFrand(9999999999.0)+ (string)llFrand(9999999999.0);
}
createSecurePass()
{
     
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
            string response="API|"+ randCheck + "||" + myKey;
            llMessageLinked(LINK_THIS, 8001, cryptPass(response), NULL_KEY);   
        }
}

// end security stuff



string SPECIAL_TYPE;
integer SP_REGEN;
integer SP_BASE=0;
integer SP;
key target;

// Function to divide to prevent math errors
float d(float this, float with)
{
	if (this <= 0 || with <= 0)
		return 0;
	else
		return this/with;
}

integer di(integer this, integer with)
{
	if (this <= 0 || with <= 0)
		return 0;
	else
		return this/with;
}

// the following helps figure out how to parse the list of powers
integer numAspects=27;
list skills;
list commands;


// append skill list
updateskills(list s)
{   
    string cmd=llStringTrim(llList2String(s, 1), STRING_TRIM);
    commands+=[cmd];
    commands=llListSort(commands, 1, FALSE);
    string name=llList2String(s, 13);
    string stat=llList2String(s, 16);
    integer statamt=llList2Integer(s, 17);
    string effect;
    if (stat != "NULL" && statamt > 0) effect="(Buff)";
    else if (stat != "NULL" && statamt < 0) effect="(Weaken)";
	llMessageLinked(LINK_THIS, 13, (string)llGetListLength(commands), NULL_KEY);
    skills+= ["CMD"] + ["CMD"+cmd] + s;
    llMessageLinked(LINK_THIS,9960,llList2CSV(commands), NULL_KEY); 
    // integer freemem=llGetFreeMemory();
   // if (freemem < 6000) llOwnerSay("api: " + (string)freemem + " bytes free.");
}
listskills() {
	integer x=0;
	while (x < llGetListLength(commands)) {
		llOwnerSay(llList2String(commands, x));
		x++;	
	}
	llOwnerSay("Further information about each command is available by accessing your character at http://www.osiris-sl.com");
}
sendToHud(string str)
{
    llMessageLinked(LINK_THIS, 7000, str, NULL_KEY);    
}
// DO SKILL
DoSkill(string cmd, key target)
{
    integer start=llListFindList(skills, ["CMD"+cmd]);
    // first lets find out if this is a valid command
    if (~start)
    {
        integer end=start+numAspects;
        list skill=llDeleteSubList(skills, end-1, llGetListLength(skills));      
        skill=llDeleteSubList(skill, 0, start+1);
        llMessageLinked(LINK_THIS, 9940, llList2CSV(skill), target);
        //llOwnerSay("API: sending cmd");
    }
}
// sets target key
setTargetKey(key n)
{
  target=n; 
  if (target != llGetOwner()) {
  	llOwnerSay("Target set to " + llKey2Name(target));
  }
  else {
  	llOwnerSay("Target set to SELF");
  }
}
// SET SPECIAL REGEN OPTIONS
setSP_TYPE(string type)
{
    SPECIAL_TYPE=type;
}
setSP_REGEN(integer amt)
{
    SP_REGEN=amt;   
}
setSP_BASE(integer num)
{
   SP_BASE=num; 
}
tickSP(integer num)
{ 
    if (num < 0 | SP < SP_BASE) {
        SP=SP+num;
        if (SP > SP_BASE) {SP=SP_BASE;}
        if (SP < 0) {SP=0;}
        float SP_PERCENT= (float)SP / (float)SP_BASE * 100;
        announceSPPercent(SP_PERCENT);   
        announceSP(SP);
    }
}
announceSPPercent(float num)
{
    llMessageLinked(LINK_THIS,9970,(string)num, NULL_KEY);  
}
announceSP(float num)
{
    llMessageLinked(LINK_THIS,9971,(string)num, NULL_KEY);
    sendToHud("SPECIAL|" + (string)SP);
    llMessageLinked(-4,10000,"-1|-1|-1|"+(string)num+"|-1",NULL_KEY); //Send special to RAM
    llMessageLinked(-4,10000,"SAVESIMDATA",NULL_KEY); //Send special to RAM
}
//  TEXT FUNCTIONS
string left(string src, string divider) {
    integer index = llSubStringIndex( src, divider );
    if(~index)
        return llDeleteSubString( src, index, -1);
    return src;
}

string right(string src, string divider) {
    integer index = llSubStringIndex( src, divider );
    if(~index)
        return llDeleteSubString( src, 0, index + llStringLength(divider) - 1);
    return src;
}
string strReplace(string str, string search, string replace) {
    return llDumpList2String(llParseStringKeepNulls((str = "") + str, [search], []), replace);
}
string skillType(integer num) {
    string sayType;
    if (num == 1) sayType = "Roleplay";
    else if (num == 2) sayType = "Direct Damage";
    else if (num == 3) sayType = "Heal";
    else if (num == 5) sayType = "Pull";
    else if (num == 6) sayType = "Area Pull";
    else if (num == 7) sayType = "Feed";
    else if (num == 8) sayType = "Damage Over Time";
    else if (num == 10) sayType = "Area Damage Over Time";
    else if (num == 11) sayType = "Regenerate";
    else if (num == 12) sayType = "Revive";
    else if (num == 13) sayType = "Reflect";
    else if (num == 14) sayType = "Damage Shield";
    else if (num == 15) sayType = "Cure Wounds";
    else if (num == 16) sayType = "Meditate";
    else if (num == 17) sayType = "Detect Trap";
    else if (num == 19) sayType = "Lockpick";
    else if (num == 20) sayType = "Resist Magic";
    else if (num == 21) sayType = "Reflect Magic";
    else if (num == 22) sayType = "Stun";
    else sayType = "N/A (" + (string)num + ")";
 return "Type: " + sayType;
}

default
{
    link_message(integer sender_num, integer num, string str, key id)
    {
        if (num==9950) 
        {
           if (str=="TARGET")
           {
             setTargetKey(id); // SET TARGET KEY  
            }
            else {
                string command=str;
                if(id) DoSkill(command, id);
                else DoSkill(command, target);  
            }
            
        }
        // hit announcements
        else if (num==9981)
        {
        	if (SPECIAL_TYPE=="R" && llGetUnixTime() > ragedecrementtime)
            {
            	if (SP > 0)  {
            		SP -= 1;
            		ragedecrementtime = llGetUnixTime()+rage_drain;
            		float SP_PERCENT= d((float)SP, (float)SP_BASE * 100); // Using d to prevent math errors
        			announceSPPercent(SP_PERCENT);   
        			announceSP(SP);
            	}
            } 
        }
        else if (num==9920)
        {
        	
            if (SPECIAL_TYPE=="R" && llGetUnixTime() > ragetime)
            {
            	//llOwnerSay("got rage " + (string)ragetime);
            	ragetime=llGetUnixTime()+rage_throttle;
            	//llOwnerSay("rage throttle: " + (string)rage_throttle);
            	//llOwnerSay("new rage time: " + (string)ragetime);
                tickSP(SP_REGEN);
            }     
        } 
        else if (num==14)
        {
        	listskills();	
        }
        else if (num==12) 
        {
            // 12 means comms are established with the hud, dump stats to hud
            sendToHud("SPECIAL|" + (string)SP);
        } 
        else if (num == 10001) { //Get the health from RAM still strange...
        	list check = llParseString2List(str,["|"],[]);
        	SP=(llList2Integer(check,3));
        	ragedecrementtime = llGetUnixTime()+rage_drain;
            float SP_PERCENT= (integer)d((float)SP, SP_BASE)*100; //Using d to prevent math errors
        	announceSPPercent(SP_PERCENT);   
        	announceSP(SP);
        }
        // updates from dataloader come on 1
        else if (num==1)
        {
        	//llOwnerSay(str);
            // set type of special
            if (left(str, "|") == "SPECIAL_TYPE")
            {
                setSP_TYPE(right(str, "|")); 
            }
            
            // get base amount for special
            else if (left(str, "|") == "SP_BASE")
            {
                setSP_BASE((integer)right(str, "|"));
            }
            // set regen timer   
            else if (left(str, "|") == "SP_REGEN")
            {
                setSP_REGEN((integer)right(str, "|"));
                if (SPECIAL_TYPE=="T") llSetTimerEvent((float)SP_REGEN);
            }
            else if (left(str, "||") == "SKILL")
            {
                list s=llParseString2List(str, ["|"],[""]);
                updateskills(s);
            }
            else if (left(str, "|") == "RAGE_THROTTLE") {
            	rage_throttle=(integer)right(str, "|");
            	//llOwnerSay("rage throttle: " + (string)rage_throttle);
            }
			else if (left(str, "|") == "RAGE_DRAIN") {
				rage_drain=(integer)right(str, "|");
			}
        }
        else if (num==8000) {receiveChallenge(str);} 
        // commands from the player
        else if (num==9932)
        {
            tickSP((integer)str);   
        }
    }
    timer()
    {
        tickSP(1); 
    }
}
