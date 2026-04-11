# Verification notes

The official ACAS sXu V4R0 Test Suite has been used to verify sUMA with the `TestSuiteTest` unit test.

Several relaxations had to be applied to deal with the reduced STM precision, especially when the intruder horizontal position and speed is close to zero. These relaxations have been implemented as comparisons with the difference below a specific absolute threshold. The affected fields are intruder horizontal beliefs, and intruder display horizontal speed and bearing. The rest of the entries use significant figures for comparison. The chosen comparison precision values are below the minimum prescribed by MOPS. These STMReport differences are minor and do not affect the final TRM results.

Intruder collections' order is ignored. Both the tested and reference lists are sorted by the intruder `id` before comparison. The reason for this behavior is that the reference collections have also been re-ordered. This shouldn't have any impact in the verification results.

Some differences in result precision have been observed between Windows and Linux platforms.

## STMReport modified by TRM
STM report generation code (`GenerateStmReport`) doesn't set the `trm_input.intruder[].vrc` and `.hrc` values. The values are set by TRM through `trm_input` structure passed from `StmReport`. This update is propagated to the original StmReport and then logged. Test Suite STMReport reference files contain `vrc` nad `hrc` values updated by TRM, so our implementation postpones logging of the `StmReport` after TRM execution. This behavior violates the STM and TRM separation and is probably unintentional.

## Empty horizontal costs
There are some cases where the `PrioritizeAndFilterIntruders` and the `SelectHorizontalAdvisory` sections are empty and reference cost file contains either empty `data_horiz` section (`PrioritizeAndFilterIntruders` and `SelectHorizontalAdvisory` missing) or `data_horiz` section with empty `PrioritizeAndFilterIntruders` and `SelectHorizontalAdvisory`. So the empty `PrioritizeAndFilterIntruders` and `SelectHorizontalAdvisory` and missing ones are considered equal.

## Incorrect `horizontal velocity mode (trm_velmode)` fail
This issue appears only in one test case (8420801). The cause of this issue was not found.

## Incorrect `classification` fails
The `classification` is read from the Input.json file. The `classification` is only copied without modification. Then it is stored to STM report. The Input.json files may contain incorrect value. This issue appears in three test cases (8421001, 8421002 and 8421003).
