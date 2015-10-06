# --
# Kernel/Output/HTML/OutputFilterPostZnuny4OTRSShowPendingTimeIfNeeded.pm - Initing the javascript functionality to remove PendingTime.
# Copyright (C) 2015 Znuny GmbH, http://znuny.com/
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (AGPL). If you
# did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
# --

package Kernel::Output::HTML::OutputFilterPostZnuny4OTRSShowPendingTimeIfNeeded;

use strict;
use warnings;

our @ObjectDependencies = (
    'Kernel::System::JSON',
    'Kernel::System::State',
);

sub new {
    my ( $Type, %Param ) = @_;

    # allocate new hash for object
    my $Self = {};
    bless( $Self, $Type );

    # check needed objects
    # additional LayoutObject $Self params are present, see LayoutObject for more information
    NEEDED:
    for my $Needed (qw( LayoutObject )) {
        $Self->{$Needed} = $Param{$Needed} || die "Got no $Needed!";
    }

    $Self->{Action} = $Param{Action} || '';

    return $Self;
}

sub Run {
    my ( $Self, %Param ) = @_;

    my @StateList = $Kernel::OM->Get('Kernel::System::State')->StateGetStatesByType(
        StateType => ['pending reminder', 'pending auto'],
        Result    => 'ID',
    );

    
    my $StateListString = $Kernel::OM->Get('Kernel::System::JSON')->Encode(
        Data     => \@StateList,
    );

    my $JSBlock = <<"JS_BLOCK";
    Core.Agent.Znuny4OTRSShowPendingTimeIfNeeded.Init({ PendingStates : $StateListString });
JS_BLOCK

    $Self->AddJSOnDocumentCompleteIfNotExists(
        Key  => 'Znuny4OTRSShowPendingTimeIfNeeded',
        Code => $JSBlock,
    );

    return 1;
}

sub AddJSOnDocumentCompleteIfNotExists {
    my ( $Self, %Param ) = @_;

    # check needed stuff
    NEEDED:
    for my $Needed (qw(Key Code)) {

        next NEEDED if defined $Param{$Needed};

        $Self->{LogObject}->Log(
            Priority => 'error',
            Message  => "Parameter '$Needed' is needed!",
        );
        return;
    }

    my $Exists = 0;
    CODEJS:
    for my $CodeJS ( @{ $Self->{LayoutObject}->{_JSOnDocumentComplete} || [] } ) {

        next CODEJS if $CodeJS !~ m{ Key: \s $Param{Key}}xms;
        $Exists = 1;
        last CODEJS;
    }

    return 1 if $Exists;

    my $AddCode = "// Key: $Param{Key}\n" . $Param{Code};

    $Self->{LayoutObject}->AddJSOnDocumentComplete(
        Code => $AddCode,
    );

    return 1;
}

1;
