# We don't know where the script is going to live on the host system
# Let's force this script to be invoked with the perl interpreter instead of a shebang line

# Requires DBI module
# Currently the only supported adapter is mysql
use DBI;
use DBI qw(:sql_types);
use Template;
use Data::Dumper qw(Dumper);
use strict;

# Set up variables from the environment
my $driver =  $ENV{'DB_DRIVER'};
my $database = $ENV{'DB_NAME'};
my $host = $ENV{'DB_HOST'};
my $dsn = "DBI:$driver:database=$database;host=$host";
my $userid = $ENV{'DB_USER'};
my $password = $ENV{'DB_PASSWORD'};
my $etc = $ENV{'ETC'};
my $port = $ENV{'PORT'};
my $lobaDir = $ENV{'LOBA_DIR'};
my $sqlDir = $ENV{'SQL_QUERY_DIR'};
my $logDir = $ENV{'LOG_DIR'};
my $upstreamDir = $etc . '/nginx/upstream';
my $serverDir = $etc . '/nginx/server';
my $tplDir = $lobaDir . '/compose/tpl';

# Template Toolkit instance
my $tt = Template->new({
    INCLUDE_PATH => $tplDir,
    INTERPOLATE  => 1,
}) || die "$Template::ERROR\n";

my %dbAttr = (  RaiseError => 1,  # error handling enabled
	            AutoCommit => 1,  # transaction enabled
);

# Make the database connection
my $dbh = DBI->connect($dsn, $userid, $password, \%dbAttr)
    or die $DBI::errstr;

# List of the queries that will be used.
my %queries;
$queries{"selectSites"}{file} = 'select_active_sites.sql';
$queries{"selectUpstream"}{file} = 'upstream_join_by_site_id.sql';
$queries{"selectUpstreamServers"}{file} = 'upstream_server_join_by_site_id.sql';

# Populate the query from the files
foreach my $key (keys %queries) {
    $queries{$key}{query} = read_file($queries{$key}{file}, $sqlDir);
}

# Get list of sites from the database
my @sites = get_sites();

# Delete the old configuration files
rm_files('*.conf', $upstreamDir);
rm_files('*.conf', $serverDir);

# Loop through sites and create configurations with templates
foreach my $site (@sites) {
    # Create the Directory for Logging
    my $serverLogDir = "$logDir/" . $site->{domain};
    if ( !-d $serverLogDir ) {
        mkdir($serverLogDir)
            or die("Couldn't create $serverLogDir");
    }

    # Get upstream data of the site
    my %upstream = get_upstream($site->{id});

    # If upstream is marked as SSL use the standard SSL port
    $upstream{'port'} = ($upstream{'ssl'}) ? '443' : $port;

    # Create the upstream config from template
    my $upstreamConfFile = "$upstreamDir/" . $site->{domain} . ".conf";
    $tt->process('upstream', \%upstream, $upstreamConfFile)
        or die("Failure creating: $upstreamConfFile from temlplate:" . $tt->error());

    # Create the server config from template
    my $serverConfFile = "$serverDir/" . $site->{domain} . ".conf";
    $tt->process('server', \%upstream, $serverConfFile)
        or die("Failure creating $serverConfFile from temlplate:" . $tt->error());
}


# ====================================
#    Subroutines below this point
# ====================================

# Reads the contents of a file and returns the content in a string
sub read_file {
   my ($file, $dir) = @_;

    # Open the file
    open my $fh, '<',  "$dir/$file"
        or die("Can't open file $dir/$file for reading");
    return do { local $/; <$fh> };
}

# Deletes files in a directory with the given identifier string
sub rm_files {
    my ($ident, $dir) = @_;

    while ($_ = glob("$dir/$ident")) {
        next if -d $_;
        
        unlink($_)
            or die("Can't remove $_");
    }
}

# Gets a list of active sites from the database
sub get_sites {
    my @rs;

    my $sth = $dbh->prepare($queries{"selectSites"}{query})
        or die("Can't prepare " . $queries{"selectSites"}{query});
    $sth->execute();

    my ($id, $domain, $active);
    $sth->bind_col(1, \$id);
    $sth->bind_col(2, \$domain);
    $sth->bind_col(3, \$active);

    while (my @row = $sth->fetchrow_array) {
        my %site = ( id => $id, domain => $domain, active => $active );
        push(@rs, \%site);
    }

    return @rs;
}

# Gets a record of an upstream from the database by the site $id parameter
sub get_upstream {
    my ($id) = @_;

    my $sth = $dbh->prepare($queries{"selectUpstream"}{query})
        or die("Can't prepare " . $queries{"selectUpstream"}{query});
    $sth->bind_param(1, $id);
    $sth->execute();
    my ($domain, $directive, $hash, $consistent, $ssl) = $sth->fetchrow_array();
    my @servers = get_upstream_servers($id);
    my %upstream = (domain      => $domain, 
                    directive   => $directive, 
                    hash        => $hash, 
                    consistent  => $consistent,
                    ssl         => $ssl,
                    servers     => \@servers,
    );

    return %upstream;
}

# Gets a list of upstream servers by the site $id parameter
sub get_upstream_servers {
    my ($id) = @_;
    my @rs;

    my $sth = $dbh->prepare($queries{"selectUpstreamServers"}{query})
        or die("Can't prepare " . $queries{"selectUpstreamServers"}{query});
    $sth->bind_param(1, $id);
    $sth->execute();
    my ($host, $weight, $backup, $fail_timeout, $max_fails);
    $sth->bind_col(1, \$host);
    $sth->bind_col(2, \$weight);
    $sth->bind_col(3, \$backup);
    $sth->bind_col(3, \$fail_timeout);
    $sth->bind_col(3, \$max_fails);

    while (my @row = $sth->fetchrow_array) {
        my %server = (  host            => $host, 
                        weight          => $weight, 
                        backup          => $backup,
                        fail_timeout    => $fail_timeout,
                        max_fails       => $max_fails,
        );
        push(@rs, \%server);
    }

    return @rs;
}