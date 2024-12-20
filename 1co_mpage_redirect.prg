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
