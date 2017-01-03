# --
# Copyright (C) 2012-2017 Znuny GmbH, http://znuny.com/
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (AGPL). If you
# did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
# --

package Kernel::Output::HTML::OutputFilterPostZnuny4OTRSShowPendingTimeIfNeeded;

use strict;
use warnings;

our @ObjectDependencies = (
    'Kernel::Output::HTML::Layout',
    'Kernel::System::JSON',
    'Kernel::System::State',
);

sub new {
    my ( $Type, %Param ) = @_;

    # allocate new hash for object
    my $Self = {};
    bless( $Self, $Type );

    $Self->{Action} = $Param{Action} || '';

    return $Self;
}

sub Run {
    my ( $Self, %Param ) = @_;

    my $LayoutObject = $Kernel::OM->Get('Kernel::Output::HTML::Layout');
    my $JSONObject   = $Kernel::OM->Get('Kernel::System::JSON');
    my $StateObject  = $Kernel::OM->Get('Kernel::System::State');

    my @StateList = $StateObject->StateGetStatesByType(
        StateType => [ 'pending reminder', 'pending auto' ],
        Result    => 'ID',
    );

    my $StateListString = $JSONObject->Encode(
        Data => \@StateList,
    );

    my $JSBlock = <<"JS_BLOCK";
    Core.Agent.Znuny4OTRSShowPendingTimeIfNeeded.Init({ PendingStates : $StateListString });
JS_BLOCK

    my $Success = $LayoutObject->AddJSOnDocumentCompleteIfNotExists(
        Key  => 'Znuny4OTRSShowPendingTimeIfNeeded',
        Code => $JSBlock,
    );

    return 1;
}

1;
