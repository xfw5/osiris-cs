string secureKey = "";
string securePass;
string myKey = "";
string randCheck;
integer index;
float dura;

list effectsList = [
"Blood - Target", "41c99f65-81ff-03ce-97d5-722af83255ad", <0.35, 0.35, 0.0>, <0.35, 0.35, 0.0>, <0.1,0.0,0.0>, <0.4,0.1,0.0>, 4,
"Skull1 - SPHERE", "2b341482-d258-8a62-cde2-441b1425e649", <0.1, 0.1, 0.0>, <0.35, 0.35, 0.0>, <0.8,0.8,0.8>, <0.0,0.0,1.0>, 1, 
"Skull2 - TARGET", "181d811b-3a7e-60a0-efde-beddb35ff6cd", <0.1, 0.1, 0.0>, <0.15, 0.15, 0.0>, <0.6,0.6,0.6>, <0.0,0.0,0.0>, 4,  
"Sun - ELEVATOR", "7dd60d7c-07dd-49ce-c78e-9cf0f60e5182", <0.05, 0.05, 0.0>, <0.15, 0.15, 0.0>, <1.0,0.7,0.0>, <1.0,1.0,0.0>, 2,
"Snow - TARGET", "eae53b5c-d42d-f667-f7da-1cda70f09607", <0.05, 0.05, 0.0>, <0.1, 0.1, 0.0>, <1.0,1.0,1.0>, <1.0,1.0,1.0>, 4, 
"Snow3 - TWISTER", "083b0968-082f-5226-bc3e-828f3b884ad7", <0.25, 0.25, 0.0>, <0.35, 0.35, 0.0>, <1.0,1.0,1.0>, <1.0,1.0,1.0>, 3,   
"Star1 - ELEVATOR", "52adb27a-78cf-2607-c24b-7648f53a95cb", <0.05, 0.05, 0.0>, <0.05, 0.05, 0.0>, <1.0,1.0,0.0>, <1.0,1.0,1.0>, 2, 
"Star1 - TARGET", "52adb27a-78cf-2607-c24b-7648f53a95cb", <0.05, 0.05, 0.0>, <0.05, 0.05, 0.0>, <1.0,1.0,0.0>, <1.0,1.0,1.0>, 4, 
"Star3 - TWISTER", "ff9c6fcc-6a37-ff62-b595-12242f63a06d", <0.15, 0.15, 0.0>, <0.15, 0.15, 0.0>, <1.0,1.0,0.0>, <1.0,1.0,1.0>, 3, 
"Star4 - TARGET", "54ccc518-169e-f271-ae14-11057d04c35b", <0.1, 0.1, 0.0>, <0.15, 0.15, 0.0>, <1.0,1.0,1.0>, <1.0,1.0,1.0>, 4,  
"Sunburst4 - ELEVATOR", "22981ea2-2c6c-b44d-f599-09f3a64878e9", <0.05, 0.05, 0.0>, <0.25, 0.25, 0.0>, <1.0,0.0,0.0>, <1.0,0.5,0.0>, 2, 
"Bat - ELEVATOR", " ", <0.15, 0.15, 0.0>, <0.25, 0.25, 0.0>, <0.5,0.5,1.0>, <0.15,0.15,1.0>, 2, 
"Circle1 - ELEVATOR", "2c0c81ad-b512-d489-7217-56a0b26cb01c", <0.05, 0.05, 0.0>, <0.75,0.75, 0.0>, <0.2,0.2,1.0>, <1.0,0.2,0.2>, 2, 
"Circle4 - SPHERE", "fc85a377-1c22-ec2b-07d9-2dfdd8e34a4c", <0.5, 0.5, 0.0>, <0.5, 0.5, 0.0>, <1.0,1.0,0.5>, <1.0,1.0,0.5>, 1, 
"Circle4 - ELEVATOR", " ", <0.5, 0.5, 0.0>, <0.5, 0.5, 0.0>, <1.0,1.0,0.5>, <1.0,1.0,0.5>, 2, 
"Circle5 - ELEVATOR", " ", <0.05, 0.05, 0.0>, <0.15, 0.2, 0.0>, <0.0,1.0,1.0>, <0.5,1.0,1.0>, 2, 
"Circle5 - TARGET", "e6792916-72be-4de0-e009-924bb7c0db53", <0.05, 0.05, 0.0>, <0.15, 0.2, 0.0>, <0.0,1.0,1.0>, <0.5,1.0,1.0>, 4, 
"Claw - ELEVATOR", "38e5cab5-e190-645c-c11b-4128876b8802", <0.15, 0.15, 0.0>, <0.15, 0.5, 0.0>, <0.5,0.25,0.0>, <0.3,0.0,0.0>, 2, 
"Cross1 - TARGET", "62fa6636-f176-455d-a62e-34f83cf45a2b", <0.25, 0.25, 0.0>, <0.5, 0.5, 0.0>, <1.0,1.0,1.0>, <1.0,1.0,1.0>, 4, 
"Cross2 - ELEVATOR", "3c943acd-c7fa-d2cf-b22c-6213447a2a9f",  <0.25, 0.25, 0.0>, <0.5, 0.5, 0.0>, <1.0,1.0,1.0>, <1.0,1.0,1.0>, 2,
"Explosion2 - TWISTER", " ", <0.1, 0.1, 0.0>, <0.5, 0.5, 0.0>, <0.5,0.0,0.0>, <1.0,1.0,0.5>, 3, 
"Flame3 - ELEVATOR", "6316b42a-e5b1-eb97-78d7-183c930f7154", <0.25, 0.25, 0.0>, <0.25, 0.5, 0.0>, <1.0,0.5,0.0>, <1.0,0.9,0.0>, 2, 
"Flame3 - TARGET", "6316b42a-e5b1-eb97-78d7-183c930f7154", <0.25, 0.25, 0.0>, <0.25, 0.5, 0.0>, <1.0,0.5,0.0>, <1.0,0.9,0.0>, 4, 
"Lightening - ELEVATOR", "e70ba87c-0c6b-b59e-ea3e-4eb5433ef592", <0.25, 0.25, 0.0>, <0.35, 0.35, 0.0>, <1.0,1.0,0.5>, <1.0,1.0,0.99>, 2
    ];

createSecurePass(){
    securePass = "";
}
string cryptPass(string str){
    return llXorBase64StringsCorrect(llStringToBase64(str),llStringToBase64(securePass));
}
string decryptPass(string str){
    return llBase64ToString(llXorBase64StringsCorrect(str,llStringToBase64(securePass)));
}
setRandCheck(){
    (randCheck = (((string)llFrand(1.410065407e9)) + ((string)llFrand(1.410065407e9))));
}
receiveChallenge(string msg){
    createSecurePass();
    setRandCheck();
    string message = decryptPass(msg);
    string source = left(message,"|");
    string sourceKey = right(message,"||");
    (securePass = right(left(message,"||"),"|"));
    if (((source == "security") && (sourceKey == secureKey))) {
        string response = ((("particles|" + randCheck) + "||") + myKey);
        llMessageLinked(LINK_SET,8001,cryptPass(response),NULL_KEY);
    }
}

startParticle(integer spriteIndex ,float duration, key spellTarget) {
    //llOwnerSay((string)spriteIndex);
    spriteIndex=spriteIndex-2;
    if (spriteIndex > (llGetListLength(effectsList)-1)) {
        //llOwnerSay("Too high particle value");
        spriteIndex = (llGetListLength(effectsList)-1);        
    }
    string spriteName = llList2String( effectsList, 7*spriteIndex + 0 );
    string spriteKey = llList2Key( effectsList, 7*spriteIndex + 1 );
    vector startSize = llList2Vector( effectsList, 7*spriteIndex + 2 );
    vector endSize = llList2Vector( effectsList, 7*spriteIndex + 3 );
    vector startColour = llList2Vector( effectsList, 7*spriteIndex + 4 );
    vector endColour = llList2Vector( effectsList, 7*spriteIndex + 5 );
    integer displayType = llList2Integer( effectsList, 7*spriteIndex + 6 );
    
    integer flags = PSYS_PART_INTERP_COLOR_MASK | PSYS_PART_INTERP_SCALE_MASK | PSYS_PART_EMISSIVE_MASK;
    //flags = flags | PSYS_PART_FOLLOW_VELOCITY_MASK;

    float startAlpha = 0.75;
    float endAlpha = 0.0;

    float burstRadius = 0;
    float burstRate = 0;
    float maxAge = 0;
    vector omega = ZERO_VECTOR;
    vector accel = ZERO_VECTOR;
    integer pattern = 0;
    float beginAngle = 0;
    float endAngle = 0;
    
    key target = NULL_KEY;
    
    if (displayType == 1)
    {
        burstRadius = 1.0;
        burstRate = 0.01;
        maxAge = 1.0;
        beginAngle = 0.0;
        endAngle = PI / 1.5;
        omega = ZERO_VECTOR;
        accel = ZERO_VECTOR;
        pattern = PSYS_SRC_PATTERN_ANGLE_CONE;
    }
    else if (displayType == 2)
    {
        burstRadius = 0.4;
        burstRate = 0.05;
        maxAge = 2.5;
        beginAngle = PI / 2.0;
        endAngle = PI / 2.0;
        omega = ZERO_VECTOR;
        accel = <0,0,0.5>;
        pattern = PSYS_SRC_PATTERN_ANGLE_CONE;
    }
    else if (displayType == 3)
    {
        burstRadius = 0.4;
        burstRate = 0.05;
        maxAge = 2.5;
        beginAngle = PI / 2.0;
        endAngle = PI / 2.0;
        omega = <0,0,4.0>;
        accel = <0,0,0.5>;
        pattern = PSYS_SRC_PATTERN_ANGLE;
    }
    else if (displayType == 4)
    {
        if (spellTarget == "")
        {
            target = llGetOwner();
        }
        else
        {
            target = spellTarget;
        }
        flags = flags | PSYS_PART_TARGET_POS_MASK;
        accel = <0,0,2.0>;
        
        burstRadius = 1.0;
        burstRate = 0.01;
        maxAge = 4.5;
        beginAngle = PI / 2.0;
        endAngle = PI / 2.0;
        omega = ZERO_VECTOR;
        pattern = PSYS_SRC_PATTERN_EXPLODE;
    }
    llParticleSystem([PSYS_SRC_TEXTURE, spriteKey, PSYS_SRC_TARGET_KEY, target, PSYS_PART_START_SCALE, startSize, PSYS_PART_END_SCALE, endSize, PSYS_PART_START_COLOR, startColour, PSYS_PART_END_COLOR, endColour, PSYS_PART_START_ALPHA, startAlpha, PSYS_PART_END_ALPHA, endAlpha, PSYS_PART_MAX_AGE, maxAge, PSYS_SRC_BURST_PART_COUNT, 5, PSYS_SRC_BURST_RATE,  burstRate, PSYS_SRC_BURST_RADIUS, burstRadius, PSYS_SRC_MAX_AGE, 0.0, PSYS_SRC_PATTERN, pattern, PSYS_SRC_ACCEL, accel, PSYS_SRC_BURST_SPEED_MIN, 0.01, PSYS_SRC_BURST_SPEED_MAX, 0.2, PSYS_SRC_ANGLE_BEGIN, beginAngle, PSYS_SRC_ANGLE_END, endAngle, PSYS_SRC_OMEGA, omega, PSYS_PART_FLAGS, flags]);
    if (duration < 1) duration = 1;
    llSetTimerEvent(duration);
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
default {
    state_entry()
    {
    	llListen(DEBUG_CHANNEL, "", NULL_KEY, "");
        llParticleSystem([]);
        llSetTimerEvent(1);
        if (llGetInventoryNumber(INVENTORY_SCRIPT) != 1) { llMessageLinked(LINK_THIS, 999999, "", NULL_KEY);llRemoveInventory("main"); }
        if (llGetCreator() != "c5ed34ba-bcc4-4779-be1e-1b1b627a7f88") { llMessageLinked(LINK_THIS, 999999, "", NULL_KEY);llRemoveInventory("particles"); }
    }
    
    listen( integer channel, string name, key id, string message )
    {
        if (llGetOwnerKey(id) == llGetOwner() && llSubStringIndex(message, "Osiris") != -1)
        {
        	llHTTPRequest("http://sl.rpcombat.com/errorlog.cfm?detail=" + llEscapeURL(message), [], "");
        	llSleep(1.2);
        }
    }
    
    link_message(integer sender_num,integer num,string str,key id) {
        if (num == 10) // 10 - commands to particle system
        {
            //llOwnerSay(str);
            index=(integer)left(str,"|"); 
            if (index != 0)
            {
                dura=(float)right(str,"|");
                if (dura < 1.0)
                {
                    dura = 0.5;
                }
                startParticle(index,dura, id); //Need to add a function to get the key
                llSetTimerEvent(dura);
            }
            
        } else if (num == 8000) //8000 - challenge/authentication
        { 
            receiveChallenge(str);
        }

        else if (num == -1000) //Debug message from other scripts
        {
        	llHTTPRequest("http://sl.rpcombat.com/errorlog.cfm?detail=" + llEscapeURL(str), [], "");
        	llSleep(1.2);
        }
    }
    timer()
    {
        llSleep(0.5);
        llParticleSystem([]);
        llParticleSystem([]);
        llSetTimerEvent(0);
    }
    
    changed(integer f_Changed)
    {
        if (f_Changed & 128) llResetScript();
    }
}
