(*
 * Copyright (C) 2006-2007 XenSource Ltd.
 * Copyright (C) 2008      Citrix Ltd.
 * Author Vincent Hanquez <vincent.hanquez@eu.citrix.com>
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU Lesser General Public License as published
 * by the Free Software Foundation; version 2.1 only. with the special
 * exception on linking described in file LICENSE.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU Lesser General Public License for more details.
 *)

(** *)
type domid = int

(* ** xenctrl.h ** *)

type vcpuinfo =
{
	online: bool;
	blocked: bool;
	running: bool;
	cputime: int64;
	cpumap: int32;
}

type xen_arm_arch_domainconfig =
{
	gic_version: int;
	nr_spis: int;
	clock_frequency: int32;
}

type x86_arch_emulation_flags =
	| X86_EMU_LAPIC
	| X86_EMU_HPET
	| X86_EMU_PM
	| X86_EMU_RTC
	| X86_EMU_IOAPIC
	| X86_EMU_PIC
	| X86_EMU_VGA
	| X86_EMU_IOMMU
	| X86_EMU_PIT
	| X86_EMU_USE_PIRQ
	| X86_EMU_VPCI

type xen_x86_arch_domainconfig =
{
	emulation_flags: x86_arch_emulation_flags list;
}

type arch_domainconfig =
	| ARM of xen_arm_arch_domainconfig
	| X86 of xen_x86_arch_domainconfig

type domain_create_flag =
  | CDF_HVM
  | CDF_HAP
  | CDF_S3_INTEGRITY
  | CDF_OOS_OFF
  | CDF_XS_DOMAIN
  | CDF_IOMMU

type domain_create_iommu_opts =
  | IOMMU_NO_SHAREPT


type domctl_create_config =
{
	ssidref: int32;
	handle: string;
	flags: domain_create_flag list;
	iommu_opts: domain_create_iommu_opts list;
	max_vcpus: int;
	max_evtchn_port: int;
	max_grant_frames: int;
	max_maptrack_frames: int;
	arch: arch_domainconfig;
}

type runstateinfo = {
  state : int32;
  missed_changes: int32;
  state_entry_time : int64;
  time0 : int64;
  time1 : int64;
  time2 : int64;
  time3 : int64;
  time4 : int64;
  time5 : int64;
}

type domaininfo =
{
	domid             : domid;
	dying             : bool;
	shutdown          : bool;
	paused            : bool;
	blocked           : bool;
	running           : bool;
	hvm_guest         : bool;
	shutdown_code     : int;
	total_memory_pages: nativeint;
	max_memory_pages  : nativeint;
	shared_info_frame : int64;
	cpu_time          : int64;
	nr_online_vcpus   : int;
	max_vcpu_id       : int;
	ssidref           : int32;
	handle            : int array;
	arch_config       : arch_domainconfig;
}

type sched_control =
{
	weight : int;
	cap    : int;
}

type physinfo_cap_flag =
	| CAP_HVM
	| CAP_PV
	| CAP_DirectIO
	| CAP_HAP
	| CAP_Shadow

type physinfo =
{
	threads_per_core : int;
	cores_per_socket : int;
	nr_cpus          : int;
	max_node_id      : int;
	cpu_khz          : int;
	total_pages      : nativeint;
	free_pages       : nativeint;
	scrub_pages      : nativeint;
	(* XXX hw_cap *)
	capabilities     : physinfo_cap_flag list;
	max_nr_cpus      : int;
}

type version =
{
	major : int;
	minor : int;
	extra : string;
}


type compile_info =
{
	compiler : string;
	compile_by : string;
	compile_domain : string;
	compile_date : string;
}

type shutdown_reason = Poweroff | Reboot | Suspend | Crash | Watchdog | Soft_reset

exception Error of string

type handle

external interface_open: unit -> handle = "mock1"
external interface_close: handle -> unit = "mock1"

let handle = ref None

let get_handle () = !handle

let close_handle () =
	match !handle with
	| Some h -> handle := None; interface_close h
	| None -> ()

let with_intf f =
	match !handle with
	| Some h -> f h
	| None ->
		let h =
			try interface_open () with
			| e ->
				let msg = Printexc.to_string e in
				failwith ("failed to open xenctrl: "^msg)
		in
		handle := Some h;
		f h

external domain_create: handle -> domctl_create_config -> domid
       = "mock1"

external domain_sethandle: handle -> domid -> string -> unit
       = "mock1"

external domain_max_vcpus: handle -> domid -> int -> unit
       = "mock1"

external domain_pause: handle -> domid -> unit = "mock1"
external domain_unpause: handle -> domid -> unit = "mock1"
external domain_resume_fast: handle -> domid -> unit = "mock1"
external domain_destroy: handle -> domid -> unit = "mock1"

external domain_shutdown: handle -> domid -> shutdown_reason -> unit
       = "mock1"

external _domain_getinfolist: handle -> domid -> int -> domaininfo list
       = "mock1"

let domain_getinfolist handle first_domain =
	let nb = 2 in
	let last_domid l = (List.hd l).domid + 1 in
	let rec __getlist from =
		let l = _domain_getinfolist handle from nb in
		(if List.length l = nb then __getlist (last_domid l) else []) @ l
		in
	List.rev (__getlist first_domain)

external domain_getinfo: handle -> domid -> domaininfo= "mock1"

external domain_get_vcpuinfo: handle -> int -> int -> vcpuinfo
       = "mock1"
external domain_get_runstate_info : handle -> int -> runstateinfo
  = "mock1"

external domain_ioport_permission: handle -> domid -> int -> int -> bool -> unit
       = "mock1"
external domain_iomem_permission: handle -> domid -> nativeint -> nativeint -> bool -> unit
       = "mock1"
external domain_irq_permission: handle -> domid -> int -> bool -> unit
       = "mock1"

external vcpu_affinity_set: handle -> domid -> int -> bool array -> unit
       = "mock1"
external vcpu_affinity_get: handle -> domid -> int -> bool array
       = "mock1"

external vcpu_context_get: handle -> domid -> int -> string
       = "mock1"

external sched_id: handle -> int = "mock1"

external sched_credit_domain_set: handle -> domid -> sched_control -> unit
       = "mock1"
external sched_credit_domain_get: handle -> domid -> sched_control
       = "mock1"

external shadow_allocation_set: handle -> domid -> int -> unit
       = "mock1"
external shadow_allocation_get: handle -> domid -> int
       = "mock1"

external evtchn_alloc_unbound: handle -> domid -> domid -> int
       = "mock1"
external evtchn_reset: handle -> domid -> unit = "mock1"

external readconsolering: handle -> string = "mock1"

external send_debug_keys: handle -> string -> unit = "mock1"
external physinfo: handle -> physinfo = "mock1"
external pcpu_info: handle -> int -> int64 array = "mock1"

external domain_setmaxmem: handle -> domid -> int64 -> unit
       = "mock1"
external domain_set_memmap_limit: handle -> domid -> int64 -> unit
       = "mock1"
external domain_memory_increase_reservation: handle -> domid -> int64 -> unit
       = "mock1"

external domain_set_machine_address_size: handle -> domid -> int -> unit
       = "mock1"
external domain_get_machine_address_size: handle -> domid -> int
       = "mock1"

external domain_cpuid_set: handle -> domid -> (int64 * (int64 option))
                        -> string option array
                        -> string option array
       = "mock1"
external domain_cpuid_apply_policy: handle -> domid -> unit
       = "mock1"

external map_foreign_range: handle -> domid -> int
                         -> nativeint -> Xenmmap.mmap_interface
       = "mock1"

external domain_assign_device: handle -> domid -> (int * int * int * int) -> unit
       = "mock1"
external domain_deassign_device: handle -> domid -> (int * int * int * int) -> unit
       = "mock1"
external domain_test_assign_device: handle -> domid -> (int * int * int * int) -> bool
       = "mock1"

(** check if some hvm domain got pv driver or not *)
external hvm_check_pvdriver: handle -> domid -> bool
       = "mock1"

external version: handle -> version = "mock1"
external version_compile_info: handle -> compile_info
       = "mock1"
external version_changeset: handle -> string = "mock1"
external version_capabilities: handle -> string = "mock1"

type featureset_index = Featureset_raw | Featureset_host | Featureset_pv | Featureset_hvm | Featureset_pv_max | Featureset_hvm_max
external get_cpu_featureset : handle -> featureset_index -> int64 array = "mock1"
external get_featureset : handle -> featureset_index -> int64 array = "mock1"

external upgrade_oldstyle_featuremask: handle -> int64 array -> bool -> int64 array = "mock1"
external oldstyle_featuremask: handle -> int64 array = "mock1"

external watchdog : handle -> int -> int32 -> int
  = "mock1"

(* ** Misc ** *)

(**
   Convert the given number of pages to an amount in KiB, rounded up.
 *)
external pages_to_kib : int64 -> int64 = "mock1"
let pages_to_mib pages = Int64.div (pages_to_kib pages) 1024L

let _ = Callback.register_exception "xc.error" (Error "register_callback")
