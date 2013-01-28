{

    package Customer;
    use Gideon driver => 'DBI';

    has id => (
        is          => 'rw',
        isa         => 'Num',
        traits      => ['Gideon::DBI::Column'],
        primary_key => 1,
    );

    has name => (
        is     => 'rw',
        isa    => 'Str',
        column => 'alias',
        traits => ['Gideon::DBI::Column']
    );

    __PACKAGE__->meta->store("test:customer");
    __PACKAGE__->meta->make_immutable;
}

{

    package Person;
    use Gideon driver => 'DBI';

    has first_name => (
        is     => 'rw',
        isa    => 'Str',
        traits => ['Gideon::DBI::Column']
    );

    has last_name => (
        is     => 'rw',
        isa    => 'Str',
        traits => ['Gideon::DBI::Column']
    );

    __PACKAGE__->meta->store("test:person");
    __PACKAGE__->meta->make_immutable;
}

use strict;
use warnings;
use Test::More tests => 4;
use Gideon::StoreRegistry;
use DBI;

my $dbh = DBI->connect( 'dbi:Mock:', undef, undef, { RaiseError => 1 } );
$dbh->{mock_session} = setup_session();

Gideon::StoreRegistry->register( 'test', $dbh );

# Test _update_object
{
    my $customer = Customer->new( id => 1, name => 'joe doe' );
    ok( Gideon::DBI->_update_object( $customer, { id => 2 } ),
        'update single instance' );

    my $person = Person->new( first_name => 'John', last_name => 'Doe' );
    ok( Gideon::DBI->_update_object( $person, { first_name => 'Joe' } ),
        'update signle instance without primary key' );
}

# Test _update
{
    ok( Gideon::DBI->_update( 'Customer', { name => 'jack' } ),
        'update all records' );
}

# Test _update with a where condition
{
    ok(
        Gideon::DBI->_update(
            'Customer',
            { name => 'jack' },
            { name => 'joe' }
        ),
        'update all records that match a given where condition'
    );
}

sub setup_session {
    DBD::Mock::Session->new(
        test => (
            {
                statement =>
                  qr/UPDATE customer SET id = \? WHERE \( id = \? \)/sm,
                results => [ ['rows'], [] ],
                bound_params => [ 2, 1 ],
            },
            {
                statement =>
                  qr/WHERE \( \( first_name = \? AND last_name = \? \) \)/sm,
                results => [ ['rows'], [] ],
                bound_params => [ 'Joe', 'John', 'Doe' ],
            },

            {
                statement    => qr/UPDATE customer SET alias = \?/,
                results      => [ ['rows'], [], [], [] ],
                bound_params => [ 'jack', ],
            },
            {
                statement =>
                  qr/UPDATE customer SET alias = \? WHERE \( alias = \? \)/,
                results => [ ['rows'], [], [], [] ],
                bound_params => [ 'jack', 'joe' ],
            },

        )
    );
}

