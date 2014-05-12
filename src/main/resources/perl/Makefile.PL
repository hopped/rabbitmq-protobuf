use ExtUtils::MakeMaker;

$CC = 'g++';

# Generate the C++, XS, and Perl files that we need.
my $protoxs = "protoxs --cpp_out=. --out=target SimpleRunner.proto";

print "Generating C++ and Perl/XS sources...\n";
print "$protoxs\n";

`$protoxs`;
`rm -f target/*.pm`;
`mv target/*.xs .`;

# Now write the Makefile.
WriteMakefile(
    'NAME'	        => 'SimpleRunner',
	'VERSION_FROM'  => 'SimpleRunner.pm',
	'OPTIMIZE'      => '-O2 -Wall',
    'CC'            => $CC,
    'LD'            => '$(CC)',
    'CCFLAGS'       => '-fno-strict-aliasing',
	'OBJECT'        => 'SimpleRunner.pb.o SimpleRunner.o RunRequest.o User.o Run.o RunList.o',
    'INC'           =>  "",
	'LIBS'          => [" -L/usr/local/lib -lprotobuf"],
    'XSOPT'         => '-C++',
    'LDDLFLAGS'     => '-arch x86_64 -bundle -undefined dynamic_lookup -L/usr/local/lib -fstack-protector',
);
