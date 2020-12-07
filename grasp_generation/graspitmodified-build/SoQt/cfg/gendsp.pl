#! /usr/bin/perl
############################################################################
# SIM's Autopain Microsoft Visual Studio Project Generation, v2.0
#
#   This is a perl rewrite (sorry python-guys) of my original Bourne Shell
# implementation to get more speed, and also to be able to restructure the
# system to generate project files for all the targeted versions of
# Microsoft Visual Studio at the same time, to save even more time.  Even
# more speed will be saved if this could be performed on a Unix server,
# since those are generally faster running make.
#   Sorry about the 'old-school' perl - I know I should update myself on
# perl modules and such, but perl is not a language I really invest that
# much in, it just is the language that is most available to me when I need
# to do the occasional hack in something faster and better than
# Bourne Shell.
#   /Lars J
#
# Authors:
#
#   Lars J. Aas <larsa@sim.no>
#
# History:
#
# 2006-12-26 1st perl rewrite (with additions) completed. (larsa)
# 2005-01-05 Initial Bourne Shell version. (larsa)
#
# Plans:
#
# - output msvc7 and msvc8 files directly, don't use the upgrade feature
# - fork off the first instance to serve as a server that collects all
#   necessary data through some IPC and then dumps the project files when
#   everything is gathered...
# - put most msvc8-settings into property pages
# - add support for precompiled headers
#

require "pwd.pl";

$date = `date`;
$cwd = $ENV{'PWD'};

$me = $0;
$cwd = $ENV{'PWD'};
if ( $me =~ m%^[^/\\]% ) {
  $me = $cwd . "/" . $me;
  $me =~ s%/./%/%g;
}

# Environment variables to back-substitute from value to variable reference
# in the project files to make the project moveable
@reversevars = ("QTDIR", "COINDIR");

# List of files that should be entered into the "Documents" project file
# group if they exist.
@docfiles = ("README", "README.WIN32", "NEWS", "RELNOTES", "LICENSE.GPL",
             "COPYING", "THANKS", "ChangeLog");

############################################################################

$prefix = "/home/liujian/WorkSpace/EBM_Hand/grasp_generation/graspitmodified-build/SoQt/../coin/install-custom";
$build_dir = "/home/liujian/WorkSpace/EBM_Hand/grasp_generation/graspitmodified-build/SoQt";
while ( $build_dir =~ m%[\\/][^\\/]*[^\\/.][\\/]\.\.% ) {
  $build_dir =~ s%[\\/][^\\/]*[^\\/\.][\\/]\.\.%%g;
}
$build_dir =~ s%[\\/]\.$%%g;
$src_dir = "/home/liujian/WorkSpace/EBM_Hand/grasp_generation/graspitmodified-build/SoQt/../../graspitmodified_lm/SoQt-1.5.0";
while ( $src_dir =~ m%[\\/][^\\/]*[^\\/.][\\/]\.\.% ) {
  $src_dir =~ s%[\\/][^\\/]*[^\\/\.][\\/]\.\.%%g;
}
$src_dir =~ s%[\\/]\.$%%;
$ac_unique_file = "src/Inventor/Qt/SoQt.cpp";
$sim_ac_relative_src_dir = "../../graspitmodified_lm/SoQt-1.5.0";
$sim_ac_relative_src_dir_p = true; # true or false
if ($sim_ac_relative_src_dir_p) {
  $sim_ac_relative_src_dir_win = Unix2Dos($sim_ac_relative_src_dir);
}
$src_dir_win = Cygpath2Win($src_dir);
$build_dir_win = Cygpath2Win($build_dir);

$src_dir_win =~ s/\\/\\\\/g;
$build_dir_win =~ s/\\/\\\\/g;
# print "SOURCE DIR:     ${src_dir}\n";
# print "SOURCE DIR WIN: ${src_dir_win}\n";
# print "BUILD DIR WIN:  ${build_dir_win}\n";

$me_u = Dos2Unix($me);
$medir_u = $me;
$medir_u =~ s,[^/]*$,,g;
$srcdir_u = $medir_u;
$srcdir_u =~ s,[^/]*/$,,g;
$thisdir_u = Dos2Unix($cwd);

if ( $sim_ac_relative_src_dir_p ) {
  local $filename = "${srcdir_u}/${sim_ac_relative_src_dir}/${ac_unique_file}";
  $filename = Dos2Unix($filename);
  if ( ! -f $filename ) {
    die "error: directories have been moved relative to each other since the last configure run. expected to find '$filename'.";
  }
} else {
  die "error: dsp generation is not supported when absolute paths are necessary to locate files.";
}

############################################################################

$group = "";
$prev_group = "";

sub LoadVars {
  local $filename = "/home/liujian/WorkSpace/EBM_Hand/grasp_generation/graspitmodified-build/SoQt/gendsp-vars.txt";
  open(IN, "${filename}");
  while (<IN>) {
    $line = $_;
    chop($line);
    if ( $line =~ m%^group = (.*)% ) {
      $prev_group = $1;
    }
  }
  close(IN);
}

sub SaveVars {
  local $filename = "/home/liujian/WorkSpace/EBM_Hand/grasp_generation/graspitmodified-build/SoQt/gendsp-vars.txt";
  open(OUT, ">${filename}");
  print OUT "group = ${group}\n";
  close(OUT);
}

sub ClearVars {
  $prev_group = "";
  $group = "";
  SaveVars();
  LoadVars();
}

sub Dos2Unix {
  local $path = $_[0];
  $path =~ s,\\,/,g;
  return $path;
}

sub Unix2Dos {
  local $path = $_[0];
  $path =~ s,/,\\,g;
  return $path;
}

sub Cygpath2Win {
  local $path = $_[0];
  $path =~ s,^/cygdrive/([a-zA-Z])/,$1:/,;
  $path =~ s,/,\\,g;
  return $path;
}

sub Cygpath2Unix {
  local $path = $_[0];
  $path =~ s,^([a-zA-Z]):,/cygdrive/$1/,;
  $path =~ s,\\,/,g;
  return $path;
}

sub Dirname {
  local $path = $_[0];
  $path =~ s,[\\/][^\\/]*$,,g;
  return $path;
}

sub Filename {
  local $path = $_[0];
  $path =~ s,^.*[\\/]([^\\/]*)$,$1,g;
  return $path;
}

sub Basename {
  local $path = $_[0];
  local $extension = $_[1];
  $path =~ s,^.*[\\/]([^\\/]*)$,$1,g;
  $path =~ s,${extension}$,,g;
  return $path;
}

sub SubstFile {
  local $filename = $_[0];
  local @vars, @vals, %dict, $num = 0;
  open(MAKE, "Makefile");
  local $starting = true;
  while (<MAKE>) {
    $line = $_;
    if ($starting) {
      if ( $line =~ m/^$/ || $line =~ m/^\#/ ) { next; }
      $starting = false;
    }
    if ( $line =~ m/^SUBDIRS/ ) { # exit variable reading when we get to the SUBDIRS directive
      break;
    } elsif ( $line =~ m/^([a-zA-Z0-9_]+) = ?(.*)?/ ) {
      $vars[$num] = $1;
      $vals[$num] = $2;
      $dict{$1} = $2;
      ++$num;
    }
  }
  close(MAKE);
  local %envvars = ();
  for $var (@reversevars) {
    $envvars{$var} = $ENV{$var};
    $envvars{$var} =~ s%\\%\\\\%g;
    $envvars{$var} =~ s%\.%\\.%g;
  }
  # variables are loaded
  local $backup = $filename . ".bak";
  rename($filename, $backup);
  open(OUT, ">$filename");
  open(IN, "$backup");
  while(<IN>) {
    $line = $_;
    if ($line =~ m/@([^@]*)@/) {
      if (defined($dict{$1})) {
        # does the (g)lobal tag enable multi-substs-per-line?
        # does @ occur naturally in Visual Studio project files?
        $line =~ s/@([^@]*)@/$dict{$1}/g;
      }
    }

    if ($line =~ m%${build_dir_win}\\%o) {
      $line =~ s%${build_dir_win}\\%%g;
    }
    if ($line =~ m%${build_dir_win}%o) {
      $line =~ s%${build_dir_win}%.%g;
    }
    if ($line =~ m%${src_dir_win}[\\]?%o) {
      $line =~ s%${src_dir_win}([\\]?)%${sim_ac_relative_src_dir_win}$1%g;
    }

    for $var (@reversevars) {
      if ($line =~ m%$envvars{$var}%) {
        $line =~ s%$envvars{$var}%\$(${var})%g;
      }
    }

    print OUT $line;
  }
  close(IN);
  close(OUT);
}

sub SubstBatFile {
  local $filename = $_[0];
  local %envvars = ();
  for $var (@reversevars) {
    $envvars{$var} = $ENV{$var};
    $envvars{$var} =~ s%\\%\\\\%g;
    $envvars{$var} =~ s%\.%\\.%g;
  }
  # variables are loaded
  local $backup = $filename . ".bak";
  rename($filename, $backup);
  open(OUT, ">$filename");
  open(IN, "$backup");
  while(<IN>) {
    $line = $_;
    for $var (@reversevars) {
      if ( $line =~ m%$envvars{$var}% ) {
        $line =~ s,$envvars{$var},%${var}%,g;
      }
    }
    print OUT $line;
  }
  close(IN);
  close(OUT);
}

sub CRLFFile {
  local $path = $_[0];
  local $backup = $path . ".old";
  rename($path, $backup);
  open(IN, $backup);
  open(OUT, ">$path");
  while(<IN>) {
    $line = $_;
    chop($line);
    print OUT "${line}\r\n";
  }
  close(IN);
  close(OUT);
  return true;
}

sub CreateScriptDSP {
  local ($scriptdspfilename, $projectname, $script, @resourcefiles) = @_;
  
  open(SCRIPTDSP, ">${scriptdspfilename}");
  print SCRIPTDSP <<"_EODSP";
# Microsoft Developer Studio Project File - Name="${projectname}" - Package Owner=<4>
# Microsoft Developer Studio Generated Build File, Format Version 6.00
# ** DO NOT EDIT **

# TARGTYPE "Win32 (x86) External Target" 0x0106

CFG=${projectname} - Win32 DLL (Debug)
!MESSAGE This is not a valid makefile. To build this project using NMAKE,
!MESSAGE use the Export Makefile command and run
!MESSAGE 
!MESSAGE NMAKE /f "${projectname}.mak".
!MESSAGE 
!MESSAGE You can specify a configuration when running NMAKE
!MESSAGE by defining the macro CFG on the command line. For example:
!MESSAGE 
!MESSAGE NMAKE /f "${projectname}.mak" CFG="${projectname} - Win32 DLL (Debug)"
!MESSAGE 
!MESSAGE Possible choices for configuration are:
!MESSAGE 
!MESSAGE "${projectname} - Win32 LIB (Release)" (based on "Win32 (x86) External Target")
!MESSAGE "${projectname} - Win32 LIB (Debug)" (based on "Win32 (x86) External Target")
!MESSAGE "${projectname} - Win32 DLL (Release)" (based on "Win32 (x86) External Target")
!MESSAGE "${projectname} - Win32 DLL (Debug)" (based on "Win32 (x86) External Target")
!MESSAGE 

# Begin Project
# PROP AllowPerConfigDependencies 0
# PROP Scc_ProjName ""
# PROP Scc_LocalPath ""

!IF  "\$(CFG)" == "${projectname} - Win32 LIB (Release)"

# PROP BASE Use_MFC
# PROP BASE Use_Debug_Libraries 0
# PROP BASE Output_Dir "StaticRelease"
# PROP BASE Intermediate_Dir "StaticRelease"
# PROP BASE Cmd_Line "${script} lib release ${msvc} ${library}\@${LIBRARY}_MAJOR_VERSION\@"
# PROP BASE Rebuild_Opt ""
# PROP BASE Target_File ""
# PROP BASE Bsc_Name ""
# PROP BASE Target_Dir ""
# PROP Use_MFC
# PROP Use_Debug_Libraries 0
# PROP Output_Dir "StaticRelease"
# PROP Intermediate_Dir "StaticRelease"
# PROP Cmd_Line "${script} lib release ${msvc} ${library}\@${LIBRARY}_MAJOR_VERSION\@"
# PROP Rebuild_Opt ""
# PROP Target_File ""
# PROP Bsc_Name ""
# PROP Target_Dir ""

!ELSEIF  "\$(CFG)" == "${projectname} - Win32 LIB (Debug)"

# PROP BASE Use_MFC
# PROP BASE Use_Debug_Libraries 1
# PROP BASE Output_Dir "StaticDebug"
# PROP BASE Intermediate_Dir "StaticDebug"
# PROP BASE Cmd_Line "${script} lib debug ${msvc} ${library}\@${LIBRARY}_MAJOR_VERSION\@"
# PROP BASE Rebuild_Opt ""
# PROP BASE Target_File ""
# PROP BASE Bsc_Name ""
# PROP BASE Target_Dir ""
# PROP Use_MFC
# PROP Use_Debug_Libraries 1
# PROP Output_Dir "StaticDebug"
# PROP Intermediate_Dir "StaticDebug"
# PROP Cmd_Line "${script} lib debug ${msvc} ${library}\@${LIBRARY}_MAJOR_VERSION\@"
# PROP Rebuild_Opt ""
# PROP Target_File ""
# PROP Bsc_Name ""
# PROP Target_Dir ""

!ELSEIF  "\$(CFG)" == "${projectname} - Win32 DLL (Release)"

# PROP BASE Use_MFC
# PROP BASE Use_Debug_Libraries 0
# PROP BASE Output_Dir "Release"
# PROP BASE Intermediate_Dir "Release"
# PROP BASE Cmd_Line "${script} dll release ${msvc} ${library}\@${LIBRARY}_MAJOR_VERSION\@"
# PROP BASE Rebuild_Opt ""
# PROP BASE Target_File ""
# PROP BASE Bsc_Name ""
# PROP BASE Target_Dir ""
# PROP Use_MFC
# PROP Use_Debug_Libraries 0
# PROP Output_Dir "Release"
# PROP Intermediate_Dir "Release"
# PROP Cmd_Line "${script} dll release ${msvc} ${library}\@${LIBRARY}_MAJOR_VERSION\@"
# PROP Rebuild_Opt ""
# PROP Target_File ""
# PROP Bsc_Name ""
# PROP Target_Dir ""

!ELSEIF  "\$(CFG)" == "${projectname} - Win32 DLL (Debug)"

# PROP BASE Use_MFC
# PROP BASE Use_Debug_Libraries 1
# PROP BASE Output_Dir "Debug"
# PROP BASE Intermediate_Dir "Debug"
# PROP BASE Cmd_Line "${script} dll debug ${msvc} ${library}\@${LIBRARY}_MAJOR_VERSION\@"
# PROP BASE Rebuild_Opt ""
# PROP BASE Target_File ""
# PROP BASE Bsc_Name ""
# PROP BASE Target_Dir ""
# PROP Use_MFC
# PROP Use_Debug_Libraries 1
# PROP Output_Dir "Debug"
# PROP Intermediate_Dir "Debug"
# PROP Cmd_Line "${script} dll debug ${msvc} ${library}\@${LIBRARY}_MAJOR_VERSION\@"
# PROP Rebuild_Opt ""
# PROP Target_File ""
# PROP Bsc_Name ""
# PROP Target_Dir ""

!ENDIF

# Begin Target

# Name "${projectname} - Win32 LIB (Release)"
# Name "${projectname} - Win32 LIB (Debug)"
# Name "${projectname} - Win32 DLL (Release)"
# Name "${projectname} - Win32 DLL (Debug)"

!IF  "\$(CFG)" == "${projectname} - Win32 LIB (Release)"

!ELSEIF  "\$(CFG)" == "${projectname} - Win32 LIB (Debug)"

!ELSEIF  "\$(CFG)" == "${projectname} - Win32 DLL (Release)"

!ELSEIF  "\$(CFG)" == "${projectname} - Win32 DLL (Debug)"

!ENDIF

# Begin Group "Resource Files"

# PROP Default_Filter "ico;cur;bmp;dlg;rc2;rct;bin;rgs;gif;jpg;jpeg;jpe;bat"
_EODSP

  for $file (@resourcefiles) {
    print SCRIPTDSP "# Begin Source File\n\n";
    print SCRIPTDSP "SOURCE=${file}\n";
    print SCRIPTDSP "# End Source File\n";
  }

  print SCRIPTDSP <<"_EODSP";
# End Group
# End Target
# End Project
_EODSP
  close(SCRIPTDSP);
}

############################################################################

LoadVars();

# **************************************************************************
# The following block (the --registar-public-header part) generates
# 1) the public headers part of the .dsp file
# 2) the install-headers.bat file
# It is invoked from a "make ... install-data"-command far down in this script

if ( $ARGV[0] eq "--register-public-header" ) {
  $studiofile = $ARGV[1];
  $headerfile = $ARGV[2];
  $installpath = $ARGV[3];
  $finalheader = $installpath;
  $finalheader =~ s,.*${prefix}/(include|data),$ENV{'COINDIR'}/$1,;
  $finalheader =~ s,/\./,/,g;
  $finalheader = &Unix2Dos($finalheader);

  $sim_ac_relative_src_dir_q = "../../graspitmodified_lm/SoQt-1.5.0";
  $sim_ac_relative_src_dir_q =~ s,\.,\\.,g;

  $tested = true;

  if ( $headerfile =~ m,.*${sim_ac_relative_src_dir}/.*, ) {
    $headerfile =~
      s%.*${sim_ac_relative_src_dir_q}/([^.])%${sim_ac_relative_src_dir}/$1%;
  } elsif ( $headerfile =~ m,^${build_dir}/.*, ) {
    $tested = false;
    print "EXPLICIT IN BUILD DIR";
    $headerfile =~ s%${build_dir}/%%;
  } elsif ( $headerfile =~ m/^${src_dir}.*/ ) {
    $tested = false;
    print "EXPLICIT IN SOURCE DIR - CONVERT TO RELATIVE";
    $headerfile =~ s%${src_dir}%${sim_ac_relative_src_dir}%;
  } else {
    $headerfile = $cwd . "/" . $headerfile;
    $headerfile =~ s%${build_dir}/%%;
  }

  # echo "final header: $headerfile"
  # echo "FINAL header: $finalheader"
  # echo "========================="

  $headerfile = Cygpath2Win($headerfile);

  $headerfile =~ s%^${build_dir}[\\/]?%.\\%;
  $headerfile =~ s%^${build_dir_win}[\\/]?%.\\%;
  if ($sim_ac_relative_src_dir_p) {
    $headerfile =~ s%^${src_dir}[\\/]?%${sim_ac_relative_src_dir_win}\\%;
    $headerfile =~ s%^${src_dir_win}[\\/]?%${sim_ac_relative_src_dir_win}\\%;
  }

  if ( ! $tested ) {
    die "untested case - manual inspection required";
  }

  open(DSP, ">>${studiofile}");
  $group = Dirname($headerfile);
  $group =~ s%.*lib[\\/]?%%g;
  $group =~ s%.*src[\\/]?%%g;
  $group =~ s%.*include[\\/]?%%g;
  $group =~ s%^Inventor[\\/]annex[\\/]%%g;

  SaveVars();
  if ($prev_group ne $group) {
    if ($prev_group ne "") {
      print DSP "# End Group\n";
    }
    if ($group ne "") {
      print DSP "# Begin Group \"${group} headers\"\n";
      print DSP "# Set Default_Filter \"h\"\n";
    }
  }

  print DSP "# Begin Source File\n";
  print DSP "\n";
  print DSP "SOURCE=${headerfile}\n";
  print DSP "# End Source File\n";
  close(DSP);

  # and the installation script
  $installheadersfile = $studiofile;
  $installheadersfile =~ s,([^\\/0-9]*)[0-9][^\\/]*\.dsp,install-headers.bat,;
 
  $installheadersfile =~ m,(msvc[6789]),;
  $msvc = $1;

  # don't generate inside misc/ to be able to generate concurrently in several
  # msvc*/-directories...
  # $installheadersfile =~ s,msvc[6789]/,misc/,;

  # sourcedirq=`echo "$sourcedir" | sed -e 's,\\\\,\\\\,g'`
  # builddirq=`echo "$builddir" | sed -e 's,\\\\,\\\\,g'`
  # relheader=`echo "$headerfile" | sed -e "s,$builddirq,.,g" -e "s,$sourcedirq,..\\\\..,g" -e 's,\\\\,\\\\\\\\,g'`
  # finalheader=`echo "$relheader" | sed -e 's,.*include,include,g'`
  # relheader=`echo "$relheader"`
  # finalheader=`echo "$finalheader"`

  $createheader = 0;
  if ( ! -e $installheadersfile ) {
    $createheader = 1;
  }
  if ( $headerfile !~ m/^${sim_ac_relative_src_dir_win}/ ) {
    $headerfile = "..\\%msvc%\\${headerfile}";
  }
  open(BAT, ">>${installheadersfile}");
  if ( $createheader ) {
    print BAT <<"_EOBAT";
rem ************************************************************************
rem * install-headers.bat - generated by gendsp.pl
rem *
set msvc=%1
_EOBAT
  }
  print BAT "copy /Y ${headerfile} ${finalheader} >nul:\n";
  close(BAT);

  $uninstallheadersfile = $installheadersfile;
  $uninstallheadersfile =~ s/install-hea/uninstall-hea/;

  open(BAT2, ">>${uninstallheadersfile}");
  if ( $createheader ) {
    print BAT2 <<"_EOBAT";
rem ************************************************************************
rem * uninstall-headers.bat - generated by gendsp.pl
rem *
set msvc=%1
_EOBAT
  }
  print BAT2 "del ${finalheader}\n";
  close(BAT2);

  exit 0;
}

# **************************************************************************

# this variable should contain the list of variables we want to use in the
# project file setup, instead of just having the values.

$sourcefile = "";
$objectfile = "";
$dependfile = "";
$studiofile = "";
$installstudiofile = "";
$uninstallstudiofile = "";
$docstudiofile = "";
$outputfile = "";

$LIBRARY = "";
$library = "";
$Library = "";

for $arg (@ARGV) {
  if ( $outputfile eq "next" ) {
    $outputfile = $arg;
  } else {
    if ( $arg eq "-c" ) {
      # -c only means _compile_ some file, not that the source file is
      # the next argument, hence we need to do it differently than for
      # the -o option
      $sourcefile = "get";
    } elsif ( $arg eq "-o" ) {
      $outputfile = "next";
    } elsif ( $arg eq "-MF" || $arg eq "-MD" || $arg eq "-MP" ) {
      # haven't investigated if one of these are defined to be last
      # before the dep-file, so i've done it this way.
      $dependfile = "get";
    } elsif ( $arg =~ m/^-Wp,-MD,.*/ ) {
      $dependfile = substr($arg, 9);
    } elsif ( $arg =~ m/^-D.*_INTERNAL/ ) {
      $LIBRARY = $arg;
      $LIBRARY =~ s/^-D//;
      $LIBRARY =~ s/_INTERNAL//;
      $library = $LIBRARY;
      $library =~ y/A-Z/a-z/;
      $Library = substr($LIBRARY, 0, 1) . substr($library, 1);
      if ( $Library =~ m/^So/o ) {
        $Library = substr($Library, 0, 2) . substr($LIBRARY, 3, 1) . substr($library, 4, -1);
      } elsif ( $Library =~ m/^Coin../o ) {
        $Library = substr($Library, 0, 4) . substr($LIBRARY, 5, 1) . substr($library, 6, -1);
      }
    } elsif ( $arg =~ m/^-Ddspfile=/ || $arg =~ m/^-Wl,-Ddspfile=/ ) {
      # the build system is hacked to pass us the path to the .dsp file
      # this way.
      $studiofile = $arg;
      $studiofile =~ s/^.*=//g;
      $installstudiofile = $studiofile;
      $uninstallstudiofile = $studiofile;
      $docstudiofile = $studiofile;
      $installstudiofile =~ s/.dsp/_install.dsp/;
      $uninstallstudiofile =~ s/.dsp/_uninstall.dsp/;
      $docstudiofile =~ s/.dsp/_docs.dsp/;
      # FIXME: we don't get the -D*_INTERNAL flag when closing, so we
      # have to set up the variables here too.
      $library = $studiofile;
      $library =~ s,.*[\\/],,g;
      $library =~ s,[0-9].*$,,;
      $LIBRARY = $library;
      $LIBRARY =~ y/a-z/A-Z/;
      $Library = substr($LIBRARY, 0, 1) . substr($library, 1);
      if ( $Library =~ m/^So/o ) {
        $Library = substr($Library, 0, 2) . substr($LIBRARY, 3, 1) . substr($library, 4);
      } elsif ( $Library =~ m/^Coin../o ) {
        $Library = substr($Library, 0, 4) . substr($LIBRARY, 5, 1) . substr($library, 6, -1);
      }
    } elsif ( $arg =~ m/^-/ ) {
      # nada - no other options for us
    } else {
      if ( $sourcefile eq "get" ) {
        $sourcefile = $arg;
      } elsif ( $dependfile eq "get" ) {
        $dependfile = $arg;
      }
    }
  }
}

if ( $studiofile eq "" ) {
  print STDERR "Error? No studiofile in command - exiting.\n";
  exit 0;
}

$vcproj7file = $studiofile;
$vcproj7file =~ s/msvc6/msvc7/;
$vcproj7file =~ s/\.dsp$/.vcproj/;
$vcproj8file = $studiofile;
$vcproj8file =~ s/msvc6/msvc8/;
$vcproj8file =~ s/\.dsp$/.vcproj/;
$vcproj9file = $studiofile;
$vcproj9file =~ s/msvc6/msvc9/;
$vcproj9file =~ s/\.dsp$/.vcproj/;

if ( $sourcefile ne "" ) {
  if ( $objectfile eq "" ) {
    $objectfile = $sourcefile;
    $objectfile =~ s%^.*[/\\\\]%%g;
    $objectfile =~ s%\.(cpp|c)$%.o%;
  }
}

if ( $objectfile ne "" ) {
  open(OBJ, ">${objectfile}");
  print OBJ $date;
  close(OBJ);
}

if ( $dependfile ne "" ) {
  open(DEP, ">${dependfile}");
  print DEP "\n";
  close(DEP);
}

if ( -f $studiofile ) {
  open(DSP, ">>${studiofile}");
} else {
  # files do not exist yet, open project
  ClearVars();

  $studiofile =~ m,(msvc[6789]),;
  $msvc = $1;

  @installrcfiles = (
    "..\\misc\\install-sdk.bat",
    "..\\misc\\install-headers.bat",
    "..\\misc\\create-directories.bat"
  );

  @uninstallrcfiles = (
    "..\\misc\\uninstall-sdk.bat",
    "..\\misc\\uninstall-headers.bat"
  );

  @docsrcfiles = (
    "..\\misc\\build-docs.bat",
    "docs\\${library}\@${LIBRARY}_MAJOR_VERSION\@.doxygen",
    "..\\html\\index.html"
  );

  &CreateScriptDSP($installstudiofile,
                   "${library}\@${LIBRARY}_MAJOR_VERSION\@_install",
                   "..\\misc\\install-sdk.bat",
                   @installrcfiles);

  &CreateScriptDSP($uninstallstudiofile,
                   "${library}\@${LIBRARY}_MAJOR_VERSION\@_uninstall",
                   "..\\misc\\uninstall-sdk.bat",
                   @uninstallrcfiles);

  &CreateScriptDSP($docstudiofile,
                   "${library}\@${LIBRARY}_MAJOR_VERSION\@_docs",
                   "..\\misc\\build-docs.bat",
                   @docsrcfiles);

  open(DSP, ">${studiofile}");
  print DSP <<"_EODSP";
# Microsoft Developer Studio Project File - Name="${library}\@${LIBRARY}_MAJOR_VERSION\@" - Package Owner=<4>
# Microsoft Developer Studio Generated Build File, Format Version 6.00
# ** DO NOT EDIT **

# TARGTYPE "Win32 (x86) Dynamic-Link Library" 0x0102

CFG=${library}\@${LIBRARY}_MAJOR_VERSION\@ - Win32 DLL (Release)
!MESSAGE This is not a valid makefile. To build this project using NMAKE,
!MESSAGE use the Export Makefile command and run
!MESSAGE
!MESSAGE NMAKE /f "${library}\@${LIBRARY}_MAJOR_VERSION\@.mak".
!MESSAGE
!MESSAGE You can specify a configuration when running NMAKE
!MESSAGE by defining the macro CFG on the command line. For example:
!MESSAGE
!MESSAGE NMAKE /f "${library}\@${LIBRARY}_MAJOR_VERSION\@.mak" CFG="${library}\@${LIBRARY}_MAJOR_VERSION\@ - Win32 DLL (Debug)"
!MESSAGE
!MESSAGE Possible choices for configuration are:
!MESSAGE
!MESSAGE "${library}\@${LIBRARY}_MAJOR_VERSION\@ - Win32 LIB (Release)" (based on "Win32 (x86) Static Library")
!MESSAGE "${library}\@${LIBRARY}_MAJOR_VERSION\@ - Win32 LIB (Debug)" (based on "Win32 (x86) Static Library")
!MESSAGE "${library}\@${LIBRARY}_MAJOR_VERSION\@ - Win32 DLL (Release)" (based on "Win32 (x86) Dynamic-Link Library")
!MESSAGE "${library}\@${LIBRARY}_MAJOR_VERSION\@ - Win32 DLL (Debug)" (based on "Win32 (x86) Dynamic-Link Library")
!MESSAGE

# Begin Project
# PROP AllowPerConfigDependencies 0
# PROP Scc_ProjName ""
# PROP Scc_LocalPath ""
CPP=cl.exe
MTL=midl.exe
RSC=rc.exe

!IF  "\$(CFG)" == "${library}\@${LIBRARY}_MAJOR_VERSION\@ - Win32 LIB (Release)"

# PROP BASE Use_MFC 0
# PROP BASE Use_Debug_Libraries 0
# PROP BASE Output_Dir "StaticRelease"
# PROP BASE Intermediate_Dir "StaticRelease"
# PROP BASE Target_Dir ""
# PROP Use_MFC 0
# PROP Use_Debug_Libraries 0
# PROP Output_Dir "StaticRelease"
# PROP Intermediate_Dir "StaticRelease"
# PROP Target_Dir ""
MTL=midl.exe
CPP=cl.exe
# ADD BASE CPP /nologo /MD /W3 /GX /Ox /Gy /Zi \@${LIBRARY}_DSP_INCS\@ /D "WIN32" /D "NDEBUG" /D "_WINDOWS" /D "_LIB" /D ${LIBRARY}_DEBUG=0 \@${LIBRARY}_LIB_DSP_DEFS\@ /FD /c
# ADD CPP /nologo /MD /W3 /GX /Ox /Gy /Zi \@${LIBRARY}_DSP_INCS\@ /D "WIN32" /D "NDEBUG" /D "_WINDOWS" /D "_LIB" /D ${LIBRARY}_DEBUG=0 \@${LIBRARY}_LIB_DSP_DEFS\@ /FD /c
RSC=rc.exe
# ADD BASE RSC /l 0x414 /d "NDEBUG"
# ADD RSC /l 0x414 /d "NDEBUG"
BSC32=bscmake.exe
# ADD BASE BSC32 /nologo
# ADD BSC32 /nologo
LIB32=link.exe -lib
# ADD BASE LIB32 /nologo /machine:I386 /out:"${library}\@${LIBRARY}_MAJOR_VERSION\@s.lib"
# ADD LIB32 /nologo /machine:I386 /out:"${library}\@${LIBRARY}_MAJOR_VERSION\@s.lib"

!ELSEIF  "\$(CFG)" == "${library}\@${LIBRARY}_MAJOR_VERSION\@ - Win32 LIB (Debug)"

# PROP BASE Use_MFC 0
# PROP BASE Use_Debug_Libraries 1
# PROP BASE Output_Dir "StaticDebug"
# PROP BASE Intermediate_Dir "StaticDebug"
# PROP BASE Target_Dir ""
# PROP Use_MFC 0
# PROP Use_Debug_Libraries 1
# PROP Output_Dir "StaticDebug"
# PROP Intermediate_Dir "StaticDebug"
# PROP Target_Dir ""
MTL=midl.exe
CPP=cl.exe
# ADD BASE CPP /nologo /MDd /W3 /GX /GZ /Od /Zi \@${LIBRARY}_DSP_INCS\@ /D "WIN32" /D "_DEBUG" /D "_WINDOWS" /D "_LIB" /D ${LIBRARY}_DEBUG=1 \@${LIBRARY}_LIB_DSP_DEFS\@ /FD /c
# ADD CPP /nologo /MDd /W3 /GX /GZ /Od /Zi \@${LIBRARY}_DSP_INCS\@ /D "WIN32" /D "_DEBUG" /D "_WINDOWS" /D "_LIB" /D ${LIBRARY}_DEBUG=1 \@${LIBRARY}_LIB_DSP_DEFS\@ /FD /c
RSC=rc.exe
# ADD BASE RSC /l 0x414 /d "_DEBUG"
# ADD RSC /l 0x414 /d "_DEBUG"
BSC32=bscmake.exe
# ADD BASE BSC32 /nologo
# ADD BSC32 /nologo
LIB32=link.exe -lib
# ADD BASE LIB32 /nologo /machine:I386 /out:"${library}\@${LIBRARY}_MAJOR_VERSION\@sd.lib"
# ADD LIB32 /nologo /machine:I386 /out:"${library}\@${LIBRARY}_MAJOR_VERSION\@sd.lib"

!ELSEIF  "\$(CFG)" == "${library}\@${LIBRARY}_MAJOR_VERSION\@ - Win32 DLL (Release)"

# PROP BASE Use_MFC 0
# PROP BASE Use_Debug_Libraries 0
# PROP BASE Output_Dir "Release"
# PROP BASE Intermediate_Dir "Release"
# PROP BASE Target_Dir ""
# PROP Use_MFC 0
# PROP Use_Debug_Libraries 0
# PROP Output_Dir "Release"
# PROP Intermediate_Dir "Release"
# PROP Ignore_Export_Lib 0
# PROP Target_Dir ""
CPP=cl.exe
# ADD BASE CPP /nologo /MD /W3 /GX /Ox /Gy /Zi \@${LIBRARY}_DSP_INCS\@ /D "WIN32" /D "NDEBUG" /D "_WINDOWS" /D ${LIBRARY}_DEBUG=0 \@${LIBRARY}_DSP_DEFS\@ /FD /c
# ADD CPP /nologo /MD /W3 /GX /Ox /Gy /Zi \@${LIBRARY}_DSP_INCS\@ /D "WIN32" /D "NDEBUG" /D "_WINDOWS" /D ${LIBRARY}_DEBUG=0 \@${LIBRARY}_DSP_DEFS\@ /FD /c
MTL=midl.exe
# ADD BASE MTL /nologo /D "NDEBUG" /mktyplib203 /win32
# ADD MTL /nologo /D "NDEBUG" /mktyplib203 /win32
RCS=rc.exe
# ADD BASE RSC /l 0x409 /d "NDEBUG"
# ADD RSC /l 0x409 /d "NDEBUG"
BSC32=bscmake.exe
# ADD BASE BSC32 /nologo
# ADD BSC32 /nologo
LINK32=link.exe
# ADD BASE LINK32 \@${LIBRARY}_DSP_LIBS\@ /nologo /dll /release /machine:I386 /pdbtype:sept
# ADD LINK32 \@${LIBRARY}_DSP_LIBS\@ /nologo /dll /release /machine:I386 /pdbtype:sept /out:"${library}\@${LIBRARY}_MAJOR_VERSION\@.dll" /opt:nowin98
# SUBTRACT LINK32 /pdb:none

!ELSEIF  "\$(CFG)" == "${library}\@${LIBRARY}_MAJOR_VERSION@ - Win32 DLL (Debug)"

# PROP BASE Use_MFC 0
# PROP BASE Use_Debug_Libraries 1
# PROP BASE Output_Dir "Debug"
# PROP BASE Intermediate_Dir "Debug"
# PROP BASE Target_Dir ""
# PROP Use_MFC 0
# PROP Use_Debug_Libraries 1
# PROP Output_Dir "Debug"
# PROP Intermediate_Dir "Debug"
# PROP Target_Dir ""
CPP=cl.exe
# ADD BASE CPP /nologo /MDd /W3 /Gm /GX /GZ /Zi /Od \@${LIBRARY}_DSP_INCS\@ /D "WIN32" /D "_DEBUG" /D "_WINDOWS" /D ${LIBRARY}_DEBUG=1 \@${LIBRARY}_DSP_DEFS\@ /FD /c
# ADD CPP /nologo /MDd /W3 /Gm /GX /GZ /Zi /Od \@${LIBRARY}_DSP_INCS\@ /D "WIN32" /D "_DEBUG" /D "_WINDOWS" /D ${LIBRARY}_DEBUG=1 \@${LIBRARY}_DSP_DEFS\@ /FD /c
MTL=midl.exe
# ADD BASE MTL /nologo /D "_DEBUG" /mktyplib203 /win32
# ADD MTL /nologo /D "_DEBUG" /mktyplib203 /win32
RCS=rc.exe
# ADD BASE RSC /l 0x409 /d "_DEBUG"
# ADD RSC /l 0x409 /d "_DEBUG"
BSC32=bscmake.exe
# ADD BASE BSC32 /nologo
# ADD BSC32 /nologo
LINK32=link.exe
# ADD BASE LINK32 \@${LIBRARY}_DSP_LIBS\@ /nologo /dll /debug /machine:I386 /pdbtype:sept
# ADD LINK32 \@${LIBRARY}_DSP_LIBS\@ /nologo /dll /debug /machine:I386 /pdbtype:sept /out:"${library}\@${LIBRARY}_MAJOR_VERSION\@d.dll" /opt:nowin98

!ENDIF

# Begin Target

# Name "${library}\@${LIBRARY}_MAJOR_VERSION\@ - Win32 DLL (Release)"
# Name "${library}\@${LIBRARY}_MAJOR_VERSION\@ - Win32 DLL (Debug)"
# Name "${library}\@${LIBRARY}_MAJOR_VERSION\@ - Win32 LIB (Release)"
# Name "${library}\@${LIBRARY}_MAJOR_VERSION\@ - Win32 LIB (Debug)"
# Begin Group "Documents"
# PROP Default_Filter ";txt"
_EODSP

      for $docfile (@docfiles) {
        if ( -f "${src_dir}/${docfile}" ) {
          print DSP <<"_EODSP";
# Begin Source File

SOURCE=${sim_ac_relative_src_dir_win}\\${docfile}
# End Source File
_EODSP
        }
      }
      print DSP <<"_EODSP";
# End Group
# Begin Group "Template Files"
# PROP Default_Filter "in"
_EODSP

      # FIXME: figure out which is the template files, and set up
      # csubst.exe-based build-rules for them...

      # print STDERR "\n\n\n\nATTENTION\n\n\n\n\n";

      open(FILES, "cd ${build_dir} && find src/Inventor " . '-name "*.h" -o -name "*.cpp" -o -name "*.c" | xargs grep "Generated from .* by configure" |');
      @lines = <FILES>;
      close(FILES);

      for $line (@lines) {
        $line =~ m/^([^:]*):.*Generated from (.*) by configure/;
        $file = &Unix2Dos($1);
        $template = $2;
        open(FILE, "cd ${src_dir} && find src/Inventor -name '${template}' |");
        $templatepath = <FILE>;
	chop($templatepath);
        $templatepath = &Unix2Dos("../../${templatepath}");
	close(FILE);
        # print STDERR "TEMPLATE '${template}' - $templatepath\n  :: TARGET '${file}'\n";
	print DSP <<"_EODSP";
# Begin Source File

SOURCE=${templatepath}

!IF  "\$(CFG)" == "${library}\@${LIBRARY}_MAJOR_VERSION\@ - Win32 DLL (Release)"

# PROP IgnoreDefaultTool 1
#Begin Custom Build - subst'ing \$(InputPath)
InputPath=${templatepath}

"${file}" : \$(SOURCE) "\$(INTDIR)" "\$(OUTDIR)"
	..\\..\\cfg\\csubst --file=${templatepath}:${file}

# End Custom Build

!ELSEIF  "\$(CFG)" == "${library}\@${LIBRARY}_MAJOR_VERSION\@ - Win32 DLL (Debug)"

# PROP IgnoreDefaultTool 1
#Begin Custom Build - subst'ing \$(InputPath)
InputPath=${headerfile}

"${file}" : \$(SOURCE) "\$(INTDIR)" "\$(OUTDIR)"
	..\\..\\cfg\\csubst --file=${templatepath}:${file}

# End Custom Build

!ELSEIF  "\$(CFG)" == "${library}\@${LIBRARY}_MAJOR_VERSION\@ - Win32 LIB (Release)"

# PROP IgnoreDefaultTool 1
#Begin Custom Build - subst'ing \$(InputPath)
InputPath=${headerfile}

"${file}" : \$(SOURCE) "\$(INTDIR)" "\$(OUTDIR)"
	..\\..\\cfg\\csubst --file=${templatepath}:${file}

# End Custom Build
  
!ELSEIF  "\$(CFG)" == "${library}\@${LIBRARY}_MAJOR_VERSION\@ - Win32 LIB (Debug)"

# PROP IgnoreDefaultTool 1
#Begin Custom Build - subst'ing \$(InputPath)
InputPath=${headerfile}

"${file}" : \$(SOURCE) "\$(INTDIR)" "\$(OUTDIR)"
	..\\..\\cfg\\csubst --file=${templatepath}:${file}

# End Custom Build

!ENDIF

# End Source File
_EODSP
      }

      print DSP <<"_EODSP";
# End Group
# Begin Group "Source Files"
# PROP Default_Filter "c;cpp;ic;icc;h"

_EODSP

}

#
# if test `grep -c "# End Project" "$studiofile"` -gt 0; then
#   me=`echo $me | sed 's%^.*/%%g'`
#   echo >&2 "$me: error: project file is closed - you must start from scratch (make clean)"
#   exit 1
# fi
#

if ( $sourcefile ne "" ) {
  # set up section for the source file
  if ( $sourcefile =~ m/^[a-zA-Z]:.*/ || $sourcefile =~ m%^/.*% ) {
  } else {
    # this is a relative path
    $sourcefile = "${cwd}/${sourcefile}";
  }
  $sourcefile = Cygpath2Win($sourcefile);
  $sourcefileunixname = Cygpath2Unix($sourcefile);
  $sourcefiledir = Dirname($sourcefileunixname);
  $sourcefiledirdir = Dirname($sourcefiledir);
  $sourcefiledirdirdir = Dirname($sourcefiledirdir);
  $targetdir = $sourcefiledir;
  $targetdir =~ s%^${sourcefiledirdirdir}[/\\]?%%g;
  $targetdir =~ s%.*src[/\\]?%%g;
  $targetdir =~ s%.*lib[/\\]?%%g;
  $group = $targetdir;
  $targetdir = Unix2Dos($targetdir);
  SaveVars();

  if ($group ne $prev_group) {
    if ($prev_group ne "") {
      print DSP "# End Group\n";
    }
    if ($group ne "") {
      print DSP <<"_EODSP";
# Begin Group "${group} sources"
# PROP Default_Filter "c;cpp;ic;icc;h"
_EODSP
    }
  }

  $sourcefile = Cygpath2Win($sourcefile);

  $sourcefile =~ s%^${build_dir}[\\/]?%.\\%;
  $sourcefile =~ s%^${build_dir_win}[\\/]?%.\\%;
  if ($sim_ac_relative_src_dir_p) {
    $sim_ac_relative_src_dir_win = Unix2Dos($sim_ac_relative_src_dir);
    $sourcefile =~ s%^${src_dir}[\\/]?%${sim_ac_relative_src_dir_win}\\%;
    $sourcefile =~ s%^${src_dir_win}[\\/]?%${sim_ac_relative_src_dir_win}\\%;
  }

  print DSP <<"_EODSP";
# Begin Source File

SOURCE=${sourcefile}
_EODSP
  if ($group ne "") {
    print DSP <<"_EODSP";
!IF  "\$(CFG)" == "${library}\@${LIBRARY}_MAJOR_VERSION\@ - Win32 DLL (Release)"
# PROP Intermediate_Dir "Release\\${targetdir}"
!ELSEIF  "\$(CFG)" == "${library}\@${LIBRARY}_MAJOR_VERSION\@ - Win32 DLL (Debug)"
# PROP Intermediate_Dir "Debug\\${targetdir}"
!ELSEIF  "\$(CFG)" == "${library}\@${LIBRARY}_MAJOR_VERSION@ - Win32 LIB (Release)"
# PROP Intermediate_Dir "StaticRelease\\${targetdir}"
!ELSEIF  "\$(CFG)" == "${library}\@${LIBRARY}_MAJOR_VERSION\@ - Win32 LIB (Debug)"
# PROP Intermediate_Dir "StaticDebug\\${targetdir}"
!ENDIF
_EODSP
  } else {
    print DSP <<"_EODSP";
!IF  "\$(CFG)" == "${library}\@${LIBRARY}_MAJOR_VERSION\@ - Win32 DLL (Release)"
# PROP Intermediate_Dir "Release"
!ELSEIF  "\$(CFG)" == "${library}\@${LIBRARY}_MAJOR_VERSION\@ - Win32 DLL (Debug)"
# PROP Intermediate_Dir "Debug"
!ELSEIF  "\$(CFG)" == "${library}\@${LIBRARY}_MAJOR_VERSION@ - Win32 LIB (Release)"
# PROP Intermediate_Dir "StaticRelease"
!ELSEIF  "\$(CFG)" == "${library}\@${LIBRARY}_MAJOR_VERSION\@ - Win32 LIB (Debug)"
# PROP Intermediate_Dir "StaticDebug"
!ENDIF
_EODSP
  }

  print DSP <<"_EODSP";
# End Source File
_EODSP

  open(SRC, "${sourcefileunixname}");
  @matches = grep(/moc_.*\.icc/, <SRC>);
  close(SRC);
  if (scalar(@matches) > 0) {
    # The sourcefile needs MOC to be executed before building.
    # The assumptions here are that the header is in the same directory in the
    # hierarchy, and that the moc file contains the magic text telling the
    # header file name.  It is also assumed that the moc file is not built
    # on its own but included in the source file, and named moc_*.icc.
    $mocfile = $matches[0];
    $mocfile =~ m%.*<(.*icc)>.*%;
    $mocfile = $1;
    $mocfile =~ s,.*/,,;
    open(MOC, $mocfile);
    @mocmatches = grep(/from reading C/, <MOC>);
    close(MOC);
    $headerfile = $mocmatches[0];
    $headerfile =~ m%.*\'(.*)\'%;
    $headerfile = $1;
    $mocfile = "${cwd}/${mocfile}";
    $mocfile =~ s%${build_dir}/%%;
    $mocfile = Unix2Dos($mocfile);
    $headerfilepath = "${cwd}/${headerfile}";
    $headerfilepath =~ s%${build_dir}/%%;

    if ( -f $headerfile ) {
      $headerfile = $headerfilepath;
    } else {
      $headerfile = "${sim_ac_relative_src_dir}/${headerfilepath}";
    }

    $headerfile = Cygpath2Win($headerfile);

    $headerfile =~ s%^${build_dir}[\\/]?%.\\%;
    $headerfile =~ s%^${build_dir_win}[\\/]?%.\\%;
    if ($sim_ac_relative_src_dir_p) {
      $sim_ac_relative_src_dir_win = Unix2Dos($sim_ac_relative_src_dir);
      $headerfile =~ s%^${src_dir}[\\/]?%${sim_ac_relative_src_dir_win}\\%;
      $headerfile =~ s%^${src_dir_win}[\\/]?%${sim_ac_relative_src_dir_win}\\%;
    }

    # FIXME: this seems awfully redundant - check if the moc-rules can be
    # folded to one config-independent rule.
    print DSP <<"_EODSP";
# Begin Source File

SOURCE=${headerfile}

!IF  "\$(CFG)" == "${library}\@${LIBRARY}_MAJOR_VERSION\@ - Win32 DLL (Release)"

# PROP IgnoreDefaultTool 1
#Begin Custom Build - moc'ing \$(InputPath)
InputPath=${headerfile}

"${mocfile}" : \$(SOURCE) "\$(INTDIR)" "\$(OUTDIR)"
	\$(QTDIR)\\bin\\moc -o ${mocfile} ${headerfile}

# End Custom Build

!ELSEIF  "\$(CFG)" == "${library}\@${LIBRARY}_MAJOR_VERSION\@ - Win32 DLL (Debug)"

# PROP IgnoreDefaultTool 1
#Begin Custom Build - moc'ing \$(InputPath)
InputPath=${headerfile}

"${mocfile}" : \$(SOURCE) "\$(INTDIR)" "\$(OUTDIR)"
	\$(QTDIR)\\bin\\moc -o ${mocfile} ${headerfile}

# End Custom Build

!ELSEIF  "\$(CFG)" == "${library}\@${LIBRARY}_MAJOR_VERSION\@ - Win32 LIB (Release)"

# PROP IgnoreDefaultTool 1
#Begin Custom Build - moc'ing \$(InputPath)
InputPath=${headerfile}

"${mocfile}" : \$(SOURCE) "\$(INTDIR)" "\$(OUTDIR)"
	\$(QTDIR)\\bin\\moc -o ${mocfile} ${headerfile}

# End Custom Build
  
!ELSEIF  "\$(CFG)" == "${library}\@${LIBRARY}_MAJOR_VERSION\@ - Win32 LIB (Debug)"

# PROP IgnoreDefaultTool 1
#Begin Custom Build - moc'ing \$(InputPath)
InputPath=${headerfile}

"${mocfile}" : \$(SOURCE) "\$(INTDIR)" "\$(OUTDIR)"
	\$(QTDIR)\\bin\\moc -o ${mocfile} ${headerfile}

# End Custom Build

!ENDIF

# End Source File
_EODSP

  }
}

if ( $outputfile =~ /\.so\./ ) {
  # this is how we detect the last command in the build process

  # fix dependency first
  open(OUT, ">${outputfile}");
  print OUT $date;
  close(OUT);

  # "close" the dsp file
  print DSP "# End Group\n";
  print DSP "# End Group\n";

  # We need to know about the root build dir and source dir to trigger the
  # header installation rule, and to locate the additional source files we
  # should put in the .dsp file
  $builddir = $studiofile;
  $builddir =~ s%/[^/]*$%%;
  $builddir_unix = $builddir;
  $builddir = Cygpath2Win($builddir);

  $sourcedir = $me;
  $sourcedir =~ s%[\\/]cfg[\\/]gendsp\..*$%%;
  $sourcedir_unix = $sourcedir;
  $sourcedir = Cygpath2Win($sourcedir);

  # PUBLIC HEADERS
  # To get the list of public header files, we run "make install" into a
  # temporary directory, while overriding the header-install program to be
  # this script with a magic option as the first argument.  Afterwards we
  # clean out the temporary install dir.
  ClearVars();
  print DSP "# Begin Group \"Public Headers\"\n";
  print DSP "\n";
  print DSP "# PROP Default_Filter \"h;ic;icc\"\n";
  close(DSP); # .dsp is appended to from subprocesses here...
  $tmpdir = "/tmp/dsp-install.tmp";
  system("cd ${builddir_unix}; make INSTALL_HEADER=\"$me --register-public-header ${studiofile}\" DESTDIR=\"${tmpdir}\" install-data");
  system("rm -rf ${tmpdir}");
  LoadVars();
  open(DSP, ">>${studiofile}");
  if ( $prev_group ne "" ) {
    print DSP "# End Group\n";
  }
  print DSP "# End Group\n";

  # PRIVATE HEADERS
  # I don't know how to properly construct a list of private headers yet,
  # but we can for sure assume that all .ic/.icc source files are includes
  # used from other source files.  We also assume that header files that
  # check for <lib>_INTERNAL and emits a #error with a message containing
  # "private" or "internal" is an internal header file.
  ClearVars();
  print DSP "# Begin Group \"Private Headers\"\n";
  print DSP "\n";
  print DSP "# PROP Default_Filter \"h;ic;icc\"\n";
  open(FIND, "(find ${src_dir}/src ${src_dir}/include ${src_dir}/data ${src_dir}/lib ${build_dir} -name \"*.h\" | xargs grep -l \"_INTERNAL\\\$\" | xargs grep -i -l \"#error.*private\"; find ${src_dir}/src ${src_dir}/lib ${build_dir} -name \"*.ic\" -o -name \"*.icc\" ) | sort | uniq |");
  @files = <FIND>;
  close(FIND);
  
  $prev_group = "";
  for $file (@files) {
    LoadVars();
    # $filename = Basename($file, "");
    next if ($file =~ m/config-wrapper.h/o);
    next if ($file =~ m/discard.h/o);

    $group = Dirname($file);
    $group =~ s%^.*[\\/]%%g;
    if ($group eq "include") {
      if ($file =~ m/${build_dir}/) {
        $group = "[setup]";
      } else {
        $group = "root";
      }
    }
    SaveVars();

    $filepath = Cygpath2Win($file);

    $filepath =~ s%^${build_dir}[\\/]?%.\\%;
    $filepath =~ s%^${build_dir_win}[\\/]?%.\\%;
    if ($sim_ac_relative_src_dir_p) {
      $sim_ac_relative_src_dir_win = Unix2Dos($sim_ac_relative_src_dir);
      $filepath =~ s%^${src_dir}[\\/]?%${sim_ac_relative_src_dir_win}\\%;
      $filepath =~ s%^${src_dir_win}[\\/]?%${sim_ac_relative_src_dir_win}\\%;
    }

    if ( $group ne $prev_group ) {
      if ($prev_group ne "") {
        print DSP "# End Group\n";
      }
      if ($filepath =~ m/include/o) {
        print DSP "# Begin Group \"${group} headers\"\n";
      } else {
        print DSP "# Begin Group \"${group} local includes\"\n";
      }
      print DSP "\n";
      print DSP "# PROP Default_Filter \"h;ic;icc\"\n";
    }
    print DSP <<"_EODSP";
# Begin Source File

SOURCE=${filepath}
# PROP Exclude_From_Build 1
# End Source File
_EODSP
  }

#  open(FIND, "find ${src_dir}/src ${build_dir} -name \"*.ic\" -o -name \"*.icc\" |");
#  @files = <FIND>;
#  close(FIND);
#  for $file (@files) {
#
#    $filepath = $file;
#
#    $filepath = Cygpath2Win($filepath);
#
#    $filepath =~ s%^${build_dir}[\\/]?%.\\%;
#    $filepath =~ s%^${build_dir_win}[\\/]?%.\\%;
#    if ($sim_ac_relative_src_dir_p) {
#      $sim_ac_relative_src_dir_win = Unix2Dos($sim_ac_relative_src_dir);
#      $filepath =~ s%^${src_dir}[\\/]?%${sim_ac_relative_src_dir_win}\\%;
#      $filepath =~ s%^${src_dir_win}[\\/]?%${sim_ac_relative_src_dir_win}\\%;
#    }
#
#    print DSP <<"_EODSP";
## Begin Source File
#
#SOURCE=${filepath}
## PROP Exclude_From_Build 1
## End Source File
#_EODSP
#  }

  if ($group ne "") {
    print DSP "# End Group\n";
  }
  print DSP <<"_EODSP";
# End Group
# End Target
# End Project
_EODSP
  close(DSP);

  # create the .dsw file
  $workspacefile = Dirname($studiofile) . "/" . Basename($studiofile, ".dsp") . ".dsw";

  open(DSW, ">${workspacefile}");
  print DSW <<"_EODSW";
Microsoft Developer Studio Workspace File, Format Version 6.00
# WARNING: DO NOT EDIT OR DELETE THIS WORKSPACE FILE!

###############################################################################

Project: "${library}\@${LIBRARY}_MAJOR_VERSION\@"=.\\${library}\@${LIBRARY}_MAJOR_VERSION\@.dsp - Package Owner=<4>

Package=<5>
{{{
}}}

Package=<4>
{{{
}}}

###############################################################################

Project: "${library}\@${LIBRARY}_MAJOR_VERSION\@_install"=.\\${library}\@${LIBRARY}_MAJOR_VERSION\@_install.dsp - Package Owner=<4>

Package=<5>
{{{
}}}

Package=<4>
{{{
    Begin Project Dependency
    Project_Dep_Name ${library}\@${LIBRARY}_MAJOR_VERSION\@
    End Project Dependency
}}}

###############################################################################

Project: "${library}\@${LIBRARY}_MAJOR_VERSION\@_uninstall"=.\\${library}\@${LIBRARY}_MAJOR_VERSION\@_uninstall.dsp - Package Owner=<4>

Package=<5>
{{{
}}}

Package=<4>
{{{
}}}

###############################################################################

Project: "${library}\@${LIBRARY}_MAJOR_VERSION\@_docs"=.\\${library}\@${LIBRARY}_MAJOR_VERSION\@_docs.dsp - Package Owner=<4>

Package=<5>
{{{
}}}

Package=<4>
{{{
}}}

###############################################################################

Global:

Package=<5>
{{{
}}}

Package=<3>
{{{
}}}

###############################################################################

_EODSW
  close(DSW);

  # Make everything peachy for MS DOS

  SubstFile($studiofile);
  SubstFile($installstudiofile);
  SubstFile($uninstallstudiofile);
  SubstFile($docstudiofile);
  SubstFile($workspacefile);
  $installheadersfile = $studiofile;
  $installheadersfile =~ s,([^\\/0-9]*)[0-9][^\\/]*\.dsp,install-headers.bat,;
  # don't generate install-headers inside misc/ to be able to generate
  # concurrently inside several msvc*/-directories.
  # $installheadersfile =~ s,msvc[6789]/,misc/,;
  $uninstallheadersfile = $installheadersfile;
  $uninstallheadersfile =~ s/install-hea/uninstall-hea/;
  SubstBatFile($installheadersfile);
  SubstBatFile($uninstallheadersfile);

  # Transform paths to be relative paths for non-installer-builds too.
  # This should probably be configurable in some way though.
  if ( $sourcedir eq $builddir ) {
    $relsourcedir = ".";
  } else {
    $num = 1;
    while ( true ) {
      $presource = `echo ${sourcedir} | cut -d'\' -f1-$num`;
      $prebuild = `echo ${builddir} | cut -d'\' -f1-$num`;
      if ( $presource ne $prebuild ) {
	break;
      }
      ++$num;
    }
    --$num;

    if ( $num == 0 ) {
      # relative path impossible
      $relsourcedir = $sourcedirregexp;
    } else {
      $numplus = $num + 1;
      $upfix = `echo "${builddir}\\\\" | cut -d'\' -f${numplus}- | sed -e 's%[^\\\\]*\\\\%..\\\\%g' -e 's%\\\\%\\\\\\\\%g'`;
      $postfix = `echo ${sourcedir} | cut -d'\' -f${numplus}- | sed -e 's%\\\\%\\\\\\\\%g'`;
      $relsourcedir = "${upfix}${postfix}";
    }
  }

  # FIXME: update paths to relative paths
  #sed -e "s%$sourcedirregexp%$relsourcedir%g" \
  #    -e "s%$builddirregexp\\\\%.\\\\%g" \
  #    -e "s%$builddirregexp%.\\\\%g" \
  #  <"$studiofile.txt2" >"$studiofile.txt"

  # here we try to reverse some environment variable values back to their
  # variable references, to make the project less system-dependent.
  for $var (@reversevars) {
    $varval = $ENV{$var};
    $varval = Cygpath2Win($varval);
    # FIXME: reverse variable values in the project files
  }

  # we want to link debug versions of this project with debug versions of the
  # libs they depend on.  we only do this for our own known libraries though.
  @debuglibs = (
    "coin[0-9]",
    "soqt[0-9]",
    "sowin[0-9]",
    "nutsnbolts[0-9]",
    "smallchange[0-9]",
    "simvoleon[0-9]"
  );
  for $lib (@debuglibs) {
    # FIXME: rewrite debuglibs ($?.lib -> $?d.lib) for lines matching "/debug"
  }

  # do unix2dos conversion (\n -> \r\n) on the DevStudio files
  CRLFFile($studiofile);
  CRLFFile($installstudiofile);
  CRLFFile($uninstallstudiofile);
  CRLFFile($docstudiofile);
  CRLFFile($workspacefile);
  # clean out temporary files

}
