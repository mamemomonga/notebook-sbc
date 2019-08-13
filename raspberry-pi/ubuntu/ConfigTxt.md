# config.txt のカスタマイズ

	$ sudo vim /boot/firmware/config.txt

	# ARM 64bit
	arm_64bit=1
	
	# device tree
	device_tree_address=0x03000000
	
	# Kernel
	kernel=kernel8.bin
	
	# i2c, spi
	dtparam=i2c_arm=off
	dtparam=spi=off
	
	# UART
	enable_uart=1
	
	# GPUメモリ
	gpu_mem=16
	
	# CPUオーバークロック
	# arm_freq=1300
	# over_voltage=5
	# gpu_freq=500
	
	# SDRAMオーバークロック
	# sdram_freq=500
	# sdram_schmoo=0x02000020
	# over_voltage_sdram_p=6
	# over_voltage_sdram_i=4
	# over_voltage_sdram_c=4

