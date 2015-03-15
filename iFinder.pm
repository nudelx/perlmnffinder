package iFinder;

use warnings;
use strict;
use Google::Search;
my $count=1;

sub new 
{
	my $obj={};
	bless $obj;
	return $obj;
	
}

sub StartProces(@_)
{
	my $obj=shift;
	my $msg=shift;
	print "$msg.....";
}

sub EndProccess(@_)
{
	my $obj=shift;
	print "OK\n";
		
}

sub MnfFindByKey(@_)
{
	
	my $obj=shift;
	my $keyword=shift;
	my @url;
	my $nkeyword=$keyword . " +wine";
	print "\n $count : Searching Data  For ==> $keyword........";
	my $search = Google::Search->Web(q => $nkeyword, 0, 0);
    my $result = $search->first;
    $count++;
  
    while (($result) && ($result->number<10))
     {
     	eval 
     	{

		
	        $result = $result->next;
	        if(defined($result->uri))
	        {
	        	$result->uri =~ m/(http:\/\/.*?)\//i;
	        	my $normal=$1;
	#       	print $normal ."\n";
	        	push(@url,$normal);
	        
	        }
	        else
	        {
	        	push(@url,"NONE");
	        	print "\nNONDEFINED URL\n";
	        }
		};
		
		if ($@)
   		{
        	### catch block
        	print " \n FAILED TO GET URI FROM WEB \n";
        	push(@url,"NONE");
   		};
        
     }
  
   
   
     print"Done\n";
     return @url;	
}

sub ReadDataFile(@_)
{
	print "Reading data file.... ";
	my $obj=shift;
	my $file=shift;
	my @lines;
	
	open (FH ,"<$file")or die "Cannot open file $!";
	
	while(<FH>)
	{	chomp($_);
		if($_=~s/[^\w\s]/ /g)
		{
#			print "Found in $_ \n";
		}
		$_=~s/\s{2,}/ /g ;
		print "\nFIXED $_\n";
		push(@lines,$_);
#		print "$_ \n";
	}
	
	close(FH);
	print "OK\n";
	return @lines;
	
	
}

sub CreateStatistics(@_)
{
	my $obj=shift;
	my $ref=shift;
	
	foreach my $key (keys %$ref)
	{
#		print  "\n".$key ." ===> ". $ref->{$key}->[0]."\n";
#		print  $#{$ref->{$key}};	
		$ref->{$key}=[GetHitValue($ref->{$key},$key)];
	}
	
	return $ref;
}
### Inside Module Function - > Don't use with object!  
sub GetHitValue(@_)
{
	my $arr =shift;
	my $key = shift;
	
	my @keys= split(/ /,$key);
	my $size=scalar @keys;
	
#	if more then one keyword check them all
 
#	if($size>1)
#	{
#		print "\nFound Size $size in $key\n";
#	}
		
	my $stat=-1;
	my @sortedarr = sort{length $a <=>length $b} @$arr;
	my $i=0;
	my @links;
	my $isHited=-1;
	 
 foreach my $url(@sortedarr)
 {
 	my $hitValue=100/$size;
 	
 	foreach my $token(@keys)
 	{
# 		print"\t\n Cheking for $url  ==> $token";	
	 	if ( $url =~ /$token/i )
	 	{
	
	 		$stat = $stat+$hitValue;
	 		$isHited=1;
			###posible to make precision by num of hited values before sorting
	 	}
	 	
 	}
 		push @links ,[$url,$stat,$isHited];
 		$stat=-1;
 		$isHited=-1;
	 	$i++;
	 	
 }
 
 return @links;
	
	
}

sub CreatFile(@_)
{
	my $obj=shift;
	my $data=shift;
	
	open (FH,">mnfOutput.csv"); 
	open (LH,">LoGMnfOutput.log"); 
	
	foreach my $key (keys %$data)
	{
		my $urlArr=$data->{$key};
		
		print "\n Result For: < " .$key ." >"."\n";
		print LH "\n Result For: < " .$key ." >"."\n";
		
		
		###if has hit so sort by hit if no sort by length
		### move ishited to key , and make if to sort...
		
		
		if(($data->{$key}->[2])>0)
		{
			print "\n\t\t !!!!!!!!!!!!!!!!Sorted By Hited value Inside $key !!!!!!!!!!!!!!!!!!!!!!!\n\n";
			my @sortedurlArr = sort {$b->[1]<=>$a->[1]} @$urlArr;
			if($sortedurlArr[0]->[1]>0)
			{
				print FH "\n Result For: " .$key . ",$sortedurlArr[0]->[0]";
			}
			else
			{
				print FH "\n Result For: " .$key . ",NONE";
			}
				
			
			foreach my $url(@sortedurlArr)
			 {
		 		print "The URL is $url->[0] ===> HIT is: $url->[1] :::: IF HITED ==> $url->[2]\n";
		 		print LH "$url->[0] ==> HIT: $url->[1]\n";
		 	
			 }

			print "\n\n";
		}
		else
		{
			print "\nNONHited value Inside \n";
			print FH "\n Result For: " .$key . ",$urlArr->[0]->[0]";
			
			foreach my $url(@$urlArr)
			 {
		 		print "The URL is $url->[0] ===> HIT is: $url->[1] :::: IF HITED ==> $url->[2]\n";
		 		print LH "$url->[0]\n";
			 }

			print "\n\n";

		}
	}
	
	close(FH);
	close(LH);
}

1