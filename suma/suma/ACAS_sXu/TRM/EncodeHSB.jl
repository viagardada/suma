function EncodeHSB(this::TRM, hrc::UInt32, chc::UInt32 )
X_parity_table::Vector{Z} = this.params["coordination"]["parity_table_hor"]
hsb::UInt32 = UInt32( X_parity_table[ (chc * 8) + hrc + 1 ] )
return hsb::UInt32
end
