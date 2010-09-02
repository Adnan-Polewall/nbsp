#
# $Id$
#
proc filter_rad {rc_varname} {

    global gisfilter;
    upvar $rc_varname rc;

    filter_rad_create_nids rc;

    foreach bundle $gisfilter(rad_bundlelist) {
	set regex $gisfilter(rad_bundle,$bundle,regex);
	if {[filterlib_uwildmat $regex $rc(fname)] == 0} {
	    continue;
	}
	filter_rad_queue_convert_nids rc $bundle;
    }
}

proc filter_rad_create_nids {rc_varname} {
    #
    # Write the nids file
    #
    global gisfilter;
    upvar $rc_varname rc;

    set seq $rc(seq);
    set fpath $rc(fpath);

    set data_savedir [subst $gisfilter(rad_outputfile_dirfmt,nids)];
    set data_savename [subst $gisfilter(rad_outputfile_namefmt,nids)];

    file mkdir $data_savedir;
    set data_path [file join $data_savedir $data_savename];
    set datafpath [file join $gisfilter(datadir) $data_path];

    set status [catch {
	filterlib_cspool_nbspfile $seq $fpath $data_savedir $data_savename;
	# filterlib_nbspfile $seq $fpath $data_savedir $data_savename;
    } errmsg];

    if {$status != 0} {
        file delete $data_path;
        log_msg $errmsg;
        return -code error $errmsg;
    }

    filter_rad_insert_inventory $data_savedir $datafpath;
    make_rad_latest $data_savedir $data_savename;

    # Reuse the rc(fpath) variable to point to the newly created gini file.
    set rc(fpath) $datafpath;
}

proc filter_rad_convert_nids {rc_varname bundle} {

    global gisfilter;
    upvar $rc_varname rc;

    set nidsfpath $rc(fpath);
    set wctrcfile $gisfilter(rad_bundle,$bundle,wctrc_file);

    # shorthand
    set fmt $gisfilter(rad_bundle,$bundle,outputfile_fmt);

    set data_savedir [subst $gisfilter(rad_outputfile_dirfmt,$fmt)];
    set data_savename [subst $gisfilter(rad_outputfile_namefmt,$fmt)];

    file mkdir $data_savedir;
    set data_path [file join $data_savedir $data_savename];
    set datafpath [file join $gisfilter(datadir) $data_path];

    set cmd [list "nbspwct" -b -f $fmt -t rad -x $wctrcfile];
    if {$gisfilter(wct_debug) != 0} {
	lappend cmd "-V";
    }
    if {$gisfilter(rad_latest_enable) != 0} {
	lappend cmd -l $gisfilter(rad_latestname);
    }
    lappend cmd -d $data_savedir -o $data_savename $nidsfpath;

    # Because WCT takes some time to process the file, we will execute it
    # in the background. 

    eval exec $cmd &;

    # Because of the background execution there is no way to know here if
    # WCT actially succeeded, so we will insert it in the inventory anyway.

    filter_rad_insert_inventory $data_savedir $datafpath;
}

proc filter_rad_queue_convert_nids {rc_varname bundle} {

    global gisfilter;
    upvar $rc_varname rc;

    set nidsfpath $rc(fpath);
    set wctrcfile $gisfilter(rad_bundle,$bundle,wctrc_file);

    # shorthand
    set fmt $gisfilter(rad_bundle,$bundle,outputfile_fmt);

    set data_savedir [subst $gisfilter(rad_outputfile_dirfmt,$fmt)];
    set data_savename [subst $gisfilter(rad_outputfile_namefmt,$fmt)];

    file mkdir $data_savedir;
    set data_path [file join $data_savedir $data_savename];
    set datafpath [file join $gisfilter(datadir) $data_path];

    # Write to the wct list
    lappend gisfilter(wct_listfile_list,$fmt)
	"$nidsfpath,[file dirname $datafpath],$wctrcfile" \
	"#,$nidsfpath,$datafpath";

    # Write the file if the current minute expired
    set current_minute [clock format [clock seconds] -format "%M"];
    if {$current_minute ne $gisfilter(wct_listfile_minute)} {
	append wct_listfile_name $fmt "." $gisfilter(wct_listfile_minute);
	set wct_listfile [file join \
	    $gisfilter(wct_listfile_qdir) $wct_listfile_name];

	::fileutil::appendToFile $wct_listfile \
	    [join $gisfilter(wct_listfile_list,$fmt) "\n"];

	# reinitialize
	set gisfilter(wct_listfile_minute) $current_minute;
	set gisfilter(wct_listfile_list,$fmt) [list];
    }

#    puts "$nidsfpath,[file dirname $datafpath],$wctrcfile";
#    puts "#,$nidsfpath,$datafpath";
}
