"""Check the real branch is untouched and the counterfactual safely rejoins."""
import unittest
import numpy as np

from encounter_3d_demo import (ActionTable,Config,DEFAULT_TABLE,
    build_encounter,intruder_actual,plan_route,route_candidate,bump)


class DemoTests(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        cls.table=ActionTable(DEFAULT_TABLE)
        cls.config=Config()
        cls.data=build_encounter(cls.table,cls.config)

    def test_actual_branch_keeps_straight_line_and_cpa(self):
        d,c=self.data,self.config
        np.testing.assert_allclose(d.own[:,0],0)
        np.testing.assert_allclose(d.own[:,2],c.altitude)
        np.testing.assert_allclose(d.own[:,1],np.minimum(c.speed*d.time,c.destination))
        self.assertEqual(d.report()['actual_min_distance'],0)
        self.assertEqual(d.report()['actual_closest_time'],15)
        self.assertGreater(d.route.trigger_time,0)
        self.assertEqual(d.queries[np.searchsorted(d.time,d.route.trigger_time)].action,d.route.action)

    def test_no_plan_motion_before_advisory_and_exact_rejoin(self):
        d,c=self.data,self.config
        before=d.time<d.route.trigger_time
        np.testing.assert_allclose(d.hypothetical[before],d.own[before])
        p=d.route.positions([d.route.rejoin_time,d.route.time[-1]],c)
        np.testing.assert_allclose(p[0],[0,d.route.rejoin_y,c.altitude],atol=1e-8)
        np.testing.assert_allclose(p[1],[0,c.destination,c.altitude],atol=1e-8)
        after=d.hypothetical[d.time>=d.route.rejoin_time]
        np.testing.assert_allclose(after[:,0],0,atol=1e-8)
        np.testing.assert_allclose(after[:,2],c.altitude,atol=1e-8)
        self.assertGreater(d.route.time[-1],c.destination/c.speed)

    def test_all_phases_obey_demo_clearance_and_motion_limits(self):
        r,c=self.data.route,self.config
        t=np.arange(r.trigger_time+.01,r.time[-1]-.01,.02)
        pos=r.positions(t,c)
        rel=pos-intruder_actual(t,c)
        clearance=np.maximum(np.linalg.norm(rel[:,:2],axis=1)/c.horizontal_margin,
                             np.abs(rel[:,2])/c.vertical_margin)
        self.assertGreaterEqual(clearance.min(),1.09)
        velocity=np.gradient(pos,t,axis=0)
        self.assertLessEqual(np.linalg.norm(velocity[:,:2],axis=1).max(),c.speed*1.001)
        self.assertLessEqual(np.abs(velocity[:,2]).max(),c.max_vertical_rate*1.001)
        heading=np.unwrap(np.arctan2(velocity[:,0],velocity[:,1]))
        turn=np.gradient(heading,t)
        self.assertLessEqual(np.max(np.abs(turn[5:-5])),np.deg2rad(c.max_turn_rate)*1.02)
        h,v=r.action
        if h==2:self.assertGreaterEqual(r.xyz[:,0].min(),-1e-9)
        if h==3:self.assertLessEqual(r.xyz[:,0].max(),1e-9)
        if v in (4,6):self.assertGreaterEqual(r.xyz[:,2].min(),c.altitude-1e-9)
        if v in (5,7):self.assertLessEqual(r.xyz[:,2].max(),c.altitude+1e-9)

    def test_unknown_record_stays_unknown(self):
        table=ActionTable.__new__(ActionTable)
        table.rows={}
        result=table.query(np.array([0,0,1000.]),np.array([0,6000,1000.]),self.config)
        self.assertIsNone(result.action)
        self.assertFalse(result.maneuver)

    def test_return_is_tangent_and_curvature_matches_original_line(self):
        r,c=self.data.route,self.config
        index=np.argmin(np.abs(r.time-r.rejoin_time))
        np.testing.assert_allclose(r.velocity[index,[0,2]],0,atol=1e-12)
        self.assertGreater(r.velocity[index,1],0)
        peak_y=float(np.interp(r.peak_time,r.time,r.xyz[:,1]))
        return_y=float(np.interp(r.return_time,r.time,r.xyz[:,1]))
        value,first,second=bump(np.array([r.rejoin_y]),r.xyz[0,1],peak_y,return_y,r.rejoin_y)
        np.testing.assert_allclose([value,first,second],0,atol=1e-12)
        # Verify the interpolated, displayed path approaches that same tangent.
        p=r.positions([r.rejoin_time-.01,r.rejoin_time,r.rejoin_time+.01],c)
        direction=p[1]-p[0]
        self.assertLess(np.linalg.norm(direction[[0,2]])/direction[1],1e-6)
        np.testing.assert_allclose(p[2,[0,2]],[0,c.altitude],atol=1e-10)

    def test_search_prioritizes_smaller_lateral_deviation(self):
        r,c=self.data.route,self.config
        fixed=route_candidate(c,r.trigger_time,r.action,600,220,700,1800)
        self.assertGreater(r.feasible_candidates,1)
        self.assertGreater(np.max(np.abs(r.xyz[:,0])),0)
        self.assertLessEqual(np.max(np.abs(r.xyz[:,0])),200)
        self.assertLessEqual(np.max(np.abs(r.xyz[:,2]-c.altitude)),150)
        self.assertLess(np.max(np.abs(r.xyz[:,0])),np.max(np.abs(fixed.xyz[:,0])))

    def test_plan_and_join_remain_fixed_during_playback(self):
        r,c=self.data.route,self.config
        expected=r.xyz.copy()
        join=r.rejoin_y
        for t in np.linspace(r.trigger_time,r.time[-1],30):
            plan,join_y=r.planned_view(float(t),c)
            np.testing.assert_array_equal(plan,expected)
            self.assertEqual(join_y,join)
        self.assertEqual(self.data.report()['planning_runs'],1)

    def test_build_selects_complete_route_only_once(self):
        from unittest.mock import patch
        with patch('encounter_3d_demo.plan_route',wraps=plan_route) as planner:
            data=build_encounter(self.table,self.config)
            self.assertEqual(planner.call_count,1)
            np.testing.assert_array_equal(data.route.xyz,self.data.route.xyz)

    def test_left_descending_path_returns_without_crossing_ground(self):
        r=plan_route(self.config,6.3,(3,5))
        self.assertLess(r.xyz[:,0].min(),0)
        self.assertLess(r.xyz[:,2].min(),self.config.altitude)
        np.testing.assert_allclose(r.xyz[-1],[0,10000,1000])
        self.assertGreaterEqual(r.clearance_ratio,1.1)

    def test_viewer_pause_seek_speed_reset_and_return_display(self):
        from types import SimpleNamespace
        import matplotlib
        matplotlib.use('Agg')
        from encounter_3d_demo import DemoViewer
        viewer=DemoViewer(self.data,fps=10,playback=3)
        try:
            self.assertTrue(viewer.playing)
            viewer._toggle();self.assertFalse(viewer.playing)
            viewer._seek(self.data.route.rejoin_time+.1)
            self.assertTrue(viewer.plan_line.get_visible())
            self.assertIn('已接回',viewer.phase_text.get_text())
            viewer._speed();self.assertEqual(viewer.playback,4)
            viewer._scroll(SimpleNamespace(inaxes=viewer.ax,button='up'))
            self.assertGreater(viewer.zoom,1)
            viewer._reset();self.assertEqual(viewer.t,0)
            self.assertFalse(viewer.plan_line.get_visible())
            viewer._toggle();self.assertTrue(viewer.playing)
        finally:
            viewer.plt.close(viewer.fig)


if __name__=='__main__':
    unittest.main()
