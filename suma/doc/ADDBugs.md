# Bugs found in ACAS sXu 4.0 ADD
In the order as found.

1. The 2nd constructor (ln. 17) of `HTRMDisplayData` is unused and invalid, missing initialization of `trm_velmode` and `horizontal_desensitivity_mode`.
2. The following variables are missing type definitions:
    1. `H_separation_min_m` in `CalculatePolicyState` (ln. 3).
    2. `D_horiz_target_separation`, `T_min_tau` and `T_max_tau` in `PointObstacleTauEstimation` (ln. 2–4).
3. Some of the params values are specified as decimals, though should be integers.
4. The 2nd constructor (ln. 31) of `TRMOwnInput` is invalid and unused, missing initialization of `agt_ids`.
5. The 4th constructor (ln. 47) of `TRMIntruderInput` is invalid and unused, invoking a non-existent `CCCB()` constructor. This also causes the 5th constructor (ln. 52) to be invalid.
6. The `RefineOwnshipAGL` refers to non-existing constants and structure members and isn't referenced anywhere. Is it supposed to be removed?
7. Setting the `multihreat_turn_from_maintain_hold` in `HorizontalMultiThreatTurnFromMaintainCost` (ln. 21 and 24) doesn't seem to have any effect. Is the value supposed to propagate to the caller?

# Bugs found in ACAS sXu 4.2 ADD
1. Paramsfile contains new parameters which are not documented:
* `AGTcrossthrlo`, `AGTcrossthrhi`, `V2Vlargecrossthrlo`, `V2Vlargecrossthrhi`, `V2Vsmallcrossthrlo` and `V2Vsmallcrossthrhi` in `trm.params.display`.
