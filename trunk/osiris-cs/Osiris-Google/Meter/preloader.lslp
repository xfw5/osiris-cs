string secureKey = "";
string securePass;
string myKey = "";
string randCheck;

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
string left(string src,string divider){
    integer index = llSubStringIndex(src,divider);
    if ((~index)) return llDeleteSubString(src,index,-1);
    return src;
}
string right(string src,string divider){
    integer index = llSubStringIndex(src,divider);
    if ((~index)) return llDeleteSubString(src,0,((index + llStringLength(divider)) - 1));
    return src;
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
integer index;
list textures = [
"41c99f65-81ff-03ce-97d5-722af83255ad",
"2b341482-d258-8a62-cde2-441b1425e649",
"181d811b-3a7e-60a0-efde-beddb35ff6cd",
"7dd60d7c-07dd-49ce-c78e-9cf0f60e5182", 
"eae53b5c-d42d-f667-f7da-1cda70f09607", 
"083b0968-082f-5226-bc3e-828f3b884ad7", 
"52adb27a-78cf-2607-c24b-7648f53a95cb", 
"52adb27a-78cf-2607-c24b-7648f53a95cb", 
"ff9c6fcc-6a37-ff62-b595-12242f63a06d", 
"54ccc518-169e-f271-ae14-11057d04c35b", 
"22981ea2-2c6c-b44d-f599-09f3a64878e9", 
"2c0c81ad-b512-d489-7217-56a0b26cb01c", 
"fc85a377-1c22-ec2b-07d9-2dfdd8e34a4c", 
"e6792916-72be-4de0-e009-924bb7c0db53",
"38e5cab5-e190-645c-c11b-4128876b8802",
"62fa6636-f176-455d-a62e-34f83cf45a2b",
"3c943acd-c7fa-d2cf-b22c-6213447a2a9f", 
"6316b42a-e5b1-eb97-78d7-183c930f7154", 
"6316b42a-e5b1-eb97-78d7-183c930f7154",
"e70ba87c-0c6b-b59e-ea3e-4eb5433ef592"
    ];

default {
    state_entry() {
        if (llGetInventoryNumber(INVENTORY_SCRIPT) != 1) {llMessageLinked(LINK_THIS, 999999, "", NULL_KEY);llRemoveInventory("preloader");}
        if ((llGetCreator() != "c5ed34ba-bcc4-4779-be1e-1b1b627a7f88")) {llMessageLinked(LINK_THIS, 999999, "", NULL_KEY);llRemoveInventory("preloader");}
        llSetTimerEvent(20.0);
    }
    timer()
    {
    	if (index > llGetListLength(textures)-1) index=0;
    	llSetPrimitiveParams([PRIM_TEXTURE, ALL_SIDES, llList2String(textures, index),<0.0,0.0,0.0>,<0.0,0.0,0.0>,0.0]);
    	++index;
    }
}
