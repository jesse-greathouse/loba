#!/usr/bin/perl

# Requires DBI module
# Currently the only supported adapter is mysql
use DBI;
use strict;

# List of SQL scripts in the order they are to be run
my @initScripts = (
    'create_table_site.sql',
    'create_table_method.sql',
    'insert_initial_methods.sql',
    'create_table_upstream.sql',
    'create_table_upstream_server.sql',
    'create_table_upstream_certificate.sql',
    'create_table_user.sql',
    'create_table_password.sql',
    'create_table_role.sql',
    'insert_initial_roles.sql',
    'create_table_user_role.sql',
    'create_table_user_password.sql',
    'create_trigger_before_password_insert.sql',
    'create_table_token.sql',
    'create_trigger_before_token_insert.sql',
);

# Set up variables from the environment
my $driver =  $ENV{'DB_DRIVER'};
my $database = $ENV{'DB_NAME'};
my $host = $ENV{'DB_HOST'};
my $dsn = "DBI:$driver:database=$database;host=$host";
my $userid = $ENV{'DB_USER'};
my $password = $ENV{'DB_PASSWORD'};
my $sql = $ENV{'SQL_QUERY_DIR'};

# Allow multi-statement SQL if the driver permits it
if ($driver eq "mysql") {
    $dsn = $dsn . ";mysql_multi_statements=1"
}

my %dbAttr = (RaiseError=>1,  # error handling enabled
	        AutoCommit=>0); # transaction enabled

# Make the database connection
my $dbh = DBI->connect($dsn, $userid, $password, \%dbAttr)
    or die $DBI::errstr;

# Read the contents of the SQL directory
opendir my $dir, $sql or die "Cannot open directory: $sql";
my @files = readdir $dir;
closedir $dir;

# Loop through the list of init scripts
foreach my $script (@initScripts) {

    # See if the init script is found in the SQL files
    foreach my $file (@files) {
        if ($script eq $file) {

            # Open the file
            open my $fh, '<',  "$sql/$file"
                or die("Can't open file $sql/$file for reading");

            # Read the contents of the file into a string
            my $sqlStatement = do { local $/; <$fh> };

            eval {
                # Make a prepared statement from the string
                my $sth = $dbh->prepare($sqlStatement)
                    or die("Can't prepare $sqlStatement");

                # Execute the SQL
                $sth->execute()
                    or die("Can't execute $sqlStatement");

            };
        }
    }
}

# Commit the transaction
$dbh->commit();

if ($@) {
    warn "Transaction aborted: $@";
    eval { $dbh->rollback( ) }; # in case rollback() fails
}

