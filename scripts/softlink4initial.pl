use warnings;
use strict;

`rm -rf ../initial`;#if you have old files in initial, you may mark this line.
`mkdir ../initial`;
##

#####make link for labelled folders
my $include_labelled = "yes";#if yes, you need to provide parent paths of your labelled folders (@all_labelled) 
my @all_labelled;
if($include_labelled eq "yes"){
    @all_labelled = qw(
        /home/dongye/DP/DP_0215_PTMcheck/label_1/
        /home/dongye/DP/DP_0215_PTMcheck/label_300/
    );
    map { s/^\s+|\s+$//g; } @all_labelled;
}

#for initial folder
my @all_inifolder;
#!!! make the following if you have place everything in the initial folder
@all_inifolder= qw(
    /home/dongye/DP/dp_train/initial/
);
map { s/^\s+|\s+$//g; } @all_inifolder;

##make softlink for initial 
my @all_ini;
for (@all_inifolder){
    my @temp = `find $_ -mindepth 1 -maxdepth 1 -type d `;
    map { s/^\s+|\s+$//g; } @temp;
    @all_ini = (@all_ini,@temp);
}

open(NC, "> ./nonconvergence.dat") or die $!;
print NC "##The following files are not converaged or no sout files, which are skipped!\n\n";
print NC "##cases in the original initial folder\n";
#my @all_ini = `find ../initial -type f -name "*.sout"`;
map { s/^\s+|\s+$//g; } @all_ini;
for my $i (@all_ini){
    my @temp = split(/\//,$i);
    if(-e "$i/$temp[-1].sout" && !`grep "convergence NOT achieved after" $i/$temp[-1].sout`){
        `mkdir ../initial/$temp[-1]`;
        `ln -s $i/$temp[-1].in ../initial/$temp[-1]/$temp[-1].in`; 
        `ln -s $i/$temp[-1].sout ../initial/$temp[-1]/$temp[-1].sout`; 
        `ln -s $i/$temp[-1].data ../initial/$temp[-1]/$temp[-1].data`;
    }
    else{
        print NC "***No $i/$temp[-1].sout\n";
    }
}

##make softlink for all labelled folders
if($include_labelled eq "yes"){
    
    print NC "\n\n##cases in the labelled folders:\n";    
    my @good_labelled;
    for (@all_labelled){
        my @temp = `find $_ -name labelled -type d `;
        map { s/^\s+|\s+$//g; } @temp;
        for my $i (@temp){
            unless(`ls $i`){
                print "empty: $i\n";
                print NC "**empty folder: $i\n";
            }
            else{
                push @good_labelled, $i;
            }
        }
    }

    open(FH, "> ./npy_files_path.dat") or die $!;
    print FH "#Original_path --> path in the initial folder\n";  
    my $counter = 0;
    for my $i (@good_labelled){    
        my @temp = `find $i -name "*.sout" -type f `;
        #my @temp_in = `find $i -name "*.in" -type f `;
        #my @temp_data = `find $i -name "*.data" -type f `;
        map { s/^\s+|\s+$//g; } @temp;

        for my $j (@temp){ 
            my $basename = `basename $j`;
            my $dirname = `dirname $j`;
            $basename =~ s/^\s+|\s+$//g;
            $dirname =~ s/^\s+|\s+$//g;
            $basename =~ s/\.sout//g;
#-e "$i/$basename.sout" &&
            #print "path: $j\n";  
            #print "$dirname\n";  
            #print "$basename\n";
            #my $sout = `grep "convergence NOT achieved after" $i/$basename.sout`;
            
            if( -e "$i/$basename.sout" && !`grep "convergence NOT achieved after" $i/$basename.sout`){
                my $index ="label_". sprintf("%07d",$counter);
                #print "index:$index\n";   
                `rm -rf ../initial/$index`;
                `mkdir ../initial/$index`;
                `cp $i/$basename.sout ../initial/$index/$index.sout`;
                `cp $i/$basename.in ../initial/$index/$index.in`;
                #`cp $i/$basename.data ../initial/$index/$index.data`;
                print FH "$i/$basename.sout --> ../initial/$index/$index.sout\n";
                $counter++;
            }
            elsif(! -e "$i/$basename.sout"){
                print NC "**no $i/$basename.sout\n";
            }
            else{
                print NC "$i/$basename.sout\n";
            }
        }
    }
  close(FH);
}

close(NC);
print "You need to check the files or folders with problems below:\n";
system("cat ./nonconvergence.dat");
print "\n\nFor details, please refer to ./nonconvergence.dat\n";