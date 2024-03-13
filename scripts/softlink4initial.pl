use warnings;
use strict;

`rm -rf ../initial`;#if you have old files in initial, you may mark this line.
`mkdir ../initial`;

#####make link for labelled folders
my $include_labelled = "yes";#if yes, you need to provide parent paths of your labelled folders (@all_labelled) 
my @all_labelled;
if($include_labelled eq "yes"){
    @all_labelled = qw(
        /home/wayne/perl4dpgen_20221025_old/all_cfgs_11
        /home/wayne/perl4dpgen_20221025_old/all_cfgs_33
    );
    map { s/^\s+|\s+$//g; } @all_labelled;
}

#for initial folder
my @all_inifolder;
#!!! make the following if you have place everything in the initial folder
@all_inifolder= qw(
    /home/wayne/perl4dpgen_20221025_old/initial
);
map { s/^\s+|\s+$//g; } @all_inifolder;

##make softlink for initial 
my @all_ini;
for (@all_inifolder){
    my @temp = `find $_ -mindepth 1 -maxdepth 1 -type d `;
    map { s/^\s+|\s+$//g; } @temp;
    @all_ini = (@all_ini,@temp);
}

#my @all_ini = `find ../initial -type f -name "*.sout"`;
map { s/^\s+|\s+$//g; } @all_ini;
for my $i (@all_ini){
    my @temp = split(/\//,$i);
    `mkdir ../initial/$temp[-1]`;
    `ln -s $i/$temp[-1].in ../initial/$temp[-1]/$temp[-1].in`; 
    `ln -s $i/$temp[-1].sout ../initial/$temp[-1]/$temp[-1].sout`; 
    `ln -s $i/$temp[-1].data ../initial/$temp[-1]/$temp[-1].data`;   
}

##make softlink for all labelled folders
if($include_labelled eq "yes"){
    my @good_labelled;
    for (@all_labelled){
        my @temp = `find $_ -name labelled -type d `;
        map { s/^\s+|\s+$//g; } @temp;
        for my $i (@temp){
            unless(`ls $i`){
                print "empty: $i\n";
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

            #print "path: $j\n";  
            #print "$dirname\n";  
            #print "$basename\n";  
            my $index ="label_". sprintf("%07d",$counter);
            #print "index:$index\n";   
            `rm -rf ../initial/$index`;
            `mkdir ../initial/$index`;
            `cp $i/$basename.sout ../initial/$index/$index.sout`;
            `cp $i/$basename.in ../initial/$index/$index.in`;
            `cp $i/$basename.data ../initial/$index/$index.data`;
            print FH "$i/$basename.sout --> ../initial/$index/$index.sout\n";
            $counter++;
        }
    }
  close(FH);
}