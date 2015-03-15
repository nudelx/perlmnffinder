#!/usr/bin/perl -w

use warnings;
use strict;
use iFinder;


sub main()
{
	$|++;
	my $imod=iFinder->new();
	my @names;
	my $idata={};

	
	 @names=$imod->ReadDataFile("input.db");
	 
	 $imod->StartProces("Starting web search");
	 foreach my $name (@names)
	 {
	  $idata->{$name}=[$imod->MnfFindByKey("$name")];
	 	 	
	 }
	 $imod->EndProccess();
	 
	 $imod->StartProces("Creating Statistics");
	 $idata=$imod->CreateStatistics($idata);
	 $imod->EndProccess();
	 
	 $imod->StartProces("Writing output file");
	 $imod->CreatFile($idata);
	 $imod->EndProccess(); 
	 
	
}

main();