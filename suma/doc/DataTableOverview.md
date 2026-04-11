# Used data tables

Table name (as referred by ADD), params entries and file names.

* Entry distribution tables (`modes[1].state_estimation.tau.entry_dist`)
    * Horizontal entry (distribution) table, (`horizontal_table`, `horizontal_active_table`)
        * "DO-396_entry_sxuvtrm_compressed.dat"
    * Vertical entry (distribution) table (`vertical_table`)
        * "DO-396_entry_vert_sxuvtrm_compressed.dat"
* Vertical offline cost tables, low performance (`modes[1].cost_estimation.offline.origami[1]`)
    * VTRM equivalence class cost table(s) (`equiv_class_table`)
        * "DO-396_q_sxuvtrm_500fpm_55ec_allSplits.dat"
    * VTRM minimum blocks index (MinBlocks) table (`minblocks_table`)
        * "DO-396_q_sxuvtrm_500fpm_55ec_minBlocks.dat"
* Vertical offline cost tables, high performance (`modes[1].cost_estimation.offline.origami[2]`)
    * VTRM equivalence class cost table(s) (`equiv_class_table`)
        * "DO-396_q_sxuvtrm_500_2000fpm_73ec_allSplits.dat"
    * VTRM minimum blocks index (MinBlocks) table (`minblocks_table`)
        * "DO-396_q_sxuvtrm_500_2000fpm_73ec_minBlocks.dat"
* Horizontal offline cost tables (`horizontal_trm.horizontal_offline.hcost_policy.origami`)
    * HTRM equivalence class cost table(s) (`equiv_class_table`)
        * "DO-396_q_sxuhtrm_16ec_allSplits_NoMB.dat"
    * HTRM minimum blocks index (MinBlocks) table (`minblocks_table`)
        * "DO-396_q_sxuhtrm_16ec_minBlocks_NoMB.dat"
* Horizontal coordination table (`horizontal_trm.horizontal_offline.hcoord_policy.hcoord_table`)
    * "DO-396_xuhtrm_coord_sxu.bin"

Tables composed of equivalence classes and minimum blocks use Origami compression.

Feet to meters conversions needs to be performed on the following tables:
* Horizontal entry (distribution) table
* Vertical entry (distribution) table
* VTRM equivalence class cost table
* HTRM equivalence class cost table
