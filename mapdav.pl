#!/usr/bin/perl
# MAPDAV More Accurate Password Dictionary Attack Vector
# by oxagast, last modified 08,24,2015
use warnings;
use File::Copy qw(move);
use Algorithm::Combinatorics qw(variations);
my $version = "v2.5";
$semcol = 0;
$crop = 0;
$maxPossible = 4;
if ( scalar(@ARGV) <= 1 )
{
  versionStuff();
  exit(1);
}
for $issemcol ( 0 .. $#ARGV )
{
  if ( $ARGV[$issemcol] =~ m/:/ )
  {
    $semcol = 1;
  }
}
if ( $semcol == 0)
{
  defaultCombos();
}
$wfn_tmp         = "wl_tmp-" . int( rand(999) );
$numGoHigh       = -1;
$overwrite       = "false";
$cropRot         = 0;
$amid            = "";
$apre            = "";
$apost           = "";
$passwd          = "";
$uniqueGuessOnly = "false";
$crop            = 0;
$isAllCombo      = "false";
$nfile           = "";
$nowrite         = "false";
$wfn             = $wfn_tmp;
$alldat          = "false";
$outtype         =  "WORDLIST";
flags();




sub defaultCombos
{
  # Default Combos
  push @ARGV, "FN:", "LN:", "MN:", "Fi:", "Mi:", "Li:", "FI:", "MI:", "LI:", "FN:LN", "LN:FN";
  push @ARGV, "FN:MN:LN",   "FN:MI:LN",   "FI:MI:LN", "FN:MI:LI", "FI:MI:LI", "[rev]FN:", "[rev]LN:";
  push @ARGV, "[rev]FN:LN", "FN:[rev]LN", "[rev]FN:", "[rev]LN:", "[rev]MN:", "fn:",      "ln:", "mn:";
  push @ARGV, "FI:",        "MI:",        "LI:",      "fn:ln",    "ln:fn",    "fn:mn:ln", "fn:mi:ln", "fi:mi:ln", "fn:mi:li";
  push @ARGV, "fi:mi:li", "[rev]fn:", "[rev]ln:",   "[rev]fn:ln", "fn:[rev]ln",      "[rev]fn:[rev]ln";
  push @ARGV, "[rev]mn:", "Fn:",      "Ln:",        "Mn:",        "Fn:Ln",           "Ln:Fn", "Fn:Mn:Ln", "Fn:MI:Ln", "Fi:Mi:Ln";
  push @ARGV, "Fn:Mi:Li", "Fi:Mi:Li", "[rev]Fn:Ln", "Fn:[rev]Ln", "[rev]Fn:[rev]Ln", "[rev]FN:[rev]LN";
  push @ARGV, "[rev]Fn:", "[rev]Ln", "[rev]Mn:", "FN:ln", "fn:LN", "LN:fn", "ln:FN", "Fn:ln";
  push @ARGV, "Ln:fn", "Fn:mn:ln", "Ln:mn:fn", "UN:", "un:", "Un:";
  $semcol = 1;
}

sub allCombos
{
  for $howManyPossible (1..$maxPossible) 
  {
    @possibles = qw(FN: LN: fn: ln: Ln: Fn: Fi: fi: Li: li: FI: Mi: MI: mi: Mn: MN: mn: Un: UN: un: [rev]FN: [rev]LN: [rev]fn: [rev]ln: [rev]Ln: [rev]Fn: [rev]Fi: [rev]fi: [rev]Li: [rev]li: [rev]FI: [rev]Mi: [rev]MI: [rev]mi: [rev]Mn: [rev]MN: [rev]mn: [rev]Un: [rev]UN: [rev]un:);
    my $iter = variations(\@possibles, $howManyPossible);
    while (my $c = $iter->next) 
    {
      push (@blah, "@$c");
    }
  }
  for $perm (0..$#blah) 
  {
    $blah[$perm] =~ s/ //g;
#    print "$blah[$perm]\n";
    push (@ARGV, $blah[$perm]);
  }
}


sub versionStuff
{
  print "MAPDAV $version\n";
  print "Useage: $0 \[options\] \{combinations\}\n";
  print "  OPTIONS:\n";
  print "   --passwdfile <file>: Password file you want to use\n";
  print "   --namesfile <file>: Line by line list of names to use\n";
  print "   --hydra <file>: Output to THCHydra file format\n";
  print "   --wordlist <file>: Output to wordlist file format\n";
  print "   --singleuser <username>: Only process a single user\n";
  print "   --append-post xyz: Append string to the end of each combination\n";
  print "   --append-mid xyz: Append string inbetween names of each combination\n";
  print "   --append-pre xyz: Append string to the beginning of each combination\n";
  print "   --crop x: Crop the passwords to this many characters\n";
  print "   --crop-rotate x: Rotate around cropping from 2 through x characters (not implemented)\n";
  print "   --count x: Count through numbers 0 through x and put in places\n                (this takes awhile, DO NOT SET THIS TOO HIGH! >9)\n";
  print "   --overwrite: MAPDAV will overwrite the destined output file\n";
  print "   --unique: Only output unique values (not implemented)\n";
  print "   --threads x: How many processing threads to use, this applies to counts (not implemented)\n";
  print "   --username <username>: A username for singular input\n";
  print "   --full-name <\"Their Full Name\">: Their full name for singular input\n";
  print "   --all-data <\"225 glory joe chapfeild 555 7533 5557533\">: Permutations\n";
  print "   --exaust: Exhaustive list of combinations.  List will be very large\n";
  print "   --verbose: Make output verbose\n";
  print "   --version: Print the version\n";
  print "  COMBINATIONS:\n";
  print "   fn Fn FN fi Fi mn Mn MN mi Mi ln Ln LN li Li un Un UN\n";
  print "  MODIFIERS:\n";
  print "   [rev]\n";
  print "\n       ex:\n";
  print "           $0 --passwdfile passwd --hydra names.hydra --overwrite --unique FN:LN [rev]fn:\n";
  print "           $0 --passwdfile passwd --wordlist names.wl\n";
  print "           $0 --passwdfile passwd --hydra names.hydra --crop 8\n";
  print "           $0 --full-name \"John Unknown Doe\" --username djohn --count 9 --overwrite --wordlist jud.out --threads 8 --verbose\n";
}

sub flags
{
  #  grabs all our options
  if ( ( ( scalar(@ARGV) > 0 ) && ( $semcol == 1 ) ) || ( $ARGV[0] eq "--version" ) )
  {
    $numOfOpArgs = 0;
    $apost      = "";
    $apre       = "";
    $verbose    = "false";
    $versionarg = "false";
    $singleuser = "notsingleusermode";
    for my $optarg ( 0 .. $#ARGV )
    {
       if ( $ARGV[$optarg] eq "--full-name" )
      {
   push( @fullname, $ARGV[ $optarg + 1 ]);
   $alldat      = "false";
        $outtype     = "WORDLIST";
    $user        = 0;
        $numOfOpArgs = $numOfOpArgs + 2;
      }     
      if ( $ARGV[$optarg] eq "--passwdfile" )
      {
        $passwd      = $ARGV[ $optarg + 1 ];
        $numOfOpArgs = $numOfOpArgs + 2;
      }
      if ( $ARGV[$optarg] eq "--namesfile" )
      {
        $nfile       = $ARGV[ $optarg + 1 ];
        $user = 0;
        $numOfOpArgs = $numOfOpArgs + 2;
      }
      if ( $ARGV[$optarg] eq "--hydra" )
      {
        if (($ARGV[$optarg + 1] =~ m/--/) || ($ARGV[$optarg + 1] =~ m/:/) || ($optarg >= $#ARGV))
        {
          $nowrite = "true";
          $outtype = "HYDRA";
          $numOfOpArgs++;
        }
        else {
          $outtype         = "HYDRA";
          $nowrite = "false";
          $wfn         = $ARGV[ $optarg + 1 ];
          $numOfOpArgs = $numOfOpArgs + 2;
        }
      }
      if ( $ARGV[$optarg] eq "--wordlist" )
      {
        if (($ARGV[$optarg + 1] =~ m/--/) || ($ARGV[$optarg + 1] =~ m/:/) || ($optarg >= $#ARGV))
        {
          $nowrite = "true";
          $outtype = "WORDLIST";
          @userName[0]     = " ";
          $numOfOpArgs++;
        }
        else {
          $outtype = "WORDLIST";
          $nowrite = "false";
          $wfn         = $ARGV[ $optarg + 1 ];
          @userName[0]     = " ";
          $numOfOpArgs = $numOfOpArgs + 2;
        }
      }
      if ( $ARGV[$optarg] eq "--unique" )
      {
        $uniqueGuessOnly = "true";
        $numOfOpArgs++;
      }
      if ( $ARGV[$optarg] eq "--exhaust" )
      {
        $isAllCombo = "true";
        $numOfOpArgs++;
      }
      if ( $ARGV[$optarg] eq "--append-post" )
      {
        $apost       = $ARGV[ $optarg + 1 ];
        $numOfOpArgs = $numOfOpArgs + 2;
      }
      if ( $ARGV[$optarg] eq "--append-pre" )
      {
        $apre        = $ARGV[ $optarg + 1 ];
        $numOfOpArgs = $numOfOpArgs + 2;
      }
      if ( $ARGV[$optarg] eq "--append-mid" )
      {
        $amid        = $ARGV[ $optarg + 1 ];
        $numOfOpArgs = $numOfOpArgs + 2;
      }
      if ( $ARGV[$optarg] eq "--crop" )
      {
        $crop        = $ARGV[ $optarg + 1 ];
        $numOfOpArgs = $numOfOpArgs + 2;
      }
      if ( $ARGV[$optarg] eq "--crop-rotate" )
      {
        $cropRot     = $ARGV[ $optarg + 1 ];
        $numOfOpArgs = $numOfOpArgs + 2;
      }
      if ( $ARGV[$optarg] eq "--count" )
      {
        $numGoHigh   = $ARGV[ $optarg + 1 ];
        $numOfOpArgs = $numOfOpArgs + 2;
      }
      if ( $ARGV[$optarg] eq "--verbose" )
      {
        $verbose = "true";
        $numOfOpArgs++;
      }
      if ( $ARGV[$optarg] eq "--version" )
      {
        $versionarg = "true";
        $numOfOpArgs++;
      }
      if ( $ARGV[$optarg] eq "--overwrite" )
      {
        $overwrite = "true";
        $numOfOpArgs++;
      }
      if ( $ARGV[$optarg] eq "--singleuser" )
      {
        $singleuser = $ARGV[ $optarg + 1 ];
        $numOfOpArgs++;
      }
      if ( $ARGV[$optarg] eq "--username" )
      {
        @userName[0] = $ARGV[ $optarg + 1 ];
       $user        = 0;
        $numOfOpArgs = $numOfOpArgs + 2;
      }
      if ( $ARGV[$optarg] eq "--all-data" )
      {
        push( @bigData, split(" ", $ARGV[ $optarg + 1 ] ));
        $user        = 0;
#        $outtype = "WORDLIST";
        $alldat      = "true";
        $numOfOpArgs = $numOfOpArgs + 2;
      }
    }
    if ( $versionarg eq "true" )
    {
      print STDERR "MAPDAV $version\n";
      exit;
    }
    if ( $verbose eq "true" )
    {
      print STDERR "MAPDAV $version\n";
    }
if ($isAllCombo eq "true") 
{
  allCombos();
}

if ( $overwrite eq "true" ) 
{ unlink($wfn) 
}
if ( -e $wfn )
{
  die "File $wfn already present.  Not overwriting, use --overwrite to override.\n";
}
if ( $passwd ne "" )
    {
      openPasswordFile();
    }
if ($#fullname > -1) {
  namesPutTogether();
  damnDatNameThing();
  }

    elsif ( $nfile ne "" )
    {
      openNamesFile();
      namesPutTogether();
      damnDatNameThing();
    }

elsif ($alldat eq "true") {
  allData();
  namesPutTogether();
  damnDatNameThing();
}
else { versionStuff();}
  }
}


sub openPasswordFile
{
  #open passwd file
  open( $passwdfileh, $passwd ) || die "Couldn't open $passwd, $!";
  my @passwdfile = <$passwdfileh>;
  close($passwdfileh);
  if ( $singleuser ne "notsingleusermode" )
  {
    for my $passwdusers ( 0 .. $#passwdfile )
    {
      my @allusers = split( /:/, $passwdfile[$passwdusers] );
      if ( $allusers[0] eq $singleuser )
      {
        @passwdfile = $passwdfile[$passwdusers];
        last;
      }
    }
  }
  
  # Get the name and username portions of the passwd file that have valid shells
  for my $line ( 0 .. $#passwdfile )
  {
    if ( ( $passwdfile[$line] =~ m/bin\/bash$/ ) || ( $passwdfile[$line] =~ m/bin\/ksh$/ ) || ( $passwdfile[$line] =~ m/bin\/csh$/ ) || ( $passwdfile[$line] =~ m/bin\/sh$/ ) || ( $passwdfile[$line] =~ m/bin\/tcsh$/ ) )
    {
      my @splitline = split( /:/, $passwdfile[$line] );
      if ( $splitline[4] ne "" )
      {
        push( @fullname, $splitline[4] );
        push( @userName, $splitline[0] );
      }
      if ( $splitline[4] eq "" )
      {
        print "Sorry, MAPDAV cannot use this file because there is nothing in the GECOS feild.\n";
        exit;
      }
    }
  }
}

sub openNamesFile
{
  #open names file
  open( $namesfileh, $nfile ) || die "Couldn't open $nfile, $!";
  my @namesfile = <$namesfileh>;
  close($namesfileh);
  for my $line ( 0 .. $#namesfile )
  {
    chomp($namesfile[$line]);
    push( @fullname, $namesfile[$line] );
    push( @userName, " " );
  }
}


sub allData
{
  if ($#bigData >= 8) 
  {
    $howMuchDataToLoop = 8;
  }
  else 
  {
    $howMuchDataToLoop = $#bigData;
  }
  for $howManyPossible (1..$howMuchDataToLoop) 
  {
    my $iter = variations(\@bigData, $howManyPossible);
    while (my $it = $iter->next) 
    {
      push (@namestuff, "@$it");
    }
    for $perm (0..$#namestuff) 
    {
      $namestuff[$perm] =~ s/ //g;
      $theirName = "$namestuff[$perm]\n";
      $combo = $theirName;
      writeFile();
      $combo = ucfirst($theirName);
      writeFile();
      $combo = uc($theirName);
      writeFile();
      $combo = substr( $theirName, 0, 1);
      writeFile();
      $combo = substr( uc($theirName), 0, 1 );
      writeFile();
      $combo = reverse($theirName);
      writeFile();
      $combo = ucfirst($theirName);
      writeFile();
      $combo = uc($theirName);
      writeFile();
    }
  }
}

sub namesPutTogether
{
#print "Extrapolating @fullname\n";
# Make some formatting corrections
  for my $correct ( 0 .. $#fullname  )
  {
    $fullname[$correct] =~ s/\W/ /g;
    $fullname[$correct] =~ s/\s{2,}/ /g;
    $fullname[$correct] = lc( $fullname[$correct] );
  }
  # Get names
  for $name ( 0 .. $#fullname )
  {
    # Get first name
    if ( $fullname[$name] =~ m/(\w+) / )
    {
      push( @firstnamepad,    $1 );
      push( @Firstnamepad,    ucfirst($1) );
      push( @FIRSTNAMEpad,    uc($1) );
      push( @firstinitpad,    substr( $1, 0, 1 ) );
      push( @Firstinitpad,    substr( uc($1), 0, 1 ) );
      push( @firstnamerevpad, reverse($1) );
      push( @Firstnamerevpad, reverse( ucfirst($1) ) );
      push( @FIRSTNAMErevpad, reverse( uc($1) ) );
    }
    else
    {
      push( @firstnamepad,    "" );
      push( @Firstnamepad,    "" );
      push( @FIRSTNAMEpad,    "" );
      push( @firstinitpad,    "" );
      push( @Firstinitpad,    "" );
      push( @firstnamerevpad, "" );
      push( @Firstnamerevpad, "" );
      push( @FIRSTNAMErevpad, "" );
    }
    
    # Get middle name
    if ( $fullname[$name] =~ m/^\w+ (\w+) \w+/ )
    {
      push( @middlenamepad,    $1 );
      push( @Middlenamepad,    ucfirst($1) );
      push( @MIDDLENAMEpad,    uc($1) );
      push( @middleinitpad,    substr( $1, 0, 1 ) );
      push( @Middleinitpad,    substr( uc($1), 0, 1 ) );
      push( @middlenamerevpad, reverse($1) );
      push( @Middlenamerevpad, reverse( ucfirst($1) ) );
      push( @MIDDLENAMErevpad, reverse( uc($1) ) );
    }
    else
    {
      push( @middlenamepad,    "" );
      push( @Middlenamepad,    "" );
      push( @MIDDLENAMEpad,    "" );
      push( @middleinitpad,    "" );
      push( @Middleinitpad,    "" );
      push( @middlenamerevpad, "" );
      push( @Middlenamerevpad, "" );
      push( @MIDDLENAMErevpad, "" );
    }
    
    # Get last name
    if ( $fullname[$name] =~ m/ (\w+)$/ )
    {
      push( @lastnamepad,    $1 );
      push( @Lastnamepad,    ucfirst($1) );
      push( @LASTNAMEpad,    uc($1) );
      push( @lastinitpad,    substr( $1, 0, 1 ) );
      push( @Lastinitpad,    substr( uc($1), 0, 1 ) );
      push( @lastnamerevpad, reverse($1) );
      push( @Lastnamerevpad, reverse( ucfirst($1) ) );
      push( @LASTNAMErevpad, reverse( uc($1) ) );
    }
    else
    {
      push( @lastnamepad,    "" );
      push( @Lastnamepad,    "" );
      push( @LASTNAMEpad,    "" );
      push( @lastinitpad,    "" );
      push( @Lastinitpad,    "" );
      push( @lastnamerevpad, "" );
      push( @Lastnamerevpad, "" );
      push( @LASTNAMErevpad, "" );
    }
  }
  }

sub damnDatNameThing
{
#print "name thing\n";
# Put together the name combinations
  for $args ( 1 .. $#ARGV )
  {
    if ( $ARGV[ $args ] =~ m/:/g )
    {
      @curarg = split( /:/, $ARGV[ $args ] );
      $combo = "";
      for $user ( 0 .. $#fullname )
      {
        for $curargs ( 0 .. $#curarg )
        {
          if ( $curarg[$curargs] eq "fn" )
          {
            $combo = "$combo$firstnamepad[$user]";
          }
          if ( $curarg[$curargs] eq "Fn" )
          {
            $combo = "$combo$Firstnamepad[$user]";
          }
          if ( $curarg[$curargs] eq "FN" )
          {
            $combo = "$combo$FIRSTNAMEpad[$user]";

          }
          if ( $curarg[$curargs] eq "[rev]fn" )
          {
            $combo = "$combo$firstnamerevpad[$user]";
          }
          if ( $curarg[$curargs] eq "[rev]Fn" )
          {
            $combo = "$combo$Firstnamerevpad[$user]";
          }
          if ( $curarg[$curargs] eq "[rev]FN" )
          {
            $combo = "$combo$FIRSTNAMErevpad[$user]";
          }
          if ( $curarg[$curargs] eq "fi" )
          {
            $combo = "$combo$firstinitpad[$user]";
          }
          if ( $curarg[$curargs] eq "Fi" )
          {
            $combo = "$combo$Firstinitpad[$user]";
          }
          if ( $curarg[$curargs] eq "mn" )
          {
            $combo = "$combo$middlenamepad[$user]";
          }
          if ( $curarg[$curargs] eq "Mn" )
          {
            $combo = "$combo$Middlenamepad[$user]";
          }
          if ( $curarg[$curargs] eq "MN" )
          {
            $combo = "$combo$MIDDLENAMEpad[$user]";
          }
          if ( $curarg[$curargs] eq "[rev]mn" )
          {
            $combo = "$combo$middlenamerevpad[$user]";
          }
          if ( $curarg[$curargs] eq "[rev]Mn" )
          {
            $combo = "$combo$Middlenamerevpad[$user]";
          }
          if ( $curarg[$curargs] eq "[rev]MN" )
          {
            $combo = "$combo$MIDDLENAMErevpad[$user]";
          }
          if ( $curarg[$curargs] eq "mi" )
          {
            $combo = "$combo$middleinitpad[$user]";
          }
          if ( $curarg[$curargs] eq "Mi" )
          {
            $combo = "$combo$Middleinitpad[$user]";
          }
          if ( $curarg[$curargs] eq "ln" )
          {
            $combo = "$combo$lastnamepad[$user]";
          }
          if ( $curarg[$curargs] eq "Ln" )
          {
            $combo = "$combo$Lastnamepad[$user]";
          }
          if ( $curarg[$curargs] eq "LN" )
          {
            $combo = "$combo$LASTNAMEpad[$user]";
          }
          if ( $curarg[$curargs] eq "[rev]ln" )
          {
            $combo = "$combo$lastnamerevpad[$user]";
          }
          if ( $curarg[$curargs] eq "[rev]Ln" )
          {
            $combo = "$combo$Lastnamerevpad[$user]";
          }
          if ( $curarg[$curargs] eq "[rev]LN" )
          {
            $combo = "$combo$LASTNAMErevpad[$user]";
          }
          if ( $curarg[$curargs] eq "li" )
          {
            $combo = "$combo$lastinitpad[$user]";
          }
          if ( $curarg[$curargs] eq "Li" )
          {
            $combo = "$combo$Lastinitpad[$user]";
          }
          unless ($user ne "") {
            if ( $curarg[$curargs] eq "UN" )
            {
              $userUC = uc( $userName[$user] );
              $combo  = "$combo$userUC";
            }
            if ( $curarg[$curargs] eq "Un" )
            {
              $userUc = ucfirst( $userName[$user] );
              $combo  = "$combo$userUc";
            }
            if ( $curarg[$curargs] eq "un" )
            {
              $userlc = lc( $userName[$user] );
              $combo  = "$combo$userlc";
            }
            if ( $curarg[$curargs] eq "[rev]UN" )
            {
              $userUC = reverse( uc( $userName[$user] ) );
              $combo  = "$combo$userUC";
            }
            if ( $curarg[$curargs] eq "[rev]Un" )
            {
              $userUc = reverse( ucfirst( $userName[$user] ) );
              $combo  = "$combo$userUc";
            }
            if ( $curarg[$curargs] eq "[rev]un" )
            {
              $userlc = reverse( lc( $userName[$user] ) );
              $combo  = "$combo$userlc";
            }
          }
          $combo = "$combo$amid";
          if ( $combo =~ m/$amid$/ )
          {
            chomp($combo);
          }
        }
        $combo = "$apre$combo$apost";
        if ( $combo =~ m/$amid$apost$/ )
        {
          $combo =~ s/$amid$apost$/$apost/g;
        }
	#        if ( $crop > 0 )
	#{
	#  $combo = substr( $combo, 0, $crop );
	#}
        unless ( ( $combo eq "" ) || ( $userName[$user] eq ""  ) )
        {
        writeFile();
        }
        $combo = "";
      }
    }
  }
}

sub writeFile
{
  open( WLL, ">>$wfn_tmp" ) or die "Couldn't open file $wfn_tmp, $!";
  if ( $outtype eq "WORDLIST")
  {
    print WLL "$combo\n";
    if ($verbose eq "true") {
	unless ( $combo =~ m/^\w+/ ) {
        if ( $crop > 0 )
	        {
                 $combo = substr( $combo, 0, $crop );
                }
	  print "$combo";
       }
    }
    close(WLL);
    $rfn = $wfn_tmp;
    writeFileUniq();
  }
  if ( $outtype eq "HYDRA" )
  {
    print WLL "$userName[$user]:$combo\n";
    if ($verbose eq "true") {
      print "$userName[$user]:$combo\n"
    }
    close(WLL);
    $rfn = $wfn_tmp;
    writeFileUniq();
  }
}


sub writeFileUniq
{
  open( RWL, "<$rfn" )     or die "Couldn't open file  $rfn for reading, $!";
  open( WL, ">>$wfn" ) or die "Couldn't open file $wfn for writing, $!";
  # %lines;
  while (<RWL>)
  {
    if ($nowrite eq "false")
    {
      print WL if not $lines{$_}++;
    }
    if ($nowrite ne "false")
    {
      print if not $lines{$_}++;
    }
  }
  close (WL);
  close (RWL);
  unlink($rfn);
}
