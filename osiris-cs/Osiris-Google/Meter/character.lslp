string 		RegionName;
integer 	tick;
integer 	base_strength;
integer 	base_intelligence;
integer 	base_wisdom;
integer 	base_constitution;
integer 	base_dexterity;
integer 	strength;
integer 	intelligence;
integer 	constitution;
integer 	dexterity;
integer 	wisdom;
key 		source;
integer 	dmg;
integer 	DOTcount;
integer		buffduration;
string 		secureKey = "something";
string 		securePass;
string 		myKey = "something else";
string 		randCheck;
integer 	H_REGEN;
integer 	S_REGEN;
integer		lastTick; //When was XP last ticked
integer		setAFK; //When was the afk entered
string 		cryptPass(string str){
    return llXorBase64StringsCorrect(llStringToBase64(str),llStringToBase64(securePass));
}
string 		decryptPass(string str){
    return llBase64ToString(llXorBase64StringsCorrect(str,llStringToBase64(securePass)));
}
setDotCount(integer x){
    DOTcount = x;
}
postStats()
{
    sendToHud("BASE_S|" + (string)base_strength);
    sendToHud("BASE_I|" + (string)base_intelligence);
    sendToHud("BASE_W|" + (string)base_wisdom);
    sendToHud("BASE_D|" + (string)base_dexterity);
    sendToHud("BASE_C|" + (string)base_constitution);
    sendToHud("S|" + (string)strength);
    sendToHud("I|" + (string)intelligence);
    sendToHud("W|" + (string)wisdom);
    sendToHud("D|" + (string)dexterity);
    sendToHud("C|" + (string)constitution);
    llMessageLinked(-4,6300,"S|" + (string)strength,NULL_KEY);
    llMessageLinked(-4,6300,"I|" + (string)intelligence,NULL_KEY);
    llMessageLinked(-4,6300,"W|" + (string)wisdom,NULL_KEY);
    llMessageLinked(-4,6300,"D|" + (string)dexterity,NULL_KEY);
    llMessageLinked(-4,6300,"C|" + (string)constitution,NULL_KEY);
}

decrementBuffDuration()
{
    buffduration -= 10;
    if ((buffduration <= 0))
    {
        setstrength(base_strength);
        setintelligence(base_intelligence);
        setconstitution(base_constitution);
        setdexterity(base_dexterity);
        setwisdom(base_wisdom);
        sendToHud("S|" + (string)strength);
        sendToHud("I|" + (string)intelligence);
        sendToHud("W|" + (string)wisdom);
        sendToHud("D|" + (string)dexterity);
        sendToHud("C|" + (string)constitution);
        buffduration = FALSE;
        llMessageLinked(LINK_THIS, 99350, "rembuffed", "");
    }
    //llOwnerSay("buff timer: " + (string)buffduration);
}

setRandCheck()
{
    randCheck = (string)llFrand(1.410065407e9) + (string)llFrand(1.410065407e9);
}

createSecurePass()
{
    securePass = "something";
}

receiveChallenge(string msg)
{
    createSecurePass();
    setRandCheck();
    string message = decryptPass(msg);
    string _source0 = left(message,"|");
    string sourceKey = right(message,"||");
    securePass = right(left(message,"||"),"|");
    if ((_source0 == "security") && (sourceKey == secureKey))
    {
        string response = ((("character|" + randCheck) + "||") + myKey);
        llMessageLinked(-4,8001,cryptPass(response),NULL_KEY);
    }
}

setRegion(string n)
{
    (RegionName = n);
}

setTick(integer n)
{
    tick = n * 60;
    lastTick = llGetUnixTime() + tick;
}

setH_REGEN(integer n)
{
    (H_REGEN = n);
}

setS_REGEN(integer n)
{
	(S_REGEN = n);
}

string left(string src,string divider)
{
    integer index = llSubStringIndex(src,divider);
    if (~index) return llDeleteSubString(src,index,-1);
    return src;
}

string right(string src,string divider)
{
    integer index = llSubStringIndex(src,divider);
    if (~index) return llDeleteSubString(src,0,((index + llStringLength(divider)) - 1));
    return src;
}
setbasestats(string s,integer stat)
{
    if (s == "S")
    {
        base_strength = stat;
    }
    else
    if (s == "I")
    {
        base_intelligence = stat;
    }
    else
    if (s == "W")
    {
        base_wisdom = stat;
    }
    else
    if (s == "D")
    {
        base_dexterity = stat;
    }
    else
    if (s == "C")
    {
        base_constitution = stat;
    }
}

sendToHud(string str)
{
    llMessageLinked(-4,7000,str,NULL_KEY);
}

doDOT(integer d,key s)
{
    DOTcount = 4;
    dmg = d;
    source = s;
}

doBuff(string stat,integer amount,integer duration) // Example: SC||10||20
{
	buffduration = duration;
    integer numstats = llStringLength(stat);
    if (numstats > 0)
    {
        integer i;
        do
        {
        	string effected = llGetSubString(stat,(i - 1),(i - 1));
            if (effected == "S")
            {
                setstrength(base_strength + amount);
            }
            else
            if (effected == "I")
            {
                setintelligence(base_intelligence + amount);
            }
            else
            if (effected == "W")
            {
                setwisdom(base_wisdom + amount);
            }
            else
            if (effected == "D")
            {
                setdexterity(base_dexterity + amount);
            }
            else
            if (effected == "C")
            {
                setconstitution(base_constitution + amount);
            }
            ++i;
         if (amount > 0)
         {
         	llMessageLinked(LINK_THIS, 99350, "buffed", "");
         }
         else
         if (amount < 0)
         {
         	llMessageLinked(LINK_THIS, 99350, "debuffed","");
         }
        }
        while (i < numstats);
    }
}

setstrength(integer x)
{
    strength = x;
    sendToHud("S|" + (string)strength);
    llMessageLinked(-4,6300,"S|" + (string)strength,NULL_KEY);
}

setintelligence(integer x)
{
    intelligence = x;
    sendToHud("I|" + (string)intelligence);
    llMessageLinked(-4,6300,"I|" + (string)intelligence,NULL_KEY);
}

setwisdom(integer x)
{
    wisdom = x;
    sendToHud("W|" + (string)wisdom);
    llMessageLinked(-4,6300,"W|" + (string)wisdom,NULL_KEY);
}

setdexterity(integer x)
{
    dexterity = x;
    sendToHud("D|" + (string)dexterity);
    llMessageLinked(-4,6300,"D|" + (string)dexterity,NULL_KEY);
}

setconstitution(integer x)
{
    constitution = x;
    sendToHud("C|" + (string)constitution);
    llMessageLinked(-4,6300,"C|" + (string)constitution,NULL_KEY);
}

default
{
    link_message(integer sender_num,integer num,string str,key id)
    {
        if (num == 8000)
        {
            receiveChallenge(str);
        }
        else
        if (num == 9934)
        {
            doDOT((integer)str,id);
        }
        else
        if (num == 9935)
        {
            string s = left(str,"|");
            integer amount = ((integer)left(right(str,"|"),"||"));
            integer dur = ((integer)right(str,"||"));
            doBuff(s,amount,dur);
        }
        else
        if (num == 1)
        {
            string loadparam = left(str,"|");
            string value = right(str,"|");
            if (loadparam == "CONFIG")
            {
            	setRegion(right(str,"|"));
            }
            else
            if (loadparam == "LOADCOMPLETE")
            {
                postStats();
                llSetTimerEvent(10);
            }
            else
            if (loadparam == "TICK")
            {
                setTick((integer)right(str,"|"));
            }
            else
            if (loadparam == "CHARSET" && right(str,"|") == "0")
            {
                llLoadURL(llGetOwner(),"You don't have a character set up in this sim. Now taking you to the website to set it up. If you do not know your password, type /9password in chat to get a new one.","http://front.rpcombat.com/setupchar.cfm?uid=" + (string)llGetOwner() + "&region=" + RegionName);
            }
            else
            if (loadparam == "H_REGEN")
            {
                setH_REGEN((integer)right(str,"|"));
            }
            else
            if (loadparam == "S_REGEN")
            {
                setS_REGEN((integer)right(str,"|"));
            }
            else
            if (loadparam == "S")
            {
                setbasestats(loadparam,((integer)value));
                setstrength((integer)right(str,"|"));
            }
            else
            if (loadparam == "I")
            {
                setbasestats(loadparam,((integer)value));
                setintelligence((integer)right(str,"|"));
            }
            else
            if (loadparam == "W")
            {
                setbasestats(loadparam,((integer)value));
                setwisdom((integer)right(str,"|"));
            }
            else
            if (loadparam == "D")
            {
                setbasestats(loadparam,(integer)value);
                setdexterity((integer)right(str,"|"));
            }
            else
            if (loadparam == "C")
            {
                setbasestats(loadparam,(integer)value);
                setconstitution((integer)right(str,"|"));
            }
        }
        else
        if (num == 12)
        {
            postStats();
        }
        else
        if (num == 7)
        {
        	if ((integer)str == 98 || (integer)str == 97)
        	{
        		setAFK = llGetUnixTime()-lastTick;
        	}
        	else
        	if ((integer)str == 0 && setAFK != 0)
        	{
        		lastTick = (llGetUnixTime()-setAFK);
        		setAFK = 0;
        	}
        }
    }
    
    timer()
    {
        llMessageLinked(-4,9980,(string)H_REGEN,NULL_KEY);
        llMessageLinked(-4,9981,(string)S_REGEN,NULL_KEY);
        
        if (llGetUnixTime() > lastTick)
        {
        	llMessageLinked(-4,0,"DOTICK",NULL_KEY);
        	lastTick = llGetUnixTime() + tick;
        }
        
        if (DOTcount)
        {
            llMessageLinked(-4,9980,(string)dmg,NULL_KEY);
            llMessageLinked(-4,9910,"",source);
            setDotCount(DOTcount - 1);
        }
        
        if (buffduration)
        {
            decrementBuffDuration();
        }
    }
}
