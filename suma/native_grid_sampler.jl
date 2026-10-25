# Native STM/TRM sampling. No nearest-neighbour labels or pilot response.
using JSON
include(joinpath(@__DIR__, "suma", "ACAS_sXu", "ACAS_sXu.jl"))
using .ACAS_sXu
const A = ACAS_sXu

function state_values(input)
    isempty(input.intruder) && return nothing
    d = input.intruder[1].stm_display
    o = input.own
    d.bearing_valid || return nothing
    b, track = d.bearing_rel_rad, o.track_angle
    ve = d.dx_rel_fps + o.ground_speed*sin(track)
    vn = d.dy_rel_fps + o.ground_speed*cos(track)
    psi = atan(sin(atan(ve,vn)-track), cos(atan(ve,vn)-track))
    # Relative velocity is east/north; bearing is relative to own heading (0 here).
    radial = d.dx_rel_fps*sin(b) + d.dy_rel_fps*cos(b)
    tau = radial < -0.1 ? -d.r_ground_ft/radial : -1.0
    isempty(o.belief_vert) && return nothing
    own_dz = sum(v.dz*v.weight for v in o.belief_vert)
    values = [d.r_ground_ft, d.z_rel_ft, rad2deg(b), rad2deg(psi),
              hypot(ve,vn), o.ground_speed, own_dz,
              d.dz_rel_fps+own_dz, tau]
    all(isfinite, values) ? values : nothing
end

function simulate(c, template, trm, duration, warmup)
    stm = A.STM(template)
    trm.stm = stm
    empty!(trm.loggedTauEstimations)
    trm.loggedCosts = A.TRMCostsLogData()
    state = A.sXuTRMState()
    r,z,b,h,vi,vo,ov,iv = Float64.(c["initial"])
    east, north = r*sind(b), r*cosd(b)
    ie, inn = vi*sind(h), vi*cosd(h)
    # Local WGS84 tangent approximation, centred at latitude 0; all distances feet.
    feet_per_degree = 6378137.0 * A.geoutils.meters_to_feet * pi/180
    lat_scale = feet_per_degree*(1-A.geoutils.earth_first_eccentricity_sq)
    samples = Any[]
    for step in 0:(warmup+duration)
        dt = Float64(step-warmup)
        t = Float64(step+1)
        own_alt = 10000.0 + ov*dt
        int_alt = 10000.0 + z + iv*dt
        A.ReceiveDiscretes(stm,UInt128(111),true,UInt8(3),0.053,16.667,false,false,false,UInt8(15))
        A.ReceiveHeadingObservation(stm,0.0,t,false)
        A.ReceivePresAltObservation(stm,own_alt,t)
        A.ReceiveHeightAglObservation(stm,own_alt)
        A.ReceiveWgs84Observation(stm,vo*dt/lat_scale,0.0,0.0,vo/A.geoutils.kts_to_fps,
                                 own_alt,ov,UInt32(10),UInt32(3),8.0,t)
        A.ReceiveStateVectorV2VReport(stm,(north+inn*dt)/lat_scale,(east+ie*dt)/feet_per_degree,
            int_alt,int_alt,ie/A.geoutils.kts_to_fps,inn/A.geoutils.kts_to_fps,
            UInt32(7),UInt32(10),UInt32(3),8.0,UInt32(3),UInt32(1),UInt128(100),
            UInt32(100),false,true,UInt8(3),UInt32(1),t)
        # Uncoordinated intruder: do not invent coordination intent/sense messages.
        A.ReceiveExternallyValidatedV2V(stm,true,UInt128(100))
        report = A.GenerateStmReport(stm,t)
        values = state_values(report.trm_input)
        result = A.sXuTRMUpdate(trm,state,report.trm_input)
        if step >= warmup && values !== nothing
            push!(samples,Dict("time"=>dt,"state"=>values,
                  "action"=>[Int(result.display_horiz.cc),Int(result.display_vert.cc)]))
        end
        A.StmHousekeeping(stm,result)
    end
    samples
end

function main()
    cases, output, params = ARGS[1:3]
    duration, warmup = parse.(Int,ARGS[4:5])
    println("Loading native STM/TRM tables..."); flush(stdout)
    stm = A.STM(params)
    trm = A.TRM(params,stm)
    done = Set{String}()
    if isfile(output)
        for line in eachline(output)
            isempty(strip(line)) && continue
            push!(done,string(JSON.parse(line)["id"]))
        end
    end
    open(output,"a") do io
        for line in eachline(cases)
            c = JSON.parse(line)
            string(c["id"]) in done && continue
            started = time()
            samples = simulate(c,stm,trm,duration,warmup)
            isempty(samples) && error("No valid native samples for case $(c["id"])")
            JSON.print(io,Dict("id"=>c["id"],"initial"=>c["initial"],"samples"=>samples))
            write(io,'\n'); flush(io)
            println("case ",c["id"]," samples=",length(samples)," seconds=",round(time()-started,digits=3)); flush(stdout)
        end
    end
end
main()
