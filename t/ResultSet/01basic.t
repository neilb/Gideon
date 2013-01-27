use strict;
use warnings;
use Test::More;
use Gideon::ResultSet;

my $set =
  Gideon::ResultSet->new( class => undef, query => { id => { '!=' => 1 } } );

is_deeply $set->query, { id => { '!=' => 1 } }, 'Set initialized ok';

{
    my $set2 = $set->find( id => { '!=' => 2 } );
    is_deeply $set2->query,
      { id => [ -and => { '!=' => 1 }, { '!=' => 2 } ] },
      'Combined statement #1';
}

{
    my $set2 = $set->find( name => { like => 'joe' } );
    is_deeply $set2->query, { id => { '!=' => 1 }, name => { like => 'joe' } },
      'Combined statement #2';
}

done_testing();
