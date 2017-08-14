open_hw_design ./timapulpemu_top.sysdef
generate_app -hw timapulpemu_top -os standalone -proc ps7_cortexa9_0 -app zynq_fsbl -compile -sw fsbl -dir ./fsbl
exit
