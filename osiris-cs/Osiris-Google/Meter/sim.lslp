	// Response script for handling incoming API commands from attachments
	// This will only listen to a specific channel and password, will put together the page to provide that shortly
	
	// Format for incoming messages:
	// "V|" + (string)target + "|M|ALL|Z|%a strikes %d a crushing blow|%d howls in pain|0|0|3|0";
	// See API\OpenAPI.lslp for the particulars on the variables
	
	// The device will listen on the same channel for commands to reset. Those should be sent from this script when a reset occurs
	
	
	string gCheckURL="http://sl.rpcombat.com/APIPlayerCheck.cfm";
	integer gAvatarChannel; // channel used for comms with API devices
	string gPass; // encryption password for API devices;
	integer APIListener; // listen handler for incoming API commands
	key owner;
	string myName;
	integer warning=0;
	key target;
	list cmd;
	string gAPIType;
	string gAPIRace;
	string gEffectedStat;
	string gEmote;
	string gVicEmote;
	string gPart;
	string gPartDur;
	string gTPart;
	string gTPartDur;
	string bulletname; // API enhanced bullets must match this name; 
	list blockAPI;
	// timers for API effects
	integer timerMelee;
	integer timerSniper;
	integer timerRanged;
	integer timerHeal;
	integer timerDD;
	integer timerbuff;
	integer timerPoison;
	integer poisonflag;
	integer poisonDuration;
	integer poisonCounter;
	string poison;
	key poisontarget;
	integer debug=0;
	
	key http_request_id;
	
	
	// security stuff
	// **************************************************
	
	// CHALLENGE/AUTHENTICATION
	string secureKey="";
	string securePass;
	string myKey="";
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
	            string response="sim|"+ randCheck + "||" + myKey;
	            llMessageLinked(LINK_THIS, 8001, cryptPass(response), NULL_KEY);   
	        }
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
	string randCheck;
	setRandCheck()
	{
	    randCheck=(string)llFrand(9999999999.0)+ (string)llFrand(9999999999.0);
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
	string crypt(string str){
	    return llXorBase64StringsCorrect(llStringToBase64(str),llStringToBase64(gPass));
	}
	
	// function used to decrypt communications
	string decrypt(string str){
	    return llBase64ToString(llXorBase64StringsCorrect(str,llStringToBase64(gPass)));
	}
	SetCMD(string str) {
		target=(key)left(str,"^");
		cmd=llParseString2List(right(str,"^"),["|"],[""]);
		gAPIType=llList2String(cmd, 0);
		gAPIRace=llList2String(cmd, 1);
		gEffectedStat=llList2String(cmd, 2);
		gEmote=llList2String(cmd, 3);
		gVicEmote=llList2String(cmd, 4);
		gPart=llList2String(cmd, 5);
		gPartDur=llList2String(cmd, 6);
		gTPart=llList2String(cmd, 7);
		gTPartDur=llList2String(cmd, 8);
	}
	ClearCMD()
	{
		cmd=[];
		target=NULL_KEY;
		gAPIType="";
		gAPIRace="";
		gEffectedStat="";
		gEmote="";
		gVicEmote="";
		gPart="";
		gPartDur="";
		gTPart="";
		gTPartDur="";
	}
	
	default
	{
		state_entry() {
			owner=llGetOwner();
			myName=llKey2Name(owner);
			ClearCMD();
			llSetTimerEvent(10);
			llListenRemove(APIListener);
			APIListener=llListen(gAvatarChannel, "",NULL_KEY, "");
		}
	    link_message(integer sender_num, integer num, string str, key id)
	    {
	        if (num==8000) {receiveChallenge(str);}
	        else if (num==9797) {debug=1;}
	        else if (num==1)
	        	{
	        		string param=left(str, "|");
	        		string value=right(str, "|");
	        		if (param=="LOADCOMPLETE") {
	        			http_request_id=llHTTPRequest(gCheckURL, [],"");
	        		} else if (param=="BLOCKAPI") {
	        			blockAPI=llCSV2List(value);
	        		}
	        	} 
	    }
	    http_response(key id,integer h_status,list meta,string body) {
	    	if (h_status==200 && id==http_request_id)
	    	{
	    		list response=llCSV2List(llStringTrim(body, STRING_TRIM));
	    			if (llList2String(response, 0)=="MSG") {
	    				//llOwnerSay(llList2String(response, 1));
	    			} else if (llList2String(response, 0)=="GO") {
	    				gAvatarChannel=llList2Integer(response, 1);
	    				gPass=llStringTrim(llList2String(response, 2), STRING_TRIM);
	    				APIListener=llListen(gAvatarChannel, "",NULL_KEY, "");
	    				bulletname=llList2String(response, 3);
	    			}
	    	}	
	    }
	    listen(integer channel, string name, key id, string message) {
	    	if (channel==gAvatarChannel && llGetOwnerKey(id)==owner) {
	    		string msg=decrypt(message);
	    		if (debug==1) {llOwnerSay(msg);}
	    		if (left(msg,"||")=="V") {
	    			SetCMD(right(msg,"||"));
	    			if (llListFindList(blockAPI, [gAPIType]) != -1) {
	    				if (warning==0) {
	    				llOwnerSay("Some enhancement API's are disabled in this sim configuration. Please contact a GM for specific information about which weapon types are disabled");	
	    				warning=1;
	    				}
	    			}
	    			else {
	    			
		    			if (gAPIType=="M") {
		    				if (debug==1) {llOwnerSay("Got API Type M");}
		    				if (llGetUnixTime() > timerMelee) { // we're checking the time here to make sure we're not spamming linked msgs... should only
		    													// accept this proc once every 5 minutes
		    					//llOwnerSay("Sending cmd to melee");
		    					llMessageLinked(LINK_THIS, 7500, llList2CSV(cmd),NULL_KEY);
								timerMelee=llGetUnixTime()+300; // set the melee timer so vendors can't flood the system with spam
								ClearCMD();
		    				}
		    			} else if (gAPIType=="S") {
		    				if (debug==1) {llOwnerSay("Received API Type Sniper");}
		    				if (llGetUnixTime() > timerSniper) { // 30 second reload required for snipers
									if (llList2String(cmd, 3) != "NULL") {
										string say = str_replace(llList2String(cmd, 3),"%a",myName);
		    							say = str_replace(say,"%d",llKey2Name(target));
		    							llSay(0,say);								
									}
									if (llList2String(cmd, 5) != "0") {
										llMessageLinked(LINK_SET,10,llList2String(cmd, 5) + "|" + llList2String(cmd, 6),NULL_KEY);
									}
									// send the hit to the opponent
									string hit = (string)target + "|P||2|-25|128|0|0|0|0|NULL|" + llList2String(cmd, 7) + "|" + llList2String(cmd, 8) + "|0|" + llList2String(cmd, 4) + "|API|" + llList2String(cmd, 1) + "|API|D^" + (string)owner;
									llMessageLinked(-4,6,hit,target);
		    					timerSniper=llGetUnixTime()+30;
		    					ClearCMD();
		    				}
		    			} else if (gAPIType=="R") {
		    				if (debug==1) {llOwnerSay("Received API type RANGED");}
		    				if (llGetUnixTime() > timerRanged) {state ranged;}
		    			} else if (gAPIType=="H") {
		    				if (llGetUnixTime() > timerHeal) { // 6 minute reload required for heal
									if (llList2String(cmd, 3) != "NULL") {
										string say = str_replace(llList2String(cmd, 3),"%a",myName);
		    							say = str_replace(say,"%d",llKey2Name(target));
		    							llSay(0,say);								
									}
									if (llList2String(cmd, 5) != "0") {
										llMessageLinked(LINK_SET,10,llList2String(cmd, 5) + "|" + llList2String(cmd, 6),NULL_KEY);
									}
									// send the hit to the opponent
									string hit = (string)target + "|P||2|50|20|0|0|0|0|NULL|" + llList2String(cmd, 7) + "|" + llList2String(cmd, 8) + "|0|" + llList2String(cmd, 4) + "|API|" + llList2String(cmd, 1) + "|API|D^" + (string)owner;
									llMessageLinked(-4,6,hit,target);
		    					timerHeal=llGetUnixTime()+360;
		    					ClearCMD();
		    				}
		    			}
		    			else if (gAPIType=="X") {
		    				if (debug==1) {llOwnerSay("Received API type DIRECT DAMAGE");}
		    				if (llGetUnixTime() > timerDD) { // 6 minute charge time between use
									if (llList2String(cmd, 3) != "NULL") {
										string say = str_replace(llList2String(cmd, 3),"%a",myName);
		    							say = str_replace(say,"%d",llKey2Name(target));
		    							llSay(0,say);								
									}
									// llOwnerSay("Got direct damage, the racial type is " + llList2String(cmd, 1));
									if (llList2String(cmd, 5) != "0") {
										llMessageLinked(LINK_SET,10,llList2String(cmd, 5) + "|" + llList2String(cmd, 6),NULL_KEY);
									}
									// send the hit to the opponent
									string hit = (string)target + "|P||2|-25|20|0|0|0|0|NULL|" + llList2String(cmd, 7) + "|" + llList2String(cmd, 8) + "|0|" + llList2String(cmd, 4)  + "|API|" + llList2String(cmd, 1) +  "|API|D^" + (string)owner;
									llMessageLinked(-4,6,hit,target);
		    					timerDD=llGetUnixTime()+360;
		    					ClearCMD();
		    				}
		    			}
		    			else if (gAPIType=="P") {
		    				if (debug==1) {llOwnerSay("Received API type POISON");}
		    				if (llGetUnixTime() > timerPoison) 
							{ // 30 minute charge time between use
									if (llList2String(cmd, 3) != "NULL") {
										string say = str_replace(llList2String(cmd, 3),"%a",myName);
										say = str_replace(say,"%d",llKey2Name(target));
										llSay(0,say);								
									}
									if (llList2String(cmd, 5) != "0") {
										llMessageLinked(LINK_SET,10,llList2String(cmd, 5) + "|" + llList2String(cmd, 6),NULL_KEY);
									}
									// send the hit to the opponent
								poisonflag=1;
								//syntax for skills
								poisontarget=target;
								poison=(string)target + "|P||2|-4|15|0|SC|-1|14|NULL|" + llList2String(cmd, 7) + "|" + llList2String(cmd, 8) + "|0|" + llList2String(cmd, 4)  + "|API|" + llList2String(cmd, 1) +  "|API|D^" + (string)owner;
								llMessageLinked(-4,6,poison,target);
								poison=(string)target + "|P||2|-4|15|0|SC|-1|14|NULL|" + llList2String(cmd, 7) + "|" + llList2String(cmd, 8) + "|0|" + "NULL|API|" + llList2String(cmd, 1) + "|API|D^" + (string)owner;
								timerPoison=llGetUnixTime()+1800;
								poisonDuration=llGetUnixTime()+2;
								poisonCounter=30;
								ClearCMD();
							}
		    			}
		    			else if (gAPIType=="A") {
							if (debug==1) {llOwnerSay("Received API type ARMOR.  This function is not implemented yet.");}
						}
		    			else if (gAPIType=="B") {
		    				if (debug==1) {llOwnerSay("Received API type BUFF");}
		    				if (llGetUnixTime() > timerbuff) { // 6 minute charge time between use
									if (llList2String(cmd, 3) != "NULL") {
										string say = str_replace(llList2String(cmd, 3),"%a",myName);
		    							say = str_replace(say,"%d",llKey2Name(target));
		    							llSay(0,say);								
									}
									if (llList2String(cmd, 5) != "0") {
										llMessageLinked(LINK_SET,10,llList2String(cmd, 5) + "|" + llList2String(cmd, 6),NULL_KEY);
									}
									// send the hit to the opponent
									string hit = (string)target + "|P||3|0|20|1|"+llList2String(cmd, 2)+"|5|60|NULL|" + llList2String(cmd, 7) + "|" + llList2String(cmd, 8) + "|0|" + llList2String(cmd, 4)   + "|API|" + llList2String(cmd, 1) + "|API|D^" + (string)owner;
									llMessageLinked(-4,6,hit,target);
		    					timerbuff=llGetUnixTime()+360;
		    					ClearCMD();
		    				}
		    			}
		    			else if (gAPIType=="D") {
		    				if (debug==1) {llOwnerSay("Received API type DEBUFF");}
		    				if (llGetUnixTime() > timerbuff) { // 6 minute charge time between use
									if (llList2String(cmd, 3) != "NULL") {
										string say = str_replace(llList2String(cmd, 3),"%a",myName);
		    							say = str_replace(say,"%d",llKey2Name(target));
		    							llSay(0,say);								
									}
									if (llList2String(cmd, 5) != "0") {
										llMessageLinked(LINK_SET,10,llList2String(cmd, 5) + "|" + llList2String(cmd, 6),NULL_KEY);
									}
									// send the hit to the opponent
									string hit = (string)target + "|P||3|0|20|1|"+llList2String(cmd, 2)+"|-5|60|NULL|" + llList2String(cmd, 7) + "|" + llList2String(cmd, 8) + "|0|" + llList2String(cmd, 4)  + "|API|" + llList2String(cmd, 1) +  "|API|D^" + (string)owner;
									llMessageLinked(-4,6,hit,target);
		    					timerbuff=llGetUnixTime()+360;
		    					ClearCMD();
		    				}
		    			}
		    			else if (gAPIType=="G") {
		    				if (debug==1) {llOwnerSay("Received API type AREA DAMAGE. Not implemented yet");}
		    				}
		    			else if (gAPIType=="R") {
							if (debug==1) {llOwnerSay("Received API type REFLECT. Not implemented yet");}
						}
		    			else if (gAPIType=="T") {
		    				if (debug==1) {llOwnerSay("Received API type API Reflect. Not implemented yet.");}
		    			}
		    		}
	    		}
	    	}	
	    }
	    changed(integer f_Changed)
	    {
	        if (f_Changed & CHANGED_OWNER) llResetScript();
	    }  
	    timer()
	    {
	    	// cleans up old entries
	    	if (llGetUnixTime() > timerMelee && timerMelee != 0) {
	    		timerMelee=0;
	    		if (debug==1) {llOwnerSay("Melee API timer expired");}
	    		llMessageLinked(LINK_THIS, 7501, "", NULL_KEY);	
	    	} 
	    	if (poisonCounter>0 && llGetUnixTime() > poisonDuration) {
	    		llMessageLinked(-4,6,poison,poisontarget);
	    		poisonDuration=llGetUnixTime()+2;
				poisonCounter--;	
					if (poisonCounter==0) {
						poisonDuration=llGetUnixTime();
						poison="";
						poisontarget=NULL_KEY;	
					}
	    	}
	    } 
	}
	// R - ranged. 2 extra damage point per hit.  Send this to the avatar only once in 5 minutes, all nearby avatars are effected
	state ranged {
		state_entry() {
				if (debug==1) {llOwnerSay("Notifying nearby avatars of ranged API, bulletname is " + (string)bulletname);}
				llSensor("","",AGENT,96,PI);
				llSetTimerEvent(4.0);
		}
		sensor(integer num_detected) {
			timerRanged = llGetUnixTime()+45;
			integer x;
			while (x < num_detected) {
	            llMessageLinked(LINK_THIS, 7502, bulletname, llDetectedKey(x));
	            ++x;
	        }
	        state default;
		}
		no_sensor() {
			state default;
		}
		timer() {
			llSetTimerEvent(0.0);
			state default;	
		}
	}
	// A - armor ( makes players harder to hit, with a corresponding drop in stamina) – stamina drop will be a function of how good the protection is, so the heaviest armor will drop stamina the most. This would be a wearable attachment, and it is recommended that it be visible.
	state armor {
		state_entry() {
		}
	}
	// G - area damage (bombs, grenades, etc which original from the player) – 25 points of area damage, 10 meter radius around the avatar, meter enforced 30 second delay between hits.
	state areadmg {
		state_entry() {
		}
	}
	// R - API Reflect (combat) – shielding that reflects melee/ranged damage back to the originator for 60 seconds.  30 minute charge between uses.
	state reflect {
		state_entry() {
		}
	}
	// S - API Reflect (spell) -  shielding that reflects either skills back to the originator for 60 seconds.  30 minute charge between uses.
	state APIReflect {
		state_entry() {
		}
	}
