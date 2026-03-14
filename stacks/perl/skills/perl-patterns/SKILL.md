# Perl Patterns

## Modern Perl with Moo/Moose

```perl
use v5.36;
use Moo;
use Types::Standard qw(Str Int ArrayRef InstanceOf);

# Moo class with type constraints
package User {
    use Moo;
    use Types::Standard qw(Str Int);

    has name  => (is => 'ro', isa => Str, required => 1);
    has email => (is => 'ro', isa => Str, required => 1);
    has age   => (is => 'rw', isa => Int, default => 0);

    sub greeting ($self) {
        return "Hello, " . $self->name;
    }
}

# Roles (like interfaces/traits)
package Printable {
    use Moo::Role;
    requires 'to_string';

    sub print_self ($self) {
        say $self->to_string;
    }
}

package Invoice {
    use Moo;
    with 'Printable';

    has amount => (is => 'ro', isa => Int, required => 1);

    sub to_string ($self) {
        return sprintf("Invoice: \$%d", $self->amount);
    }
}
```

## Regex Mastery

```perl
use v5.36;

# Named captures for readability
my $log_pattern = qr/
    ^(?<timestamp>\d{4}-\d{2}-\d{2}T[\d:]+)
    \s+(?<level>INFO|WARN|ERROR)
    \s+\[(?<module>[^\]]+)\]
    \s+(?<message>.+)$
/x;

if ($line =~ $log_pattern) {
    say "Level: $+{level}, Module: $+{module}";
}

# Non-destructive substitution with /r
my $cleaned = $input =~ s/\s+/ /gr =~ s/^\s+|\s+$//gr;

# Lookahead and lookbehind
my @amounts = $text =~ /(?<=\$)\d+(?:\.\d{2})?/g;

# Multi-line matching
my @functions = $source =~ /^sub\s+(\w+)/gm;
```

## References and Dereferencing

```perl
use v5.36;

# Array and hash references
my $users = [
    { name => "Alice", age => 30 },
    { name => "Bob",   age => 25 },
];

# Postfix dereferencing (modern syntax)
for my $user ($users->@*) {
    say "$user->{name} is $user->{age} years old";
}

# Nested data structure access
my $config = {
    database => {
        host => "localhost",
        ports => [5432, 5433],
    },
};
my $primary_port = $config->{database}{ports}[0];

# Hash slices
my %user = (name => "Alice", age => 30, role => "admin");
my @important = @user{qw(name role)};
```

## CPAN Patterns

```perl
use v5.36;

# HTTP with HTTP::Tiny (core module)
use HTTP::Tiny;
use JSON::MaybeXS qw(decode_json encode_json);

my $http = HTTP::Tiny->new(timeout => 10);
my $resp = $http->get("https://api.example.com/data");
die "Request failed: $resp->{status}" unless $resp->{success};
my $data = decode_json($resp->{content});

# Path handling with Path::Tiny
use Path::Tiny;
my $config = path("config.json")->slurp_utf8;
path("output")->mkpath;
path("output/result.txt")->spew_utf8($result);

# Database with DBI
use DBI;
my $dbh = DBI->connect("dbi:Pg:dbname=mydb", $user, $pass, {
    RaiseError => 1,
    AutoCommit => 1,
});
my $sth = $dbh->prepare("SELECT * FROM users WHERE age > ?");
$sth->execute(18);
while (my $row = $sth->fetchrow_hashref) {
    say "$row->{name}: $row->{age}";
}
```

## Error Handling

```perl
use v5.36;
use Feature::Compat::Try;

# Structured try/catch
try {
    my $result = risky_operation();
    process($result);
}
catch ($e) {
    if (ref $e eq 'HASH' && $e->{code} == 404) {
        warn "Not found: $e->{message}";
    } else {
        die $e;  # re-throw
    }
}

# Die with structured errors
sub find_user ($id) {
    my $user = $db->fetch_user($id)
        or die { code => 404, message => "User $id not found" };
    return $user;
}

# Guard clauses
sub process_order ($order) {
    die "Order required"          unless defined $order;
    die "Order must have items"   unless $order->{items}->@*;
    die "Order already processed" if $order->{status} eq 'done';
    # ... process
}
```

## Subroutine Signatures and Functional Patterns

```perl
use v5.36;
use List::Util qw(reduce any all none sum);

# Subroutine signatures (v5.36+)
sub greet ($name, $greeting = "Hello") {
    return "$greeting, $name!";
}

# Functional patterns with List::Util
my @evens = grep { $_ % 2 == 0 } @numbers;
my @doubled = map { $_ * 2 } @numbers;
my $total = sum @amounts;

my $has_admin = any { $_->{role} eq 'admin' } @users;

# Chained transformations
my @result = sort { $a->{name} cmp $b->{name} }
             grep { $_->{active} }
             map  { process_user($_) }
             @raw_users;
```

## Testing with Test2

```perl
use v5.36;
use Test2::V0;

# Basic assertions
is(add(2, 3), 5, "addition works");
ok(is_valid($input), "input is valid");
like($output, qr/success/i, "output indicates success");

# Exception testing
my $err = dies { find_user(-1) };
like($err, qr/not found/i, "dies on invalid user");

# Subtest grouping
subtest "User validation" => sub {
    ok(validate_email('user@example.com'), "valid email passes");
    ok(!validate_email('invalid'), "invalid email fails");
};

# Mocking
use Test2::Mock;
my $mock = Test2::Mock->new(class => 'HTTP::Tiny');
$mock->override(get => sub { { success => 1, content => '{"ok":true}' } });

done_testing;
```
