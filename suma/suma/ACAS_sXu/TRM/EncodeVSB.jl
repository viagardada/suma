function EncodeVSB(this::TRM, vrc::UInt32, cvc::UInt32 )
X_parity_table::Vector{Z} = this.params["coordination"]["parity_table_vert"]
vsb::UInt32 = UInt32( X_parity_table[ (cvc * 4) + vrc + 1 ] )
return vsb::UInt32
end
