#
# $Id$
#

proc filter_process_listfile {type wct_listfile fmt} {

    global gisfilter;

    set cmd [list nbspwctlist -b -K -t $type];
    if {$gisfilter(${type}_latest_enable) == 1} {
	lappend cmd "-l" $gisfilter(${type}_latestname);
    }

    lappend cmd $wct_listfile $fmt "&";

    set status [catch {
	eval exec $cmd;
    } errmsg];

    if {$status != 0} {
	log_err $errmsg;
    }
}

proc filter_sat_process_listfile {wct_listfile fmt} {

    filter_process_listfile "sat" $wct_listfile $fmt;
}

proc filter_rad_process_listfile {wct_listfile fmt} {

    filter_process_listfile "rad" $wct_listfile $fmt;
}

proc filter_make_next_qf {fmt} {

    global gisfilter;

    set current_minute [clock format [clock seconds] -format "%M"];
    append wct_listfile_name $fmt "." $current_minute \
	$gisfilter(wct_listfile_qfext);

    return [file join \
		$gisfilter(wct_listfile_qdir) $wct_listfile_name];
}