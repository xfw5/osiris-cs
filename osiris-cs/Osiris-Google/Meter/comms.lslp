// known channel numbers for llMessageLinked


// 0 - messages to dataloader
// 1 - messages from dataloader
// 2 - password reset
// 3 - announce damage channel
// 4 - unused
// 5 - sets encryption password
// 6 - commands against target, to be routed for damage or sent to target
// 7 - status messages from main (i.e. wounded, noncombative, whatever)
// 8 -- status messages to main
// 10 - commands to particle system
// 12 - notice that we have comms with the HUD
// 13 - counter of skills loading
// 14 - sends command to list skills
// 15 - send command to comms script to say message to owner
// 16 - send command to comms script to say message in chat
// 17 - send command to comms script to shout message
//12000 - Load tournament mode
//12001 - dataloader: tourn mode loaded
//10000 - Send data to RAM
//10001 - Get data from RAM
//11000 - Send text and functions to translator in RAM script
//9999 - pass damage to dmgHandler
//9998 - health status announcements
//9997 - melee fighting system announcements
//9996 - ranged fighting system announcements
//9995 - 
//9990 - max health announcement
//9985 - current stamina annoucement
//9981 - stamina tick & rage downtick if ragetype
//9980 - health tick;
//9970 - special percentage announcements
//9971 - special actual announcements
//9960 - API script - list of available skills
//9950 - Commands passed by the player
//9940 - Skills and API effects passed to the skills script
//9939 - COmmands from dmgHandler to skills
//9930 - Health +/- effects passed from API
//9931 - Stamina +/- effects passed from API
//9932 - Tstat +/- passed from API
//9934 - DOT passed from dmgHandler
//9935 - BUFF passed from dmgHandler
//99350 - BUFF status passed from character
//9936 - Meditate on command (freezes avatar in place)
//9937 - Meditate off command (unfreezes avatar)
//9920 - tells API to tick special up one for rage type special
//9910 - announces last person who hit me
//8000 - challenge/authentication
//8001 - response
//8050 - ok signal ... send encrypted


// Commands specific to the vendor API
//7500 - Send Melee weapon API spec to melee script
//7501 - Send clear melee details to API script
//7502 - Sends ranged weapon signal to main, format is num 7502, key target
//7503 - Receives incoming ranged weapon signal in damagehandler, sent to ranged to deal with dmg and list of bullets

//7300 - Capture mode on
//7301 - capture mode off
//7350 - message to dataloader: we DIED do the xp thing!
//7351 - signal from dataloader to main: send bout ID to the winner
//7352 - infoming signal with the boutid -- dataloader grabs and gets the xp

//7000 - updates intended for hud
//6500 - set color for meter
//6501 - set title
//6502 - hide GM status
//6503 - show GM status
//6504 - XP drop details
//6300 - statistics announcements
//5000 - triggers gm menu

//4000 - send signal to targeting to run sensor and present dialog
//4001 - send signal to targeting to cast specific skill at _name_
//4002 - send signal to targeting to set target by name

//3333 - xp drops
//2223 - gm permissions - signal to turn on radio
//2222 - announcement from GM script of status/name
//1150 - commands to anticamp
//1111 - command to check region for dataloader

//9797 - debug command for scripters

//999999 - self destruct!!!!!!

// comms - LSL Script 

// CHALLENGE/AUTHENTICATION
string secureKey="";
string securePass;
string myKey="";
string randCheck;
integer localchannel;
integer gmhudchan=-9783421;
integer listener;
integer commandlistener;
integer commandchannel=98;
integer gmstatus; // current GM status

//******** Encryption from old Erie Staff Hud **********//
//encryption
string pass="";
string crypt (string str)
{
    return llXorBase64StringsCorrect(llStringToBase64(str), llStringToBase64(pass));
}
string decrypt (string str)
{
    return llBase64ToString(llXorBase64StringsCorrect(str, llStringToBase64(pass)));
}
setGMLevel(integer n)
{
gmstatus=n;	
}
setchannel(integer chan)
{
    llListenRemove(listener);
    localchannel=chan;
    llOwnerSay("Radio currently listening on channel " + (string)localchannel + ". To change, type /98 setchannel");
    listener=llListen(localchannel, llKey2Name(llGetOwner()),llGetOwner(),"");
    
}
// ****** end encryption ********///
setRandCheck()
{
    randCheck=(string)llFrand(9999999999.0)+ (string)llFrand(9999999999.0);
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
sayMessage(integer num, integer messageID, string str, key id) {
	string message;
	// set the message
	if (messageID==1) {message="You may only wear one Osiris meter at a time.";}
	else if (messageID==2) {message="Your sim has enabled capture mode, type /9cap to enable. /9endcap to red flag and terminate capture";}
	else if (messageID==3) {message="Your roleplay name in this sim has been set to " + str;}
	else if (messageID==4) {message="You may not enter tournament mode while dead or captured";}
	else if (messageID==5) {message="You may not enter tournament mode while injured";}
	else if (messageID==6) {message="You may not reset unless your health is above 75";}
	// say it
	if (num==15) {llOwnerSay(message);}
	else if (num==16) {llSay(0, message);}
	else if (num==17) {llShout(0, message);}
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
            string response="comms|"+ randCheck + "||" + myKey;
            llMessageLinked(LINK_THIS, 8001, cryptPass(response), NULL_KEY);   
        }
}

default
{
    state_entry()
    {
        createSecurePass();         
    }
     link_message(integer sender_num, integer num, string str, key id)
    {
        if (num==8000) {receiveChallenge(str);}
        else if (num==2223) { state radio;}
        else if (num==15) {sayMessage(15, num, str, id);}
        else if (num==16) {sayMessage(16, num, str, id);}
        else if (num==17) {sayMessage(17, num, str, id);}
    }  
    
 
}
state radio
{
	state_entry()
	{
		setchannel(12);
        commandlistener=llListen(commandchannel, llKey2Name(llGetOwner()),llGetOwner(),"");
		
	}	
	listen(integer channel, string name, key id, string message)
    {
        if (channel == commandchannel)
        {
            integer newchannel=(integer)llStringTrim(right(message, "setchannel"),STRING_TRIM);
            setchannel(newchannel);
        }
        else if (channel == localchannel)
        {
           llRegionSay(gmhudchan, crypt(name + ": " + message));
           llOwnerSay(name + ": " + message);
        }
    }
    link_message(integer sender_num, integer num, string str, key id)
    {
        if (num==8000) {receiveChallenge(str);}
        else if (num==15) {sayMessage(15, num, str, id);}
        else if (num==16) {sayMessage(16, num, str, id);}
        else if (num==17) {sayMessage(17, num, str, id);}
        else if (num==1) // input is coming from dataloader
        {
            if (left(str, "|") == "GMLEVEL")
            {
                setGMLevel((integer)right(str,"|")); 
                if (gmstatus < 4)
                {
                state default;
                }
            } 
            
        }
    }  
}