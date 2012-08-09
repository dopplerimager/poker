
;\\ CLEANUP ROUTINES
pro PokerFlat_cleanup, misc, console

	comms_wrapper, misc.port_map.filter.number, misc.dll_name, type='moxa', /close, errcode=errcode
	console->log, 'Close Filter Port: ' + string(errcode, f='(i0)'), 'InstrumentSpecific', /display

end

;\\ MIRROR ROUTINES
pro PokerFlat_mirror,  drive_to_pos = drive_to_pos, $
				  home_motor = home_motor, $
				  read_pos = read_pos,  $
				  misc, console

	if keyword_set(drive_to_pos) then begin
		comms_wrapper, 3, misc.dll_name, type='dio', /dio_write8, data = drive_to_pos, errcode=errcode
		wait, 0.5
	endif

	if keyword_set(read_pos) then begin
		read_pos = -1
	endif
end



;\\ CALIBRATION SWITCH ROUTINES
pro PokerFlat_switch, source, $
				  	  misc, console




end



;\\ FILTER SELECT ROUTINES
pro PokerFlat_filter, filter_number, $
					  log_path = log_path, $
				  	  misc, console

	if keyword_set(log_path) then cd, log_path, current = old_dir

	;\\ Stop the camera while we move the filter:
	   	res = call_external(misc.dll_name, 'uAbortAcquisition')

	;\\ Notify that we are changing the filter
		base = widget_base(col=1, group=misc.console_id, /floating)
		info = widget_label(base, value='Selecting Filter ' + string(filter_number, f='(i1)'), font='Ariel*20*Bold')
		widget_control, /realize, base

	;\\ At every call, ensure the serial port is in the correct mode:
		port = misc.port_map.filter.number
		dll = misc.dll_name
		tx = string(13B)
		comms_wrapper, port, dll, type = 'moxa', moxa_setbaud=13

		cmd = string(filter_number, format='(i1)') + ' MV' + tx
		comms_wrapper, port, dll, type = 'moxa', /write, data = cmd

		fin = 0
		while fin eq 0 do begin
			comms_wrapper, port, dll, type='moxa', /read, data=in
			in = strsplit(in, tx, /extract)
			match = where(strmid(in, 0, 2) eq 'W1', nmatch)
			fin = nmatch
			wait, 0.001
		endwhile

		;\\ Query new status
		comms_wrapper, port, dll, type='moxa', /write, data='+'+tx
		wait, 1
		comms_wrapper, port, dll, type='moxa', /read, data=in

		in = strsplit(in, tx, /extract)
		new_filter = fix((strsplit(in[2], '=', /extract))[1])

		if new_filter ne filter_number then begin
			;\\ DO WHAT HERE??
			openw, hnd, log.log_directory + 'Filter_Faults.txt', /append, /get
			printf, hnd, systime(/ut) + ' > Requested: ' + string(filter_number, f='(i0)') + $
					', Got: ' + string(new_filter, f='(i0)')
			free_lun, hnd
		endif

	;\\ CLose the message box
		if widget_info(base, /valid) eq 1 then widget_control, base, /destroy

	;\\ Restart the camera
		res = call_external(misc.dll_name, 'uStartAcquisition')

	if keyword_set(log_path) then cd, old_dir
end





;\\ ETALON LEG ROUTINES
pro PokerFlat_etalon, dll, $
				  leg1_voltage, $
				  leg2_voltage, $
				  leg3_voltage, $
				  misc, console

		legid = 1L
		data = [(leg1_voltage and '300'xu)/256, leg1_voltage and 255us, legid+20, misc.motor_cur_pos]
		comms_wrapper, 0, misc.dll_name, type='dio', /dio_config, data = data
		data = [(leg1_voltage and '300'xu)/256, leg1_voltage and 255us, legid+4, misc.motor_cur_pos]
		comms_wrapper, 0, misc.dll_name, type='dio', /dio_writeall, data = data

		legid = 2L
		data = [(leg2_voltage and '300'xu)/256, leg2_voltage and 255us, legid+20, misc.motor_cur_pos]
		comms_wrapper, 0, misc.dll_name, type='dio', /dio_config, data = data
		data = [(leg2_voltage and '300'xu)/256, leg2_voltage and 255us, legid+4, misc.motor_cur_pos]
		comms_wrapper, 0, misc.dll_name, type='dio', /dio_writeall, data = data

		legid = 3L
		data = [(leg3_voltage and '300'xu)/256, leg3_voltage and 255us, legid+20, misc.motor_cur_pos]
		comms_wrapper, 0, misc.dll_name, type='dio', /dio_config, data = data
		data = [(leg3_voltage and '300'xu)/256, leg3_voltage and 255us, legid+4, misc.motor_cur_pos]
		comms_wrapper, 0, misc.dll_name, type='dio', /dio_writeall, data = data
end


;\\ IMAGE POST PROCESSING ROUTINES
pro PokerFlat_imageprocess, image

	image = 10*image
	smim = smooth(image, 41, /edge_truncate)
	image = (250 + image - min(smim(128:384, 128:384))) > 0
	image = rot(image, 180)

end

;\\ INITIALISATION ROUTINES
pro PokerFlat_initialise, misc, console

	console->log, '** Poker Flat SDI **', 'InstrumentSpecific', /display

	;\\ Set up the com ports
	comms_wrapper, misc.port_map.filter.number, misc.dll_name, type='moxa', /open, errcode=errcode, moxa_setbaud=13
	console->log, 'Open Filter Port: ' + string(errcode, f='(i0)'), 'InstrumentSpecific', /display

end

