// things to check
// have I been rezzed?
// get list of scripts.  Are all of them created by Colleen?
// check the texture on the outside of rpcs.  Is it the correct one?
// was the prim created by colleen?
// are permissions on all  scripts and the main prim no-mod/copy/transfer?
// are the primitize params (size etc) correct?
// do I have the right number of scripts inside of me? 
// do all of the scripts have the right names?
// correct # of prims?
// have I been attached to hud?
// do a llregionsay to find out if owner has any other copies of rpcs rezzed or attached elsewhere



// Initial declarations of variables
// *********************************

integer debug=0;
string myKey="";
key colleen="aa3457ab-3f55-4341-ae89-2a9c2baaa452";
key liace="";
key hermit="";
string main="";
string API="";
string character="";
string comms="";
string dataloader="";
string dmgHandler="";
string GM = "";
string melee="";
string particles="";
string password="";
string ranged="";
string sim="";
string skills="";
string meter="";
string anticamp="";
string preloader="";
string capture="";
string ram="";
string targeting="";
// check keys
string maincheck;
string APIcheck;
string charactercheck;
string commscheck;
string dataloadercheck;
string dmgHandlercheck;
string GMcheck;
string meleecheck;
string particlescheck;
string passwordcheck;
string rangedcheck;
string simcheck;
string skillscheck;
string metercheck;
string anticampcheck;
string preloadercheck;
string capturecheck;
string ramcheck;
string targetingcheck;
integer fail; // running total of number of failures
integer error; // 1 or 0, to determine if one of the scripts has failed authentication
integer avatar=0; // what the hell is this used for?
list scripts=["anticamp","API", "meter", "capture", "character", "comms", "dataloader", "dmgHandler", "GM", "main", "melee", "password", "ram", "ranged", "security", "sim", "skills", "targeting"];

string pass;
string initialpass;
string randCheck;

// Creates initial password (based on date) to challenge the other scripts
// plus the new password which will be passed to the other script. They'll reply
// using the new password
createPass()
{
    initialpass="";
    pass=randomPass(24);  
}
// encrypt using the standard password
string crypt (string str)
{
    return llXorBase64StringsCorrect(llStringToBase64(str), llStringToBase64(pass));
}
// encrypt using the initial password
string initialCrypt (string str)
{
    return llXorBase64StringsCorrect(llStringToBase64(str), llStringToBase64(initialpass));
}
// decrypt (uses standard password only
string decrypt (string str)
{
    return llBase64ToString(llXorBase64StringsCorrect(str, llStringToBase64(pass)));
}
// send linked message challenging other scripts to authenticate
sendChallenge()
{
    string msg="security|" + pass + "||" + myKey;
    if (debug==1) {llOwnerSay("sending challenge: " + msg);}
    llMessageLinked(LINK_SET, 8000, initialCrypt(msg),NULL_KEY); 
}
// receive authentication challenge from main
getChallenge(string msg)
{
    
    string message=decrypt(msg);
    if (debug==1) {llOwnerSay("Received challenge from main: " + message);}
    if (left(message,"|")=="MAIN" && right(message,"||")==main)
    {
    if (debug==1) {llOwnerSay("Responding to challenge from main");}
    string response="SECURITY|" + randomPass(12) + "||" +  myKey;
    llMessageLinked(LINK_THIS,8003,crypt(response), NULL_KEY); 
    }
}
// generates a random password
string randomPass(integer length)   {
    string letters = "abcdefghijkmnopqrstuvwxyz234567890!@#$$%^&";
    string rPass;
    while(llStringLength(rPass) < length)   {
        integer rand = llFloor(llFrand(llStringLength(letters)));
        rPass += llGetSubString(letters,rand,rand);
    }
    return rPass;
}
// increment number of failures
incrementfail()
{
 ++fail;
 if (debug==1) {llOwnerSay("Auth failures: " + (string)fail);}  
}
// check the responses from each of the other scripts
checkResponse()
{
    // this routine will check the keys sent back by each of the other scripts to make sure they are correct   
   if (debug==1) {llOwnerSay("Checking responses");}
    error=0;
  //  
    if (character != charactercheck) {error=1;if (debug==1) {llOwnerSay("character failed");}}
    if (comms != commscheck) {error=1;if (debug==1) {llOwnerSay("comms failed");}}
    if (dataloader != dataloadercheck) {error=1;if (debug==1) {llOwnerSay("dataloader failed");}}
    if (dmgHandler != dmgHandlercheck) {error=1;if (debug==1) {llOwnerSay("dmgHandler failed");}}
    if (GM != GMcheck) {error=1;if (debug==1) {llOwnerSay("GM failed");}}
    if (melee != meleecheck) {error=1;if (debug==1) {llOwnerSay("melee failed");}}
    if (particles != particlescheck) {error=1;if (debug==1) {llOwnerSay("particles failed");}}
    if (password != passwordcheck) {error=1;if (debug==1) {llOwnerSay("password failed");}}
    if (ranged != rangedcheck) {error=1;if (debug==1) {llOwnerSay("ranged failed");}}
    if (sim != simcheck) {error=1;if (debug==1) {llOwnerSay("sim failed");}}
    if (skills != skillscheck) {error=1;if (debug==1) {llOwnerSay("skills failed");}}
    if (meter != metercheck) {error=1; if (debug==1) {llOwnerSay("meter failed");}}
    if (anticamp != anticampcheck) {error=1; if (debug==1) {llOwnerSay("anticamp failed");}}
    if (preloader != preloadercheck) {error=1; if (debug==1) {llOwnerSay("preloader failed");}}
    if (capture != capturecheck) {error=1; if (debug==1) {llOwnerSay("capture failed");}}
    if (ram != ramcheck) {error=1; if (debug==1) {llOwnerSay("ram failed");}}
    if (targeting != targetingcheck) {error=1; if (debug==1) {llOwnerSay("targeting failed");}}
    
    if (error==0)
     {fail=-100; if (debug==1) {llOwnerSay("Initial checks passed");}}
    else if (error>0)
    {
    incrementfail();
     llSleep(1);
     sendChallenge();
    }
    else if (fail > 10) {
    disable();
    }
}
// decrypt responses from other scripts and store in variable
setKey(string msg)
{
    string message=decrypt(msg);
    if (debug==1) {llOwnerSay("Received response: " + message);}
    string source=left(message, "|");
    string sourceKey=right(message, "||");
   // llOwnerSay(message);
    if (source=="main" && sourceKey==main && maincheck=="")
        {
            maincheck=sourceKey;
            if (main !=maincheck) {error=1;llOwnerSay("main");}
        }
    if (source=="GM" && sourceKey==GM && GMcheck=="")
        {
            GMcheck=sourceKey;  
        }
    if (source=="dataloader" && sourceKey==dataloader && dataloadercheck=="")
        {
            dataloadercheck=sourceKey;  
        }    
     if (source=="API" && sourceKey==API && APIcheck=="")
        {
            APIcheck=sourceKey; 
            if (API !=APIcheck) {error=1;llOwnerSay("API");} 
        }  
     if (source=="capture" && sourceKey==capture && capturecheck=="")
     	{
     		capturecheck=sourceKey;
     	}      
     if (source=="character" && sourceKey==character && charactercheck=="")
        {
            charactercheck=sourceKey;  
        } 
     if (source=="comms" && sourceKey==comms && commscheck=="")
        {
            commscheck=sourceKey;  
        }        
     if (source=="dmgHandler" && sourceKey==dmgHandler && dmgHandlercheck=="")
        {
            dmgHandlercheck=sourceKey;  
        }
     if (source=="melee" && sourceKey==melee && meleecheck=="")
        {
            meleecheck=sourceKey;  
        }       
     if (source=="particles" && sourceKey==particles && particlescheck=="")
        {
            particlescheck=sourceKey;  
        }
     if (source=="password" && sourceKey==password && passwordcheck=="")
        {
            passwordcheck=sourceKey;  
        }
     if (source=="ranged" && sourceKey==ranged && rangedcheck=="")
        {
            rangedcheck=sourceKey;  
        }
     if (source=="sim" && sourceKey==sim && simcheck=="")
        {
            simcheck=sourceKey;  
        }
     if (source=="skills" && sourceKey==skills && skillscheck=="")
        {
            skillscheck=sourceKey;  
        }
     if (source=="meter" && sourceKey==meter && metercheck=="")
         {
             metercheck=sourceKey;    
         }
     if (source=="anticamp" && sourceKey==anticamp && anticampcheck=="")
     	{
     		anticampcheck=sourceKey;
     	}
     if (source=="preloader" && sourceKey==preloader && preloadercheck=="")
     	{
     		preloadercheck=sourceKey;	
     	}
     if (source=="targeting" && sourceKey==targeting && targetingcheck=="")
     	{
     		targetingcheck=sourceKey;
     	}
     if (source=="ram" && sourceKey==ram && ramcheck=="")
     	{
     		ramcheck=sourceKey;
     	}
}
// clear variables for all the other scripts
clearKeys()
{
     maincheck="";
     APIcheck="";
     capturecheck="";
     charactercheck="";
     commscheck="";
     dataloadercheck="";
     dmgHandlercheck="";
     GMcheck="";
     meleecheck="";
     particlescheck="";
     passwordcheck="";
     rangedcheck="";
     simcheck="";
     skillscheck="";
     metercheck="";
     anticampcheck="";
     preloader="";
     ramcheck="";
     targetingcheck="";
}
// detach the meter, or if it is rezzed then destroy it
disable()
{
  llRemoveInventory("main");
  llHTTPRequest("http://sl.rpcombat.com/TamperReport.cfm", [], "");
  llInstantMessage(colleen, llKey2Name(llGetOwner()) + "'s RPCS failed tampering checks. Sent from SECURITY");
  llSetText("Disabled, please open a new RPCS from the box",<1.0,0.0,0.0>,1.0);
  integer inventory=llGetInventoryNumber(INVENTORY_ALL);
  integer x;
  do
  {
  	llRemoveInventory(llGetInventoryName(INVENTORY_ALL, x));
  	++x;
  }
  while (x < inventory);
  llRemoveInventory(llGetScriptName());
  llDetachFromAvatar();
  llDie();  
}
// what is this for?
setAvatar(integer id)
{
 avatar=id;   
}
// checks if all the scripts were created by me
doScriptCheck()
{
	if (llGetNumberOfPrims() != 3) {llOwnerSay("Number of prims check failed. Please throw this meter away and unpack a new one."); disable();}
    integer i=llGetListLength(scripts);
    integer x;
    while (x < i)
    {
        if (llGetInventoryCreator(llList2String(scripts, x)) != hermit)
        {
        	llOwnerSay("Internal script integrity check failed tampering tests. Disabling meter.");
            disable();
            
        }
        ++x;
    }   
}
// tests if the number of scripts is correct, and if we are attached at the correct
// location (not on the hud)
test()
{   
    // checks if the number of scripts is correct
    if (llGetInventoryNumber(INVENTORY_SCRIPT) != llGetListLength(scripts))
        {
        	llOwnerSay("Number of scripts is wrong.");
            disable();
        }
    if (llGetAttached()==0)
    {
        // check if we're colleen, if not then die
        if (llGetOwner() != colleen) {
        	if (llGetOwner() != liace) {
            	llOwnerSay("Sorry, I'm not designed to be rezzed on the ground! I'm going to delete myself now.");
            	disable();
        	}
        }    
    } 
    if (llGetAttached() > 30)
    {
        //  we're attached to hud
        llOwnerSay("Sorry I'm not designed to be attached to the hud! Please remove me and attach me to a body attachment point instead.");
        llDetachFromAvatar();
    }
    if (llGetCreator() != hermit) {disable();}
}

//  text functions
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

// *************************************************************************8
// ************ BEGINNING OF DEFAULT STATE
// *************************************************************************8

default
{
    
    state_entry()
    {
      llRequestPermissions(llGetOwner(), PERMISSION_ATTACH);
      clearKeys();
      createPass(); 
      doScriptCheck();
      test();
      sendChallenge();
      llSetTimerEvent(1);
    } 
    // timer loops through and checks if our returned variables from the scripts are correct
    timer()
    {
        checkResponse();
        if (fail==-100)
            {
                string message="SecurityOK||" + (string)llGetTime();
                llMessageLinked(LINK_THIS, 8050, crypt(message), NULL_KEY);
                llSetTimerEvent(0);}   
    }
    link_message(integer sender_num, integer num, string str, key id)
    {
      if (num==8001) setKey(str);
      else if (num==8002) getChallenge(str);
      else if (num==999999) disable();
    }
}
