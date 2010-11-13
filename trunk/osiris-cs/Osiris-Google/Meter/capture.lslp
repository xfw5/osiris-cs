// CHALLENGE/AUTHENTICATION
string secureKey="something";
string securePass;
string myKey="something else";
string randCheck;

createSecurePass()
{
  securePass="something";   
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
            string response="capture|"+ randCheck + "||" + myKey;
            llMessageLinked(LINK_THIS, 8001, cryptPass(response), NULL_KEY);   
        }
}
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




default {
    state_entry() {
        //llOwnerSay("Hello Scripter");
    }
    link_message(integer sender_num, integer num, string str, key id) {
        if (num==8000) {receiveChallenge(str);
        }
    }
}
