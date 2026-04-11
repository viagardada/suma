mutable struct IntruderExternalValidation
adsb_validated::Bool # Validated flag of the ADS-B track
v2v_validated::Bool # Validated flag of the V2V track
agt_tracks_validated::Vector{AgtExternalValidation}
# validated flags for each of the AGT tracks
IntruderExternalValidation() = new(false, false, AgtExternalValidation[])
end
