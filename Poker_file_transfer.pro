
pro poker_file_transfer
common pkr_xfer, xfer_tstamp

;    if n_elements(xfer_tstamp) eq 0 then xfer_tstamp = 'unknown'
;    jsnow   = dt_tm_tojs(systime())
;    tstamp  = dt_tm_mk(js2jd(0d)+1, jsnow, format='Y$ doy$ h$')
;---Only record tstamp to the precision of "tens of hours" column. So at most well retry every 10 hours:
;    tstamp  = strmid(tstamp, 0, strlen(tstamp)-1)

;    if tstamp ne xfer_tstamp then begin
;       spawn, 'psexec \\137.229.27.251  -u conde -p davros -i -d "c:\program files\itt\idl64\bin\bin.x86\idlde" @sdi3k_batch_autorun.pro'
;       xfer_tstamp = tstamp
;    endif

    if n_elements(xfer_tstamp) eq 0 then xfer_tstamp = 0d
    jsnow   = dt_tm_tojs(systime())

    if jsnow - xfer_tstamp gt 12d*3600d then begin
       spawn, 'psexec \\137.229.27.251  -u conde -p davros -i -d "c:\program files\itt\idl64\bin\bin.x86\idlde" @sdi3k_batch_autorun.pro'
       xfer_tstamp = jsnow
    endif

end