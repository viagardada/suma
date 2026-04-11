mutable struct IntruderHorizontalBelief
x_rel::R # E/W component of position relative to own ship (ft)
y_rel::R # N/S component of position relative to own ship (ft)
dx_rel::R # E/W component of velocity relative to own ship (ft/s)
dy_rel::R # N/S component of velocity relative to own ship (ft/s)
weight::R # weight of this sample [0-1]
#
IntruderHorizontalBelief( x_rel::R, y_rel::R, dx_rel::R, dy_rel::R, w::R ) =
new( x_rel, y_rel, dx_rel, dy_rel, w )
IntruderHorizontalBelief() = new( 0.0, 0.0, 0.0, 0.0, 0.0 )
end
