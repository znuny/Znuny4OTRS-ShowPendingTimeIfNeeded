// --
// Copyright (C) 2012-2015 Znuny GmbH, http://znuny.com/
// --
// This software comes with ABSOLUTELY NO WARRANTY. For details, see
// the enclosed file COPYING for license information (AGPL). If you
// did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
// --

"use strict";

var Core   = Core       || {};
Core.Agent = Core.Agent || {};

/**
 * @namespace
 * @exports TargetNS as Core.Agent.Znuny4OTRSShowPendingTimeIfNeeded
 * @description
 *      This namespace contains the special module functions for Znuny4OTRSShowPendingTimeIfNeeded.
 */
Core.Agent.Znuny4OTRSShowPendingTimeIfNeeded = (function (TargetNS) {
    var PendingStates = [];
    TargetNS.Init = function ( Param ) {

        var ParamCheckSuccess = true;
        $.each( [ 'PendingStates' ], function (Index, ParameterName) {
            if ( !Param[ ParameterName ] ) {
                ParamCheckSuccess = false;
            }
        });
        if ( !ParamCheckSuccess ) {
            return false;
        }
        PendingStates = Param.PendingStates;
        $('#NextStateID, #NewStateID, #StateID, #ComposeStateID').on('change', TargetNS.TogglePendingState);


        TargetNS.TogglePendingState();

        return true;
    }

    TargetNS.TogglePendingState = function () {

        var StateID = $('#NextStateID, #NewStateID, #StateID, #ComposeStateID').val();
        if ( $.inArray( StateID, PendingStates ) === -1 ) {
            $('#Month').parent().prev().hide();
            $('#Month').parent().hide();
        }
        else {
            $('#Month').parent().prev().show();
            $('#Month').parent().show();
        }
        return true;
    }

    return TargetNS;
}(Core.Agent.Znuny4OTRSShowPendingTimeIfNeeded || {}));
