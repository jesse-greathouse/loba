#!/usr/bin/perl

# Requires DBI module
# Currently the only supported adapter is mysql
use DBI;
use strict;
use constant ADMIN_ROLE_ID => 1;

# Set up variables from the environment
my $adminEmail =  $ENV{'ADMIN_EMAIL'};
my $adminPassword =  $ENV{'ADMIN_PASSWORD'};
my $sqlDir = $ENV{'SQL_QUERY_DIR'};
my $driver =  $ENV{'DB_DRIVER'};
my $database = $ENV{'DB_NAME'};
my $host = $ENV{'DB_HOST'};
my $dsn = "DBI:$driver:database=$database;host=$host";
my $userid = $ENV{'DB_USER'};
my $password = $ENV{'DB_PASSWORD'};

my %dbAttr = (  RaiseError => 1,  # error handling enabled
	            AutoCommit => 1,  # transaction enabled
);

# Make the database connection
my $dbh = DBI->connect($dsn, $userid, $password, \%dbAttr)
    or die $DBI::errstr;

# List of the queries that will be used.
my %queries;
$queries{"insertPassword"}{file} = 'insert_password.sql';
$queries{"insertUser"}{file} = 'insert_user.sql';
$queries{"insertUserPassword"}{file} = 'insert_user_password.sql';
$queries{"insertUserRole"}{file} = 'insert_user_role.sql';
$queries{"selectPasswordById"}{file} = 'select_password_by_id.sql';
$queries{"selectUserByEmail"}{file} = 'select_user_by_email.sql';
$queries{"selectUserById"}{file} = 'select_user_by_id.sql';
$queries{"selectUserPasswordByUser"}{file} = 'select_user_password_by_user.sql';
$queries{"selectUserPasswordById"}{file} = 'select_user_password_by_id.sql';
$queries{"selectUserRoleById"}{file} = 'select_user_role_by_id.sql';
$queries{"selectUserRoleByUser"}{file} = 'select_user_role_by_user.sql';
$queries{"updateUserPassword"}{file} = 'update_user_password.sql';
$queries{"updateUserRole"}{file} = 'update_user_role.sql';

# Populate the query from the files
foreach my $key (keys %queries) {
    $queries{$key}{query} = read_file($queries{$key}{file}, $sqlDir);
}

my %adminUser = get_user_by_email($adminEmail);
# Create an adminUser if it was not found.
%adminUser = create_user($adminEmail) unless %adminUser;

# Fetch a list of the roles assigned to the adminUser
my @roles = get_user_roles(%adminUser);

# Create a password record with the given input
my %password = create_password($adminPassword);

# fetches a record from the admin_password reference table
my %adminPasswordRef = get_user_password_by_user($adminUser{'id'});

# Update adminPasswordRef or create it if not found.
if (%adminPasswordRef) {
    $adminPasswordRef{'passwordId'} =  $password{'id'};
    %adminPasswordRef = update_user_password(%adminPasswordRef);
} else {
    $adminPasswordRef{'passwordId'} =  $password{'id'};
    $adminPasswordRef{'userId'} =  $adminUser{'id'};
    %adminPasswordRef = create_user_password(%adminPasswordRef);
}

# If the user does not have the ADMIN role, assign it
if (!has_role("ADMIN", @roles)) {
    # If the user has a role, upgrade it to ADMIN
    if (scalar @roles) {
        $roles[0]->{roleId} = ADMIN_ROLE_ID;
        my %adminRole = update_user_role($roles[0]);
    } else {
        # Create a new ADMIN role
        my %adminRole = (
            userId => $adminUser{'id'}, 
            roleId => ADMIN_ROLE_ID,
        );
        %adminRole = create_user_role(%adminRole);
    }
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

# Loops through a list of user roles and returns boolean if match
sub has_role {
    my ($name, @roles) = @_;

    foreach (@roles) {
        if ($_{'name'} eq $name) {
            return 1;
        }
    }

    return 0;
}

# Gets all the user_role records from the database by hash input
sub get_user_roles {
    my (%user) = @_;
    my @roles;
    my $sth = $dbh->prepare($queries{"selectUserRoleByUser"}{query})
        or die("Can't prepare " . $queries{"selectUserRoleByUser"}{query});
    $sth->bind_param(1, $user{'id'});
    $sth->execute() or die($dbh->errstr . "\n");

    my ($id, $userId, $roleId);
    $sth->bind_col(1, \$id);
    $sth->bind_col(2, \$userId);
    $sth->bind_col(3, \$roleId);

    while (my @row = $sth->fetchrow_array) {
        my %role = ( id => $id, userId => $userId, roleId => $roleId);
        push(@roles, \%role);
    }

    return @roles;
}

# Gets a record of an user from the database by the user $email parameter
sub get_user_by_email {
    my ($email) = @_;
    my %user;
    my $sth = $dbh->prepare($queries{"selectUserByEmail"}{query})
        or die("Can't prepare " . $queries{"selectUserByEmail"}{query});
    $sth->bind_param(1, $email);
    $sth->execute() or die($dbh->errstr . "\n");
    my @row = $sth->fetchrow_array();

    if (@row) {
        my ($id, $email, $firstName, $lastName, $avatarUrl) = @row;
        %user = (   id          => $id, 
                    email       => $email, 
                    firstName   => $firstName, 
                    lastName    => $lastName,
                    avatarUrl   => $avatarUrl,
        );
    }

    return %user;
}

# Gets a record of an user from the database by the user id parameter
sub get_user_by_id {
    my ($id) = @_;
    my %user;
    my $sth = $dbh->prepare($queries{"selectUserById"}{query})
        or die("Can't prepare " . $queries{"selectUserById"}{query});
    $sth->bind_param(1, $id);
    $sth->execute() or die($dbh->errstr . "\n");
    my @row = $sth->fetchrow_array();

    if (@row) {
        my ($id, $email, $firstName, $lastName, $avatarUrl) = @row;
        %user = (   id          => $id, 
                    email       => $email, 
                    firstName   => $firstName, 
                    lastName    => $lastName,
                    avatarUrl   => $avatarUrl,
        );
    }

    return %user;
}

# Gets a record of a password from the database by the password id parameter
sub get_password_by_id {
    my ($id) = @_;
    my %password;
    my $sth = $dbh->prepare($queries{"selectPasswordById"}{query})
        or die("Can't prepare " . $queries{"selectPasswordById"}{query});
    $sth->bind_param(1, $id);
    $sth->execute() or die($dbh->errstr . "\n");
    my @row = $sth->fetchrow_array();

    if (@row) {
        my ($id, $password, $salt) = @row;
        %password = (   id          => $id, 
                        password    => $password, 
                        salt        => $salt,
        );
    }

    return %password;
}

# Gets a record of user_role from the database by the id parameter
sub get_user_role_by_id {
    my ($roleId) = @_;
    my %userRole;
    my $sth = $dbh->prepare($queries{"selectUserRoleById"}{query})
        or die("Can't prepare " . $queries{"selectUserRoleById"}{query});
    $sth->bind_param(1, $roleId);
    $sth->execute() or die($dbh->errstr . "\n");
    my @row = $sth->fetchrow_array();

    if (@row) {
        my ($id, $userId, $roleId) = @row;
        %userRole = (id        => $id, 
                    userId     => $userId, 
                    roleId     => $roleId,
        );
    }

    return %userRole;
}

# Gets a record of user_password from the database by the id parameter
sub get_user_password_by_id {
    my ($id) = @_;
    my %userPassword;
    my $sth = $dbh->prepare($queries{"selectUserPasswordById"}{query})
        or die("Can't prepare " . $queries{"selectUserPasswordById"}{query});
    $sth->bind_param(1, $id);
    $sth->execute() or die($dbh->errstr . "\n");
    my @row = $sth->fetchrow_array();

    if (@row) {
        my ($id, $userId, $passwordId) = @row;
        %userPassword = (id        => $id, 
                        userId     => $userId, 
                        passwordId => $passwordId,
        );
    }

    return %userPassword;
}

# Gets a record of user_password from the database by the user_id parameter
sub get_user_password_by_user {
    my ($userId) = @_;
    my %userPassword;
    my $sth = $dbh->prepare($queries{"selectUserPasswordByUser"}{query})
        or die("Can't prepare " . $queries{"selectUserPasswordByUser"}{query});
    $sth->bind_param(1, $userId);
    $sth->execute() or die($dbh->errstr . "\n");
    my @row = $sth->fetchrow_array();

    if (@row) {
        my ($id, $userId, $passwordId) = @row;
        %userPassword = (id        => $id, 
                        userId     => $userId, 
                        passwordId => $passwordId,
        );
    }

    return %userPassword;
}

# Creates a user_password record with a hash input
sub create_user_password {
    my (%userPassword) = @_;
    my $sth = $dbh->prepare($queries{"insertUserPassword"}{query})
        or die("Can't prepare " . $queries{"insertUserPassword"}{query});
    $sth->bind_param(1, $userPassword{'userId'});
    $sth->bind_param(2, $userPassword{'passwordId'});
    $sth->execute() or die($dbh->errstr . "\n");
    return get_user_password_by_id($sth->{mysql_insertid});
}

# Creates a user_role record with a hash input
sub create_user_role {
    my (%userRole) = @_;
    my $sth = $dbh->prepare($queries{"insertUserRole"}{query})
        or die("Can't prepare " . $queries{"insertUserRole"}{query});
    $sth->bind_param(1, $userRole{'userId'});
    $sth->bind_param(2, $userRole{'roleId'});
    $sth->execute() or die($dbh->errstr . "\n");
    return get_user_role_by_id($sth->{mysql_insertid});
}

# Creates a password record with a password as the input
sub create_password {
    my ($pw) = @_;
    my $sth = $dbh->prepare($queries{"insertPassword"}{query})
        or die("Can't prepare " . $queries{"insertPassword"}{query});
    $sth->bind_param(1, $pw);
    $sth->execute() or die($dbh->errstr . "\n");
    return get_password_by_id($sth->{mysql_insertid});
}

# Creates a user record with an email as the input
sub create_user {
    my ($email) = @_;
    my $sth = $dbh->prepare($queries{"insertUser"}{query})
        or die("Can't prepare " . $queries{"insertUser"}{query});
    $sth->bind_param(1, $email);
    $sth->bind_param(2, undef);
    $sth->bind_param(3, undef);
    $sth->bind_param(4, undef);
    $sth->execute() or die($dbh->errstr . "\n");
    return get_user_by_id($sth->{mysql_insertid});
}

# Updates a user_password record with a hash input
sub update_user_password {
    my (%userPassword) = @_;
    my $sth = $dbh->prepare($queries{"updateUserPassword"}{query})
        or die("Can't prepare " . $queries{"updateUserPassword"}{query});
    $sth->bind_param(1, $userPassword{'userId'});
    $sth->bind_param(2, $userPassword{'passwordId'});
    $sth->bind_param(3, $userPassword{'id'});
    $sth->execute() or die($dbh->errstr . "\n");
    return get_user_password_by_id($userPassword{'id'});
}

# Updates a user_role record with a hash input
sub update_user_role {
    my ($userRole) = @_;
    my $sth = $dbh->prepare($queries{"updateUserRole"}{query})
        or die("Can't prepare " . $queries{"updateUserRole"}{query});
    $sth->bind_param(1, $userRole->{userId});
    $sth->bind_param(2, $userRole->{roleId});
    $sth->bind_param(3, $userRole->{id});
    $sth->execute() or die($dbh->errstr . "\n");
    return get_user_role_by_id($userRole->{id});
}