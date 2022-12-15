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

type domid = int
type vcpuinfo = {
  online : bool;
  blocked : bool;
  running : bool;
  cputime : int64;
  cpumap : int32;
}

type xen_arm_arch_domainconfig = {
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

type x86_arch_misc_flags =
  | X86_MSR_RELAXED

type xen_x86_arch_domainconfig = {
  emulation_flags: x86_arch_emulation_flags list;
  misc_flags: x86_arch_misc_flags list;
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
  | CDF_NESTED_VIRT
  | CDF_VPMU

type domain_create_iommu_opts =
  | IOMMU_NO_SHAREPT

type domctl_create_config = {
  ssidref: int32;
  handle: string;
  flags: domain_create_flag list;
  iommu_opts: domain_create_iommu_opts list;
  max_vcpus: int;
  max_evtchn_port: int;
  max_grant_frames: int;
  max_maptrack_frames: int;
  max_grant_version: int;
  cpupool_id: int32;
  arch: arch_domainconfig;
}

type domaininfo = {
  domid : domid;
  dying : bool;
  shutdown : bool;
  paused : bool;
  blocked : bool;
  running : bool;
  hvm_guest : bool;
  shutdown_code : int;
  total_memory_pages : nativeint;
  max_memory_pages : nativeint;
  shared_info_frame : int64;
  cpu_time : int64;
  nr_online_vcpus : int;
  max_vcpu_id : int;
  ssidref : int32;
  handle : int array;
  arch_config : arch_domainconfig;
}
type sched_control = { weight : int; cap : int; }
type physinfo_cap_flag =
  | CAP_HVM
  | CAP_PV
  | CAP_DirectIO
  | CAP_HAP
  | CAP_Shadow
  | CAP_IOMMU_HAP_PT_SHARE
  | CAP_Vmtrace
  | CAP_Vpmu
  | CAP_Gnttab_v1
  | CAP_Gnttab_v2

type arm_physinfo_cap_flag

type x86_physinfo_cap_flag

type arch_physinfo_cap_flags =
  | ARM of arm_physinfo_cap_flag list
  | X86 of x86_physinfo_cap_flag list

type physinfo = {
  threads_per_core : int;
  cores_per_socket : int;
  nr_cpus          : int;
  max_node_id      : int;
  cpu_khz          : int;
  total_pages      : nativeint;
  free_pages       : nativeint;
  scrub_pages      : nativeint;
  capabilities     : physinfo_cap_flag list;
  max_nr_cpus      : int; (** compile-time max possible number of nr_cpus *)
  arch_capabilities : arch_physinfo_cap_flags;
}
type version = { major : int; minor : int; extra : string; }
type compile_info = {
  compiler : string;
  compile_by : string;
  compile_domain : string;
  compile_date : string;
}
type shutdown_reason = Poweroff | Reboot | Suspend | Crash | Watchdog | Soft_reset
exception Error of string
type handle
val interface_open : unit -> handle
val interface_close : handle -> unit

(** [with_intf f] runs [f] with a global handle that is opened on demand
 * and kept open. Conceptually, a client should use either
 * interface_open and interface_close or with_intf although mixing both
 * is possible *)
val with_intf : (handle -> 'a) -> 'a
(** [get_handle] returns the global handle used by [with_intf] *)
val get_handle: unit -> handle option
(** [close handle] closes the handle maintained by [with_intf]. This
 * should only be closed before process exit. It must not be called from
 * a function called directly or indirectly by with_intf as this
 * would invalidate the handle that with_intf passes to its argument. *)
val close_handle: unit -> unit

val domain_create : handle -> domctl_create_config -> domid

val domain_sethandle : handle -> domid -> string -> unit
val domain_max_vcpus : handle -> domid -> int -> unit

val domain_pause : handle -> domid -> unit
val domain_unpause : handle -> domid -> unit
val domain_resume_fast : handle -> domid -> unit

val domain_destroy : handle -> domid -> unit
val domain_shutdown : handle -> domid -> shutdown_reason -> unit

val _domain_getinfolist : handle -> domid -> int -> domaininfo list

val domain_getinfolist : handle -> domid -> domaininfo list
val domain_getinfo : handle -> domid -> domaininfo

val domain_get_vcpuinfo : handle -> int -> int -> vcpuinfo

val domain_get_runstate_info : handle -> int -> runstateinfo

val domain_ioport_permission: handle -> domid -> int -> int -> bool -> unit

val domain_iomem_permission: handle -> domid -> nativeint -> nativeint -> bool -> unit

val domain_irq_permission: handle -> domid -> int -> bool -> unit

val vcpu_affinity_set : handle -> domid -> int -> bool array -> unit

val vcpu_affinity_get : handle -> domid -> int -> bool array

val vcpu_context_get : handle -> domid -> int -> string

val sched_id : handle -> int
val sched_credit_domain_set : handle -> domid -> sched_control -> unit

val sched_credit_domain_get : handle -> domid -> sched_control

val shadow_allocation_set : handle -> domid -> int -> unit

val shadow_allocation_get : handle -> domid -> int

val evtchn_alloc_unbound : handle -> domid -> domid -> int

val evtchn_reset : handle -> domid -> unit
val readconsolering : handle -> string
val send_debug_keys : handle -> string -> unit
val physinfo : handle -> physinfo
val pcpu_info: handle -> int -> int64 array
val domain_setmaxmem : handle -> domid -> int64 -> unit

val domain_set_memmap_limit : handle -> domid -> int64 -> unit

val domain_memory_increase_reservation :
  handle -> domid -> int64 -> unit

val map_foreign_range :
  handle -> domid -> int -> nativeint -> Xenmmap.mmap_interface


val domain_assign_device: handle -> domid -> (int * int * int * int) -> unit

val domain_deassign_device: handle -> domid -> (int * int * int * int) -> unit

val domain_test_assign_device: handle -> domid -> (int * int * int * int) -> bool


val hvm_check_pvdriver : handle -> domid -> bool

val version : handle -> version
val version_compile_info : handle -> compile_info

val version_changeset : handle -> string
val version_capabilities : handle -> string


type featureset_index = Featureset_raw | Featureset_host | Featureset_pv | Featureset_hvm | Featureset_pv_max | Featureset_hvm_max
val get_cpu_featureset : handle -> featureset_index -> int64 array
val get_featureset : handle -> featureset_index -> int64 array

val upgrade_oldstyle_featuremask: handle -> int64 array -> bool -> int64 array
val oldstyle_featuremask: handle -> int64 array

val pages_to_kib : int64 -> int64
val pages_to_mib : int64 -> int64
val watchdog : handle -> int -> int32 -> int


val domain_set_machine_address_size: handle -> domid -> int -> unit

val domain_get_machine_address_size: handle -> domid -> int


val domain_cpuid_set: handle -> domid -> (int64 * (int64 option))
                        -> string option array
                        -> string option array

val domain_cpuid_apply_policy: handle -> domid -> unit

