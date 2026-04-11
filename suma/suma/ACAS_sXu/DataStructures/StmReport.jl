mutable struct StmReport
trm_input::TRMInput # Input to the TRM
own_v2v_osm::V2VOperationalStatusMessage # Ownship V2V operational status message
display::Vector{StmDisplayStruct} # Intruder data for the display
StmReport( trm_input::TRMInput, own_v2v_osm::V2VOperationalStatusMessage, display::Vector{StmDisplayStruct} ) = new( trm_input, v2v_osm, display)
StmReport() = new( TRMInput(), V2VOperationalStatusMessage(), StmDisplayStruct[] )
end
