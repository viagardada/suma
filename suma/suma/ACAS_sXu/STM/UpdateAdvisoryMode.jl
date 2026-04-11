function UpdateAdvisoryMode(this::STM)
if (this.own.discrete.opflg == false) || (this.own.discrete.requested_opmode == OPMODE_STANDBY)
this.own.opmode = OPMODE_STANDBY
elseif (this.own.discrete.requested_opmode == OPMODE_SURV_ONLY)
this.own.opmode = OPMODE_SURV_ONLY
else
this.own.opmode = OPMODE_RA
end
return
end
