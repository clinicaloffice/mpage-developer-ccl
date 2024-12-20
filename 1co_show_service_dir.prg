/*************************************************************************
 
        Script Name:    1co_show_service_dir
 
        Description:    Clinical Office - mPage Edition
                        Utility Script to verify web service directory
 
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
drop program 1co_show_service_dir:group1 go
create program 1co_show_service_dir:group1
 
prompt
	"Output to File/Printer/MINE" = "MINE"   ;* Enter or select the printer or file name to send this report to.
with outdev
 
free record rHost
record rHost (
    1 domain                        = vc
    1 zone                          = vc
    1 full_canonical_domain_name    = vc
    1 service_directory_url         = vc
)
 
set rHost->domain = trim(cnvtlower(logical("environment")),3)
 
; Determine the Zone name
; -----------------------
declare cUri = vc
declare cTmp = vc with noconstant(concat("1co_mp_domain",format(sysdate,"yyyymmddhhmmss;;d"),".txt"))
declare cCmd = vc with noconstant("hostnew -t SRV")
if (cursys != cursys2)
    set cCmd = "host -N 2 -t SRV"
endif
declare cDcl = vc with noconstant(concat(cCmd, " _cerner_", rHost->domain, "_mqclient._tcp >> ", cTmp))
 
call dcl(cDcl, size(cDcl), 0)
free define rtl
define rtl is value(cTmp)
 
select into "nl:"
from rtlt   r
detail
    zoneStart = findstring("._tcp.", r.line)+6
    zoneEnd = findstring(char(32), r.line, zoneStart)
    rHost->zone = substring(zoneStart, (zoneEnd-zoneStart), r.line)
    rHost->full_canonical_domain_name = concat(trim(rHost->domain), ".", trim(rHost->zone))
with counter
 
set stat = remove(cTmp)
 
; Determine DNS name (requires multiple passes)
call getServiceDirectoryUrl(build2("_cerner_svcdirssl_", rHost->domain, "._tcp.", rHost->zone),"https://")
call getServiceDirectoryUrl(build2("_cerner_svcdir_", rHost->domain, "._tcp.", rHost->zone),"http://")
call getServiceDirectoryUrl(build2("_cerner_svcdirssl._tcp.", rHost->zone),"https://")
call getServiceDirectoryUrl(build2("_cerner_svcdir._tcp.", rHost->zone),"http://")
 
; Output
select into value($outdev)
from    dummyt      d
plan d
detail
    cUri = build2(
            rHost->service_directory_url,
            ^/services-directory/authorities/^,
            rHost->full_canonical_domain_name,
            ^/keys/urn:cerner:api:mpages.json^
            )
 
 
	col 0, ^<!DOCTYPE html>^, row + 1
	col 0, ^<html lang="en">^, row + 1
	col 0, ^<head>^, row + 1
 
	; Allow CCLINK and set browser preferences
	col 0, ^<meta content="IE=Edge" http-equiv="X-UA-Compatible" />^, row + 1
 
    col 0, ^<script type="text/javascript">^, row + 1
 
    col 0, ^function loadJSON(path, success, error)^, row + 1
    col 0, ^{^, row + 1
    col 0, ^    var xhr = new XMLHttpRequest();^, row + 1
    col 0, ^    xhr.onreadystatechange = function()^, row + 1
    col 0, ^    {^, row + 1
    col 0, ^        if (xhr.readyState === 4) {^, row + 1
    col 0, ^            if (xhr.status === 200) {^, row + 1
    col 0, ^                if (success)^, row + 1
    col 0, ^                    var resp = JSON.parse(xhr.responseText);^, row + 1
    col 0, ^                    success(resp);^, row + 1
    col 0, ^            } else {^, row + 1
    col 0, ^                if (error)^, row + 1
    col 0, ^                    error(xhr);^, row + 1
    col 0, ^            }^, row + 1
    col 0, ^        }^, row + 1
    col 0, ^    };^, row + 1
    col 0, ^    xhr.open("GET", path, true);^, row + 1
    col 0, ^    xhr.send();^, row + 1
    col 0, ^}^, row + 1
 
    col 0, ^loadJSON('^, cUri, ^',function(data) {^, row + 1
    col 0, ^    var iFLink = data.link.substring(0, data.link.indexOf('/mpages/'));^, row + 1
    col 0, ^    iFLink = '<iframe width="100%" height="500px" src="' + iFLink + '"></iframe>';^, row + 1
    col 0, ^    document.getElementById("frame").innerHTML = iFLink;^, row + 1
    col 0, ^    data.link = data.link + 'reports';^, row + 1
    col 0, ^    var cHTML = '<a href="' + data.link + '">' + data.link + '</a>';^, row + 1
    col 0, ^    document.getElementById("content").innerHTML = data.link;^, row + 1
 
    col 0, ^}, function(xhr) { alert(xhr); });^, row + 1
 
    col 0, ^</script>^, row + 1
    col 0, ^</head>^, row + 1
    col 0, ^<body>^, row + 1
 
    col 0, ^<h2>Clinical Office: MPage Edition</h2>^, row + 1
    col 0, ^<p>This tool attempts to identify the location of your Discern Web Services install. Discern Web Services ^,
            ^can be used to display MPage output from locations that do not have access to XMLCclRequest such as ^,
            ^Revenue Cycle or through an Angular Proxy when live-testing MPages during development.</p>^, row + 1
 
    col 0, ^<h3>contextRoot / cclproxy value</h3>^,row + 1
    col 0, ^<p>The following value can be used in your proxy.conf.json file for real-time development using the Angular ^,
            ^Proxy or as your MPage contextRoot value for applications that do not have XMLCclRequest capabilities.</p>^, row + 1
 
    col 0, ^<code style="background-color: #dfdfdf; font-size: 1.5rem; padding: 1rem;" id="content">x</code>^, row + 1
 
    col 0, ^<br />&nbsp;<br /><h2>If the contextRoot value above is valid, you should see the ^,
            ^"Welcome to Discern MPages" page in the frame below.</h2>^, row + 1
    col 0, ^<div id="frame">x</div>^, row + 1
 
    col 0, ^</body>^, row + 1
    col 0, ^</html>^, row + 1
with counter, maxrow=1, maxcol=1500, format=variable, noformfeed, format
 
; Used to determine the correct service directory
subroutine getServiceDirectoryUrl(cPath, cPrefix)
 
    if (trim(rHost->service_directory_url) = "")
 
        set cDcl = concat(cCmd, " ", cPath, " >> ", cTmp)
        call dcl(cDcl, size(cDcl), 0)
 
        free define rtl
        define rtl is value(cTmp)
 
        select into "nl:"
            text = trim(substring(findstring(char(32), trim(r.line), 1, 1),255,r.line),3)
        from rtlt   r
        plan r
        detail
            url = substring(1,size(trim(text))-1, text)
            if (cnvtint(substring(1,1,url)) = 0)
                rHost->service_directory_url = concat(cPrefix, url)
            endif
        with maxcol=500
 
        set stat = remove(cTmp)
    endif
 
end
 
end go
