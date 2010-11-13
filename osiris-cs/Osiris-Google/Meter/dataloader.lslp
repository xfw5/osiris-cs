// LSL script generated: Sat May 16 14:28:44 EDT 2009
list	domains = [""];
list	domainDesc = [""];
integer	dIndex = 0;

key colleen = "aa3457ab-3f55-4341-ae89-2a9c2baaa452";
string version="0.84";
string ConfigURL()
{
	return "http://" + llList2String(domains, dIndex) + "/";
}
string SimPassURL()
{
	return "http://" + llList2String(domains, dIndex) + "/";
}
string CharURL()
{
	return "http://" + llList2String(domains, dIndex) + "/";
}
string CheckRegionURL()
{
	return "http://" + llList2String(domains, dIndex) + "/";
}
string tickURL()
{
	return "http://" + llList2String(domains, dIndex) + "/";
}
string skillURL()
{
	return "http://" + llList2String(domains, dIndex) + "/";
}
string CharSettingsURL()
{
	return "http://" + llList2String(domains, dIndex) + "/";
}
string killURL()
{
	return "http://" + llList2String(domains, dIndex) + "/";
}
string regURL()
{
	return "http://" + llList2String(domains, dIndex) + "/";
}

string RegionName;
string simpass;
key http_request_id; // key for outgoing requests
key url_request; // key for incoming requests
string myURL;
list configdata;
list chardata;
integer simconfig_received = 0;
integer currpassword_received = 0;
integer character_received = 0;
integer skills_received = 0;
integer charactersettings_received = 0;
list skills;
integer currentskill = -1;
integer totalskills;
string secureKey = "";
string securePass;
string myKey = "";
key me;
integer tourn;
string randCheck;
integer numLoaded; //Just a counter of skills loaded
integer status; // 0 = normal, 
                // 1 = noncombative; 
                // 2 = observer/setup incomplete, 
                // 3 = out of character
                // 4 = captured
                // 5 = dead
                // 6 = loading
                // 7 = wounded
                // 99 = checking security
                // 98 = anticamp activated
setStatus(integer num)
{
    status = num;
    if (status == 98)
    {
    	llOwnerSay("AntiCamp timeout, Osiris has been deactivated.");
    }
    else if (status == 97)
    {
    	llOwnerSay("You entered AFK mode, Osiris has been deactivated.");
    }
    else if (status == 1)
    {
    	llOwnerSay("Changing to noncombative mode.");
    }
    else if (status == 0)
    {
    	//llOwnerSay("Activating...");
    }
}
createSecurePass()
{
    securePass = "";
}
string cryptPass(string str)
{
    return llXorBase64StringsCorrect(llStringToBase64(str),llStringToBase64(securePass));
}
string decryptPass(string str)
{
    return llBase64ToString(llXorBase64StringsCorrect(str,llStringToBase64(securePass)));
}
setRandCheck()
{
    randCheck = (string)llFrand(1.410065407e9) + (string)llFrand(1.410065407e9);
}
receiveChallenge(string msg)
{
    createSecurePass();
    setRandCheck();
    string message = decryptPass(msg);
    string source = left(message,"|");
    string sourceKey = right(message,"||");
    securePass = right(left(message,"||"),"|");
    if (source == "security" && sourceKey == secureKey)
    {
        string response = "dataloader|" + randCheck + "||" + myKey;
        llMessageLinked(-4,8001,cryptPass(response),NULL_KEY);
    }
}
disable()
{
    llSetScriptState("dataloader",0);
    llDetachFromAvatar();
    llDie();
}
sendToHud(string str)
{
    llMessageLinked(-4,7000,str,NULL_KEY);
}
string getConfigName(integer idx)
{
    return llStringTrim(llList2String(configdata,((idx * 2) + 0)),3);
}
string getConfigValue(integer idx)
{
    return llStringTrim(llList2String(configdata,((idx * 2) + 1)),3);
}
string getConfigList(string data)
{
    integer start = llSubStringIndex(data,"\\");
    integer end = llStringLength(data);
    return llGetSubString(data,(start + 2),(end - 1));
}
string getCharList(string data)
{
    integer start = llSubStringIndex(data,"\\");
    integer end = llStringLength(data);
    return llGetSubString(data,(start + 2),(end - 1));
}
string getCharName(integer idx)
{
    return llStringTrim(llList2String(chardata,((idx * 2) + 0)),3);
}
string getCharValue(integer idx)
{
    return llStringTrim(llList2String(chardata,((idx * 2) + 1)),3);
}
integer set_simconfig_received(integer int)
{
    simconfig_received = int;
    return int;
}
integer set_password_received(integer int)
{
    currpassword_received = int;
    return int;
}
integer set_character_received(integer int)
{
    character_received = int;
    return int;
}
integer set_charactersettings_received(integer int)
{
    charactersettings_received = int;
    return int;    
}
integer set_skills_received(integer int)
{
    skills_received = int;
    return int;
}
loadSimConfig()
{
    string newRegionName = llGetRegionName();
    string rn = llEscapeURL(newRegionName);
    http_request_id = llHTTPRequest(ConfigURL() + "?region=" + rn + "&version=" + version,[],"");
}
getSkills(list skilllist){
    currentskill = currentskill + 1;
    totalskills = llGetListLength(skills);
    if (currentskill < totalskills) {
        http_request_id = llHTTPRequest(skillURL() + "?sid=" + llList2String(skilllist,currentskill),[],"");
    }
    else
    {
        set_skills_received(1);
    }
}
setRegion(string name)
{
    RegionName = name;
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
integer checkComplete()
{
    integer test = 0;
    if (simconfig_received == 0)
    {
        test = 1;
    }
    if (currpassword_received == 0)
    {
        test = 1;
    }
    if (character_received == 0)
    {
        test = 1;
    }
    if (skills_received == 0)
    {
        test = 1;
    }
    if (charactersettings_received == 0)
    {
        test = 1;
    }
    if (test == 0)
    {
        return 1;
    }
    else 
    {
        return 0;
    }
}
default
{
    state_entry()
    {
        me = llGetOwner();
        llRequestPermissions(me,32);
        //url_request = llRequestURL();
    }
    
    link_message(integer sender_num,integer num,string str,key id)
    {
        if (num == 0)
        {
            if (str == "DOTICK")
            {
            	if (status < 97)
            	{
        			http_request_id = llHTTPRequest(tickURL(),[],"");
        		}
        		else if (status == 98)
        		{
        			llOwnerSay("Unable to tick xp while anticamp is activated.");
        		}
        		else if (status == 97)
        		{
        			llOwnerSay("Unable to tick xp while afk mode is activated.");
        		}
        		else if (status == 3)
        		{
        			llOwnerSay("Unable to tick xp in OOC mode.");
            	} 
            }
            else if (str == "LOAD")
            {
                llMessageLinked(0,1,"loading",NULL_KEY);
                loadSimConfig();
                llSetTimerEvent(1);
            }
        }
        else if (num == 7)
        {
        	setStatus((integer)str);
        }
        else if (num == 1111)
        {
        	url_request = llRequestURL();
            http_request_id = llHTTPRequest(CheckRegionURL() + "?oldregion=" + llEscapeURL(RegionName),[],"");	
        }
        else if (num == 3333 && tourn==0)
        {
        	//llOwnerSay("dataloader: got command to tick xp: " + str);
        	if (status == 0 | status == 1)
        	{
        		http_request_id=llHTTPRequest(tickURL() + "?sender=" + (string)llGetOwnerKey(id) + "&amount=" + str, [],"");
        	}
        	else if (status == 98)
        	{
        		llOwnerSay("Unable to tick xp while anticamp is activated.");
        	}
        	else if (status == 97)
        	{
        		llOwnerSay("Unable to tick xp while afk mode is activated.");
        	}
        }
        else if (num == 7350 && tourn==0) // we've been killed, record it
        {
        	http_request_id=llHTTPRequest(killURL() + "?uid=" + (string)id, [],"");
        }
        else if (num == 7352 && tourn==0) // we've killed someone, get the data
        {
        	http_request_id=llHTTPRequest(killURL() + "?boutid=" + str, [], "");
        }
        else if (num == 8000)
        {
            receiveChallenge(str);
        }
        else if (num == 12000)
        {
        	llOwnerSay("Now loading tournament mode");
			character_received = 0;
        	llResetOtherScript("skills");
        	llResetOtherScript("dmgHandler");
        	llResetOtherScript("API");
        	llResetOtherScript("sim");
        	llResetOtherScript("ranged");
        	llResetOtherScript("character");
        	llResetOtherScript("meter");
        	llResetOtherScript("melee");
        	llSleep(3);
        	string body="CHAR||24\\CONFIGID|0|TICK|30|MAXMELEE|30|MAXRANGED|15|MELEEDAMAGE|10|RANGED|3|RANGEDRATE|0.2|MELEERATE|0.7|MOVEWHILEDEAD|1|KILLAMT|0|TICKAMT|99|CAPTIME|30|CAPTURE|1|HEALWHILEDEAD|0|DEATHTIMER|15|DISPLAYGM|1|DISPLAY|HSRCL|DISPLAYGM|1|DISPLAYPUBLIC|1|WOUNDEDTIMER|15|ADVANTAGES|NULL|C|25|D|10|DTEXT|Defeated|H_REGEN|1|I|10|S|10|SPECIAL_TYPE|T|SP_BASE|5|SP_NAME|Special|SP_REGEN|30|S_REGEN|10|V_GRP|NULL|W|10|LVL1|1|LVL2|1|CHARSET|1|SKILLS|310,";	
        	llSleep(1.0);
        	llMessageLinked(-4,7,"6",NULL_KEY);
            llMessageLinked(-4,1,"loading",NULL_KEY);
            chardata = llParseString2List(getCharList(body),["|"],[]);
            integer x = 0;
            for (x = 0; x < (llGetListLength(chardata)/2); x = x+1)
            {
                llMessageLinked(-4,1,((getCharName(x) + "|") + getCharValue(x)),NULL_KEY);
            }
            llMessageLinked(-4,5,simpass,NULL_KEY);
            llMessageLinked(-4,1, "SKILL||heal|%a heals %d|4|14|0|1|S|32|20|1|Spell3|W|heal|C|8|NULL|0|0|3|0|8|1|%d feels better|3", NULL_KEY);
            llSleep(1.0);
            llMessageLinked(-4,1,"LOADCOMPLETE|1",NULL_KEY);
            llSleep(1.0);
            tourn=1;
            llMessageLinked(-4, 12001, "", NULL_KEY);
        }
    }
    http_response(key id,integer h_status,list meta,string body)
    {
    	if (id == http_request_id)
    	{
    		if (h_status != 200)
    		{
	    		if (dIndex++ < llGetListLength(domains)-1)
    			{
    				llOwnerSay(llList2String(domainDesc, dIndex-1) + " did not give valid reply, changing domain.");
    				loadSimConfig();
    			}
    			else
    			{
	    			llOwnerSay(llList2String(domainDesc, dIndex-1) + " did not give valid reply. All domains are unavailible, please try again later.");
    				dIndex = 0;
    				return;
    			}
    		}
    		else
    		{
    			if (h_status==200 && id == http_request_id)
    			{
			        body = llStringTrim(body,3);
	        
			        if (id == http_request_id)
			        {
		       			if (body == "RELOAD")
		       			{
		           			llResetOtherScript("main");
		           		}
		           		else if (left(body,"||") == "CONFIG")
		           		{
		               		if (right(body,"||") != RegionName)
		               		{
		                   		llMessageLinked(-4,1,"doreset",NULL_KEY);
		               		}
		           		}
		           		else if (left(body,"||") == "Region Found")
		           		{
		           			tourn=0;
		               		llSleep(0.1);
		               		llMessageLinked(0,1,"loading",NULL_KEY);
		               		body = right(body,"||");
		               		string _RegionName0 = left(body,"\\");
		               		llOwnerSay(("Loading Region Config:" + _RegionName0));
		               		setRegion(_RegionName0);
		               		llMessageLinked(-4,1,("CONFIG|" + _RegionName0),NULL_KEY);
		               		configdata = llParseString2List(getConfigList(body),["|"],[]);
		               		integer x = 0;
		               		for (x = 0; x < (llGetListLength(configdata) / 2); x = x + 1)
		               		{
		                   		llMessageLinked(-4,1,((getConfigName(x) + "|") + getConfigValue(x)),NULL_KEY);
		               		}
		               		set_simconfig_received(1);
		               		http_request_id = llHTTPRequest(SimPassURL(),[],"");
		               		llSetTimerEvent(1);
		           		}
		           		else if (left(body,"||") == "Not Found")
		           		{
		               		llSleep(0.1);
		               		llMessageLinked(0,1,"loading",NULL_KEY);
		               		body = right(body,"||");
		               		string _RegionName2 = left(body,"\\");
		               		llOwnerSay("Loading Region Config:" + _RegionName2);
		               		setRegion(_RegionName2);
		               		configdata = llParseString2List(getConfigList(body),["|"],[]);
		               		integer x = 0;
		               		for (x = 0; x < (llGetListLength(configdata) / 2); x = x + 1)
		               		{
		                   		llMessageLinked(-4,1, getConfigName(x) + "|" + getConfigValue(x),NULL_KEY);
		               		}
		               		set_simconfig_received(1);
		               		http_request_id = llHTTPRequest(SimPassURL(),[],"");
		               		llSetTimerEvent(1);
		           		}
		           		else if (left(body,"||") == "SIMP")
		           		{
		               		llSleep(0.1);
		               		llMessageLinked(0,1,"loading",NULL_KEY);
		               		simpass = llStringTrim(right(body,"||"), STRING_TRIM);
		               		llMessageLinked(-4,5,simpass,NULL_KEY);
		               		set_password_received(1);
		               		http_request_id = llHTTPRequest(CharURL(),[],"");
		               		llSetTimerEvent(1);
		           		}
		           		else if (left(body,"||") == "CHAR")
		           		{
		           			//llOwnerSay(body);
		               		llSleep(0.1);
		               		llMessageLinked(0,1,"loading",NULL_KEY);
		               		chardata = llParseString2List(getCharList(body),["|"],[]);
		               		integer x = 0;
		               		for (x = 0; x < (llGetListLength(chardata) / 2); x = x + 1)
		               		{
		                  		llMessageLinked(-4,1,((getCharName(x) + "|") + getCharValue(x)),NULL_KEY);
		               		}
	                		set_character_received(1);
	                		llSetTimerEvent(1);
	                		skills = llParseString2List(right(body,"SKILLS|"),[","],[]);
	                		http_request_id = llHTTPRequest(CharSettingsURL(), [], "");
	            		}
	            		else if (left(body,"||") == "CHARSETTINGS")
	            		{
	                		llSleep(0.25);
	                		llMessageLinked(0,1,"loading",NULL_KEY);
	                		chardata = llParseString2List(right(body, "||"),["|"],[]);
	                		integer x = 0;
	                		for (x = 0; x < (llGetListLength(chardata) / 2); x = x + 1)
	                		{
	                    		llMessageLinked(-4,1,((getCharName(x) + "|") + getCharValue(x)),NULL_KEY);
	                		}
	                		set_charactersettings_received(1);
	                		llSetTimerEvent(1);
	                		getSkills(skills);
	            		}
	            		else if (left(body,"||") == "NOCHAR")
	            		{
	            			llHTTPRequest(regURL() + "?myURL=" + myURL, [], "");
	                		llSleep(0.25);
	                		llMessageLinked(0,1,"loading",NULL_KEY);
	                		chardata = llParseString2List(getCharList(body),["|"],[]);
	                		integer x = 0;
	                		for (x = 0; x < (llGetListLength(chardata) / 2); x = x + 1)
	                		{
	                    		llMessageLinked(-4,1,((getCharName(x) + "|") + getCharValue(x)),NULL_KEY);
	                		}
	                		set_character_received(1);
	                		set_charactersettings_received(1);
	                		set_skills_received(1);
	                		llSetTimerEvent(1);
	            		}
	            		else if (left(body,"||") == "XP")
	            		{
	            			string xpdata = left(right(body,"||"),"^");
		            		string xpmsg = right(body,"^");
		            		chardata = llParseString2List(getCharList(xpdata),["|"],[]);
		            		integer x = 0;
		            		do
		            		{
		                		llMessageLinked(-4,1,getCharName(x) + "|" + getCharValue(x),NULL_KEY);
		                		sendToHud("exp|" + getCharName(x) + ":" + getCharValue(x));
		                		++x;
		            		}
		            		while (x < llGetListLength(chardata) / 2);
		            		llOwnerSay(xpmsg);
	            		}
	            		else if (left(body,"||") == "LEVELLED")
	            		{
	                		list lvldata = llParseString2List(right(body,"||"),["|"],[""]);
	                		if (llGetListLength(lvldata) == 4)
	                		{
	                			llPlaySound("5b3537a9-ba4b-70e4-a409-42f061347735",1);
                				llMessageLinked(LINK_SET,10,"7|5|",NULL_KEY);
	                    		llSay(0, llKey2Name(me) + " is now level " + llList2String(lvldata,1) + "/" + llList2String(lvldata,3));
	                		}
	                		else
	                		{
	                			llPlaySound("5b3537a9-ba4b-70e4-a409-42f061347735",1);
                				llMessageLinked(LINK_SET,10,"7|5|",NULL_KEY);
                				llSay(0, llKey2Name(me) + " is now level " + llList2String(lvldata,1));
	                		}
	                		sendToHud("RESET");
	                		llSleep(0.2);
	                		llMessageLinked(-4,1,"doreset",NULL_KEY);
	            		}
	            		else if (left(body,"||") == "KILL")
	            		{
	            			//llOwnerSay(body);
	            			// format should be KILL||BOUTID/KILLAMT|^NEWXP
	            			string tmp=right(body, "||");
	            			string boutid=left(tmp, "/");
	            			string tmpxp=right(tmp, "^");
	            			string killamt=left(right(body, "/"),"^");
	            			llOwnerSay("You lose " + killamt + " xp.  Current xp is " + tmpxp);	
	            			//llOwnerSay("sending boutid " + boutid);
	            			llMessageLinked(LINK_THIS, 7351, boutid, NULL_KEY); 
	            		}
	            		else if (left(body,"||") == "SKILL")
	            		{
	                		llMessageLinked(-4,1,body,NULL_KEY);
	                		if (numLoaded <= 10) //Changed from 15 to 10
	                		{
	                			++numLoaded;
	                			llSleep(0.1); //0.15s longer wait
	                		}
	                		else
	                		{
	                			//llOwnerSay("throttle");
	                			llSleep(6);
	                			numLoaded = 5; //Load another 5 before throttleling again
	                		}
	                		getSkills(skills);
	            		}
			        }
	            }
	        }
    	}
    }
    http_request(key id, string method, string body)
    {
        if (url_request == id)
        {
            url_request = "";
            if (method == URL_REQUEST_GRANTED)
            {
                myURL=llEscapeURL(body);
                llHTTPRequest(regURL() + "?myURL=" + myURL, [], "");
            }
        }
        else
        {
            llHTTPResponse(id, 200, body);
            if (body=="RESET")
            {
            	llMessageLinked(-4,1,"doreset",NULL_KEY);
            }
        }
    }
    
    timer()
    {
        if (checkComplete() == 1)
        {
            llOwnerSay("Data load from server complete. Type /9skills to view a list of skills available to your character");
            llMessageLinked(-4,1,"LOADCOMPLETE|1",NULL_KEY);
            llSetTimerEvent(0);
        }
    }
}
