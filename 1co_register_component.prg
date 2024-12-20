/*************************************************************************
 
        Script Name:    1co_register_component.prg
 
        Description:    Clinical Office - mPage Edition
        				Registers an Edge Component by Bedrock Name and
        				matches it to HTML Output.
 
        Date Written:   May 18, 2023
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
 None
 *************************************************************************
                            Revision Information
 *************************************************************************
 Rev    Date     By             Comments
 ------ -------- -------------- ------------------------------------------
 001    05/18/23 J. Simpson     Initial Development
 *************************************************************************/

drop program 1co_register_component:group1 go
create program 1co_register_component:group1

prompt 
	"Output to File/Printer/MINE" = "MINE"    ;* Enter or select the printer or file name to send this report to.
	, "Component Label (from Bedrock)" = ""
	, "Component Target" = "" 

with outdev, label, target

call echo("1co_register_component")

; Set the absolute maximum possible variable length
set modify maxvarlen 268435456
 
record request (
	1 blob_in = vc
)
 
; Variable declarations
declare _Memory_Reply_String = vc
declare nPERSON_ID = f8 with noconstant(0.0)
declare nENCNTR_ID = f8 with noconstant(0.0)
declare nPRSNL_ID = f8 with noconstant(reqinfo->updt_id)
declare cTarget = vc with noconstant($target)

; Check target
if (substring(size(trim(cTarget)), 1, cTarget) in ("\", "/"))
    set cTarget = substring(1, size(trim(cTarget)) - 1, cTarget)
    
    call echo(cTarget)
endif

declare nCategoryId = f8

select into "nl:"
from    br_datamart_filter      f,
        br_datamart_value       v
plan f
    where f.filter_mean = "CUSTOM_COMP_*"
join v
    where v.br_datamart_filter_id = f.br_datamart_filter_id
    and v.mpage_param_mean = "mp_label"
    and v.mpage_param_value = $label
    and v.end_effective_dt_tm > sysdate
detail
    nCategoryId = f.br_datamart_category_id
with counter

if (nCategoryId = 0)
    select into value($outdev)
    from    dummyt          d
    detail
        col 0, "Invalid Label Entered, please check values in BEDROCK. You entered ", 
               $label, ".", row + 1
    with counter               
    
    go to end_program
endif

set request->blob_in = concat(^{"payload":{"patientSource":[{"personId":0,"encntrId":0}],"customScript":{"script":^,
^[{"name":"1co_mpage_dm_info:group1","run":"pre","id":"update-component","parameters":{"action":"w",^,
^"data":[{"infoDomain":"Clinical Office Component","infoName":"^, $label, ^","infoDate":"^,
format(sysdate, "yyyy-mm-ddThh:mm:ss.000+00.00;;q"), ^","infoChar":"^, cTarget, ^","infoNumber":0,"infoLongText":"",^,
^"infoDomainId":0}]^,
^}}]}}}^)

call echorecord(request)

execute 1co3_mpage_entry:group1 "mine", value(nPERSON_ID), value(nENCNTR_ID), value(nPRSNL_ID), 0, ^{"mode":"ORG"}^
 
select into value($outdev)
from    dummyt          d
detail
    col 0, "Component '", $label, "' added/updated.", row + 1
with counter               


#end_program

end go
