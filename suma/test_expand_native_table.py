"""Checks for state discretisation, joint labels and restart-safe merging."""
import contextlib
import csv
import io
import json
import math
from pathlib import Path
import tempfile
from types import SimpleNamespace
import unittest

import expand_native_table as m
from priority_native_cases import encounter_geometry
from run_native_workers import ids_in
from fill_inner_ring import target_grid


class NativeTableTests(unittest.TestCase):
    def test_polar_view_does_not_invent_joint_advisories(self):
        import matplotlib
        matplotlib.use('Agg')
        import numpy as np
        from avoidance_polar_map import AvoidancePolarMap
        viewer=AvoidancePolarMap.__new__(AvoidancePolarMap)
        actions=[(2,5)]*4+[(3,4)]*3+[(4,4)]*2
        viewer.arr=np.array([[1000,0,0,-180,200,200,0,0,5,h,v] for h,v in actions],dtype=float)
        viewer.nR=viewer.nB=1
        viewer.ranges=np.array([1000]);viewer.bearings=np.array([0])
        viewer.sel={'range':0,'bearing':0}
        viewer._filter_mask=lambda:np.ones(len(actions),dtype=bool)
        viewer.aggregate()
        h,v,n,fh,fv=viewer.current_pair()
        self.assertEqual((h,v,n),(2,5,9))
        self.assertAlmostEqual(fh,4/9)
        self.assertAlmostEqual(fv,4/9)

    def test_inner_ring_grid_uses_real_speed_pairs_and_limits_range(self):
        manifest={'grid':[[100,1000,1500],[0],[-180,0],[-180,0],
                          [100,200],[100,200],[0],[0]]}
        cells,pairs=target_grid(manifest)
        self.assertEqual(len(cells),120)
        self.assertEqual(len(set(cells)),120)
        self.assertEqual({p[0] for p in cells},{100,1000})
        self.assertEqual(pairs[1.0],(100,100))
        for ratio,(vi,vo) in pairs.items():
            self.assertEqual(round(vo/vi,6),ratio)

    def test_worker_resume_rejects_duplicate_and_truncated_records(self):
        with tempfile.TemporaryDirectory() as temp:
            path=Path(temp)/'samples.jsonl'
            self.assertEqual(ids_in(path),set())
            path.write_text('{"id": 1}\n{"id": 2}\n',encoding='utf-8')
            self.assertEqual(ids_in(path),{1,2})
            path.write_text('{"id": 1}\n{"id": 1}\n',encoding='utf-8')
            with self.assertRaises(ValueError): ids_in(path)
            path.write_text('{"id": 1}\n{"id":',encoding='utf-8')
            with self.assertRaises(json.JSONDecodeError): ids_in(path)

    def test_collision_screening_uses_relative_velocity_and_vertical_motion(self):
        result = encounter_geometry([1000,100,0,-180,200,200,0,-40])
        self.assertAlmostEqual(result['cpa_time'],2.5)
        self.assertAlmostEqual(result['horizontal_cpa_ft'],0)
        self.assertAlmostEqual(result['vertical_at_cpa_ft'],0)
        self.assertAlmostEqual(result['tau'],2.5)
        crossing = encounter_geometry([1000,0,-90,90,200,200,0,0])
        self.assertAlmostEqual(crossing['horizontal_cpa_ft'],math.sqrt(500000))
        self.assertIsNone(encounter_geometry([1000,0,0,0,400,200,0,0]))
        self.assertIsNone(encounter_geometry([1000,0,0,0,200,200,0,0]))

    def test_discretization_boundaries(self):
        key = m.discretize([42,-149,180,359,201,349,-14,16,-1])
        self.assertEqual(key,(100,-100,-180,0,200,350,-10,20,-1))
        self.assertEqual(m.discretize([800,0,0,0,200,200,0,0,2])[8],5)
        self.assertEqual(m.discretize([2400,0,0,0,200,200,0,0,999])[8],100)

    def test_joint_mode_resume_and_legacy_preservation(self):
        with tempfile.TemporaryDirectory() as temp:
            work = Path(temp)
            table = work/'legacy.csv'
            state = [1000,0,0,-180,200,200,0,0,5]
            with table.open('w',newline='',encoding='utf-8') as f:
                w = csv.writer(f); w.writerow(m.FIELDS)
                w.writerow([*state,'H:0 | V:0'])
                w.writerow([3000,200,0,0,150,150,0,0,-1,'H:0 | V:0'])
            # H and V marginal modes would create the absent pair (2,4).
            actions = [[2,5]]*4 + [[3,4]]*3 + [[4,4]]*2
            case = dict(id=7,samples=[dict(state=state,action=a) for a in actions])
            (work/'native_samples.jsonl').write_text(json.dumps(case)+'\n',encoding='utf-8')
            args = SimpleNamespace(work=work,table=table,install=False)
            original = table.read_bytes()
            with contextlib.redirect_stdout(io.StringIO()):
                m.merge(args)
                first = (work/'expanded_table.csv').read_bytes()
                m.merge(args)
            self.assertEqual(first,(work/'expanded_table.csv').read_bytes())
            self.assertEqual(original,table.read_bytes())
            rows = list(csv.DictReader(io.StringIO(first.decode())))
            self.assertEqual(rows[0]['Recommended_Action'],'H:2 | V:5')
            self.assertEqual(len(rows),2)
            self.assertEqual(json.loads((work/'coverage_report.json').read_text())['completed_cases'],1)


if __name__ == '__main__':
    unittest.main()
