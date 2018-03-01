# --
# Copyright (C) 2012-2018 Znuny GmbH, http://znuny.com/
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (AGPL). If you
# did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
# --

package Kernel::Language::de_Znuny4OTRSShowPendingTimeIfNeeded;

use strict;
use warnings;

use utf8;

sub Data {
    my $Self = shift;

    $Self->{Translation}->{'This configuration registers an OutputFilter module that injects the javascript functionality to remove PendingTime.'} = 'Diese Konfiguration registriert ein Outputfilter, um die Erinnerungszeit via Javascript auszublenden.';
    $Self->{Translation}->{'List of JS files to always be loaded for the agent interface.'} = 'Liste von JS-Dateien, die immer für den Agenten-Interfaace geladen werden.';

    return 1;
}

1;
