//GM UTILITIES
// format for incoming http msg with gm status: [8:40]  RPCS 0.64: GM|10^10000|1|0|1|1|Lead GM 
// GMLEVEL^|xplimit^staffradio|banlimit (num hours)|allowban|allow rez from rezzerbox|title
//
// To be done: Clean up script, finalize functions, secure, etc etc blah blah

integer gmchannel;
integer gmstatus;
integer IsGM;
key me;
// this channel is not actually 1
integer gmhudchan=-1; // channel for receiving messages on the hud
integer gmbanchan=-1; // channel for ban messages
integer mainchannel=-4532135; // menu channel
integer gmlistener; // listener for gm hud messages
integer dialoglistener; // listener for dialogboxes
string pass=""; // password for encrypted comms
integer xpamt; // passed to state xpdrop
integer xplimit;
integer banlimit;
integer allowban;
integer allowrez;
integer radio;
string gmname;


// security stuff
// **************************************************

// CHALLENGE/AUTHENTICATION
string secureKey="";
string securePass;
string myKey="";
string randCheck;

list gmmenu=["Ban","Remove Ban"];
integer showGM=1; // toggles whether or not to show gm status
integer displayGM; // sim owner option whether or not gms can hide their status
list xpmenu;
list mainmenu=["Drop XP","Monster"];
list displaymenu=["Hide status","Show status"];
list banreasons=["Abuse","Harassment","OOC Bash","Rule breaking","Other"];
list banduration=["1 hour","1 day","3 days"];
list monster=["Eyeball","Rats","Ghost"];
integer mute;//determines whether or not the staff radio is muted
list people; // list of ppl
list radiocache; // list of messages in radio cache when the radio is muted
string rezzerbox; // key of the rezzerbox in our current sim
integer currentxplimit=-500; // xp available to be given

//http request items
string playerurl="";
string keyurl=""; //returns avatar key by name
key http_request_id;
integer http_ok; // determines if ok to send http request, 1 yes, 0 no

// mutes incoming messages
Mute()
{
 mute=1;
}
UnMute()
{
 mute=0;
 integer n;
 integer length = llGetListLength(radiocache);
 for (; n < length; ++n) {
    llOwnerSay(llList2String(radiocache, n) + "\n");
    }
radiocache=[""];
llMessageLinked(LINK_SET,-997,"",NULL_KEY);
}
addCache(string msg)
{
    radiocache=radiocache + [msg]; 
    integer freemem=llGetFreeMemory();  
    integer listlength = llGetListLength(radiocache);
    llMessageLinked(LINK_SET,-997,(string)listlength,NULL_KEY);
    if (freemem < 4096)
        {
            llOwnerSay("Radio cache is running out of memory, unmuting. You can switch it back once the message cache is clear.");
            UnMute();   
        }
}

setRandCheck()
{
    randCheck=(string)llFrand(9999999999.0)+ (string)llFrand(9999999999.0);
}
createSecurePass()
{
  securePass="Pain in the ass password" + llGetDate();   
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
            string response="GM|"+ randCheck + "||" + myKey;
            llMessageLinked(LINK_THIS, 8001, cryptPass(response), NULL_KEY);   
        }
}
string crypt(string str){
    return llXorBase64StringsCorrect(llStringToBase64(str),llStringToBase64(pass));
}
string decrypt(string str){
    return llBase64ToString(llXorBase64StringsCorrect(str,llStringToBase64(pass)));
}
integer generateChannel(string text){
	return ((-2 * ((integer)("0x" + llGetSubString(text,-5,-1)))) - 173000);
}
integer randInt(integer n)
{
     return (integer)llFrand(n + 1);
}
setGMChannel()
{
    gmchannel=randInt(500000)-450000;    
}
integer GMStatus;

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
setme() {me=llGetOwner();}

// Converts float to a smaller decent string
string Float2String ( float num, integer places, integer rnd) { 
//allows string output of a float in a tidy text format
//rnd (rounding) should be set to TRUE for rounding, FALSE for no rounding
 
    if (rnd) {
        float f = llPow( 10.0, places );
        integer i = llRound(llFabs(num) * f);
        string s = "00000" + (string)i; // number of 0s is (value of max places - 1 )
        if(num < 0.0)
            return "-" + (string)( (integer)(i / f) ) + "." + llGetSubString( s, -places, -1);
        return (string)( (integer)(i / f) ) + "." + llGetSubString( s, -places, -1);
    }
    if (!places)
        return (string)((integer)num );
    if ( (places = (places - 7 - (places < 1) ) ) & 0x80000000)
        return llGetSubString((string)num, 0, places);
    return (string)num;
}

integer duration; // how long we are banning
string reason; // why ban or warn
string bannedperson; // name of person being banned or warned
key banid; // key of person being banned or warned
integer reasonchannel=-45673675; // specific channels for ban dialogs
integer durationchannel=-45673679; // specific channels for ban dialogs
integer banchannel=8; // for menu dialog to ban individuals

doBan(key uid,string name, string cause, integer time)
{
    string banmsg="BAN:"+(string)llGetOwner()+"^"+llKey2Name(llGetOwner())+"|"+(string)uid+"^"+name+"||"+(string)time;
    llRegionSay(gmbanchan,crypt(banmsg));
    string reportmsg="GM|" + llKey2Name(llGetOwner()) + " banned " + name + " for " + cause + ", duration " + (string)time + " hours";
    //llRegionSay(gmhudchan,crypt(reportmsg));
    llOwnerSay(reportmsg);
}
unBan(key uid,string name)
{
    string banmsg="UNBAN:"+(string)llGetOwner()+"^"+llKey2Name(llGetOwner())+"|"+(string)uid+"^"+name;
    llRegionSay(gmbanchan,crypt(banmsg));
    string reportmsg="GM|" + llKey2Name(llGetOwner()) + " un-banned " + name;
    llOwnerSay(reportmsg);
    llRegionSay(gmhudchan,crypt(reportmsg));
}
setduration(string dur)
{
    if (dur=="1 hour") duration=1;
    else if (dur=="1 day") duration=24;
    else if (dur=="3 days") duration=72;
    else if (dur=="1 week") duration=168;
    else if (dur=="2 weeks") duration=336;
    else if (dur=="1 month") duration=720;
    else if (dur=="3 months") duration=2160;
    else if (dur=="Permanent") duration=0;
}
addreason(string msg)
{
    reason=msg ;  
}
setkey(key givenuid)
{
   // llOwnerSay("setting key to " + (string)givenuid);
    banid=givenuid;
}
// ******** SIM FUNCTIONS ****************

// Set rezzer box key for emails
// to be implemented
setRezzerBox()
{
}


sethttp_ok(integer status)
{
    http_ok=status;   
}

// requests gm status from database
getgmstatus()
{
   if (http_ok==1)
   {
       sethttp_ok(0);
       //llOwnerSay("requesting gm status");
    http_request_id = llHTTPRequest("", [], "");
   }
}
// sets gmstatus based on return from database


setgmstatus(string gm)
{
	//llOwnerSay(gm);
	mainmenu=[];
	banduration=[];
	gmstatus=(integer)left(gm, "^");
	if (gmstatus == 0) {return;}
	list gmperms=llCSV2List(right(gm,"^"));
	xplimit=llList2Integer(gmperms, 0);
	radio=llList2Integer(gmperms, 1);
	banlimit=llList2Integer(gmperms, 2);
	allowban=llList2Integer(gmperms, 3);
	allowrez=llList2Integer(gmperms, 4);
	gmname=llList2String(gmperms,5);
	
	if (displayGM==1) {mainmenu=mainmenu + ["Display"];}
 	
 	
 	// loop through the xp menu and add any values which are less than the limit
 	if (xplimit > 0)  {
 		list tempxpmenu=[5,10,25,100,250,500,1000];
 		mainmenu=mainmenu + ["Drop XP"];
 		integer i;
 	do {
 		if (llList2Integer(tempxpmenu,i) < (xplimit+1)) {
	 		xpmenu=xpmenu + [llList2String(tempxpmenu, i)];}
 		++i;
 	} while (i < llGetListLength(tempxpmenu));
 	}
 	
	if (allowban == 1) {
		if (banlimit>0 && banlimit < 24) {banduration=banduration+["1 hour"];}
		else if (banlimit==24) {banduration=banduration+["1 hour","1 day"];}
		else if (banlimit==72) {banduration=banduration+["1 hour","1 day","3 days"];}
		else if (banlimit==168) {banduration=banduration+["1 hour","1 day","3 days","1 week"];}
		else if (banlimit==720) {banduration=banduration+["1 hour","1 day","3 days","1 week","1 month"];}
		else if (banlimit==0) {banduration=banduration+["1 hour","1 day","3 days","1 week","1 month","Permanent"];}
		mainmenu=mainmenu + ["Ban","Remove Ban"];
	}
	
	//if (allowrez == 1) {mainmenu=mainmenu+["Rezzers"];}
	if (radio == 1) {
		mainmenu=mainmenu+["Mute","UnMute"];
		llMessageLinked(LINK_THIS, 2223,"",NULL_KEY);
		}
	if (allowrez==1 | allowban==1 | xplimit > 0)
		{IsGM=1;}
}
// request amount of xp dropped
getCurrentXPLimit()
{
    if  (http_ok==1)
    {
    sethttp_ok(0);
    http_request_id = llHTTPRequest("", [], "");
    }
}
// set amount of available xp based on how much dropped previously
setxpstatus(integer xpdropped)
{    
    if (currentxplimit==-500) {currentxplimit=xplimit;}
    currentxplimit=xplimit - xpdropped;
    llOwnerSay("You have dropped " + (string)xpdropped + " xp today, with " + (string)currentxplimit + " available");
}

// drop xp on a group of players
dropXP(integer amount)
{
    xpamt=amount; 
}
//******************* MAIN FUNCTION TO PROCESS RESPONSES FROM DIALOG *********
processresponse(string message)
{
   
}

// INITIALIZES THE SCRIPT, CALLS FUNCTIONS TO GET IT UP AND RUNNING
init()
{
    // set initial values for scanner
    // reset variables so the gm menus don't go too long
    setGMChannel();
    banreasons=["Abuse","Harassment","OOC Bash","Rule breaking","Other"];
    sethttp_ok(1);
    llListenRemove(gmlistener);
    gmlistener=llListen(gmhudchan,"",NULL_KEY,"");
    llListenRemove(dialoglistener);
    dialoglistener=llListen(mainchannel,llKey2Name(llGetOwner()),llGetOwner(),"");
    setRezzerBox();  
}

default
{
    state_entry()
    {
        createSecurePass(); 
        setme();
        llListenRemove(gmlistener);
        llListenRemove(dialoglistener);
        llSetTimerEvent(10.0);
    }
    link_message(integer sender_num, integer num, string str, key id)
    {
        
        //else  if ((num == 5)) setpass(str);
        if (num==8000) {receiveChallenge(str);}
        else if (num==1)
            {
            string param=left(str,"|");
        	if (param=="LOADCOMPLETE") {
                getgmstatus();
                llSetTimerEvent(10.0);
        	} else if (param == "DISPLAYGM") displayGM=(integer)right(str, "|");
        }
        
    }
    http_response(key request_id, integer f_Status, list metadata, string body)
    {
        sethttp_ok(1);
        integer status;
        if (request_id == http_request_id) 

        {
            
            if(f_Status == 200)
            {

                if (left(body,"|")=="GM")
                {
                   //llOwnerSay(body);
                   setgmstatus(llStringTrim(right(body,"|"),STRING_TRIM)); 
                   llSetTimerEvent(2.0);
                   
                }
            }
            else if(f_Status != 200)
            {
                
            //llOwnerSay("Having trouble reaching the web server, delaying for 5 minutes and will try again.");
            llSetTimerEvent(20);
            }
        }
        
    }
    changed(integer f_Changed)
    {
        if (f_Changed & CHANGED_OWNER) llResetScript();
    }
    timer()
    {
    	llSetTimerEvent(0.0); // kill the timer so it won't keep requesting it over and over and over again :O
    	if (IsGM==1) {
    		state GM;
    	}
    }
    
}
state GM
{
    state_entry()
    {
        init() ;   
        getCurrentXPLimit();
        llMessageLinked(LINK_THIS, 2222, gmname, NULL_KEY);
        llSetTimerEvent(60);   
    }
    link_message(integer sender_num, integer num, string str, key id)
    {
        if (num==5000) {llDialog(me, "Please select an option", mainmenu, mainchannel);}
        else if (num==8000) {receiveChallenge(str);}
        else if (num==6502 && displayGM==1) {
        	showGM=0;
        	}
        else if (num==6503) {
        	showGM=1;;
        	}
        else if (num==1) {
        	if (str == "DISPLAYGM|0") {displayGM=0;}
        	else if (str == "DISPLAYGM|1") {displayGM=1; mainmenu=mainmenu+["Display"];}
        }
    }
    changed(integer f_Changed)
    {
        if (f_Changed & CHANGED_OWNER) llResetScript();
    }
    http_response(key request_id, integer f_Status, list metadata, string body)
    {
        sethttp_ok(1);
        integer status;
        if (request_id == http_request_id) 
        //llOwnerSay(body);
        {
            if(f_Status == 200)
            {
                
                if (left(body,"|")=="GM")
                {
                   setgmstatus(llStringTrim(right(body,"|"),STRING_TRIM));  
                }
                else if (left(body,"|")=="XPDROP")
                {
                    setxpstatus((integer)right(body,"|"));   
                }
            }
        }
        
    }
       listen(integer channel, string name, key id, string message)
    {
        if (channel==gmhudchan)
        {
        	if (mute==0) {
            	llOwnerSay(decrypt(message));
        	} else if (mute==1) {
        		addCache(decrypt(message));
        	}
        }
        else if (channel==mainchannel)
        {
                
                if (message=="Monster") llDialog(llGetOwner(),"Select monster",monster,mainchannel);
                // xp drops
                else if (message=="Drop XP") llDialog(llGetOwner(),"Select amount",xpmenu,mainchannel);
                else if (message=="Display") llDialog(llGetOwner(),"Show or hide GM status",displaymenu, mainchannel);
                else if (message=="Hide status") llMessageLinked(LINK_THIS, 6502, "", NULL_KEY);
                else if (message=="Show status") llMessageLinked(LINK_THIS, 6503, "", NULL_KEY);
                else if (message=="5") {dropXP(5); state xpdrop;}
                else if (message=="10") {dropXP(10);state xpdrop;}
                else if (message=="25") {dropXP(25);state xpdrop;}
                else if (message=="100") {dropXP(100);state xpdrop;}
                else if (message=="250") {dropXP(250);  state xpdrop;} 
                else if (message=="500") {dropXP(500); state xpdrop;}
                else if (message=="1000") {dropXP(1000); state xpdrop;} 
                // end xp drops
                else if (message=="Ban") {state ban;} 
                else if (message=="Remove Ban") {state unban;}  
                else if (message=="Mute") {Mute();}
                else if (message=="UnMute") {UnMute();}
        
        }
        else if (channel==banchannel)
        {
            // if its coming in on this channel, that means it's someone's name
            llListenRemove(dialoglistener);
            bannedperson=message;
            llOwnerSay("You selected " + bannedperson);
            // we have the name, let's make sure we have the key of the person being banned
            sethttp_ok(0);
            http_request_id=llHTTPRequest(keyurl + "?name=" + llEscapeURL(message),[],"");
            
            llDialog(llGetOwner(),"Select the reason they are being banned",banreasons,reasonchannel);
            dialoglistener=llListen(reasonchannel,llKey2Name(llGetOwner()),llGetOwner(),"");
            llSetTimerEvent(120);
        }
        if (channel==reasonchannel) // if this comes in on the reason channel it will be the reason they are being banned
            {
                //addreason(message);
                reason=message;
                llOwnerSay("You are banning " + bannedperson + " for " + reason);
                llDialog(llGetOwner(),"How long?",banduration,durationchannel);
                dialoglistener=llListen(durationchannel,llKey2Name(llGetOwner()),llGetOwner(),"");
                llSetTimerEvent(120);
            }
        if (channel==durationchannel) // duration of ban
            {
                setduration(message);
                llSetTimerEvent(120);
                doBan(banid,bannedperson,reason,duration);
                state default;
        }
    } 
    timer()
    {
    	llSensor("",NULL_KEY, AGENT, 96, PI);	
    	llMessageLinked(LINK_THIS, 2222, gmname, NULL_KEY);
    }
    sensor(integer total_number)
    {
        	integer i;
            if (i < total_number)
            {
                if (llListFindList(people, [llDetectedName(i)]) == -1)
                {
                        http_request_id=llHTTPRequest(playerurl+"?key=" + llEscapeURL((string)llDetectedKey(i)) + "&avatar=" + llEscapeURL(llDetectedName(i)), [],"");
                        people=people + llDetectedName(i);
            	}
			i++;
        	}
        if (llGetListLength(people) > 100)
        {people=[""];}
    }
    
    
}

state xpdrop {
    state_entry() {
       if (xpamt > currentxplimit) {
           llOwnerSay("Sorry, that exceeds your xp limits for today.");
           state GM;
       }
       else {
       		llMessageLinked(-4,6504,(string)xpamt,"");
       		llOwnerSay(llKey2Name(me) + "dropped " + (string)xpamt + "xp");
       		llRegionSay(gmhudchan, crypt(llKey2Name(me) + "dropped " + (string)xpamt + "xp"));
       		http_request_id = llHTTPRequest("someurl" + (string)llGetOwner() + "&amount=" + (string)xpamt, [], "");  
			state GM;
       }
    }
}

state ban
{
    state_entry()
    {
        llOwnerSay("Please type the name of the person you are banning:\n/8 name\nThe name must be typed in exact and is case sensitive.");        
        dialoglistener=llListen(banchannel,llKey2Name(llGetOwner()),llGetOwner(),"");
        llSetTimerEvent(300);
    }
    timer()
    {
    // make sure we don't get stuck in this state
        llListenRemove(dialoglistener);
        llOwnerSay("No response received, switching back to default state");
        state default;    
    }  
    listen(integer channel, string name, key id, string message)
    {
        if (channel==gmhudchan)
        {
            llOwnerSay(decrypt(message));
        }
        else if (channel==banchannel)
        {
            // if its coming in on this channel, that means it's someone's name
            llListenRemove(dialoglistener);
            bannedperson=message;
            llOwnerSay("You selected " + bannedperson);
            // we have the name, let's make sure we have the key of the person being banned
            sethttp_ok(0);
            llOwnerSay("Requesting avatar key for " + bannedperson);
            http_request_id=llHTTPRequest(keyurl + "?name=" + llEscapeURL(bannedperson),[],"");


        }
        if (channel==reasonchannel) // if this comes in on the reason channel it will be the reason they are being banned
            {
                //addreason(message);
                reason=message;
                llOwnerSay("You are banning " + bannedperson + " for " + reason);
                llDialog(llGetOwner(),"How long?",banduration,durationchannel);
                dialoglistener=llListen(durationchannel,llKey2Name(llGetOwner()),llGetOwner(),"");
                llSetTimerEvent(120);
            }
        if (channel==durationchannel) // duration of ban
            {
                setduration(message);
                llSetTimerEvent(120);
                doBan(banid,bannedperson,reason,duration);
                state default;
        }
    } 
     link_message(integer sender_num, integer num, string str, key id)
    {
        if (num==5000) {llDialog(me, "Please select an option", mainmenu, mainchannel); state GM;}
        else if (num==8000) {receiveChallenge(str); state default;}
    }
     http_response(key request_id, integer status, list metadata, string body)
    {
        sethttp_ok(1);
        if ((key)llStringTrim(body,STRING_TRIM))
        {
	        setkey((key)llStringTrim(body, STRING_TRIM));
	        llOwnerSay("Received key for " + bannedperson + "(" + (string)banid + ")");
	        llDialog(llGetOwner(),"Select the reason they are being banned",banreasons,reasonchannel);
	        dialoglistener=llListen(reasonchannel,llKey2Name(llGetOwner()),llGetOwner(),"");
        }  
        else
        {
        	llOwnerSay("Could not retrieve a valid key for " + bannedperson + ".  Are you sure you spelled the name correctly? Please try again.");
        	state GM;	
        }  
    }
 
}
// ************* REMOVE BAN FUNCTION *****************
state unban
{
    state_entry()
    {
        string msg="Please type the name of the person you wish to unban, example:\n/8 name\nThe name must be typed in exact and is case sensitive.";
        llOwnerSay(msg);
        dialoglistener=llListen(banchannel,llKey2Name(llGetOwner()),llGetOwner(),"");
        llSetTimerEvent(300);
    }
    timer()
    {
    // make sure we don't get stuck in this state
        llListenRemove(dialoglistener);
        llOwnerSay("No response received, switching back to default state");
        state GM;    
    }  
    listen(integer channel, string name, key id, string message)
    {
        if (channel==gmhudchan)
        {
            llOwnerSay(decrypt(message));
        }
        else if (channel==banchannel)
        {
            // if its coming in on this channel, that means it's someone's name
            llListenRemove(dialoglistener);
            bannedperson=message;
            llOwnerSay("You selected " + bannedperson);
            // we have the name, let's make sure we have the key of the person being banned
            sethttp_ok(0);
            http_request_id=llHTTPRequest(keyurl + "?name=" + llEscapeURL(bannedperson),[],"");

            }
        if (channel==durationchannel) // duration of ban
            {
                llSetTimerEvent(20);
                unBan(banid, bannedperson);
                state GM;
        }
    }
    link_message(integer sender_num, integer num, string str, key id)
    {
        if (num==5000) {llDialog(me, "Please select an option", mainmenu, mainchannel); state GM;}
        else if (num==8000) {receiveChallenge(str); state default;}
    } 
     http_response(key request_id, integer status, list metadata, string body)
    {
        sethttp_ok(1);
        if ((key)llStringTrim(body,STRING_TRIM))
        {
        	setkey((key)llStringTrim(body, STRING_TRIM));
        	llOwnerSay("Received key for bannedperson: " + (string)banid);
	        llDialog(llGetOwner(),"You are removing " + bannedperson + " from the ban list.",["Ok"],durationchannel);
	        dialoglistener=llListen(durationchannel,llKey2Name(llGetOwner()),llGetOwner(),"");
	        llSetTimerEvent(30);
        }    
    }
 
}
