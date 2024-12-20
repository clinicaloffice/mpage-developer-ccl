/*************************************************************************
 
        Script Name:    1co3_mpage_encounter.prg
 
        Description:    Clinical Office - mPage Edition
        				Encounter Data Retrieval
 
        Date Written:   October 14, 2023
        Written by:     John Simpson
                        Precision Healthcare Solutions
 
 *************************************************************************
		   Copyright (c) 2023 Precision Healthcare Solutions
 
 NO PART OF THIS CODE MAY BE COPIED, MODIFIED OR DISTRIBUTED WITHOUT
 PRIOR WRITTEN CONSENT OF PRECISION HEALTHCARE SOLUTIONS EXECUTIVE
 LEADERSHIP TEAM.
 
 FOR LICENSING TERMS PLEASE VISIT www.clinicaloffice.com/mpage/license
 
 *************************************************************************
                            Special Instructions
 *************************************************************************
 Called from 1CO3_MPAGE_ENTRY. Do not attempt to run stand alone.
 
 Possible Payload values:
 
	"patientSource":[
		{"personId": value, "encntrId": value}
	],
	"encounter": {
    	"includeCodeValues": true,
		"aliases": true,
		"encounterInfo": true,
		"prsnlReltn": true,
		"locHist": true
	},
	"typeList": [
		{"codeSet": value, "type": "value", "typeCd": value}
	]
 
 
 
 *************************************************************************
                            Revision Information
 *************************************************************************
 Rev    Date     By             Comments
 ------ -------- -------------- ------------------------------------------
 001    14/10/23 J. Simpson     Initial Development
 002    13/12/23 J. Simpson     Added location level organization_id's
 003    06/15/23 J. Simpson     Set persist on record structure and allow skipping
                                of JSON content
 *************************************************************************/

drop program 1co3_mpage_encounter:group1 go
create program 1co3_mpage_encounter:group1

; Check to see if running from mPage entry script
if (validate(payload->encounter) = 0 or size(patient_source->visits, 5) = 0)
	go to end_program
endif

; Required variables
declare cParser = vc
declare nNum = i4
declare cString = vc

free record rEncounter
record rEncounter (
    1 encounters[*]
        2 encntr_id                     = f8
        2 person_id                     = f8
        2 encntr_class                  = vc
        2 encntr_type                   = vc
        2 encntr_type_class             = vc
        2 encntr_status                 = vc
        2 pre_reg_dt_tm                 = dq8
        2 pre_reg_prsnl_id              = f8
        2 reg_dt_tm                     = dq8
        2 reg_prsnl_id                  = f8
        2 est_arrive_dt_tm              = dq8
        2 est_depart_dt_tm              = dq8
        2 arrive_dt_tm                  = dq8
        2 depart_dt_tm                  = dq8
        2 admit_type                    = vc
        2 admit_src                     = vc
        2 admit_mode                    = vc
        2 disch_disposition             = vc
        2 disch_to_loctn                = vc
        2 readmit                       = vc
        2 accommodation                 = vc
        2 accommodation_request         = vc
        2 accommodation_reason          = vc
        2 ambulatory_cond               = vc
        2 courtesy                      = vc
        2 isolation                     = vc
        2 med_service                   = vc
        2 confid_level                  = vc
        2 vip                           = vc
        2 location                      = vc
        2 loc_facility                  = vc
        2 loc_building                  = vc
        2 loc_nurse_unit                = vc
        2 loc_room                      = vc
        2 loc_bed                       = vc
        2 disch_dt_tm                   = dq8
        2 organization_id               = f8
        2 reason_for_visit              = vc
        2 encntr_financial_id           = f8
        2 financial_class               = vc
        2 trauma                        = vc
        2 triage                        = vc
        2 triage_dt_tm                  = dq8
        2 visitor_status                = vc
        2 inpatient_admit_dt_tm         = dq8
        2 encntr_class_cd               = f8
        2 encntr_type_cd                = f8
        2 encntr_type_class_cd          = f8
        2 encntr_status_cd              = f8
        2 admit_type_cd                 = f8
        2 admit_src_cd                  = f8
        2 admit_mode_cd                 = f8
        2 disch_disposition_cd          = f8
        2 disch_to_loctn_cd             = f8
        2 readmit_cd                    = f8
        2 accommodation_cd              = f8
        2 accommodation_request_cd      = f8
        2 accommodation_reason_cd       = f8
        2 ambulatory_cond_cd            = f8
        2 courtesy_cd                   = f8
        2 isolation_cd                  = f8
        2 med_service_cd                = f8
        2 confid_level_cd               = f8
        2 vip_cd                        = f8
        2 location_cd                   = f8
        2 location_org_id               = f8
        2 loc_facility_cd               = f8
        2 loc_building_cd               = f8
        2 loc_nurse_unit_cd             = f8
        2 loc_room_cd                   = f8
        2 loc_bed_cd                    = f8
        2 financial_class_cd            = f8
        2 trauma_cd                     = f8
        2 triage_cd                     = f8
        2 visitor_status_cd             = f8
        2 aliases[*]
            3 alias_pool                = vc
            3 alias_type                = vc
            3 alias_type_meaning        = vc
            3 alias                     = vc
            3 alias_formatted           = vc
            3 alias_sub_type            = vc
            3 alias_pool_cd             = f8
            3 encntr_alias_type_cd      = f8
            3 encntr_alias_sub_type_cd  = f8
        2 prsnl_reltn[*]
            3 reltn_type                = vc
            3 reltn_type_meaning        = vc
            3 person_id                 = f8
            3 priority_seq              = i4
            3 internal_seq              = i4
            3 prsnl_type                = vc
            3 name_full_formatted       = vc
            3 physician_ind             = i4
            3 position                  = vc
            3 name_last                 = vc
            3 name_first                = vc
            3 user_name                 = vc
            3 encntr_prsnl_r_cd         = f8
            3 prsnl_type_cd             = f8
            3 position_cd               = f8
        2 encntr_info[*]
            3 info_type                 = vc
            3 info_type_meaning         = vc
            3 info_sub_type             = vc
            3 info_sub_type_meaning     = vc
            3 value_numeric_ind         = i4
            3 value_numeric             = i4
            3 value_dt_tm               = dq8
            3 chartable_ind             = i4
            3 priority_seq              = i4
            3 internal_seq              = i4
            3 value                     = vc
            3 long_text                 = vc
            3 info_type_cd              = f8
            3 info_sub_type_cd          = f8
            3 value_cd                  = f8
        2 loc_hist[*]
            3 beg_effective_dt_tm       = dq8
            3 end_effective_dt_tm       = dq8
            3 arrive_dt_tm              = dq8
            3 arrive_prsnl_id           = f8
            3 depart_dt_tm              = dq8
            3 depart_prsnl_id           = f8
            3 location                  = vc
            3 loc_facility              = vc
            3 loc_building              = vc
            3 loc_nurse_unit            = vc
            3 loc_room                  = vc
            3 loc_bed                   = vc
            3 encntr_type               = vc
            3 med_service               = vc
            3 transaction_dt_tm         = dq8
            3 activity_dt_tm            = dq8
            3 accommodation             = vc
            3 accommodation_request     = vc
            3 accommodation_reason      = vc
            3 admit_type                = vc
            3 isolation                 = vc
            3 organization_id           = f8
            3 encntr_type_class         = vc
            3 location_cd               = f8
            3 location_org_id           = f8
            3 loc_facility_cd           = f8
            3 loc_building_cd           = f8
            3 loc_nurse_unit_cd         = f8
            3 loc_room_cd               = f8
            3 loc_bed_cd                = f8
            3 encntr_type_cd            = f8
            3 med_service_cd            = f8
            3 accommodation_cd          = f8
            3 accommodation_request_cd  = f8
            3 accommodation_reason_cd   = f8
            3 admit_type_cd             = f8
            3 isolation_cd              = f8
            3 encntr_type_class_cd      = f8            
) with persist

; Initialize the population size
set stat = alterlist(rEncounter->encounters, size(patient_source->visits, 5))

; Loop through all the patients
for (nLoop = 1 to size(patient_source->visits, 5))
    set rEncounter->encounters[nLoop].encntr_id = patient_source->visits[nLoop].encntr_id
endfor

; Collect the core encounter
select into "nl:"
from 	encounter			e,
        location            l
plan e
    where expand(nNum, 1, size(rEncounter->encounters, 5), e.encntr_id, rEncounter->encounters[nNum].encntr_id)
join l
    where l.location_cd = e.location_cd    
detail
    nPos = locateval(nNum, 1, size(rEncounter->encounters, 5), e.encntr_id, rEncounter->encounters[nNum].encntr_id)
    rEncounter->encounters[nPos].person_id = e.person_id
    rEncounter->encounters[nPos].encntr_class = uar_get_code_display(e.encntr_class_cd)
    rEncounter->encounters[nPos].encntr_type = uar_get_code_display(e.encntr_type_cd)
    rEncounter->encounters[nPos].encntr_type_class = uar_get_code_display(e.encntr_type_class_cd)
    rEncounter->encounters[nPos].encntr_status = uar_get_code_display(e.encntr_status_cd)
    rEncounter->encounters[nPos].pre_reg_dt_tm = e.pre_reg_dt_tm
    rEncounter->encounters[nPos].pre_reg_prsnl_id = e.pre_reg_prsnl_id
    rEncounter->encounters[nPos].reg_dt_tm = e.reg_dt_tm
    rEncounter->encounters[nPos].reg_prsnl_id = e.reg_prsnl_id
    rEncounter->encounters[nPos].est_arrive_dt_tm = e.est_arrive_dt_tm
    rEncounter->encounters[nPos].est_depart_dt_tm = e.est_depart_dt_tm
    rEncounter->encounters[nPos].arrive_dt_tm = e.arrive_dt_tm
    rEncounter->encounters[nPos].depart_dt_tm = e.depart_dt_tm
    rEncounter->encounters[nPos].admit_type = uar_get_code_display(e.admit_type_cd)
    rEncounter->encounters[nPos].admit_src = uar_get_code_display(e.admit_src_cd)
    rEncounter->encounters[nPos].admit_mode = uar_get_code_display(e.admit_mode_cd)
    rEncounter->encounters[nPos].disch_disposition = uar_get_code_display(e.disch_disposition_cd)
    rEncounter->encounters[nPos].disch_to_loctn = uar_get_code_display(e.disch_to_loctn_cd)
    rEncounter->encounters[nPos].readmit = uar_get_code_display(e.readmit_cd)
    rEncounter->encounters[nPos].accommodation = uar_get_code_display(e.accommodation_cd)
    rEncounter->encounters[nPos].accommodation_request = uar_get_code_display(e.accommodation_request_cd)
    rEncounter->encounters[nPos].accommodation_reason = uar_get_code_display(e.accommodation_reason_cd)
    rEncounter->encounters[nPos].ambulatory_cond = uar_get_code_display(e.ambulatory_cond_cd)
    rEncounter->encounters[nPos].courtesy = uar_get_code_display(e.courtesy_cd)
    rEncounter->encounters[nPos].isolation = uar_get_code_display(e.isolation_cd)
    rEncounter->encounters[nPos].med_service = uar_get_code_display(e.med_service_cd)
    rEncounter->encounters[nPos].confid_level = uar_get_code_display(e.confid_level_cd)
    rEncounter->encounters[nPos].vip = uar_get_code_display(e.vip_cd)
    rEncounter->encounters[nPos].location = uar_get_code_display(e.location_cd)
    rEncounter->encounters[nPos].loc_facility = uar_get_code_display(e.loc_facility_cd)
    rEncounter->encounters[nPos].loc_building = uar_get_code_display(e.loc_building_cd)
    rEncounter->encounters[nPos].loc_nurse_unit = uar_get_code_display(e.loc_nurse_unit_cd)
    rEncounter->encounters[nPos].loc_room = uar_get_code_display(e.loc_room_cd)
    rEncounter->encounters[nPos].loc_bed = uar_get_code_display(e.loc_bed_cd)
    rEncounter->encounters[nPos].disch_dt_tm = e.disch_dt_tm
    rEncounter->encounters[nPos].organization_id = e.organization_id
    rEncounter->encounters[nPos].reason_for_visit = e.reason_for_visit
    rEncounter->encounters[nPos].encntr_financial_id = e.encntr_financial_id
    rEncounter->encounters[nPos].financial_class = uar_get_code_display(e.financial_class_cd)
    rEncounter->encounters[nPos].trauma = uar_get_code_display(e.trauma_cd)
    rEncounter->encounters[nPos].triage = uar_get_code_display(e.triage_cd)
    rEncounter->encounters[nPos].triage_dt_tm = e.triage_dt_tm
    rEncounter->encounters[nPos].visitor_status = uar_get_code_display(e.visitor_status_cd)
    rEncounter->encounters[nPos].inpatient_admit_dt_tm = e.inpatient_admit_dt_tm
    rEncounter->encounters[nPos].encntr_class_cd = e.encntr_class_cd
    rEncounter->encounters[nPos].encntr_type_cd = e.encntr_type_cd
    rEncounter->encounters[nPos].encntr_type_class_cd = e.encntr_type_class_cd
    rEncounter->encounters[nPos].encntr_status_cd = e.encntr_status_cd
    rEncounter->encounters[nPos].admit_type_cd = e.admit_type_cd
    rEncounter->encounters[nPos].admit_src_cd = e.admit_src_cd
    rEncounter->encounters[nPos].admit_mode_cd = e.admit_mode_cd
    rEncounter->encounters[nPos].disch_disposition_cd = e.disch_disposition_cd
    rEncounter->encounters[nPos].disch_to_loctn_cd = e.disch_to_loctn_cd
    rEncounter->encounters[nPos].readmit_cd = e.readmit_cd
    rEncounter->encounters[nPos].accommodation_cd = e.accommodation_cd
    rEncounter->encounters[nPos].accommodation_request_cd = e.accommodation_request_cd
    rEncounter->encounters[nPos].accommodation_reason_cd = e.accommodation_reason_cd
    rEncounter->encounters[nPos].ambulatory_cond_cd = e.ambulatory_cond_cd
    rEncounter->encounters[nPos].courtesy_cd = e.courtesy_cd
    rEncounter->encounters[nPos].isolation_cd = e.isolation_cd
    rEncounter->encounters[nPos].med_service_cd = e.med_service_cd
    rEncounter->encounters[nPos].confid_level_cd = e.confid_level_cd
    rEncounter->encounters[nPos].vip_cd = e.vip_cd
    rEncounter->encounters[nPos].location_cd = e.location_cd
    rEncounter->encounters[nPos].location_org_id = l.organization_id
    rEncounter->encounters[nPos].loc_facility_cd = e.loc_facility_cd
    rEncounter->encounters[nPos].loc_building_cd = e.loc_building_cd
    rEncounter->encounters[nPos].loc_room_cd = e.loc_room_cd
    rEncounter->encounters[nPos].loc_bed_cd = e.loc_bed_cd
    rEncounter->encounters[nPos].financial_class_cd = e.financial_class_cd
    rEncounter->encounters[nPos].trauma_cd = e.trauma_cd
    rEncounter->encounters[nPos].triage_cd = e.triage_cd
    rEncounter->encounters[nPos].visitor_status_cd = e.visitor_status_cd
with counter, expand=2

; Collect the Encounter Level Aliases
; -----------------------------------
if (validate(payload->encounter->aliases, 0) = 1)
 
    ; Set the Parser
    call type_parser("ea.encntr_alias_type_cd", 319)
 
    ; Collect the alias
    select into "nl:"
    from	encntr_alias		ea
    plan ea
        where expand(nNum, 1, size(rEncounter->encounters, 5), ea.encntr_id, rEncounter->encounters[nNum].encntr_id)
        and parser(cParser)
        and ea.active_ind = 1
        and ea.end_effective_dt_tm > sysdate
    order ea.encntr_id
	head ea.encntr_id
        nPos = locateval(nNum, 1, size(rEncounter->encounters, 5), ea.encntr_id, rEncounter->encounters[nNum].encntr_id)
        nCount = 0
    detail
        nCount = nCount + 1
        stat = alterlist(rEncounter->encounters[nPos].aliases, nCount)
            
        rEncounter->encounters[nPos].aliases[nCount].alias_pool = uar_get_code_display(ea.alias_pool_cd)
        rEncounter->encounters[nPos].aliases[nCount].alias_type = uar_get_code_display(ea.encntr_alias_type_cd)
        rEncounter->encounters[nPos].aliases[nCount].alias_type_meaning = uar_get_code_meaning(ea.encntr_alias_type_cd)
        rEncounter->encounters[nPos].aliases[nCount].alias = ea.alias
        rEncounter->encounters[nPos].aliases[nCount].alias_formatted = cnvtalias(ea.alias, ea.alias_pool_cd)
        rEncounter->encounters[nPos].aliases[nCount].alias_sub_type = uar_get_code_display(ea.encntr_alias_sub_type_cd)
        rEncounter->encounters[nPos].aliases[nCount].alias_pool_cd = ea.alias_pool_cd
        rEncounter->encounters[nPos].aliases[nCount].encntr_alias_type_cd = ea.encntr_alias_type_cd
        rEncounter->encounters[nPos].aliases[nCount].encntr_alias_sub_type_cd = ea.encntr_alias_sub_type_cd       
    with counter, expand=2
endif    

; Collect the Prsnl relationships at the encounter level
; ---------------------------------------------------
if (validate(payload->encounter->prsnlreltn, 0) = 1)
		
    ; Set the Parser
	call type_parser("epr.encntr_prsnl_r_cd", 333)
		
    select into "nl:"
    from 	encntr_prsnl_reltn		epr,
			prsnl					p
    plan epr
        where expand(nNum, 1, size(rEncounter->encounters, 5), epr.encntr_id, rEncounter->encounters[nNum].encntr_id)
        and parser(cParser)
    	and epr.active_ind = 1
		and epr.end_effective_dt_tm > sysdate
	join p
		where p.person_id = epr.prsnl_person_id
    order epr.encntr_id
	head epr.encntr_id
        nPos = locateval(nNum, 1, size(rEncounter->encounters, 5), epr.encntr_id, rEncounter->encounters[nNum].encntr_id)
        nCount = 0
    detail
        nCount = nCount + 1
        stat = alterlist(rEncounter->encounters[nPos].prsnl_reltn, nCount)
        
        rEncounter->encounters[nPos].prsnl_reltn[nCount].reltn_type = uar_get_code_display(epr.encntr_prsnl_r_cd)
        rEncounter->encounters[nPos].prsnl_reltn[nCount].reltn_type_meaning = uar_get_code_meaning(epr.encntr_prsnl_r_cd)
        rEncounter->encounters[nPos].prsnl_reltn[nCount].person_id = p.person_id
        rEncounter->encounters[nPos].prsnl_reltn[nCount].priority_seq = epr.priority_seq
        rEncounter->encounters[nPos].prsnl_reltn[nCount].internal_seq = epr.internal_seq
        rEncounter->encounters[nPos].prsnl_reltn[nCount].prsnl_type = uar_get_code_display(p.prsnl_type_cd)
        rEncounter->encounters[nPos].prsnl_reltn[nCount].name_full_formatted = p.name_full_formatted
        rEncounter->encounters[nPos].prsnl_reltn[nCount].physician_ind = p.physician_ind
        rEncounter->encounters[nPos].prsnl_reltn[nCount].position = uar_get_code_display(p.position_cd)
        rEncounter->encounters[nPos].prsnl_reltn[nCount].name_last = p.name_last
        rEncounter->encounters[nPos].prsnl_reltn[nCount].name_first = p.name_first
        rEncounter->encounters[nPos].prsnl_reltn[nCount].user_name = p.username
        rEncounter->encounters[nPos].prsnl_reltn[nCount].encntr_prsnl_r_cd = epr.encntr_prsnl_r_cd
        rEncounter->encounters[nPos].prsnl_reltn[nCount].prsnl_type_cd = p.prsnl_type_cd
        rEncounter->encounters[nPos].prsnl_reltn[nCount].position_cd = p.position_cd
    with counter, expand=2
endif

; Collect the ENCOUNTER_INFO records
; ----------------------------------
if (validate(payload->encounter->encounterInfo, 0) = 1)
    ; set the parser
    call type_parser("ei.info_sub_type_cd", 356)
 
    select into "nl:"
    from 	encntr_info			ei,
	       	long_text			lt
    plan ei
        where expand(nNum, 1, size(rEncounter->encounters, 5), ei.encntr_id, rEncounter->encounters[nNum].encntr_id)
        and parser(cParser)
        and ei.active_ind = 1
        and ei.end_effective_dt_tm > sysdate
    join lt
        where lt.long_text_id = outerjoin(ei.long_text_id)
    order ei.encntr_id
	head ei.encntr_id
        nPos = locateval(nNum, 1, size(rEncounter->encounters, 5), ei.encntr_id, rEncounter->encounters[nNum].encntr_id)
        nCount = 0
    detail
        nCount = nCount + 1
        stat = alterlist(rEncounter->encounters[nPos].encntr_info, nCount)
        
        rEncounter->encounters[nPos].encntr_info[nCount].info_type = uar_get_code_display(ei.info_type_cd)
        rEncounter->encounters[nPos].encntr_info[nCount].info_type_meaning = uar_get_code_meaning(ei.info_type_cd)
        rEncounter->encounters[nPos].encntr_info[nCount].info_sub_type = uar_get_code_display(ei.info_sub_type_cd)
        rEncounter->encounters[nPos].encntr_info[nCount].info_sub_type_meaning = uar_get_code_meaning(ei.info_sub_type_cd)
        rEncounter->encounters[nPos].encntr_info[nCount].value_numeric_ind = ei.value_numeric_ind
        rEncounter->encounters[nPos].encntr_info[nCount].value_numeric = ei.value_numeric
        rEncounter->encounters[nPos].encntr_info[nCount].value_dt_tm = ei.value_dt_tm
        rEncounter->encounters[nPos].encntr_info[nCount].chartable_ind = ei.chartable_ind
        rEncounter->encounters[nPos].encntr_info[nCount].priority_seq = ei.priority_seq
        rEncounter->encounters[nPos].encntr_info[nCount].internal_seq = ei.internal_seq
        rEncounter->encounters[nPos].encntr_info[nCount].value = uar_get_code_display(ei.value_cd)
        rEncounter->encounters[nPos].encntr_info[nCount].long_text = lt.long_text
        rEncounter->encounters[nPos].encntr_info[nCount].info_type_cd = ei.info_type_cd
        rEncounter->encounters[nPos].encntr_info[nCount].info_sub_type_cd = ei.info_sub_type_cd
        rEncounter->encounters[nPos].encntr_info[nCount].value_cd = ei.value_cd
    with counter, expand=2
endif


; Collect the ENCOUNTER_LOC_HIST records
; --------------------------------------
if (validate(payload->encounter->lochist, 0) = 1)
    select into "nl:"
    from 	encntr_loc_hist		elh,
            location            l
    plan elh
        where expand(nNum, 1, size(rEncounter->encounters, 5), elh.encntr_id, rEncounter->encounters[nNum].encntr_id)
        and elh.active_ind = 1
    join l
        where l.location_cd = elh.location_cd        
    order elh.encntr_id
	head elh.encntr_id
        nPos = locateval(nNum, 1, size(rEncounter->encounters, 5), elh.encntr_id, rEncounter->encounters[nNum].encntr_id)
        nCount = 0
    detail
        nCount = nCount + 1
        stat = alterlist(rEncounter->encounters[nPos].loc_hist, nCount)
        
        rEncounter->encounters[nPos].loc_hist[nCount].beg_effective_dt_tm = elh.beg_effective_dt_tm
        rEncounter->encounters[nPos].loc_hist[nCount].end_effective_dt_tm = elh.end_effective_dt_tm
        rEncounter->encounters[nPos].loc_hist[nCount].arrive_dt_tm = elh.arrive_dt_tm
        rEncounter->encounters[nPos].loc_hist[nCount].arrive_prsnl_id = elh.arrive_prsnl_id
        rEncounter->encounters[nPos].loc_hist[nCount].depart_dt_tm = elh.depart_dt_tm
        rEncounter->encounters[nPos].loc_hist[nCount].depart_prsnl_id = elh.depart_prsnl_id
        rEncounter->encounters[nPos].loc_hist[nCount].location = uar_get_code_display(elh.location_cd)
        rEncounter->encounters[nPos].loc_hist[nCount].loc_facility = uar_get_code_display(elh.loc_facility_cd)
        rEncounter->encounters[nPos].loc_hist[nCount].loc_building = uar_get_code_display(elh.loc_building_cd)
        rEncounter->encounters[nPos].loc_hist[nCount].loc_nurse_unit = uar_get_code_display(elh.loc_nurse_unit_cd)
        rEncounter->encounters[nPos].loc_hist[nCount].loc_room = uar_get_code_display(elh.loc_room_cd)
        rEncounter->encounters[nPos].loc_hist[nCount].loc_bed = uar_get_code_display(elh.loc_bed_cd)
        rEncounter->encounters[nPos].loc_hist[nCount].encntr_type = uar_get_code_display(elh.encntr_type_cd)
        rEncounter->encounters[nPos].loc_hist[nCount].med_service = uar_get_code_display(elh.med_service_cd)
        rEncounter->encounters[nPos].loc_hist[nCount].transaction_dt_tm = elh.transaction_dt_tm
        rEncounter->encounters[nPos].loc_hist[nCount].activity_dt_tm = elh.activity_dt_tm
        rEncounter->encounters[nPos].loc_hist[nCount].accommodation = uar_get_code_display(elh.accommodation_cd)
        rEncounter->encounters[nPos].loc_hist[nCount].accommodation_request = uar_get_code_display(elh.accommodation_request_cd)
        rEncounter->encounters[nPos].loc_hist[nCount].accommodation_reason = uar_get_code_display(elh.accommodation_reason_cd)
        rEncounter->encounters[nPos].loc_hist[nCount].admit_type = uar_get_code_display(elh.admit_type_cd)
        rEncounter->encounters[nPos].loc_hist[nCount].isolation = uar_get_code_display(elh.isolation_cd)
        rEncounter->encounters[nPos].loc_hist[nCount].organization_id = elh.organization_id
        rEncounter->encounters[nPos].loc_hist[nCount].encntr_type_class = uar_get_code_display(elh.encntr_type_class_cd)
        rEncounter->encounters[nPos].loc_hist[nCount].location_cd = elh.location_cd
        rEncounter->encounters[nPos].loc_hist[nCount].location_org_id = l.organization_id
        rEncounter->encounters[nPos].loc_hist[nCount].loc_facility_cd = elh.loc_facility_cd
        rEncounter->encounters[nPos].loc_hist[nCount].loc_building_cd = elh.loc_building_cd
        rEncounter->encounters[nPos].loc_hist[nCount].loc_nurse_unit_cd = elh.loc_nurse_unit_cd
        rEncounter->encounters[nPos].loc_hist[nCount].loc_room_cd = elh.loc_room_cd
        rEncounter->encounters[nPos].loc_hist[nCount].loc_bed_cd = elh.loc_bed_cd
        rEncounter->encounters[nPos].loc_hist[nCount].encntr_type_cd = elh.encntr_type_cd
        rEncounter->encounters[nPos].loc_hist[nCount].med_service_cd = elh.med_service_cd
        rEncounter->encounters[nPos].loc_hist[nCount].accommodation_cd = elh.accommodation_cd
        rEncounter->encounters[nPos].loc_hist[nCount].accommodation_request_cd = elh.accommodation_request_cd
        rEncounter->encounters[nPos].loc_hist[nCount].accommodation_reason_cd = elh.accommodation_reason_cd
        rEncounter->encounters[nPos].loc_hist[nCount].admit_type_cd = elh.admit_type_cd
        rEncounter->encounters[nPos].loc_hist[nCount].isolation_cd = elh.isolation_cd
        rEncounter->encounters[nPos].loc_hist[nCount].encntr_type_class_cd = elh.encntr_type_class_cd       
    with counter, expand=2
endif    

if (validate(payload->encounter->skipJSON, 0) = 0)
    call add_standard_output(cnvtrectojson(rEncounter, 4, 1))
endif

#END_PROGRAM

end go 
/*************************************************************************
 
        Script Name:    1co3_mpage_entry.prg
 
        Description:    Clinical Office - mPage Edition V3
        				Chart level initial entry point for mPages
 
        Date Written:   August 4, 2021
        Written by:     John Simpson
                        Precision Healthcare Solutions
 
 *************************************************************************
		   Copyright (c) 2018 Precision Healthcare Solutions
 
 NO PART OF THIS CODE MAY BE COPIED, MODIFIED OR DISTRIBUTED WITHOUT
 PRIOR WRITTEN CONSENT OF PRECISION HEALTHCARE SOLUTIONS EXECUTIVE
 LEADERSHIP TEAM.
 
 FOR LICENSING TERMS PLEASE VISIT www.clinicaloffice.com/mpage/license
 
 *************************************************************************
                            Special Instructions
 *************************************************************************
 Called from Angular mPage Application through Chart Level mPages
 *************************************************************************
                            Revision Information
 *************************************************************************
 Rev    Date     By             Comments
 ------ -------- -------------- ------------------------------------------
 001    27/02/18 J. Simpson     Initial Development
 002	10/11/18 J. Simpson		Modified the TYPE_PARSER to allow code_value
 								of 0 to be passed.
 003	10/10/18 J. Simpson		Fixed UTC issue with cDATE_FORMAT
 004	01/10/19 J. Simpson		Added JEsc subroutine
 005	03/05/20 J. Simpson		Added support for $PRSNL_ID access from DA2
 006    07/08/20 J. Simpson     Fixed issue with typelist filtering conversion
 007    22/03/21 J. Simpson     Added errors:[] array to report CCL errors
 008    03/08/21 J. Simpson     Added add_standard_output() to support V3 scripts
 009    10/11/21 J. Simpson     Added JSON Config prompt for additional functionality
 010    11/28/22 J. Simpson     Added nameFullFormatted and prsnlName to chart_id structure
 011    03/22/23 J. Simpson     Added check for hexMode to allow hex conversion for v3.6.28 >
 012    06/09/23 J. Simpson     Added support for user position and physician_ind
 013    14/10/23 J. Simpson     Switched to 1co3_mpage_encounter and cleaned out older code no longer used
 *************************************************************************/
 
DROP PROGRAM 1co3_mpage_entry:GROUP1 GO
CREATE PROGRAM 1co3_mpage_entry:GROUP1
 
prompt
	"Output to File/Printer/MINE" = "MINE"     ;* Enter or select the printer or file name to send this report to.
	, "Person ID" = 0
	, "Encounter ID" = 0
	, "Prsnl ID" = 0
	, "Process ID" = 0
	, "Extra Configuration Information" = ""
 
with OUTDEV, PERSON_ID, ENCNTR_ID, PRSNL_ID, ID, CONFIG
 
; Set the absolute maximum possible variable length
SET MODIFY MAXVARLEN 268435456
 
; Variable declarations
DECLARE _Memory_Reply_String = vc
;;DECLARE cDATE_FORMAT = vc WITH NOCONSTANT("YYYY-MM-DDTHH:MM:SS.CC0-05:00;;Q")
DECLARE nTZ = i4 WITH NOCONSTANT(datetimediff(datetimezone(sysdate,curtimezoneapp),sysdate,3))
DECLARE cTZ = vc WITH NOCONSTANT(CONCAT(EVALUATE2(IF(nTZ < 0) "-" ELSE "+" ENDIF), FORMAT(ABS(nTZ), "##;P0")))
DECLARE cDATE_FORMAT = vc WITH NOCONSTANT(CONCAT("YYYY-MM-DDTHH:MM:SS.CC0",cTZ,":00;;Q"))
DECLARE cPARSER = vc
DECLARE nPRSNL_ID = f8 ; WITH NOCONSTANT($PRSNL_ID)  ; 03/22/2021 - $PRSNL_ID failing in DVDev, code below works for all cases
declare cv48_Active = f8 with noconstant(uar_get_code_by("MEANING", 48, "ACTIVE"))
declare nCopyChartIdToPayload = i4 with noconstant(0)
declare nPos = i4
 
; If run from Visual Developer or DA2, the $PRSNL_ID variable is invalid and not properly set. This will
; correct the issue by replacing nPRSNL_ID with the current user id.
if (nPRSNL_ID = 0)
	set nPRSNL_ID = reqinfo->updt_id
endif
 
; ******************
; Custom subroutines
; ******************
 /*
; JEsc - Escapes invalid JSON characters
subroutine (JEsc(cText = vc) = vc with copy, persist)
	; Eliminate bad characters
	set cText = replace(replace(replace(cText, char(0), ""),char(8), ""), char(9), "")
	set cText = replace(replace(replace(replace(cText, char(10), ""),char(11), ""), char(12), ""), char(13), "")
 
	; Replace Javascript special characters
	set cText = replace(cText, ^\^, ^\\^)
	set cText = replace(cText, ^"^, ^\"^)
	return(cText)
end
*/
 
; FIXJSON - Removes the first and last character off a JSON string. This is necessary
; to combine multiple JSON strings into a single payload for return to the mPage
SUBROUTINE (FIXJSON(cJSON = vc) = vc WITH COPY)
	SET cJSON = SUBSTRING(2, SIZE(cJSON) - 2, cJSON)
	RETURN(cJSON)
END
 
; Runs the custom script pre or post block
SUBROUTINE RUN_CUSTOM(cTYPE)
	IF (VALIDATE(PAYLOAD->CUSTOMSCRIPT->SCRIPT) = 1)
		SET _Memory_Reply_String = CONCAT(_Memory_Reply_String, ^,"custom^, CNVTCAP(cTYPE), ^":[^)
		FOR (nSCRIPT = 1 TO SIZE(PAYLOAD->CUSTOMSCRIPT->SCRIPT, 5))
			IF (CNVTUPPER(PAYLOAD->CUSTOMSCRIPT->SCRIPT[nSCRIPT].RUN) = CNVTUPPER(cTYPE))
				CALL PARSER(CONCAT("EXECUTE ", PAYLOAD->CUSTOMSCRIPT->SCRIPT[nSCRIPT].NAME, " GO"))
			ENDIF
		ENDFOR
		SET _Memory_Reply_String = CONCAT(_Memory_Reply_String, ^]^)
	ENDIF
END
 
; Adds standard output objects to the output JSON stream
subroutine add_standard_output(cJSON)
    set nPos = findstring(":", cJSON)
	if (substring(size(trim(_Memory_Reply_String)),1,_Memory_Reply_String) != "[")
        set _Memory_Reply_String = concat(_Memory_Reply_String, ^,^)
	endif
	set _Memory_Reply_String = concat(_Memory_Reply_String, substring(nPos+2, size(trim(cJSON))-(nPos+3), cJSON))
end
 
; Adds the output of the custom record structure to the output JSON stream
SUBROUTINE ADD_CUSTOM_OUTPUT(cJSON)
	IF (TRIM(PAYLOAD->CUSTOMSCRIPT->SCRIPT[nSCRIPT].ID) != "")
		SET nPOS = FINDSTRING(":", cJSON)
		IF (SUBSTRING(SIZE(TRIM(_Memory_Reply_String)),1,_Memory_Reply_String) != "[")
			SET _Memory_Reply_String = CONCAT(_Memory_Reply_String, ^,^)
		ENDIF
		SET _Memory_Reply_String = CONCAT(_Memory_Reply_String,
											^{"id":"^, PAYLOAD->CUSTOMSCRIPT->SCRIPT[nSCRIPT].ID, ^",^,
											^"data"^, SUBSTRING(nPOS, SIZE(cJSON)-nPOS, cJSON), ^}^)
	ENDIF
END
 
; Returns a parser string listing code values
; ---------------------------------------------------
SUBROUTINE TYPE_PARSER(cPREFIX, nCODE_SET)
	SET cPARSER = "1=1"		; Default all
 
	IF (VALIDATE(PAYLOAD->TYPELIST) = 1)
 
		SELECT DISTINCT INTO "NL:"
		    code_value = cv.code_value
		    ;CODE_VALUE			= CNVTINT(CV.CODE_VALUE)
		FROM 	(DUMMYT			D WITH SEQ=VALUE(SIZE(PAYLOAD->TYPELIST,5))),
				CODE_VALUE		CV
		PLAN D
		JOIN CV
			WHERE (CV.CODE_VALUE = PAYLOAD->TYPELIST[D.SEQ].TYPECD AND nCODE_SET = PAYLOAD->TYPELIST[D.SEQ].CODESET)
			OR
				(CV.CODE_SET = PAYLOAD->TYPELIST[D.SEQ].CODESET
				AND (
						(CV.CDF_MEANING = PAYLOAD->TYPELIST[D.SEQ].TYPE AND TRIM(CV.CDF_MEANING) != "")
						OR CV.DISPLAY_KEY = PAYLOAD->TYPELIST[D.SEQ].TYPE
					)
				AND CV.CODE_SET = nCODE_SET
				AND CV.CODE_VALUE > 0
				AND CV.ACTIVE_IND = 1
				AND CV.END_EFFECTIVE_DT_TM > SYSDATE
			)
		ORDER CODE_VALUE
		HEAD REPORT
			cPARSER = " "
		DETAIL
			cPARSER = BUILD(cPARSER, ",", CODE_VALUE)
		FOOT REPORT
			cPARSER = CONCAT(cPREFIX, " IN (", TRIM(SUBSTRING(2,SIZE(cPARSER),cPARSER)), ")")
		WITH COUNTER
	ENDIF
END

; Define run stats record structure
free record run_stats
RECORD RUN_STATS (
	1 ID			= i4
	1 START_TIME	= dq8
	1 END_TIME		= dq8
	1 STATUS		= vc
	1 HEX_MODE      = i4
)
 
; Test incoming config parameter and assign to CONFIG record structure
if (trim($config) != "")
    free record config
    set stat = cnvtjsontorec(concat(^{"config":^, $config, ^}^), 0, 0, 1)    
endif
 
; Test incoming blob data and assign to PAYLOAD record structure
IF (VALIDATE(REQUEST->BLOB_IN))
	IF (REQUEST->BLOB_IN > " ")
	
        ; 011: Convert JSON from Hex first if needed
	    if (validate(config->hexMode, 0) = 1)
	      set run_stats->hex_mode = 1
	      SET STAT = CNVTJSONTOREC(cnvthexraw(REQUEST->BLOB_IN), 0, 0, 1) 
	    else	
		  SET STAT = CNVTJSONTOREC(REQUEST->BLOB_IN, 0, 0, 1)
		endif
	ENDIF
ENDIF
  
SET RUN_STATS->ID = $ID
SET RUN_STATS->START_TIME = SYSDATE
 
IF (VALIDATE(PAYLOAD) = 0)
	SET RUN_STATS->STATUS = "ERROR: Invalid Payload"
 
	GO TO FINALIZE_PAYLOAD
ENDIF
 
; Populate the callback structure which contains the PERSON_ID, ENCNTR_ID and PRSNL_ID values
; passed from PowerChart to CCL. These values are passed back to the mPage for use in some of
; the data services.
free record chart_id
record chart_id (
	1 person_id		       = f8
	1 encntr_id		       = f8
	1 name_full_formatted  = vc
	1 prsnl_id		       = f8
	1 prsnl_name           = vc
	1 physician_ind        = i4
	1 position_cd          = f8
	1 position             = vc
	1 domain               = vc
)
 
set chart_id->person_id = $person_id
set chart_id->encntr_id = $encntr_id
set chart_id->prsnl_id = nPRSNL_ID
set chart_id->domain = curdomain

; Collect the name of the user
select into "nl:"
from    prsnl           p
plan p
    where p.person_id = chart_id->prsnl_id
detail
    chart_id->prsnl_name = p.name_full_formatted
    chart_id->position_cd = p.position_cd
    chart_id->position = uar_get_code_display(p.position_cd)
    chart_id->physician_ind = p.physician_ind
with counter
 
; If chart mode and encntr_id is 0, try loading the user prefs
if (validate(config->mode) = 1)
 
    if (config->mode = "CHART" and chart_id->encntr_id = 0)
        select into "nl:"
        from    dm_info         d,
                encounter       e,
                person          p
        plan d
            where d.info_domain = "CLINICAL OFFICE"
            and d.info_name = "DEVELOPER TEST VISIT"
            and d.info_domain_id = chart_id->prsnl_id ;reqinfo->updt_id
        join e
            where e.encntr_id = d.info_number
        join p
            where p.person_id = e.person_id
        detail
            nCopyChartIdToPayload = 1
            chart_id->person_id = e.person_id
            chart_id->encntr_id = e.encntr_id
 
            run_stats->status = concat("Chart Level MPage with no encounter. Using testing value from dm_info: ",
                                    trim(p.name_full_formatted), " (ENCNTR_ID: ", trim(cnvtstring(e.encntr_id)), ")")
        with counter
    endif

    ; Collect the patient name
    if (config->mode = "CHART")
        select into "nl:"
        from    person          p
        plan p
            where p.person_id = chart_id->person_id
        detail
            chart_id->name_full_formatted = p.name_full_formatted
        with counter
    endif
 
endif
 
; Populate the encounter/person structure. While we could use the values from payload without
; copying to the PATIENT_SOURCE structure, having it available in a seperate record structure
; allows for dynamically loading from other CCL scripts.
; (e.g. Current Census followed by Patient Demographics)
RECORD PATIENT_SOURCE (
	1 VISITS[*]
		2 PERSON_ID		= f8
		2 ENCNTR_ID		= f8
	1 PATIENTS[*]
		2 PERSON_ID		= f8
)
 
IF (VALIDATE(PAYLOAD->PATIENTSOURCE) = 1)
	; Populate the PATIENT_SOURCE structure and assign any missing PERSON_ID values
	SELECT INTO "NL:"
		PERSON_ID			= IF (PAYLOAD->PATIENTSOURCE[D.SEQ].PERSONID > 0)
								PAYLOAD->PATIENTSOURCE[D.SEQ].PERSONID
							  ELSE
							  	E.PERSON_ID
							  ENDIF,
		ENCNTR_ID			= PAYLOAD->PATIENTSOURCE[D.SEQ].ENCNTRID
	FROM	(DUMMYT				D WITH SEQ=VALUE(SIZE(PAYLOAD->PATIENTSOURCE, 5))),
			ENCOUNTER			E
	PLAN D
		WHERE PAYLOAD->PATIENTSOURCE[D.SEQ].PERSONID > 0
		OR PAYLOAD->PATIENTSOURCE[D.SEQ].ENCNTRID > 0
	JOIN E
		WHERE E.ENCNTR_ID = PAYLOAD->PATIENTSOURCE[D.SEQ].ENCNTRID
	ORDER PERSON_ID, ENCNTR_ID
	HEAD REPORT
		STAT = ALTERLIST(PATIENT_SOURCE->VISITS, SIZE(PAYLOAD->PATIENTSOURCE, 5))
		nPATCOUNT = 0
		nVISCOUNT = 0
	HEAD PERSON_ID
		nPATCOUNT = nPATCOUNT + 1
		STAT = ALTERLIST(PATIENT_SOURCE->PATIENTS, nPATCOUNT)
 
		PATIENT_SOURCE->PATIENTS[nPATCOUNT].PERSON_ID = PERSON_ID
	DETAIL
		nVISCOUNT = nVISCOUNT + 1
		PATIENT_SOURCE->VISITS[nVISCOUNT].ENCNTR_ID = ENCNTR_ID
		PATIENT_SOURCE->VISITS[nVISCOUNT].PERSON_ID = PERSON_ID
	WITH COUNTER
ENDIF
 
; Check to see if PATIENT_SOURCE is empty and if it is populate with the id's passed from the mPage
if (size(patient_source->visits, 5) = 0)
	set stat = alterlist(patient_source->visits, 1)
	set stat = alterlist(patient_source->patients, 1)
 
	if (nCopyChartIdToPayload = 1)
        set patient_source->visits[1].person_id = chart_id->person_id
        set patient_source->visits[1].encntr_id = chart_id->encntr_id
 
        set patient_source->patients[1].person_id = chart_id->person_id
	else
        set patient_source->visits[1].person_id = $person_id
        set patient_source->visits[1].encntr_id = $encntr_id
 
        set patient_source->patients[1].person_id = $person_id
    endif
endif
 
; ******************************************************************************************
; Execute Pre-CCL scripts (These are scripts that need to run first as they may populate the
; PATIENT_SOURCE record structure
; ******************************************************************************************
IF(VALIDATE(PAYLOAD->CUSTOMSCRIPT) = 1)
	; Clear all entries from the PATIENT_SOURCE structure if parameter passed
	IF (VALIDATE(PAYLOAD->CUSTOMSCRIPT->CLEARPATIENTSOURCE, 0) = 1)
		SET STAT = INITREC(PATIENT_SOURCE)
	ENDIF
 
	CALL RUN_CUSTOM("PRE")
ENDIF
 
; ******************************************************************************************
; Execute the main data collection CCL scripts based on the payload
; ******************************************************************************************
 
if (validate(payload->codevalue) = 1) execute 1co_mpage_cvlookup:group1 endif
if (validate(payload->person) = 1) execute 1co3_mpage_person:group1 endif
if (validate(payload->encounter) = 1) execute 1co3_mpage_encounter:group1 endif
if (validate(payload->organization) = 1 or
	validate(payload->address) = 1 or
	validate(payload->phone) = 1) execute 1co_mpage_apo:group1
endif
if (validate(payload->allergy) = 1) execute 1co_mpage_allergy:group1 endif
if (validate(payload->diagnosis) = 1) execute 1co_mpage_diagnosis:group1 endif
if (validate(payload->problem) = 1) execute 1co_mpage_problem:group1 endif
 
; ******************************************************************************************
; Execute any custom Post-CCL scripts
; ******************************************************************************************
CALL RUN_CUSTOM("POST")
 
#FINALIZE_PAYLOAD
 
; Add any CCL Errors to the reply string
declare cErrorMessage = c132
declare cErrors = vc
declare nErrorCode = i4 with noconstant(1)
while (nErrorCode != 0)
    set nErrorCode = error(cErrorMessage, 0)
    if (nErrorCode != 0)
        if (trim(cErrors) != "")
            set cErrors = concat(trim(cErrors), ",")
        endif
        set cErrors = concat(trim(cErrors), ^{"code":^, build(nErrorCode), ^,"message":"^, trim(cErrorMessage), ^"}^)
    endif
endwhile
set cErrors = concat(^"errors":[^, trim(cErrors), ^]^)
 
; Generate the final _Memory_Reply_String
SET RUN_STATS->END_TIME = SYSDATE
SET _Memory_Reply_String = BUILD("{",
								FIXJSON(CNVTRECTOJSON(RUN_STATS, 4, 1)), ",",
								FIXJSON(CNVTRECTOJSON(CHART_ID, 4, 1)), ",",
								cErrors,
								 _Memory_Reply_String,
								 "}")
 
; 011: Convert JSON to Hex first if needed
if (validate(config->hexMode, 0) = 1) 
    set _Memory_Reply_String = cnvtrawhex(_Memory_Reply_String)
endif
 
END GO
/*************************************************************************
 
        Script Name:    1co3_mpage_person.prg
 
        Description:    Clinical Office - MPage Edition V3
        				Person Data Retrieval
 
        Date Written:   August 4, 2021
        Written by:     John Simpson
                        Precision Healthcare Solutions
 
 *************************************************************************
		   Copyright (c) 2021 Precision Healthcare Solutions
 
 NO PART OF THIS CODE MAY BE COPIED, MODIFIED OR DISTRIBUTED WITHOUT
 PRIOR WRITTEN CONSENT OF PRECISION HEALTHCARE SOLUTIONS EXECUTIVE
 LEADERSHIP TEAM.
 
 FOR LICENSING TERMS PLEASE VISIT www.clinicaloffice.com/mpage/license
 
 *************************************************************************
                            Special Instructions
 *************************************************************************
 Called from 1co_mpage_entry. Do not attempt to run stand alone.
 
 Possible Payload values:
 
	"patientSource":[
		{"personId": value, "encntrId": value}
	],
	"person": {
    	"includeCodeValues": true,  [*** DEPRECATED AS OF V3 ***]
		"patient": true,
		"aliases": true,
		"names": true,
		"personInfo": true,
		"prsnlReltn": true,
		"personReltn": true,
		"personCodeReltn": true,
		"orgReltn": true,
		"prsnl": true,              [*** REMOVED AS OF V3 - See PrsnlService ***]
		"prsnlAlias": true,         [*** REMOVED AS OF V3 - See PrsnlService ***]
		"prsnlGroup": true,         [*** REMOVED AS OF V3 - See PrsnlService ***]
		"prsnlOrgReltn": true,      [*** REMOVED AS OF V3 - See PrsnlService ***]
	},
	"typeList": [
		{"codeSet": value, "type": "value", "typeCd": value}
	]
 
 
 
 *************************************************************************
                            Revision Information
 *************************************************************************
 Rev    Date     By             Comments
 ------ -------- -------------- ------------------------------------------
 001    03/08/21 J. Simpson     V3 Modernizations
 002    01/19/22 J. Simpson     Added person_code_value_r table data
 003    14/10/23 J. Simpson     Set persist on record structure and allow skipping
                                of JSON content
 *************************************************************************/
 
drop program 1co3_mpage_person:group1 go
create program 1co3_mpage_person:group1
 
; Check to see if running from mPage entry script
if (validate(payload->person) = 0 or size(patient_source->patients, 5) = 0)
	go to end_program
endif
 
; Required variables
declare cParser = vc
declare nNum = i4
declare cString = vc
 
free record rPerson
record rPerson (
    1 persons[*]
        2 person_id                     = f8
        2 logical_domain_id             = f8
        2 name_full_formatted           = vc
        2 name_last                     = vc
        2 name_first                    = vc
		2 name_middle                   = vc
		2 birth_dt_tm                   = dq8
        2 deceased_dt_tm                = dq8
        2 last_encntr_dt_tm             = dq8
        2 autopsy                       = vc
        2 deceased                      = vc
        2 ethnic_grp                    = vc
        2 language                      = vc
        2 marital_type                  = vc
        2 race                          = vc
        2 religion                      = vc
        2 sex                           = vc
        2 species                       = vc
        2 confid_level                  = vc
        2 vip                           = vc
        2 interp_required               = vc
        2 living_will                   = vc
        2 gest_age_at_birth             = i4
        2 gest_age_method               = vc
        2 health_info_access_offered    = vc
        2 autopsy_cd                    = f8
        2 deceased_cd                   = f8
        2 ethnic_grp_cd                 = f8
        2 language_cd                   = f8
        2 marital_type_cd               = f8
        2 race_cd                       = f8
        2 religion_cd                   = f8
        2 sex_cd                        = f8
        2 species_cd                    = f8
        2 confid_level_cd               = f8
        2 vip_cd                        = f8
        2 interp_required_cd            = f8
        2 living_will_cd                = f8
        2 gest_age_method_cd            = f8
        2 health_info_access_offered_cd = f8
        2 aliases[*]
            3 alias_pool                = vc
            3 alias_type                = vc
            3 alias_type_meaning        = vc
            3 alias                     = vc
            3 alias_formatted           = vc
            3 alias_sub_type            = vc
            3 visit_seq_nbr             = i4
            3 health_card_province      = vc
            3 health_card_ver_code      = vc
            3 health_card_issue_dt_tm   = dq8
            3 health_card_expiry_dt_tm  = dq8
            3 health_card_type          = vc
            3 alias_pool_cd             = f8
            3 person_alias_type_cd      = f8
            3 person_alias_sub_type_cd  = f8
        2 names[*]
            3 name_type                 = vc
            3 name_type_meaning         = vc
            3 beg_effective_dt_tm       = dq8
            3 end_effective_dt_tm       = dq8
            3 name_full_formatted       = vc
            3 name_first                = vc
            3 name_middle               = vc
            3 name_last                 = vc
            3 name_degree               = vc
            3 name_title                = vc
            3 name_prefix               = vc
            3 name_suffix               = vc
            3 name_initials             = vc
            3 name_type_seq             = i4
            3 name_type_cd              = f8
        2 prsnl_reltn[*]
            3 reltn_type                = vc
            3 reltn_type_meaning        = vc
            3 person_id                 = f8
            3 priority_seq              = i4
            3 prsnl_type                = vc
            3 name_full_formatted       = vc
            3 physician_ind             = i4
            3 position                  = vc
            3 name_last                 = vc
            3 name_first                = vc
            3 user_name                 = vc
            3 person_prsnl_r_cd         = f8
            3 prsnl_type_cd             = f8
            3 position_cd               = f8
        2 person_reltn[*]
            3 person_reltn_type         = vc
            3 person_reltn_type_meaning = vc
            3 person_reltn              = vc
            3 related_person_reltn      = vc
            3 person_id                 = f8
            3 priority_seq              = i4
            3 internal_seq              = i4
            3 name_full_formatted       = vc
            3 name_last                 = vc
            3 name_first                = vc
            3 name_middle               = vc
            3 person_reltn_type_cd      = f8
            3 person_reltn_cd           = f8
            3 related_person_reltn_cd   = f8
        2 person_org_reltn[*]
            3 person_org_reltn          = vc
            3 person_org_reltn_meaning  = vc
            3 organization_id           = f8
            3 empl_type                 = vc
            3 empl_status               = vc
            3 org_name                  = vc
            3 priority_seq              = i4
            3 person_org_reltn_cd       = f8
            3 empl_type_cd              = f8
            3 empl_status_cd            = f8
        2 person_info[*]
            3 info_type                 = vc
            3 info_type_meaning         = vc
            3 info_sub_type             = vc
            3 info_sub_type_meaning     = vc
            3 value_numeric_ind         = i4
            3 value_numeric             = f8
            3 value_dt_tm               = dq8
            3 chartable_ind             = i4
            3 priority_seq              = i4
            3 internal_seq              = i4
            3 value                     = vc
            3 long_text                 = vc
            3 info_type_cd              = f8
            3 info_sub_type_cd          = f8
            3 value_cd                  = f8
        2 person_code_reltn[*]
            3 person_code_value_r_id    = f8
            3 code_set                  = f8
            3 code_value                = f8
            3 display                   = vc
) with persist
 
 
; Initialize the population size
set stat = alterlist(rPerson->persons, size(patient_source->patients, 5))
 
; Loop through all the patients
for (nLoop = 1 to size(patient_source->patients, 5))
    set rPerson->persons[nLoop].person_id = patient_source->patients[nloop].person_id
endfor
 
select into "nl:"
from    person              p,
        person_patient      pp
plan p
    where expand(nNum, 1, size(rPerson->persons, 5), p.person_id, rPerson->persons[nNum].person_id)
    and p.active_ind = 1
    and p.end_effective_dt_tm > sysdate
    and p.active_status_cd = cv48_Active
join pp
    where pp.person_id = outerjoin(p.person_id)
    and pp.active_ind = outerjoin(1)
    and pp.end_effective_dt_tm > outerjoin(sysdate)
    and pp.active_status_cd = outerjoin(cv48_Active)
detail
    nPos = locateval(nNum, 1, size(rPerson->persons, 5), p.person_id, rPerson->persons[nNum].person_id)
 
    rPerson->persons[nPos].logical_domain_id = p.logical_domain_id
    rPerson->persons[nPos].name_full_formatted = p.name_full_formatted
    rPerson->persons[nPos].name_last = p.name_last
    rPerson->persons[nPos].name_first = p.name_first
    rPerson->persons[nPos].name_middle = p.name_middle
    rPerson->persons[nPos].birth_dt_tm = p.birth_dt_tm
    rPerson->persons[nPos].deceased_dt_tm = p.deceased_dt_tm
    rPerson->persons[nPos].last_encntr_dt_tm = p.last_encntr_dt_tm
    rPerson->persons[nPos].autopsy = uar_get_code_display(p.autopsy_cd)
    rPerson->persons[nPos].deceased = uar_get_code_display(p.deceased_cd)
    rPerson->persons[nPos].ethnic_grp = uar_get_code_display(p.ethnic_grp_cd)
    rPerson->persons[nPos].language = uar_get_code_display(p.language_cd)
    rPerson->persons[nPos].marital_type = uar_get_code_display(p.marital_type_cd)
    rPerson->persons[nPos].race = uar_get_code_display(p.race_cd)
    rPerson->persons[nPos].religion = uar_get_code_display(p.religion_cd)
    rPerson->persons[nPos].sex = uar_get_code_display(p.sex_cd)
    rPerson->persons[nPos].species = uar_get_code_display(p.species_cd)
    rPerson->persons[nPos].confid_level = uar_get_code_display(p.confid_level_cd)
    rPerson->persons[nPos].vip = uar_get_code_display(p.vip_cd)
    rPerson->persons[nPos].autopsy_cd = p.autopsy_cd
    rPerson->persons[nPos].deceased_cd = p.deceased_cd
    rPerson->persons[nPos].ethnic_grp_cd = p.ethnic_grp_cd
    rPerson->persons[nPos].language_cd = p.language_cd
    rPerson->persons[nPos].marital_type_cd = p.marital_type_cd
    rPerson->persons[nPos].race_cd = p.race_cd
    rPerson->persons[nPos].religion_cd = p.religion_cd
    rPerson->persons[nPos].sex_cd = p.sex_cd
    rPerson->persons[nPos].species_cd = p.species_cd
    rPerson->persons[nPos].confid_level_cd = p.confid_level_cd
    rPerson->persons[nPos].vip_cd = p.vip_cd
 
    if (validate(payload->person->patient, 0) = 1)
        rPerson->persons[nPos].interp_required = uar_get_code_display(pp.interp_required_cd)
        rPerson->persons[nPos].living_will = uar_get_code_display(pp.living_will_cd)
        rPerson->persons[nPos].gest_age_at_birth = pp.gest_age_at_birth
        rPerson->persons[nPos].gest_age_method = uar_get_code_display(pp.gest_age_method_cd)
        rPerson->persons[nPos].health_info_access_offered = uar_get_code_display(pp.health_info_access_offered_cd)
        rPerson->persons[nPos].interp_required_cd = pp.interp_required_cd
        rPerson->persons[nPos].living_will_cd = pp.living_will_cd
        rPerson->persons[nPos].gest_age_method_cd = pp.gest_age_method_cd
        rPerson->persons[nPos].health_info_access_offered_cd = pp.health_info_access_offered_cd
    endif
with counter, expand=2
 
	; Collect the Person Level Aliases
	; --------------------------------
	if (validate(payload->person->aliases, 0) = 1)
 
		; set the Parser
		call type_parser("pa.person_alias_type_cd", 4)
 
		; Collect the alias values
		select into "nl:"
		  person_id           = pa.person_id
		from  person_alias            pa
		plan pa
		  where expand(nNum, 1, size(rPerson->persons, 5), pa.person_id, rPerson->persons[nNum].person_id)
		  and parser(cParser)
		  and pa.active_ind = 1
		  and pa.end_effective_dt_tm > sysdate
		order person_id
		head person_id
		    nPos = locateval(nNum, 1, size(rPerson->persons, 5), pa.person_id, rPerson->persons[nNum].person_id)
            nCount = 0
        detail
            nCount = nCount + 1
            stat = alterlist(rPerson->persons[nPos].aliases, nCount)
 
            rPerson->persons[nPos].aliases[nCount].alias_pool = uar_get_code_display(pa.alias_pool_cd)
            rPerson->persons[nPos].aliases[nCount].alias_type = uar_get_code_display(pa.person_alias_type_cd)
            rPerson->persons[nPos].aliases[nCount].alias_type_meaning = uar_get_code_meaning(pa.person_alias_type_cd)
            rPerson->persons[nPos].aliases[nCount].alias = pa.alias
            rPerson->persons[nPos].aliases[nCount].alias_formatted = cnvtalias(pa.alias, pa.alias_pool_cd)
            rPerson->persons[nPos].aliases[nCount].alias_sub_type = uar_get_code_display(pa.person_alias_sub_type_cd)
            rPerson->persons[nPos].aliases[nCount].visit_seq_nbr = pa.visit_seq_nbr
            rPerson->persons[nPos].aliases[nCount].health_card_province = pa.health_card_province
            rPerson->persons[nPos].aliases[nCount].health_card_ver_code = pa.health_card_ver_code
            rPerson->persons[nPos].aliases[nCount].health_card_issue_dt_tm = pa.health_card_issue_dt_tm
            rPerson->persons[nPos].aliases[nCount].health_card_expiry_dt_tm = pa.health_card_expiry_dt_tm
            rPerson->persons[nPos].aliases[nCount].health_card_type = pa.health_card_type
            rPerson->persons[nPos].aliases[nCount].alias_pool_cd = pa.alias_pool_cd
            rPerson->persons[nPos].aliases[nCount].person_alias_type_cd = pa.person_alias_type_cd
            rPerson->persons[nPos].aliases[nCount].person_alias_sub_type_cd = pa.person_alias_sub_type_cd
 
		with expand=2
    endif
 
	; Collect the person name information
	; -----------------------------------
	if (validate(payload->person->names, 0) = 1)
 
		; set the Parser
		call type_parser("pn.name_type_cd", 213)
 
		select into "nl:"
		  person_id           = pn.person_id
		from  person_name             pn
		plan pn
		  where expand(nNum, 1, size(rPerson->persons, 5), pn.person_id, rPerson->persons[nNum].person_id)
		  and parser(cParser)
		  and pn.active_ind = 1
		  and pn.end_effective_dt_tm > sysdate
		order person_id
		head person_id
		    nPos = locateval(nNum, 1, size(rPerson->persons, 5), pn.person_id, rPerson->persons[nNum].person_id)
            nCount = 0
        detail
            nCount = nCount + 1
            stat = alterlist(rPerson->persons[nPos].names, nCount)
 
            rPerson->persons[nPos].names[nCount].name_type = uar_get_code_display(pn.name_type_cd)
            rPerson->persons[nPos].names[nCount].name_type_meaning = uar_get_code_meaning(pn.name_type_cd)
            rPerson->persons[nPos].names[nCount].beg_effective_dt_tm = pn.beg_effective_dt_tm
            rPerson->persons[nPos].names[nCount].end_effective_dt_tm = pn.end_effective_dt_tm
            rPerson->persons[nPos].names[nCount].name_full_formatted = pn.name_full
            rPerson->persons[nPos].names[nCount].name_first = pn.name_first
            rPerson->persons[nPos].names[nCount].name_middle = pn.name_middle
            rPerson->persons[nPos].names[nCount].name_last = pn.name_last
            rPerson->persons[nPos].names[nCount].name_degree = pn.name_degree
            rPerson->persons[nPos].names[nCount].name_title = pn.name_title
            rPerson->persons[nPos].names[nCount].name_prefix = pn.name_prefix
            rPerson->persons[nPos].names[nCount].name_suffix = pn.name_suffix
            rPerson->persons[nPos].names[nCount].name_initials = pn.name_initials
            rPerson->persons[nPos].names[nCount].name_type_seq = pn.name_type_seq
            rPerson->persons[nPos].names[nCount].name_type_cd = pn.name_type_cd
        with expand=2
    endif
 
 
	; Collect the Prsnl relationships at the person level
	; ---------------------------------------------------
	if (validate(payload->person->prsnlreltn, 0) = 1)
 
		; set the Parser
		call type_parser("ppr.person_prsnl_r_cd", 331)
 
        select into "nl:"
            person_id       = ppr.person_id
        from    person_prsnl_reltn      ppr,
                prsnl                   p
        plan ppr
		  where expand(nNum, 1, size(rPerson->persons, 5), ppr.person_id, rPerson->persons[nNum].person_id)
		  and parser(cParser)
		  and ppr.active_ind = 1
		  and ppr.end_effective_dt_tm > sysdate
		join p
			where p.person_id = ppr.prsnl_person_id
		order person_id
		head person_id
		    nPos = locateval(nNum, 1, size(rPerson->persons, 5), ppr.person_id, rPerson->persons[nNum].person_id)
            nCount = 0
        detail
            nCount = nCount + 1
            stat = alterlist(rPerson->persons[nPos].prsnl_reltn, nCount)
 
            rPerson->persons[nPos].prsnl_reltn[nCount].reltn_type = uar_get_code_display(ppr.person_prsnl_r_cd)
            rPerson->persons[nPos].prsnl_reltn[nCount].reltn_type_meaning = uar_get_code_meaning(ppr.person_prsnl_r_cd)
            rPerson->persons[nPos].prsnl_reltn[nCount].person_id = p.person_id
            rPerson->persons[nPos].prsnl_reltn[nCount].priority_seq = ppr.priority_seq
            rPerson->persons[nPos].prsnl_reltn[nCount].prsnl_type = uar_get_code_display(p.prsnl_type_cd)
            rPerson->persons[nPos].prsnl_reltn[nCount].name_full_formatted = p.name_full_formatted
            rPerson->persons[nPos].prsnl_reltn[nCount].physician_ind = p.physician_ind
            rPerson->persons[nPos].prsnl_reltn[nCount].position = uar_get_code_display(p.position_cd)
            rPerson->persons[nPos].prsnl_reltn[nCount].name_last = p.name_last
            rPerson->persons[nPos].prsnl_reltn[nCount].name_first = p.name_first
            rPerson->persons[nPos].prsnl_reltn[nCount].user_name = p.username
            rPerson->persons[nPos].prsnl_reltn[nCount].person_prsnl_r_cd = ppr.person_prsnl_r_cd
            rPerson->persons[nPos].prsnl_reltn[nCount].prsnl_type_cd = p.prsnl_type_cd
            rPerson->persons[nPos].prsnl_reltn[nCount].position_cd = p.position_cd
 
        with expand=2
    endif
 
 
	; Collect the person relationships at the person level
	; ----------------------------------------------------
	if (validate(payload->person->personreltn, 0) = 1)
		; set the Parser
		call type_parser("ppr.person_reltn_type_cd", 351)
 
        select into "nl:"
            person_id               = ppr.person_id,
            person_reltn_type_cd	= ppr.person_reltn_type_cd,
			priority_seq			= ppr.priority_seq,
			internal_seq            = ppr.internal_seq,
		    person_person_reltn_id  = ppr.person_person_reltn_id
        from    person_person_reltn     ppr,
                person                  p
        plan ppr
		  where expand(nNum, 1, size(rPerson->persons, 5), ppr.person_id, rPerson->persons[nNum].person_id)
		  and parser(cParser)
		  and ppr.active_ind = 1
		  and ppr.end_effective_dt_tm > sysdate
		join p
			where p.person_id = ppr.related_person_id
		order person_id, person_reltn_type_cd, priority_seq, internal_seq, person_person_reltn_id desc
		head person_id
		    nPos = locateval(nNum, 1, size(rPerson->persons, 5), ppr.person_id, rPerson->persons[nNum].person_id)
            nCount = 0
        head person_reltn_type_cd
            x = 0
        head priority_seq
            x = 0
        head internal_seq
            nCount = nCount + 1
            stat = alterlist(rPerson->persons[nPos].person_reltn, nCount)
 
            rPerson->persons[nPos].person_reltn[nCount].person_reltn_type = uar_get_code_display(ppr.person_reltn_type_cd)
            rPerson->persons[nPos].person_reltn[nCount].person_reltn_type_meaning =
                                                                        uar_get_code_meaning(ppr.person_reltn_type_cd)
            rPerson->persons[nPos].person_reltn[nCount].person_reltn = uar_get_code_display(ppr.person_reltn_cd)
            rPerson->persons[nPos].person_reltn[nCount].related_person_reltn = uar_get_code_display(ppr.related_person_reltn_cd)
            rPerson->persons[nPos].person_reltn[nCount].person_id = ppr.related_person_id
            rPerson->persons[nPos].person_reltn[nCount].priority_seq = ppr.priority_seq
            rPerson->persons[nPos].person_reltn[nCount].internal_seq = ppr.internal_seq
            rPerson->persons[nPos].person_reltn[nCount].name_full_formatted = p.name_full_formatted
            rPerson->persons[nPos].person_reltn[nCount].name_last = p.name_last
            rPerson->persons[nPos].person_reltn[nCount].name_first = p.name_first
            rPerson->persons[nPos].person_reltn[nCount].name_middle = p.name_middle
            rPerson->persons[nPos].person_reltn[nCount].person_reltn_type_cd = ppr.person_reltn_type_cd
            rPerson->persons[nPos].person_reltn[nCount].person_reltn_cd = ppr.person_reltn_cd
            rPerson->persons[nPos].person_reltn[nCount].related_person_reltn_cd = ppr.related_person_reltn_cd
		with expand=2
 
    endif
 
	; Collect the Person Organization Relationships (e.g. Employer)
	; -------------------------------------------------------------
	if (validate(payload->person->orgreltn, 0) = 1)
 
		; set the Parser
		call type_parser("por.person_org_reltn_cd", 338)
 
        select into "nl:"
            person_id               = por.person_id
        from    person_org_reltn        por,
                organization            o
        plan por
            where expand(nNum, 1, size(rPerson->persons, 5), por.person_id, rPerson->persons[nNum].person_id)
            and parser(cParser)
            and por.active_ind = 1
            and por.end_effective_dt_tm > sysdate
        join o
            where o.organization_id = por.organization_id
		order person_id
		head person_id
		    nPos = locateval(nNum, 1, size(rPerson->persons, 5), por.person_id, rPerson->persons[nNum].person_id)
            nCount = 0
        detail
            nCount = nCount + 1
            stat = alterlist(rPerson->persons[nPos].person_org_reltn, nCount)
 
            rPerson->persons[nPos].person_org_reltn[nCount].person_org_reltn = uar_get_code_display(por.person_org_reltn_cd)
            rPerson->persons[nPos].person_org_reltn[nCount].person_org_reltn_meaning =
                                                                        uar_get_code_meaning(por.person_org_reltn_cd)
            rPerson->persons[nPos].person_org_reltn[nCount].organization_id = por.organization_id
            rPerson->persons[nPos].person_org_reltn[nCount].empl_type = uar_get_code_display(por.empl_type_cd)
            rPerson->persons[nPos].person_org_reltn[nCount].empl_status = uar_get_code_display(por.empl_status_cd)
            if (por.organization_id > 0)
                rPerson->persons[nPos].person_org_reltn[nCount].org_name = o.org_name
            else
                rPerson->persons[nPos].person_org_reltn[nCount].org_name = por.ft_org_name
            endif
            rPerson->persons[nPos].person_org_reltn[nCount].priority_seq = por.priority_seq
            rPerson->persons[nPos].person_org_reltn[nCount].person_org_reltn_cd = por.person_org_reltn_cd
            rPerson->persons[nPos].person_org_reltn[nCount].empl_type_cd = por.empl_type_cd
            rPerson->persons[nPos].person_org_reltn[nCount].empl_status_cd = por.empl_status_cd
        with expand=2
 
    endif
 
	; Collect the PERSON Info records
	; -------------------------------
	if (validate(payload->person->personinfo, 0) = 1)
 
		; set the Parser
		call type_parser("pi.info_sub_type_cd", 356)
 
		select into "nl:"
		  person_id                   = pi.person_id,
		  person_info_id              = pi.person_info_id,
		  person_code_value_r_id      = pcv.person_code_value_r_id
		from  person_info             pi,
		      person_code_value_r     pcv,
		      long_text               lt
		plan pi
            where expand(nNum, 1, size(rPerson->persons, 5), pi.person_id, rPerson->persons[nNum].person_id)
            and parser(cParser)
            and pi.active_ind = 1
            and pi.end_effective_dt_tm > sysdate
            and pi.active_status_cd = cv48_Active
        join pcv
            where pcv.person_id = outerjoin(pi.person_id)
            and pcv.code_value = outerjoin(pi.value_cd)
            and pcv.code_value > outerjoin(0)
            and pcv.active_ind = outerjoin(1)
            and pcv.active_status_cd = outerjoin(cv48_Active)
            and pcv.end_effective_dt_tm > outerjoin(sysdate)
        join lt
            where lt.long_text_id = outerjoin(pi.long_text_id)
            and lt.active_ind = outerjoin(1)
		order person_id, person_info_id, person_code_value_r_id
		head person_id
		    nPos = locateval(nNum, 1, size(rPerson->persons, 5), pi.person_id, rPerson->persons[nNum].person_id)
            nCount = 0
        head person_info_id
            cString = ""
        head person_code_value_r_id
            x = 0
        detail
            if (pcv.code_value > 0)
                if (trim(cString) != "")
                    cString = concat(trim(cString), ",")
                endif
                cString = trim(concat(trim(cString), " ", uar_get_code_display(pcv.code_value)),3)
            endif
        foot person_code_value_r_id
            x = 0
        foot person_info_id
            nCount = nCount + 1
            stat = alterlist(rPerson->persons[nPos].person_info, nCount)
 
            rPerson->persons[nPos].person_info[nCount].info_type = uar_get_code_display(pi.info_type_cd)
            rPerson->persons[nPos].person_info[nCount].info_type_meaning = uar_get_code_meaning(pi.info_type_cd)
            rPerson->persons[nPos].person_info[nCount].info_sub_type = uar_get_code_display(pi.info_sub_type_cd)
            rPerson->persons[nPos].person_info[nCount].info_sub_type_meaning = uar_get_code_meaning(pi.info_sub_type_cd)
            rPerson->persons[nPos].person_info[nCount].value_numeric_ind = pi.value_numeric_ind
            rPerson->persons[nPos].person_info[nCount].value_numeric = pi.value_numeric
            rPerson->persons[nPos].person_info[nCount].value_dt_tm = pi.value_dt_tm
            rPerson->persons[nPos].person_info[nCount].chartable_ind = pi.chartable_ind
            rPerson->persons[nPos].person_info[nCount].priority_seq = pi.priority_seq
            rPerson->persons[nPos].person_info[nCount].internal_seq = pi.internal_seq
            if (trim(cString) != "")
                rPerson->persons[nPos].person_info[nCount].value = cString
            else
                rPerson->persons[nPos].person_info[nCount].value = uar_get_code_display(pi.value_cd)
            endif
            rPerson->persons[nPos].person_info[nCount].long_text = lt.long_text
            rPerson->persons[nPos].person_info[nCount].info_type_cd = pi.info_type_cd
            rPerson->persons[nPos].person_info[nCount].info_sub_type_cd = pi.info_sub_type_cd
            rPerson->persons[nPos].person_info[nCount].value_cd = pi.value_cd
 
        with expand=2
    endif
 
    ; Collect the code value relationships
    if (validate(payload->person->personCodeReltn, 0) = 1)
        select into "nl:"
		  person_id                   = pcv.person_id,
		  code_set                    = pcv.code_set,
		  code_value                  = pcv.code_value,
		  display                     = uar_get_code_display(pcv.code_value)
		from  person_code_value_r     pcv
		plan pcv
            where expand(nNum, 1, size(rPerson->persons, 5), pcv.person_id, rPerson->persons[nNum].person_id)
            and pcv.active_ind = 1
            and pcv.active_status_cd = outerjoin(cv48_Active)
            and pcv.end_effective_dt_tm > outerjoin(sysdate)
        order person_id, code_set, display
		head person_id
		    nPos = locateval(nNum, 1, size(rPerson->persons, 5), pcv.person_id, rPerson->persons[nNum].person_id)
            nCount = 0
        detail
            nCount = nCount + 1
            stat = alterlist(rPerson->persons[nPos].person_code_reltn, nCount)
 
            rPerson->persons[nPos].person_code_reltn[nCount].person_code_value_r_id = pcv.person_code_value_r_id
            rPerson->persons[nPos].person_code_reltn[nCount].code_set = code_set
            rPerson->persons[nPos].person_code_reltn[nCount].code_value = code_value
            rPerson->persons[nPos].person_code_reltn[nCount].display = display
        with counter, expand=2
 
    endif
 
 

if (validate(payload->person->skipJSON, 0) = 0) 
    call add_standard_output(cnvtrectojson(rPerson, 4, 1))
endif
 
;call echorecord(rPerson)
 
#END_PROGRAM
 
 
END GO
/*************************************************************************
 
        Script Name:    1co_mpage_test_visit.prg
 
        Description:    Clinical Office - mPage Edition
                        Used to assign test visit from Activity Log
 
        Date Written:   November 28, 2022
        Written by:     John Simpson
                        Precision Healthcare Solutions
 
 *************************************************************************
            Copyright (c) 2022 Precision Healthcare Solutions
 
 NO PART OF THIS CODE MAY BE COPIED, MODIFIED OR DISTRIBUTED WITHOUT
 PRIOR WRITTEN CONSENT OF PRECISION HEALTHCARE SOLUTIONS EXECUTIVE
 LEADERSHIP TEAM.
 
 FOR LICENSING TERMS PLEASE VISIT www.clinicaloffice.com/mpage/license
 
 *************************************************************************
                            Special Instructions
 *************************************************************************
 Used from the Activity Log component to assign a new visit
 
 *************************************************************************
                            Revision Information
 *************************************************************************
 Rev    Date     By             Comments
 ------ -------- -------------- ------------------------------------------
 001    11/28/22 J. Simpson     Initial Development
 *************************************************************************/
drop program 1co3_mpage_test_visit:group1 go
create program 1co3_mpage_test_visit:group1
  
; Check to see if we have cleared the patient source and if not, do we have data in the patient source
; to run our custom CCL against.
if (validate(payload->customscript->clearpatientsource, 0) = 0)
	if (size(patient_source->patients, 5) = 0)
		go to end_program
	endif
endif

if (patient_source->visits[1].encntr_id > 0)

    ; Delete old values first
    delete from dm_info d
        where d.info_domain = "CLINICAL OFFICE"
        and d.info_name = "DEVELOPER TEST VISIT"
        and d.info_domain_id = reqinfo->updt_id
 
    ; Insert the new record
    insert into dm_info d
        set d.info_domain = "CLINICAL OFFICE",
            d.info_name = "DEVELOPER TEST VISIT",
            d.info_domain_id = reqinfo->updt_id,
            d.info_number = patient_source->visits[1].encntr_id
 
    commit

endif
  
#end_program
 
end go
/*************************************************************************
 
        Script Name:    1co_code_value_search.prg
 
        Description:    Clinical Office - mPage Edition
                        Code Value Search Component CCL Support Script
 
        Date Written:   March 3, 2022
        Written by:     John Simpson
                        Precision Healthcare Solutions
 
 *************************************************************************
            Copyright (c) 2022 Precision Healthcare Solutions
 
 NO PART OF THIS CODE MAY BE COPIED, MODIFIED OR DISTRIBUTED WITHOUT
 PRIOR WRITTEN CONSENT OF PRECISION HEALTHCARE SOLUTIONS EXECUTIVE
 LEADERSHIP TEAM.
 
 FOR LICENSING TERMS PLEASE VISIT www.clinicaloffice.com/mpage/license
 
 *************************************************************************
                            Special Instructions
 *************************************************************************
 Called from select component
 *************************************************************************
                            Revision Information
 *************************************************************************
 Rev    Date     By             Comments
 ------ -------- -------------- ------------------------------------------
 001    03/03/22 J. Simpson     Initial Development
 002    09/21/22 J. Simpson     Added code set limits to allow initial filtering of list
 003    07/24/23 J. Simpson     Fixed search values with comma to prevent split of data
 *************************************************************************/
drop program 1co_code_value_search:group1 go
create program 1co_code_value_search:group1
 
; Check to see if we have cleared the patient source and if not, do we have data in the patient source
; to run our custom CCL against.
if (validate(payload->customscript->clearpatientsource, 0) = 0)
	if (size(patient_source->patients, 5) = 0)
		go to end_program
	endif
endif


; Declare variables and subroutines
declare nNum = i4
declare nDefault = i4
  
; Clear and define rCustom structure
free record rCustom
record rCustom (
    1 status
        2 error_ind             = i4
        2 message               = vc
    1 data[*]
        2 key                   = f8
        2 value                 = vc      
)

; Define and populate the parameters structure
free record rParam
record rParam (
    1 search_ind                = i4
    1 search_limit              = i4
    1 physician_ind             = i4
    1 code_set                  = i4
    1 value_type                = vc
    1 search_value              = vc
    1 limit_type                = vc
    1 limits[*]                 = vc
    1 default[*]               = f8
)

set rParam->search_ind = payload->customscript->script[nscript]->parameters->search
set rParam->search_limit = payload->customscript->script[nscript]->parameters->searchlimit
set rParam->physician_ind = payload->customscript->script[nscript]->parameters->physicianind
set rParam->code_set= payload->customscript->script[nscript]->parameters->codeset
set rParam->value_type = cnvtupper(payload->customscript->script[nscript]->parameters->valuetype)
set rParam->search_value = cnvtupper(payload->customscript->script[nscript]->parameters->searchvalue)
set rParam->limit_type = cnvtupper(payload->customscript->script[nscript]->parameters->codeSetLimitType)

if (size(payload->customscript->script[nscript]->parameters->codeSetLimits, 5) > 0)
    set stat = alterlist(rParam->limits, size(payload->customscript->script[nscript]->parameters->codeSetLimits, 5))
    for (nLoop = 1 to size(rParam->limits, 5))
        set rParam->limits[nLoop] = payload->customscript->script[nscript]->parameters->codeSetLimits[nLoop]
    endfor
endif

if (validate(payload->customscript->script[nscript]->parameters->default) = 1)
    if (size(payload->customscript->script[nscript]->parameters->default, 5) > 0)
        set stat = alterlist(rParam->default, size(payload->customscript->script[nscript]->parameters->default, 5))
        for (nLoop = 1 to size(rParam->default, 5))
            set rParam->default[nLoop] = cnvtreal(payload->customscript->script[nscript]->parameters->default[nLoop])
        endfor
    endif
endif    

call echorecord(payload->customscript->script[nscript]->parameters)
call echorecord(rParam)
 
; Custom parser declarations
declare cParser = vc with noconstant("1=1")
if (rParam->search_value != "")

    ; Build the parser
    set cParser = concat(^cnvtupper(cv.^, rParam->value_type,  ^) = patstring(|^,
                                    trim(rParam->search_value), ^*|)^)

endif

; Build a parser for default values                                    
declare cDefaultParser = vc with noconstant("1=1")
if (size(rParam->default, 5) > 0)
    set cDefaultParser = ^expand(nNum, 1, size(rParam->default, 5), cv.code_value, cnvtreal(rParam->default[nNum]))^
    set nDefault = 1
endif

declare cLimitParser = vc with noconstant("1=1")
if (size(rParam->limits, 5) > 0 and rParam->limit_type in 
        ("CDF_MEANING","DISPLAY","DISPLAY_KEY","DESCRIPTION","DEFINITION","CKI","CONCEPT_CKI"))
    set cLimitParser = concat(^expand(nNum, 1, size(rParam->limits, 5), cv.^, rParam->limit_type, 
                        ^, rParam->limits[nNum])^)
endif

; Perform a limit check to determine if too many values exist to upload
; ---------------------------------------------------------------------
if (rParam->search_limit > 0)
    
    ; Perform your select to count the results you are after
    select into "nl:"
        row_count   = count(cv.code_value)
    from    code_value      cv
    plan cv
        where cv.code_set = rParam->code_set
        and parser(cParser)
        and parser(cLimitParser)
        and cv.active_ind = 1
        and cv.end_effective_dt_tm > sysdate
        
    ; WARNING: Avoid modifying the detail section below or your code may fail
    detail
        if (row_count > rParam->search_limit and size(rParam->default, 5) = 0)
            rCustom->status->error_ind = 1
            rCustom->status->message = concat(build(cnvtint(row_count)), " records retrieved. Limit is ", 
                                        build(rParam->search_limit), ".")
        endif            
    with expand=1, nocounter        
    
endif

; Perform the load if search limit does not fail
if (rCustom->status->error_ind = 0 or nDefault = 1)

    set rCustom->status.message = "No records qualified."

    select into "nl:"
        display_value   = if (rParam->value_type = "DISPLAY_KEY")
                            cv.display_key
                          elseif (rParam->value_type = "DESCRIPTION")
                            cv.description
                          elseif (rParam->value_type = "DEFINITION")
                            cv.definition
                          else
                            cv.display
                          endif
    from    code_value      cv
    plan cv
        where cv.code_set = rParam->code_set
        and parser(cParser)
        and parser(cLimitParser)
        and parser(cDefaultParser)
        and cv.active_ind = 1
        and cv.end_effective_dt_tm > sysdate
    order display_value        
    head report
        rCustom->status.message = "Ok."
        nCount = 0
        
    ; WARNING: Detail section must write to rCustom->data[].key and rCustom->data[].value        
    detail
        nCount = nCount + 1
        stat = alterlist(rCustom->data, nCount)
        rCustom->data[nCount].key = cv.code_value
        rCustom->data[nCount].value = display_value
        
    with expand=1, counter        

endif
 
; ------------------------------------------------------------------------------------------------
;								END OF YOUR CUSTOM CODE
; ------------------------------------------------------------------------------------------------
 
; If you wish to return output back to the mPage, you need to run the ADD_CUSTOM_OUTPUT function.
; Any valid JSON format is acceptable including the CNVTRECTOJSON function. If using
; CNVTRECTOJSON be sure to use parameters 4 and 1 as shown below.
; If you plan on creating your own JSON string rather than converting a record structure, be
; sure to have it in the format of {"name":{your custom json data}} as the ADD_CUSTOM_OUTPUT
; subroutine will extract the first sub-object from the JSON. (e.g. {"name":{"personId":123}} will
; be sent to the output stream as {"personId": 123}.
call add_custom_output(cnvtrectojson(rCustom, 4, 1))
 
#end_program
 
end go
/*************************************************************************
 
        Script Name:    1CO_CONVERT_BLOB.PRG
 
        Description:    Clinical Office - mPage Edition
        				Uses TDBExecute statement to convert Blobs between
        				formats (e.g. Postscript to RTF to HTML
 
        Date Written:   November 10, 2021
        Written by:     John Simpson
                        Precision Healthcare Solutions
 
 *************************************************************************
		   Copyright (c) 2021 Precision Healthcare Solutions
 
 NO PART OF THIS CODE MAY BE COPIED, MODIFIED OR DISTRIBUTED WITHOUT
 PRIOR WRITTEN CONSENT OF PRECISION HEALTHCARE SOLUTIONS EXECUTIVE
 LEADERSHIP TEAM.
 
 FOR LICENSING TERMS PLEASE VISIT www.clinicaloffice.com/mpage/license
 
 *************************************************************************
                            Special Instructions
 *************************************************************************
 1. Execute this script in your CCL script.
 2. Populate co_blob_events from inside your CCL script.
 3. call convert_blob(format) where format is your desired format (e.g. HTML, PDF, RTF)
 4. Copy the contents of co_blob_events[]->converted_text to where you need it.
 
 Any format other than AS (ASCII text) will be Hex Encoded
 *************************************************************************
                            Revision Information
 *************************************************************************
 Rev    Date     By             Comments
 ------ -------- -------------- ------------------------------------------
 001    11/10/21 J. Simpson     Initial Development
 002    05/12/22 J. Simpson     Created convert_text routine to allow passing non-blob content
 *************************************************************************/
 
drop program 1co_convert_blob:group1 go
create program 1co_convert_blob:group1
 
; Set the absolute maximum possible variable length
set modify maxvarlen 268435456
 
; Define temporary structure
free record co_blob_events
record co_blob_events (
    1 data[*]
        2 event_id              = f8
        2 original_format_cd    = f8
        2 original_text         = vc
        2 converted_text        = vc
) with persist
 
; Misc variables
free define nNum
declare nNum = i4 with persist
 
; Define the conversion function
declare convert_blob(cFormat=vc)=null with persist
declare convert_text(cFormatTo=vc)=null with persist

; Convert CE_BLOB data 
subroutine convert_blob(cFormat)
 
    ; Declare blob working variables
    declare good_blob = vc
    declare outbuf = c32768
    declare blobout = vc
    declare retlen = i4
    declare offset = i4
    declare newsize = i4
    declare finlen = i4
    declare xlen=i4 
 
    ; Declare Code Values
    declare cv8_Auth = f8 with noconstant(uar_get_code_by("MEANING", 8, "AUTH"))
    declare cv8_Modified = f8 with noconstant(uar_get_code_by("MEANING", 8, "MODIFIED"))
    declare cv15751_True = f8 with noconstant(uar_get_code_by("MEANING", 15751, "T"))
 
 
    ; Read the blob results
    if (size(co_blob_events->data, 5) > 0)
 
        select into "nl:"
        from	ce_blob_result          cbr,
                ce_blob	                cb
        plan cbr
            where expand(nNum, 1, size(co_blob_events->data, 5), cbr.event_id, co_blob_events->data[nNum].event_id)
            and cbr.valid_until_dt_tm > sysdate
        join cb
	       where cb.event_id = cbr.event_id
	       and cb.valid_until_dt_tm > sysdate
        order cb.event_id, cb.blob_seq_num
        head cb.event_id
            for (x = 1 to (cb.blob_length/32768))
                blobout = notrim(concat(notrim(blobout),notrim(fillstring(32768, " "))))
            endfor
            finlen = mod(cb.blob_length,32768)
 
            blobout = notrim(concat(notrim(blobout),notrim(substring(1,finlen,fillstring(32768, " ")))))
 
            good_blob = " "	; Clear the last value
        detail
            retlen = 1
            offset = 0
 
            while (retlen > 0)
                retlen = blobget(outbuf, offset, cb.blob_contents)
                offset = offset + retlen
                if(retlen != 0)
                    xlen = findstring("OCF_BLOB",outbuf,1)-1
 
                    if(xlen<1)
                        xlen = retlen
                    endif
 
                    good_blob = notrim(concat(notrim(good_blob), notrim(substring(1,xlen,outbuf))))
                endif
            endwhile
        foot cb.event_id
            newsize = 0
            good_blob = concat(notrim(good_blob),"OCF_BLOB")
            blob_un = uar_ocf_uncompress(good_blob, size(good_blob),
                            blobout, size(blobout), newsize)
 
            ; Write to memory
            nPos = locateval(nNum, 1, size(co_blob_events->data, 5), cbr.event_id, co_blob_events->data[nNum].event_id)
            co_blob_events->data[nPos].original_format_cd = cbr.format_cd
            co_blob_events->data[nPos].original_text = substring(1, newsize, blobout)
        with expand=1, rdbarrayfetch = 1

        ; Convert the text
        call convert_text(cFormat)
 
    endif
end

; Convert the text
subroutine convert_text(cFormat)

    declare cEncoded = vc
    declare iBase64Size = i4
 
    declare uar_si_encode_base64((p1=vc(ref)),(p2=i4(ref)),(p3=i4(ref)))=vc


    free record 969553_request
    record 969553_request (
        1 desired_format_cd = f8
        1 origin_format_cd = f8
        1 origin_text = gvc
        1 page_height = vc
        1 page_width = vc
        1 page_margin_top = vc
        1 page_margin_bottom = vc
        1 page_margin_left = vc
        1 page_margin_right = vc
    )
 
    free record 969553_reply
    record 969553_reply (
        1 converted_text = gvc
        1 status_data
            2 status = c1
            2 subeventstatus [*]
                3 OperationName = c25
                3 OperationStatus = c1
                3 TargetObjectName = c25
                3 TargetObjectValue = vc
    )

    ; Loop through each result and perform the conversion
    for (nLoop = 1 to size(co_blob_events->data, 5))
        set stat = initrec(969553_request)
        set stat = initrec(969553_reply)
 
        set 969553_request->origin_text = trim(co_blob_events->data[nLoop].original_text)
        set 969553_request->origin_format_cd = co_blob_events->data[nLoop].original_format_cd
        set 969553_request->desired_format_cd = value(uar_get_code_by("MEANING", 23, cnvtupper(cFormat)))
 
        ; Execute the conversion
        set stat = tdbexecute(3202004, 3202004, 969553, "REC", 969553_request, "REC", 969553_reply)
 
        ; Write the reply back
        if (969553_reply->status_data->status = "S")
            if (cnvtupper(cFormat) = "AS")
                set co_blob_events->data[nLoop].converted_text = 969553_reply->converted_text
            else
                ; Convert non-text to hex to prevent html send errors
                set co_blob_events->data[nLoop].converted_text = cnvtrawhex(969553_reply->converted_text)
            endif
        endif
    endfor

end
 
end go
/*************************************************************************
 
        Script Name:    1co_custom_ping.prg
 
        Description:    Clinical Office - mPage Edition
                        Used to perform a ping to the domain for callbacks
 
        Date Written:   November 22, 2022
        Written by:     John Simpson
                        Precision Healthcare Solutions
 
 *************************************************************************
            Copyright (c) 2022 Precision Healthcare Solutions
 
 NO PART OF THIS CODE MAY BE COPIED, MODIFIED OR DISTRIBUTED WITHOUT
 PRIOR WRITTEN CONSENT OF PRECISION HEALTHCARE SOLUTIONS EXECUTIVE
 LEADERSHIP TEAM.
 
 FOR LICENSING TERMS PLEASE VISIT www.clinicaloffice.com/mpage/license
 
 *************************************************************************
                            Special Instructions
 *************************************************************************
 None
  
 *************************************************************************
                            Revision Information
 *************************************************************************
 Rev    Date     By             Comments
 ------ -------- -------------- ------------------------------------------
 001    11/22/22 J. Simpson     Initial Development
 *************************************************************************/
drop program 1co_custom_ping:group1 go
create program 1co_custom_ping:group1
 
; Check to see if we have cleared the patient source and if not, do we have data in the patient source
; to run our custom CCL against.
if (validate(payload->customscript->clearpatientsource, 0) = 0)
	if (size(patient_source->patients, 5) = 0)
		go to end_program
	endif
endif
 
free record rCustom
record rCustom (
	1 ping                        = vc
)

set rCustom->ping = "pong"
 
call add_custom_output(cnvtrectojson(rCustom, 4, 1))
 
#end_program
 
end go
/*************************************************************************
 
        Script Name:    1co_enc_search.prg
 
        Description:    Clinical Office - mPage Edition
                        Person/Encounter Search Component CCL Support Script
 
        Date Written:   March 3, 2022
        Written by:     John Simpson
                        Precision Healthcare Solutions
 
 *************************************************************************
            Copyright (c) 2022 Precision Healthcare Solutions
 
 NO PART OF THIS CODE MAY BE COPIED, MODIFIED OR DISTRIBUTED WITHOUT
 PRIOR WRITTEN CONSENT OF PRECISION HEALTHCARE SOLUTIONS EXECUTIVE
 LEADERSHIP TEAM.
 
 FOR LICENSING TERMS PLEASE VISIT www.clinicaloffice.com/mpage/license
 
 *************************************************************************
                            Special Instructions
 *************************************************************************
 Called from Patient/Encounter search component
 *************************************************************************
                            Revision Information
 *************************************************************************
 Rev    Date     By             Comments
 ------ -------- -------------- ------------------------------------------
 001    03/03/22 J. Simpson     Initial Development
 *************************************************************************/
drop program 1co_enc_search:group1 go
create program 1co_enc_search:group1
 
; Check to see if we have cleared the patient source and if not, do we have data in the patient source
; to run our custom CCL against.
if (validate(payload->customscript->clearpatientsource, 0) = 0)
	if (size(patient_source->patients, 5) = 0)
		go to end_program
	endif
endif
 
; Clear and define rCustom structure
free record rCustom
record rCustom (
    1 status
        2 type                  = vc
        2 message               = vc
        2 code                  = i4
)

free record rTemp
record rTemp (
    1 qual_match                = i4       ; Global Qualification Match Level
    1 data[*]
        2 person_id             = f8
        2 encntr_id             = f8
        2 qual_match            = i4       ; Person/Encounter specific Qualification Match Level
)
 
; Declare variables and subroutines
declare nNum = i4
set rCustom->status->type = "person"
declare addTemp(nPersonId=f8, nEncntrId=f8, nForceAdd=i4)=null
subroutine addTemp(nPersonId, nEncntrId, nForceAdd)
    if (nForceAdd = 1)
        set nNum = 0
    else
        set nNum = locateval(nNum, 1, size(rTemp->data, 5), nPersonId, rTemp->data[nNum].person_id)
    endif
            
    if (nNum > 0)
        call echorecord(rTemp->data[nNum])
        if (nEncntrId in (0.0, rTemp->data[nNum].encntr_id))
            set rTemp->data[nNum].qual_match = rTemp->data[nNum].qual_match + 1
        endif
    else
        set stat = alterlist(rTemp->data, size(rTemp->data, 5)+1)
        set rTemp->data[size(rTemp->data, 5)].person_id = nPersonId
        set rTemp->data[size(rTemp->data, 5)].encntr_id = nEncntrId
        set rTemp->data[size(rTemp->data, 5)].qual_match = 1
    endif
end
 
; Collect code values
declare cv48_Active = f8 with noconstant(uar_get_code_by("MEANING", 48, "ACTIVE"))
declare cv302_Person = f8 with noconstant(uar_get_code_by("MEANING", 302, "PERSON"))

; Search ENCNTR_ALIAS
if (validate(payload->customscript->script[nscript]->parameters->encntrAlias) > 0)
    set rTemp->qual_match = rTemp->qual_match + 
        size(payload->customscript->script[nscript]->parameters->encntrAlias, 5)   ; Update the qualification check level
    
    select into "nl:"
        person_id           = e.person_id
    from    encntr_alias            ea,
            encounter               e
    plan ea
        where expand(nNum, 1, size(payload->customscript->script[nscript]->parameters->encntrAlias, 5), ea.alias, 
                payload->customscript->script[nscript]->parameters->encntrAlias[nNum].alias,
                ea.encntr_alias_type_cd, 
                uar_get_code_by("MEANING", 319, payload->customscript->script[nscript]->parameters->encntrAlias[nNum].cdfMeaning))
        and ea.active_status_cd = cv48_Active
        and ea.active_ind = 1
        and ea.end_effective_dt_tm > sysdate
    join e
        where e.encntr_id = ea.encntr_id        
    order person_id        
    detail        
        call addTemp(person_id, ea.encntr_id, 0)
    with expand=1, counter        
endif

; Search PERSON_ALIAS
if (validate(payload->customscript->script[nscript]->parameters->personAlias) > 0)
    set rTemp->qual_match = rTemp->qual_match + 
            size(payload->customscript->script[nscript]->parameters->personAlias, 5)   ; Update the qualification check level
    
    select into "nl:"
        person_id           = pa.person_id
    from    person_alias            pa
    plan pa
        where expand(nNum, 1, size(payload->customscript->script[nscript]->parameters->personAlias, 5), pa.alias, 
                payload->customscript->script[nscript]->parameters->personAlias[nNum].alias,
                pa.person_alias_type_cd, 
                uar_get_code_by("MEANING", 4, payload->customscript->script[nscript]->parameters->personAlias[nNum].cdfMeaning))
        and pa.active_status_cd = cv48_Active
        and pa.active_ind = 1
        and pa.end_effective_dt_tm > sysdate
    order person_id        
    detail        
        call addTemp(person_id, 0.0, 0)
    with expand=1, counter        
endif

; Search the PERSON table
declare cFirstName = vc
declare cLastName = vc
declare dBirthDate = dq8
declare cPersonSearchParser = vc with noconstant("1=1")
declare nPersonCount = i4

; Setup name values
if (validate(payload->customscript->script[nscript]->parameters->fullname) > 0)
    set cLastName = trim(cnvtupper(piece(payload->customscript->script[nscript]->parameters->fullname, "," , 1,
                            payload->customscript->script[nscript]->parameters->fullname)),3)
    set cFirstName = trim(cnvtupper(piece(payload->customscript->script[nscript]->parameters->fullname, "," , 2, "")),3)
endif

if (validate(payload->customscript->script[nscript]->parameters->lastname) > 0)
    set cLastName = cnvtupper(payload->customscript->script[nscript]->parameters->lastname)
endif

if (validate(payload->customscript->script[nscript]->parameters->firstname) > 0)
    set cFirstName = cnvtupper(payload->customscript->script[nscript]->parameters->firstname)
endif

if (size(cFirstName) > 0)
    set cPersonSearchParser = "p.name_first_key = patstring(cFirstName)"
endif

; Setup DOB values
if (validate(payload->customscript->script[nscript]->parameters->birthdate) > 0)
    set dBirthDate = payload->customscript->script[nscript]->parameters->birthdate

    set cPersonSearchParser = concat(trim(cPersonSearchParser), 
            ^ and p.birth_dt_tm between cnvtdatetime("^, format(dBirthDate, ^DD-MMM-YYYY;;D^),
            ^") and cnvtdatetime("^, format(dBirthDate, ^DD-MMM-YYYY 23:59:59;;D^), ^")^)
endif

; Setup SexCd values
if (validate(payload->customscript->script[nscript]->parameters->sexCd) > 0)
    if (payload->customscript->script[nscript]->parameters->sexCd > 0)
        set cPersonSearchParser = concat(trim(cPersonSearchParser), 
            ^ and p.sex_cd = ^, cnvtstring(cnvtreal(payload->customscript->script[nscript]->parameters->sexCd)))
    endif            
endif

; Collect a count of the last name
if (size(cLastName) > 1)
    set rTemp->qual_match = rTemp->qual_match + 1

    select into "nl:"
        personCount = count(p.person_id)
    from    person          p
    plan    p
        where p.name_last_key = patstring(cLastName)
        and parser(cPersonSearchParser)
        and exists (select pp.person_id from person_patient pp where pp.person_id = p.person_id)
        and p.person_type_cd = cv302_Person
        and p.active_ind = 1
        and p.active_status_cd = cv48_Active
    detail
        nPersonCount = personCount
        if (personCount > 1000)
            rCustom->status.code = 1000
            rCustom->status.message = concat("More than 1000 patients returned. Please modify your search.")
        endif
    with counter        

    ; Only process up to 1000 patients.
    if (nPersonCount <= 1000)
    
    select into "nl:"
    from    person          p
    plan    p
        where p.name_last_key = patstring(cLastName)
        and parser(cPersonSearchParser)
        and p.person_type_cd = cv302_Person
        and exists (select pp.person_id from person_patient pp where pp.person_id = p.person_id)
        and p.active_ind = 1
        and p.active_status_cd = cv48_Active
    detail
        call addTemp(p.person_id, 0.0, 0)        
    with counter        
    
    endif
endif

; Collect encounters for the selected person_id
if (validate(payload->customscript->script[nscript]->parameters->personId) > 0)

    if (payload->customscript->script[nscript]->parameters->personId > 0)
        set rCustom->status->type = "encounter"
    endif        
    
    select into "nl:"
    from    encounter           e
    plan e
        where e.person_id = payload->customscript->script[nscript]->parameters->personId
        and e.person_id > 0.0
        and e.active_status_cd = cv48_Active
        and e.active_ind = 1
        and e.end_effective_dt_tm > sysdate
    head report
        rTemp->qual_match = rTemp->qual_match + 1        
    detail
        call addTemp(e.person_id, e.encntr_id, 1)
    with counter
    
endif

; Update the Patient Source with the valid qualifiers
for (nLoop = 1 to size(rTemp->data, 5))
    if (rTemp->data[nLoop].qual_match = rTemp->qual_match)
        ; Person Level
        set nNum = locateval(nNum, 1, size(patient_source->patients, 5), rTemp->data[nLoop].person_id, 
                                    patient_source->patients[nNum].person_id)
        if (nNum = 0)
            set stat = alterlist(patient_source->patients, size(patient_source->patients, 5) + 1)
            set patient_source->patients[size(patient_source->patients, 5)].person_id = rTemp->data[nLoop].person_id
        endif            
        
        ; Encounter Level
        if (rTemp->data[nLoop].encntr_id > 0.0)
            set stat = alterlist(patient_source->visits, size(patient_source->visits, 5) + 1)
            set patient_source->visits[size(patient_source->visits, 5)].person_id = rTemp->data[nLoop].person_id
            set patient_source->visits[size(patient_source->visits, 5)].encntr_id = rTemp->data[nLoop].encntr_id
        endif
    endif
endfor

; Update the status values
if (rCustom->status.code = 0)
    if (size(patient_source->patients, 5) = 0 or 
        (payload->customscript->script[nscript]->parameters->personId > 0 and size(patient_source->visits, 5) = 0))
        set rCustom->status.code = 99
        set rCustom->status.message = "No records qualified."
    endif        
endif

call add_custom_output(cnvtrectojson(rCustom, 4, 1))
 
#end_program
 
end go
/*************************************************************************
 
        Script Name:    1co_enc_search_data.prg
 
        Description:    Clinical Office - mPage Edition
                        Person/Encounter Search Component Data CCL Support Script
 
        Date Written:   March 3, 2022
        Written by:     John Simpson
                        Precision Healthcare Solutions
 
 *************************************************************************
            Copyright (c) 2022 Precision Healthcare Solutions
 
 NO PART OF THIS CODE MAY BE COPIED, MODIFIED OR DISTRIBUTED WITHOUT
 PRIOR WRITTEN CONSENT OF PRECISION HEALTHCARE SOLUTIONS EXECUTIVE
 LEADERSHIP TEAM.
 
 FOR LICENSING TERMS PLEASE VISIT www.clinicaloffice.com/mpage/license
 
 *************************************************************************
                            Special Instructions
 *************************************************************************
 Called from Patient/Encounter search component and used to display the
 output for collected person/encounter records.
 *************************************************************************
                            Revision Information
 *************************************************************************
 Rev    Date     By             Comments
 ------ -------- -------------- ------------------------------------------
 001    03/03/22 J. Simpson     Initial Development
 *************************************************************************/
drop program 1co_enc_search_data:group1 go
create program 1co_enc_search_data:group1
 
; Check to see if we have cleared the patient source and if not, do we have data in the patient source
; to run our custom CCL against.
if (validate(payload->customscript->clearpatientsource, 0) = 0)
	if (size(patient_source->patients, 5) = 0)
		go to end_program
	endif
endif
 
; Clear and define rCustom structure
free record rCustom
record rCustom (
    1 person[*]
        2 person_id             = f8
        2 name                  = vc
        2 mrn                   = vc
        2 sex                   = vc
        2 birth_date            = dq8
        2 age                   = vc
        2 ethnic_group          = vc
    1 encounter[*]
        2 encntr_id             = f8
        2 person_id             = f8
        2 fin_number            = vc
        2 facility              = vc
        2 nurse_unit            = vc
        2 room_bed              = vc
        2 reg_dt_tm             = dq8
        2 disch_dt_tm           = dq8
        2 medical_service       = vc
        2 encounter_type        = vc
        2 attending_physician   = vc
)
 
; Declare variables and subroutines
declare nNum = i4
 
; Collect code values
declare cv48_Active = f8 with noconstant(uar_get_code_by("MEANING", 48, "ACTIVE"))
declare cv4_MRN = f8 with noconstant(uar_get_code_by("MEANING", 4, "MRN"))
declare cv319_FinNbr = f8 with noconstant(uar_get_code_by("MEANING", 319, "FIN NBR"))
declare cv333_AttendDoc = f8 with noconstant(uar_get_code_by("MEANING", 333, "ATTENDDOC"))

; Collect the person level data
if (size(patient_source->patients, 5) > 0)

    select into "nl:"
        name            = p.name_full_formatted
    from    person              p,
            person_alias        pa
    plan p
        where expand(nNum, 1, size(patient_source->patients, 5), p.person_id, patient_source->patients[nNum].person_id)
        and p.active_status_cd = cv48_Active
    join pa
        where pa.person_id = outerjoin(p.person_id)
        and pa.person_alias_type_cd = outerjoin(cv4_MRN)
        and pa.active_status_cd = outerjoin(cv48_Active)
        and pa.active_ind = outerjoin(1)
        and pa.end_effective_dt_tm > outerjoin(sysdate)
    order name, p.person_id
    head report
        nCount = 0
    head name
        x = 0
    head p.person_id
        nCount = nCount + 1
        stat = alterlist(rCustom->person, nCount)
        
        rCustom->person[nCount].person_id = p.person_id
        rCustom->person[nCount].name = p.name_full_formatted
        rCustom->person[nCount].mrn = cnvtalias(pa.alias, pa.alias_pool_cd)
        rCustom->person[nCount].sex = uar_get_code_display(p.sex_cd)
        rCustom->person[nCount].birth_date = p.birth_dt_tm
        rCustom->person[nCount].age = trim(cnvtage(p.birth_dt_tm),3)
        rCustom->person[nCount].ethnic_group = uar_get_code_display(p.ethnic_grp_cd)
    with expand=1
endif

; Collect the encounter level data
if (size(patient_source->visits, 5) > 0)

    select into "nl:"
        person_id             = e.person_id,
        encntr_id             = e.encntr_id,
        sort_key_1            = format(e.disch_dt_tm, "yyyymmddhhmm;;d"),
        sort_key_2            = format(e.reg_dt_tm, "yyyymmddhhmm;;d")
    from    encounter           e,
            encntr_alias        ea
    plan e
        where expand(nNum, 1, size(patient_source->visits, 5), e.encntr_id, patient_source->visits[nNum].encntr_id)
        and e.active_status_cd = cv48_Active
    join ea
        where ea.encntr_id = outerjoin(e.encntr_id)
        and ea.encntr_alias_type_cd = outerjoin(cv319_FinNbr)
        and ea.active_status_cd = outerjoin(cv48_Active)
        and ea.active_ind = outerjoin(1)
        and ea.end_effective_dt_tm > outerjoin(sysdate)
    order person_id, sort_key_1, sort_key_2 desc, encntr_id
    head report
        nCount = 0
    head person_id
        x = 0
    head sort_key_1
        x = 0
    head sort_key_2
        x = 0                
    head encntr_id
        nCount = nCount + 1
        stat = alterlist(rCustom->encounter, nCount)
        
        rCustom->encounter[nCount].encntr_id = e.encntr_id
        rCustom->encounter[nCount].person_id = e.person_id
        rCustom->encounter[nCount].medical_service = uar_get_code_display(e.med_service_cd)
        rCustom->encounter[nCount].facility = uar_get_code_display(e.loc_facility_cd)
        rCustom->encounter[nCount].nurse_unit = uar_get_code_display(e.loc_nurse_unit_cd)
        if (e.loc_bed_cd > 0.0)
            rCustom->encounter[nCount].room_bed = concat(trim(uar_get_code_display(e.loc_room_cd)), "-",
                                    trim(uar_get_code_display(e.loc_bed_cd)))
        else                                    
            rCustom->encounter[nCount].room_bed = uar_get_code_display(e.loc_room_cd)
        endif
        rCustom->encounter[nCount].reg_dt_tm = e.reg_dt_tm
        rCustom->encounter[nCount].disch_dt_tm = e.disch_dt_tm
        rCustom->encounter[nCount].fin_number = cnvtalias(ea.alias, ea.alias_pool_cd)
        rCustom->encounter[nCount].encounter_type = uar_get_code_display(e.encntr_type_cd)
    with expand=1
    
    ; Collect the attending physician
    select into "nl:"
    from    encntr_prsnl_reltn          epr,
            prsnl                       p
    plan epr
        where expand(nNum, 1, size(rCustom->encounter, 5), epr.encntr_id, rCustom->encounter[nNum].encntr_id)
        and epr.encntr_prsnl_r_cd = cv333_AttendDoc
        and epr.active_ind = 1
        and epr.active_status_cd = cv48_Active
        and epr.end_effective_dt_tm > sysdate
    join p
        where p.person_id = epr.prsnl_person_id
    detail
        nPos = locateval(nNum, 1, size(rCustom->encounter, 5), epr.encntr_id, rCustom->encounter[nNum].encntr_id)
        rCustom->encounter[nPos].attending_physician = p.name_full_formatted
    with expand=1        
     
endif
 
 
; ------------------------------------------------------------------------------------------------
;								END OF YOUR CUSTOM CODE
; ------------------------------------------------------------------------------------------------
 
; If you wish to return output back to the mPage, you need to run the ADD_CUSTOM_OUTPUT function.
; Any valid JSON format is acceptable including the CNVTRECTOJSON function. If using
; CNVTRECTOJSON be sure to use parameters 4 and 1 as shown below.
; If you plan on creating your own JSON string rather than converting a record structure, be
; sure to have it in the format of {"name":{your custom json data}} as the ADD_CUSTOM_OUTPUT
; subroutine will extract the first sub-object from the JSON. (e.g. {"name":{"personId":123}} will
; be sent to the output stream as {"personId": 123}.
call add_custom_output(cnvtrectojson(rCustom, 4, 1))
 
#end_program
 
end go
/*************************************************************************
 
        Script Name:    1co_get_patient_list.prg
 
        Description:    Populate PATIENT_SOURCE structure with a patient list
        				based on the input of a PATIENT_LIST_ID value.
 
        Date Written:   July 22, 2019
        Written by:     John Simpson
                        Precision Healthcare Solutions
 
 *************************************************************************
                            Special Instructions
 *************************************************************************
 1. None
 *************************************************************************
                            Revision Information
 *************************************************************************
 Rev    Date     By             Comments
 ------ -------- -------------- ------------------------------------------
 001    07/22/19 J. Simpson     Initial Development
 *************************************************************************/
 
drop program 1co_get_patient_list:group1 go
create program 1co_get_patient_list:group1
 
prompt
	"PatientListId" = ""   ;* Enter or select the printer or file name to send this report to.
 
with PatientListId
 
declare nNum = i4
 
; Clear the patient source
set stat = initrec(patient_source)
 
; Define record structures
free record 600144_request
record 600144_request (
	1 patient_list_id					= f8
	1 prsnl_id							= f8
	1 definition_version				= i4
)
 
free record 600123_request
record 600123_request (
	1 patient_list_id					= f8
	1 patient_list_type_cd				= f8
	1 best_encntr_flag 					= i2
	1 arguments[*]
		2 argument_name					= vc
		2 argument_value				= vc
		2 parent_entity_name			= vc
		2 parent_entity_id				= f8
	1 encntr_type_filters[*]
		2 encntr_type_cd				= f8
		2 encntr_class_cd				= f8
	1 patient_list_name					= vc
	1 mv_flag							= i2
	1 rmv_pl_rows_flag					= i2
)
 
; Assign values to 600144_request
set 600144_request->patient_list_id = cnvtreal($PatientListId)
set 600144_request->prsnl_id = nPRSNL_ID
set 600144_request->definition_version = 1
 
; Retrieve the patient list argument data
set stat = tdbexecute(600005, 600024, 600144, "REC", 600144_request, "REC", 600144_reply)
 
; Assign values to 600123_request
select into "nl:"
	patient_list_id	 		= d.patient_list_id,
	patient_list_type_cd	= d.patient_list_type_cd,
	patient_list_name		= d.name
from	dcp_patient_list			d
plan d
	where d.patient_list_id = 600144_reply->patient_list_id
detail
	600123_request->patient_list_id = patient_list_id
	600123_request->patient_list_type_cd = patient_list_type_cd
	600123_request->best_encntr_flag = 1
	600123_request->patient_list_name = patient_list_name
	600123_request->mv_flag = -1
	600123_request->rmv_pl_rows_flag = 0
with nocounter
 
; Move the arguments from 600144 to 600123
set stat = moverec(600144_reply->arguments, 600123_request->arguments)
 
; Execute the patient list retrieval
set stat = tdbexecute(600005, 600024, 600123, "REC", 600123_request, "REC", 600123_reply)
 
; Populate the patient source structure
if (600123_reply->status_data->status = "S")
 
	select into "nl:"
		person_id		= 600123_reply->patients[d.seq].person_id,
		encntr_id		= 600123_reply->patients[d.seq].encntr_id
	from	(dummyt				d with seq=value(size(600123_reply->patients, 5)))
	order person_id, encntr_id
	head person_id
		stat = alterlist(patient_source->patients, size(patient_source->patients, 5)+1)
		patient_source->patients[size(patient_source->patients,5)].person_id = person_id
	head encntr_id
		stat = alterlist(patient_source->visits, size(patient_source->visits, 5)+1)
		patient_source->visits[size(patient_source->visits,5)].person_id = person_id
		patient_source->visits[size(patient_source->visits,5)].encntr_id = encntr_id
	with counter
 
endif
 
#end_program
 
end go
 
/*************************************************************************
 
        Script Name:    1co_load_document.prg
 
        Description:    Clinical Office - mPage Edition
                        Returns document or reference to external document usable in MPages
 
        Date Written:   August 31, 2022
        Written by:     John Simpson
                        Precision Healthcare Solutions
 
 *************************************************************************
            Copyright (c) 2022 Precision Healthcare Solutions
 
 NO PART OF THIS CODE MAY BE COPIED, MODIFIED OR DISTRIBUTED WITHOUT
 PRIOR WRITTEN CONSENT OF PRECISION HEALTHCARE SOLUTIONS EXECUTIVE
 LEADERSHIP TEAM.
 
 FOR LICENSING TERMS PLEASE VISIT www.clinicaloffice.com/mpage/license
 
 *************************************************************************
                            Special Instructions
 *************************************************************************
 None
 *************************************************************************
                            Revision Information
 *************************************************************************
 Rev    Date     By             Comments
 ------ -------- -------------- ------------------------------------------
 001    03/31/22 J. Simpson     Initial Development
 *************************************************************************/
drop program 1co_load_document:group1 go
create program 1co_load_document:group1
 
; Check to see if we have cleared the patient source and if not, do we have data in the patient source
; to run our custom CCL against.
if (validate(payload->customscript->clearpatientsource, 0) = 0)
	if (size(patient_source->patients, 5) = 0)
		go to end_program
	endif
endif
 
; Clear and define rCustom structure
free record rCustom
record rCustom (
    1 status
        2 message               = vc
    1 document[*]
        2 event_id              = f8
        2 event_end_dt_tm       = dq8
        2 event_title_text      = vc
        2 event_cd              = f8
        2 event                 = vc
        2 event_tag             = vc
        2 result_status_cd      = f8
        2 result_status         = vc
        2 storage_cd            = f8
        2 storage               = vc
        2 format_cd             = f8
        2 format                = vc
        2 doc_content           = vc
        2 signature             = vc
        2 blob_handle           = vc
        2 image_url             = vc
)

set rCustom->status->message = "Invalid Parent Event Id"

; Declare variables and subroutines
if (validate(payload->customscript->script[nscript]->parameters->parentEventId) = 0)
    call echo("Problem in parameters")
    call echorecord(payload->customscript->script[nscript])
    go to end_program
endif
    
declare nParentEventId = f8 with noconstant(cnvtreal(payload->customscript->script[nscript]->parameters->parentEventId))

declare nNum = i4
declare cTemp = vc

; Collect code values
declare cv23_RTF = f8 with noconstant(uar_get_code_by("MEANING", 23, "RTF"))
declare cv23_AH = f8 with noconstant(uar_get_code_by("MEANING", 23, "AH"))
declare cv25_Blob = f8 with noconstant(uar_get_code_by("MEANING", 25, "BLOB"))
declare cv48_Active = f8 with noconstant(uar_get_code_by("MEANING", 48, "ACTIVE"))
declare cv53_Doc = f8 with noconstant(uar_get_code_by("MEANING", 53, "DOC"))
declare cv120_OCFCompression = f8 with noconstant(uar_get_code_by("MEANING", 120, "OCFCOMP"))
declare cv120_NoCompression = f8 with noconstant(uar_get_code_by("MEANING", 120, "NOCOMP"))

execute 1co_convert_blob:group1

; Collect the document events
select into "nl:"
from    clinical_event      ce,
        ce_blob_result      cbr
plan ce
    where ce.parent_event_id = nParentEventId
    and ce.valid_until_dt_tm > sysdate
    and ce.event_class_cd = cv53_Doc
join cbr
    where cbr.event_id = ce.event_id
    and cbr.valid_until_dt_tm > sysdate
head report
    nCount = 0
    nBCount = 0
detail
    nCount = nCount + 1
    stat = alterlist(rCustom->document, nCount)
    
    rCustom->document[nCount].event_id = ce.event_id
    rCustom->document[nCount].event_end_dt_tm = ce.event_end_dt_tm
    rCustom->document[nCount].event_title_text = ce.event_title_text
    rCustom->document[nCount].event_cd = ce.event_cd
    rCustom->document[nCount].event = uar_get_code_display(ce.event_cd)
    rCustom->document[nCount].event_tag = ce.event_tag
    rCustom->document[nCount].result_status_cd = ce.result_status_cd
    rCustom->document[nCount].result_status = uar_get_code_display(ce.result_status_cd)
    rCustom->document[nCount].storage_cd = cbr.storage_cd
    rCustom->document[nCount].storage = uar_get_code_display(cbr.storage_cd)
    rCustom->document[nCount].format_cd = cbr.format_cd
    rCustom->document[nCount].format = uar_get_code_display(cbr.format_cd)
    rCustom->document[nCount].blob_handle = cbr.blob_handle
    if (cbr.storage_cd != cv25_Blob)
        rCustom->document[nCount].image_url = "Image"
    endif

    if (cbr.storage_cd = cv25_Blob)
        nBCount = nBCount + 1
        stat = alterlist(co_blob_events->data, nBCount)
        co_blob_events->data[nBCount].event_id = ce.event_id
        co_blob_events->data[nBCount].original_format_cd = cbr.format_cd
    endif
    
    rCustom->status.message = "Document Loaded."
with counter


; Convert any blob items
call convert_blob("HTML")

; Blend the results of the blob conversion into rCustom
if (size(co_blob_events->data, 5) > 0)

    select into "nl:"
    from    (dummyt         d with seq=value(size(rCustom->document, 5))),
            (dummyt         d2 with seq=value(size(co_blob_events->data, 5)))
    plan d
    join d2
        where rCustom->document[d.seq].event_id = co_blob_events->data[d2.seq].event_id
    detail
        rCustom->document[d.seq].doc_content = co_blob_events->data[d2.seq].converted_text
    with counter        

endif

; Look for signature lines
declare blobout = vc
declare blobNoRtf = vc
declare bSize = i4

; Clear the blob events
set stat = initrec(co_blob_events)

select into "nl:"
from    ce_event_note       cen,
        long_blob           lb
plan cen
    where expand(nNum, 1, size(rCustom->document, 5), cen.event_id, rCustom->document[nNum].event_id)
    and cen.valid_until_dt_tm > sysdate
join lb
    where lb.parent_entity_id = cen.ce_event_note_id
    and lb.parent_entity_name = "CE_EVENT_NOTE"
    and lb.active_ind = 1
head report
    nCount = 0    
detail
    blobout = notrim(fillstring(32768, " "))
        
    nCount = nCount + 1
    
    stat = alterlist(co_blob_events->data, nCount)    
    co_blob_events->data[nCount].event_id = cen.event_id

    if (cen.compression_cd = cv120_OCFCompression)
        unCompSize = 0
        blob_un = uar_ocf_uncompress(lb.long_blob, size(lb.long_blob), blobout, size(blobout), unCompSize)
        co_blob_events->data[nCount].original_format_cd = cv23_AH ;cv23_RTF
    else
        co_blob_events->data[nCount].original_format_cd = cv23_AH
        blobout = lb.long_blob
    endif

    co_blob_events->data[nCount].original_text = blobout    
    
with expand=1

call convert_text("HTML")

; Blend the signatures into rCustom
if (size(co_blob_events->data, 5) > 0)

    select into "nl:"
    from    (dummyt         d with seq=value(size(rCustom->document, 5))),
            (dummyt         d2 with seq=value(size(co_blob_events->data, 5)))
    plan d
    join d2
        where rCustom->document[d.seq].event_id = co_blob_events->data[d2.seq].event_id
    detail
        rCustom->document[d.seq].signature = co_blob_events->data[d2.seq].converted_text
    with counter        

endif


call echorecord(co_blob_events)

#end_program

call add_custom_output(cnvtrectojson(rCustom, 4, 1))
  
end go
/*************************************************************************
 
        Script Name:    1CO_LOCATION_ROUTINES.PRG
 
        Description:    Clinical Office - mPage Edition
        				Location Tree data source code
 
        Date Written:   September 1, 2022
        Written by:     John Simpson
                        Precision Healthcare Solutions
 
 *************************************************************************
		   Copyright (c) 2022 Precision Healthcare Solutions
 
 NO PART OF THIS CODE MAY BE COPIED, MODIFIED OR DISTRIBUTED WITHOUT
 PRIOR WRITTEN CONSENT OF PRECISION HEALTHCARE SOLUTIONS EXECUTIVE
 LEADERSHIP TEAM.
 
 FOR LICENSING TERMS PLEASE VISIT www.clinicaloffice.com/mpage/license
 
 *************************************************************************
                            Special Instructions
 *************************************************************************
 Used by 1co_location_tree and your custom CCL scripts to provide location
 tree functionality.
 *************************************************************************
                            Revision Information
 *************************************************************************
 Rev    Date     By             Comments
 ------ -------- -------------- ------------------------------------------
 001    09/01/22 J. Simpson     Initial Development
 *************************************************************************/

drop program 1co_location_routines:group1 go
create program 1co_location_routines:group1
 
prompt 
	"JsonParam" = "MINE"
	, "Field Name" = "" 

with JsonParam, fieldName
 
; Declare internal subroutines
declare LocationBranch(cBranchId = vc) = null with persist
declare GetLocationParent(nChildCd = f8, cParentType = vc) = f8 with persist
declare SelectedCount(cParentType = vc) = i4 with persist
declare AddFilteredLocation(cDisplayKey = vc, cCdfMeaning = vc) = null with persist
 
; Required Code values
declare cvFacility = f8 with noconstant(uar_get_code_by("MEANING", 222, "FACILITY"))
declare cvBuilding = f8 with noconstant(uar_get_code_by("MEANING", 222, "BUILDING"))
 
; Misc Variables
declare nRow = i4
declare nNum = i4
 
; Record structure to contain Full Location Hierarchy (some data excluded based on filters)
free record rAllLocations
record rAllLocations (
	1 data[*]
	    2 organization_id       = f8
		2 facility_cd			= f8
		2 building_cd           = f8
		2 unit_cd				= f8
		2 unit_type_cd			= f8
		2 room_cd				= f8
		2 bed_cd				= f8
		2 census_ind			= i4
	1 children[*]
		2 location_cd			= f8
		2 children				= i4
) with persist
 
; Record structure containing list of filtered locations
free record rFilteredLocations
record rFilteredLocations (
	1 data[*]
		2 location_cd			= f8
		2 meaning				= vc
		2 expand				= i4
) with persist
 
; Temporary record structure to handle exclusions
free record rLocationExclusion
record rLocationExclusion (
	1 data[*]
		2 location_cd			= f8
)
 
; Temporary structure to handle location group root values
free record rRoot
record rRoot (
	1 data[*]
		2 root_loc_cd			= f8
)
; Always need a 0 entry
set stat = alterlist(rRoot->data, 1)
set rRoot->data[1].root_loc_cd = 0
  
; Convert the incoming parameter string to a record structure and create appropriate parser strings
declare cJsonParam = vc with noconstant(concat(^{"param":{^, trim($JsonParam), ^}}^))
set stat = cnvtjsontorec(cJsonParam)
 
; Process the parameter of unit types to allow (e.g. NURSEUNIT, AMBULATORY, etc.)
declare cUnitParser = vc with noconstant("1=1")
declare cFaclParser = vc with noconstant("1=1")
declare cBldParser = vc with noconstant("bld.root_loc_cd = 0.0")
 
if (validate(param->showUnits)=1)
	set cUnitParser = ""
	for (nLoop = 1 to size(param->showUnits, 5))
		if (trim(cUnitParser) != "")
			set cUnitParser = concat(trim(cUnitParser),",")
		endif
		set cUnitParser = concat(trim(cUnitParser), ^"^, param->showUnits[nLoop], ^"^)
 
		; Populate the root location with HIM Root values
		if (param->showUnits[nLoop] = "HIM")
			select into "nl:"
			from	code_value			cv
			plan cv
				where cv.code_set = 220
				and cv.cdf_meaning = "HIMROOT"
				and cv.active_ind = 1
			detail
				stat = alterlist(rRoot->data, size(rRoot->data, 5) + 1)
				rRoot->data[size(rRoot->data, 5)].root_loc_cd = cv.code_value
			with counter
 
			set cBldParser = "expand(nRow, 1, size(rRoot->data, 5), bld.root_loc_cd, rRoot->data[nRow].root_loc_cd)"
		endif
 
	endfor
	if (trim(cUnitParser) != "")
		set cUnitParser = concat(^cv.cdf_meaning in (^, trim(cUnitParser), ^)^) 
	endif
endif
  
declare cMaxViewLevel = vc with noconstant(validate(param->maxViewLevel,"ALL")), persist
declare nOrgSecurity = i4 with noconstant(cnvtint(validate(param->orgSecurity,"1"))), persist	; Default to org security
declare nCensusInd = i4 with noconstant(cnvtint(validate(param->censusInd,"0"))), persist		; Default to not check census ind
declare cRootValue = vc with noconstant(validate(param->rootValue, "x")), persist
declare nRootCode = f8 with noconstant(1.0), persist
  
; Facility Parser
if (nOrgSecurity = 1 and reqinfo->updt_id > 0)
    set cFaclParser = concat("exists (select por.prsnl_org_reltn_id from prsnl_org_reltn por ",
                    "where por.organization_id = facl.organization_id and por.person_id = reqinfo->updt_id ",
                    "and por.active_ind=1 and por.end_effective_dt_tm > sysdate)")
endif
  
; Collect the all of the locations into memory
select into "nl:"
	organization_id		= facl.organization_id,
	fac_cd				= facl.location_cd,
	building_cd         = bld.parent_loc_cd,
	unit_cd				= unit.location_cd,
	unit_type_cd		= unit.location_type_cd,
	room_cd				= if (cMaxViewLevel = "ALL")
							room.child_loc_cd
						  endif,
	bed_cd				= if (cMaxViewLevel = "ALL")
							bed.child_loc_cd
						  endif,
	census_ind			= unit.census_ind
from	location			facl,       ; FACILITY
        location_group      fac,
		location_group		bld,
		location			unit,		; UNIT
		code_value			cv,
		location_group		room,
		location_group		bed
plan facl
    where facl.location_type_cd = cvFacility
	and facl.active_ind = 1
	and facl.end_effective_dt_tm > sysdate
	and parser(cFaclParser)
join fac
	where fac.parent_loc_cd = facl.location_cd
	and fac.location_group_type_cd = cvFacility
	and fac.root_loc_cd = 0.0
	and fac.active_ind = 1
	and fac.end_effective_dt_tm > sysdate
join bld
	where bld.parent_loc_cd = fac.child_loc_cd
	and bld.location_group_type_cd = cvBuilding
	and parser(cBldParser)
	and bld.active_ind = 1
	and bld.end_effective_dt_tm > sysdate
join unit
	where unit.location_cd = bld.child_loc_cd
	and unit.active_ind = 1
	and unit.end_effective_dt_tm > sysdate
join cv
	where cv.code_value = unit.location_cd
	and (bld.root_loc_cd = 0 or cv.cdf_meaning = "HIM")
	and parser(cUnitParser)
join room
	where room.parent_loc_cd = outerjoin(unit.location_cd)
	and room.root_loc_cd = outerjoin(0)
	and room.parent_loc_cd > outerjoin(0)
	and room.active_ind = outerjoin(1)
	and room.end_effective_dt_tm > outerjoin(sysdate)
join bed
	where bed.parent_loc_cd = outerjoin(room.child_loc_cd)
	and bed.root_loc_cd = outerjoin(0)
	and bed.parent_loc_cd > outerjoin(0)
	and bed.active_ind = outerjoin(1)
	and bed.end_effective_dt_tm > outerjoin(sysdate)
order fac_cd, building_cd, unit_cd, room_cd, bed_cd
;/*
head report
	nCount = 0
	nChildCount = 0
 
	; Used to count children at each level
	subroutine addChild(nLocCd, nChildren)
		nChildCount = nChildCount + 1
 
		stat = alterlist(rAllLocations->children, nChildCount)
		rAllLocations->children[nChildCount].location_cd = nLocCd
		rAllLocations->children[nChildCount].children = nChildren
	end
head fac_cd
	nFacCount = 0
head building_cd
    nBldCount = 0
    nFacCount = nFacCount + 1
head unit_cd
	nBldCount = nBldCount + 1
head room_cd
	x = 0
head bed_cd
    if (nCensusInd = 0 or census_ind = 1)
        nCount = nCount + 1
        stat = alterlist(rAllLocations->data, nCount)
 
        rAllLocations->data[nCount].organization_id = organization_id
        rAllLocations->data[nCount].facility_cd = fac_cd
        rAllLocations->data[nCount].building_cd = building_cd
        rAllLocations->data[nCount].unit_cd = unit_cd
        rAllLocations->data[nCount].unit_type_cd = unit_type_cd
        rAllLocations->data[nCount].census_ind = census_ind
        rAllLocations->data[nCount].room_cd = room_cd
        rAllLocations->data[nCount].bed_cd = bed_cd
    endif
foot room_cd
	x = 0
foot unit_cd
	x = 0
foot building_cd
	stat = addChild(building_cd, nBldCount)	
foot fac_cd
	stat = addChild(fac_cd, nFacCount)
;*/
with expand=1, counter
 
; If the ValueList prompt value contains a list of locations, populate the rFilteredLocations structure
; with either beds or units.
if (trim($fieldName) != "")
    call echo("-----------------------")
    call echo("Start")
    call echo("-----------------------")

    declare cFilterLocations = vc
    if (findstring(".", $fieldName) > 0 or findstring(">", $fieldName) > 0)
        set cFilterLocations = concat(^expand(nNum, 1, ^,
                                ^size(^, trim($fieldName), ^,5),^,
                                ^cv.code_value, cnvtreal(^, trim($fieldName),
                                ^[nNum]))^)
    else
        set cFilterLocations = concat(^expand(nNum, 1, ^,
                                ^size(payload->customscript->script[nscript]->parameters.^, trim($fieldName), ^,5),^,
                                ^cv.code_value, cnvtreal(payload->customscript->script[nscript]->parameters.^, trim($fieldName),
                                ^[nNum]))^)
    endif                                
    call echo(  cFilterLocations)                              

 
    ; Step 1 - Find the exclusion list to prevent entire branches from being collected
    select distinct into "nl:"
    	exclude_cd		= if (cv.code_value = rAllLocations->data[d.seq].building_cd)
                            rAllLocations->data[d.seq].facility_cd
					      elseif (cv.code_value = rAllLocations->data[d.seq].unit_cd)
                            rAllLocations->data[d.seq].building_cd
	        			  elseif (cv.code_value = rAllLocations->data[d.seq].room_cd)
                            rAllLocations->data[d.seq].unit_cd
                          elseif (cv.code_value = rAllLocations->data[d.seq].bed_cd)
                            rAllLocations->data[d.seq].room_cd
                          endif
        from	code_value			cv,
                (dummyt				d with seq=value(size(rAllLocations->data, 5)))
    plan cv
        where parser(cFilterLocations)
    ;	where cv.code_value = $ValueList
	   and cv.code_value != 0
    join d
    	where cv.code_value in (
		  rAllLocations->data[d.seq].facility_cd,
		  rAllLocations->data[d.seq].building_cd,
    	  rAllLocations->data[d.seq].unit_cd,
		  rAllLocations->data[d.seq].room_cd,
		  rAllLocations->data[d.seq].bed_cd
	   )
    order exclude_cd
    detail
    	if (exclude_cd > 0)
		  stat = alterlist(rLocationExclusion->data, size(rLocationExclusion->data, 5)+1)
    		rLocationExclusion->data[size(rLocationExclusion->data, 5)].location_cd = exclude_cd
	   endif
    with expand=1, counter
 
    set stat = initrec(rFilteredLocations)
  
    ; Collect the values that haven't been excluded
    select into "nl:"
        facility        = uar_get_code_description(rAllLocations->data[d.seq].facility_cd),
        building        = uar_get_code_description(rAllLocations->data[d.seq].building_cd),
        unit            = uar_get_code_description(rAllLocations->data[d.seq].unit_cd),
        room            = uar_get_code_description(rAllLocations->data[d.seq].room_cd),
        bed             = uar_get_code_description(rAllLocations->data[d.seq].bed_cd),
    	location_cd		= if (cMaxViewLevel = "ALL")
    						  rAllLocations->data[d.seq].bed_cd
					      else
					          rAllLocations->data[d.seq].unit_cd
					      endif
    from    code_value			cv,
		    (dummyt				d with seq=value(size(rAllLocations->data, 5)))
    plan cv
;	where cv.code_value = $ValueList
        where parser(cFilterLocations)
    	and cv.code_value != 0
	    and not exists (
		  select cv.code_value from code_value
		      where expand(nRow, 1, size(rLocationExclusion->data,5), cv.code_value, rLocationExclusion->data[nRow].location_cd)
		  )
    join d
	   where cv.code_value in (
            rAllLocations->data[d.seq].facility_cd,
            rAllLocations->data[d.seq].building_cd,
    		rAllLocations->data[d.seq].unit_cd,
            rAllLocations->data[d.seq].room_cd,
            rAllLocations->data[d.seq].bed_cd
	   )
    order facility, building, unit, room, bed, location_cd
    head report
	   nCount = 0 
    head facility
        x = 0
    head building
        x = 0    
    head unit
        x = 0
    head room
        x = 0
    head bed
    	x = 0
    head location_cd
    	if (location_cd > 0)
		  nCount = nCount + 1
    	  stat = alterlist(rFilteredLocations->data, nCount)
 
		  rFilteredLocations->data[nCount].location_cd = location_cd
		  rFilteredLocations->data[nCount].meaning = uar_get_code_meaning(location_cd)
	   endif
    with expand=1

endif

 
 ; Used to return a single level of location code values from the hierarchy
subroutine LocationBranch(cBranchId)
 
	set nBranchId = cnvtreal(cBranchId)
	set cBranchDisplay = uar_get_code_display(nBranchId)
	set cBranchMeaning = uar_get_code_meaning(nBranchId)
 
	set stat = initrec(rFilteredLocations)
 
	select into "nl:"
	nBranchId,cBranchMeaning,
		root_code			= if (nBranchId = 1.0)
								rAllLocations->data[d.seq].facility_cd
							  elseif (cBranchMeaning = "FACILITY")
							  	rAllLocations->data[d.seq].building_cd
							  elseif (cBranchMeaning = "BUILDING")
						  		rAllLocations->data[d.seq].unit_cd
							  elseif (cBranchMeaning in ("NURSEUNIT","AMBULATORY"))
							  	rAllLocations->data[d.seq].room_cd
							  elseif (cBranchMeaning = "ROOM")
							  	rAllLocations->data[d.seq].bed_cd
							  endif,
        expandable          = if ((nBranchId = 1.0 and rAllLocations->data[d.seq].building_cd > 0.0)
							     or (cBranchMeaning = "FACILITY" and rAllLocations->data[d.seq].unit_cd > 0.0)
							     or (cBranchMeaning = "BUILDING" and rAllLocations->data[d.seq].room_cd > 0.0)
							     or (cBranchMeaning in ("NURSEUNIT","AMBULATORY") and rAllLocations->data[d.seq].bed_cd > 0.0))							  	
                                1							  	
							  endif
	from	(dummyt				d with seq=value(size(rAllLocations->data, 5)))
	plan d
		where nBranchId in (
				1.0,
				rAllLocations->data[d.seq].facility_cd,
				rAllLocations->data[d.seq].building_cd,
				rAllLocations->data[d.seq].unit_cd,
				rAllLocations->data[d.seq].room_cd,
				rAllLocations->data[d.seq].bed_cd
		)
		and nBranchId > 0.0
	order root_code
;/*	
	head report
		nCount = 0
	head root_code
		nExpand = 0
		if (nBranchId = 1.0 or cBranchMeaning in ("FACILITY", "BUILDING")
			or (nBranchId = rAllLocations->data[d.seq].unit_cd and rAllLocations->data[d.seq].room_cd > 0))
			nExpand = 2
		endif
	detail
		nExpand = nExpand + 1
	foot root_code
		; Limit the maximum view level if passed in the parameters
		if (cMaxViewLevel != "FACILITY" and nBranchId = 1.0)
			x = 0
		elseif (
			(cMaxViewLevel = "FACILITY" and nBranchId = 1.0) or
			(cMaxViewLevel = "BUILDING" and uar_get_code_meaning(root_code)
									!= "FACILITY") or
			(cMaxViewLevel = "UNIT" and uar_get_code_meaning(root_code)
									not in ("FACILITY","BUILDING"))
			)
			nExpand = 0
		endif
 
		; Write the new record to the record structure
		nCount = nCount + 1
		stat = alterlist(rFilteredLocations->data, nCount)
 
		rFilteredLocations->data[nCount].location_cd = root_code
 
		if (nExpand > 1 and expandable = 1)
			rFilteredLocations->data[nCount].expand = 1
		endif ;*/
	with counter
end
 
end go
/*************************************************************************
 
        Script Name:    1CO_LOCATION_TREE.PRG
 
        Description:    Clinical Office - mPage Edition
        				Location Tree
 
        Date Written:   September 1, 2022
        Written by:     John Simpson
                        Precision Healthcare Solutions
 
 *************************************************************************
		   Copyright (c) 2022 Precision Healthcare Solutions
 
 NO PART OF THIS CODE MAY BE COPIED, MODIFIED OR DISTRIBUTED WITHOUT
 PRIOR WRITTEN CONSENT OF PRECISION HEALTHCARE SOLUTIONS EXECUTIVE
 LEADERSHIP TEAM.
 
 FOR LICENSING TERMS PLEASE VISIT www.clinicaloffice.com/mpage/license
 
 *************************************************************************
                            Special Instructions
 *************************************************************************
 Used by 1co_location_tree and your custom CCL scripts to provide location
 tree functionality.
 *************************************************************************
                            Revision Information
 *************************************************************************
 Rev    Date     By             Comments
 ------ -------- -------------- ------------------------------------------
 001    09/01/22 J. Simpson     Initial Development
 *************************************************************************/

drop program 1co_location_tree:group1 go
create program 1co_location_tree:group1

; Check to see if we have cleared the patient source and if not, do we have data in the patient source
; to run our custom CCL against.
if (validate(payload->customscript->clearpatientsource, 0) = 0)
	if (size(patient_source->patients, 5) = 0)
		go to end_program
	endif
endif

; Define output structure
free record rCustom
record rCustom (
    1 data[*]
        2 parent_id     = f8
        2 id            = f8
        2 display       = vc
        2 expandable    = i4
        2 selected      = i4
        2 indeterminate = i4
        2 expanded      = i4
        2 dirty         = i4
        2 create_zone   = i4
)    

; Required variables
declare nBranchId = f8 with noconstant(payload->customscript->script[nscript]->parameters.branchid)
declare nNum = i4
declare cSearchMode = vc with noconstant("")
declare cParser = vc
declare qualifySearchRow(nRow = i4) = vc

call echorecord(payload->customscript->script[nscript]->parameters)

; Execute the code to load the locations
execute 1co_location_routines:group1 payload->customscript->script[nscript]->parameters.scriptparams, ""

declare cSearchText = vc with noconstant("")
if (nBranchId = 0 and trim(payload->customscript->script[nscript]->parameters->searchText) != "")
    set cSearchText = cnvtlower(concat(trim(payload->customscript->script[nscript]->parameters->searchText),"*"))
    set cSearchMode = "search"
elseif (nBranchId = 1 and size(payload->customscript->script[nscript]->parameters->default,5) > 0)
    set cSearchMode = "value"
endif

; Normal drill down
;/*
if (nBranchId > 0)
    call LocationBranch(cnvtstring(nBranchId))
    
	select into "nl:"
		item_display		= uar_get_code_description(rFilteredLocations->data[d.seq].location_cd),
		item_keyvalue		= rFilteredLocations->data[d.seq].location_cd,
		item_expand_flag	= rFilteredLocations->data[d.seq].expand
	from	(dummyt				d with seq=value(size(rFilteredLocations->data, 5)))
	order item_display
	head report
	   nCount = 0
	detail
	   nCount = nCount + 1
	   stat = alterlist(rCustom->data, nCount)

       rCustom->data[nCount].parent_id = nBranchId
	   rCustom->data[nCount].id = item_keyvalue
	   rCustom->data[nCount].display = item_display
	   rCustom->data[nCount].expandable = item_expand_flag
	   rCustom->data[nCount].create_zone = 1
	with counter
endif
;*/

; Search	
if (nBranchId in (0,1) and cSearchMode in ("value","search"))

    ; Create entries for the branches that match the search
    select ; into "nl:"
        sort_key        = substring(1,50,qualifySearchRow(d.seq)),
        facility        = uar_get_code_description(rAllLocations->data[d.seq].facility_cd),
        building        = uar_get_code_description(rAllLocations->data[d.seq].building_cd),
        unit            = uar_get_code_description(rAllLocations->data[d.seq].unit_cd),
        room            = uar_get_code_description(rAllLocations->data[d.seq].room_cd),
        bed             = uar_get_code_description(rAllLocations->data[d.seq].bed_cd)
    from    (dummyt         d with seq=value(size(rAllLocations->data, 5)))
    plan d
        where qualifySearchRow(d.seq) != "XXXNOTFOUNDXXX"
;        or cSearchMode = "value"
    order sort_key, facility, building, unit, room, bed
;/*    
    head report
        position = 0
 
        subroutine addBranch(nParent, cBranchDisplay)
          cBranchMeaning = uar_get_code_meaning(nParent)
 
          nChild = 0.0
          nGrandChild = 0.0
           
		  if (cBranchMeaning = "FACILITY")
            nChild = rAllLocations->data[d.seq].building_cd
            nGrandChild = rAllLocations->data[d.seq].unit_cd
          elseif (cBranchMeaning = "BUILDING")          		      
            nChild = rAllLocations->data[d.seq].unit_cd
            nGrandChild = rAllLocations->data[d.seq].room_cd
          elseif (cBranchMeaning in ("NURSEUNIT","AMBULATORY"))
            nChild = rAllLocations->data[d.seq].room_cd
            nGrandChild = rAllLocations->data[d.seq].bed_cd
          elseif (cBranchMeaning = "ROOM")
            nChild = rAllLocations->data[d.seq].bed_cd
          endif
 
          ; Determine if next level down should be collected
          cChildMeaning = uar_get_code_meaning(nChild)
          case (cChildMeaning)
            of "BED": nChildLevel = 1
            of "ROOM": nChildLevel = 2
            of "NURSEUNIT": nChildLevel = 3
            of "AMBULATORY": nChildLevel = 3
            of "BUILDING": nChildLevel = 4
            of "FACILITY": nChildLevel = 5
          endcase
          
          col 10, cBranchMeaning, " child:", nChild, " childLevel:",  nChildLevel, " pos: ", position, row + 1
 
          if (nChildLevel >= position and nChild > 0.0)
 
            cChildDisplay = uar_get_code_description(nChild)
 
            nExpand = 0
            if ((cMaxViewLevel in ("ALL", "FACILITY") or
        	   (cMaxViewLevel = "UNIT" and nChildLevel > 3) or
        	   (cMaxViewLevel = "BUILDING"  and nChildLevel > 4) ; or
        	   ;(cMaxViewLevel = "FACILITY"  and nChildLevel > 5)
        	   ) and nGrandChild > 0)
                nExpand = 1
            endif
 
 
            ; Add the row if not previously added
            if (locateval(nNum, 1, size(rCustom->data, 5), nChild, rCustom->data[nNum].id) = 0)
            
                col 20, "***WRITE***", rCustom->data[nNum].id, " child: ", nChild, " gc: ", nGrandChild, row + 1
            
                nCount = size(rCustom->data, 5) + 1
                stat = alterlist(rCustom->data, nCount)
                rCustom->data[nCount].parent_id = nParent
                rCustom->data[nCount].id = nChild
                rCustom->data[nCount].display = cChildDisplay                
                rCustom->data[nCount].expandable = nExpand
                if (nChildLevel = position and cSearchMode = "value")
                    rCustom->data[nCount].selected = 1
                endif
                if (nChildLevel != position and nChildLevel > 0 and cSearchMode = "value")  
                    rCustom->data[nCount].indeterminate = 1
                endif
                if (nChildLevel > position)
                    rCustom->data[nCount].expanded = nExpand
                endif
                rCustom->data[nCount].dirty = 1
            endif
 
            call addBranch(nChild, cChildDisplay)
          endif
        end
    head sort_key
        position = cnvtint(piece(sort_key, "|", 1, "0"))
        
        ; Add the facility level if it doesn't exist already
        nFoundFAC = locateval(nNum, 1, size(rCustom->data, 5), rAllLocations->data[d.seq].facility_cd,
                    rCustom->data[nNum].id)
        if (nFoundFAC = 0) ; or rCustom->data[nFoundFac].create_zone)
            nCount = size(rCustom->data, 5) + 1
            stat = alterlist(rCustom->data, nCount)
                        
            rCustom->data[nCount].parent_id = 1.0
            rCustom->data[nCount].id = rAllLocations->data[d.seq].facility_cd
            rCustom->data[nCount].display = facility
            rCustom->data[nCount].expandable = 1
            rCustom->data[nCount].expanded = 1
            rCustom->data[nCount].dirty = 1
            if (position = 5)
                rCustom->data[nCount].selected = 1
            endif
            if (position between 1 and 4)
                rCustom->data[nCount].indeterminate = 1
            endif
        else
            rCustom->data[nFoundFAC].dirty = 1
            if (position between 1 and 4)
                rCustom->data[nFoundFAC].indeterminate = 1
            else
                rCustom->data[nFoundFAC].selected = 1
            endif
        endif

        if (position > 0)
            call addBranch(rAllLocations->data[d.seq].facility_cd, facility)
        endif
    with counter
;*/
endif

subroutine qualifySearchRow(nRow)
    set nReturnValue = 0
    set nQualValue = 0.0
 
    for (nSearchLoop = 5 to 1 by -1)  ; 1 = Bed ---> 5 = Facility
        if (cMaxViewLevel = "ALL" or
        	(cMaxViewLevel = "UNIT" and nSearchLoop > 2) or
        	(cMaxViewLevel = "BUILDING" and nSearchLoop > 3) or
        	(cMaxViewLevel = "FACILITY"  and nSearchLoop > 4))
 
            set nValue = 0.0
 
            ; Pick the correct search string
            case (nSearchLoop)
                of 1:   set cString = uar_get_code_description(rAllLocations->data[nRow].bed_cd)
                        set nValue = rAllLocations->data[nRow].bed_cd
                of 2:   set cString = uar_get_code_description(rAllLocations->data[nRow].room_cd)
                        set nValue = rAllLocations->data[nRow].room_cd
                of 3:   set cString = uar_get_code_description(rAllLocations->data[nRow].unit_cd)
                        set nValue = rAllLocations->data[nRow].unit_cd
                of 4:   set cString = uar_get_code_description(rAllLocations->data[nRow].building_cd)
                        set nValue = rAllLocations->data[nRow].building_cd
                of 5:   set cString = uar_get_code_description(rAllLocations->data[nRow].facility_cd)
                        set nValue = rAllLocations->data[nRow].facility_cd
            endcase

            ; Perform text search
            if (cSearchMode = "search" and trim(cSearchText) != "" 
                            and cnvtlower(cstring) = patstring(concat(trim(cSearchText), "*")))
                set nReturnValue = nSearchLoop
                set nQualValue = nValue
            elseif (cSearchMode = "value" and nValue > 0.0)
                if (locateval(nNum, 1, size(payload->customscript->script[nscript]->parameters->default, 5), nValue,
                    payload->customscript->script[nscript]->parameters->default[nNum]) > 0) 
                    set nReturnValue = nSearchLoop
                    set nQualValue = nValue
                endif
            endif

        endif
    endfor

    if (nQualValue = 0)
        return ("XXXNOTFOUNDXXX")
    else
        return (build(nReturnValue, "|", cnvtstring(nQualValue)))
    endif
end


; ------------------------------------------------------------------------------------------------
;								END OF YOUR CUSTOM CODE
; ------------------------------------------------------------------------------------------------
 
; If you wish to return output back to the mPage, you need to run the ADD_CUSTOM_OUTPUT function.
; Any valid JSON format is acceptable including the CNVTRECTOJSON function. If using
; CNVTRECTOJSON be sure to use parameters 4 and 1 as shown below.
; If you plan on creating your own JSON string rather than converting a record structure, be
; sure to have it in the format of {"name":{your custom json data}} as the ADD_CUSTOM_OUTPUT
; subroutine will extract the first sub-object from the JSON. (e.g. {"name":{"personId":123}} will
; be sent to the output stream as {"personId": 123}.
call add_custom_output(cnvtrectojson(rCustom, 4, 1))
 
#end_program


end go
/*************************************************************************
 
        Script Name:    1CO_MPAGE_ALLERGY.PRG
 
        Description:    Clinical Office - mPage Edition
        				Allergy Data Retrieval
 
        Date Written:   April 24, 2018
        Written by:     John Simpson
                        Precision Healthcare Solutions
 
 *************************************************************************
		   Copyright (c) 2018 Precision Healthcare Solutions
 
 NO PART OF THIS CODE MAY BE COPIED, MODIFIED OR DISTRIBUTED WITHOUT
 PRIOR WRITTEN CONSENT OF PRECISION HEALTHCARE SOLUTIONS EXECUTIVE
 LEADERSHIP TEAM.
 
 FOR LICENSING TERMS PLEASE VISIT www.clinicaloffice.com/mpage/license
 
 *************************************************************************
                            Special Instructions
 *************************************************************************
 Called from 1CO_MPAGE_ENTRY. Do not attempt to run stand alone.
 
 Possible Payload values:
 
	"patientSource":[
		{"personId": value, "encntrId": value}
	],
	"allergy": {
    	"includeCodeValues": true,
		"reactions": true
		"comments": true
	},
	"typeList": [
		{"codeSet": value, "type": "value", "typeCd": value}
	]
 
 
 
 *************************************************************************
                            Revision Information
 *************************************************************************
 Rev    Date     By             Comments
 ------ -------- -------------- ------------------------------------------
 001    02/06/18 J. Simpson     Initial Development
 *************************************************************************/
 
DROP PROGRAM 1CO_MPAGE_ALLERGY:GROUP1 GO
CREATE PROGRAM 1CO_MPAGE_ALLERGY:GROUP1
 
; Check to see if running from mPage entry script
IF (VALIDATE(PAYLOAD->ALLERGY) = 0 OR SIZE(PATIENT_SOURCE->PATIENTS, 5) = 0)
	GO TO END_PROGRAM
ENDIF
 
RECORD rALLERGY (
	1 DATA[*]
		2 PERSON_ID						= f8
		2 ENCNTR_ID						= f8
		2 ALLERGY_ID					= f8
		2 ALLERGY_INSTANCE_ID			= i8
		2 SUBSTANCE						= vc
		2 SUBSTANCE_IDENTIFIER			= vc
		2 SUBSTANCE_FTDESC				= vc
		2 SUBSTANCE_TYPE_CD				= f8
		2 REACTION_CLASS_CD				= f8
		2 SEVERITY_CD					= f8
		2 SOURCE_OF_INFO_CD				= f8
		2 SOURCE_OF_INFO_FT				= vc
		2 ONSET_DT_TM					= dq8
		2 REACTION_STATUS_CD			= f8
		2 CREATED_DT_TM					= dq8
		2 CREATED_PRSNL_ID				= f8
		2 CANCEL_REASON_CD				= f8
		2 CANCEL_DT_TM					= dq8
		2 CANCEL_PRSNL_ID				= f8
		2 VERIFIED_STATUS_FLAG			= i4
		2 REC_SRC_VOCAB_CD				= f8
		2 REC_SRC_IDENTIFER				= vc
		2 REC_SRC_STRING				= vc
		2 ONSET_PRECISION_CD			= f8
		2 ONSET_PRECISION_FLAG			= i4
		2 REVIEWED_DT_TM				= dq8
		2 REVIEWED_PRSNL_ID				= f8
		2 ORIG_PRSNL_ID					= f8
		2 REACTION_STATUS_DT_TM			= dq8
		2 REACTION[*]
			3 REACTION					= vc
			3 REACTION_IDENTIFIER		= vc
			3 REACTION_FTDESC			= vc
		2 COMMENT[*]
			3 COMMENT_DT_TM				= dq8
			3 COMMENT_PRSNL_ID			= f8
			3 ALLERGY_COMMENT			= vc
)
 
DECLARE cPARSER = vc
DECLARE cPARSER2= vc
 
; Set the Parser
CALL TYPE_PARSER("A.REACTION_STATUS_CD", 12025)
SET cPARSER2 = cPARSER
CALL TYPE_PARSER("A.SUBSTANCE_TYPE_CD", 12020)
 
; Collect the allergies
SELECT INTO "NL:"
	DSEQ				= D.SEQ,
	SORT_KEY			= CNVTUPPER(N.SOURCE_STRING)
FROM	(DUMMYT				D WITH SEQ=VALUE(SIZE(PATIENT_SOURCE->PATIENTS, 5))),
		ALLERGY				A,
		NOMENCLATURE		N
PLAN D
JOIN A
	WHERE A.PERSON_ID = PATIENT_SOURCE->PATIENTS[D.SEQ].PERSON_ID
	AND PARSER(cPARSER)
	AND PARSER(cPARSER2)
	AND A.ACTIVE_IND = 1
	AND A.END_EFFECTIVE_DT_TM > SYSDATE
JOIN N
	WHERE N.NOMENCLATURE_ID = A.SUBSTANCE_NOM_ID
ORDER BY DSEQ, SORT_KEY
HEAD REPORT
	nCOUNT = 0
DETAIL
	nCOUNT = nCOUNT + 1
	STAT = ALTERLIST(rALLERGY->DATA, nCOUNT)
 
	rALLERGY->DATA[nCOUNT].PERSON_ID = A.PERSON_ID
	rALLERGY->DATA[nCOUNT].ENCNTR_ID = A.ENCNTR_ID
	rALLERGY->DATA[nCOUNT].ALLERGY_ID = A.ALLERGY_ID
	rALLERGY->DATA[nCOUNT].ALLERGY_INSTANCE_ID = A.ALLERGY_INSTANCE_ID
	rALLERGY->DATA[nCOUNT].SUBSTANCE = N.SOURCE_STRING
	rALLERGY->DATA[nCOUNT].SUBSTANCE_IDENTIFIER = N.SOURCE_IDENTIFIER
	rALLERGY->DATA[nCOUNT].SUBSTANCE_FTDESC = A.SUBSTANCE_FTDESC
	rALLERGY->DATA[nCOUNT].SUBSTANCE_TYPE_CD = A.SUBSTANCE_TYPE_CD
	rALLERGY->DATA[nCOUNT].SOURCE_OF_INFO_CD = A.SOURCE_OF_INFO_CD
	rALLERGY->DATA[nCOUNT].SOURCE_OF_INFO_FT = A.SOURCE_OF_INFO_FT
	rALLERGY->DATA[nCOUNT].ONSET_DT_TM = A.ONSET_DT_TM
	rALLERGY->DATA[nCOUNT].REACTION_STATUS_CD = A.REACTION_STATUS_CD
	rALLERGY->DATA[nCOUNT].CREATED_DT_TM = A.CREATED_DT_TM
	rALLERGY->DATA[nCOUNT].CREATED_PRSNL_ID = A.CREATED_PRSNL_ID
	rALLERGY->DATA[nCOUNT].CANCEL_REASON_CD = A.CANCEL_REASON_CD
	rALLERGY->DATA[nCOUNT].CANCEL_DT_TM = A.CANCEL_DT_TM
	rALLERGY->DATA[nCOUNT].CANCEL_PRSNL_ID = A.CANCEL_PRSNL_ID
	rALLERGY->DATA[nCOUNT].VERIFIED_STATUS_FLAG = A.VERIFIED_STATUS_FLAG
	rALLERGY->DATA[nCOUNT].REC_SRC_VOCAB_CD = A.REC_SRC_VOCAB_CD
	rALLERGY->DATA[nCOUNT].REC_SRC_IDENTIFER = A.REC_SRC_IDENTIFER
	rALLERGY->DATA[nCOUNT].REC_SRC_STRING = A.REC_SRC_STRING
	rALLERGY->DATA[nCOUNT].ONSET_PRECISION_CD = A.ONSET_PRECISION_CD
	rALLERGY->DATA[nCOUNT].ONSET_PRECISION_FLAG = A.ONSET_PRECISION_FLAG
	rALLERGY->DATA[nCOUNT].REVIEWED_DT_TM = A.REVIEWED_DT_TM
	rALLERGY->DATA[nCOUNT].REVIEWED_PRSNL_ID = A.REVIEWED_PRSNL_ID
	rALLERGY->DATA[nCOUNT].ORIG_PRSNL_ID = A.ORIG_PRSNL_ID
	rALLERGY->DATA[nCOUNT].REACTION_STATUS_DT_TM = A.REACTION_STATUS_DT_TM
WITH NOCOUNTER
 
; Collect the reactions
IF (VALIDATE(PAYLOAD->ALLERGY->REACTIONS, 0) = 1)
	SELECT INTO "NL:"
		DSEQ				= D.SEQ,
		SORT_KEY			= CNVTUPPER(N.SOURCE_STRING)
	FROM	(DUMMYT				D WITH SEQ=VALUE(SIZE(rALLERGY->DATA, 5))),
			REACTION			R,
			NOMENCLATURE		N
	PLAN D
	JOIN R
		WHERE R.ALLERGY_ID = rALLERGY->DATA[D.SEQ].ALLERGY_ID
		AND R.ACTIVE_IND = 1
		AND R.END_EFFECTIVE_DT_TM > SYSDATE
	JOIN N
		WHERE N.NOMENCLATURE_ID = R.REACTION_NOM_ID
	ORDER DSEQ, SORT_KEY
	HEAD DSEQ
		nCOUNT = 0
	DETAIL
		nCOUNT = nCOUNT + 1
		STAT = ALTERLIST(rALLERGY->DATA[D.SEQ].REACTION, nCOUNT)
 
		rALLERGY->DATA[D.SEQ].REACTION[nCOUNT].REACTION = N.SOURCE_STRING
		rALLERGY->DATA[D.SEQ].REACTION[nCOUNT].REACTION_IDENTIFIER = N.SOURCE_IDENTIFIER
		rALLERGY->DATA[D.SEQ].REACTION[nCOUNT].REACTION_FTDESC = R.REACTION_FTDESC
	WITH NOCOUNTER
ENDIF
 
; Collect the comments
IF (VALIDATE(PAYLOAD->ALLERGY->COMMENTS, 0) = 1)
	SELECT INTO "NL:"
		DSEQ				= D.SEQ,
		SORT_DATE			= FORMAT(AC.COMMENT_DT_TM, "YYYYMMDDHHMMSS;;Q")
	FROM	(DUMMYT				D WITH SEQ=VALUE(SIZE(rALLERGY->DATA, 5))),
			ALLERGY_COMMENT		AC
	PLAN D
	JOIN AC
		WHERE AC.ALLERGY_ID = rALLERGY->DATA[D.SEQ].ALLERGY_ID
		AND AC.ACTIVE_IND = 1
		AND AC.END_EFFECTIVE_DT_TM > SYSDATE
	ORDER DSEQ, SORT_DATE DESC
	HEAD DSEQ
		nCOUNT = 0
	HEAD SORT_DATE
		X = 0
	DETAIL
		nCOUNT = nCOUNT + 1
		STAT = ALTERLIST(rALLERGY->DATA[D.SEQ].COMMENT, nCOUNT)
 
		rALLERGY->DATA[D.SEQ].COMMENT[nCOUNT].COMMENT_DT_TM = AC.COMMENT_DT_TM
		rALLERGY->DATA[D.SEQ].COMMENT[nCOUNT].COMMENT_PRSNL_ID = AC.COMMENT_PRSNL_ID
		rALLERGY->DATA[D.SEQ].COMMENT[nCOUNT].ALLERGY_COMMENT = REPLACE(REPLACE(AC.ALLERGY_COMMENT, CHAR(13), ""), CHAR(10), "\\n")
 
	WITH NOCOUNTER
ENDIF
 
; Skip the rest if no allergies loaded
IF (SIZE(rALLERGY->DATA, 5) = 0)
	GO TO END_PROGRAM
ENDIF
 
SET _Memory_Reply_String = BUILD(_Memory_Reply_String, ^,"allergies":[^)
 
; Loop through all the patients
FOR (nLOOP = 1 TO SIZE(rALLERGY->DATA, 5))
	IF (nLOOP > 1)
		SET _Memory_Reply_String = BUILD(_Memory_Reply_String, ^,^)
	ENDIF
 
	; Set the person_id to return as the first item
	SET _Memory_Reply_String = BUILD(_Memory_Reply_String,
					^{"personId":^, CNVTINT(rALLERGY->DATA[nLOOP].PERSON_ID), ^,^,
					^"encntrId":^, CNVTINT(rALLERGY->DATA[nLOOP].ENCNTR_ID), ^,^,
					^"allergyId":^, CNVTINT(rALLERGY->DATA[nLOOP].ALLERGY_ID), ^,^,
					^"allergyInstanceId":^, CNVTINT(rALLERGY->DATA[nLOOP].ALLERGY_INSTANCE_ID), ^,^,
					^"substance":"^, rALLERGY->DATA[nLOOP].SUBSTANCE, ^",^,
					^"substanceIdentifier":"^, rALLERGY->DATA[nLOOP].SUBSTANCE_IDENTIFIER, ^",^,
					^"substanceFtDesc":"^, rALLERGY->DATA[nLOOP].SUBSTANCE_FTDESC, ^",^,
					^"substanceType":"^, UAR_GET_CODE_DISPLAY(rALLERGY->DATA[nLOOP].SUBSTANCE_TYPE_CD), ^",^,
					^"substanceTypeMeaning":"^, UAR_GET_CODE_MEANING(rALLERGY->DATA[nLOOP].SUBSTANCE_TYPE_CD), ^",^,
					^"reactionClass":"^, UAR_GET_CODE_DISPLAY(rALLERGY->DATA[nLOOP].REACTION_CLASS_CD), ^",^,
					^"severity":"^, UAR_GET_CODE_DISPLAY(rALLERGY->DATA[nLOOP].SEVERITY_CD), ^",^,
					^"sourceOfInfo":"^, UAR_GET_CODE_DISPLAY(rALLERGY->DATA[nLOOP].SOURCE_OF_INFO_CD), ^",^,
					^"sourceOfInfoFt":"^, rALLERGY->DATA[nLOOP].SOURCE_OF_INFO_FT, ^",^,
					^"onsetDtTm":"^, FORMAT(rALLERGY->DATA[nLOOP].ONSET_DT_TM, cDATE_FORMAT), ^",^,
					^"reactionStatus":"^, UAR_GET_CODE_DISPLAY(rALLERGY->DATA[nLOOP].REACTION_STATUS_CD), ^",^,
					^"createdDtTm":"^, FORMAT(rALLERGY->DATA[nLOOP].CREATED_DT_TM, cDATE_FORMAT), ^",^,
					^"createdPrsnlId":^, CNVTINT(rALLERGY->DATA[nLOOP].CREATED_PRSNL_ID) , ^,^,
					^"cancelReason":"^, UAR_GET_CODE_DISPLAY(rALLERGY->DATA[nLOOP].CANCEL_REASON_CD), ^",^,
					^"cancelDtTm":"^, FORMAT(rALLERGY->DATA[nLOOP].CANCEL_DT_TM, cDATE_FORMAT), ^",^,
					^"cancelPrsnlId":^, CNVTINT(rALLERGY->DATA[nLOOP].CANCEL_PRSNL_ID) , ^,^,
					^"verifiedStatusFlag":^, rALLERGY->DATA[nLOOP].VERIFIED_STATUS_FLAG , ^,^,
					^"recSrcVocab":"^, UAR_GET_CODE_DISPLAY(rALLERGY->DATA[nLOOP].REC_SRC_VOCAB_CD), ^",^,
					^"recSrcIdentifier":"^, rALLERGY->DATA[nLOOP].REC_SRC_IDENTIFER , ^",^,
					^"recSrcString":"^, rALLERGY->DATA[nLOOP].REC_SRC_STRING , ^",^,
					^"onsetPrecision":"^, UAR_GET_CODE_DISPLAY(rALLERGY->DATA[nLOOP].ONSET_PRECISION_CD), ^",^,
					^"onsetPrecisionFlag":^, CNVTINT(rALLERGY->DATA[nLOOP].ONSET_PRECISION_FLAG) , ^,^,
					^"reviewedDtTm":"^, FORMAT(rALLERGY->DATA[nLOOP].REVIEWED_DT_TM, cDATE_FORMAT), ^",^,
					^"reviewedPrsnlId":^, CNVTINT(rALLERGY->DATA[nLOOP].REVIEWED_PRSNL_ID) , ^,^,
					^"origPrsnlId":^, CNVTINT(rALLERGY->DATA[nLOOP].ORIG_PRSNL_ID) , ^,^,
					^"reactionStatusDtTm":"^, FORMAT(rALLERGY->DATA[nLOOP].REACTION_STATUS_DT_TM, cDATE_FORMAT), ^"^
					)
 
	IF (VALIDATE(PAYLOAD->ALLERGY->INCLUDECODEVALUES,0) = 1)
		SET _Memory_Reply_String = BUILD(_Memory_Reply_String, ^,^,
					^"substanceTypeCd":^, CNVTINT(rALLERGY->DATA[nLOOP].SUBSTANCE_TYPE_CD), ^,^,
					^"reactionClassCd":^, CNVTINT(rALLERGY->DATA[nLOOP].REACTION_CLASS_CD), ^,^,
					^"severityCd":^, CNVTINT(rALLERGY->DATA[nLOOP].SEVERITY_CD), ^,^,
					^"sourceOfInfoCd":^, CNVTINT(rALLERGY->DATA[nLOOP].SOURCE_OF_INFO_CD), ^,^,
					^"reactionStatusCd":^, CNVTINT(rALLERGY->DATA[nLOOP].REACTION_STATUS_CD), ^,^,
					^"cancelReasonCd":^, CNVTINT(rALLERGY->DATA[nLOOP].CANCEL_REASON_CD), ^,^,
					^"recSrcVocabCd":^, CNVTINT(rALLERGY->DATA[nLOOP].REC_SRC_VOCAB_CD), ^,^,
					^"onsetPrecisionCd":^, CNVTINT(rALLERGY->DATA[nLOOP].ONSET_PRECISION_CD)
					)
	ENDIF
 
	IF (SIZE(rALLERGY->DATA[nLOOP].REACTION, 5) > 0)
		SET _Memory_Reply_String = BUILD(_Memory_Reply_String, ^,"reactions":[^)
		FOR (nLOOP2 = 1 TO SIZE(rALLERGY->DATA[nLOOP].REACTION, 5))
			IF (nLOOP2 > 1)
				SET _Memory_Reply_String = BUILD(_Memory_Reply_String, ^,^)
			ENDIF
			SET _Memory_Reply_String = BUILD(_Memory_Reply_String, ^{^,
						^"reaction":"^, rALLERGY->DATA[nLOOP].REACTION[nLOOP2].REACTION , ^",^,
						^"reactionIdentifier":"^, rALLERGY->DATA[nLOOP].REACTION[nLOOP2].REACTION_IDENTIFIER , ^",^,
						^"reactionFtDesc":"^, rALLERGY->DATA[nLOOP].REACTION[nLOOP2].REACTION_FTDESC , ^"^,
				^}^)
		ENDFOR
		SET _Memory_Reply_String = BUILD(_Memory_Reply_String, ^]^)
	ENDIF
 
 
	IF (SIZE(rALLERGY->DATA[nLOOP].COMMENT, 5) > 0)
		SET _Memory_Reply_String = BUILD(_Memory_Reply_String, ^,"comments":[^)
		FOR (nLOOP2 = 1 TO SIZE(rALLERGY->DATA[nLOOP].COMMENT, 5))
			IF (nLOOP2 > 1)
				SET _Memory_Reply_String = BUILD(_Memory_Reply_String, ^,^)
			ENDIF
			SET _Memory_Reply_String = BUILD(_Memory_Reply_String, ^{^,
						^"commentDtTm":"^, FORMAT(rALLERGY->DATA[nLOOP].COMMENT[nLOOP2].COMMENT_DT_TM, cDATE_FORMAT), ^",^,
						^"commentPrsnlId":^, CNVTINT(rALLERGY->DATA[nLOOP].COMMENT[nLOOP2].COMMENT_PRSNL_ID) , ^,^,
						^"comment":"^, rALLERGY->DATA[nLOOP].COMMENT[nLOOP2].ALLERGY_COMMENT , ^"^,
				^}^)
		ENDFOR
		SET _Memory_Reply_String = BUILD(_Memory_Reply_String, ^]^)
	ENDIF
 
	; End tag
	SET _Memory_Reply_String = BUILD(_Memory_Reply_String, ^}^)
ENDFOR
 
SET _Memory_Reply_String = BUILD(_Memory_Reply_String, ^]^)
 
#END_PROGRAM
 
END GO
/*************************************************************************
 
        Script Name:    1CO_MPAGE_APO.PRG
 
        Description:    Clinical Office - mPage Edition
        				Address/Phone/Organization Data Retrieval
 
        Date Written:   March 23, 2018
        Written by:     John Simpson
                        Precision Healthcare Solutions
 
 *************************************************************************
		   Copyright (c) 2018 Precision Healthcare Solutions
 
 NO PART OF THIS CODE MAY BE COPIED, MODIFIED OR DISTRIBUTED WITHOUT
 PRIOR WRITTEN CONSENT OF PRECISION HEALTHCARE SOLUTIONS EXECUTIVE
 LEADERSHIP TEAM.
 
 FOR LICENSING TERMS PLEASE VISIT www.clinicaloffice.com/mpage/license
 
 *************************************************************************
                            Special Instructions
 *************************************************************************
 Called from 1CO_MPAGE_ENTRY. Do not attempt to run stand alone.
 
 Possible Payload values:
 
	"patientSource":[
		{"personId": value, "encntrId": value}
	],
	"orgSource": [
		{"organizationId": value}
	],
	"organization": {
		"includeCodeValues": true,
		"aliases": true
	},
	"address": {
		"includeCodeValues": true
	},
	"phone": {
		"includeCodeValues": true
	},
	"typeList": [
		{"codeSet": value, "type": "value", "typeCd": value}
	]
 
 
 *************************************************************************
                            Revision Information
 *************************************************************************
 Rev    Date     By             Comments
 ------ -------- -------------- ------------------------------------------
 001    02/23/18 J. Simpson     Initial Development
 002	12/10/18 J. Simpson		Fixed issue where error thrown if no id's
 003    01/09/23 J. Simpson     Added flag to change phone format option
 *************************************************************************/
 
DROP PROGRAM 1CO_MPAGE_APO:GROUP1 GO
CREATE PROGRAM 1CO_MPAGE_APO:GROUP1
 
; Check to see if running from mPage entry script
IF (VALIDATE(PAYLOAD->ADDRESS) = 0 AND VALIDATE(PAYLOAD->PHONE) = 0 AND VALIDATE(PAYLOAD->ORGANIZATION) = 0)
	GO TO END_PROGRAM
ENDIF
 
; Define the PARENT_VALUES structure used to store ID's we want addresses/phones for.
FREE RECORD PARENT_VALUES
RECORD PARENT_VALUES (
	1 DATA[*]
		2 PARENT_ENTITY_ID			= f8
		2 PARENT_ENTITY_NAME		= vc
)
 
; Add the person id values to the parent_values structure
IF (VALIDATE(PATIENT_SOURCE->PATIENTS) = 1)
	SET STAT = ALTERLIST(PARENT_VALUES->DATA, SIZE(PATIENT_SOURCE->PATIENTS, 5))
 
	FOR (nLOOP = 1 TO SIZE(PATIENT_SOURCE->PATIENTS, 5))
		SET PARENT_VALUES->DATA[nLOOP].PARENT_ENTITY_ID = PATIENT_SOURCE->PATIENTS[nLOOP].PERSON_ID
		SET PARENT_VALUES->DATA[nLOOP].PARENT_ENTITY_NAME = "PERSON"
	ENDFOR
ENDIF
 
SET _Memory_Reply_String = BUILD(_Memory_Reply_String, ^,"apoExecuted": 1^)
 
; Add the organization id values to the parent values structure
IF (VALIDATE(PAYLOAD->ORGSOURCE) = 1)
	SET nSTART = SIZE(PARENT_VALUES->DATA, 5)
	SET STAT = ALTERLIST(PARENT_VALUES->DATA, SIZE(PAYLOAD->ORGSOURCE, 5) + nSTART)
	FOR (nLOOP = 1 TO SIZE(PAYLOAD->ORGSOURCE, 5))
		SET PARENT_VALUES->DATA[nSTART + nLOOP].PARENT_ENTITY_ID = PAYLOAD->ORGSOURCE[nLOOP].ORGANIZATIONID
		SET PARENT_VALUES->DATA[nSTART + nLOOP].PARENT_ENTITY_NAME = "ORGANIZATION"
	ENDFOR
ENDIF
 
IF (VALIDATE(PAYLOAD->ORGANIZATION) = 0 OR VALIDATE(PAYLOAD->ORGSOURCE) = 0)
	GO TO SKIP_ORGS
ENDIF
 
SET _Memory_Reply_String = BUILD(_Memory_Reply_String, ^,"organizations":[^)
 
; Collect the organization data
; -----------------------------
FOR (nLOOP = 1 TO SIZE(PAYLOAD->ORGSOURCE, 5))
 
	IF (nLOOP > 1)
		SET _Memory_Reply_String = BUILD(_Memory_Reply_String, ^,^)
	ENDIF
 
	; Set the person_id to return as the first item
	SET _Memory_Reply_String = BUILD(_Memory_Reply_String,
					^{"organizationId":^, CNVTINT(PAYLOAD->ORGSOURCE[nLOOP].ORGANIZATIONID))
 
	; Basic organization level information
	SELECT INTO "NL:"
		ORG_NAME				= O.ORG_NAME,
		FEDERAL_TAX_ID_NBR		= O.FEDERAL_TAX_ID_NBR,
		ORG_STATUS_CD			= O.ORG_STATUS_CD,
		ORG_CLASS_CD			= O.ORG_CLASS_CD,
		EXTERNAL_IND			= O.EXTERNAL_IND
	FROM	ORGANIZATION		O
	PLAN O
		WHERE O.ORGANIZATION_ID = PAYLOAD->ORGSOURCE[nLOOP].ORGANIZATIONID
		AND O.ACTIVE_IND = 1
		AND O.END_EFFECTIVE_DT_TM > SYSDATE
	DETAIL
		_Memory_Reply_String = BUILD(_Memory_Reply_String, ^,^,
			^"orgName":"^, ORG_NAME, ^",^,
			^"federalTaxIdNbr":"^, FEDERAL_TAX_ID_NBR, ^",^,
			^"orgStatus":"^, UAR_GET_CODE_DISPLAY(ORG_STATUS_CD), ^",^,
			^"orgClass":"^, UAR_GET_CODE_DISPLAY(ORG_CLASS_CD), ^",^,
			^"externalInd":^, EXTERNAL_IND
			)
		IF (VALIDATE(PAYLOAD->ORGANIZATION->INCLUDECODEVALUES,0) = 1)
			_Memory_Reply_String = BUILD(_Memory_Reply_String, ^,^,
				^"orgStatusCd":^, CNVTINT(ORG_STATUS_CD), ^,^,
				^"orgClassCd":^, CNVTINT(ORG_CLASS_CD)
			)
		ENDIF
	WITH COUNTER
 
	; Set the Parser
	CALL TYPE_PARSER("OA.ORG_ALIAS_TYPE_CD", 334)
 
	; Org Aliases
	IF (VALIDATE(PAYLOAD->ORGANIZATION->ALIASES, 0) = 1)
		SELECT INTO "NL:"
			ALIAS_POOL_CD				= OA.ALIAS_POOL_CD,
			ORG_ALIAS_TYPE_CD			= OA.ORG_ALIAS_TYPE_CD,
			ALIAS						= OA.ALIAS,
			ORG_ALIAS_SUB_TYPE_CD		= OA.ORG_ALIAS_SUB_TYPE_CD
		FROM	ORGANIZATION_ALIAS			OA
		PLAN OA
			WHERE OA.ORGANIZATION_ID = PAYLOAD->ORGSOURCE[nLOOP].ORGANIZATIONID
			AND PARSER(cPARSER)
			AND OA.ACTIVE_IND = 1
			AND OA.END_EFFECTIVE_DT_TM > SYSDATE
		HEAD REPORT
			_Memory_Reply_String = BUILD(_Memory_Reply_String, ^,"aliases":[^)
			nFIRST = 1
		DETAIL
			IF (nFIRST = 1)
				nFIRST = 0
			ELSE
				_Memory_Reply_String = BUILD(_Memory_Reply_String, ^,^)
			ENDIF
			_Memory_Reply_String = BUILD(_Memory_Reply_String, ^{^,
				^"aliasPool":"^, UAR_GET_CODE_DISPLAY(ALIAS_POOL_CD), ^",^,
				^"aliasType":"^, UAR_GET_CODE_DISPLAY(ORG_ALIAS_TYPE_CD), ^",^,
				^"aliasTypeMeaning":"^, UAR_GET_CODE_MEANING(ORG_ALIAS_TYPE_CD), ^",^,
				^"alias":"^, ALIAS, ^",^,
				^"aliasFormatted":"^, CNVTALIAS(ALIAS, ALIAS_POOL_CD), ^",^,
				^"aliasSubType":"^, UAR_GET_CODE_DISPLAY(ORG_ALIAS_SUB_TYPE_CD), ^"^
			)
 
			IF (VALIDATE(PAYLOAD->ORGANIZATION->INCLUDECODEVALUES,0) = 1)
				_Memory_Reply_String = BUILD(_Memory_Reply_String, ^,^,
					^"aliasPoolCd":^, CNVTINT(ALIAS_POOL_CD), ^,^,
					^"orgAliasTypeCd":^, CNVTINT(ORG_ALIAS_TYPE_CD), ^,^,
					^"orgAliasSubTypeCd":^, CNVTINT(ORG_ALIAS_SUB_TYPE_CD)
				)
			ENDIF
 
			_Memory_Reply_String = BUILD(_Memory_Reply_String, ^}^)
		FOOT REPORT
			_Memory_Reply_String = BUILD(_Memory_Reply_String, ^]^)
		WITH NOCOUNTER
	ENDIF
 
	SET _Memory_Reply_String = BUILD(_Memory_Reply_String, ^}^)
ENDFOR
 
SET _Memory_Reply_String = BUILD(_Memory_Reply_String, ^]^)
 
#SKIP_ORGS
 
; Skip address/phone if no id's loaded
IF (SIZE(PARENT_VALUES->DATA, 5) = 0)
	GO TO END_PROGRAM
ENDIF
 
IF (VALIDATE(PAYLOAD->ADDRESS) = 0)
	GO TO SKIP_ADDRESS
ENDIF
 
; Set the Parser
CALL TYPE_PARSER("A.ADDRESS_TYPE_CD", 212)
 
; Collect the addresses
; ---------------------
SELECT INTO "NL:"
	ADDRESS_ID				= A.ADDRESS_ID,
	PARENT_ENTITY_ID		= A.PARENT_ENTITY_ID,
	PARENT_ENTITY_NAME		= A.PARENT_ENTITY_NAME,
	ADDRESS_TYPE_CD			= A.ADDRESS_TYPE_CD,
	ACTIVE_IND				= A.ACTIVE_IND,
	BEG_EFFECTIVE_DT_TM		= A.BEG_EFFECTIVE_DT_TM,
	END_EFFECTIVE_DT_TM		= A.END_EFFECTIVE_DT_TM,
	STREET_ADDR				= A.STREET_ADDR,
	STREET_ADDR2			= A.STREET_ADDR2,
	STREET_ADDR3			= A.STREET_ADDR3,
	STREET_ADDR4			= A.STREET_ADDR4,
	CITY					= A.CITY,
	STATE_CD				= A.STATE_CD,
	ZIPCODE					= A.ZIPCODE,
	COUNTY_CD				= A.COUNTY_CD,
	COUNTRY_CD				= A.COUNTRY_CD,
	ADDRESS_TYPE_SEQ		= A.ADDRESS_TYPE_SEQ
FROM	(DUMMYT				D WITH SEQ=VALUE(SIZE(PARENT_VALUES->DATA, 5))),
		ADDRESS				A
PLAN D
JOIN A
	WHERE A.PARENT_ENTITY_ID = PARENT_VALUES->DATA[D.SEQ].PARENT_ENTITY_ID
	AND A.PARENT_ENTITY_NAME = PARENT_VALUES->DATA[D.SEQ].PARENT_ENTITY_NAME
	AND PARSER(cPARSER)
	AND A.ACTIVE_IND = 1
	AND A.END_EFFECTIVE_DT_TM > SYSDATE
ORDER PARENT_ENTITY_ID, PARENT_ENTITY_NAME
HEAD REPORT
	_Memory_Reply_String = BUILD(_Memory_Reply_String, ^,"addresses":[^)
 
	nCOMMA = 0
HEAD PARENT_ENTITY_ID
	X = 0
HEAD PARENT_ENTITY_NAME
	X = 0
DETAIL
	IF (nCOMMA = 0) nCOMMA = 1
	ELSE _Memory_Reply_String = BUILD(_Memory_Reply_String, ^,^)
	ENDIF
 
	_Memory_Reply_String = BUILD(_Memory_Reply_String, ^{"parentEntityId":^, CNVTINT(PARENT_ENTITY_ID),
		^,"parentEntityName":"^, PARENT_ENTITY_NAME, ^",^,
		^"addressId":^, CNVTINT(ADDRESS_ID), ^,^,
		^"addressType":"^, UAR_GET_CODE_DISPLAY(ADDRESS_TYPE_CD), ^",^,
		^"addressTypeMeaning":"^, UAR_GET_CODE_MEANING(ADDRESS_TYPE_CD), ^",^,
		^"addressTypeSeq":^, ADDRESS_TYPE_SEQ, ^,^,
		^"activeInd":^, ACTIVE_IND, ^,^,
		^"begEffectiveDtTm":"^, FORMAT(BEG_EFFECTIVE_DT_TM, cDATE_FORMAT), ^",^,
		^"endEffectiveDtTm":"^, FORMAT(END_EFFECTIVE_DT_TM, cDATE_FORMAT), ^",^,
		^"streetAddr":"^, STREET_ADDR, ^",^,
		^"streetAddr2":"^, STREET_ADDR2, ^",^,
		^"streetAddr3":"^, STREET_ADDR3, ^",^,
		^"streetAddr4":"^, STREET_ADDR4, ^",^,
		^"city":"^, CITY, ^",^,
		^"state":"^, UAR_GET_CODE_DISPLAY(STATE_CD), ^",^,
		^"zipCode":"^, ZIPCODE, ^",^,
		^"county":"^, UAR_GET_CODE_DISPLAY(COUNTY_CD), ^",^,
		^"country":"^, UAR_GET_CODE_DISPLAY(COUNTRY_CD), ^"^
	)
 
	IF (VALIDATE(PAYLOAD->ADDRESS->INCLUDECODEVALUES,0) = 1)
		_Memory_Reply_String = BUILD(_Memory_Reply_String, ^,^,
			^"addressTypeCd":^, CNVTINT(ADDRESS_TYPE_CD), ^,^,
			^"stateCd":^, CNVTINT(STATE_CD), ^,^,
			^"countyCd":^, CNVTINT(COUNTY_CD), ^,^,
			^"countryCd":^, CNVTINT(COUNTRY_CD)
		)
	ENDIF
	_Memory_Reply_String = BUILD(_Memory_Reply_String, ^}^)
FOOT PARENT_ENTITY_NAME
	X = 0
FOOT REPORT
	_Memory_Reply_String = BUILD(_Memory_Reply_String, ^]^)
WITH NOCOUNTER
 
#SKIP_ADDRESS
 
IF (VALIDATE(PAYLOAD->PHONE) = 0)
	GO TO SKIP_PHONE
ENDIF
 
; Set the Parser
CALL TYPE_PARSER("PH.PHONE_TYPE_CD", 43)

; Phone format option
declare nPhoneOption = i4 with noconstant(0)
if (validate(payload->phone->phoneOption,0) = 1)
    set nPhoneOption = cnvtint(payload->phone->phoneOption)
endif
 
; Collect the phone information
; -----------------------------
SELECT INTO "NL:"
	PHONE_ID				= PH.PHONE_ID,
	PARENT_ENTITY_ID		= PH.PARENT_ENTITY_ID,
	PARENT_ENTITY_NAME		= PH.PARENT_ENTITY_NAME,
	PHONE_TYPE_CD			= PH.PHONE_TYPE_CD,
	ACTIVE_IND				= PH.ACTIVE_IND,
	BEG_EFFECTIVE_DT_TM		= PH.BEG_EFFECTIVE_DT_TM,
	END_EFFECTIVE_DT_TM		= PH.END_EFFECTIVE_DT_TM,
	PHONE_NUM				= PH.PHONE_NUM,
	PHONE_FORMATTED			= CNVTPHONE(CNVTALPHANUM(PH.PHONE_NUM), PH.PHONE_FORMAT_CD, nPhoneOption),
	EXTENSION				= PH.EXTENSION,
	PHONE_TYPE_SEQ			= PH.PHONE_TYPE_SEQ
FROM	(DUMMYT				D WITH SEQ=VALUE(SIZE(PARENT_VALUES->DATA, 5))),
		PHONE				PH
PLAN D
JOIN PH
	WHERE PH.PARENT_ENTITY_ID = PARENT_VALUES->DATA[D.SEQ].PARENT_ENTITY_ID
	AND PH.PARENT_ENTITY_NAME = PARENT_VALUES->DATA[D.SEQ].PARENT_ENTITY_NAME
	AND PARSER(cPARSER)
	AND PH.ACTIVE_IND = 1
	AND PH.END_EFFECTIVE_DT_TM > SYSDATE
ORDER PARENT_ENTITY_ID, PARENT_ENTITY_NAME
HEAD REPORT
	_Memory_Reply_String = BUILD(_Memory_Reply_String, ^,"phones":[^)
 
	nCOMMA = 0
HEAD PARENT_ENTITY_ID
	X = 0
HEAD PARENT_ENTITY_NAME
	X = 0
DETAIL
	IF (nCOMMA = 0) nCOMMA = 1
	ELSE _Memory_Reply_String = BUILD(_Memory_Reply_String, ^,^)
	ENDIF
 
	_Memory_Reply_String = BUILD(_Memory_Reply_String, ^{"parentEntityId":^, CNVTINT(PARENT_ENTITY_ID),
		^,"parentEntityName":"^, PARENT_ENTITY_NAME, ^",^,
		^"phoneId":^, CNVTINT(PHONE_ID), ^,^,
		^"phoneType":"^, UAR_GET_CODE_DISPLAY(PHONE_TYPE_CD), ^",^,
		^"phoneTypeMeaning":"^, UAR_GET_CODE_MEANING(PHONE_TYPE_CD), ^",^,
		^"phoneTypeSeq":^, PHONE_TYPE_SEQ, ^,^,
		^"activeInd":^, ACTIVE_IND, ^,^,
		^"begEffectiveDtTm":"^, FORMAT(BEG_EFFECTIVE_DT_TM, cDATE_FORMAT), ^",^,
		^"endEffectiveDtTm":"^, FORMAT(END_EFFECTIVE_DT_TM, cDATE_FORMAT), ^",^,
		^"phoneNumber":"^, PHONE_NUM, ^",^,
		^"phoneFormatted":"^, PHONE_FORMATTED, ^",^,
		^"extension":"^, EXTENSION, ^"^)
	IF (VALIDATE(PAYLOAD->PHONE->INCLUDECODEVALUES,0) = 1)
		_Memory_Reply_String = BUILD(_Memory_Reply_String, ^,^,
			^"phoneTypeCd":^, CNVTINT(PHONE_TYPE_CD)
		)
	ENDIF
 
	_Memory_Reply_String = BUILD(_Memory_Reply_String, ^}^)
FOOT PARENT_ENTITY_NAME
	X = 0
FOOT REPORT
	_Memory_Reply_String = BUILD(_Memory_Reply_String, ^]^)
WITH NOCOUNTER
 
#SKIP_PHONE
#END_PROGRAM
 
END GO
/*************************************************************************
 
        Script Name:    1co_mpage_census_list:group1
 
        Description:    Clinical Office - mPage Edition
        				LoadList Census Script
 
        Date Written:   July 4, 2020
        Written by:     John Simpson
                        Precision Healthcare Solutions
 
 *************************************************************************
		   Copyright (c) 2020 Precision Healthcare Solutions
 
 NO PART OF THIS CODE MAY BE COPIED, MODIFIED OR DISTRIBUTED WITHOUT
 PRIOR WRITTEN CONSENT OF PRECISION HEALTHCARE SOLUTIONS EXECUTIVE
 LEADERSHIP TEAM.
 
 FOR LICENSING TERMS PLEASE VISIT www.clinicaloffice.com/mpage/license
 
 *************************************************************************
                            Special Instructions
 *************************************************************************
 Called from 1CO_MPAGE_ENTRY. Do not attempt to run stand alone. If you
 wish to test the development of your custom script from the CCL back-end,
 please run with 1CO_MPAGE_TEST.
 
 Possible Payload values:
 
	"customScript": {
		"script": [
			"name": "your custom script name:GROUP1",
			"id": "identifier for your output, omit if you won't be returning data",
			"run": "pre or post",
			"parameters": {
				"your custom parameters for your job"
			}
		],
		"clearPatientSource": true
	},
	"typeList": [
		{"codeSet": value, "type": "value", "typeCd": value}
	]
 
 
 
 *************************************************************************
                            Revision Information
 *************************************************************************
 Rev    Date     By             Comments
 ------ -------- -------------- ------------------------------------------
 001    07/04/20 J. Simpson     Initial Development
 *************************************************************************/
 
drop program 1co_mpage_census_list:group1 go
create program 1co_mpage_census_list:group1
 
; Check to see if we have cleared the patient source and if not, do we have data in the patient source
; to run our custom CCL against.
if (validate(payload->customscript->clearpatientsource, 0) = 0)
	if (size(patient_source->patients, 5) = 0)
		go to end_program
	endif
endif
 
; Define the custom record structure you wish to have sent back in the JSON to the mPage. The name
; of the record structure can be anything you want.
free record rCustom
record rCustom (
	1 visits[*]
		2 person_id					= f8
		2 encntr_id					= f8
)
 
; Set the Parser for the various filters
declare cParser = vc
declare cParser2 = vc
 
call Type_Parser("e.encntr_type_class_cd", 69)
set cParser2 = cParser
call Type_Parser("ed.loc_nurse_unit_cd", 220)
 
; Clear the patient source
set stat = initrec(patient_source)
 
; Collect the census
select into "nl:"
	person_id				= e.person_id,
	encntr_id				= e.encntr_id
from	encntr_domain			ed,
		encounter				e
plan ed
	where ed.end_effective_dt_tm > sysdate
	and parser(cParser)
	and ed.active_ind = 1
join e
	where e.encntr_id = ed.encntr_id
	and nullind(e.disch_dt_tm) = 1
	and parser(cParser2)
	and e.active_ind = 1
order person_id, encntr_id
head report
	nPerson = 0
	nEncounter = 0
head person_id
	nPerson = nPerson + 1
 
	stat = alterlist(patient_source->patients, nPerson)
	patient_source->patients[nPerson].person_id = person_id
head encntr_id
	nEncounter = nEncounter + 1
 
	stat = alterlist(patient_source->visits, nEncounter)
	patient_source->visits[nEncounter].person_id = person_id
	patient_source->visits[nEncounter].encntr_id = encntr_id
with nocounter
 
; Update rCustom with the patient list
if (size(patient_source->visits, 5) > 0)
	set stat = moverec(patient_source->visits, rCustom)
 
	call Add_Custom_Output(cnvtrectojson(rCustom, 4, 1))
endif
 
#end_program
 
end go
/*************************************************************************
 
        Script Name:    1CO_MPAGE_CVLOOKUP.PRG
 
        Description:    Clinical Office - mPage Edition
        				Generic Code Value Lookup
 
        Date Written:   March 2, 2018
        Written by:     John Simpson
                        Precision Healthcare Solutions
 
 *************************************************************************
		   Copyright (c) 2018 Precision Healthcare Solutions
 
 NO PART OF THIS CODE MAY BE COPIED, MODIFIED OR DISTRIBUTED WITHOUT
 PRIOR WRITTEN CONSENT OF PRECISION HEALTHCARE SOLUTIONS EXECUTIVE
 LEADERSHIP TEAM.
 
 FOR LICENSING TERMS PLEASE VISIT www.clinicaloffice.com/mpage/license
 
 *************************************************************************
                            Special Instructions
 *************************************************************************
 Called from 1CO_MPAGE_ENTRY. Do not attempt to run stand alone.
 
 Possible Payload values:
 
     "codeSet": [
		{ "cs": cs, "cv": codeValue, "filter": displayKey, "alias": displayKey, "outboundAlias": true }
     ]
 
  *************************************************************************
                            Revision Information
 *************************************************************************
 Rev    Date     By             Comments
 ------ -------- -------------- ------------------------------------------
 001    02/03/18 J. Simpson     Initial Development
 002    02/10/21 J. Simpson     Set default sort to display key
 003    05/16/22 J. Simpson     Switched to use CNVTRECTOJSON
 *************************************************************************/
 
drop program 1co_mpage_cvlookup:group1 go
create program 1co_mpage_cvlookup:group1
 
; Check to see if running from mPage entry script
if (validate(payload->codevalue) = 0)
	go to end_program
endif
 
record rCodeValue (
	1 code_values[*]
		2 code_value					= f8
		2 code_set						= i4
		2 cdf_meaning					= vc
		2 display						= vc
		2 display_key					= vc
		2 description					= vc
		2 definition					= vc
		2 alias_ind						= vc
		2 alias							= vc
		2 outbound_ind					= vc
		2 outbound						= vc
)
 
for (nLoop = 1 to size(payload->codevalue, 5))
	; Ensure the parser works
	if (payload->codevalue[nloop].filter = "")
		set payload->codevalue[nloop].filter = "1=1"
	endif
 
	; Collect the code values
	select into "nl:"
	from	code_value	cv
	plan cv
		where (cv.code_set = payload->codevalue[nloop].cs
		or cv.code_value = payload->codevalue[nloop].value)
		and cv.code_value != 0
		and parser(payload->codevalue[nloop].filter)
		and cv.active_ind = 1
		and cv.end_effective_dt_tm > sysdate
		and cv.code_set > 0
    order cv.display_key
	head report
		ncount = size(rCodeValue->code_values, 5)
	detail
		ncount = ncount + 1
		stat = alterlist(rCodeValue->code_values, ncount)
 
		rCodeValue->code_values[ncount].code_value = cv.code_value
		rCodeValue->code_values[ncount].code_set = cv.code_set
		rCodeValue->code_values[ncount].cdf_meaning = cv.cdf_meaning
		rCodeValue->code_values[ncount].display = cv.display
		rCodeValue->code_values[ncount].display_key = cv.display_key
		rCodeValue->code_values[ncount].description = cv.description
		rCodeValue->code_values[ncount].definition = cv.definition
		rCodeValue->code_values[ncount].alias_ind = payload->codevalue[nloop].alias
		rCodeValue->code_values[ncount].outbound_ind = payload->codevalue[nloop].outboundalias
	with nocounter
endfor
 
; Collect the alias
select into "nl:"
	dseq			= d.seq,
	primary_ind		= cva.primary_ind
from	(dummyt				d with seq=value(size(rCodeValue->code_values, 5))),
		code_value_alias	cva,
		code_value			cv
plan d
	where trim(rCodeValue->code_values[d.seq].alias_ind) != ""
join cva
	where cva.code_value = rCodeValue->code_values[d.seq].code_value
join cv
	where cv.code_value = cva.contributor_source_cd
	and cv.display_key = cnvtupper(rCodeValue->code_values[d.seq].alias_ind)
order dseq, primary_ind
detail
	rCodeValue->code_values[d.seq].alias = cva.alias
with nocounter
 
; Collect outbound alias
select into "nl:"
	dseq			= d.seq
from	(dummyt				d with seq=value(size(rCodeValue->code_values, 5))),
		code_value_outbound	cvo,
		code_value			cv
plan d
	where trim(rCodeValue->code_values[d.seq].outbound_ind) != ""
join cvo
	where cvo.code_value = rCodeValue->code_values[d.seq].code_value
join cv
	where cv.code_value = cvo.contributor_source_cd
	and cv.display_key = cnvtupper(rCodeValue->code_values[d.seq].outbound_ind)
order dseq
detail
	rCodeValue->code_values[d.seq].outbound = cvo.alias
with nocounter
 
; Output the JSON
if (size(rCodeValue->code_values, 5) > 0)
	call add_standard_output(cnvtrectojson(rCodeValue, 4, 1))
endif
 
#end_program
 
end go
/*************************************************************************
 
        Script Name:    1CO_MPAGE_DIAGNOSIS.PRG
 
        Description:    Clinical Office - mPage Edition
        				Diagnosis Data Retrieval
 
        Date Written:   May 3, 2018
        Written by:     John Simpson
                        Precision Healthcare Solutions
 
 *************************************************************************
		   Copyright (c) 2018 Precision Healthcare Solutions
 
 NO PART OF THIS CODE MAY BE COPIED, MODIFIED OR DISTRIBUTED WITHOUT
 PRIOR WRITTEN CONSENT OF PRECISION HEALTHCARE SOLUTIONS EXECUTIVE
 LEADERSHIP TEAM.
 
 FOR LICENSING TERMS PLEASE VISIT www.clinicaloffice.com/mpage/license
 
 *************************************************************************
                            Special Instructions
 *************************************************************************
 Called from 1CO_MPAGE_ENTRY. Do not attempt to run stand alone.
 
 Possible Payload values:
 
	"patientSource":[
		{"personId": value, "encntrId": value}
	],
	"diagnosis": {
    	"includeCodeValues": true
	},
	"typeList": [
		{"codeSet": value, "type": "value", "typeCd": value}
	]
 
 
 
 *************************************************************************
                            Revision Information
 *************************************************************************
 Rev    Date     By             Comments
 ------ -------- -------------- ------------------------------------------
 001    02/06/18 J. Simpson     Initial Development
 *************************************************************************/
 
DROP PROGRAM 1CO_MPAGE_DIAGNOSIS:GROUP1 GO
CREATE PROGRAM 1CO_MPAGE_DIAGNOSIS:GROUP1
 
; Check to see if running from mPage entry script
IF (VALIDATE(PAYLOAD->DIAGNOSIS) = 0 OR SIZE(PATIENT_SOURCE->VISITS, 5) = 0)
	GO TO END_PROGRAM
ENDIF
 
RECORD rDIAGNOSIS (
	1 DATA[*]
		2 PERSON_ID						= f8
		2 ENCNTR_ID						= f8
		2 DIAGNOSIS_ID					= f8
		2 NOMENCLATURE_ID				= f8
		2 DX_SOURCE_STRING				= vc
		2 DX_SOURCE_IDENTIFIER			= vc
		2 DX_SOURCE_VOCAB_CD			= f8
		2 DIAG_DT_TM					= dq8
		2 DIAG_TYPE_CD					= f8
		2 DIAGNOSTIC_CATEGORY_CD		= f8
		2 DIAG_PRIORITY					= i4
		2 DIAG_PRSNL_ID					= f8
		2 DIAG_PRSNL_NAME				= vc
		2 DIAG_CLASS_CD					= f8
		2 CONFID_LEVEL_CD				= f8
		2 ATTESTATION_DT_TM				= dq8
		2 DIAG_FTDESC					= vc
		2 MOD_NOMENCLATURE_ID			= f8
		2 MOD_SOURCE_STRING				= vc
		2 MOD_SOURCE_IDENTIFIER			= vc
		2 MOD_SOURCE_VOCAB_CD			= f8
		2 DIAG_NOTE						= vc
		2 CONDITIONAL_QUAL_CD			= f8
		2 CLINICAL_SERVICE_CD			= f8
		2 CONFIRMATION_STATUS_CD		= f8
		2 CLASSIFICATION_CD				= f8
		2 SEVERITY_CLASS_CD				= f8
		2 CERTAINTY_CD					= f8
		2 PROBABILITY					= i4
		2 DIAGNOSIS_DISPLAY				= vc
		2 SEVERITY_FTDESC				= vc
		2 LONG_BLOB_ID					= f8
		2 RANKING_CD					= f8
		2 SEVERITY_CD					= f8
		2 DIAGNOSIS_GROUP				= f8
		2 CLINICAL_DIAG_PRIORITY		= i4
		2 PRESENT_ON_ADMIT_CD			= f8
		2 HAC_IND						= i4
		2 LATERALITY_CD					= f8
		2 ORIGINATING_NOMENCLATURE_ID	= f8
		2 ORIG_DX_SOURCE_STRING			= vc
		2 ORIG_DX_SOURCE_IDENTIFIER		= vc
		2 ORIG_DX_SOURCE_VOCAB_CD		= f8
 
)
 
DECLARE cPARSER = vc
DECLARE cPARSER2= vc
 
; Set the Parser
CALL TYPE_PARSER("N.SOURCE_VOCABULARY_CD", 400)
SET cPARSER2 = cPARSER
CALL TYPE_PARSER("DX.DIAG_TYPE_CD", 17)
 
; Collect the diagnosis
SELECT INTO "NL:"
	DSEQ				= D.SEQ,
	SORT_KEY			= CNVTUPPER(DX.DIAGNOSIS_DISPLAY)
FROM	(DUMMYT				D WITH SEQ=VALUE(SIZE(PATIENT_SOURCE->VISITS, 5))),
		DIAGNOSIS			DX,
		NOMENCLATURE		N,
		NOMENCLATURE		N2,
		NOMENCLATURE		N3
PLAN D
JOIN DX
	WHERE DX.ENCNTR_ID = PATIENT_SOURCE->VISITS[D.SEQ].ENCNTR_ID
	AND PARSER(cPARSER)
	AND DX.ACTIVE_IND = 1
	AND DX.END_EFFECTIVE_DT_TM > SYSDATE
JOIN N
	WHERE N.NOMENCLATURE_ID = DX.NOMENCLATURE_ID
	AND PARSER(cPARSER2)
JOIN N2
	WHERE N2.NOMENCLATURE_ID = DX.MOD_NOMENCLATURE_ID
JOIN N3
	WHERE N3.NOMENCLATURE_ID = DX.ORIGINATING_NOMENCLATURE_ID
ORDER BY DSEQ, SORT_KEY
HEAD REPORT
	nCOUNT = 0
DETAIL
	nCOUNT = nCOUNT + 1
	STAT = ALTERLIST(rDIAGNOSIS->DATA, nCOUNT)
 
	rDIAGNOSIS->DATA[nCOUNT].PERSON_ID = DX.PERSON_ID
	rDIAGNOSIS->DATA[nCOUNT].ENCNTR_ID = DX.ENCNTR_ID
	rDIAGNOSIS->DATA[nCOUNT].DIAGNOSIS_ID = DX.DIAGNOSIS_ID
	rDIAGNOSIS->DATA[nCOUNT].NOMENCLATURE_ID = DX.NOMENCLATURE_ID
	rDIAGNOSIS->DATA[nCOUNT].DX_SOURCE_STRING = N.SOURCE_STRING
	rDIAGNOSIS->DATA[nCOUNT].DX_SOURCE_IDENTIFIER = N.SOURCE_IDENTIFIER
	rDIAGNOSIS->DATA[nCOUNT].DX_SOURCE_VOCAB_CD = N.SOURCE_VOCABULARY_CD
	rDIAGNOSIS->DATA[nCOUNT].DIAG_DT_TM = DX.DIAG_DT_TM
	rDIAGNOSIS->DATA[nCOUNT].DIAG_TYPE_CD = DX.DIAG_TYPE_CD
	rDIAGNOSIS->DATA[nCOUNT].DIAGNOSTIC_CATEGORY_CD = DX.DIAGNOSTIC_CATEGORY_CD
	rDIAGNOSIS->DATA[nCOUNT].DIAG_PRIORITY = DX.DIAG_PRIORITY
	rDIAGNOSIS->DATA[nCOUNT].DIAG_PRSNL_ID = DX.DIAG_PRSNL_ID
	rDIAGNOSIS->DATA[nCOUNT].DIAG_PRSNL_NAME = DX.DIAG_PRSNL_NAME
	rDIAGNOSIS->DATA[nCOUNT].DIAG_CLASS_CD = DX.DIAG_CLASS_CD
	rDIAGNOSIS->DATA[nCOUNT].CONFID_LEVEL_CD = DX.CONFID_LEVEL_CD
	rDIAGNOSIS->DATA[nCOUNT].ATTESTATION_DT_TM = DX.ATTESTATION_DT_TM
	rDIAGNOSIS->DATA[nCOUNT].DIAG_FTDESC = DX.DIAG_FTDESC
	rDIAGNOSIS->DATA[nCOUNT].MOD_NOMENCLATURE_ID = DX.MOD_NOMENCLATURE_ID
	rDIAGNOSIS->DATA[nCOUNT].MOD_SOURCE_IDENTIFIER = N2.SOURCE_IDENTIFIER
	rDIAGNOSIS->DATA[nCOUNT].MOD_SOURCE_STRING = N2.SOURCE_STRING
	rDIAGNOSIS->DATA[nCOUNT].MOD_SOURCE_VOCAB_CD = N2.SOURCE_VOCABULARY_CD
	rDIAGNOSIS->DATA[nCOUNT].DIAG_NOTE = DX.DIAG_NOTE
	rDIAGNOSIS->DATA[nCOUNT].CONDITIONAL_QUAL_CD = DX.CONDITIONAL_QUAL_CD
	rDIAGNOSIS->DATA[nCOUNT].CLINICAL_SERVICE_CD = DX.CLINICAL_SERVICE_CD
	rDIAGNOSIS->DATA[nCOUNT].CONFIRMATION_STATUS_CD = DX.CONFIRMATION_STATUS_CD
	rDIAGNOSIS->DATA[nCOUNT].CLASSIFICATION_CD = DX.CLASSIFICATION_CD
	rDIAGNOSIS->DATA[nCOUNT].SEVERITY_CLASS_CD = DX.SEVERITY_CLASS_CD
	rDIAGNOSIS->DATA[nCOUNT].CERTAINTY_CD = DX.CERTAINTY_CD
	rDIAGNOSIS->DATA[nCOUNT].PROBABILITY = DX.PROBABILITY
	rDIAGNOSIS->DATA[nCOUNT].DIAGNOSIS_DISPLAY = DX.DIAGNOSIS_DISPLAY
	rDIAGNOSIS->DATA[nCOUNT].SEVERITY_FTDESC = DX.SEVERITY_FTDESC
	rDIAGNOSIS->DATA[nCOUNT].LONG_BLOB_ID = DX.LONG_BLOB_ID
	rDIAGNOSIS->DATA[nCOUNT].RANKING_CD = DX.RANKING_CD
	rDIAGNOSIS->DATA[nCOUNT].SEVERITY_CD = DX.SEVERITY_CD
	rDIAGNOSIS->DATA[nCOUNT].DIAGNOSIS_GROUP = DX.DIAGNOSIS_GROUP
	rDIAGNOSIS->DATA[nCOUNT].CLINICAL_DIAG_PRIORITY = DX.CLINICAL_DIAG_PRIORITY
	rDIAGNOSIS->DATA[nCOUNT].PRESENT_ON_ADMIT_CD = DX.PRESENT_ON_ADMIT_CD
	rDIAGNOSIS->DATA[nCOUNT].HAC_IND = DX.HAC_IND
	rDIAGNOSIS->DATA[nCOUNT].LATERALITY_CD = DX.LATERALITY_CD
	rDIAGNOSIS->DATA[nCOUNT].ORIGINATING_NOMENCLATURE_ID = DX.ORIGINATING_NOMENCLATURE_ID
	rDIAGNOSIS->DATA[nCOUNT].ORIG_DX_SOURCE_STRING = N3.SOURCE_STRING
	rDIAGNOSIS->DATA[nCOUNT].ORIG_DX_SOURCE_IDENTIFIER = N3.SOURCE_IDENTIFIER
	rDIAGNOSIS->DATA[nCOUNT].ORIG_DX_SOURCE_VOCAB_CD = N3.SOURCE_VOCABULARY_CD
 
WITH NOCOUNTER
 
; Skip the rest if no allergies loaded
IF (SIZE(rDIAGNOSIS->DATA, 5) = 0)
	GO TO END_PROGRAM
ENDIF
 
SET _Memory_Reply_String = BUILD(_Memory_Reply_String, ^,"diagnosis":[^)
 
; Loop through all the patients
FOR (nLOOP = 1 TO SIZE(rDIAGNOSIS->DATA, 5))
	IF (nLOOP > 1)
		SET _Memory_Reply_String = BUILD(_Memory_Reply_String, ^,^)
	ENDIF
 
	; Set the person_id to return as the first item
	SET _Memory_Reply_String = BUILD(_Memory_Reply_String,
					^{"personId":^, CNVTINT(rDIAGNOSIS->DATA[nLOOP].PERSON_ID), ^,^,
					^"encntrId":^, CNVTINT(rDIAGNOSIS->DATA[nLOOP].ENCNTR_ID), ^,^,
					^"diagnosisId":^, CNVTINT(rDIAGNOSIS->DATA[nLOOP].DIAGNOSIS_ID), ^,^,
					^"nomenclatureId":^, CNVTINT(rDIAGNOSIS->DATA[nLOOP].NOMENCLATURE_ID), ^,^,
					^"dxSourceString":"^, rDIAGNOSIS->DATA[nLOOP].DX_SOURCE_STRING, ^",^,
					^"dxSourceIdentifier":"^, rDIAGNOSIS->DATA[nLOOP].DX_SOURCE_IDENTIFIER, ^",^,
					^"dxVocab":"^, UAR_GET_CODE_DISPLAY(rDIAGNOSIS->DATA[nLOOP].DX_SOURCE_VOCAB_CD), ^",^,
					^"diagDtTm":"^, FORMAT(rDIAGNOSIS->DATA[nLOOP].DIAG_DT_TM, cDATE_FORMAT), ^",^,
					^"diagType":"^, UAR_GET_CODE_DISPLAY(rDIAGNOSIS->DATA[nLOOP].DIAG_TYPE_CD), ^",^,
					^"diagTypeMeaning":"^, UAR_GET_CODE_MEANING(rDIAGNOSIS->DATA[nLOOP].DIAG_TYPE_CD), ^",^,
					^"diagnosticCategory":"^, UAR_GET_CODE_DISPLAY(rDIAGNOSIS->DATA[nLOOP].DIAGNOSTIC_CATEGORY_CD), ^",^,
					^"diagPriority":^, CNVTINT(rDIAGNOSIS->DATA[nLOOP].DIAG_PRIORITY), ^,^,
					^"diagPrsnlId":^, CNVTINT(rDIAGNOSIS->DATA[nLOOP].DIAG_PRSNL_ID), ^,^,
					^"diagPrsnlName":"^, rDIAGNOSIS->DATA[nLOOP].DIAG_PRSNL_NAME, ^",^,
					^"diagClass":"^, UAR_GET_CODE_DISPLAY(rDIAGNOSIS->DATA[nLOOP].DIAG_CLASS_CD), ^",^,
					^"confidLevel":"^, UAR_GET_CODE_DISPLAY(rDIAGNOSIS->DATA[nLOOP].CONFID_LEVEL_CD), ^",^,
					^"attestationDtTm":"^, FORMAT(rDIAGNOSIS->DATA[nLOOP].ATTESTATION_DT_TM, cDATE_FORMAT), ^",^,
					^"diagFtDesc":"^, rDIAGNOSIS->DATA[nLOOP].DIAG_FTDESC, ^",^,
					^"modNomenclatureId":^, CNVTINT(rDIAGNOSIS->DATA[nLOOP].MOD_NOMENCLATURE_ID), ^,^,
					^"modSourceString":"^, rDIAGNOSIS->DATA[nLOOP].MOD_SOURCE_STRING, ^",^,
					^"modSourceIdentifier":"^, rDIAGNOSIS->DATA[nLOOP].MOD_SOURCE_IDENTIFIER, ^",^,
					^"modVocab":"^, UAR_GET_CODE_DISPLAY(rDIAGNOSIS->DATA[nLOOP].MOD_SOURCE_VOCAB_CD), ^",^,
					^"diagNote":"^, rDIAGNOSIS->DATA[nLOOP].DIAG_NOTE, ^",^,
					^"conditionalQual":"^, UAR_GET_CODE_DISPLAY(rDIAGNOSIS->DATA[nLOOP].CONDITIONAL_QUAL_CD), ^",^,
					^"clinicalService":"^, UAR_GET_CODE_DISPLAY(rDIAGNOSIS->DATA[nLOOP].CLINICAL_SERVICE_CD), ^",^,
					^"confirmationStatus":"^, UAR_GET_CODE_DISPLAY(rDIAGNOSIS->DATA[nLOOP].CONFIRMATION_STATUS_CD), ^",^,
					^"classification":"^, UAR_GET_CODE_DISPLAY(rDIAGNOSIS->DATA[nLOOP].CLASSIFICATION_CD), ^",^,
					^"severityClass":"^, UAR_GET_CODE_DISPLAY(rDIAGNOSIS->DATA[nLOOP].SEVERITY_CLASS_CD), ^",^,
					^"certainty":"^, UAR_GET_CODE_DISPLAY(rDIAGNOSIS->DATA[nLOOP].CERTAINTY_CD), ^",^,
					^"probability":^, rDIAGNOSIS->DATA[nLOOP].PROBABILITY, ^,^,
					^"diagnosisDisplay":"^, rDIAGNOSIS->DATA[nLOOP].DIAGNOSIS_DISPLAY, ^",^,
					^"severityFtDesc":"^, rDIAGNOSIS->DATA[nLOOP].SEVERITY_FTDESC, ^",^,
					^"longBlobId":^, CNVTINT(rDIAGNOSIS->DATA[nLOOP].LONG_BLOB_ID), ^,^,
					^"ranking":"^, UAR_GET_CODE_DISPLAY(rDIAGNOSIS->DATA[nLOOP].RANKING_CD), ^",^,
					^"severity":"^, UAR_GET_CODE_DISPLAY(rDIAGNOSIS->DATA[nLOOP].SEVERITY_CD), ^",^,
					^"diagnosisGroup":^, CNVTINT(rDIAGNOSIS->DATA[nLOOP].DIAGNOSIS_GROUP), ^,^,
					^"clinicalDiagPriority":^, rDIAGNOSIS->DATA[nLOOP].CLINICAL_DIAG_PRIORITY, ^,^,
					^"presentOnAdmit":"^, UAR_GET_CODE_DISPLAY(rDIAGNOSIS->DATA[nLOOP].PRESENT_ON_ADMIT_CD), ^",^,
					^"hacInd":^, rDIAGNOSIS->DATA[nLOOP].HAC_IND, ^,^,
					^"laterality":"^, UAR_GET_CODE_DISPLAY(rDIAGNOSIS->DATA[nLOOP].LATERALITY_CD), ^",^,
					^"originatingNomenclatureId":^, CNVTINT(rDIAGNOSIS->DATA[nLOOP].ORIGINATING_NOMENCLATURE_ID), ^,^,
					^"origDxSourceString":"^, rDIAGNOSIS->DATA[nLOOP].ORIG_DX_SOURCE_STRING, ^",^,
					^"origDxSourceIdentifier":"^, rDIAGNOSIS->DATA[nLOOP].ORIG_DX_SOURCE_IDENTIFIER, ^",^,
					^"origDxSourceVocab":"^, UAR_GET_CODE_DISPLAY(rDIAGNOSIS->DATA[nLOOP].ORIG_DX_SOURCE_VOCAB_CD), ^"^
					)
 
	IF (VALIDATE(PAYLOAD->DIAGNOSIS->INCLUDECODEVALUES,0) = 1)
		SET _Memory_Reply_String = BUILD(_Memory_Reply_String, ^,^,
					^"dxVocabCd":^, CNVTINT(rDIAGNOSIS->DATA[nLOOP].DX_SOURCE_VOCAB_CD), ^,^,
					^"diagTypeCd":^, CNVTINT(rDIAGNOSIS->DATA[nLOOP].DIAG_TYPE_CD), ^,^,
					^"diagnosticCategoryCd":^, CNVTINT(rDIAGNOSIS->DATA[nLOOP].DIAGNOSTIC_CATEGORY_CD), ^,^,
					^"diagClassCd":^, CNVTINT(rDIAGNOSIS->DATA[nLOOP].DIAG_CLASS_CD), ^,^,
					^"confidLevelCd":^, CNVTINT(rDIAGNOSIS->DATA[nLOOP].CONFID_LEVEL_CD), ^,^,
					^"modVocabCd":^, CNVTINT(rDIAGNOSIS->DATA[nLOOP].MOD_SOURCE_VOCAB_CD), ^,^,
					^"conditionalQualCd":^, CNVTINT(rDIAGNOSIS->DATA[nLOOP].CONDITIONAL_QUAL_CD), ^,^,
					^"clinicalServiceCd":^, CNVTINT(rDIAGNOSIS->DATA[nLOOP].CLINICAL_SERVICE_CD), ^,^,
					^"confirmationStatusCd":^, CNVTINT(rDIAGNOSIS->DATA[nLOOP].CONFIRMATION_STATUS_CD), ^,^,
					^"classificationCd":^, CNVTINT(rDIAGNOSIS->DATA[nLOOP].CLASSIFICATION_CD), ^,^,
					^"severityClassCd":^, CNVTINT(rDIAGNOSIS->DATA[nLOOP].SEVERITY_CLASS_CD), ^,^,
					^"certaintyCd":^, CNVTINT(rDIAGNOSIS->DATA[nLOOP].CERTAINTY_CD), ^,^,
					^"rankingCd":^, CNVTINT(rDIAGNOSIS->DATA[nLOOP].RANKING_CD), ^,^,
					^"severityCd":^, CNVTINT(rDIAGNOSIS->DATA[nLOOP].SEVERITY_CD), ^,^,
					^"presentOnAdmitCd":^, CNVTINT(rDIAGNOSIS->DATA[nLOOP].PRESENT_ON_ADMIT_CD), ^,^,
					^"lateralityCd":^, CNVTINT(rDIAGNOSIS->DATA[nLOOP].LATERALITY_CD), ^,^,
					^"origDxSourceVocabCd":^, CNVTINT(rDIAGNOSIS->DATA[nLOOP].ORIG_DX_SOURCE_VOCAB_CD)
					)
	ENDIF
 
 
	; End tag
	SET _Memory_Reply_String = BUILD(_Memory_Reply_String, ^}^)
ENDFOR
 
SET _Memory_Reply_String = BUILD(_Memory_Reply_String, ^]^)
 
#END_PROGRAM
 
END GO
/*************************************************************************
 
        Script Name:    1CO_MPAGE_DM_INFO.PRG
 
        Description:    Clinical Office - MPage Edition
        				DM_INFO Read/Write Script
 
        Date Written:   June 5, 2018
        Written by:     John Simpson
                        Precision Healthcare Solutions
 
 *************************************************************************
		   Copyright (c) 2018 Precision Healthcare Solutions
 
 NO PART OF THIS CODE MAY BE COPIED, MODIFIED OR DISTRIBUTED WITHOUT
 PRIOR WRITTEN CONSENT OF PRECISION HEALTHCARE SOLUTIONS EXECUTIVE
 LEADERSHIP TEAM.
 
 FOR LICENSING TERMS PLEASE VISIT www.clinicaloffice.com/mpage/license
 
 *************************************************************************
                            Special Instructions
 *************************************************************************
 Called from 1CO_MPAGE_ENTRY. Do not attempt to run stand alone. If you
 wish to test the development of your custom script from the CCL back-end,
 please run with 1CO_MPAGE_TEST.
 
 Possible Payload values:
 
	"customScript": {
		"script": [
			"name": "1CO_MPAGE_DM_INFO:GROUP1",
			"id": "identifier for your output, omit if you won't be returning data",
			"run": "pre or post",
			"parameters": {
				"action": "read, write or delete",
				"data": [{
					"infoDomain": "string",
					"infoName": "string",
					"infoDate": "JavaScript Date or null",
					"infoChar": "string",
					"infoNumber": number,
					"infoLongText": "string",
					"infoDomainId": number
				}]
			}
		],
		"clearPatientSource": true
	}
 
 
 *************************************************************************
                            Revision Information
 *************************************************************************
 Rev    Date     By             Comments
 ------ -------- -------------- ------------------------------------------
 001    06/05/18 J. Simpson     Initial Development
 *************************************************************************/
DROP PROGRAM 1CO_MPAGE_DM_INFO:GROUP1 GO
CREATE PROGRAM 1CO_MPAGE_DM_INFO:GROUP1
 
DECLARE cACTION = vc
 
; Check to see if we have cleared the patient source and if not, do we have data in the patient source
; to run our custom CCL against.
IF (VALIDATE(PAYLOAD->CUSTOMSCRIPT->CLEARPATIENTSOURCE, 0) = 0)
	IF (SIZE(PATIENT_SOURCE->PATIENTS, 5) = 0)
		GO TO END_PROGRAM
	ENDIF
ENDIF
 
; Define the custom record structure you wish to have sent back in the JSON to the mPage. The name
; of the record structure can be anything you want.
FREE RECORD rCUSTOM
RECORD rCUSTOM (
	1 DM_INFO[*]
		2 INFO_DOMAIN				= vc
		2 INFO_NAME					= vc
		2 INFO_DATE					= dq8
		2 INFO_CHAR					= vc
		2 INFO_NUMBER				= f8
		2 LONG_TEXT_ID				= f8
		2 LONG_TEXT					= vc
		2 UPDT_DT_TM				= dq8
		2 UPDT_ID					= f8
		2 INFO_DOMAIN_ID			= f8
		2 ACTION_STATUS				= vc
)
 
; Check the action and perform the correct tasks
IF (VALIDATE(PAYLOAD->CUSTOMSCRIPT->SCRIPT[nSCRIPT]->PARAMETERS->ACTION) = 1)
	SET cACTION = SUBSTRING(1,1,CNVTUPPER(PAYLOAD->CUSTOMSCRIPT->SCRIPT[nSCRIPT]->PARAMETERS->ACTION))
 
	; Read the records (Needed for read operation, write if an update and to collect the LONG_TEXT_ID if deleting)
	SELECT INTO "NL:"
		D.SEQ, DI.SEQ
	FROM	(DUMMYT			D WITH SEQ=VALUE(SIZE(PAYLOAD->CUSTOMSCRIPT->SCRIPT[nSCRIPT]->PARAMETERS->DATA, 5))),
			DM_INFO			DI,
			DUMMYT			D_OJ
	PLAN D
	JOIN D_OJ
	JOIN DI
		WHERE PAYLOAD->CUSTOMSCRIPT->SCRIPT[nSCRIPT]->PARAMETERS->DATA[D.SEQ].INFODOMAIN = DI.INFO_DOMAIN
		AND (
				PAYLOAD->CUSTOMSCRIPT->SCRIPT[nSCRIPT]->PARAMETERS->DATA[D.SEQ].INFONAME = DI.INFO_NAME
				OR
				(TRIM(PAYLOAD->CUSTOMSCRIPT->SCRIPT[nSCRIPT]->PARAMETERS->DATA[D.SEQ].INFONAME) = NULL AND cACTION="R")
			)
		AND (
				PAYLOAD->CUSTOMSCRIPT->SCRIPT[nSCRIPT]->PARAMETERS->DATA[D.SEQ].INFODOMAINID = DI.INFO_DOMAIN_ID
				OR
				(PAYLOAD->CUSTOMSCRIPT->SCRIPT[nSCRIPT]->PARAMETERS->DATA[D.SEQ].INFODOMAINID = 0 AND cACTION="R")
			)
	HEAD REPORT
		nCOUNT = 0
 
		SUBROUTINE ADD_DM_INFO(cINFO_DOMAIN, cINFO_NAME, dINFO_DATE, cINFO_CHAR, nINFO_NUMBER, nLONG_TEXT_ID,
						cLONG_TEXT, dUPDT_DT_TM, nUPDT_ID, nINFO_DOMAIN_ID, cACTION_STATUS)
			nCOUNT = nCOUNT + 1
			STAT = ALTERLIST(rCUSTOM->DM_INFO, nCOUNT)
 
			rCUSTOM->DM_INFO[nCOUNT].INFO_DOMAIN = cINFO_DOMAIN
			rCUSTOM->DM_INFO[nCOUNT].INFO_NAME = cINFO_NAME
			rCUSTOM->DM_INFO[nCOUNT].INFO_DATE = dINFO_DATE
			rCUSTOM->DM_INFO[nCOUNT].INFO_CHAR = cINFO_CHAR
			rCUSTOM->DM_INFO[nCOUNT].INFO_NUMBER = nINFO_NUMBER
			rCUSTOM->DM_INFO[nCOUNT].LONG_TEXT_ID = nLONG_TEXT_ID
			rCUSTOM->DM_INFO[nCOUNT].LONG_TEXT = cLONG_TEXT
			rCUSTOM->DM_INFO[nCOUNT].UPDT_DT_TM = dUPDT_DT_TM
			rCUSTOM->DM_INFO[nCOUNT].UPDT_ID = nUPDT_ID
			rCUSTOM->DM_INFO[nCOUNT].INFO_DOMAIN_ID = nINFO_DOMAIN_ID
			rCUSTOM->DM_INFO[nCOUNT].ACTION_STATUS = cACTION_STATUS
		END
	DETAIL
		; Read Action, Data found
		IF (cACTION = "R" AND DI.SEQ > 0)
			CALL ADD_DM_INFO(	DI.INFO_DOMAIN, DI.INFO_NAME, DI.INFO_DATE, DI.INFO_CHAR, DI.INFO_NUMBER, DI.INFO_LONG_ID,
								"", DI.UPDT_DT_TM, DI.UPDT_ID, DI.INFO_DOMAIN_ID, "READ")
		; Insert new record
		ELSEIF (cACTION = "W" AND DI.SEQ = 0)
			CALL ADD_DM_INFO(	PAYLOAD->CUSTOMSCRIPT->SCRIPT[nSCRIPT]->PARAMETERS->DATA[D.SEQ].INFODOMAIN,
								PAYLOAD->CUSTOMSCRIPT->SCRIPT[nSCRIPT]->PARAMETERS->DATA[D.SEQ].INFONAME,
								CNVTDATETIME(PAYLOAD->CUSTOMSCRIPT->SCRIPT[nSCRIPT]->PARAMETERS->DATA[D.SEQ].INFODATE),
								PAYLOAD->CUSTOMSCRIPT->SCRIPT[nSCRIPT]->PARAMETERS->DATA[D.SEQ].INFOCHAR,
								PAYLOAD->CUSTOMSCRIPT->SCRIPT[nSCRIPT]->PARAMETERS->DATA[D.SEQ].INFONUMBER,
								0,
								PAYLOAD->CUSTOMSCRIPT->SCRIPT[nSCRIPT]->PARAMETERS->DATA[D.SEQ].INFOLONGTEXT,
								SYSDATE,
								nPRSNL_ID,
								PAYLOAD->CUSTOMSCRIPT->SCRIPT[nSCRIPT]->PARAMETERS->DATA[D.SEQ].INFODOMAINID,
								"INSERT")
		ELSEIF (cACTION = "W" AND DI.SEQ > 0)
			CALL ADD_DM_INFO(	DI.INFO_DOMAIN,
								DI.INFO_NAME,
								CNVTDATETIME(PAYLOAD->CUSTOMSCRIPT->SCRIPT[nSCRIPT]->PARAMETERS->DATA[D.SEQ].INFODATE),
								PAYLOAD->CUSTOMSCRIPT->SCRIPT[nSCRIPT]->PARAMETERS->DATA[D.SEQ].INFOCHAR,
								PAYLOAD->CUSTOMSCRIPT->SCRIPT[nSCRIPT]->PARAMETERS->DATA[D.SEQ].INFONUMBER,
								DI.INFO_LONG_ID,
								PAYLOAD->CUSTOMSCRIPT->SCRIPT[nSCRIPT]->PARAMETERS->DATA[D.SEQ].INFOLONGTEXT,
								SYSDATE,
								nPRSNL_ID,
								DI.INFO_DOMAIN_ID,
								"UPDATE")
		ELSEIF (cACTION = "D" AND DI.SEQ > 0)
			CALL ADD_DM_INFO(	DI.INFO_DOMAIN, DI.INFO_NAME, DI.INFO_DATE, DI.INFO_CHAR, DI.INFO_NUMBER, DI.INFO_LONG_ID,
								"", DI.UPDT_DT_TM, DI.UPDT_ID, DI.INFO_DOMAIN_ID, "DELETE")
		ENDIF
	WITH OUTERJOIN = D_OJ
 
	IF (SIZE(rCUSTOM->DM_INFO, 5) = 0)
		GO TO END_PROGRAM
	ENDIF
 
	; For new writes, determine the next LONG_TEXT_ID to insert
	SELECT INTO "NL:"
		D.SEQ, LONG_SEQ = SEQ(LONG_DATA_SEQ, NEXTVAL)
	FROM	(DUMMYT				D WITH SEQ=VALUE(SIZE(rCUSTOM->DM_INFO, 5))),
			DUAL				DL
	PLAN D
		WHERE rCUSTOM->DM_INFO[D.SEQ].ACTION_STATUS = "INSERT"
		AND SIZE(TRIM(rCUSTOM->DM_INFO[D.SEQ].LONG_TEXT)) > 0
	JOIN DL
	DETAIL
		rCUSTOM->DM_INFO[D.SEQ].LONG_TEXT_ID = LONG_SEQ
	WITH COUNTER
 
	; Read the existing long text data
	SELECT INTO "NL:"
		D.SEQ, LT.LONG_TEXT
	FROM 	(DUMMYT				D WITH SEQ=VALUE(SIZE(rCUSTOM->DM_INFO, 5))),
			LONG_TEXT			LT
	PLAN D
		WHERE rCUSTOM->DM_INFO[D.SEQ].ACTION_STATUS = "READ"
		AND rCUSTOM->DM_INFO[D.SEQ].LONG_TEXT_ID > 0
	JOIN LT
		WHERE LT.LONG_TEXT_ID = rCUSTOM->DM_INFO[D.SEQ].LONG_TEXT_ID
		AND LT.PARENT_ENTITY_NAME = "DM_INFO"
		AND LT.ACTIVE_IND = 1
	DETAIL
		rCUSTOM->DM_INFO[D.SEQ].LONG_TEXT = LT.LONG_TEXT
	WITH COUNTER
 
	; Insert/Update/Delete the records
	IF (cACTION != "R")
		FOR (nLOOP = 1 TO SIZE(rCUSTOM->DM_INFO, 5))
 
			; Perform Insert
			; --------------
			IF (rCUSTOM->DM_INFO[nLOOP].ACTION_STATUS = "INSERT")
				INSERT INTO DM_INFO DI
				SET DI.INFO_DOMAIN = rCUSTOM->DM_INFO[nLOOP].INFO_DOMAIN,
					DI.INFO_NAME = rCUSTOM->DM_INFO[nLOOP].INFO_NAME,
					DI.INFO_DATE = CNVTDATETIME(rCUSTOM->DM_INFO[nLOOP].INFO_DATE),
					DI.INFO_CHAR = rCUSTOM->DM_INFO[nLOOP].INFO_CHAR,
					DI.INFO_NUMBER = rCUSTOM->DM_INFO[nLOOP].INFO_NUMBER,
					DI.INFO_LONG_ID = rCUSTOM->DM_INFO[nLOOP].LONG_TEXT_ID,
					DI.UPDT_DT_TM = CNVTDATETIME(rCUSTOM->DM_INFO[nLOOP].UPDT_DT_TM),
					DI.UPDT_ID = rCUSTOM->DM_INFO[nLOOP].UPDT_ID,
					DI.INFO_DOMAIN_ID = rCUSTOM->DM_INFO[nLOOP].INFO_DOMAIN_ID
 
				IF (rCUSTOM->DM_INFO[nLOOP].LONG_TEXT_ID > 0)
					INSERT INTO LONG_TEXT LT
					SET LT.LONG_TEXT_ID = rCUSTOM->DM_INFO[nLOOP].LONG_TEXT_ID,
						LT.UPDT_DT_TM = SYSDATE,
						LT.UPDT_ID = rCUSTOM->DM_INFO[nLOOP].UPDT_ID,
						LT.ACTIVE_IND = 1,
						LT.ACTIVE_STATUS_DT_TM = SYSDATE,
						LT.ACTIVE_STATUS_PRSNL_ID = rCUSTOM->DM_INFO[nLOOP].UPDT_ID,
						LT.PARENT_ENTITY_NAME = "DM_INFO",
						LT.LONG_TEXT = rCUSTOM->DM_INFO[nLOOP].LONG_TEXT
				ENDIF
 
			; Perform Update
			; --------------
			ELSEIF (rCUSTOM->DM_INFO[nLOOP].ACTION_STATUS = "UPDATE")
				UPDATE INTO DM_INFO DI
				SET DI.INFO_DATE = CNVTDATETIME(rCUSTOM->DM_INFO[nLOOP].INFO_DATE),
					DI.INFO_CHAR = rCUSTOM->DM_INFO[nLOOP].INFO_CHAR,
					DI.INFO_NUMBER = rCUSTOM->DM_INFO[nLOOP].INFO_NUMBER,
					DI.INFO_LONG_ID = rCUSTOM->DM_INFO[nLOOP].LONG_TEXT_ID,
					DI.UPDT_DT_TM = CNVTDATETIME(rCUSTOM->DM_INFO[nLOOP].UPDT_DT_TM),
					DI.UPDT_ID = rCUSTOM->DM_INFO[nLOOP].UPDT_ID
				WHERE DI.INFO_DOMAIN = rCUSTOM->DM_INFO[nLOOP].INFO_DOMAIN
				AND DI.INFO_NAME = rCUSTOM->DM_INFO[nLOOP].INFO_NAME
				AND DI.INFO_DOMAIN_ID = rCUSTOM->DM_INFO[nLOOP].INFO_DOMAIN_ID
 
				IF (rCUSTOM->DM_INFO[nLOOP].LONG_TEXT_ID > 0)
					UPDATE INTO LONG_TEXT LT
					SET LT.UPDT_DT_TM = SYSDATE,
						LT.UPDT_ID = rCUSTOM->DM_INFO[nLOOP].UPDT_ID,
						LT.LONG_TEXT = rCUSTOM->DM_INFO[nLOOP].LONG_TEXT
					WHERE LT.LONG_TEXT_ID = rCUSTOM->DM_INFO[nLOOP].LONG_TEXT_ID
					AND LT.PARENT_ENTITY_NAME = "DM_INFO"
				ENDIF
 
			; Perform Delete
			; --------------
			ELSEIF (rCUSTOM->DM_INFO[nLOOP].ACTION_STATUS = "DELETE")
				DELETE FROM DM_INFO DI
				WHERE DI.INFO_DOMAIN = rCUSTOM->DM_INFO[nLOOP].INFO_DOMAIN
				AND DI.INFO_NAME = rCUSTOM->DM_INFO[nLOOP].INFO_NAME
				AND DI.INFO_DOMAIN_ID = rCUSTOM->DM_INFO[nLOOP].INFO_DOMAIN_ID
 
				IF (rCUSTOM->DM_INFO[nLOOP].LONG_TEXT_ID > 0)
					UPDATE INTO LONG_TEXT LT
					SET LT.UPDT_DT_TM = SYSDATE,
						LT.UPDT_ID = rCUSTOM->DM_INFO[nLOOP].UPDT_ID,
						LT.ACTIVE_IND = 0
					WHERE LT.LONG_TEXT_ID = rCUSTOM->DM_INFO[nLOOP].LONG_TEXT_ID
					AND LT.PARENT_ENTITY_NAME = "DM_INFO"
				ENDIF
 
 
			ENDIF
		ENDFOR
 
		COMMIT
 
	ENDIF
 
	; Write the output back to the MPage
	CALL ADD_CUSTOM_OUTPUT(CNVTRECTOJSON(rCUSTOM, 4, 1))
 
ENDIF
 
#END_PROGRAM
 
END GO
 
/*************************************************************************
 
        Script Name:    1CO_MPAGE_ENCOUNTER.PRG
 
        Description:    Clinical Office - mPage Edition
        				Encounter Data Retrieval
 
        Date Written:   April 11, 2018
        Written by:     John Simpson
                        Precision Healthcare Solutions
 
 *************************************************************************
		   Copyright (c) 2018 Precision Healthcare Solutions
 
 NO PART OF THIS CODE MAY BE COPIED, MODIFIED OR DISTRIBUTED WITHOUT
 PRIOR WRITTEN CONSENT OF PRECISION HEALTHCARE SOLUTIONS EXECUTIVE
 LEADERSHIP TEAM.
 
 FOR LICENSING TERMS PLEASE VISIT www.clinicaloffice.com/mpage/license
 
 *************************************************************************
                            Special Instructions
 *************************************************************************
 Called from 1CO_MPAGE_ENTRY. Do not attempt to run stand alone.
 
 Possible Payload values:
 
	"patientSource":[
		{"personId": value, "encntrId": value}
	],
	"encounter": {
    	"includeCodeValues": true,
		"aliases": true,
		"encounterInfo": true,
		"prsnlReltn": true,
		"locHist": true
	},
	"typeList": [
		{"codeSet": value, "type": "value", "typeCd": value}
	]
 
 
 
 *************************************************************************
                            Revision Information
 *************************************************************************
 Rev    Date     By             Comments
 ------ -------- -------------- ------------------------------------------
 001    02/06/18 J. Simpson     Initial Development
 *************************************************************************/
 
DROP PROGRAM 1CO_MPAGE_ENCOUNTER:GROUP1 GO
CREATE PROGRAM 1CO_MPAGE_ENCOUNTER:GROUP1
 
; Check to see if running from mPage entry script
IF (VALIDATE(PAYLOAD->ENCOUNTER) = 0 OR SIZE(PATIENT_SOURCE->VISITS, 5) = 0)
	GO TO END_PROGRAM
ENDIF
 
DECLARE cPARSER = vc
 
SET _Memory_Reply_String = BUILD(_Memory_Reply_String, ^,"encounters":[^)
 
; Loop through all the patients
FOR (nLOOP = 1 TO SIZE(PATIENT_SOURCE->VISITS, 5))
	IF (nLOOP > 1)
		SET _Memory_Reply_String = BUILD(_Memory_Reply_String, ^,^)
	ENDIF
 
	; Set the person_id to return as the first item
	SET _Memory_Reply_String = BUILD(_Memory_Reply_String,
					^{"encntrId":^, CNVTINT(PATIENT_SOURCE->VISITS[nLOOP].ENCNTR_ID),
					^,"personId":^, CNVTINT(PATIENT_SOURCE->VISITS[nLOOP].PERSON_ID))
 
 
	; Collect the core encounter
	SELECT INTO "NL:"
		ENCNTR_CLASS_CD				= E.ENCNTR_CLASS_CD,
		ENCNTR_TYPE_CD				= E.ENCNTR_TYPE_CD,
		ENCNTR_TYPE_CLASS_CD		= E.ENCNTR_TYPE_CLASS_CD,
		ENCNTR_STATUS_CD			= E.ENCNTR_STATUS_CD,
		PRE_REG_DT_TM				= E.PRE_REG_DT_TM,
		PRE_REG_PRSNL_ID			= E.PRE_REG_PRSNL_ID,
		REG_DT_TM					= E.REG_DT_TM,
		REG_PRSNL_ID				= E.REG_PRSNL_ID,
		EST_ARRIVE_DT_TM			= E.EST_ARRIVE_DT_TM,
		EST_DEPART_DT_TM			= E.EST_DEPART_DT_TM,
		ARRIVE_DT_TM				= E.ARRIVE_DT_TM,
		DEPART_DT_TM				= E.DEPART_DT_TM,
		ADMIT_TYPE_CD				= E.ADMIT_TYPE_CD,
		ADMIT_SRC_CD				= E.ADMIT_SRC_CD,
		ADMIT_MODE_CD				= E.ADMIT_MODE_CD,
		DISCH_DISPOSITION_CD		= E.DISCH_DISPOSITION_CD,
		DISCH_TO_LOCTN_CD			= E.DISCH_TO_LOCTN_CD,
		READMIT_CD					= E.READMIT_CD,
		ACCOMMODATION_CD			= E.ACCOMMODATION_CD,
		ACCOMMODATION_REQUEST_CD	= E.ACCOMMODATION_REQUEST_CD,
		AMBULATORY_COND_CD			= E.AMBULATORY_COND_CD,
		COURTESY_CD					= E.COURTESY_CD,
		ISOLATION_CD				= E.ISOLATION_CD,
		MED_SERVICE_CD				= E.MED_SERVICE_CD,
		CONFID_LEVEL_CD				= E.CONFID_LEVEL_CD,
		VIP_CD						= E.VIP_CD,
		LOCATION_CD					= E.LOCATION_CD,
		LOC_FACILITY_CD				= E.LOC_FACILITY_CD,
		LOC_BUILDING_CD				= E.LOC_BUILDING_CD,
		LOC_NURSE_UNIT_CD			= E.LOC_NURSE_UNIT_CD,
		LOC_ROOM_CD					= E.LOC_ROOM_CD,
		LOC_BED_CD					= E.LOC_BED_CD,
		DISCH_DT_TM					= E.DISCH_DT_TM,
		ORGANIZATION_ID				= E.ORGANIZATION_ID,
		REASON_FOR_VISIT			= E.REASON_FOR_VISIT,
		ENCNTR_FINANCIAL_ID			= E.ENCNTR_FINANCIAL_ID,
		FINANCIAL_CLASS_CD			= E.FINANCIAL_CLASS_CD,
		TRAUMA_CD					= E.TRAUMA_CD,
		TRIAGE_CD					= E.TRIAGE_CD,
		TRIAGE_DT_TM				= E.TRIAGE_DT_TM,
		VISITOR_STATUS_CD			= E.VISITOR_STATUS_CD,
		INPATIENT_ADMIT_DT_TM		= E.INPATIENT_ADMIT_DT_TM
	FROM 	ENCOUNTER			E
	PLAN E
		WHERE E.ENCNTR_ID = PATIENT_SOURCE->VISITS[nLOOP].ENCNTR_ID
	DETAIL
		_Memory_Reply_String = BUILD(_Memory_Reply_String, ^,^,
			^"encntrClass":"^, UAR_GET_CODE_DISPLAY(ENCNTR_CLASS_CD), ^",^,
			^"encntrType":"^, UAR_GET_CODE_DISPLAY(ENCNTR_TYPE_CD), ^",^,
			^"encntrTypeClass":"^, UAR_GET_CODE_DISPLAY(ENCNTR_TYPE_CLASS_CD), ^",^,
			^"encntrStatus":"^, UAR_GET_CODE_DISPLAY(ENCNTR_STATUS_CD), ^",^,
			^"preRegDtTm":"^, FORMAT(PRE_REG_DT_TM, cDATE_FORMAT), ^",^,
			^"preRegPrsnlId":^, CNVTINT(PRE_REG_PRSNL_ID), ^,^,
			^"regDtTm":"^, FORMAT(REG_DT_TM, cDATE_FORMAT), ^",^,
			^"regPrsnlId":^, CNVTINT(REG_PRSNL_ID), ^,^,
			^"estArriveDtTm":"^, FORMAT(EST_ARRIVE_DT_TM, cDATE_FORMAT), ^",^,
			^"estDepartDtTm":"^, FORMAT(EST_DEPART_DT_TM, cDATE_FORMAT), ^",^,
			^"arriveDtTm":"^, FORMAT(ARRIVE_DT_TM, cDATE_FORMAT), ^",^,
			^"departDtTm":"^, FORMAT(DEPART_DT_TM, cDATE_FORMAT), ^",^,
			^"admitType":"^, UAR_GET_CODE_DISPLAY(ADMIT_TYPE_CD), ^",^,
			^"admitSrc":"^, JEsc(UAR_GET_CODE_DISPLAY(ADMIT_SRC_CD)), ^",^,
			^"admitMode":"^, UAR_GET_CODE_DISPLAY(ADMIT_MODE_CD), ^",^,
			^"dischDisposition":"^, UAR_GET_CODE_DISPLAY(DISCH_DISPOSITION_CD), ^",^,
			^"dischToLoctn":"^, UAR_GET_CODE_DISPLAY(DISCH_TO_LOCTN_CD), ^",^,
			^"readmit":"^, UAR_GET_CODE_DISPLAY(READMIT_CD), ^",^,
			^"accommodation":"^, UAR_GET_CODE_DISPLAY(ACCOMMODATION_CD), ^",^,
			^"accommodationRequest":"^, UAR_GET_CODE_DISPLAY(ACCOMMODATION_REQUEST_CD), ^",^,
			^"ambulatoryCond":"^, UAR_GET_CODE_DISPLAY(AMBULATORY_COND_CD), ^",^,
			^"courtesy":"^, UAR_GET_CODE_DISPLAY(COURTESY_CD), ^",^,
			^"isolation":"^, UAR_GET_CODE_DISPLAY(ISOLATION_CD), ^",^,
			^"medService":"^, UAR_GET_CODE_DISPLAY(MED_SERVICE_CD), ^",^,
			^"confidLevel":"^, UAR_GET_CODE_DISPLAY(CONFID_LEVEL_CD), ^",^,
			^"vip":"^, UAR_GET_CODE_DISPLAY(VIP_CD), ^",^,
			^"location":"^, UAR_GET_CODE_DISPLAY(LOCATION_CD), ^",^,
			^"locFacility":"^, UAR_GET_CODE_DISPLAY(LOC_FACILITY_CD), ^",^,
			^"locBuilding":"^, UAR_GET_CODE_DISPLAY(LOC_BUILDING_CD), ^",^,
			^"locNurseUnit":"^, UAR_GET_CODE_DISPLAY(LOC_NURSE_UNIT_CD), ^",^,
			^"locRoom":"^, UAR_GET_CODE_DISPLAY(LOC_ROOM_CD), ^",^,
			^"locBed":"^, UAR_GET_CODE_DISPLAY(LOC_BED_CD), ^",^,
			^"dischDtTm":"^, FORMAT(DISCH_DT_TM, cDATE_FORMAT), ^",^,
			^"organizationId":^, CNVTINT(ORGANIZATION_ID), ^,^,
			^"reasonForVisit":"^, JEsc(REASON_FOR_VISIT), ^",^,
			^"encntrFinancialId":^, CNVTINT(ENCNTR_FINANCIAL_ID), ^,^,
			^"financialClass":"^, UAR_GET_CODE_DISPLAY(FINANCIAL_CLASS_CD), ^",^,
			^"trauma":"^, UAR_GET_CODE_DISPLAY(TRAUMA_CD), ^",^,
			^"triage":"^, UAR_GET_CODE_DISPLAY(TRIAGE_CD), ^",^,
			^"triageDtTm":"^, FORMAT(TRIAGE_DT_TM, cDATE_FORMAT), ^",^,
			^"visitorStatus":"^, UAR_GET_CODE_DISPLAY(VISITOR_STATUS_CD), ^",^,
			^"inpatientAdmitDtTm":"^, FORMAT(INPATIENT_ADMIT_DT_TM, cDATE_FORMAT), ^"^
			)
		IF (VALIDATE(PAYLOAD->ENCOUNTER->INCLUDECODEVALUES,0) = 1)
			_Memory_Reply_String = BUILD(_Memory_Reply_String, ^,^,
				^"encntrClassCd":^, CNVTINT(ENCNTR_CLASS_CD), ^,^,
				^"encntrTypeCd":^, CNVTINT(ENCNTR_TYPE_CD), ^,^,
				^"encntrTypeClassCd":^, CNVTINT(ENCNTR_TYPE_CLASS_CD), ^,^,
				^"encntrStatusCd":^, CNVTINT(ENCNTR_STATUS_CD), ^,^,
				^"admitTypeCd":^, CNVTINT(ADMIT_TYPE_CD), ^,^,
				^"admitSrcCd":^, CNVTINT(ADMIT_SRC_CD), ^,^,
				^"admitModeCd":^, CNVTINT(ADMIT_MODE_CD), ^,^,
				^"dischDispositionCd":^, CNVTINT(DISCH_DISPOSITION_CD), ^,^,
				^"dischToLoctnCd":^, CNVTINT(DISCH_TO_LOCTN_CD), ^,^,
				^"readmitCd":^, CNVTINT(READMIT_CD), ^,^,
				^"accommodationCd":^, CNVTINT(ACCOMMODATION_CD), ^,^,
				^"accommodationRequestCd":^, CNVTINT(ACCOMMODATION_REQUEST_CD), ^,^,
				^"ambulatoryCondCd":^, CNVTINT(AMBULATORY_COND_CD), ^,^,
				^"courtesyCd":^, CNVTINT(COURTESY_CD), ^,^,
				^"isolationCd":^, CNVTINT(ISOLATION_CD), ^,^,
				^"medServiceCd":^, CNVTINT(MED_SERVICE_CD), ^,^,
				^"confidLevelCd":^, CNVTINT(CONFID_LEVEL_CD), ^,^,
				^"vipCd":^, CNVTINT(VIP_CD), ^,^,
				^"locationCd":^, CNVTINT(LOCATION_CD), ^,^,
				^"locFacilityCd":^, CNVTINT(LOC_FACILITY_CD), ^,^,
				^"locBuildingCd":^, CNVTINT(LOC_BUILDING_CD), ^,^,
				^"locNurseUnitCd":^, CNVTINT(LOC_NURSE_UNIT_CD), ^,^,
				^"locRoomCd":^, CNVTINT(LOC_ROOM_CD), ^,^,
				^"locBedCd":^, CNVTINT(LOC_BED_CD), ^,^,
				^"financialClassCd":^, CNVTINT(FINANCIAL_CLASS_CD), ^,^,
				^"traumaCd":^, CNVTINT(TRAUMA_CD), ^,^,
				^"triageCd":^, CNVTINT(TRIAGE_CD), ^,^,
				^"visitorStatusCd":^, CNVTINT(VISITOR_STATUS_CD)
			)
		ENDIF
	WITH OUTERJOIN=D, NOCOUNTER
 
	; Collect the Encounter Level Aliases
	; --------------------------------
	IF (VALIDATE(PAYLOAD->ENCOUNTER->ALIASES, 0) = 1)
 
		; Set the Parser
		CALL TYPE_PARSER("EA.ENCNTR_ALIAS_TYPE_CD", 319)
 
		; Collect the alias
		SELECT INTO "NL:"
			ALIAS_POOL_CD				= EA.ALIAS_POOL_CD,
			ENCNTR_ALIAS_TYPE_CD		= EA.ENCNTR_ALIAS_TYPE_CD,
			ALIAS						= EA.ALIAS,
			ENCNTR_ALIAS_SUB_TYPE_CD	= EA.ENCNTR_ALIAS_SUB_TYPE_CD
		FROM	ENCNTR_ALIAS		EA
		PLAN EA
			WHERE EA.ENCNTR_ID = PATIENT_SOURCE->VISITS[nLOOP].ENCNTR_ID
			AND PARSER(cPARSER)
			AND EA.ACTIVE_IND = 1
			AND EA.END_EFFECTIVE_DT_TM > SYSDATE
		HEAD REPORT
			_Memory_Reply_String = BUILD(_Memory_Reply_String, ^,"aliases":[^)
			nFIRST = 1
		DETAIL
			IF (nFIRST = 1)
				nFIRST = 0
			ELSE
				_Memory_Reply_String = BUILD(_Memory_Reply_String, ^,^)
			ENDIF
			_Memory_Reply_String = BUILD(_Memory_Reply_String, ^{^,
				^"aliasPool":"^, UAR_GET_CODE_DISPLAY(ALIAS_POOL_CD), ^",^,
				^"aliasType":"^, UAR_GET_CODE_DISPLAY(ENCNTR_ALIAS_TYPE_CD), ^",^,
				^"aliasTypeMeaning":"^, UAR_GET_CODE_MEANING(ENCNTR_ALIAS_TYPE_CD), ^",^,
				^"alias":"^, ALIAS, ^",^,
				^"aliasFormatted":"^, CNVTALIAS(ALIAS, ALIAS_POOL_CD), ^",^,
				^"aliasSubType":"^, UAR_GET_CODE_DISPLAY(ENCNTR_ALIAS_SUB_TYPE_CD), ^"^
			)
 
			IF (VALIDATE(PAYLOAD->ENCOUNTER->INCLUDECODEVALUES,0) = 1)
				_Memory_Reply_String = BUILD(_Memory_Reply_String, ^,^,
					^"aliasPoolCd":^, CNVTINT(ALIAS_POOL_CD), ^,^,
					^"encntrAliasTypeCd":^, CNVTINT(ENCNTR_ALIAS_TYPE_CD), ^,^,
					^"encntrAliasSubTypeCd":^, CNVTINT(ENCNTR_ALIAS_SUB_TYPE_CD)
				)
			ENDIF
 
			_Memory_Reply_String = BUILD(_Memory_Reply_String, ^}^)
		FOOT REPORT
			_Memory_Reply_String = BUILD(_Memory_Reply_String, ^]^)
		WITH NOCOUNTER
	ENDIF
 
	; Collect the Prsnl relationships at the encounter level
	; ---------------------------------------------------
	IF (VALIDATE(PAYLOAD->ENCOUNTER->PRSNLRELTN, 0) = 1)
		; Set the Parser
		CALL TYPE_PARSER("EPR.ENCNTR_PRSNL_R_CD", 333)
 
		SELECT INTO "NL:"
			ENCNTR_PRSNL_R_CD			= EPR.ENCNTR_PRSNL_R_CD,
			PERSON_ID					= EPR.PRSNL_PERSON_ID,
			PRIORITY_SEQ				= EPR.PRIORITY_SEQ,
			INTERNAL_SEQ				= EPR.INTERNAL_SEQ,
			PRSNL_TYPE_CD				= P.PRSNL_TYPE_CD,
			NAME_FULL_FORMATTED			= P.NAME_FULL_FORMATTED,
			PHYSICIAN_IND				= P.PHYSICIAN_IND,
			POSITION_CD					= P.POSITION_CD,
			NAME_LAST					= P.NAME_LAST,
			NAME_FIRST					= P.NAME_FIRST,
			USERNAME					= P.USERNAME
		FROM 	ENCNTR_PRSNL_RELTN		EPR,
				PRSNL					P
		PLAN EPR
			WHERE EPR.ENCNTR_ID = PATIENT_SOURCE->VISITS[nLOOP].ENCNTR_ID
			AND PARSER(cPARSER)
			AND EPR.ACTIVE_IND = 1
			AND EPR.END_EFFECTIVE_DT_TM > SYSDATE
		JOIN P
			WHERE P.PERSON_ID = EPR.PRSNL_PERSON_ID
		HEAD REPORT
			_Memory_Reply_String = BUILD(_Memory_Reply_String, ^,"prsnlReltn":[^)
			nFIRST = 1
		DETAIL
			IF (nFIRST = 1)
				nFIRST = 0
			ELSE
				_Memory_Reply_String = BUILD(_Memory_Reply_String, ^,^)
			ENDIF
			_Memory_Reply_String = BUILD(_Memory_Reply_String, ^{^,
				^"reltnType":"^, UAR_GET_CODE_DISPLAY(ENCNTR_PRSNL_R_CD), ^",^,
				^"reltnTypeMeaning":"^, UAR_GET_CODE_MEANING(ENCNTR_PRSNL_R_CD), ^",^,
				^"personId":^, CNVTINT(PERSON_ID), ^,^,
				^"prioritySeq":^, PRIORITY_SEQ, ^,^,
				^"internalSeq":^, INTERNAL_SEQ, ^,^,
				^"prsnlType":"^, UAR_GET_CODE_DISPLAY(PRSNL_TYPE_CD), ^",^,
				^"nameFullFormatted":"^, NAME_FULL_FORMATTED, ^",^,
				^"physicianInd":^, PHYSICIAN_IND, ^,^,
				^"position":"^, UAR_GET_CODE_DISPLAY(POSITION_CD), ^",^,
				^"nameLast":"^, NAME_LAST, ^",^,
				^"nameFirst":"^, NAME_FIRST, ^",^,
				^"userName":"^, USERNAME, ^"^
			)
 
			IF (VALIDATE(PAYLOAD->ENCOUNTER->INCLUDECODEVALUES,0) = 1)
				_Memory_Reply_String = BUILD(_Memory_Reply_String, ^,^,
					^"encntrPrsnlRCd":^, CNVTINT(ENCNTR_PRSNL_R_CD), ^,^,
					^"prsnlTypeCd":^, CNVTINT(PRSNL_TYPE_CD), ^,^,
					^"positionCd":^, CNVTINT(POSITION_CD)
				)
			ENDIF
			_Memory_Reply_String = BUILD(_Memory_Reply_String, ^}^)
		FOOT REPORT
			_Memory_Reply_String = BUILD(_Memory_Reply_String, ^]^)
		WITH NOCOUNTER
	ENDIF
 
	; Collect the ENCOUNTER Info records
	; -------------------------------
	IF (VALIDATE(PAYLOAD->ENCOUNTER->ENCOUNTERINFO, 0) = 1)
		; Set the Parser
		CALL TYPE_PARSER("EI.INFO_SUB_TYPE_CD", 356)
 
		SELECT INTO "NL:"
			INFO_TYPE_CD		= EI.INFO_TYPE_CD,
			INFO_SUB_TYPE_CD	= EI.INFO_SUB_TYPE_CD,
			VALUE_NUMERIC		= EI.VALUE_NUMERIC,
			VALUE_DT_TM			= EI.VALUE_DT_TM,
			CHARTABLE_IND		= EI.CHARTABLE_IND,
			PRIORITY_SEQ		= EI.PRIORITY_SEQ,
			INTERNAL_SEQ		= EI.INTERNAL_SEQ,
			VALUE_CD			= EI.VALUE_CD,
			VALUE_NUMERIC_IND	= EI.VALUE_NUMERIC_IND,
			LONG_TEXT			= LT.LONG_TEXT
		FROM 	ENCNTR_INFO			EI,
				LONG_TEXT			LT,
				DUMMYT				D
		PLAN EI
			WHERE EI.ENCNTR_ID = PATIENT_SOURCE->VISITS[nLOOP].ENCNTR_ID
			AND PARSER(cPARSER)
			AND EI.ACTIVE_IND = 1
			AND EI.END_EFFECTIVE_DT_TM > SYSDATE
		JOIN D
		JOIN LT
			WHERE LT.LONG_TEXT_ID = EI.LONG_TEXT_ID
			AND LT.ACTIVE_IND = 1
		HEAD REPORT
			_Memory_Reply_String = BUILD(_Memory_Reply_String, ^,"encntrInfo":[^)
			nFIRST = 1
		DETAIL
			IF (nFIRST = 1)
				nFIRST = 0
			ELSE
				_Memory_Reply_String = BUILD(_Memory_Reply_String, ^,^)
			ENDIF
			_Memory_Reply_String = BUILD(_Memory_Reply_String, ^{^,
				^"infoType":"^, UAR_GET_CODE_DISPLAY(INFO_TYPE_CD), ^",^,
				^"infoTypeMeaning":"^, UAR_GET_CODE_MEANING(INFO_TYPE_CD), ^",^,
				^"infoSubType":"^, UAR_GET_CODE_DISPLAY(INFO_SUB_TYPE_CD), ^",^,
				^"infoSubTypeMeaning":"^, UAR_GET_CODE_MEANING(INFO_SUB_TYPE_CD), ^",^,
				^"valueNumericInd":^, VALUE_NUMERIC_IND, ^,^,
				^"valueNumeric":^, VALUE_NUMERIC, ^,^,
				^"valueDtTm":"^, FORMAT(VALUE_DT_TM, cDATE_FORMAT), ^",^,
				^"chartableInd":^, CHARTABLE_IND, ^,^,
				^"prioritySeq":^, PRIORITY_SEQ, ^,^,
				^"internalSeq":^, INTERNAL_SEQ, ^,^,
				^"value":"^, UAR_GET_CODE_DISPLAY(VALUE_CD), ^",^,
				^"longText":"^, JEsc(REPLACE(TRIM(LONG_TEXT),^"^,^'^)), ^"^
			)
 
			IF (VALIDATE(PAYLOAD->ENCOUNTER->INCLUDECODEVALUES,0) = 1)
				_Memory_Reply_String = BUILD(_Memory_Reply_String, ^,^,
					^"infoTypeCd":^, CNVTINT(INFO_TYPE_CD), ^,^,
					^"infoSubTypeCd":^, CNVTINT(INFO_SUB_TYPE_CD), ^,^,
					^"valueCd":^, CNVTINT(VALUE_CD)
				)
			ENDIF
			_Memory_Reply_String = BUILD(_Memory_Reply_String, ^}^)
		FOOT REPORT
			_Memory_Reply_String = BUILD(_Memory_Reply_String, ^]^)
		WITH OUTERJOIN=D, NOCOUNTER
	ENDIF
 
	; Collect the ENCOUNTER Info records
	; ----------------------------------
	IF (VALIDATE(PAYLOAD->ENCOUNTER->LOCHIST, 0) = 1)
 
		SELECT INTO "NL:"
			BEG_EFFECTIVE_DT_TM			= ELH.BEG_EFFECTIVE_DT_TM,
			END_EFFECTIVE_DT_TM			= ELH.END_EFFECTIVE_DT_TM,
			ARRIVE_DT_TM				= ELH.ARRIVE_DT_TM,
			ARRIVE_PRSNL_ID				= ELH.ARRIVE_PRSNL_ID,
			DEPART_DT_TM				= ELH.DEPART_DT_TM,
			DEPART_PRSNL_ID				= ELH.DEPART_PRSNL_ID,
			LOCATION_CD					= ELH.LOCATION_CD,
			LOC_FACILITY_CD				= ELH.LOC_FACILITY_CD,
			LOC_BUILDING_CD				= ELH.LOC_BUILDING_CD,
			LOC_NURSE_UNIT_CD			= ELH.LOC_NURSE_UNIT_CD,
			LOC_ROOM_CD					= ELH.LOC_ROOM_CD,
			LOC_BED_CD					= ELH.LOC_BED_CD,
			ENCNTR_TYPE_CD				= ELH.ENCNTR_TYPE_CD,
			MED_SERVICE_CD				= ELH.MED_SERVICE_CD,
			TRANSACTION_DT_TM			= ELH.TRANSACTION_DT_TM,
			ACTIVITY_DT_TM				= ELH.ACTIVITY_DT_TM,
			ACCOMMODATION_CD			= ELH.ACCOMMODATION_CD,
			ACCOMMODATION_REQUEST_CD	= ELH.ACCOMMODATION_REQUEST_CD,
			ADMIT_TYPE_CD				= ELH.ADMIT_TYPE_CD,
			ISOLATION_CD				= ELH.ISOLATION_CD,
			ORGANIZATION_ID				= ELH.ORGANIZATION_ID,
			ENCNTR_TYPE_CLASS_CD		= ELH.ENCNTR_TYPE_CLASS_CD
		FROM 	ENCNTR_LOC_HIST		ELH
		PLAN ELH
			WHERE ELH.ENCNTR_ID = PATIENT_SOURCE->VISITS[nLOOP].ENCNTR_ID
			AND ELH.ACTIVE_IND = 1
		HEAD REPORT
			_Memory_Reply_String = BUILD(_Memory_Reply_String, ^,"locHist":[^)
			nFIRST = 1
		DETAIL
			IF (nFIRST = 1)
				nFIRST = 0
			ELSE
				_Memory_Reply_String = BUILD(_Memory_Reply_String, ^,^)
			ENDIF
			_Memory_Reply_String = BUILD(_Memory_Reply_String, ^{^,
				^"begEffectiveDtTm":"^, FORMAT(BEG_EFFECTIVE_DT_TM, cDATE_FORMAT), ^",^,
				^"endEffectiveDtTm":"^, FORMAT(END_EFFECTIVE_DT_TM, cDATE_FORMAT), ^",^,
				^"arriveDtTm":"^, FORMAT(ARRIVE_DT_TM, cDATE_FORMAT), ^",^,
				^"arrivePrsnlId":^, CNVTINT(ARRIVE_PRSNL_ID), ^,^,
				^"departDtTm":"^, FORMAT(DEPART_DT_TM, cDATE_FORMAT), ^",^,
				^"departPrsnlId":^, CNVTINT(DEPART_PRSNL_ID), ^,^,
				^"location":"^, UAR_GET_CODE_DISPLAY(LOCATION_CD), ^",^,
				^"locFacility":"^, UAR_GET_CODE_DISPLAY(LOC_FACILITY_CD), ^",^,
				^"locBuilding":"^, UAR_GET_CODE_DISPLAY(LOC_BUILDING_CD), ^",^,
				^"locNurseUnit":"^, UAR_GET_CODE_DISPLAY(LOC_NURSE_UNIT_CD), ^",^,
				^"locRoom":"^, UAR_GET_CODE_DISPLAY(LOC_ROOM_CD), ^",^,
				^"locBed":"^, UAR_GET_CODE_DISPLAY(LOC_BED_CD), ^",^,
				^"encntrType":"^, UAR_GET_CODE_DISPLAY(ENCNTR_TYPE_CD), ^",^,
				^"medService":"^, UAR_GET_CODE_DISPLAY(MED_SERVICE_CD), ^",^,
				^"transactionDtTm":"^, FORMAT(TRANSACTION_DT_TM, cDATE_FORMAT), ^",^,
				^"activityDtTm":"^, FORMAT(ACTIVITY_DT_TM, cDATE_FORMAT), ^",^,
				^"accommodation":"^, UAR_GET_CODE_DISPLAY(ACCOMMODATION_CD), ^",^,
				^"accommodationRequest":"^, UAR_GET_CODE_DISPLAY(ACCOMMODATION_REQUEST_CD), ^",^,
				^"admitType":"^, UAR_GET_CODE_DISPLAY(ADMIT_TYPE_CD), ^",^,
				^"isolation":"^, UAR_GET_CODE_DISPLAY(ISOLATION_CD), ^",^,
				^"organizationId":^, CNVTINT(ORGANIZATION_ID), ^,^,
				^"encntrTypeClass":"^, UAR_GET_CODE_DISPLAY(ENCNTR_TYPE_CLASS_CD), ^"^
			)
 
			IF (VALIDATE(PAYLOAD->ENCOUNTER->INCLUDECODEVALUES,0) = 1)
				_Memory_Reply_String = BUILD(_Memory_Reply_String, ^,^,
					^"locationCd":^, CNVTINT(LOCATION_CD), ^,^,
					^"locFacilityCd":^, CNVTINT(LOC_FACILITY_CD), ^,^,
					^"locBuildingCd":^, CNVTINT(LOC_BUILDING_CD), ^,^,
					^"locNurseUnitCd":^, CNVTINT(LOC_NURSE_UNIT_CD), ^,^,
					^"locRoomCd":^, CNVTINT(LOC_ROOM_CD), ^,^,
					^"locBedCd":^, CNVTINT(LOC_BED_CD), ^,^,
					^"encntrTypeCd":^, CNVTINT(ENCNTR_TYPE_CD), ^,^,
					^"medServiceCd":^, CNVTINT(MED_SERVICE_CD), ^,^,
					^"accommodationCd":^, CNVTINT(ACCOMMODATION_CD), ^,^,
					^"accommodationRequestCd":^, CNVTINT(ACCOMMODATION_REQUEST_CD), ^,^,
					^"admitTypeCd":^, CNVTINT(ADMIT_TYPE_CD), ^,^,
					^"isolationCd":^, CNVTINT(ISOLATION_CD), ^,^,
					^"encntrTypeClassCd":^, CNVTINT(ENCNTR_TYPE_CLASS_CD)
				)
			ENDIF
			_Memory_Reply_String = BUILD(_Memory_Reply_String, ^}^)
		FOOT REPORT
			_Memory_Reply_String = BUILD(_Memory_Reply_String, ^]^)
		WITH NOCOUNTER
	ENDIF
 
 
	; End tag for encounter
	SET _Memory_Reply_String = BUILD(_Memory_Reply_String, ^}^)
 
ENDFOR
 
SET _Memory_Reply_String = BUILD(_Memory_Reply_String, ^]^)
 
#END_PROGRAM
 
 
END GO
 
/*************************************************************************
 
        Script Name:    1CO_MPAGE_ENC_LIST.PRG
 
        Description:    Clinical Office - mPage Edition
        				Custom CCL Pre/Post Blank Template
 
        Date Written:   May 15, 2018
        Written by:     John Simpson
                        Precision Healthcare Solutions
 
 *************************************************************************
		   Copyright (c) 2018 Precision Healthcare Solutions
 
 NO PART OF THIS CODE MAY BE COPIED, MODIFIED OR DISTRIBUTED WITHOUT
 PRIOR WRITTEN CONSENT OF PRECISION HEALTHCARE SOLUTIONS EXECUTIVE
 LEADERSHIP TEAM.
 
 FOR LICENSING TERMS PLEASE VISIT www.clinicaloffice.com/mpage/license
 
 *************************************************************************
                            Special Instructions
 *************************************************************************
 Called from 1CO_MPAGE_ENTRY. Do not attempt to run stand alone. If you
 wish to test the development of your custom script from the CCL back-end,
 please run with 1CO_MPAGE_TEST.
 
 Possible Payload values:
 
	"customScript": {
		"script": [
			"name": "your custom script name:GROUP1",
			"id": "identifier for your output, omit if you won't be returning data",
			"run": "pre or post",
			"parameters": {
				"your custom parameters for your job"
			}
		],
		"clearPatientSource": true
	},
	"typeList": [
		{"codeSet": value, "type": "value", "typeCd": value}
	]
 
 
 
 *************************************************************************
                            Revision Information
 *************************************************************************
 Rev    Date     By             Comments
 ------ -------- -------------- ------------------------------------------
 001    05/07/18 J. Simpson     Initial Development
 002	08/15/18 J. Simpson		Added ability to filter by org name
 003	06/25/19 J. Simpson		Changed org name filter to support multiple orgs
 004	01/18/20 J. Simpson		Added ability to filter by encntr_type_class_cd
 *************************************************************************/
DROP PROGRAM 1CO_MPAGE_ENC_LIST:GROUP1 GO
CREATE PROGRAM 1CO_MPAGE_ENC_LIST:GROUP1
 
SET cDATE_FIELD = PAYLOAD->CUSTOMSCRIPT->SCRIPT[nSCRIPT]->PARAMETERS.DATEFIELD
SET dFROM_DATE = PAYLOAD->CUSTOMSCRIPT->SCRIPT[nSCRIPT]->PARAMETERS.FROMDATE
SET dTO_DATE = PAYLOAD->CUSTOMSCRIPT->SCRIPT[nSCRIPT]->PARAMETERS.TODATE
 
; Check to see if we have cleared the patient source and if not, do we have data in the patient source
; to run our custom CCL against.
IF (VALIDATE(PAYLOAD->CUSTOMSCRIPT->CLEARPATIENTSOURCE, 0) = 0)
	IF (SIZE(PATIENT_SOURCE->PATIENTS, 5) = 0)
		GO TO END_PROGRAM
	ENDIF
ENDIF
 
; Define the custom record structure you wish to have sent back in the JSON to the mPage. The name
; of the record structure can be anything you want.
FREE RECORD rCUSTOM
RECORD rCUSTOM (
	1 VISITS[*]
		2 PERSON_ID					= f8
		2 ENCNTR_ID					= f8
)
 
; Set the Parser for the various filters
DECLARE cPARSER  = vc
DECLARE cPARSER2 = vc
DECLARE cPARSER3 = vc
DECLARE cPARSER4 = vc
DECLARE cPARSER5 = vc
DECLARE cPARSER6 = vc
DECLARE cPARSER7 = vc
DECLARE nNum = i4
 
CALL TYPE_PARSER("E.DISCH_DISPOSITION_CD", 19)
SET cPARSER2 = cPARSER
CALL TYPE_PARSER("E.ENCNTR_TYPE_CD", 71)
SET cPARSER3 = cPARSER
CALL TYPE_PARSER("E.MED_SERVICE_CD", 34)
SET cPARSER4 = cPARSER
CALL TYPE_PARSER("E.LOC_FACILITY_CD", 220)
SET cPARSER5 = cPARSER
CALL TYPE_PARSER("E.LOC_NURSE_UNIT_CD", 220)
SET cPARSER7 = cPARSER
CALL TYPE_PARSER("E.ENCNTR_TYPE_CLASS_CD", 69)
 
; Parse the Organization Name
SET cPARSER6 = "1=1"
 
IF (VALIDATE(PAYLOAD->CUSTOMSCRIPT->SCRIPT[nSCRIPT]->PARAMETERS.ORGANIZATIONS) > 0)
	SET cPARSER6 = "1=0"	; Set false in case org name does not exist
 
	SELECT INTO "NL:"
		ORGANIZATION_ID			= O.ORGANIZATION_ID
	FROM	ORGANIZATION		O
	PLAN O
		WHERE EXPAND(nNum, 1, SIZE(PAYLOAD->CUSTOMSCRIPT->SCRIPT[nSCRIPT]->PARAMETERS->ORGANIZATIONS, 5), O.ORG_NAME_KEY,
						PAYLOAD->CUSTOMSCRIPT->SCRIPT[nSCRIPT]->PARAMETERS->ORGANIZATIONS[nNum].ORGNAME)
	HEAD REPORT
		cPARSER6 = ""
	DETAIL
		IF (TRIM(cPARSER6) = "")
			cPARSER6 = CONCAT(cPARSER6, BUILD(ORGANIZATION_ID))
		ELSE
			cPARSER6 = CONCAT(cPARSER6, "," , BUILD(ORGANIZATION_ID))
		ENDIF
	FOOT REPORT
		cPARSER6 = CONCAT("E.ORGANIZATION_ID IN (", TRIM(cPARSER6, 3), ")")
	WITH COUNTER
ENDIF
 
/*
IF (VALIDATE(PAYLOAD->CUSTOMSCRIPT->SCRIPT[nSCRIPT]->PARAMETERS.ORGNAME) > 0)
	SET cPARSER6 = "1=0"	; Set false in case org name does not exist
 
	SELECT INTO "NL:"
		ORGANIZATION_ID			= O.ORGANIZATION_ID
	FROM	ORGANIZATION		O
	PLAN O
		WHERE O.ORG_NAME_KEY = PAYLOAD->CUSTOMSCRIPT->SCRIPT[nSCRIPT]->PARAMETERS.ORGNAME
	DETAIL
		cPARSER6 = CONCAT("E.ORGANIZATION_ID = ", BUILD(ORGANIZATION_ID))
	WITH COUNTER
ENDIF
*/
 
; If the patient list was cleared, we will look for encounters for anybody
IF (SIZE(PATIENT_SOURCE->PATIENTS, 5) = 0)
call echo(cparser6)
 
	SELECT INTO "NL:"
		PERSON_ID			= E.PERSON_ID,
		ENCNTR_ID			= E.ENCNTR_ID
	FROM	ENCOUNTER				E
	PLAN E
		WHERE PARSER(CONCAT("E.", cDATE_FIELD, " BETWEEN CNVTDATETIME(", BUILD(dFROM_DATE),
					") AND CNVTDATETIME(", BUILD(dTO_DATE), ")"))
		AND PARSER(cPARSER)
		AND PARSER(cPARSER2)
		AND PARSER(cPARSER3)
		AND PARSER(cPARSER4)
		AND PARSER(cPARSER5)
		AND PARSER(cPARSER6)
		AND E.ACTIVE_IND = 1
	ORDER PERSON_ID, ENCNTR_ID
	HEAD REPORT
		nPERSON = 0
		nENCOUNTER = 0
	HEAD PERSON_ID
		nPERSON = nPERSON + 1
 
		STAT = ALTERLIST(PATIENT_SOURCE->PATIENTS, nPERSON)
		PATIENT_SOURCE->PATIENTS[nPERSON].PERSON_ID = PERSON_ID
	HEAD ENCNTR_ID
		nENCOUNTER = nENCOUNTER + 1
 
		STAT = ALTERLIST(PATIENT_SOURCE->VISITS, nENCOUNTER)
		PATIENT_SOURCE->VISITS[nENCOUNTER].PERSON_ID = PERSON_ID
		PATIENT_SOURCE->VISITS[nENCOUNTER].ENCNTR_ID = ENCNTR_ID
	WITH NOCOUNTER
 
; If the patient list was not cleared, get the encounters for the listed patients
ELSE
	; First make a copy of the patient source
	SET STAT = COPYREC(PATIENT_SOURCE, TEMP_PAT_SOURCE, 1)
 
	; Clear the patient source as we need to populate it with our results
	SET STAT = INITREC(PATIENT_SOURCE)
 
	SELECT INTO "NL:"
		PERSON_ID			= E.PERSON_ID,
		ENCNTR_ID			= E.ENCNTR_ID
	FROM	(DUMMYT					D WITH SEQ=VALUE(SIZE(TEMP_PAT_SOURCE->PATIENTS, 5))),
			ENCOUNTER				E
	PLAN D
	JOIN E
		WHERE E.PERSON_ID = TEMP_PAT_SOURCE->PATIENTS[D.SEQ].PERSON_ID
		AND PARSER(CONCAT("E.", cDATE_FIELD, " BETWEEN CNVTDATETIME(", BUILD(dFROM_DATE),
					") AND CNVTDATETIME(", BUILD(dTO_DATE), ")"))
		AND PARSER(cPARSER)
		AND PARSER(cPARSER2)
		AND PARSER(cPARSER3)
		AND PARSER(cPARSER4)
		AND PARSER(cPARSER5)
		AND PARSER(cPARSER6)
		AND E.ACTIVE_IND = 1
	ORDER PERSON_ID, ENCNTR_ID
	HEAD REPORT
		nPERSON = 0
		nENCOUNTER = 0
	HEAD PERSON_ID
		nPERSON = nPERSON + 1
 
		STAT = ALTERLIST(PATIENT_SOURCE->PATIENTS, nPERSON)
		PATIENT_SOURCE->PATIENTS[nPERSON].PERSON_ID = PERSON_ID
	HEAD ENCNTR_ID
		nENCOUNTER = nENCOUNTER + 1
 
		STAT = ALTERLIST(PATIENT_SOURCE->VISITS, nENCOUNTER)
		PATIENT_SOURCE->VISITS[nENCOUNTER].PERSON_ID = PERSON_ID
		PATIENT_SOURCE->VISITS[nENCOUNTER].ENCNTR_ID = ENCNTR_ID
	WITH NOCOUNTER
ENDIF
 
IF (SIZE(PATIENT_SOURCE->VISITS, 5) > 0)
 
	SET STAT = MOVEREC(PATIENT_SOURCE->VISITS, rCUSTOM)
    CALL ADD_CUSTOM_OUTPUT(CNVTRECTOJSON(rCUSTOM, 4, 1))
 
ENDIF
 
 
 
#END_PROGRAM
 
END GO
 
/*************************************************************************
 
        Script Name:    1CO_MPAGE_PROBLEM.PRG
 
        Description:    Clinical Office - mPage Edition
        				Problem Data Retrieval
 
        Date Written:   May 3, 2018
        Written by:     John Simpson
                        Precision Healthcare Solutions
 
 *************************************************************************
		   Copyright (c) 2018 Precision Healthcare Solutions
 
 NO PART OF THIS CODE MAY BE COPIED, MODIFIED OR DISTRIBUTED WITHOUT
 PRIOR WRITTEN CONSENT OF PRECISION HEALTHCARE SOLUTIONS EXECUTIVE
 LEADERSHIP TEAM.
 
 FOR LICENSING TERMS PLEASE VISIT www.clinicaloffice.com/mpage/license
 
 *************************************************************************
                            Special Instructions
 *************************************************************************
 Called from 1CO_MPAGE_ENTRY. Do not attempt to run stand alone.
 
 Possible Payload values:
 
	"patientSource":[
		{"personId": value, "encntrId": value}
	],
	"problem": {
    	"includeCodeValues": true,
    	"comments": true
	},
	"typeList": [
		{"codeSet": value, "type": "value", "typeCd": value}
	]
 
 
 
 *************************************************************************
                            Revision Information
 *************************************************************************
 Rev    Date     By             Comments
 ------ -------- -------------- ------------------------------------------
 001    02/06/18 J. Simpson     Initial Development
 *************************************************************************/
 
DROP PROGRAM 1CO_MPAGE_PROBLEM:GROUP1 GO
CREATE PROGRAM 1CO_MPAGE_PROBLEM:GROUP1
 
; Check to see if running from mPage entry script
IF (VALIDATE(PAYLOAD->PROBLEM) = 0 OR SIZE(PATIENT_SOURCE->PATIENTS, 5) = 0)
	GO TO END_PROGRAM
ENDIF
 
RECORD rPROBLEM (
	1 DATA[*]
		2 PERSON_ID						= f8
		2 PROBLEM_INSTANCE_ID			= f8
		2 PROBLEM_ID					= f8
		2 NOMENCLATURE_ID				= f8
		2 PROB_SOURCE_STRING			= vc
		2 PROB_SOURCE_IDENTIFIER		= vc
		2 PROB_SOURCE_VOCAB_CD			= f8
		2 PROBLEM_FTDESC				= vc
		2 ESTIMATED_RESOLUTION_DT_TM	= dq8
		2 ACTUAL_RESOLUTION_DT_TM		= dq8
		2 CLASSIFICATION_CD				= f8
		2 PERSISTENCE_CD				= f8
		2 CONFIRMATION_STATUS_CD		= f8
		2 LIFE_CYCLE_STATUS_CD			= f8
		2 LIFE_CYCLE_DT_TM				= dq8
		2 ONSET_DT_CD					= f8
		2 ONSET_DT_TM					= dq8
		2 RANKING_CD					= f8
		2 CERTAINTY_CD					= f8
		2 PROBABILITY					= f8
		2 PERSON_AWARE_CD				= f8
		2 PROGNOSIS_CD					= f8
		2 PERSON_AWARE_PROGNOSIS_CD		= f8
		2 FAMILY_AWARE_CD				= f8
		2 SENSITIVITY					= i4
		2 COURSE_CD						= f8
		2 CANCEL_REASON_CD				= f8
		2 ONSET_DT_FLAG					= i4
		2 STATUS_UPDT_PRECISION_CD		= f8
		2 STATUS_UPDT_FLAG				= i4
		2 STATUS_UPDT_DT_TM				= dq8
		2 QUALIFIER_CD					= f8
		2 ANNOTATED_DISPLAY				= vc
		2 SEVERITY_CLASS_CD				= f8
		2 SEVERITY_CD					= f8
		2 SEVERITY_FTDESC				= vc
		2 LIFE_CYCLE_DT_CD				= f8
		2 LIFE_CYCLE_DT_FLAG			= i4
		2 PROBLEM_TYPE_FLAG				= i4
		2 LATERALITY_CD					= f8
		2 ORIGINATING_NOMENCLATURE_ID	= f8
		2 ORIG_PROB_SOURCE_STRING		= vc
		2 ORIG_PROB_SOURCE_IDENTIFIER	= vc
		2 ORIG_PROB_SOURCE_VOCAB_CD		= f8
		2 COMMENT[*]
			3 COMMENT_DT_TM				= dq8
			3 COMMENT_PRSNL_ID			= f8
			3 PROBLEM_COMMENT			= vc
)
 
DECLARE cPARSER = vc
DECLARE cPARSER2= vc
 
; Set the Parser
CALL TYPE_PARSER("N.SOURCE_VOCABULARY_CD", 400)
SET cPARSER2 = cPARSER
CALL TYPE_PARSER("P.LIFE_CYCLE_STATUS_CD", 12030)
 
; Collect the problems
SELECT INTO "NL:"
	DSEQ				= D.SEQ,
	SORT_KEY			= CNVTUPPER(P.ANNOTATED_DISPLAY)
FROM	(DUMMYT				D WITH SEQ=VALUE(SIZE(PATIENT_SOURCE->PATIENTS, 5))),
		PROBLEM				P,
		NOMENCLATURE		N,
		NOMENCLATURE		N2
PLAN D
JOIN P
	WHERE P.PERSON_ID = PATIENT_SOURCE->PATIENTS[D.SEQ].PERSON_ID
	AND PARSER(cPARSER)
	AND P.ACTIVE_IND = 1
	AND P.END_EFFECTIVE_DT_TM > SYSDATE
JOIN N
	WHERE N.NOMENCLATURE_ID = P.NOMENCLATURE_ID
	AND PARSER(cPARSER2)
JOIN N2
	WHERE N2.NOMENCLATURE_ID = P.ORIGINATING_NOMENCLATURE_ID
ORDER BY DSEQ, SORT_KEY
HEAD REPORT
	nCOUNT = 0
DETAIL
	nCOUNT = nCOUNT + 1
	STAT = ALTERLIST(rPROBLEM->DATA, nCOUNT)
 
	rPROBLEM->DATA[nCOUNT].PERSON_ID = P.PERSON_ID
	rPROBLEM->DATA[nCOUNT].PROBLEM_INSTANCE_ID = P.PROBLEM_INSTANCE_ID
	rPROBLEM->DATA[nCOUNT].PROBLEM_ID = P.PROBLEM_ID
	rPROBLEM->DATA[nCOUNT].NOMENCLATURE_ID = P.NOMENCLATURE_ID
	rPROBLEM->DATA[nCOUNT].PROB_SOURCE_STRING = N.SOURCE_STRING
	rPROBLEM->DATA[nCOUNT].PROB_SOURCE_IDENTIFIER = N.SOURCE_IDENTIFIER
	rPROBLEM->DATA[nCOUNT].PROB_SOURCE_VOCAB_CD = N.SOURCE_VOCABULARY_CD
	rPROBLEM->DATA[nCOUNT].PROBLEM_FTDESC = P.PROBLEM_FTDESC
	rPROBLEM->DATA[nCOUNT].ESTIMATED_RESOLUTION_DT_TM = P.ESTIMATED_RESOLUTION_DT_TM
	rPROBLEM->DATA[nCOUNT].ACTUAL_RESOLUTION_DT_TM = P.ACTUAL_RESOLUTION_DT_TM
	rPROBLEM->DATA[nCOUNT].CLASSIFICATION_CD = P.CLASSIFICATION_CD
	rPROBLEM->DATA[nCOUNT].PERSISTENCE_CD = P.PERSISTENCE_CD
	rPROBLEM->DATA[nCOUNT].CONFIRMATION_STATUS_CD = P.CONFIRMATION_STATUS_CD
	rPROBLEM->DATA[nCOUNT].LIFE_CYCLE_STATUS_CD = P.LIFE_CYCLE_STATUS_CD
	rPROBLEM->DATA[nCOUNT].LIFE_CYCLE_DT_TM = P.LIFE_CYCLE_DT_TM
	rPROBLEM->DATA[nCOUNT].ONSET_DT_CD = P.ONSET_DT_CD
	rPROBLEM->DATA[nCOUNT].ONSET_DT_TM = P.ONSET_DT_TM
	rPROBLEM->DATA[nCOUNT].RANKING_CD = P.RANKING_CD
	rPROBLEM->DATA[nCOUNT].CERTAINTY_CD = P.CERTAINTY_CD
	rPROBLEM->DATA[nCOUNT].PROBABILITY = P.PROBABILITY
	rPROBLEM->DATA[nCOUNT].PERSON_AWARE_CD = P.PERSON_AWARE_CD
	rPROBLEM->DATA[nCOUNT].PROGNOSIS_CD = P.PROGNOSIS_CD
	rPROBLEM->DATA[nCOUNT].PERSON_AWARE_PROGNOSIS_CD = P.PERSON_AWARE_PROGNOSIS_CD
	rPROBLEM->DATA[nCOUNT].FAMILY_AWARE_CD = P.FAMILY_AWARE_CD
	rPROBLEM->DATA[nCOUNT].SENSITIVITY = P.SENSITIVITY
	rPROBLEM->DATA[nCOUNT].COURSE_CD = P.COURSE_CD
	rPROBLEM->DATA[nCOUNT].CANCEL_REASON_CD = P.CANCEL_REASON_CD
	rPROBLEM->DATA[nCOUNT].ONSET_DT_FLAG = P.ONSET_DT_FLAG
	rPROBLEM->DATA[nCOUNT].STATUS_UPDT_PRECISION_CD = P.STATUS_UPDT_PRECISION_CD
	rPROBLEM->DATA[nCOUNT].STATUS_UPDT_FLAG = P.STATUS_UPDT_FLAG
	rPROBLEM->DATA[nCOUNT].STATUS_UPDT_DT_TM = P.STATUS_UPDT_DT_TM
	rPROBLEM->DATA[nCOUNT].QUALIFIER_CD = P.QUALIFIER_CD
	rPROBLEM->DATA[nCOUNT].ANNOTATED_DISPLAY = P.ANNOTATED_DISPLAY
	rPROBLEM->DATA[nCOUNT].SEVERITY_CLASS_CD = P.SEVERITY_CLASS_CD
	rPROBLEM->DATA[nCOUNT].SEVERITY_CD = P.SEVERITY_CD
	rPROBLEM->DATA[nCOUNT].SEVERITY_FTDESC = P.SEVERITY_FTDESC
	rPROBLEM->DATA[nCOUNT].LIFE_CYCLE_DT_CD = P.LIFE_CYCLE_DT_CD
	rPROBLEM->DATA[nCOUNT].LIFE_CYCLE_DT_FLAG = P.LIFE_CYCLE_DT_FLAG
	rPROBLEM->DATA[nCOUNT].PROBLEM_TYPE_FLAG = P.PROBLEM_TYPE_FLAG
	rPROBLEM->DATA[nCOUNT].LATERALITY_CD = P.LATERALITY_CD
	rPROBLEM->DATA[nCOUNT].ORIGINATING_NOMENCLATURE_ID = P.ORIGINATING_NOMENCLATURE_ID
	rPROBLEM->DATA[nCOUNT].ORIG_PROB_SOURCE_STRING = N2.SOURCE_STRING
	rPROBLEM->DATA[nCOUNT].ORIG_PROB_SOURCE_IDENTIFIER = N2.SOURCE_IDENTIFIER
	rPROBLEM->DATA[nCOUNT].ORIG_PROB_SOURCE_VOCAB_CD = N2.SOURCE_VOCABULARY_CD
WITH NOCOUNTER
 
; Collect the comments
IF (VALIDATE(PAYLOAD->PROBLEM->COMMENTS, 0) = 1)
	SELECT INTO "NL:"
		DSEQ				= D.SEQ,
		SORT_DATE			= FORMAT(PC.COMMENT_DT_TM, "YYYYMMDDHHMMSS;;Q")
	FROM	(DUMMYT				D WITH SEQ=VALUE(SIZE(rPROBLEM->DATA, 5))),
			PROBLEM_COMMENT		PC
	PLAN D
	JOIN PC
		WHERE PC.PROBLEM_ID = rPROBLEM->DATA[D.SEQ].PROBLEM_ID
		AND PC.ACTIVE_IND = 1
		AND PC.END_EFFECTIVE_DT_TM > SYSDATE
	ORDER DSEQ, SORT_DATE DESC
	HEAD DSEQ
		nCOUNT = 0
	HEAD SORT_DATE
		X = 0
	DETAIL
		nCOUNT = nCOUNT + 1
		STAT = ALTERLIST(rPROBLEM->DATA[D.SEQ].COMMENT, nCOUNT)
 
		rPROBLEM->DATA[D.SEQ].COMMENT[nCOUNT].COMMENT_DT_TM = PC.COMMENT_DT_TM
		rPROBLEM->DATA[D.SEQ].COMMENT[nCOUNT].COMMENT_PRSNL_ID = PC.COMMENT_PRSNL_ID
		rPROBLEM->DATA[D.SEQ].COMMENT[nCOUNT].PROBLEM_COMMENT = REPLACE(REPLACE(PC.PROBLEM_COMMENT, CHAR(13), ""), CHAR(10), "\\n")
 
	WITH NOCOUNTER
ENDIF
 
; Skip the rest if no allergies loaded
IF (SIZE(rPROBLEM->DATA, 5) = 0)
	GO TO END_PROGRAM
ENDIF
 
SET _Memory_Reply_String = BUILD(_Memory_Reply_String, ^,"problem":[^)
 
; Loop through all the patients
FOR (nLOOP = 1 TO SIZE(rPROBLEM->DATA, 5))
	IF (nLOOP > 1)
		SET _Memory_Reply_String = BUILD(_Memory_Reply_String, ^,^)
	ENDIF
 
	; Set the person_id to return as the first item
	SET _Memory_Reply_String = BUILD(_Memory_Reply_String,
					^{"personId":^, CNVTINT(rPROBLEM->DATA[nLOOP].PERSON_ID), ^,^,
					^"problemInstanceId":^, CNVTINT(rPROBLEM->DATA[nLOOP].PROBLEM_INSTANCE_ID), ^,^,
					^"problemId":^, CNVTINT(rPROBLEM->DATA[nLOOP].PROBLEM_ID), ^,^,
					^"nomenclatureId":^, CNVTINT(rPROBLEM->DATA[nLOOP].NOMENCLATURE_ID), ^,^,
					^"probSourceString":"^, rPROBLEM->DATA[nLOOP].PROB_SOURCE_STRING, ^",^,
					^"probSourceIdentifier":"^, rPROBLEM->DATA[nLOOP].PROB_SOURCE_IDENTIFIER, ^",^,
					^"probSourceVocab":"^, UAR_GET_CODE_DISPLAY(rPROBLEM->DATA[nLOOP].PROB_SOURCE_VOCAB_CD), ^",^,
					^"problemFtDesc":"^, rPROBLEM->DATA[nLOOP].PROBLEM_FTDESC, ^",^,
					^"estimatedResolutionDtTm":"^, FORMAT(rPROBLEM->DATA[nLOOP].ESTIMATED_RESOLUTION_DT_TM, cDATE_FORMAT), ^",^,
					^"actualResolutionDtTm":"^, FORMAT(rPROBLEM->DATA[nLOOP].ACTUAL_RESOLUTION_DT_TM, cDATE_FORMAT), ^",^,
					^"classification":"^, UAR_GET_CODE_DISPLAY(rPROBLEM->DATA[nLOOP].CLASSIFICATION_CD), ^",^,
					^"persistence":"^, UAR_GET_CODE_DISPLAY(rPROBLEM->DATA[nLOOP].PERSISTENCE_CD), ^",^,
					^"confirmationStatus":"^, UAR_GET_CODE_DISPLAY(rPROBLEM->DATA[nLOOP].CONFIRMATION_STATUS_CD), ^",^,
					^"lifeCycleStatus":"^, UAR_GET_CODE_DISPLAY(rPROBLEM->DATA[nLOOP].LIFE_CYCLE_STATUS_CD), ^",^,
					^"lifeCycleStatusMeaning":"^, UAR_GET_CODE_MEANING(rPROBLEM->DATA[nLOOP].LIFE_CYCLE_STATUS_CD), ^",^,
					^"lifeCycleDtTm":"^, FORMAT(rPROBLEM->DATA[nLOOP].LIFE_CYCLE_DT_TM, cDATE_FORMAT), ^",^,
					^"onsetDt":"^, UAR_GET_CODE_DISPLAY(rPROBLEM->DATA[nLOOP].ONSET_DT_CD), ^",^,
					^"onsetDtTm":"^, FORMAT(rPROBLEM->DATA[nLOOP].ONSET_DT_TM, cDATE_FORMAT), ^",^,
					^"ranking":"^, UAR_GET_CODE_DISPLAY(rPROBLEM->DATA[nLOOP].RANKING_CD), ^",^,
					^"certainty":"^, UAR_GET_CODE_DISPLAY(rPROBLEM->DATA[nLOOP].CERTAINTY_CD), ^",^,
					^"probability":^, CNVTINT(rPROBLEM->DATA[nLOOP].PROBABILITY), ^,^,
					^"personAware":"^, UAR_GET_CODE_DISPLAY(rPROBLEM->DATA[nLOOP].PERSON_AWARE_CD), ^",^,
					^"prognosis":"^, UAR_GET_CODE_DISPLAY(rPROBLEM->DATA[nLOOP].PROGNOSIS_CD), ^",^,
					^"personAwarePrognosis":"^, UAR_GET_CODE_DISPLAY(rPROBLEM->DATA[nLOOP].PERSON_AWARE_PROGNOSIS_CD), ^",^,
					^"familyAware":"^, UAR_GET_CODE_DISPLAY(rPROBLEM->DATA[nLOOP].FAMILY_AWARE_CD), ^",^,
					^"sensitivity":^, CNVTINT(rPROBLEM->DATA[nLOOP].SENSITIVITY), ^,^,
					^"course":"^, UAR_GET_CODE_DISPLAY(rPROBLEM->DATA[nLOOP].COURSE_CD), ^",^,
					^"cancelReason":"^, UAR_GET_CODE_DISPLAY(rPROBLEM->DATA[nLOOP].CANCEL_REASON_CD), ^",^,
					^"onsetDtFlag":^, CNVTINT(rPROBLEM->DATA[nLOOP].ONSET_DT_FLAG), ^,^,
					^"statusUpdtPrecision":"^, UAR_GET_CODE_DISPLAY(rPROBLEM->DATA[nLOOP].STATUS_UPDT_PRECISION_CD), ^",^,
					^"statusUpdtFlag":^, CNVTINT(rPROBLEM->DATA[nLOOP].STATUS_UPDT_FLAG), ^,^,
					^"statusUpdtDtTm":"^, FORMAT(rPROBLEM->DATA[nLOOP].STATUS_UPDT_DT_TM, cDATE_FORMAT), ^",^,
					^"qualifier":"^, UAR_GET_CODE_DISPLAY(rPROBLEM->DATA[nLOOP].QUALIFIER_CD), ^",^,
					^"annotatedDisplay":"^, rPROBLEM->DATA[nLOOP].ANNOTATED_DISPLAY, ^",^,
					^"severityClass":"^, UAR_GET_CODE_DISPLAY(rPROBLEM->DATA[nLOOP].SEVERITY_CLASS_CD), ^",^,
					^"severity":"^, UAR_GET_CODE_DISPLAY(rPROBLEM->DATA[nLOOP].SEVERITY_CD), ^",^,
					^"severityFtDesc":"^, rPROBLEM->DATA[nLOOP].SEVERITY_FTDESC, ^",^,
					^"lifeCycleDt":"^, UAR_GET_CODE_DISPLAY(rPROBLEM->DATA[nLOOP].LIFE_CYCLE_DT_CD), ^",^,
					^"lifeCycleDtFlag":^, CNVTINT(rPROBLEM->DATA[nLOOP].LIFE_CYCLE_DT_FLAG), ^,^,
					^"problemTypeFlag":^, CNVTINT(rPROBLEM->DATA[nLOOP].PROBLEM_TYPE_FLAG), ^,^,
					^"laterality":"^, UAR_GET_CODE_DISPLAY(rPROBLEM->DATA[nLOOP].LATERALITY_CD), ^",^,
					^"originatingNomenclature":^, CNVTINT(rPROBLEM->DATA[nLOOP].ORIGINATING_NOMENCLATURE_ID), ^,^,
					^"origProbSourceString":"^, rPROBLEM->DATA[nLOOP].ORIG_PROB_SOURCE_STRING, ^",^,
					^"origProbSourceIdentifier":"^, rPROBLEM->DATA[nLOOP].ORIG_PROB_SOURCE_IDENTIFIER, ^",^,
					^"origProbSourceVocab":"^, UAR_GET_CODE_DISPLAY(rPROBLEM->DATA[nLOOP].ORIG_PROB_SOURCE_VOCAB_CD), ^"^
					)
 
	IF (VALIDATE(PAYLOAD->PROBLEM->INCLUDECODEVALUES,0) = 1)
		SET _Memory_Reply_String = BUILD(_Memory_Reply_String, ^,^,
					^"probSourceVocabCd":^, CNVTINT(rPROBLEM->DATA[nLOOP].PROB_SOURCE_VOCAB_CD), ^,^,
					^"classificationCd":^, CNVTINT(rPROBLEM->DATA[nLOOP].CLASSIFICATION_CD), ^,^,
					^"persistenceCd":^, CNVTINT(rPROBLEM->DATA[nLOOP].PERSISTENCE_CD), ^,^,
					^"confirmationStatusCd":^, CNVTINT(rPROBLEM->DATA[nLOOP].CONFIRMATION_STATUS_CD), ^,^,
					^"lifeCycleStatusCd":^, CNVTINT(rPROBLEM->DATA[nLOOP].LIFE_CYCLE_STATUS_CD), ^,^,
					^"onsetDtCd":^, CNVTINT(rPROBLEM->DATA[nLOOP].ONSET_DT_CD), ^,^,
					^"rankingCd":^, CNVTINT(rPROBLEM->DATA[nLOOP].RANKING_CD), ^,^,
					^"certaintyCd":^, CNVTINT(rPROBLEM->DATA[nLOOP].CERTAINTY_CD), ^,^,
					^"personAwareCd":^, CNVTINT(rPROBLEM->DATA[nLOOP].PERSON_AWARE_CD), ^,^,
					^"prognosisCd":^, CNVTINT(rPROBLEM->DATA[nLOOP].PROGNOSIS_CD), ^,^,
					^"personAwarePrognosisCd":^, CNVTINT(rPROBLEM->DATA[nLOOP].PERSON_AWARE_PROGNOSIS_CD), ^,^,
					^"familyAwareCd":^, CNVTINT(rPROBLEM->DATA[nLOOP].FAMILY_AWARE_CD), ^,^,
					^"courseCd":^, CNVTINT(rPROBLEM->DATA[nLOOP].COURSE_CD), ^,^,
					^"cancelReasonCd":^, CNVTINT(rPROBLEM->DATA[nLOOP].CANCEL_REASON_CD), ^,^,
					^"statusUpdtPrecisionCd":^, CNVTINT(rPROBLEM->DATA[nLOOP].STATUS_UPDT_PRECISION_CD), ^,^,
					^"qualifierCd":^, CNVTINT(rPROBLEM->DATA[nLOOP].QUALIFIER_CD), ^,^,
					^"severityClassCd":^, CNVTINT(rPROBLEM->DATA[nLOOP].SEVERITY_CLASS_CD), ^,^,
					^"severityCd":^, CNVTINT(rPROBLEM->DATA[nLOOP].SEVERITY_CD), ^,^,
					^"lifeCycleDtCd":^, CNVTINT(rPROBLEM->DATA[nLOOP].LIFE_CYCLE_DT_CD), ^,^,
					^"lateralityCd":^, CNVTINT(rPROBLEM->DATA[nLOOP].LATERALITY_CD), ^,^,
					^"origProbSourceVocabCd":^, CNVTINT(rPROBLEM->DATA[nLOOP].ORIG_PROB_SOURCE_VOCAB_CD)
					)
	ENDIF
 
	IF (SIZE(rPROBLEM->DATA[nLOOP].COMMENT, 5) > 0)
		SET _Memory_Reply_String = BUILD(_Memory_Reply_String, ^,"comments":[^)
		FOR (nLOOP2 = 1 TO SIZE(rPROBLEM->DATA[nLOOP].COMMENT, 5))
			IF (nLOOP2 > 1)
				SET _Memory_Reply_String = BUILD(_Memory_Reply_String, ^,^)
			ENDIF
			SET _Memory_Reply_String = BUILD(_Memory_Reply_String, ^{^,
						^"commentDtTm":"^, FORMAT(rPROBLEM->DATA[nLOOP].COMMENT[nLOOP2].COMMENT_DT_TM, cDATE_FORMAT), ^",^,
						^"commentPrsnlId":^, CNVTINT(rPROBLEM->DATA[nLOOP].COMMENT[nLOOP2].COMMENT_PRSNL_ID) , ^,^,
						^"comment":"^, rPROBLEM->DATA[nLOOP].COMMENT[nLOOP2].PROBLEM_COMMENT , ^"^,
				^}^)
		ENDFOR
		SET _Memory_Reply_String = BUILD(_Memory_Reply_String, ^]^)
	ENDIF
 
	; End tag
	SET _Memory_Reply_String = BUILD(_Memory_Reply_String, ^}^)
ENDFOR
 
SET _Memory_Reply_String = BUILD(_Memory_Reply_String, ^]^)
 
#END_PROGRAM
 
END GO
/*************************************************************************
 
        Script Name:    1co_mpage_redirect.prg
 
        Description:    Clinical Office - mPage Edition
        				Perform a redirect to WebSphere
 
        Date Written:   March 17, 2021
        Written by:     John Simpson
                        Precision Healthcare Solutions
 
 *************************************************************************
		   Copyright (c) 2018 Precision Healthcare Solutions
 
 NO PART OF THIS CODE MAY BE COPIED, MODIFIED OR DISTRIBUTED WITHOUT
 PRIOR WRITTEN CONSENT OF PRECISION HEALTHCARE SOLUTIONS EXECUTIVE
 LEADERSHIP TEAM.
 
 FOR LICENSING TERMS PLEASE VISIT www.clinicaloffice.com/mpage/license
 
 *************************************************************************
                            Special Instructions
 *************************************************************************
 Used for back-end testing of Clinical Office mPage scripts. You can
 test your own payload JSON by modifying the payload code below.
 *************************************************************************
                            Revision Information
 *************************************************************************
 Rev    Date     By             Comments
 ------ -------- -------------- ------------------------------------------
 001    02/03/18 J. Simpson     Initial Development
 002    05/19/21 J. Simpson     Added support for external links on components
 003    04/27/22 J. Simpson     Switched to JavaScript location instead of meta refresh
 004    05/18/23 J. Simpson     Added support for new component lookup
 *************************************************************************/
 
DROP PROGRAM 1co_mpage_redirect:group1 GO
CREATE PROGRAM 1co_mpage_redirect:group1
 
prompt
	"Output to File/Printer/MINE" = "MINE"   ;* Enter or select the printer or file name to send this report to.
	, "Path" = ""
 
with outdev, path
  
; Variable declarations
declare _Memory_Reply_String = vc
declare cPath = vc with noconstant($path)
declare cPiece = vc
 
if (findstring("/index.html", cPath) = 0)
    set cPath = concat(trim(cPath), "/index.html#/")
endif
 
free record response
record response (
    1 url               = vc
    1 component         = vc
)
 
; Check for new MS Edge Component
if (cnvtupper($outdev) = "EDGE-COMPONENT")

    select into "nl:"
    from    dm_info         d
    plan d
        where d.info_domain = "Clinical Office Component"
        and d.info_name = $path
    detail
        cPath = d.info_char
        if (substring(1,4,d.info_char) != "http")
            response->component = d.info_char
        else    ; Need to parse the component name
            nPiece = 1
            while (cPiece != "x")
                cPiece = (piece(d.info_char, "/", nPiece, "x"))
                if (cPiece != "x")
                    response->component = cPiece
                endif
                nPiece = nPiece + 1
            endwhile
            
            call echo(response->component)
        endif
    with counter     
endif

; Will skip the dm_info lookup if http: or https: path sent and a component
if (substring(1,4,cnvtlower(cPath)) = "http")
    set response->url = cPath
 
    if (cnvtupper($outdev) in ("COMPONENT", "EDGE-COMPONENT"))
        go to skip_lookup
    endif
endif
 
select into "nl:"
    full_path = if(trim(response->url) != "")
                    response->url
                else
                    build(d.info_char,"/custom_mpage_content/", cPath)
                endif
from dm_info d
plan d
    where d.info_domain = "INS"
    and d.info_name = "CONTENT_SERVICE_URL"
head report
    if (cnvtupper($outdev) in ("COMPONENT","EDGE-COMPONENT"))
        response->url = trim(full_path,3)
    else
        _Memory_Reply_String = concat(
            ^<!DOCTYPE html>^,
            ^<html><head>^,
            ^<script>window.location.href="^, trim(full_path,3), ^"</script>^,
            ^</head><body><p>Preparing Report Output</p></body></html>^) 
    endif
with maxrow=1, maxcol=500, noformfeed, format=variable, counter
 
#skip_lookup
 
if (cnvtupper($outdev) in ("COMPONENT", "EDGE-COMPONENT"))
    set _Memory_Reply_String = cnvtrectojson(response, 4, 1)
endif

call echo(_Memory_Reply_String)
 
#end_program
 
end go
/*************************************************************************
 
        Script Name:    1co_mp_note_types.prg
 
        Description:    Clinical Office - mPage Edition
        				Clinical Document/Note Types list in mpage-select format
 
        Date Written:   October 14, 2023
        Written by:     John Simpson
                        Precision Healthcare Solutions
 
 *************************************************************************
		   Copyright (c) 2023 Precision Healthcare Solutions
 
 NO PART OF THIS CODE MAY BE COPIED, MODIFIED OR DISTRIBUTED WITHOUT
 PRIOR WRITTEN CONSENT OF PRECISION HEALTHCARE SOLUTIONS EXECUTIVE
 LEADERSHIP TEAM.
 
 FOR LICENSING TERMS PLEASE VISIT www.clinicaloffice.com/mpage/license
 
 *************************************************************************
                            Special Instructions
 *************************************************************************
 Called from 1CO3_MPAGE_ENTRY. Do not attempt to run stand alone.
 
 Possible Payload values:
 
	"patientSource":[
		{"personId": value, "encntrId": value}
	],
	"encounter": {
    	"includeCodeValues": true,
		"aliases": true,
		"encounterInfo": true,
		"prsnlReltn": true,
		"locHist": true
	},
	"typeList": [
		{"codeSet": value, "type": "value", "typeCd": value}
	]
 
 
 
 *************************************************************************
                            Revision Information
 *************************************************************************
 Rev    Date     By             Comments
 ------ -------- -------------- ------------------------------------------
 001    14/10/23 J. Simpson     Initial Development
 *************************************************************************/

drop program 1co_mp_note_types:dba go
create program 1co_mp_note_types:dba
 
; Check to see if we have cleared the patient source and if not, do we have data in the patient source
; to run our custom CCL against.
if (validate(payload->customscript->clearpatientsource, 0) = 0)
	if (size(patient_source->patients, 5) = 0)
		go to end_program
	endif
endif
 
; Clear and define rCustom structure
free record rCustom
record rCustom (
    1 status
        2 error_ind             = i4
        2 message               = vc
        2 count                 = i4
    1 data[*]
        2 key                   = f8
        2 value                 = vc      
)

; Define and populate the parameters structure
free record rParam
record rParam (
    1 search_ind                = i4
    1 search_limit              = i4
    1 physician_ind             = i4
    1 code_set                  = i4
    1 value_type                = vc
    1 search_value              = vc
    1 default[*]                = f8
)

set rParam->search_ind = payload->customscript->script[nscript]->parameters->search
set rParam->search_limit = payload->customscript->script[nscript]->parameters->searchlimit
set rParam->physician_ind = payload->customscript->script[nscript]->parameters->physicianind
set rParam->code_set= payload->customscript->script[nscript]->parameters->codeset
set rParam->value_type = cnvtupper(payload->customscript->script[nscript]->parameters->valuetype)
set rParam->search_value = cnvtupper(payload->customscript->script[nscript]->parameters->searchvalue)

if (size(payload->customscript->script[nScript]->parameters->default, 5) > 0)
    set stat = alterlist(rParam->default, size(payload->customscript->script[nScript]->parameters->default, 5))
    for (nLoop = 1 to size(rParam->default, 5))   
        set rParam->default[nLoop] = cnvtreal(payload->customscript->script[nScript]->parameters->default[nLoop])
    endfor        
endif
 
; Declare variables and subroutines
declare nNum = i4
declare nDefault = i4

; ------------------------------------------------------------------------------------------------
;								BEGIN YOUR CUSTOM CODE HERE
; ------------------------------------------------------------------------------------------------
 
; Collect code values
declare cv48_Active = f8 with noconstant(uar_get_code_by("MEANING", 48, "ACTIVE"))
declare cv93_ClinicalDoc = f8 with noconstant(uar_get_code_by("DISPLAYKEY", 93, "CLINICALDOC"))

; Custom parser declarations
declare cParser = vc with noconstant("1=1")

; Build the parser for user search
if (rParam->search_value != "")

    set cParser = concat(^cnvtupper(cv.display) = patstring(|^, rParam->search_value, ^*|)^)
                                    
; Build a parser for default values                                    
elseif (rParam->search_limit > 0 and size(rParam->default, 5) > 0)

    set cParser = ^expand(nNum, 1, size(rParam->default, 5), cv.code_value, rParam->default[nNum])^
    set nDefault = 1

endif

; Perform a limit check to determine if too many values exist to upload
; ---------------------------------------------------------------------
if (rParam->search_limit > 0)
    
    ; Perform your select to count the results you are after
    select into "nl:"
        row_count   = count(cv.code_value)
    from    v500_event_set_explode      vese,
            code_value                  cv
    plan vese
        where vese.event_set_cd = cv93_ClinicalDoc
    join cv
        where cv.code_value = vese.event_cd
        and parser(cParser)
        and cv.active_ind = 1
        and cv.active_type_cd = cv48_Active
        and cv.end_effective_dt_tm > sysdate

    ; WARNING: Avoid modifying the detail section below or your code may fail
    detail
        if (row_count > rParam->search_limit)
            rCustom->status->error_ind = 1
            rCustom->status->message = concat(build(cnvtint(row_count)), " records retrieved. Limit is ", 
                                        build(rParam->search_limit), ".")
        endif
        rCustom->status->count = row_count
    with nocounter        
    
endif

; Perform the load if search limit does not fail
if (rCustom->status->error_ind = 0 or nDefault = 1)

    set rCustom->status.message = "No records qualified."

    select into "nl:"
    from    v500_event_set_explode      vese,
            code_value                  cv
    plan vese
        where vese.event_set_cd = cv93_ClinicalDoc
    join cv
        where cv.code_value = vese.event_cd
        and parser(cParser)
        and cv.active_ind = 1
        and cv.active_type_cd = cv48_Active
        and cv.end_effective_dt_tm > sysdate
    order cv.display_key
    head report
        rCustom->status.message = "Ok."
        nCount = 0
        
    ; WARNING: Detail section must write to rCustom->data[].key and rCustom->data[].value        
    detail
        nCount = nCount + 1
        stat = alterlist(rCustom->data, nCount)
        rCustom->data[nCount].key = cv.code_value
        rCustom->data[nCount].value = cv.display
        
    with counter, expand=2

endif
 
; ------------------------------------------------------------------------------------------------
;								END OF YOUR CUSTOM CODE
; ------------------------------------------------------------------------------------------------
 
; If you wish to return output back to the mPage, you need to run the ADD_CUSTOM_OUTPUT function.
; Any valid JSON format is acceptable including the CNVTRECTOJSON function. If using
; CNVTRECTOJSON be sure to use parameters 4 and 1 as shown below.
; If you plan on creating your own JSON string rather than converting a record structure, be
; sure to have it in the format of {"name":{your custom json data}} as the ADD_CUSTOM_OUTPUT
; subroutine will extract the first sub-object from the JSON. (e.g. {"name":{"personId":123}} will
; be sent to the output stream as {"personId": 123}.
call add_custom_output(cnvtrectojson(rCustom, 4, 1))
 
#end_program
 
end go
/*************************************************************************
 
        Script Name:    1co_pdf_to_chart.prg
 
        Description:    Clinical Office - MPage Edition
                        Sends an incoming PDF document to the patient chart
			using CAMMS.

			This code is experimental and is provided AS-IS
			and may or may not be included in future versions
			of Clinical Office.
 
        Date Written:   March 2, 2023
        Written by:     John Simpson
                        Precision Healthcare Solutions
                        
        Credit:         Based on code originally written by Travis Cazes                        
 
 *************************************************************************
            Copyright (c) 2023 Precision Healthcare Solutions
 
 NO PART OF THIS CODE MAY BE COPIED, MODIFIED OR DISTRIBUTED WITHOUT
 PRIOR WRITTEN CONSENT OF PRECISION HEALTHCARE SOLUTIONS EXECUTIVE
 LEADERSHIP TEAM.
 
 FOR LICENSING TERMS PLEASE VISIT www.clinicaloffice.com/mpage/license
 
 *************************************************************************
                            Special Instructions
 *************************************************************************
 None
  
 *************************************************************************
                            Revision Information
 *************************************************************************
 Rev    Date     By             Comments
 ------ -------- -------------- ------------------------------------------
 001    03/02/23 J. Simpson     Initial Development
 *************************************************************************/
drop program 1co_pdf_to_chart:group1 go
create program 1co_pdf_to_chart:group1

; Check to see if we have cleared the patient source and if not, do we have data in the patient source
; to run our custom CCL against.
if (validate(payload->customscript->clearpatientsource, 0) = 0)
	if (size(patient_source->patients, 5) = 0)
		go to end_program
	endif
endif

; Define code values
declare cv8_Auth = f8 with noconstant(uar_get_code_by("MEANING", 8, "AUTH"))
declare cv8_Modified = f8 with noconstant(uar_get_code_by("MEANING", 8, "MODIFIED"))
declare cv8_InError = f8 with noconstant(uar_get_code_by("MEANING", 8, "INERROR"))

free record rCustom
record rCustom (
    1 data[*]
        2 person_id             = f8
        2 encntr_id             = f8
        2 action                = vc
        2 parent_event_id       = f8
        2 status                = vc
)

; Testing camm error for John
/*
if (reqinfo->updt_id = 14308939)
    set stat = alterlist(rCustom->data, 1)
    set rCustom->data[1].status = "CAMM ERROR"
    go to output
endif
;*/

; Cerner record structures
free set mmf_store_request
record mmf_store_request (
    1 filename                  = vc
    1 contentType 		        = vc
    1 mediaType 		        = vc
    1 name                      = vc
    1 personId                  = f8
    1 encounterId               = f8
)
 
free record mmf_store_reply
record mmf_store_reply (   
    1 identifier 		        = vc
%i cclsource:status_block.inc
)
 
free set mmf_publish_ce_request
record mmf_publish_ce_request (
    1 personId                  = f8
    1 encounterId               = f8
    1 documentType_key          = vc 	;code set 72 display_key
    1 title                     = vc
    1 service_dt_tm             = dq8
    1 notetext                  = vc
    1 noteformat                = vc 	;code set 23 cdf_meaning
    1 personnel[*]
        2 id                    = f8
        2 action                = vc     ; code set 21 cdf_meaning
        2 status                = vc     ; code set 103 cdf_meanings
    1 mediaObjects[*]
        2 display               = vc
        2 identifier            = vc
    1 mediaObjectGroups[*]
        2 identifier            = vc
    1 publishAsNote             = i2
    1 debug                     = i2
)
 
free set mmf_publish_ce_reply
record mmf_publish_ce_reply (
    1 parentEventId = f8
%i cclsource:status_block.inc
) with persist

free record ensure_request
record ensure_request (
    1 req[*]
        2 ensure_type                           = i2
        2 version_dt_tm                         = dq8
        2 version_dt_tm_ind                     = i2
        2 event_prsnl
            3 event_prsnl_id                    = f8
            3 person_id                         = f8
            3 event_id                          = f8
            3 action_type_cd                    = f8
            3 request_dt_tm                     = dq8
            3 request_dt_tm_ind                 = i2
            3 request_prsnl_id                  = f8
            3 request_prsnl_ft                  = vc
            3 request_comment                   = vc
            3 action_dt_tm                      = dq8
            3 action_dt_tm_ind                  = i2
            3 action_prsnl_id                   = f8
            3 action_prsnl_ft                   = vc
            3 proxy_prsnl_id                    = f8
            3 proxy_prsnl_ft                    = vc
            3 action_status_cd                  = f8
            3 action_comment                    = vc
            3 change_since_action_flag          = i2
            3 change_since_action_flag_ind      = i2
            3 action_prsnl_pin                  = vc
            3 defeat_succn_ind                  = i2
            3 ce_event_prsnl_id                 = f8
            3 valid_from_dt_tm                  = dq8
            3 valid_from_dt_tm_ind              = i2
            3 valid_until_dt_tm                 = dq8
            3 valid_until_dt_tm_ind             = i2
            3 updt_dt_tm                        = dq8
            3 updt_dt_tm_ind                    = i2
            3 updt_task                         = i4
            3 updt_task_ind                     = i2
            3 updt_id                           = f8
            3 updt_cnt                          = i4
            3 updt_cnt_ind                      = i2
            3 updt_applctx                      = i4
            3 updt_applctx_ind                  = i2
            3 long_text_id                      = f8
            3 linked_event_id                   = f8
            3 request_tz                        = i4
            3 action_tz                         = i4
            3 system_comment                    = vc
            3 event_action_modifier_list[*]
                4 ce_event_action_modifier_id   = f8
                4 event_action_modifier_id      = f8
                4 event_id                      = f8
                4 event_prsnl_id                = f8
                4 action_type_modifier_cd       = f8
                4 valid_from_dt_tm              = dq8
                4 valid_from_dt_tm_ind          = i2
                4 valid_until_dt_tm             = dq8
                4 valid_until_dt_tm_ind         = i2
                4 updt_dt_tm                    = dq8
                4 updt_dt_tm_ind                = i2
                4 updt_task                     = i4
                4 updt_task_ind                 = i2
                4 updt_id                       = f8
                4 updt_cnt                      = i4
                4 updt_cnt_ind                  = i2
                4 updt_applctx                  = i4
                4 updt_applctx_ind              = i2
            3 ensure_type                       = i2
            3 digital_signature_ident           = vc
            3 action_prsnl_group_id             = f8
            3 request_prsnl_group_id            = f8
            3 receiving_person_id               = f8
            3 receiving_person_ft               = vc
        2 ensure_type2                          = i2
        2 clinsig_updt_dt_tm_flag               = i2
        2 clinsig_updt_dt_tm                    = dq8
        2 clinsig_updt_dt_tm_ind                = i2
    1 message_item
        2 message_text                          = vc
        2 subject                               = vc
        2 confidentiality                       = i2
        2 priority                              = i2
        2 due_date                              = dq8
        2 sender_id                             = f8
    1 user_id                                   = f8
)
 
free record ensure_reply
record ensure_reply (
    1 rep[*]
        2 event_prsnl_id            = f8
        2 event_id                  = f8
        2 action_prsnl_id           = f8
        2 action_type_cd            = f8
        2 sb
            3 severityCd            = i4
            3 statusCd              = i4
            3 statusText            = vc
            3 subStatusList[*]
                4 subStatusCd       = i4
    1 sb
        2 severityCd                = i4
        2 statusCd                  = i4
        2 statusText                = vc
        2 subStatusList[*]
            3 subStatusCd           = i4
%i cclsource:status_block.inc
)


call echorecord(patient_source)
call echorecord(payload)

; Assign incoming paramters
free record rParams
record rParams (
    1 action                    = vc
    1 title                     = vc
    1 pdf_document              = vc
    1 parent_event_id           = f8
    1 event_key                 = vc
    1 prsnl_actions[*]
        2 prsnl_id              = f8
        2 action[*]             = vc
)

set rParams->action = payload->customscript->script[nscript]->parameters.action
if (validate(payload->customscript->script[nscript]->parameters.parentEventId) > 0)
    set rParams->parent_event_id = payload->customscript->script[nscript]->parameters.parentEventId
endif

if (rParams->action in ("create", "modify", "addendum"))
    set rParams->title = payload->customscript->script[nscript]->parameters.documentTitle
    set rParams->pdf_document = payload->customscript->script[nscript]->parameters.pdfDocument
    if (validate(payload->customscript->script[nscript]->parameters.eventKey) > 0)
        set rParams->event_key = payload->customscript->script[nscript]->parameters.eventKey
    elseif (validate(payload->customscript->script[nscript]->parameters.eventCd) > 0)
        set rParams->event_key = uar_get_displaykey(payload->customscript->script[nscript]->parameters.eventCd)
    endif

    for (nLoop = 1 to size(payload->customscript->script[nscript]->parameters.prsnlActions, 5))
        set stat = alterlist(rParams->prsnl_actions, nLoop)
        set rParams->prsnl_actions[nLoop].prsnl_id = 
                payload->customscript->script[nscript]->parameters->prsnlActions[nLoop].prsnlId
    
        for (nLoop2 = 1 to size(payload->customscript->script[nscript]->parameters->prsnlActions[nLoop].action, 5))
            set stat = alterlist(rParams->prsnl_actions[nLoop].action, nLoop2)
            set rParams->prsnl_actions[nLoop].action[nLoop2] = 
                payload->customscript->script[nscript]->parameters->prsnlActions[nLoop].action[nLoop2]
        endfor                
    endfor
endif    

; Perform Create/Update Action
if (rParams->action in ("create", "modify", "addendum"))

    declare cFolder = vc with constant(concat(trim(logical("CCLUSERDIR"),3),"/")), protect
    declare cDcl = vc
    declare cFileName = vc with noconstant(
                build(^pdf_^, rand(curtime), ^_^, substring(1,10,rParams->pdf_document),"_",
                format(sysdate,"yyyymmddhhmmss;;q")))
    declare cBase64Pdf = vc with noconstant(
                replace(cnvthexraw(rParams->pdf_document), "data:application/pdf;base64,",""))

    ; Convert the Base64 PDF to an ASCII file
    record fRec (
        1 file_desc     = i4
        1 file_offest   = i4
        1 file_dir      = i4
        1 file_name     = vc
        1 file_buf      = vc
    )
    
    set fRec->file_name = build(cFileName, ".b64")
    set fRec->file_buf = "w"
    set stat = cclio("OPEN", fRec)
    
    set fRec->file_buf = cBase64Pdf
    set stat = cclio("PUTS", fRec)
    set stat = cclio("CLOSE", fRec)
    
    set cDcl = concat(^cat ^, cFileName, ^.b64 | base64 --decode > ^, cFileName, ^.pdf && rm ^, cFileName, ^.b64^)
    call dcl(cDcl, size(cDcl), 0)
    
    set stat = alterlist(rCustom->data, size(patient_source->visits, 5))
    
    ; Loop through each visit to assign document (Same PDF can be assigned to multiple encounters)
    for (nLoop = 1 to size(patient_source->visits, 5))
    
        ; Clear any previous values
        set stat = initrec(mmf_store_request)
		set stat = initrec(mmf_store_reply)
    
        ; Assign mmf_store_request variables
        set mmf_store_request->filename = build(cFolder, cFileName, ".pdf")
        set mmf_store_request->mediaType = "application/pdf"
        set mmf_store_request->contentType = "PDF_GENERATED_FORM"
        set mmf_store_request->name = build(cFileName, ".pdf")
        set mmf_store_request->personid = patient_source->visits[nLoop].person_id
        set mmf_store_request->encounterid = patient_source->visits[nLoop].encntr_id
        
        ; Execute Cerner Script
        execute mmf_store_object_with_xref with replace("REQUEST",mmf_store_request), replace("REPLY",mmf_store_reply)
        
        call echorecord(mmf_store_reply)
        call echo("****************************")
        
        set rCustom->data[nLoop].person_id = patient_source->visits[nLoop].person_id
        set rCustom->data[nLoop].encntr_id = patient_source->visits[nLoop].encntr_id
        set rCustom->data[nLoop].action = rParams->action
        
        ; Failed        
        if (mmf_store_reply->status_data->status = "F")
        
            set rCustom->data[nLoop].status = "CAMM ERROR"
        
        ; Perform Create task
        elseif (rParams->action = "create")      
        
        
            ; Clear previous values
            set stat = initrec(mmf_publish_ce_request)
            set stat = initrec(mmf_publish_ce_reply)
            
            set stat = alterlist(mmf_publish_ce_request->mediaObjects, 1)	;add row for our mediaObject
            set mmf_publish_ce_request->documenttype_key = rParams->event_key
            set mmf_publish_ce_request->service_dt_tm = sysdate
            set mmf_publish_ce_request->personId = patient_source->visits[nLoop].person_id
            set mmf_publish_ce_request->encounterId = patient_source->visits[nLoop].encntr_id
            set mmf_publish_ce_request->mediaObjects[1].display = rParams->title
            set mmf_publish_ce_request->mediaObjects[1].identifier = mmf_store_reply->identifier
            set mmf_publish_ce_request->title = rParams->title
            set mmf_publish_ce_request->notetext = rParams->title
            set mmf_publish_ce_request->noteformat = "PDF" ;"AS"
            set mmf_publish_ce_request->publishAsNote = 1 ; 0 = Summary with link, 1 = Embed
            set mmf_publish_ce_request->debug = 1
            
            ; Assign actions
            set nAction = 0
            for (nLoop2 = 1 to size(rParams->prsnl_actions, 5))
                for (nLoop3 = 1 to size(rParams->prsnl_actions[nLoop2].action, 5))
                    set nAction = nAction + 1
                    set stat = alterlist(mmf_publish_ce_request->personnel, nAction)
                    set mmf_publish_ce_request->personnel[nAction].id = rParams->prsnl_actions[nLoop2].prsnl_id
                    set mmf_publish_ce_request->personnel[nAction].action = rParams->prsnl_actions[nLoop2].action[nLoop3]
                    set mmf_publish_ce_request->personnel[nAction].status = "COMPLETED"                    
                endfor
            endfor
            
            ; Execute Cerner Script
            execute mmf_publish_ce with replace("REQUEST",mmf_publish_ce_request),replace("REPLY",mmf_publish_ce_reply)
            
            ; Update the MPage output
            set rCustom->data[nLoop].parent_event_id = mmf_publish_ce_reply->parentEventId
                        
            call echorecord(mmf_publish_ce_reply)
            
        ; Modify Note (only allow single modify)
        elseif (rParams->parent_event_id > 0 and nLoop = 1)
        
            call echo(concat("Updating CLINICAL_EVENT - parent_event_id=",cnvtstring(rParams->parent_event_id)))
        
            ; Update the main clinical event record
            update into clinical_event          ce
            set ce.result_status_cd     = evaluate(rParams->action, "modify", cv8_Auth, cv8_Modified),
                ce.event_title_text     = trim(rParams->title,3),
                ce.event_end_dt_tm      = sysdate,
                ce.updt_dt_tm           = sysdate,
                ce.updt_id              = reqinfo->updt_id,
                ce.updt_task            = reqinfo->updt_task,
                ce.updt_cnt             = 0,
                ce.updt_applctx         = reqinfo->updt_applctx
            where ce.parent_event_id = rParams->parent_event_id
            and ce.valid_until_dt_tm > sysdate
            and ce.encntr_id = patient_source->visits[1].encntr_id
            and ce.person_id = patient_source->visits[1].person_id
            
            call echo("Updating CE_BLOB_RESULT")
            
            ; Update blob result
            update into ce_blob_result          cbr
            set cbr.blob_handle         = mmf_store_reply->identifier,
                cbr.updt_dt_tm          = sysdate,
                cbr.updt_id             = reqinfo->updt_id,
                cbr.updt_task           = reqinfo->updt_task,
                cbr.updt_cnt             = 0,
                cbr.updt_applctx         = reqinfo->updt_applctx
            where cbr.event_id = (
                    select  ce.event_id
                    from    clinical_event      ce
                    where ce.parent_event_id = rParams->parent_event_id
                    and ce.valid_until_dt_tm > sysdate
                    and ce.encntr_id = patient_source->visits[1].encntr_id
                    and ce.person_id = patient_source->visits[1].person_id
            )
            and cbr.valid_until_dt_tm > sysdate
            
            commit
            
            call echo("Updating Actions")
            
            ; Update the actions
            set stat = initrec(ensure_request)
            set stat = initrec(ensure_reply)

            set nAction = 0
            for (nLoop2 = 1 to size(rParams->prsnl_actions, 5))
                for (nLoop3 = 1 to size(rParams->prsnl_actions[nLoop2].action, 5))
                call echo(rParams->prsnl_actions[nLoop2].action[nLoop3])
                    set nAction = nAction + 1
                    set stat = alterlist(ensure_request->req, nAction)
                    set ensure_request->req[nAction].ensure_type = 2
                    set ensure_request->req[nAction].version_dt_tm_ind = 1
                    set ensure_request->req[nAction]->event_prsnl.event_id = rParams->parent_event_id
                    set ensure_request->req[nAction]->event_prsnl.action_type_cd = 
                            value(uar_get_code_by("MEANING", 21, build(rParams->prsnl_actions[nLoop2].action[nLoop3])))
                    set ensure_request->req[nAction]->event_prsnl.action_dt_tm = sysdate                            
                    set ensure_request->req[nAction]->event_prsnl.action_prsnl_id = rParams->prsnl_actions[nLoop2].prsnl_id
                    set ensure_request->req[nAction]->event_prsnl.proxy_prsnl_id = 0.0
                    set ensure_request->req[nAction]->event_prsnl.action_status_cd = 
                            value(uar_get_code_by("MEANING", 103, "COMPLETED"))
                    set ensure_request->req[nAction]->event_prsnl.defeat_succn_ind = 1
                    set ensure_request->req[nAction]->event_prsnl.action_comment = "Modified via PDF to Chart"
                endfor
            endfor
            
            call echorecord(ensure_request)
            
            ; Execute Cerner Script
            execute inn_event_prsnl_batch_ensure with replace("ensure_request",ensure_request),replace("ensure_reply",ensure_reply)
            
            set rCustom->data[nLoop].parent_event_id = rParams->parent_event_id
            set rCustom->data[nLoop].status = trim(ensure_reply->status_data, 3)
            
                    
        endif
        
    endfor        
    
    ; Delete the PDF file
    set stat = remove(build(cFileName, ^.pdf^))

; In Error the document
elseif (rParams->action = "inerror")
    
    set stat = alterlist(rCustom->data, 1)
    set rCustom->data[1].person_id = patient_source->visits[1].person_id
    set rCustom->data[1].encntr_id = patient_source->visits[1].encntr_id
    set rCustom->data[1].action = rParams->action
    set rCustom->data[1].parent_event_id = rParams->parent_event_id
    
    if (rParams->parent_event_id > 0.0)
        
        ; Update the main clinical event record
        update into clinical_event          ce
        set ce.result_status_cd     = cv8_InError,
            ;ce.event_title_text     = trim(rParams->title,3),
            ce.event_end_dt_tm      = sysdate,
            ce.updt_dt_tm           = sysdate,
            ce.updt_id              = reqinfo->updt_id,
            ce.updt_task            = reqinfo->updt_task,
            ce.updt_cnt             = 0,
            ce.updt_applctx         = reqinfo->updt_applctx
        where ce.parent_event_id = rParams->parent_event_id
        and ce.valid_until_dt_tm > sysdate
        and ce.encntr_id = patient_source->visits[1].encntr_id
        and ce.person_id = patient_source->visits[1].person_id        
        
        commit

        ; Update the actions
        set stat = initrec(ensure_request)
        set stat = initrec(ensure_reply)

        set stat = alterlist(ensure_request->req, 1)
        set ensure_request->req[1].ensure_type = 2
        set ensure_request->req[1].version_dt_tm_ind = 1
        set ensure_request->req[1]->event_prsnl.event_id = rParams->parent_event_id
        set ensure_request->req[1]->event_prsnl.action_type_cd = value(uar_get_code_by("MEANING", 21, "MODIFY"))
        set ensure_request->req[1]->event_prsnl.action_dt_tm = sysdate                            
        set ensure_request->req[1]->event_prsnl.action_prsnl_id = reqinfo->updt_id
        set ensure_request->req[1]->event_prsnl.proxy_prsnl_id = 0.0
        set ensure_request->req[1]->event_prsnl.action_status_cd = value(uar_get_code_by("MEANING", 103, "INERROR"))
        set ensure_request->req[1]->event_prsnl.defeat_succn_ind = 1
        set ensure_request->req[1]->event_prsnl.action_comment = "In-Errored via PDF to Chart"

        ; Execute Cerner Script
        execute inn_event_prsnl_batch_ensure with replace("ensure_request",ensure_request),replace("ensure_reply",ensure_reply)
    endif

endif

#output

call add_custom_output(cnvtrectojson(rCustom, 4, 1))

#end_program
 
end go
/*************************************************************************
 
        Script Name:    1co_prsnl_search.prg
 
        Description:    Clinical Office - mPage Edition
                        Prsnl Search Component CCL Support Script
 
        Date Written:   March 3, 2022
        Written by:     John Simpson
                        Precision Healthcare Solutions
 
 *************************************************************************
            Copyright (c) 2022 Precision Healthcare Solutions
 
 NO PART OF THIS CODE MAY BE COPIED, MODIFIED OR DISTRIBUTED WITHOUT
 PRIOR WRITTEN CONSENT OF PRECISION HEALTHCARE SOLUTIONS EXECUTIVE
 LEADERSHIP TEAM.
 
 FOR LICENSING TERMS PLEASE VISIT www.clinicaloffice.com/mpage/license
 
 *************************************************************************
                            Special Instructions
 *************************************************************************
 Called from select component
 *************************************************************************
                            Revision Information
 *************************************************************************
 Rev    Date     By             Comments
 ------ -------- -------------- ------------------------------------------
 001    03/03/22 J. Simpson     Initial Development
 002    12/23/23 J. Simpson     Allow support for mpage-personnel-search component
 *************************************************************************/
drop program 1co_prsnl_search:group1 go
create program 1co_prsnl_search:group1
 
; Check to see if we have cleared the patient source and if not, do we have data in the patient source
; to run our custom CCL against.
if (validate(payload->customscript->clearpatientsource, 0) = 0)
	if (size(patient_source->patients, 5) = 0)
		go to end_program
	endif
endif

; Declare variables and subroutines
declare nNum = i4
declare nDefault = i4
declare cMode = vc with noconstant("mpage-select")
declare cFirstName = vc
declare cLastName = vc

; Custom parser declarations
declare cPrsnlParser = vc with noconstant("1=1")
declare cPrsnlPhysParser = vc with noconstant("1=1")
declare cDefaultParser = vc with noconstant("1=1")

; Collect code values
declare cv48_Active = f8 with noconstant(uar_get_code_by("MEANING", 48, "ACTIVE"))

; Determine the run mode
if (validate(payload->customscript->script[nscript]->parameters->mode) = 1)
    set cMode = payload->customscript->script[nscript]->parameters->mode
endif

free record rCustom

if (cMode = "provider-search")

    record rCustom (
        1 status
            2 error_ind             = i4
            2 message               = vc
        1 data[*]
            2 person_id             = f8
            2 name_full_formatted   = vc
            2 position_cd           = f8
            2 position              = vc
            2 physician             = vc
    )
       
    ; Setup name values
    if (validate(payload->customscript->script[nscript]->parameters->fullname) > 0)
        set cLastName = trim(cnvtupper(piece(payload->customscript->script[nscript]->parameters->fullname, "," , 1,
                            payload->customscript->script[nscript]->parameters->fullname)),3)
        set cFirstName = trim(cnvtupper(piece(payload->customscript->script[nscript]->parameters->fullname, "," , 2, "")),3)
    endif

    if (validate(payload->customscript->script[nscript]->parameters->lastname) > 0)
        set cLastName = cnvtupper(payload->customscript->script[nscript]->parameters->lastname)
    endif

    if (validate(payload->customscript->script[nscript]->parameters->firstname) > 0)
        set cFirstName = cnvtupper(payload->customscript->script[nscript]->parameters->firstname)
    endif

    set cPrsnlParser = "p.name_last_key = patstring(cLastName)"

    if (size(cFirstName) > 0)
        set cPrsnlParser = concat(cPrsnlParser, " and p.name_first_key = patstring(cFirstName)")
    endif
    
    call echorecord(payload->customscript->script[nscript]->parameters)
    
    ; Physician Indicator
    if (payload->customscript->script[nscript]->parameters->physicianInd = 1)
        set cPrsnlPhysParser = "p.physician_ind = 1"
    endif
    
    ; Position Codes
    if (size(payload->customscript->script[nscript]->parameters->positionCd, 5) > 0)
        if (payload->customscript->script[nscript]->parameters->positionCd > 0.0)
        
            set cDefaultParser = concat(^expand(nNum,1,size(payload->customscript->script[nscript]->parameters->positionCd, 5),^,
                                ^p.position_cd, payload->customscript->script[nscript]->parameters->positionCd[nNum])^)
        endif
    endif
        
elseif (cMode = "mpage-select")
    
    record rCustom (
        1 status
            2 error_ind             = i4
            2 message               = vc
            2 count                 = i4
        1 data[*]
            2 key                   = f8
            2 value                 = vc      
    )

    ; Define and populate the parameters structure
    free record rParam
    record rParam (
        1 search_ind                = i4
        1 search_limit              = i4
        1 physician_ind             = i4
        1 code_set                  = i4
        1 value_type                = vc
        1 search_value              = vc
        1 default[*]                = f8
    )

    set rParam->search_ind = payload->customscript->script[nscript]->parameters->search
    set rParam->search_limit = payload->customscript->script[nscript]->parameters->searchlimit
    set rParam->physician_ind = payload->customscript->script[nscript]->parameters->physicianind
    set rParam->code_set = payload->customscript->script[nscript]->parameters->codeset
    set rParam->value_type = payload->customscript->script[nscript]->parameters->valuetype
    set rParam->search_value = cnvtupper(payload->customscript->script[nscript]->parameters->searchvalue)

    if (size(payload->customscript->script[nScript]->parameters->default, 5) > 0)
        set stat = alterlist(rParam->default, size(payload->customscript->script[nScript]->parameters->default, 5))
        for (nLoop = 1 to size(rParam->default, 5))   
            set rParam->default[nLoop] = cnvtreal(payload->customscript->script[nScript]->parameters->default[nLoop])
        endfor        
    endif
  
    ; Build the user search parser
    if (rParam->search_value != "")
    
        set cPrsnlParser = concat(^p.name_last_key = patstring(|^,
                                    piece(rParam->search_value,",",1,rParam->search_value), ^*|)^)
 
        if (piece(rParam->search_value,",",2,"onlylastname") != "onlylastname")
            set cPrsnlParser = concat(trim(cPrsnlParser),
                                ^ and p.name_first_key = patstring(|^,
                                trim(piece(rParam->search_value,",",2,rParam->search_value),3), ^*|)^)
        endif
    ; Build a parser for default values                                    
    elseif (rParam->search_limit > 0 and size(rParam->default, 5) > 0)

        set cDefaultParser = ^expand(nNum, 1, size(rParam->default, 5), p.person_id, rParam->default[nNum])^
        set nDefault = 1

    endif

    if (rParam->physician_ind = 1)
        set cPrsnlPhysParser = "p.physician_ind = 1"
    endif

    ; Perform a limit check to determine if too many values exist to upload
    ; ---------------------------------------------------------------------
    if (rParam->search_limit > 0)
    
        ; Perform your select to count the results you are after
        select into "nl:"
            row_count   = count(p.person_id)
        from    prsnl           p
        plan p
            where parser(cPrsnlParser)
            and parser(cPrsnlPhysParser)
            and p.active_ind = 1
            and p.active_status_cd = cv48_Active
            and p.end_effective_dt_tm > sysdate
        
        ; WARNING: Avoid modifying the detail section below or your code may fail
        detail
            if (row_count > rParam->search_limit and size(rParam->default, 5) = 0)
                rCustom->status->error_ind = 1
                rCustom->status->message = concat(build(cnvtint(row_count)), " records retrieved. Limit is ", 
                                        build(rParam->search_limit), ".")
            endif
            rCustom->status->count = row_count            
        with nocounter        
    
    endif
endif    

    ; Perform the load if search limit does not fail
if (rCustom->status->error_ind = 0 or nDefault = 1)

    set rCustom->status.message = "No records qualified."

    select into "nl:"
    from    prsnl           p
    plan p
        where parser(cPrsnlParser)
        and parser(cPrsnlPhysParser)
        and parser(cDefaultParser)
        and p.active_ind = 1
        and p.active_status_cd = cv48_Active
        and p.end_effective_dt_tm > sysdate
    order p.name_full_formatted        
    head report
        rCustom->status.message = "Ok."
        nCount = 0
        
    ; WARNING: Detail section must write to rCustom->data[].key and rCustom->data[].value        
    detail
        nCount = nCount + 1
        stat = alterlist(rCustom->data, nCount)
        
        if (cMode = "mpage-select")
            statKey = assign(validate(rCustom->data[nCount].key), p.person_id)
            statValue = assign(validate(rCustom->data[nCount].value), p.name_full_formatted)

        elseif (cMode = "provider-search")            
            statPersonId = assign(validate(rCustom->data[nCount].person_id), p.person_id)
            statNameFull = assign(validate(rCustom->data[nCount].name_full_formatted), p.name_full_formatted)
            statPosCd = assign(validate(rCustom->data[nCount].position_cd), p.position_cd)
            statPosition = assign(validate(rCustom->data[nCount].position), uar_get_code_display(p.position_cd))
            statPhys = assign(validate(rCustom->data[nCount].physician), evaluate(p.physician_ind, 1, "Yes", "No"))

        endif
        
    with counter        

endif
 
; ------------------------------------------------------------------------------------------------
;								END OF YOUR CUSTOM CODE
; ------------------------------------------------------------------------------------------------
 
; If you wish to return output back to the mPage, you need to run the ADD_CUSTOM_OUTPUT function.
; Any valid JSON format is acceptable including the CNVTRECTOJSON function. If using
; CNVTRECTOJSON be sure to use parameters 4 and 1 as shown below.
; If you plan on creating your own JSON string rather than converting a record structure, be
; sure to have it in the format of {"name":{your custom json data}} as the ADD_CUSTOM_OUTPUT
; subroutine will extract the first sub-object from the JSON. (e.g. {"name":{"personId":123}} will
; be sent to the output stream as {"personId": 123}.
call add_custom_output(cnvtrectojson(rCustom, 4, 1))
 
#end_program
 
end go
