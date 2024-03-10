use warnings;
use strict;

`mkdir ../initial`;
my @all_inifolder = qw(
    /home/jsp1/test/perl4dpgen_20221025/initial
);
map { s/^\s+|\s+$//g; } @all_inifolder;
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
    #print "$temp[-1]\n";
    `rm -rf ..initial/$temp[-1]`;
    `ln -s $i ../initial/$temp[-1]`; 
   # my $temp = `dirname $i`;
   # #my $temp = `dirname $i`;
   # $temp = s/^\s+|\s+$//g;
    #$i =~ s/\$temp//g;
#print "$i: $temp\n";


}