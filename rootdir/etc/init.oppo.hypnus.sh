#!/vendor/bin/sh
#
#ifdef VENDOR_EDIT
#jie.cheng@swdp.shanghai, 2015/11/09, add init.oppo.hypnus.sh
enable=`getprop persist.sys.enable.hypnus`
complete=`getprop sys.boot_completed`
#persist_enable_logging=`getprop persist.sys.oppo.junklog`
persist_enable_logging=false
enable_logging=1

case "$persist_enable_logging" in
    "true")
        enable_logging=1
	;;
    "false")
        enable_logging=0
	;;
esac

if [ ! -n "$complete" ] ; then
        complete="0"
fi

case "$enable" in
    "1")

        #disable core_ctl
        echo 1 > /sys/devices/system/cpu/cpu0/core_ctl/disable
        echo 1 > /sys/devices/system/cpu/cpu4/core_ctl/disable

        n=0
        while [ n -lt 3 ]; do
                #load data folder module if it is exist
                if [ -f /data/hypnus/hypnus.ko ]; then
                        insmod /data/hypnus/hypnus.ko -f boot_completed=$complete
                else
                        insmod /system/lib/modules/hypnus.ko -f boot_completed=$complete
                fi

		if [ $? != 0 ];then
                        if [ -f /data/hypnus/hypnus.ko ]; then
                                insmod /data/hypnus/hypnus.ko -f
                        else
                                insmod /system/lib/modules/hypnus.ko -f
                        fi

	                if [ $? != 0 ];then
	                        n=$((n+1));
	                        echo "Error: insmod hypnus.ko failed, retry: n="$n > /dev/kmsg
	                else
	                        echo "Hypnus module insmod!" > /dev/kmsg
	                        break
	                fi
                else
                        echo "Hypnus module insmod!" > /dev/kmsg
                        break
                fi
        done
        chown system:system /sys/kernel/hypnus/scene_info
        chown system:system /sys/kernel/hypnus/action_info
        chown system:system /sys/kernel/hypnus/view_info
        chown system:system /sys/kernel/hypnus/notification_info
        chcon u:object_r:sysfs_hypnus:s0 /sys/kernel/hypnus/view_info
        echo $enable_logging > /sys/module/hypnus/parameters/enable_logging
        setprop persist.report.tid 2
        /system/bin/restorecon -RF /sys/kernel/hypnus
        ;;
esac

case "$enable" in
    "0")
        rmmod hypnus.ko
        # Bring up all cores online
        echo 1 > /sys/devices/system/cpu/cpu0/online
        echo 1 > /sys/devices/system/cpu/cpu1/online
        echo 1 > /sys/devices/system/cpu/cpu2/online
        echo 1 > /sys/devices/system/cpu/cpu3/online
        echo 1 > /sys/devices/system/cpu/cpu4/online
        echo 1 > /sys/devices/system/cpu/cpu5/online
        echo 1 > /sys/devices/system/cpu/cpu6/online
        echo 1 > /sys/devices/system/cpu/cpu7/online

        # Enable low power modes
        echo 0 > /sys/module/lpm_levels/parameters/sleep_disabled

        #governor settings
        echo 633600 > /sys/devices/system/cpu/cpu0/cpufreq/scaling_min_freq
        echo 1843200 > /sys/devices/system/cpu/cpu0/cpufreq/scaling_max_freq
        echo 1113600 > /sys/devices/system/cpu/cpu4/cpufreq/scaling_min_freq
        echo 2208000 > /sys/devices/system/cpu/cpu4/cpufreq/scaling_max_freq

        #enable core_ctl
        echo 0 > /sys/devices/system/cpu/cpu0/core_ctl/disable
        echo 0 > /sys/devices/system/cpu/cpu4/core_ctl/disable
        ;;
esac
#endif /* VENDOR_EDIT */
