integer debug=0;
integer health=100;
integer maxhealth=100;
integer Constitution;
integer Dexterity;
integer intelligence;
integer wisdom;
integer strength;
integer missPercent;
integer meleedamage; // number of damage per hit (melee)
float meleerate; // amount of time between hits (melee)
integer dmgstatus = 1;
integer status;
string myName; // owner's name
string rpname="NULL";
key me; // owner's key
string pass;
integer targetID; // used by the targeting system
integer listener;
integer reflectstate;
integer reflectend;
string secureKey="";
string securePass;
string myKey="";
string hitType;
string v_GRP; // this is the racial vulnerabilities group
integer blockAOE; // is AOE API blocked in this sim?
integer AOETime; // this tracks the time of the last AOE hit

// temporary variables for roleplay skills
key tmpSourceKey;
string tmpSourceName;
list tmpCmd;
integer tmpTime;

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
            string response="dmgHandler|"+ randCheck + "||" + myKey;
            llMessageLinked(LINK_THIS, 8001, cryptPass(response), NULL_KEY);   
        }
}
//  COMMUNICATION AND ENCRYPTION FUNCTIONS
setpass(string k)
{
    pass=k;
}
string crypt(string str)
{
	return llXorBase64StringsCorrect(llStringToBase64(str), llStringToBase64(pass));
}
string decrypt(string str)
{
    return llBase64ToString(llXorBase64StringsCorrect(str, llStringToBase64(pass)));
}
// SET STATUS
setStatus(integer num)
{
	status = num;
}
integer listenhandle;
setListener(integer s)
{
    llListenRemove(listenhandle);
    //llOwnerSay("setting listener on channel " + (string)s);
    listener=s;
    listenhandle=llListen((integer)s,"","","");
}
setName(key o)
{
	myName=llKey2Name(o);
}

setHealth(integer amount)
{
    health=amount; 
    announcehealth(health); 
}
string currName() {
	if (rpname == "NULL" | rpname == "") {
		return myName;
	} else { 
		return rpname + " (" + myName + ")";
	}
}

setConstitution(integer amount)
{
    Constitution=amount;
    integer base=10;
    integer boost=(Constitution-base)*5;
    setMaxHealth(100+boost); 
    if (maxhealth < 100) setMaxHealth(100);
}

setDexterity(integer amount)
{
    Dexterity=amount; 
    missPercent=di(Dexterity, 2);
}

setMaxHealth(integer amount)
{
    maxhealth=amount;
    sendToHud("MAXHEALTH|" + (string)maxhealth);
    llMessageLinked(LINK_THIS,9990,(string)maxhealth,NULL_KEY);  
}

// change health
changeHealth(integer amount)
{
    health += amount;
    if (health < 0) health=0;
    if (health > maxhealth) health = maxhealth;
    if (debug == 1 && health < maxhealth)
    {
        llOwnerSay("Damage: " + (string)amount + "; Health: " + (string)health);    
    }
    announcehealth(health);  
}

setDmgStatus(integer stat)
{
	dmgstatus=stat;
}

setMeleeDamage(integer amount)
{
	meleedamage=amount;
}

setMeleeRate(float sec)
{
	meleerate=sec;
}

string right(string src, string divider)
{
    integer index = llSubStringIndex( src, divider );
    if(~index)
        return llDeleteSubString( src, 0, index + llStringLength(divider) - 1);
    return src;
}

string left(string src, string divider)
{
    integer index = llSubStringIndex( src, divider );
    if(~index)
        return llDeleteSubString( src, index, -1);
    return src;
}

string str_replace(string src, string from, string to)
{
    integer len = (~-(llStringLength(from)));
    if(~len)
    {
        string  buffer = src;
        integer b_pos = -1;
        integer to_len = (~-(llStringLength(to)));
        @loop;//instead of a while loop, saves 5 bytes (and run faster).
        integer to_pos = ~llSubStringIndex(buffer, from);
        if(to_pos)
        {
            buffer = llGetSubString(src = llInsertString(llDeleteSubString(src, b_pos -= to_pos, b_pos + len), b_pos, to), (-~(b_pos += to_len)), 0x8000);
            jump loop;
        }
    }
    return src;
}

integer randInt(integer n)
{
     return (integer)llFrand(n + 1);
}

announcehealth(integer health)
{
    llMessageLinked(LINK_THIS,9998,(string)health,NULL_KEY);
    sendToHud("H|"+(string)health);
}

sendToHud(string str)
{
    llMessageLinked(LINK_THIS, 7000, str, NULL_KEY);    
}

doDOT(integer dmg, key source)
{
    llMessageLinked(LINK_THIS, 9934, (string)dmg, source);    
}

// Handle API stuff
yank(key source)
{
    llMessageLinked(LINK_THIS, 9939, "PULL", source);
}

doRPcmd(key source, string sourcename, list cmd)
{
    tmpSourceKey=source;
    tmpSourceName=sourcename;
    tmpCmd=cmd;
    tmpTime=llGetUnixTime()+60;
    list buttons=["Consent", "Evade", "Decline"];
    string message=sourcename + " is attempting to use skill " + llList2String(cmd, 12) + " on you. This is a roleplay based skill. You may consent, attempt to evade, or refuse the roleplay (decline). You have 60 seconds to respond.";
    llDialog(me, message, buttons, listener);
}

startAnimation(string animation)
{
	if (llGetInventoryType(animation) == 20)
	{
		llStartAnimation(animation);
	}
	else
	{
		llMessageLinked(LINK_THIS,-1000, "Missing animation: " + animation, NULL_KEY);  
	}
}

doRP()
{
	list cmd=tmpCmd;
    string stat=llList2String(cmd, 4);
    string amount=llList2String(cmd, 5);
    string duration=llList2String(cmd, 6);
    string VANIM=llList2String(cmd, 7);
    string VPART=llList2String(cmd, 8);
    string VPARTDUR=llList2String(cmd, 9);
    integer VSND=llList2Integer(cmd, 10);
    string VSAY=llList2String(cmd, 11);
    integer DMG=llList2Integer(cmd, 1);
    if ((integer)amount != 0 && (integer)duration != 0) llMessageLinked(LINK_THIS, 9935, stat+"|"+amount+"||"+duration, NULL_KEY);
   	changeHealth(DMG);
    if (DMG < 0) llMessageLinked(LINK_THIS, 9920, "",NULL_KEY); // Sending only null_key to channel 9920?? this signals API to tick RAGE type special up by 1
    string say = str_replace(VSAY, "%d", currName());
    if (say != "NULL" && say != "") {llSay(0, say);}
            
    startAnimation(VANIM); //New function to handle the start of animations, so it can't yell an error about it not being in inv
            
    if (VSND != 0) playSound(VSND);
    llMessageLinked(LINK_SET,10,VPART+"|"+VPARTDUR,NULL_KEY);
    if (tmpSourceKey != me) {llMessageLinked(LINK_THIS,9910,"",tmpSourceKey);} //announce who hit me
}

doAPIProc(string n)
{
	if (debug) llOwnerSay(n);	
    string proc=right(n, "||");
    key source=(key)right(proc, "^");
    string sourcename=llKey2Name(source);
    proc=left(proc, "^");
    //llOwnerSay(proc);
    list cmd=llParseString2List(proc, ["|"],[]);
    integer STYPE=llList2Integer(cmd, 0);
    
   // llOwnerSay("stype:" + (string)STYPE);
    if (STYPE==1)
    {
    	doRPcmd(source, sourcename, cmd);
    	return;
    }
    if (checkReflect()==21)
    {
    	llMessageLinked(LINK_THIS, 6, (string)source+"|"+"A||"+proc, source);
    	return;
    }
    if (status != 0) // what to do if the player is not currently combative
    {
        if (STYPE==3 && status==5)
        {
        	setStatus(7);llMessageLinked(LINK_THIS, 8, "7", NULL_KEY);
        }
        else
        if (STYPE==15 && status==7) //Found status=7 changed to status==7
        {
        	setStatus(1);
        	llMessageLinked(LINK_THIS, 8, "1", NULL_KEY);
        	llOwnerSay("You are no longer wounded.");
        }
        else
        if (STYPE==12)
        {
            if (status==5 || status==7)
            {
            	setStatus(0);llMessageLinked(LINK_THIS, 8, "1", NULL_KEY);
            	llSleep(0.25);
            	llMessageLinked(LINK_THIS, 8, "1", NULL_KEY);
            }
        }
        else
        {
        	return;
        }
    }
    vector targetpos=llList2Vector(llGetObjectDetails(source,[OBJECT_POS]),1);
    vector mypos=llList2Vector(llGetObjectDetails(me,[OBJECT_POS]),1);
    float distance=llVecDist(mypos,targetpos);
    if (distance < llList2Float(cmd, 2) || distance == llList2Float(cmd, 2))
    {
    	
    	integer SOFF=llList2Integer(cmd, 15);
        string SDEF=llList2String(cmd, 14);
        string VANIM=llList2String(cmd, 7);
        string VPART=llList2String(cmd, 8);
        string VPARTDUR=llList2String(cmd, 9);
        integer VSND=llList2Integer(cmd, 10);
        string VSAY=llList2String(cmd, 11);
        string CMDTYPE=llList2String(cmd, 12);
        integer DMG=llList2Integer(cmd, 1);    
        if (debug==1) llOwnerSay("In range of attack. DMG=" + (string)DMG + " STYPE=" + (string)STYPE + " CMDTYPE=" + CMDTYPE);
        
        // check if this is AOE
        if (CMDTYPE == "AOE")
        {
        	if (llGetUnixTime()-AOETime < 20)
        	{
        		if ((debug == 1)) llOwnerSay("Delay for AOE imposed, bypassing damage");
        		return;
        	}
        	if (blockAOE == 1) {
        		if ((debug ==1)) llOwnerSay("AOE API blocked in this sim configuration, no damage applied.");
        		return;	
        	}
        	AOETime=llGetUnixTime();
        	if (DMG > 20) DMG=20;
        }
        
        // check if this is successful
        if (source != me && DMG < 0 && hitType=="A")
        {
            if (doCalcChance(SOFF, SDEF)==0)
            {
                llSay(0, llList2String(cmd, 12) + " fails");
                return;
            }    
        }
        
        // check if this is a API effect and if it targets our vulnerability group
        if (debug==1) {llOwnerSay("from dmghandler: vgroup is " + llList2String(cmd, 13) + " hitype is " + hitType);}
        if (hitType=="P" && llList2String(cmd, 13) !="NULL" && llList2String(cmd, 13) != "ALL")
        {
            //llOwnerSay("v_GRP is " + v_GRP + " and incoming is " + llList2String(cmd, 13));
            if (llList2String(cmd, 13) == v_GRP)
            {
                DMG=llRound((float)DMG*1.5);
            }
            else
            {
                DMG=llCeil((float)DMG*0.5); 
            }
        } 
        
        //llOwnerSay((string)DMG);
        if (checkReflect()==20)
        {
        	DMG=llCeil((float)DMG*0.5);
        }
        
        if (STYPE==5 || STYPE==6)
        {
        	yank(source);
       	}
        else
        if (STYPE==13 || STYPE==14 || STYPE==21)
        {
        	setReflectstate(STYPE, llList2Float(cmd, 6));
        }
        else
        if (STYPE==5 || STYPE==6)
        {
        	yank(source);
       	}
        else
        if (STYPE==8 || STYPE==10)
        {
        	doDOT(DMG, source);
        }
        else
        if (STYPE==22)
        {
        	llMessageLinked(LINK_THIS, 9955, llList2String(cmd, 6), NULL_KEY);
        }
        if (llList2String(cmd, 4) !="NULL")
        {
        	string stat=llList2String(cmd, 4);
            string amount=llList2String(cmd, 5);
            string duration=llList2String(cmd, 6);
            llMessageLinked(LINK_THIS, 9935, stat+"|"+amount+"||"+duration, NULL_KEY);
        }
        changeHealth(DMG);
        if (DMG < 0) llMessageLinked(LINK_THIS, 9920, "",NULL_KEY); // Sending only null_key to channel 9920?? this signals API to tick RAGE type special up by 1
        string say=str_replace(VSAY, "%d", currName());
        if (say != "NULL" && say != "") llSay(0, say);
            
        startAnimation(VANIM); //Starting animation, using new function for it

        if (VSND != 0)
        {
        	playSound(VSND);
        }
        llMessageLinked(LINK_SET,10,VPART+"|"+VPARTDUR,NULL_KEY);
        if (source != me) llMessageLinked(LINK_THIS, 9910, "", source); //announce who hit me
    }    
}

integer doCalcChance(integer off, string defense)
{
    integer def;
    if (defense=="S") def=strength;
    else if (defense=="I") def=intelligence;
    else if (defense=="W") def=wisdom;
    else if (defense=="C") def=Constitution;
    else if (defense=="D") def=Dexterity;
    float failchance= d(off,def);
    if (failchance < 0.6) failchance=0.6;
    if (failchance > 0.9) failchance=0.9;
    if (llFrand(1.0) > failchance)
    {
    	return 0;
    }
    else
    {
    	return 1;
    }
}

setReflectstate(integer type, float duration)
{
    reflectend=llGetUnixTime()+(integer)duration;
    reflectstate=type;
}

integer checkReflect()
{
    if (llGetUnixTime() > reflectend)
    {
    	reflectstate=0;
    	return 0;
    }
    else
    {
    	return reflectstate;
    }
}

doMeleeHit(string command, key sender, integer stren)
{
    //llOwnerSay((string)missPercent);
    if ((randInt(100) > missPercent) && status==0)
    {
        integer bonus;
        bonus=(integer)(d(stren,4))-1; //using d to divide
        if (bonus > 6) bonus=6;
        integer dmg = meleedamage+bonus;
        if (checkReflect()==13)
        {
        	llMessageLinked(LINK_THIS, 9997, (string)sender + "|r||" + (string)stren, NULL_KEY);
        	dmg=0;
        }
        if (checkReflect()==14)
        {
        	llMessageLinked(LINK_THIS, 9997, (string)sender + "|r||" + (string)stren, NULL_KEY);
        }
        changeHealth(-dmg);
        if (sender != me) llMessageLinked(LINK_THIS,9910,"",sender); //announce who hit me
        dmgstatus=0;
        llSetTimerEvent(meleerate);
        llMessageLinked(LINK_THIS, 9920, "",NULL_KEY);
    }
}

playSound(integer s)
{
    key sound;
    if (s==1) sound="ddd3ca16-df93-dca9-f378-a001541bfade";
    else if (s==2) sound="c931f1b9-3a16-0b18-e690-d57dca779847";
    else if (s==3) sound="7e8ba214-7a57-d585-80d8-f1527493f4be";
    else if (s==4) sound="5b3537a9-ba4b-70e4-a409-42f061347735";
    else if (s==5) sound="7ec2b6f9-c22e-10a0-2e03-034f852629ec";
    else if (s==6) sound="cf964179-92e5-9988-718c-24a877f69a7f";
    else if (s==7) sound="8f032124-7076-1092-0268-4f63b0b18aaf"; // zombie attack
    else if (s==8) sound="06f8e838-38f3-6274-c81e-ca575778d777"; // dragon scream
    else if (s==9) sound="9827d4b9-2d4a-28dc-3e62-7fc9f54ab109"; // dragon scream 2
    else if (s==10) sound="47a0aafd-9017-b5f9-f319-aa46be3a76b1"; // dragon hiss
    else if (s==11) sound="35b968f0-8cef-502b-508c-02a52b41eb8e"; //monster
    else if (s==12) sound="259bac73-e155-6107-9b36-5e4402c58e7c"; //zombie bite
    else if (s==13) sound="76e5be3b-8674-43b9-e65d-edc611e30be4"; // flies
    else if (s==14) sound="6fd513f1-b133-7a37-e4b8-f435afd44f8d"; // whale call
    else if (s==15) sound="24050764-ab87-6f8d-7f10-d11df1a192f0"; // fly
    else if (s==16) sound="d401237c-0ea2-f77f-cd5f-17c938a851c0"; // wolf
    else if (s==17) sound="0fd75abd-9a5f-4e12-38a2-e47083c4e4c0"; // bear
    else if (s==18) sound="408ba8a5-880e-eb86-cb3d-67f8744672dc"; // creepy
    else if (s==19) sound="91edeea0-b1c1-0ebd-67e2-7f141b675581"; // hell choir
    else if (s==20) sound="7d1cd126-7b4d-e7c9-4d14-500dc801f172"; // chant
    else if (s==21) sound="b968b224-8829-656c-b12d-3d3c48454023"; // alien
    else if (s==22) sound="e63dfdf9-92eb-4eb6-8e24-6f1f0fb9fb1a"; // robot movement
    else if (s==23) sound="512e5127-2978-4462-a8e5-abc749b3d737"; // reload
    else if (s==24) sound="4439f80c-9042-e89b-35eb-63146e5f3d54"; // railgun
    else if (s==25) sound="3cbdccbb-ef54-c326-e10f-90bc1091c99a"; // missile
    else if (s==26) sound="c45335bf-b8c9-99a7-534f-6baf0cdcd573"; // whispers
    else if (s==27) sound="c45335bf-b8c9-99a7-534f-6baf0cdcd573"; // ghostly
    
    llPlaySound(sound, 1.0);
}
    
default
{
    state_entry()
    {
        me=llGetOwner();
        setName(me);
        llRequestPermissions(me, PERMISSION_TRIGGER_ANIMATION);
    }
    listen(integer channel, string name, key id, string message)
    {
        if (id==llGetOwner() && message=="Consent")
        {
            doRP();
        }
        else
        if (id==llGetOwner() && message=="Evade")
        {
            integer SOFF=llList2Integer(tmpCmd, 14);
            string SDEF=llList2String(tmpCmd, 13);
            if (doCalcChance(SOFF, SDEF)==0)
            {
            	llSay(0, tmpSourceName + "'s attempt to " + llList2String(tmpCmd, 12) + " fails");
                tmpSourceName="";
                tmpSourceKey="";
                tmpCmd=[];
                tmpTime=0;
                return;
            }
            else
            {
            	llSay(0, currName() + " attempts to evade, but fails.");
                doRP();    
                tmpSourceName="";
                tmpSourceKey="";
                tmpCmd=[];
                tmpTime=0;
            }    
        }
        else
        if (id==llGetOwner() && message=="Decline")
        {
            llInstantMessage(tmpSourceKey, currName() + " declines the roleplay");
            tmpSourceName="";
            tmpSourceKey="";
            tmpCmd=[];
            tmpTime=0;
        }
        else
        {
        	string msg=decrypt(message);
            if (debug==1) llOwnerSay(msg);
            key targetkey=(key)left(msg,"|");
            if (targetkey==me)
            {
            	string command = right(msg,"|");
                key sender=llGetOwnerKey(id);
                //llMessageLinked(LINK_THIS, 9999, command, llGetOwnerKey(id));
                hitType=left(command,"||");
                if (debug==1) llOwnerSay("hittype: " + hitType);
                integer stren=(integer)llStringTrim(right(command,"||"), STRING_TRIM);
                //llOwnerSay("stren: " + (string)stren);     
                if (hitType=="m")
                {
                	if (dmgstatus==1)
                	{
                		doMeleeHit(command, sender, stren);
                	}
                }
                else
                if (hitType=="r")
                {
                	integer bonus;
        			bonus=(integer)(d(stren,4))-1; //using d to divide
        			if (bonus > 6) bonus=6;
        			integer dmg = -3-bonus;
 					changeHealth(dmg);
                }
                else
                if (hitType=="x")
                {
                	//this is xp drop
                    llMessageLinked(LINK_THIS, 3333,right(command,"||"), sender);
                }
                else if (hitType=="e" || hitType=="E") // enhanced bullet announcement
                {
                	llMessageLinked(LINK_THIS, 7503,right(command,"||"), sender);
                    //llOwnerSay("dmgHandler: got new bullet cmd");
                }
                else
                if (hitType=="k") // this is a comm from the loser in a fight to tick xp
                {
                	llMessageLinked(LINK_THIS, 7352, right(command, "||"), sender);                         
                }
                else // this will be A (for skills) or P (for API procs)
                {
                	doAPIProc(right(command, "||"));
                }
            }
        }
    }
    
    link_message(integer sender_num, integer num, string str, key id)
    {
        //llOwnerSay((string)num + "|" + str);
        if (num==9999)
        {
             doAPIProc(right(str, "||"));   
        }
        else
        if (num==9996) //this msg is coming from the ranged damage handler
        {
        	if ((randInt(100) > missPercent) && status==0)
        	{
        		integer dmg=(integer)str;
                if (checkReflect()==13)
                {
                	llMessageLinked(LINK_THIS, 9997, (string)id + "|r||" + (string)Dexterity, NULL_KEY);
                	dmg=0;
                }
                if (checkReflect()==14)	llMessageLinked(LINK_THIS, 9997, (string)id + "|r||" + (string)Dexterity, NULL_KEY);
                health=health-dmg;
                if (health<0) health=0;
                if (health>maxhealth) health=maxhealth;
                llMessageLinked(LINK_THIS,9998,(string)health,NULL_KEY); // replaces announcehealth
                llMessageLinked(LINK_THIS, 7000, (string)health, NULL_KEY);  // replaces send2hud
            }
        }
        else if (num==9980) changeHealth((integer)str); // this is a message from CHARACTER with the health tick
        else if (num==9797) debug=1;
        else if (num==9930) changeHealth((integer)str); // this is a msg from API telling me to change health
        else if (num==8000) receiveChallenge(str);
        else if (num==12)
        {
        	sendToHud("MAXHEALTH|" + (string)maxhealth);
            sendToHud("HEALTH|" + (string)health);
        }
        else if (num==7) setStatus((integer)str);
        else if (num==5) setpass(str);
        else if (num==4) 
        {
            //llOwnerSay("received dmgchannel " + str);
            //llListen((integer)str,"","","");    
            setListener((integer)str);
        }
        else if (num==6300)
        {
            string loadparam=left(str, "|");
            if (loadparam == "C") {setConstitution((integer)right(str,"|"));}
            else if (loadparam == "D") {setDexterity((integer)right(str,"|"));}
            else if (loadparam == "S") strength=(integer)right(str,"|");
            else if (loadparam == "W") wisdom=(integer)right(str,"|");
            else if (loadparam == "I") intelligence=(integer)right(str,"|");
        }
        else if (num==1) // input is coming from dataloader on chan 1
        {
            string loadparam=left(str, "|");
            if (loadparam == "MELEEDAMAGE") setMeleeDamage((integer)right(str, "|"));
            else if (loadparam == "MELEERATE") setMeleeRate((float)right(str,"|"));
            else if (loadparam == "V_GRP") v_GRP=(right(str,"|"));
            else if (loadparam == "C")
            {
            	setConstitution((integer)right(str,"|"));
            	setHealth(maxhealth);
            }
            else if (loadparam == "RPNAME") {
            	rpname = right(str,"|");
            }
            else if (loadparam =="LOADCOMPLETE") 
            {
                setHealth(maxhealth);
                announcehealth(health);
                llSetTimerEvent(0.2);
            }  else if (loadparam =="BLOCKAPI") {
	        	list blockAPI=llCSV2List(right(str,"|"));
	        	if (llListFindList(blockAPI, ["G"]) != -1) {
	    				blockAOE=1;
	    				
		    	}
	        }
            
        }        
    }
    timer()
    {
        dmgstatus=1;
        if (llGetUnixTime() > tmpTime && tmpTime !=0)
        {
        	tmpSourceName="";
            tmpSourceKey="";
            tmpCmd=[];
            tmpTime=0;    
        }
    }
}
