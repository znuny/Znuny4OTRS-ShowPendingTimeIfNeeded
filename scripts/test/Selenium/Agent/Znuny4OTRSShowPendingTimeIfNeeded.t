# --
# Copyright (C) 2012-2018 Znuny GmbH, http://znuny.com/
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (AGPL). If you
# did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
# --

use strict;
use warnings;
use utf8;

use Kernel::System::VariableCheck qw(:all);

use vars (qw($Self));

# create configuration backup
$Kernel::OM->ObjectParamAdd(
    'Kernel::System::UnitTest::Helper' => {
        RestoreSystemConfiguration => 1,
    },
);

# get the Znuny4OTRS Selenium object
my $SeleniumObject = $Kernel::OM->Get('Kernel::System::UnitTest::Selenium');

# store test function in variable so the Selenium object can handle errors/exceptions/dies etc.
my $SeleniumTest = sub {

    # initialize Znuny4OTRS Helpers and other needed objects
    my $ZnunyHelperObject = $Kernel::OM->Get('Kernel::System::ZnunyHelper');
    my $HelperObject      = $Kernel::OM->Get('Kernel::System::UnitTest::Helper');
    my $StateObject       = $Kernel::OM->Get('Kernel::System::State');

    $ZnunyHelperObject->_PackageSetupInit();

    $HelperObject->ConfigSettingChange(
        Valid => 1,
        Key   => 'Ticket::Frontend::AgentTicketNote###State',
        Value => 1,
    );

    my %LoaderConfig = (
        AgentTicketPhone => [
            'Core.Form.Znuny4OTRSInput.js',
        ],
        AgentTicketEmail => [
            'Core.Form.Znuny4OTRSInput.js',
        ],
        AgentTicketNote => [
            'Core.Form.Znuny4OTRSInput.js',
        ],
    );

    my $Success = $ZnunyHelperObject->_LoaderAdd(%LoaderConfig);

    my @PendingStateIDs = $StateObject->StateGetStatesByType(
        StateType => [ 'pending reminder', 'pending auto' ],
        Result    => 'ID',
    );

    # create test user and login
    my %TestUser = $SeleniumObject->AgentLogin(
        Groups => ['users'],
    );

    my @Tests = (
        {
            Name => "Action - AgentTicketPhone",
            Data => {
                Action => 'AgentTicketPhone',
                State  => 'NextStateID',
            },
        },
        {
            Name => "Action - AgentTicketEmail",
            Data => {
                Action => 'AgentTicketEmail',
                State  => 'NextStateID',
            },
        },
        {
            Name => "Action - AgentTicketNote",
            Data => {
                Action => 'AgentTicketNote',
                State  => 'NewStateID',
                Ticket => 1,
            },
        },
    );

    TEST:
    for my $Test (@Tests) {

        my $DisabledElement;
        my $TicketID;

        if ( $Test->{Data}->{Ticket} ) {
            $TicketID = $HelperObject->TicketCreate();
        }

        # navigate to Admin page
        $SeleniumObject->AgentInterface(
            Action      => $Test->{Data}->{Action},
            TicketID    => $TicketID,
            WaitForAJAX => 0,
        );

        my $Element = $SeleniumObject->FindElementSave(
            Selector     => "#$Test->{Data}->{State}",
            SelectorType => 'css',
        );

        for my $Field (qw(Day Year Month Hour Minute)) {

            eval {
                $DisabledElement = $SeleniumObject->find_element( "#$Field", 'css' )->is_displayed();
            };
            $Self->False(
                $DisabledElement,
                "Checking for disabled element '$Field'",
            );
        }

        my $Result = $SeleniumObject->InputSet(
            Attribute   => $Test->{Data}->{State},
            Content     => $PendingStateIDs[0],
            WaitForAJAX => 0,
            Options     => {
                KeyOrValue => 'Key',
            },
        );

        $Self->True(
            $Result,
            "Change NextStateID successfully.",
        );

        next TEST if !$Result;

        for my $Field (qw(Day Year Month Hour Minute)) {

            $Self->True(
                $SeleniumObject->find_element( "#$Field", 'css' )->is_displayed(),
                "Checking for enabled element '$Field'",
            );
        }
    }
};

# finally run the test(s) in the browser
$SeleniumObject->RunTest($SeleniumTest);

1;
