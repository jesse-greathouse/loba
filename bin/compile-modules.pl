# We don't know where the script is going to live on the host system
# Let's force this script to be invoked with the perl interpreter instead of a shebang line
use strict;

my $etc = $ENV{'ETC'};
my $opt = $ENV{'OPT'};
my $src = $ENV{'SRC'};
my $lobaSrc = $ENV{'LOBA_DIR'};
my $lobaCDir = "$lobaSrc/c";
my $luaDir = "$opt/openresty/luajit";

my @compileDirs = ($lobaCDir);

foreach (@compileDirs)
{
    my $cDir = $_;
    pic_pass_dir($cDir);
    so_pass_dir($cDir);
}

# ====================================
#    Subroutines below this point
# ====================================

sub pic_pass_dir {
    my ($picDir) = @_;

    # Change to the Directory with the C Modules
    chdir "$picDir";

    # pic compile pass (https://www.cprogramming.com/tutorial/shared-libraries-linux-gcc.html#step-1-compiling-with-position-independent-code)
    while ($_ = glob("$picDir/*.c")) {
        next if -d $_;

        my @cmd = ('gcc');
        push @cmd, '-c';
        push @cmd, '-Wall';
        push @cmd, '-Werror';
        push @cmd, $_;
        push @cmd, "-I$luaDir/include/luajit-2.1";
        push @cmd, '-fPIC';
        system(@cmd);

        command_result($?, $!, "PIC pass for: $_", \@cmd);
    }
}

sub so_pass_dir {
    my ($soDir) = @_;

    # Create shared library from object files
    while ($_ = glob("$soDir/*.o")) {
        next if -d $_;

        my $name = get_module_name($_);
        my @cmd = ('gcc');
        push @cmd, '-shared';
        push @cmd, '-o';
        push @cmd, "$name.so";
        push @cmd, $_;
        push @cmd, "-I$luaDir/include/luajit-2.1";
        push @cmd, "-L$luaDir/lib";
        push @cmd, '-lluajit-5.1';
        system(@cmd);

        command_result($?, $!, "Shared library pass for: $_", \@cmd);
    }
}

sub get_module_name {
    my ($uri) = @_;
    my @spl = split('/', $_);
    my $fileName  = @spl[-1];
    my @fileSpl = split('\.', $fileName);
    return $fileSpl[0];
}

sub command_result {
    my ($exit, $err, $operation_str, @cmd) = @_;

    if ($exit == -1) {
        print "failed to execute: $err \n";
        exit $exit;
    }
    elsif ($exit & 127) {
        printf "child died with signal %d, %s coredump\n",
            ($exit & 127),  ($exit & 128) ? 'with' : 'without';
        exit $exit;
    }
    else {
        printf "$operation_str exited with value %d\n", $exit >> 8;
    }
}

