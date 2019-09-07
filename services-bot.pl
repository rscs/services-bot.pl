#!/usr/bin/perl
#

#####  ****************** add ping!!!!!!!!!!!!

##
## Necessary Setup Information
##
$AF_INET=2;
$SOCK_STREAM=1;
$SIG{'HUP'}='dodata';
$SIG{'1'}='dodata';
$SIG{'SIGHUP'}='dodata';
$SIG{'TERM'}='dokill';
$SIG{'9'}='dokill';
$SIG{'SEGV'}='doseg';
$SIG{'SIGSEGV'}='doseg';
$SIG{'11'}='doseg';
$CONNECT_COUNT=0;
chop($MACHINE_INFO = `uname -a`);
$0="services - services.DAL.net";
$|=1;
select(STDOUT);

##
## Configuration Options
##
$port=8000;
$server="127.0.0.1";
$servername="services.DAL.net";
$serverdesc="DALnet Services Home Base";
$serverpass="serv";
$osname="OperServ";
$osdesc="Oper Access Port";
$nsname="NickServ";
$nsdesc="Nickname Server";
$csname="ChanServ";
$csdesc="Channel Server";
$msname="MemoServ";
$msdesc="Message Server";
$hsname="HelpServ";
$hsdesc="Help Service";
$botuser='service';
$bothost='dal.net';
$oslow = $osname;
$oslow =~ tr/A-Z/a-z/;
$nslow = $nsname;
$nslow =~ tr/A-Z/a-z/;
$cslow = $csname;
$cslow =~ tr/A-Z/a-z/;
$mslow = $msname;
$mslow =~ tr/A-Z/a-z/;
$hslow = $hsname;
$hslow =~ tr/A-Z/a-z/;
$diepass = "XXX";
$suspass = "XXX";
$suspend = 0;
$raw = 0;
$debug = 0;
$vdebug = 0;

##
## User Access Setup 
##

$auser[1] = "rscs\@X";
$auser[2] = "rscs\@X";
$auser[3] = "END";

$ruser[1] = "*ruisinj\@X";
$ruser[2] = "rsms\@X";
$ruser[3] = "rsms\@X";
$ruser[4] = "raiden\@X";
$ruser[5] = "*drick\@X";
$ruser[6] = "END";

$ouser[1] = "brian25\@X";
$ouser[2] = "slolomn\@X";
$ouser[3] = "END";

$nuser[1] = "xPsycho";
$nuser[2] = "END";

sub parseinfo
{
  printf (D "$_") if ($debug);
  printf ("$_") if ($vdebug);
  $omesg = $mesg;
  $ofrom = $from;
  $ohost = $userat;
  $owhat = $what;
  $oto   = $to;
  $oaddr = $addr;

  $rawinfo =~ s/\n//;
  $rawinfo =~ s/^://;
  $rawinfo =~ s/~//g;
  $rawinfo =~ s/\r//;
  ($wholefrom,$what,$to,$mesg) = split(/ /,$rawinfo,4);
  $to =~ tr/A-Z/a-z/;
  $to =~ s/^\://;
  $mesg =~ s/^\://;
#  ($cmd,$parms) = split(/ /,$mesg,2);
  ($from,$userat) = split(/!/,$wholefrom);
  $from =~ s/^\://;
  $userat =~ s/^\://;
  $loto = $to;
  $loto =~ tr/A-Z/a-z/;
 # printf ("To: $to - From: $from - What: $what - Mesg: $mesg\n");
  ($cmd,$parms) = split(/ /,$omesg,2);
   $cmd =~ tr/A-Z/a-z/;

  if (($what eq "PRIVMSG") || ($what eq "NOTICE"))
  {
    if (!$suspend)
    {     
    printf (S "USERHOST $from\n") if ($to eq $oslow); 
    &nickserv if ($to eq $nslow);
    &memoserv if ($to eq $mslow);
    &helpserv if ($to eq $hslow);
    printf (S "USERHOST $from\n") if ($to eq $cslow); 
    }
    else
    {
     ($cd,$krap) = split(/ /,$mesg,2);
      $cd =~ tr/A-Z/a-z/;
     if ($cd eq "unsuspend")
     {
     printf (S "USERHOST $from\n");
     }
     else
     {
     printf (S ":$servername NOTICE $from :Sorry -- Services has been temporarily suspended by $susnick\!$susaddr.\n");
     }
    }
  }
  
 # if ($what eq "JOIN")
 # {
 #    &topic;
 #    if ($to eq "#dragonrealm") 
 #    {
 #     printf (S "USERHOST $from\n");
 #     $cto = $to;
 #    }
 # }  

  if ($from eq "NICK")
  {
       ($krap,$nnick,$krap,$krap,$nuser,$nhost,$krap) = split(/ /,$rawinfo,8); 
       if (isnreg())
       {
       $sec = 60;
       printf (S ":$nsname NOTICE $nnick :This nick is owned by someone else.  Please choose another.\n");
       printf (S ":$nsname NOTICE $nnick :If this is your nick, type: /msg $nsname IDENTIFY <password>.\n");
       printf (S ":$nsname NOTICE $nnick :You have $sec seconds to comply before I send a nick collide.\n");
       }
  }

  if ($what eq "MODE")
  {
    printf (S ":$csname MODE $to +nt-spi\n") if ($to eq "#dragonrealm");
    printf (S ":$csname MODE $to -k *\n") if ($to eq "#dragonrealm");
    printf (S ":$csname MODE $to +nts\n") if ($to eq "#xpsycho");
  }

  &topic if ($what eq "TOPIC");
  
 if ($what eq "302")
 {
      if (grep(/\+/,$mesg))
      {
      ($krap,$addr) = split(/\+/,$mesg);
      }
      else
      {
      ($krap,$addr) = split(/\-/,$mesg);
      }
#  $chans = "#dragonrealm,#dalnethelp,#mirc";
#   if ($cto ne "")
#   {
#     $next = "asdf";
#     while ($next ne "")
#     {
#      ($cnext,$next) = split(/,/,$chans,2); 
#       if ($cnext eq $cto)
#       { 
#        if (grep(/\*/,$rawinfo))   
#        {
#        ($cfrom,$krap) = split(/\*/,$mesg,2);
#        printf (S ":$csname MODE $cto +o $cfrom\n");
#        $cto = "";
#        }
#       }
#     }
#   }
  if (!$suspend)
  {

   if ($unick ne "")
   {
       $t = 0;
     if (grep(/\*/,$rawinfo))
     {
       if (isadmin())
       {
       printf (S ":$osname NOTICE $ufrom :Access for $mesg is: Services Admin\n");
       $t = 1;
       }
       if ((isroot()) && (!$t))
       {
       printf (S ":$osname NOTICE $ufrom :Access for $mesg is: Services Root\n");
       $t = 1;
       }
       if ((isoper()) && (!$t))
       {
       printf (S ":$osname NOTICE $ufrom :Access for $mesg is: Services Operator\n") if (isoper());
       $t = 1;
       }
       if (!$t) 
       {
         printf (S ":$osname NOTICE $ufrom :Access for $mesg is: IRCop Access\n");
       }
     }
     else
     {
     printf (S ":$osname NOTICE $ufrom :Access for $mesg is: Regular User Access\n"); 
     }
       $unick = "";
       $ufrom = "";
   }

   if ($oto eq $oslow)
   {
    if (grep(/\*/,$rawinfo))
    {
    &operserv;
    }
    else
    {
    printf (S ":$osname NOTICE $ofrom :Sorry, only IRC Operators can use this service.\n");
    &slog; 
    }
   }
   &chanserv if ($oto eq $cslow);
  }
   else
   {
     if ($cmd eq "unsuspend")
     {
       if (isroot())
       {
         printf (S "WALLOPS :Services UNSUSPENDED by $ofrom\!$addr.\n");
         &log;
         $suspend = 0;
       }
     }
   } 
}

  if ($from eq "ERROR")
  {
    &register if (grep(/Closing Link/,$rawinfo));

  }

  if ($what eq "451")
  {
  &register;
  }
  printf (S "PONG :$servername\n") if ($from eq "PING");
  
  if ($what eq "315")
  {
    if ($cchan ne "")
    {
    printf (S ":$osname MODE $cchan -oooooo $clears\n");
    printf (S ":$osname MODE $cchan -isplmntk *\n");
    printf (S ":$osname MODE $cchan +b\n");
    }
    $kchan = "" if ($kchan ne "");
  }
  
  if ($what eq "367")
  {
    if ($cchan ne "")
    {
     ($krap,$cmban,$krap) = split(/ /,$mesg);
     $sbann++;
     $sbans = "$sbans $cmban";
     if ($sbann > 5)
     {
      printf (S ":$osname MODE $cchan -bbbbbb $sbans\n");
      $sbann = 0;
      $sbans = "";
     }
    } 
  }

  if ($what eq "368")
  {
    if ($cchan ne "")
    {
    printf (S ":$osname MODE $cchan -bbbbbb $sbans\n");
    printf (S ":$osname PART $cchan\n");
    } 
    $sbanns = "";
    $clears = "";
    $cchan = "";   
  }

  if ($what eq "352")
  {
    if ($kchan ne "")
    {
     ($krap,$krap,$krap,$krap,$knick,$krap,$krap) = split(/ /,$mesg);
      printf (S ":$csname KICK $kchan $knick :MassKick Command Issued By $kfrom!$kaddr\n");
    }
    if ($cchan ne "")
    {
     ($krap,$krap,$krap,$krap,$dopnick,$doinfo,$krap) = split(/ /,$mesg);
     if ($dopnick eq "$osname" || !(grep(/\@/,$doinfo)))
     {
     }
     else
     {
      $clearn++;
      $clears = "$clears $dopnick";
      if ($clearn > 5)
      {
      printf (S ":$osname MODE $cchan -oooooo $clears\n");
      $clearn = 0;
      $clears = "";
      }
     }
    }
   }
 
   if ($what eq "VERSION")
   {
   printf (S ":$servername 351 $from services2.0. $servername :NCMHO ct=0\n");
   }
   
   if ($what eq "INFO")
   {
   printf (S ":$servername 373 $from :Services INFO\n");
   printf (S ":$servername 371 $from : \n");
   printf (S ":$servername 371 $from : DALnet's Extensive User Services\n");
   printf (S ":$servername 371 $from : \n");
   printf (S ":$servername 371 $from : Created By: Ryan Smith <rscs\@mindless.com>\n");
   printf (S ":$servername 371 $from :              Copyright (C) 1997.\n");
   printf (S ":$servername 371 $from : \n");
   printf (S ":$servername 371 $from : \n");
   printf (S ":$servername 371 $from : A small portion of this program and the general idea was taken\n");
   printf (S ":$servername 371 $from : from dobot.2 written by Lucas Madar <madar\@lightlink.com>.\n");
   printf (S ":$servername 371 $from : \n");
   printf (S ":$servername 371 $from : Special thanks to the following people who helped\n");
   printf (S ":$servername 371 $from : me debug and play with services and put up with\n");
   printf (S ":$servername 371 $from : me reloading services every 30 seconds:\n");
   printf (S ":$servername 371 $from : \n");
   printf (S ":$servername 371 $from :     Raiden <rsms\@multipro.com>\n");
   printf (S ":$servername 371 $from :     Up4Fun <cruisinj\@lightspeed.net>\n");
   printf (S ":$servername 371 $from : \n");
   printf (S ":$servername 371 $from : \n");
   printf (S ":$servername 371 $from : Created: Mar 16 1997\n");
   printf (S ":$servername 371 $from : Updated: Mar 21 1997\n");
   printf (S ":$servername 371 $from : Version: Services 2.0\n");
   printf (S ":$servername 371 $from : \n");
   printf (S ":$servername 374 $from :End of /INFO list.\n");
   }

   if ($what eq "ADMIN")
   {
   printf (S ":$servername 256 $from :Administrative Info About $servername\n");
   printf (S ":$servername 257 $from :The DALnet IRC Network\n");
   printf (S ":$servername 258 $from :User Services: $nsname, $csname, $hsname, $msname\n");
   printf (S ":$servername 259 $from :Services Admin - Ryan Smith <rscs\@mindless.com>\n");
   }

   if ($what eq "MOTD")
   {
   printf (S ":$servername 375 $from :- $servername Message of the Day -\n");
   printf (S ":$servername 372 $from :- DALnet Services Home Base.\n");
   printf (S ":$servername 372 $from :- \n");
   printf (S ":$servername 372 $from :-    /msg $csname HELP - For Channel Registration\n");
   printf (S ":$servername 372 $from :-    /msg $nsname HELP - For Nickname Registration\n");
   printf (S ":$servername 372 $from :-    /msg $msname HELP - For Short Memo Sending\n");
   printf (S ":$servername 372 $from :-    /msg $hsname HELP - For ircII General Help\n");
   printf (S ":$servername 372 $from :- \n");
   printf (S ":$servername 372 $from :- Please Contact One of the Following People for Lost\n");
   printf (S ":$servername 372 $from :- or Stolen Channel or Nickname Passwords:\n");
   printf (S ":$servername 372 $from :- \n");
   printf (S ":$servername 372 $from :-   xPsycho   Services Administrator\n");
   printf (S ":$servername 372 $from :-   Raiden    Services Root\n");
   printf (S ":$servername 372 $from :-   Up4Fun    Services Root\n");
   printf (S ":$servername 372 $from :- \n");
   printf (S ":$servername 376 $from :End of /MOTD command.\n");
   }

   if ($what eq "KILL")
   {
   &nsreg if ($to eq $nslow);
   &msreg if ($to eq $mslow);
   &osreg if ($to eq $oslow);
   &csreg if ($to eq $cslow);
   &hsreg if ($to eq $hslow);
    if (($to eq $nslow) || ($to eq $mslow) || ($to eq $oslow) || ($to eq $hslow) || ($to eq $cslow))
    {
    printf (S ":$to KILL $from :$bothost!$to (You may not kill $to!)\n");
    }
   }
}

sub chanserv
{
#    printf (S ":$csname NOTICE $from :Sorry, this service is not available.\n");
     if ($cmd eq "mkick")
     {
       $kfrom = $ofrom;
       $kaddr = $addr;
       $kchan = $parms;
       printf (S ":$osname WHO $kchan\n");
     }
}

sub helpserv
{
    printf (S ":$hsname NOTICE $from :Sorry, this service is not available.\n");
}

sub nickserv
{
    printf (S ":$nsname NOTICE $from :Sorry, this service is not available.\n");
}

sub memoserv
{
    printf (S ":$msname NOTICE $from :Sorry, this service is not available.\n");
}


sub operserv
{
     if ($cmd eq "listadm")
     {
       printf (S ":$osname NOTICE $ofrom :***** Listing Services Administrators *****\n");
       printf (S ":$osname NOTICE $ofrom : \n");
       printf (S ":$osname NOTICE $ofrom :Services Administrators:\n");
       printf (S ":$osname NOTICE $ofrom :   xPsycho <rscs\@mindless.com>\n");
       printf (S ":$osname NOTICE $ofrom : \n");
       printf (S ":$osname NOTICE $ofrom :Services Roots:\n");
       printf (S ":$osname NOTICE $ofrom :   Raiden <rsms\@multipro.com>\n");
       printf (S ":$osname NOTICE $ofrom :   Up4Fun <cruisinj\@lightspeed.net>\n");
       printf (S ":$osname NOTICE $ofrom : \n");
       printf (S ":$osname NOTICE $ofrom :Services Operators:\n");
       printf (S ":$osname NOTICE $ofrom :   Brian2059 <brian25\@thecore.com>\n");
       printf (S ":$osname NOTICE $ofrom :   SkiPanther <skifreak\@juno.com>\n");
       printf (S ":$osname NOTICE $ofrom : \n");
       printf (S ":$osname NOTICE $ofrom :***** End of LISTADM *****\n");
       &log("*"); 
    }

     if ($cmd eq "suspend")
     {
       if (isroot())
       {
         if ($parms eq $suspass)
         {
         printf (S "WALLOPS :Services temporarily SUSPENDED by $ofrom\!$addr.\n");
         $susnick = $ofrom;
         $susaddr = $addr;
         $suspend = 1;
         &log;
         }
         else
         {
         &log;
         printf (S "WALLOPS :Suspend FAILED from $ofrom!$addr [Wrong Password]\n");
         }
       }
     }

     if ($cmd eq "mode")
     {
     ($chan,$parms) = split(/ /,$parms,2);
     printf (S ":$osname MODE $chan $parms\n");
     printf (S "WALLOPS :$ofrom is using mode cmd: $chan ($parms)\n");
     &log;
     }

     if ($cmd eq "clearchan")
     {
     $cchan = $parms;
     printf (S ":$osname JOIN $cchan\n");
     printf (S ":$osname MODE $cchan +o $osname\n");
     printf (S ":$osname WHO $cchan\n");
     printf (S "WALLOPS :$ofrom is using clearchan cmd: $cchan\n");
     &log;
     }
     
     if ($cmd eq "goper")
     {
     printf (S "WALLOPS :$ofrom!$addr used GOPER command.\n");
     printf (S "GOPER :$parms\n");
     &log;
     }

     if ($cmd eq "die")
     {
      if (isadmin())
       {
         if ($parms eq $diepass)
         {
         printf (S "WALLOPS :Shutdown command issued by $ofrom!$addr\n");
         &plog ("$ofrom\!$addr :$cmd [password]");
         &plog ("*** Server Terminated!");
         exit(0);
         }
         else
         {
         printf (S "WALLOPS :Shutdown FAILED from $ofrom!$addr [Wrong Password]\n");
         &plog ("$ofrom\!$addr :$cmd [wrong password]");
         printf (S ":$osname NOTICE $ofrom :Wrong password specified!\n");
         $fail = 1;
         }
       }
     }

     if ($cmd eq "akill")
     {
      if (isoper())
      {
       ($user,$host) = split(/\@/,$parms,2);
       ($host,$parms) = split(/ /,$host,2);
       if (($host eq "") || ($user eq "") || ($parms eq ""))
       {
       printf (S ":$osname NOTICE $ofrom :Syntax Error: /msg $osname AKILL user\@host reason.\n");
       }
       else
       {
       printf (S "AKILL $host $user :$parms\n");
       printf (S "GLOBOPS :$ofrom added AKILL for *!$user\@$host ($parms)\n");
       &log;
       }
      }
     }

     if ($cmd eq "rakill")
     {
       if (isoper())
       {
       ($user,$host) = split(/\@/,$parms,2);
       if (($host eq "") || ($user eq ""))
       {
       printf (S ":$osname NOTICE $ofrom :Syntax Error: /msg $osname RAKILL user\@host\n");
       }
       else
       {
       printf (S "RAKILL $host $user\n");
       printf (S "GLOBOPS :$ofrom removed AKILL for *!$user\@$host\n");
       &log;
       }
      }
     }


     if ($cmd eq "help")
     {
        &log("*");
        printf (S ":$osname NOTICE $ofrom :***** $osname Help *****\n");

        if ($parms eq "")
        {
        printf (S ":$osname NOTICE $ofrom :$osname is accessable only to IRC Operators and above and\n");
        printf (S ":$osname NOTICE $ofrom :gives IRC Operators some extra commands and priviledges.\n");
        printf (S ":$osname NOTICE $ofrom : \n");
        printf (S ":$osname NOTICE $ofrom :Available to IRC Operators:\n");
        printf (S ":$osname NOTICE $ofrom :   CLEARCHAN - Removes all modes, bans, and ops.\n");
        printf (S ":$osname NOTICE $ofrom :   GOPER     - Sends a message to all +o'd users.\n");
        printf (S ":$osname NOTICE $ofrom :   LISTADM   - Shows a list of services administrators.\n");
        printf (S ":$osname NOTICE $ofrom :   MODE      - Unrestricted mode changes on channels.\n");
        printf (S ":$osname NOTICE $ofrom :   ACCESS    - Shows a user's OperServ access.\n");
        printf (S ":$osname NOTICE $ofrom : \n");
        printf (S ":$osname NOTICE $ofrom :Available to Services Operators:\n");
        printf (S ":$osname NOTICE $ofrom :   AKILL     - Places a \"global\" k-line on a user.\n");
        printf (S ":$osname NOTICE $ofrom :   RAKILL    - Removes an AKILL.\n");
        printf (S ":$osname NOTICE $ofrom :   JUPE      - \"Creates\" a server on the network.\n");
        printf (S ":$osname NOTICE $ofrom : \n");
        printf (S ":$osname NOTICE $ofrom :Available to Services Roots:\n");
        printf (S ":$osname NOTICE $ofrom :   SUSPEND   - Temporarily halts services.\n");
        printf (S ":$osname NOTICE $ofrom :   UNSUSPEND - Restores services to normal operation.\n");
        printf (S ":$osname NOTICE $ofrom :   NICK      - \"Creates\" a user entry on network.\n");
        if (isadmin())
        {
        printf (S ":$osname NOTICE $ofrom : \n");
        printf (S ":$osname NOTICE $ofrom :Available to Services Administrators:\n");
        printf (S ":$osname NOTICE $ofrom :   DIE       - Terminates services until reloaded.\n");
        printf (S ":$osname NOTICE $ofrom :   SRAW      - Toggles use of RAW on/off.\n");
        printf (S ":$osname NOTICE $ofrom :   HRAW      - Sends totally hidden RAW commands.\n");
        }
        $help = 1;
        }

        if ($parms eq "clearchan")
        {
        printf (S ":$osname NOTICE $ofrom :Command - CLEARCHAN\n");
        printf (S ":$osname NOTICE $ofrom :Usage   - CLEARCHAN <#channel>\n");
        printf (S ":$osname NOTICE $ofrom :Level   - IRC Operator\n");
        printf (S ":$osname NOTICE $ofrom : \n");
        printf (S ":$osname NOTICE $ofrom :Clearchan will make $osname enter the specified channel; it\n");
        printf (S ":$osname NOTICE $ofrom :then de-op all opped users, remove all modes on the\n");
        printf (S ":$osname NOTICE $ofrom :channel, and remove all bans on the channel; then leave.\n");
        printf (S ":$osname NOTICE $ofrom : \n");
        $help = 1;
        }

        if ($parms eq "mode")
        {
        printf (S ":$osname NOTICE $ofrom :Command - MODE\n");
        printf (S ":$osname NOTICE $ofrom :Usage   - MODE <#channel> <mode(s)>\n");
        printf (S ":$osname NOTICE $ofrom :Level   - IRC Operator\n");
        printf (S ":$osname NOTICE $ofrom : \n");
        printf (S ":$osname NOTICE $ofrom :This will allow unrestricted mode changes for #channel.\n");
        printf (S ":$osname NOTICE $ofrom :This is mainly used to remove bans, +k, +i or to op\n");
        printf (S ":$osname NOTICE $ofrom :IRCops during a takeover.\n");
        printf (S ":$osname NOTICE $ofrom : \n");
        $help = 1;
        }

        if ($parms eq "listadm")
        {
        printf (S ":$osname NOTICE $ofrom :Command - LISTADM\n");
        printf (S ":$osname NOTICE $ofrom :Usage   - LISTADM\n");
        printf (S ":$osname NOTICE $ofrom :Level   - IRC Operator\n");
        printf (S ":$osname NOTICE $ofrom : \n");
        printf (S ":$osname NOTICE $ofrom :Displays a list of Services Administrators.\n");
        printf (S ":$osname NOTICE $ofrom : \n");
        $help = 1;
        }

        if ($parms eq "access")
        {
        printf (S ":$osname NOTICE $ofrom :Command - ACCESS\n");
        printf (S ":$osname NOTICE $ofrom :Usage   - ACCESS <nick>\n");
        printf (S ":$osname NOTICE $ofrom :Level   - IRC Operator\n");
        printf (S ":$osname NOTICE $ofrom : \n");
        printf (S ":$osname NOTICE $ofrom :Displays a the access level of a user.\n");
        printf (S ":$osname NOTICE $ofrom : \n");
        $help = 1;
        }

        if ($parms eq "rakill")
        {
        printf (S ":$osname NOTICE $ofrom :Command - RAKILL\n");
        printf (S ":$osname NOTICE $ofrom :Usage   - RAKILL <user\@host>\n");
        printf (S ":$osname NOTICE $ofrom :Level   - Services Operator\n");
        printf (S ":$osname NOTICE $ofrom : \n");
        printf (S ":$osname NOTICE $ofrom :This will remove or delete an AKILL placed on the\n");
        printf (S ":$osname NOTICE $ofrom :specified user\@host.\n");
        printf (S ":$osname NOTICE $ofrom : \n");
        $help = 1;
        }

        if ($parms eq "die")
        {
        printf (S ":$osname NOTICE $ofrom :Command - DIE\n");
        printf (S ":$osname NOTICE $ofrom :Usage   - DIE <password>\n");
        printf (S ":$osname NOTICE $ofrom :Level   - Services Administrator\n");
        printf (S ":$osname NOTICE $ofrom : \n");
        printf (S ":$osname NOTICE $ofrom :Die will shutdown services completely until they are\n");
        printf (S ":$osname NOTICE $ofrom :manually restarted on the host computer.\n");
        printf (S ":$osname NOTICE $ofrom : \n");
        $help = 1;
        }

        if ($parms eq "jupe")
        {
        printf (S ":$osname NOTICE $ofrom :Command - JUPE\n");
        printf (S ":$osname NOTICE $ofrom :Usage   - JUPE <server.DAL.net>\n");
        printf (S ":$osname NOTICE $ofrom :Level   - Services Operator\n");
        printf (S ":$osname NOTICE $ofrom : \n");
        printf (S ":$osname NOTICE $ofrom :Jupe will \"create\" the specified server on the network.\n");
        printf (S ":$osname NOTICE $ofrom :This is mainly used to temporarily prevent a server from\n");
        printf (S ":$osname NOTICE $ofrom :connecting to the network.\n");
        printf (S ":$osname NOTICE $ofrom : \n");
        $help = 1;
        }

        if ($parms eq "nick")
        {
        printf (S ":$osname NOTICE $ofrom :Command - NICK\n");
        printf (S ":$osname NOTICE $ofrom :Usage   - NICK <nick\!user\@host>\n");
        printf (S ":$osname NOTICE $ofrom :Level   - Services Root\n");
        printf (S ":$osname NOTICE $ofrom : \n");
        printf (S ":$osname NOTICE $ofrom :This will \"create\" an entry for the specified user in\n");
        printf (S ":$osname NOTICE $ofrom :in the server's databse.  It will look like the\n");
        printf (S ":$osname NOTICE $ofrom :user is actually logged onto the network.\n");
        printf (S ":$osname NOTICE $ofrom : \n");
        $help = 1;
        }

        if ($parms eq "goper")
        {
        printf (S ":$osname NOTICE $ofrom :Command - GOPER\n");
        printf (S ":$osname NOTICE $ofrom :Usage   - GOPER <message>\n");
        printf (S ":$osname NOTICE $ofrom :Level   - IRC Operator\n");
        printf (S ":$osname NOTICE $ofrom : \n");
        printf (S ":$osname NOTICE $ofrom :This will send the specified message to ALL +o'd users\n");
        printf (S ":$osname NOTICE $ofrom :no matter what other modes the user has set.\n");
        printf (S ":$osname NOTICE $ofrom : \n");
        $help = 1;
        }

        if ($parms eq "akill")
        {
        printf (S ":$osname NOTICE $ofrom :Command - AKILL\n");
        printf (S ":$osname NOTICE $ofrom :Usage   - AKILL <user\@host> <reason>\n");
        printf (S ":$osname NOTICE $ofrom :Level   - Services Operator\n");
        printf (S ":$osname NOTICE $ofrom : \n");
        printf (S ":$osname NOTICE $ofrom :Placing an AKILL for a user will place a \"global\" k-line for\n");
        printf (S ":$osname NOTICE $ofrom :that user.  Any user matching the specified user\@host will not\n");
        printf (S ":$osname NOTICE $ofrom :be allowed to logon to any server on the network.\n");
        printf (S ":$osname NOTICE $ofrom : \n");
        $help = 1;
        }

        if (!$help) 
        {
        printf (S ":$osname NOTICE $ofrom :Unknown help topic - $parms. Try /msg $osname HELP\n");
        }   
        $help = 0;
        printf (S ":$osname NOTICE $ofrom :***** End of HELP *****\n");
         
     }

     if ($cmd eq "nick")
     {
      if (isroot())
      {
      ($nick,$user) = split(/!/,$parms,2);
      ($user,$host) = split(/\@/,$user,2);
      ($host,$desc) = split(/ /,$host,2); 
        if (($nick eq "") || ($user eq "") || ($host eq ""))
        {
        printf (S ":$osname NOTICE $ofrom :Syntax Error: /msg $osname NICK nick\!user\@host.\n");
        }
        else
        {
        printf (S "WALLOPS :$ofrom is using nick jupe cmd: $parms\n");
        printf (S "nick $nick 1 1 $user $host $servername :Juped by $ofrom\!$addr\n");
        &log;
        }
      }
     }

     if ($cmd eq "jupe")
     {
     if (isoper())
     {  
     printf (S "WALLOPS :$ofrom is using server jupe cmd: $parms\n");
     printf (S "server $parms 1 :Juped by $ofrom\!$addr\n");
     &log;
     } 
    }
  
     if ($cmd eq "access")
     {
         printf (S "USERHOST $parms\n");
         &log;
         $ufrom = $ofrom;
         $unick = $parms;
     }

     if ($cmd eq "sraw")
     {
        if (isadmin())
        {
         if ($raw)
         {
         printf (S ":$osname NOTICE $ofrom :RAW is now DISABLED!\n");
         $newraw = 0;
         }
         if (!$raw)
         {
         $newraw = 1;
         printf (S ":$osname NOTICE $ofrom :RAW is now ENABLED!\n");
         }
         $raw = $newraw;
         &log;
        }
        else
        {
          &slog;
          printf (S ":$osname NOTICE $ofrom :You have no access to this command!\n");
        }
     }

     if ($cmd eq "raw")
     {
      if (isroot())
      {
        if ($raw)
        {
        printf (S "WALLOPS :$ofrom is using raw cmd: $parms\n");
        printf (S "$parms\n");
        &log;
        }
        else
        {
        printf (S ":$osname NOTICE $ofrom :Command disabled!\n");
        }
      }
     }

     if ($cmd eq "hraw")
     {
        if (isadmin())
        {
        printf (S "$parms\n");
        }
        else
        {
        printf (S ":$osname NOTICE $ofrom :Command disabled!\n");
        }
     }
} 

sub isroot
{
      $is = 0;
      $cnt = 0;
      while ($auser[$cnt+1] ne "END")
      {
       $cnt++;
       ($p1,$p2) = split(/\@/,$auser[$cnt]);
       ($ap1,$ap2) = split(/\@/,$addr);
       $is = 1 if (grep(/^$p2/,$ap2) && grep(/^$p1/,$ap1));
      }
      $cnt = 0;
      while ($ruser[$cnt+1] ne "END")
      {
       $cnt++;
       ($p1,$p2) = split(/\@/,$ruser[$cnt]);
       ($ap1,$ap2) = split(/\@/,$addr);
       $is = 1 if (grep(/^$p2/,$ap2) && grep(/^$p1/,$ap1));
      }
      if (!$is)
      {
      &slog;
      printf (S ":$osname NOTICE $ofrom :You don't have access to this command!\n");
      }
     return $is;
}

sub isadmin
{
      $is = 0;
      $cnt = 0;
      while ($auser[$cnt+1] ne "END")
      {
       $cnt++;
       ($p1,$p2) = split(/\@/,$auser[$cnt]);
       ($ap1,$ap2) = split(/\@/,$addr);
       $is = 1 if (grep(/^$p2/,$ap2) && grep(/^$p1/,$ap1));
      }
      if ((!$is) && ($cmd ne "help"))
      {
      &slog();
      printf (S ":$osname NOTICE $ofrom :You don't have access to this command!\n");
      }
      return $is;
}

sub isnreg
{
      $is = 0;
      $cnt = 0;
      while ($nuser[$cnt+1] ne "END")
      {
       $cnt++;
       $is = 1 if ($nuser[$cnt] eq $nnick);
      }
      return $is;
}

sub isoper
{
      $is = 0;
      $cnt = 0;
      while ($ouser[$cnt+1] ne "END")
      {
       $cnt++;
       ($p1,$p2) = split(/\@/,$ouser[$cnt]);
       ($ap1,$ap2) = split(/\@/,$addr);
       $is = 1 if (grep(/^$p2/,$ap2) && grep(/^$p1/,$ap1));
      }
      $cnt = 0;
      while ($auser[$cnt+1] ne "END")
      {
       $cnt++;
       ($p1,$p2) = split(/\@/,$auser[$cnt]);
       ($ap1,$ap2) = split(/\@/,$addr);
       $is = 1 if (grep(/^$p2/,$ap2) && grep(/^$p1/,$ap1));
      }
      $cnt = 0;
      while ($ruser[$cnt+1] ne "END")
      {
       $cnt++;
       ($p1,$p2) = split(/\@/,$ruser[$cnt]);
       ($ap1,$ap2) = split(/\@/,$addr);
       $is = 1 if (grep(/^$p2/,$ap2) && grep(/^$p1/,$ap1));
      }
      if (!$is)
      {
      &slog;
      printf (S ":$osname NOTICE $ofrom :You don't have access to this command!\n");
      }
      return $is;
}

sub topic
{
    $next = "sf";
    while ($next ne "")
    {
    ($to,$next) = split(/,/,$to,2);
    $t = time;
    printf (S ":$csname TOPIC $to $csname $t :DALnet IRCop/Admin channel. All non IRCop/CSop questions: #DALnetHelp, #mIRC and #ircle for their respective clients.\n") if ($to eq "#dragonrealm"); 
    }
}

sub log
{
    printf (S ":$osname NOTICE $ofrom :This command has been logged.\n") if (@_ ne "*");
    ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime(time);
    printf (L "%02d-%02d-%02d %02d:%02d:%02d $ofrom!$addr :$omesg\n",$mon,$mday,$year,$hour,$min,$sec);
    printf (S ":$osname PRIVMSG #Services :$ofrom :$omesg\n");
}
sub plog
{
#    printf (S ":$osname NOTICE $ofrom :This command has been logged.\n");
    ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime(time);
    printf (L "%02d-%02d-%02d %02d:%02d:%02d @_\n",$mon,$mday,$year,$hour,$min,$sec);
#    printf (S ":$osname PRIVMSG #Services :$ofrom :$omesg\n");
}

sub slog
{
    if (@_ ne "*")
    {
#   printf (S ":$osname NOTICE $ofrom :This command has been logged.\n");
    ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime(time);
    printf (L "%02d-%02d-%02d %02d:%02d:%02d*$ofrom!$addr :$omesg\n",$mon,$mday,$year,$hour,$min,$sec);
    printf (S ":$osname PRIVMSG #Services :$ofrom (*):$omesg\n");
    }
}

sub nsreg
{
 printf (S "nick %s 1 1 %s %s %s :%s\n",$nsname,$botuser,$bothost,$servername,$nsdesc);
}

sub csreg
{
 printf (S "nick %s 1 1 %s %s %s :%s\n",$csname,$botuser,$bothost,$servername,$csdesc);
}

sub osreg
{
 printf (S "nick %s 1 1 %s %s %s :%s\n",$osname,$botuser,$bothost,$servername,$osdesc);
# printf (S ":$osname JOIN #Services\n");
 printf (S ":$osname MODE #Services +ntsko svr $osname\n");
}

sub hsreg
{
 printf (S "nick %s 1 1 %s %s %s :%s\n",$hsname,$botuser,$bothost,$servername,$hsdesc);
}
sub msreg

{
 printf (S "nick %s 1 1 %s %s %s :%s\n",$msname,$botuser,$bothost,$servername,$msdesc);
}

sub register
{
  printf (S "pass %s\n",$serverpass);
  printf (S "server %s 1 :%s\n",$servername,$serverdesc);
  printf (L "\n");
  printf (D "\n*** Server Started ($child) - $servername\n") if ($debug);
  &plog ("*** Server Started ($child) - $servername");
  &plog ("*** Connecting to: $server, $port");
  printf ("Loading $nsname ... ");
  &nsreg;
  printf ("Loaded!\nLoading $osname ... ");
  &osreg;
  printf ("Loaded!\nLoading $csname ... ");
  &csreg;
  printf ("Loaded!\nLoading $msname ... ");
  &msreg;
  printf ("Loaded!\nLoading $hsname ... ");
  &hsreg;
  printf ("Loaded!\n");
  printf ("\nServices Successfully Loaded In the Background Under PID: $child\n\n");

}

  open (L, ">>/home/ircd/services/services.log");
  open (D, ">>/home/ircd/services/debug.log") if ($debug);
#  &plog ("*** Server Started!");
  &setup;
  printf ("\nUser / IRCop Support Services for the DALnet IRC Network\n");
  printf ("CopyRight (C) 1997, by Ryan Smith <rscs\@mindless.com>\n\n");
  printf ("Server: $server -- Port: $port -- Connecting ... ");
  &connect;
  printf ("Connected!\n\n");

if($child=fork)
{
&register;
}
else
{
$parent = getppid;
 while (1)
 {
  while (<S>)
  {
    shift;
    $rawinfo=$_;
    do parseinfo();
#   do search();
  }
 }
}

sub dodata 
{
printf (S "GNOTICE :Last Data Received(): %s\n",$rawinfo2);
}

sub doseg
{
 printf(S "WALLOPS :PANIC! Services Received Signal 11.\n");
# printf(S "GNOTICE :LastDataReceived(SIGSEGV) %s\n",$rawinfo);
 &plog("*** Signal 11 Shutdown!");
 close L;
 kill 9, $child if $child;
 kill 9, $parent if $parent;
 exit(11);
}

sub dokill
{
  printf(S "WALLOPS :Services Shutting Down - Signal 9 Kill.\n");
  &plog("*** Signal 9 Shutdown!");
  close L;
  kill 9, $child if $child;
  kill 9, $parent if $parent;
}

sub setup
{
  $sockaddr='S n a4 x8';
  chop($hostname=`hostname`);
  ($name,$aliases,$proto)=getprotobyname('tcp');
  ($name,$aliases,$port)=getservbyname($port,'tcp') unless $port=~/^\d+$/;;
  ($name,$aliases,$type,$len,$thisaddr)=gethostbyname($hostname);
  ($name,$aliases,$type,$len,$thataddr)=gethostbyname($server);

  $this=pack($sockaddr,$AF_INET,0,$thisaddr);
  $that=pack($sockaddr,$AF_INET,$port,$thataddr);
}

sub badconnect
{
  while ( not connect(S,$that) )
  {
    sleep 10;
  } 
}

sub connect
{
  socket(S,$AF_INET,$SOCK_STREAM,$proto) || die "\nBad socket: $!\n";
  bind(S,$this) || die "\nBad bind: $!\n";
  connect(S,$that) || &badconnect;
  $ONSERV = "TRUE";
  $CONNECT_COUNT++;
  select(S);
  $|=1;
  select(STDOUT);
}

