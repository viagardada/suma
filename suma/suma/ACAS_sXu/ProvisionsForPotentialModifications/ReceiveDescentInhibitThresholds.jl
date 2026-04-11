function ReceiveDescentInhibitThresholds(this::STM, h_lo_ft::R, h_hi_ft::R )
# Deviation potential: Refer to ACAS sXu MOPS Vol. I section 1
this.own.h_lo_ft[1] = h_lo_ft
this.own.h_hi_ft[1] = h_hi_ft
end
