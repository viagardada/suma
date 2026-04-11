# Complete ACAS sXu module.
# Algorithms are in ADD order, data structures in reversed ADD order,
# unless reordered to satisfy dependencies.
#
# Whole file by HON.

module ACAS_sXu
    # Required for diagm (potentially more)
    using LinearAlgebra

    # The name of the top module, so it can be removed from stringified
    # type names.
    MODULE_NAME = "ACAS_sXu"

    # Type aliases.
    include("Aliases.jl")

    # Constants.
    include("ConstantVariables/constants.jl")
    include("ConstantVariables/GeoUtils.jl")

    # Commonly used utilities.
    geoutils = GeoUtils()

    # All data structures.
    include("DataStructures/IntruderIDEntry.jl")
    include("DataStructures/IntruderIDDirectory.jl")
    include("DataStructures/AgtAltType.jl")
    include("DataStructures/AgtExternalValidation.jl")
    include("DataStructures/InternalVertTrackAltType.jl")
    include("DataStructures/IntruderExternalValidation.jl")
    include("DataStructures/StmDisplayStruct.jl")
    include("DataStructures/IntruderVerticalBelief.jl")
    include("DataStructures/IntruderHorizontalBelief.jl")
    include("DataStructures/CCCB.jl")
    include("DataStructures/TRMIntruderInput.jl")
    include("DataStructures/OwnVerticalBelief.jl")
    include("DataStructures/TRMOwnInput.jl")
    include("DataStructures/TRMInput.jl")
    include("DataStructures/V2VOperationalStatusMessage.jl")
    include("DataStructures/StmReport.jl")
    include("DataStructures/TrackFile.jl")
    include("DataStructures/TrackSummary.jl")
    include("DataStructures/ORNCTTrackFile.jl")
    include("DataStructures/ADSBTrackFile.jl")
    include("DataStructures/AGTTrackFile.jl")
    include("DataStructures/PointObstacleTrackFile.jl")
    include("DataStructures/V2VTrackFile.jl")
    include("DataStructures/CorrelationHistory.jl")
    include("DataStructures/DesignationState.jl")
    include("DataStructures/OwnDiscreteData.jl")
    include("DataStructures/GeodeticStates.jl")
    include("DataStructures/ValueTime.jl")
    include("DataStructures/OwnHistory.jl")
    include("DataStructures/OwnShipData.jl")
    include("DataStructures/ReceivedCoordinationData.jl")
    include("DataStructures/PriorityCodes.jl")
    include("DataStructures/ADSBOperationalStatusMessage.jl")
    include("DataStructures/Target.jl")
    include("DataStructures/Database.jl")
    include("DataStructures/TrackMap.jl")
    include("DataStructures/TRMIntruderDisplayData.jl")
    include("DataStructures/DisplayLogic.jl")
    include("DataStructures/VTRMDisplayData.jl")
    include("DataStructures/HTRMIntruderDisplayData.jl")
    include("DataStructures/HorizontalDisplayLogic.jl")
    include("DataStructures/HTRMDisplayData.jl")
    include("DataStructures/TRMLogicModeData.jl")
    include("DataStructures/TRMIntruderDesignationData.jl")
    include("DataStructures/TRMDesignationData.jl")
    include("DataStructures/TIDAltRngBrg.jl")
    include("DataStructures/sXuTRMBroadcastData.jl")
    include("DataStructures/TRMAlertingData.jl")
    include("DataStructures/TRMCoordinationData.jl")
    include("DataStructures/sXuTRMReport.jl")
    include("DataStructures/VTRMRAData.jl")
    include("DataStructures/IntruderPublishedRaState.jl")
    include("DataStructures/IndividualAdvisory.jl")
    include("DataStructures/AdvisoryBeliefState.jl")
    include("DataStructures/paramsfile_type.jl")
    include("DataStructures/AltitudeInhibitCState.jl")
    include("DataStructures/AdvisoryRestartCState.jl")
    include("DataStructures/InitializationCState.jl")
    include("DataStructures/RestrictCOCCState.jl")
    include("DataStructures/MaxReversalCState.jl")
    include("DataStructures/ResponseEstimationCState.jl")
    include("DataStructures/CompatibilityCState.jl")
    include("DataStructures/SA01HeuristicCState.jl")
    include("DataStructures/BadTransitionCState.jl")
    include("DataStructures/CrossingNoAlertCState.jl")
    include("DataStructures/PreventEarlyCOCCState.jl")
    include("DataStructures/CoordinatedRADeferralCState.jl")
    include("DataStructures/AltitudeDependentCOCCState.jl")
    include("DataStructures/SafeCrossingRADeferralCState.jl")
    include("DataStructures/CriticalIntervalProtectionCState.jl")
    include("DataStructures/TimeBasedNonComplianceCState.jl")
    include("DataStructures/CoordinationDelayCState.jl")
    include("DataStructures/OnlineCostState.jl")
    include("DataStructures/ActionArbitrationCState.jl")
    include("DataStructures/TRMIntruderState.jl")
    include("DataStructures/GlobalAdvisory.jl")
    include("DataStructures/VerticalRAOutputState.jl")
    include("DataStructures/MultithreatCostBalancingCState.jl")
    include("DataStructures/ActionArbitrationGlobalCState.jl")
    include("DataStructures/TRMOwnState.jl")
    include("DataStructures/TRMState.jl")
    include("DataStructures/EnuPositionVelocity.jl")
    include("DataStructures/EnuBelief.jl")
    include("DataStructures/EnuBeliefSet.jl")
    include("DataStructures/HTRMIntruderState.jl")
    include("DataStructures/HorizontalAdvisory.jl")
    include("DataStructures/HTRMOwnState.jl")
    include("DataStructures/HTRMState.jl")
    include("DataStructures/sXuTRMState.jl")
    include("DataStructures/CombinedVerticalBelief.jl")
    include("DataStructures/HTRMReport.jl")
    include("DataStructures/PolicyStateBelief.jl")
    include("DataStructures/PolicyUInt8DataTable.jl")
    include("DataStructures/RDataTable.jl")
    include("DataStructures/RDataTableScaled.jl")
    include("DataStructures/TauBelief.jl")
    include("DataStructures/TRMIndivAdjustState.jl")
    include("DataStructures/TRMIntruderData.jl")
    include("DataStructures/VTRMReport.jl")
    include("DataStructures/TRMOfflineTable.jl")
    include("DataStructures/TRMOwnStateDeviation.jl")
    include("DataStructures/TRMOwnInputDeviation.jl")
    include("DataStructures/OnlineCostStateDeviation.jl")

    # DataTable Format Specification.
    include("DataTableFormatSpecification/LoadDataTables.jl")

    # Parameter File Specification.
    include("ParameterFileSpecification/LoadParams.jl")

    # ValidationUpdate logged data.
    mutable struct AVUpdateLogData
        mu_hor_s::Vector{R}
        Sigma_hor_s::Matrix{R}
        mu_vert_s_1::R
    end

    # Predicted trackers data.
    mutable struct TrackerPredictionLogData
        track_time::R
        modes::UInt32
        id::UInt32
        source::Z
        mu::Union{Vector{R}, Nothing}
        inflated_sigma::Union{Matrix{R}, Nothing}
        mu_hor_pol::Union{Vector{R}, Nothing}
        sigma::Union{Matrix{R}, Nothing}

        function TrackerPredictionLogData(track_time::R, modes::UInt32, id::UInt32, source::Z)
            new(track_time, modes, id, source, nothing, nothing, nothing, nothing)
        end
    end

    # STM global context.
    mutable struct STM
        params::paramsfile_type
        own::OwnShipData
        target_db::Database{UInt32, Target}

        loggedAVUpdate::Union{AVUpdateLogData, Nothing}
        loggedTrackerPreditions::Array{TrackerPredictionLogData}

        function STM(paramsFilePath::String)
            new(
                LoadSTMParams(paramsFilePath),
                OwnShipData(),
                Database{UInt32, Target}(convert(UInt32, 0)),
                nothing,
                [])
        end

        # Construct using an existing context instance to avoid re-loading params.
        function STM(stm::STM)
            new(
                stm.params,
                OwnShipData(),
                Database{UInt32, Target}(convert(UInt32, 0)),
                nothing,
                [])
        end
    end

    # TauEstimation logged data.
    mutable struct TauEstimationLogData
        address::UInt32
        tau::Vector{TauBelief}
    end

    # TRM logged itemized intruder costs.
    mutable struct ItemizedOnlineCostsLogData
        is_point_obs::Bool
        point_obs_descend_cost::Array{R}
        point_obs_prevent_early_coc_cost::Array{R}
        time_based_non_compliance::Array{R}
        coord_ra_deferral::Array{R}
        max_reversal::Array{R}
        prevent_early_weakening::Array{R}
        SA01::Array{R}
        bad_transition::Array{R}
        restrict_coc_due_to_reversal::Array{R}
        safe_crossing_ra_deferral::Array{R}
        critical_interval_protection::Array{R}
        advisory_restart::Array{R}
        altitude_dependent_coc::Array{R}
        compatibility::Array{R}
        coord_delay::Array{R}
        initialization::Array{R}
        C_force_alert::Array{R}
        prevent_early_coc::Array{R}
        crossing_no_alert::Array{R}
        C_restrict_mtlo::R # MTLO action only.

        function ItemizedOnlineCostsLogData(numberOfActions::UInt32)
            new(
                false,
                zeros(numberOfActions),
                zeros(numberOfActions),
                zeros(numberOfActions),
                zeros(numberOfActions),
                zeros(numberOfActions),
                zeros(numberOfActions),
                zeros(numberOfActions),
                zeros(numberOfActions),
                zeros(numberOfActions),
                zeros(numberOfActions),
                zeros(numberOfActions),
                zeros(numberOfActions),
                zeros(numberOfActions),
                zeros(numberOfActions),
                zeros(numberOfActions),
                zeros(numberOfActions),
                zeros(numberOfActions),
                zeros(numberOfActions),
                zeros(numberOfActions),
                0.0)
        end
    end

    # TRM logged intruder costs.
    mutable struct IntruderMultithreatCostsLogData
        sandwich_prevention::Union{Array{R}, Nothing}
        C_restrict_mtlo::R # MTLO action only.

        function IntruderMultithreatCostsLogData()
            new(
                nothing,
                0.0)
        end
    end

    # TRM logged intruder costs.
    # Costs for each action.
    mutable struct IntruderCostsLogData
        id::UInt32
        id_directory::IntruderIDDirectory
        offline::Array{R}
        total::Array{R}
        online_itemized::ItemizedOnlineCostsLogData
        online::Array{R}
        online_subset::Array{R}
        multithreat::Union{IntruderMultithreatCostsLogData, Nothing}

        function IntruderCostsLogData(id::UInt32, id_directory::IntruderIDDirectory, numberOfActions::UInt32)
            new(
                id,
                id_directory,
                zeros(numberOfActions),
                zeros(numberOfActions),
                ItemizedOnlineCostsLogData(numberOfActions),
                zeros(numberOfActions),
                zeros(numberOfActions),
                nothing)
        end
    end

    # TRM logged horizontal costs.
    mutable struct StateDependentOnlineCostsType
        crossing_cost_factors::Array{R}

        function StateDependentOnlineCostsType(numberOfHorizontalActions::UInt32)
            new(
                zeros(numberOfHorizontalActions))
        end
    end

    # TRM logged horizontal costs.
    mutable struct intruders_item
        id::UInt32
        id_directory::IntruderIDDirectory
        offline_costs::Union{Array{R}, Nothing}
        stateDependentOnlineCosts::Union{StateDependentOnlineCostsType, Nothing}

        function intruders_item()
            new(
                0,
                IntruderIDDirectory(),
                nothing,
                nothing)
        end
    end

    # TRM logged horizontal costs.
    mutable struct project_times_item
        combined::Union{Array{R}, Nothing}
        project_time::R
        intruders::Array{intruders_item}

        function project_times_item(_project_time::R)
            new(
                nothing,
                _project_time,
                [])
        end
    end

    # TRM logged horizontal costs.
    mutable struct DetermineDAAGuidanceItem
        delta_track_angle_rad::R
        project_times::Array{project_times_item}

        function DetermineDAAGuidanceItem(_delta_track_angle_rad::R)
            new(
                _delta_track_angle_rad,
                [])
        end
    end

    # TRM logged horizontal costs.
    mutable struct HorizontalCostFusionType
        combined::Array{R}
        individual::Array{intruders_item}

        function HorizontalCostFusionType(numberOfHorizontalActions::UInt32)
            new(
                zeros(numberOfHorizontalActions),
                [])
        end
    end

    # TRM logged horizontal costs.
    mutable struct ApplyHorizontalOnlineCostsType
        coordinationCost::Array{R}
        desensitivityCost::Array{R}
        initialCACost::Array{R}
        multiThreatReversalCost::Array{R}
        reversalCost::Array{R}
        coordinatedReversalCost::Array{R}
        turnRateSensitivityCostFactor::Array{R}
        forceAlertCost::Array{R}
        weakeningCostFactor::Array{R}
        horizontalMaintainHeadingIncentive::Array{R}
        horizontalInitialMaintainCost::Array{R}
        horizontalTurnFromMaintainIncentive::Array{R}

        function ApplyHorizontalOnlineCostsType(numberOfHorizontalActions::UInt32)
            new(
                zeros(numberOfHorizontalActions),
                zeros(numberOfHorizontalActions),
                zeros(numberOfHorizontalActions),
                zeros(numberOfHorizontalActions),
                zeros(numberOfHorizontalActions),
                zeros(numberOfHorizontalActions),
                zeros(numberOfHorizontalActions),
                zeros(numberOfHorizontalActions),
                zeros(numberOfHorizontalActions),
                zeros(numberOfHorizontalActions),
                zeros(numberOfHorizontalActions),
                zeros(numberOfHorizontalActions))
        end
    end

    # TRM logged horizontal costs.
    mutable struct SelectHorizontalAdvisoryItem
        t_lookahead::R
        combined::Array{R}
        horizontalCostFusion::HorizontalCostFusionType
        applyHorizontalOnlineCosts::ApplyHorizontalOnlineCostsType

        function SelectHorizontalAdvisoryItem(numberOfHorizontalActions::UInt32)
            new(
                0.0,
                zeros(numberOfHorizontalActions),
                HorizontalCostFusionType(numberOfHorizontalActions),
                ApplyHorizontalOnlineCostsType(numberOfHorizontalActions))
        end
    end

    # TRM logged costs.
    mutable struct TRMCostsLogData
        individual::Array{IntruderCostsLogData}
        unequippedCostFusion::Union{Array{R}, Nothing}
        prioritizeAndFilterIntruders::Array{intruders_item}
        selectHorizontalAdvisory::Array{SelectHorizontalAdvisoryItem}

        function TRMCostsLogData()
            new(
                [],
                nothing,
                [],
                [])
        end
    end

    # TRM global context.
    mutable struct TRM
        params::paramsfile_type

        # STM context for UpdateIntruderVRC/HRC callbacks from TRM.
        stm::STM

        loggedTauEstimations::Array{TauEstimationLogData}
        loggedCosts::TRMCostsLogData
        loggedCurrentIntruderIdx::UInt32
        loggedCurrentAction::UInt32
        costLogMode::UInt8

        function TRM(paramsFilePath::String, stm::STM)
            params = LoadTRMParams(paramsFilePath)
            new(
                params,
                stm,
                [],
                TRMCostsLogData(),
                0,
                0,
                CLM_PrioritizeAndFilterIntruders)
        end

        # Construct using an existing context instance to avoid re-loading params and tables.
        function TRM(trm::TRM, stm::STM)
            new(
                trm.params,
                stm,
                [],
                TRMCostsLogData(),
                0,
                0,
                CLM_PrioritizeAndFilterIntruders,
                false)
        end
    end

    # Provisions For Potential Modifications.
    include("ProvisionsForPotentialModifications/DetermineVerticalRADataDeviation.jl")
    include("ProvisionsForPotentialModifications/GetVTRMOwnDataDeviation.jl")
    include("ProvisionsForPotentialModifications/IntruderPrepDeviation.jl")
    include("ProvisionsForPotentialModifications/OnlineUncoordinatedActionCostEstimationDeviation.jl")
    include("ProvisionsForPotentialModifications/ReceiveDescentInhibitThresholds.jl")
    include("ProvisionsForPotentialModifications/ReceiveTargetDesignation.jl")
    include("ProvisionsForPotentialModifications/SetOwnshipDataDeviation.jl")
    include("ProvisionsForPotentialModifications/SetRABroadcastDataDeviation.jl")
    include("ProvisionsForPotentialModifications/StmHousekeepingTargetDesignation.jl")
    include("ProvisionsForPotentialModifications/VerticalTRMUpdatePrepDeviation.jl")

    # Math Utilities.
    include("MathUtilities/AngleDifference.jl")
    include("MathUtilities/block_diag.jl")
    include("MathUtilities/eye.jl")
    include("MathUtilities/mahal.jl")
    include("MathUtilities/nanmin.jl")
    include("MathUtilities/nanmax.jl")
    include("MathUtilities/nanminimum.jl")
    include("MathUtilities/nanmaximum.jl")
    include("MathUtilities/Normalize.jl")
    include("MathUtilities/uchol.jl")
    include("MathUtilities/UnitVectorNormalize.jl")
    include("MathUtilities/WrapAngleDiffToPi.jl")
    include("MathUtilities/WrapTo2Pi.jl")
    include("MathUtilities/WrapToPi.jl")

    # Data Management Utilities.
    include("DataManagementUtilities/DetermineIntruderHorizontalValidity.jl")
    include("DataManagementUtilities/DetermineIntruderVerticalValidity.jl")
    include("DataManagementUtilities/ResetHorizontalTRMOwnshipState.jl")
    include("DataManagementUtilities/HorizontalTRMUpdatePrep.jl")
    include("DataManagementUtilities/VerticalTRMUpdatePrep.jl")

    # STM Housekeeping algorithms.
    include("STMHousekeeping/StmHousekeeping.jl")
    include("STMHousekeeping/StmHousekeepingPrioritization.jl")

    # Offline Table Scaling and Online Cost Index selection.
    include("OfflineTableScalingAndOnlineCostIndexSelection/CreateHorizontalScaledCutsSets.jl")
    include("OfflineTableScalingAndOnlineCostIndexSelection/CreateVerticalScaledCutsSets.jl")
    include("OfflineTableScalingAndOnlineCostIndexSelection/GetIndexFromClassification.jl")
    include("OfflineTableScalingAndOnlineCostIndexSelection/ScaleHorizontalCuts.jl")
    include("OfflineTableScalingAndOnlineCostIndexSelection/ScaleVerticalCuts.jl")

    # Correlation Processing Implementation algorithms.
    include("CorrelationProcessingImplementation/AddDecorrelatedTrackToTarget.jl")
    include("CorrelationProcessingImplementation/AGTOnlyTarget.jl")
    include("CorrelationProcessingImplementation/ConvertCartesianToPolar2D.jl")
    include("CorrelationProcessingImplementation/CorrelateByType.jl")
    include("CorrelationProcessingImplementation/CorrelateID.jl")
    include("CorrelationProcessingImplementation/CorrelateIndividualTracks.jl")
    include("CorrelationProcessingImplementation/CorrelateIndividualTracksToOwnship.jl")
    include("CorrelationProcessingImplementation/CorrelatePosition.jl")
    include("CorrelationProcessingImplementation/CorrelateTargets.jl")
    include("CorrelationProcessingImplementation/CorrelateTargetsToOwnship.jl")
    include("CorrelationProcessingImplementation/CorrelateToOwnshipByType.jl")
    include("CorrelationProcessingImplementation/CorrelationHistoryCheck.jl")
    include("CorrelationProcessingImplementation/CorrelationHistoryUpdate.jl")
    include("CorrelationProcessingImplementation/CorrelationTrackType.jl")
    include("CorrelationProcessingImplementation/DecorrelateTargets.jl")
    include("CorrelationProcessingImplementation/DecorrelateTargetsFromOwnship.jl")
    include("CorrelationProcessingImplementation/ExtrapolateADSBTrack.jl")
    include("CorrelationProcessingImplementation/ExtrapolateAGTTrack.jl")
    include("CorrelationProcessingImplementation/ExtrapolateORNCTTrack.jl")
    include("CorrelationProcessingImplementation/ExtrapolateOwnshipTrack.jl")
    include("CorrelationProcessingImplementation/ExtrapolateTrack.jl")
    include("CorrelationProcessingImplementation/ExtrapolateV2VTrack.jl")
    include("CorrelationProcessingImplementation/GenerateLeadTrackList.jl")
    include("CorrelationProcessingImplementation/GetAircraftTracks.jl")
    include("CorrelationProcessingImplementation/GetCorrelationMechanism.jl")
    include("CorrelationProcessingImplementation/GetTracksToDecorrelate.jl")
    include("CorrelationProcessingImplementation/GetTracksToExtrapolate.jl")
    include("CorrelationProcessingImplementation/LinearTransform.jl")
    include("CorrelationProcessingImplementation/MergeTargets.jl")
    include("CorrelationProcessingImplementation/PredictTrackSummary.jl")
    include("CorrelationProcessingImplementation/RemoveDecorrelatedTrackFromOwnship.jl")
    include("CorrelationProcessingImplementation/RemoveDecorrelatedTrackFromTarget.jl")
    include("CorrelationProcessingImplementation/SetDualADSBOutWithV2VUID.jl")
    include("CorrelationProcessingImplementation/SingleNARCorrelationAuthorized.jl")
    include("CorrelationProcessingImplementation/SortByRange.jl")
    include("CorrelationProcessingImplementation/WeightedMeanAndCovariance.jl")

    # STM algorithms.
    include("STM/AbsoluteGeodeticToOwnshipRelative.jl")
    include("STM/AddADSBTrackToDB.jl")
    include("STM/AddADSBTrackToReport.jl")
    include("STM/AddAGTTrackToDB.jl")
    include("STM/AddAGTTrackToReport.jl")
    include("STM/AddAltBiasAndSample.jl")
    include("STM/AddHorBias.jl")
    include("STM/AddORNCTTrackToDB.jl")
    include("STM/AddORNCTTrackToReport.jl")
    include("STM/AddPointObstacleTrackToDB.jl")
    include("STM/AddPointObstacleTrackToReport.jl")
    include("STM/AddToDB.jl")
    include("STM/AddTracksToReport.jl")
    include("STM/AddV2VTrackToDB.jl")
    include("STM/AddV2VTrackToReport.jl")
    include("STM/AdvanceOwnHAETrack.jl")
    include("STM/AdvancePassiveTrackPosition.jl")
    include("STM/AdvancePassiveTrackState.jl")
    include("STM/AdvancePassiveTrackVelocity.jl")
    include("STM/AdvanceVerticalTrack.jl")
    include("STM/AlignAltitudeTypesUsedInGeodeticPositions.jl")
    include("STM/AssembleAGTTrack.jl")
    include("STM/AssessVerticalValidity.jl")
    include("STM/AssociateADSBReportToTarget.jl")
    include("STM/AssociateAGTToOwnship.jl")
    include("STM/AssociateAGTToTarget.jl")
    include("STM/AssociateORNCTIdToTarget.jl")
    include("STM/AssociatePointObstacleReportToTarget.jl")
    include("STM/AssociateV2VToTarget.jl")
    include("STM/AssociateV2VToV2VAndAGTTargets.jl")
    include("STM/CalculateOwnshipVelocityOffsets.jl")
    include("STM/CheckORNCTUncertainty.jl")
    include("STM/CheckTrackStatus.jl")
    include("STM/CompareIntruderRange.jl")
    include("STM/ConvertECEFToWGS84.jl")
    include("STM/ConvertGeodeticToOrthometricHeight.jl")
    include("STM/ConvertGVAToSigmaVEPU.jl")
    include("STM/ConvertNACpToSigmaHEPU.jl")
    include("STM/ConvertNACvToSigmaHVA.jl")
    include("STM/ConvertOrthometricToGeodeticHeight.jl")
    include("STM/ConvertVFOMToSigmaVEPU.jl")
    include("STM/ConvertWGS84ToECEF.jl")
    include("STM/CoordinationTimeoutCheck.jl")
    include("STM/CorrelationProcessing.jl")
    include("STM/DeleteAGTTrack.jl")
    include("STM/DeleteIntent.jl")
    include("STM/DetermineORNCTDeletion.jl")
    include("STM/ECEFToENURotation.jl")
    include("STM/ENUToECEFRotation.jl")
    include("STM/FilterTracksForTRM.jl")
    include("STM/GenerateStmReport.jl")
    include("STM/GetAltForHorTrkObservation.jl")
    include("STM/GetEarthRadiusAtLatitude.jl")
    include("STM/GetGroundSpeed.jl")
    include("STM/GetNormalGravityAtLatitude.jl")
    include("STM/GetPresAEMSigma.jl")
    include("STM/GetPreviouslySelectedTrack.jl")
    include("STM/GetRelativeAltitude.jl")
    include("STM/GetSwitchingAltitudeType.jl")
    include("STM/GetVerticalOutlierParams.jl")
    include("STM/HAEAltAtToa.jl")
    include("STM/HeadingAtToa.jl")
    include("STM/InflatePassiveHorSigmaUL.jl")
    include("STM/InitializeHeadingTracker.jl")
    include("STM/InitializeOwnVerticalTracker.jl")
    include("STM/InitializePassiveTrackerPosition.jl")
    include("STM/InitializePassiveTrackFile.jl")
    include("STM/InitializeVerticalTracker.jl")
    include("STM/IsAGTOutlier.jl")
    include("STM/IsOutlier.jl")
    include("STM/IsTrackAltitudeReporting.jl")
    include("STM/IsTrackValidated.jl")
    include("STM/MatrixRotation.jl")
    include("STM/OffsetTracksByOwnshipTurn.jl")
    include("STM/OptimalPreTrackedTracks.jl")
    include("STM/OptimalQualityTrack.jl")
    include("STM/OptimalTrackHistoryUpdate.jl")
    include("STM/OwnWgs84Timeout.jl")
    include("STM/ParseORNCTStatus.jl")
    include("STM/PassiveQualityCheck.jl")
    include("STM/PolarAlignmentHorizontalRotation.jl")
    include("STM/Predict1DKalmanFilter.jl")
    include("STM/Predict2DKalmanFilter.jl")
    include("STM/PredictedAltitude.jl")
    include("STM/PredictKalmanFilter.jl")
    include("STM/PredictORNCTTrack.jl")
    include("STM/PredictPassiveTracker.jl")
    include("STM/PredictPreTrackedTrack.jl")
    include("STM/PredictVerticalTracker.jl")
    include("STM/PresAltAtToa.jl")
    include("STM/PropagateGeodeticToToa.jl")
    include("STM/PropagateOwnshipToToa.jl")
    include("STM/RASorting.jl")
    include("STM/ReceiveAbsoluteGeodeticTrack.jl")
    include("STM/ReceiveADSBOperationalStatusMessage.jl")
    include("STM/ReceiveDiscretes.jl")
    include("STM/ReceiveExternallyValidatedADSB.jl")
    include("STM/ReceiveExternallyValidatedV2V.jl")
    include("STM/ReceiveHeadingObservation.jl")
    include("STM/ReceiveHeightAglObservation.jl")
    include("STM/ReceiveModeStatusReport.jl")
    include("STM/ReceiveOwnRelNonCoopTrack.jl")
    include("STM/ReceivePointObstacleReport.jl")
    include("STM/ReceivePresAltObservation.jl")
    include("STM/ReceiveStateVectorPositionReport.jl")
    include("STM/ReceiveStateVectorUatReport.jl")
    include("STM/ReceiveStateVectorV2VReport.jl")
    include("STM/ReceiveStateVectorVelocityReport.jl")
    include("STM/ReceiveTrueAirspeedObservation.jl")
    include("STM/ReceiveV2VCoordination.jl")
    include("STM/ReceiveV2VOperationalStatusMessage.jl")
    include("STM/ReceiveWgs84Observation.jl")
    include("STM/ReCenterHorizontalTrackLocation.jl")
    include("STM/RedefineEstimateInRotatedFrame.jl")
    include("STM/RefineECEFAndLLA.jl")
    include("STM/RemoveStaleADSBTrack.jl")
    include("STM/RemoveStaleAGTTracks.jl")
    include("STM/RemoveStaleORNCTTrack.jl")
    include("STM/RemoveStaleTracks.jl")
    include("STM/RemoveStaleV2VTrack.jl")
    include("STM/RetrieveWithID.jl")
    include("STM/RotateECEFToENU.jl")
    include("STM/RotateENUToECEF.jl")
    include("STM/RotateHorizontalFrame.jl")
    include("STM/SelectFinalTrack.jl")
    include("STM/SetAvailableSources.jl")
    include("STM/SetClassification.jl")
    include("STM/SetCoordination.jl")
    include("STM/SetDisplayDataORNCT.jl")
    include("STM/SetDisplayDataPassive.jl")
    include("STM/SetExternalValidationFlags.jl")
    include("STM/SetInternalVertTrackAltType.jl")
    include("STM/SetIntruderBeliefStates.jl")
    include("STM/SetIntruderDegradedFlags.jl")
    include("STM/SetIntruderIDDirectory.jl")
    include("STM/SetOwnshipData.jl")
    include("STM/SetOwnshipDegradedFlags.jl")
    include("STM/SetOwnshipVelocity.jl")
    include("STM/SetOwnV2VOperationalStatusMessage.jl")
    include("STM/SigmaPointSample.jl")
    include("STM/SlantRange.jl")
    include("STM/SplitSortedIndexByClassification.jl")
    include("STM/SurroundingPoints.jl")
    include("STM/TargetIsEmpty.jl")
    include("STM/TrackExists.jl")
    include("STM/TrackSourceSelection.jl")
    include("STM/UpdateAdvisoryMode.jl")
    include("STM/UpdateAGTTrack.jl")
    include("STM/UpdateAltInHorGeoPos.jl")
    include("STM/UpdateHeadingTracker.jl")
    include("STM/UpdateHistory.jl")
    include("STM/UpdateHorizontalVelocityMode.jl")
    include("STM/UpdateIntruderHRC.jl")
    include("STM/UpdateIntruderVRC.jl")
    include("STM/UpdateKalmanFilter.jl")
    include("STM/UpdateORNCTTrack.jl")
    include("STM/UpdatePassiveQualityHistory.jl")
    include("STM/UpdatePassiveTrackerPosition.jl")
    include("STM/UpdatePassiveTrackerState.jl")
    include("STM/UpdatePassiveTrackerVelocity.jl")
    include("STM/UpdateVerticalTracker.jl")
    include("STM/ValidationCheck.jl")
    include("STM/ValidCovarianceMatrix.jl")
    include("STM/VerticalRateArrowUpdate.jl")

    # TRM algorithms.
    include("TRM/ActionArbitration.jl")
    include("TRM/ActionSelection.jl")
    include("TRM/ActionToRates.jl")
    include("TRM/AdjustDisplayDataForDroppedIntruder.jl")
    include("TRM/AdjustRAModeIntruderOutput.jl")
    include("TRM/AdvisoryRestartCost.jl")
    include("TRM/AllowUnequippedMTLO.jl")
    include("TRM/AltitudeDependentCOCCost.jl")
    include("TRM/AltitudeInhibitCost.jl")
    include("TRM/ApplyHorizontalCoordinationHysteresis.jl")
    include("TRM/ApplyHorizontalOnlineCosts.jl")
    include("TRM/ApplyStateDependentOnlineCosts.jl")
    include("TRM/ArbitrateConflictingSenses.jl")
    include("TRM/ArbitrateMatchingSenses.jl")
    include("TRM/BadMaintainTransitionCost.jl")
    include("TRM/BadTransitionCost.jl")
    include("TRM/CalculateCrossingCostPsiFactor.jl")
    include("TRM/CalculateCrossingCostSpeedFactor.jl")
    include("TRM/CalculateCrossingCostThetaFactor.jl")
    include("TRM/CalculateCrossingCostVerticalTauFactor.jl")
    include("TRM/CalculatePolicyState.jl")
    include("TRM/CalculateThresholdRampDownFactor.jl")
    include("TRM/CalculateThresholdRampUpFactor.jl")
    include("TRM/CalculateUncoordinatedCosts.jl")
    include("TRM/CoastEnuBeliefBasedOnIndividualSamples.jl")
    include("TRM/CoastEnuPositionVelocity.jl")
    include("TRM/CombineVerticalBeliefs.jl")
    include("TRM/CompatibilityCost.jl")
    include("TRM/Consistent.jl")
    include("TRM/Consistent271.jl")
    include("TRM/ConvertHorizontal.jl")
    include("TRM/ConvertIntruderInputsToEnuBeliefs.jl")
    include("TRM/ConvertOwnInputsToEnuBeliefs.jl")
    include("TRM/ConvertOwnInputsToEnuBeliefsGroundAndCompassMix.jl")
    include("TRM/ConvertOwnInputsToEnuBeliefsWindRelative.jl")
    include("TRM/CoordinatedRADeferralCost.jl")
    include("TRM/CoordinationDelayCost.jl")
    include("TRM/CoordinationSelection.jl")
    include("TRM/CreateGroundIntruder.jl")
    include("TRM/CreatePolicyStateBeliefs.jl")
    include("TRM/CriticalIntervalProtectionCost.jl")
    include("TRM/CriticalIntervalRequiresVerticalDivergence.jl")
    include("TRM/CrossingNoAlertCost.jl")
    include("TRM/Crosslink.jl")
    include("TRM/DetermineAltitudeDependentCOCFactor.jl")
    include("TRM/DetermineCode.jl")
    include("TRM/DetermineConflictingSenses.jl")
    include("TRM/DetermineCrossing.jl")
    include("TRM/DetermineDimensionalRAState.jl")
    include("TRM/DetermineDisplayData.jl")
    include("TRM/DetermineDisplayTrackAngleAndTurnRate.jl")
    include("TRM/DetermineGroundAlert.jl")
    include("TRM/DetermineHorizontalCode.jl")
    include("TRM/DetermineHorizontalDesensitivity.jl")
    include("TRM/DetermineHorizontalScore.jl")
    include("TRM/DetermineHorizontalWorstCaseNearMeanFactor.jl")
    include("TRM/DetermineHorizontalWorstCasePhiSpreadFactor.jl")
    include("TRM/DetermineLabel271.jl")
    include("TRM/DetermineLDI.jl")
    include("TRM/DetermineMinimumCostAction.jl")
    include("TRM/DetermineMultidimensionalMultithreat.jl")
    include("TRM/DetermineMultiIntruderAction.jl")
    include("TRM/DetermineOwnNonComplianceFactor.jl")
    include("TRM/DetermineResponse.jl")
    include("TRM/DetermineSenses.jl")
    include("TRM/DetermineStateDependentSpeedFactor.jl")
    include("TRM/DetermineTauVerticalDistribution.jl")
    include("TRM/DetermineTID.jl")
    include("TRM/DetermineVerticalProximateFactor.jl")
    include("TRM/DetermineVerticalRAData.jl")
    include("TRM/DetermineVerticalRateReductionFactor.jl")
    include("TRM/DetermineVerticalScore.jl")
    include("TRM/DiscretizePolicyState.jl")
    include("TRM/DisplayLogicDetermination.jl")
    include("TRM/DroppedIntrudersAdjustment.jl")
    include("TRM/EncodeCHC.jl")
    include("TRM/EncodeCVC.jl")
    include("TRM/EncodeHRC.jl")
    include("TRM/EncodeHSB.jl")
    include("TRM/EncodeTIDAltitude.jl")
    include("TRM/EncodeTIDBearing.jl")
    include("TRM/EncodeTIDRange.jl")
    include("TRM/EncodeVRC.jl")
    include("TRM/EncodeVSB.jl")
    include("TRM/EnuBeliefEstimation.jl")
    include("TRM/ExpectedTau.jl")
    include("TRM/FindCompliantRateDelta.jl")
    include("TRM/FindHighestThreatIndex.jl")
    include("TRM/FindMaximumWeightAndIndex.jl")
    include("TRM/GenerateBlendedsXuTRMOutput.jl")
    include("TRM/GenerateHTRMOutput.jl")
    include("TRM/GenerateRAModeOutput.jl")
    include("TRM/GenerateStandbyModeOutput.jl")
    include("TRM/GenerateSurvOnlyModeOutput.jl")
    include("TRM/GenerateVTRMOutput.jl")
    include("TRM/GetCutpointIndexVector.jl")
    include("TRM/GetEntryDistributionTables.jl")
    include("TRM/GetEquivClassTableMaxCutValues.jl")
    include("TRM/GetHorizontalCoordinationOffsetFactor.jl")
    include("TRM/GetHorizontalCoordinationPolicy.jl")
    include("TRM/GetHorizontalPolicyCosts.jl")
    include("TRM/GetMatchingLabel270Rule.jl")
    include("TRM/GetMaxApplicabilityRange.jl")
    include("TRM/GetModifiedGlobalRates.jl")
    include("TRM/GetOfflineCostTauBeliefs.jl")
    include("TRM/GetOwnHeight.jl")
    include("TRM/GetOwnWeightedAverages.jl")
    include("TRM/GetPerformanceBasedParams.jl")
    include("TRM/GetPerformanceBasedTableIndex.jl")
    include("TRM/GetPolicyTableCosts.jl")
    include("TRM/GetTableMaxCutValue.jl")
    include("TRM/GetVTRMOwnData.jl")
    include("TRM/GroundPointObstacleTauEstimation.jl")
    include("TRM/HorizontalActionToRate.jl")
    include("TRM/HorizontalAlertLookahead.jl")
    include("TRM/HorizontalCoordinatedReversalCost.jl")
    include("TRM/HorizontalCoordinationCost.jl")
    include("TRM/HorizontalCoordinationSelection.jl")
    include("TRM/HorizontalCostFusion.jl")
    include("TRM/HorizontalDesensitivityCost.jl")
    include("TRM/HorizontalDisplayLogicDetermination.jl")
    include("TRM/HorizontalForceAlertCost.jl")
    include("TRM/HorizontalInitialCACost.jl")
    include("TRM/HorizontalInitialMaintainCost.jl")
    include("TRM/HorizontalMaintainHeadingIncentive.jl")
    include("TRM/HorizontalMultiThreatMaintainHeadingCost.jl")
    include("TRM/HorizontalMultiThreatReversalCost.jl")
    include("TRM/HorizontalMultiThreatTurnFromMaintainCost.jl")
    include("TRM/HorizontalRateToAction.jl")
    include("TRM/HorizontalRateToAdvisory.jl")
    include("TRM/HorizontalRateToSense.jl")
    include("TRM/HorizontalReversalCost.jl")
    include("TRM/HorizontalStateEstimation.jl")
    include("TRM/HorizontalTrackThreatAssessment.jl")
    include("TRM/HorizontalTRMUpdate.jl")
    include("TRM/HorizontalTurnFromMaintainIncentive.jl")
    include("TRM/HorizontalTurnRateSensitivityCostFactor.jl")
    include("TRM/HorizontalWeakeningCostFactor.jl")
    include("TRM/HorizontalWorstCase.jl")
    include("TRM/HRCToAdvisory.jl")
    include("TRM/IndividualCostEstimation.jl")
    include("TRM/IndividualSelectionCostEstimation.jl")
    include("TRM/InitializationCost.jl")
    include("TRM/Interpolants.jl")
    include("TRM/InterpolateBlocks.jl")
    include("TRM/InterpolateOneDimension.jl")
    include("TRM/IntruderPrep.jl")
    include("TRM/IntruderResponseEstimation.jl")
    include("TRM/IsCOC.jl")
    include("TRM/IsCorrective.jl")
    include("TRM/IsCrossing.jl")
    include("TRM/IsDiverging.jl")
    include("TRM/IsDNC.jl")
    include("TRM/IsDND.jl")
    include("TRM/IsHorizontalCOC.jl")
    include("TRM/IsHorizontalMaintain.jl")
    include("TRM/IsHorizontalReversal.jl")
    include("TRM/IsHorizontalWeakening.jl")
    include("TRM/IsIntruderEquipped.jl")
    include("TRM/IsIntruderInScope.jl")
    include("TRM/IsIntruderMaster.jl")
    include("TRM/IsMaintain.jl")
    include("TRM/IsMasterForcingReversal.jl")
    include("TRM/IsMTLO.jl")
    include("TRM/IsOutsideCriticalInterval.jl")
    include("TRM/IsPreventive.jl")
    include("TRM/IsProjectedCrossing.jl")
    include("TRM/IsReversal.jl")
    include("TRM/IsSlowClosure.jl")
    include("TRM/IsStrengthening.jl")
    include("TRM/IsVerticallyConverging.jl")
    include("TRM/IsWithinRateBounds.jl")
    include("TRM/LookupEntryDistribution.jl")
    include("TRM/LookupOfflineCost.jl")
    include("TRM/MaintainRates.jl")
    include("TRM/MaxReversalCost.jl")
    include("TRM/MinCostIndex.jl")
    include("TRM/ModifyPolicySpeedBinsIndividual.jl")
    include("TRM/MTLOAction.jl")
    include("TRM/MTLODetermination.jl")
    include("TRM/MultithreatCostBalancing.jl")
    include("TRM/NoIntrudersAction.jl")
    include("TRM/OfflineCostEstimation.jl")
    include("TRM/OfflineStatesScaleFactor.jl")
    include("TRM/OnlineCoordinatedActionCostEstimation.jl")
    include("TRM/OnlineCostEstimation.jl")
    include("TRM/OnlineUncoordinatedActionCostEstimation.jl")
    include("TRM/OnlineUncoordinatedCostEstimation.jl")
    include("TRM/OwnResponseEstimation.jl")
    include("TRM/PersistMTLO.jl")
    include("TRM/PointObsDescendCost.jl")
    include("TRM/PointObsPreventEarlyCOCCost.jl")
    include("TRM/PointObstacleEnuBeliefEstimation.jl")
    include("TRM/PointObstacleTauEstimation.jl")
    include("TRM/PreventEarlyCOCCost.jl")
    include("TRM/PreventEarlyWeakeningCost.jl")
    include("TRM/PrioritizeAndFilterIntruders.jl")
    include("TRM/RatesToAction.jl")
    include("TRM/RatesToSense.jl")
    include("TRM/ResetHTRMState.jl")
    include("TRM/RestrictCOCDueToReversal.jl")
    include("TRM/SA01Heuristic.jl")
    include("TRM/SafeCrossingRADeferralCost.jl")
    include("TRM/SandwichPreventionCost.jl")
    include("TRM/SelectAndModifyPolicyBins.jl")
    include("TRM/SelectHorizontalAdvisory.jl")
    include("TRM/SelectHorizontalAlertLookaheadAction.jl")
    include("TRM/SelectScaledPolicyBins.jl")
    include("TRM/SetAHRAReportData.jl")
    include("TRM/SetBeliefBasedOnlineCostState.jl")
    include("TRM/SetBlendedCoordinationData.jl")
    include("TRM/SetBlendedIntruderThreatData.jl")
    include("TRM/SetDroppedIntruder.jl")
    include("TRM/SetHorizontalDroppedIntruderOutput.jl")
    include("TRM/SetHorizontalIntruderOutput.jl")
    include("TRM/SetHorizontalTRMSurvOnlyMode.jl")
    include("TRM/SetIntruderVerticalScores.jl")
    include("TRM/SetInvalidIntruder.jl")
    include("TRM/SetPrevHorizontalTerminationData.jl")
    include("TRM/SetPrevVerticalTerminationData.jl")
    include("TRM/SetRABroadcastData.jl")
    include("TRM/SetRaPublishedState.jl")
    include("TRM/SetReportDataOnRATerm.jl")
    include("TRM/SetReportRATerminationBits.jl")
    include("TRM/SetThreatIdentityData.jl")
    include("TRM/SetVerticalRAMessageOutput.jl")
    include("TRM/SetVerticalTRMSurvOnlyMode.jl")
    include("TRM/ShouldReverse.jl")
    include("TRM/StateAndCostEstimation.jl")
    include("TRM/StateDependentCrossingCostFactors.jl")
    include("TRM/StateEstimation.jl")
    include("TRM/sXuTRMBlendedReportPrep.jl")
    include("TRM/sXuTRMUpdate.jl")
    include("TRM/TauEstimation.jl")
    include("TRM/TimeBasedNonComplianceCost.jl")
    include("TRM/TRMIntruderStateUpdate.jl")
    include("TRM/TurnEnuBeliefBasedOnIndividualSamples.jl")
    include("TRM/TurnEnuPositionVelocity.jl")
    include("TRM/UnequippedCostFusion.jl")
    include("TRM/UpdateAdvisoryRestartCState.jl")
    include("TRM/UpdateAltitudeInhibitCState.jl")
    include("TRM/UpdateBadTransitionCState.jl")
    include("TRM/UpdateCompatibilityCState.jl")
    include("TRM/UpdateCoordinatedRADeferralCState.jl")
    include("TRM/UpdateCoordinationDelayCState.jl")
    include("TRM/UpdateCriticalIntervalProtectionCState.jl")
    include("TRM/UpdateCrossingNoAlertCState.jl")
    include("TRM/UpdateEnuBeliefs.jl")
    include("TRM/UpdateHTRMIntruderInputs.jl")
    include("TRM/UpdateHTRMIntruderState.jl")
    include("TRM/UpdateHTRMIntruderStates.jl")
    include("TRM/UpdateIndivAdjustCounts.jl")
    include("TRM/UpdateIndivAdjustThreatInfo.jl")
    include("TRM/UpdateInitializationCState.jl")
    include("TRM/UpdateIntruderInputs.jl")
    include("TRM/UpdateMaxReversalCState.jl")
    include("TRM/UpdateNumHorizontalReversals.jl")
    include("TRM/UpdatePolicySpeedBinIndividual.jl")
    include("TRM/UpdatePolicySpeedBins.jl")
    include("TRM/UpdatePreventEarlyCOCCState.jl")
    include("TRM/UpdateRaPubState.jl")
    include("TRM/UpdateRestrictCOCDueToReversalCState.jl")
    include("TRM/UpdateSA01HeuristicCState.jl")
    include("TRM/UpdateSafeCrossingRADeferralCState.jl")
    include("TRM/UpdateTargetTrackAngle.jl")
    include("TRM/UpdateTimeBasedNonComplianceCState.jl")
    include("TRM/VerticalTRMUpdate.jl")
    include("TRM/VRCToSense.jl")
end
