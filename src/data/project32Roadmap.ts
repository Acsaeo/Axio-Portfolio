export type Project32Status =
  | "COMPLETE"
  | "ACTIVE"
  | "BLOCKED"
  | "PENDING"
  | "NOT STARTED";

export type Project32Milestone = {
  id: string;
  label: string;
  status: Project32Status;
  evidence?: string;
};

export type Project32Phase = {
  id: string;
  title: string;
  status: Project32Status;
  open: boolean;
  items: Project32Milestone[];
};

export const project32Phases: Project32Phase[] = [
  {
    id: "PRE-PHASE A",
    title: "Android and guest-runtime foundation",
    status: "COMPLETE",
    open: true,
    items: [
      {
        id: "P0.1",
        label: "Android project builds and installs",
        status: "COMPLETE",
      },
      {
        id: "P0.2",
        label: "APK extraction and ELF loading",
        status: "COMPLETE",
      },
      {
        id: "P0.3",
        label: "Guest memory mapping and basic import stubs",
        status: "COMPLETE",
      },
      {
        id: "P0.4",
        label: "JNI environment and JNI_OnLoad execution",
        status: "COMPLETE",
      },
      {
        id: "P0.5",
        label: "Unity native-method discovery",
        status: "COMPLETE",
      },
      {
        id: "P0.6",
        label: "EGL/graphics host scaffolding",
        status: "COMPLETE",
      },
      {
        id: "P0.7",
        label: "Guest execution history and trap provenance tooling",
        status: "COMPLETE",
      },
    ],
  },
  {
    id: "PHASE A",
    title: "Guest-code integrity and constructor-flow safety",
    status: "COMPLETE",
    open: true,
    items: [
      {
        id: "A1.1",
        label: "Disable fixed-PC guest intercepts",
        status: "COMPLETE",
        evidence: "Commit 1d971b5",
      },
      {
        id: "A1.2",
        label: "Remove constructor-flow corruption",
        status: "COMPLETE",
        evidence:
          "0x4020e1c0 no longer bypasses a live function epilogue",
      },
    ],
  },
  {
    id: "PHASE B",
    title: "Runtime provenance and controlled execution",
    status: "ACTIVE",
    open: true,
    items: [
      {
        id: "B1.1",
        label: "Guest fault and execution tracing",
        status: "COMPLETE",
        evidence: "Historical B0 commits",
      },
      {
        id: "B1.2",
        label: "Controlled guest function runner",
        status: "COMPLETE",
        evidence: "Commit f4a57a0",
      },
      {
        id: "B1.3",
        label: "VFP capability enablement",
        status: "COMPLETE",
        evidence: "Commit ef650c9",
      },
      {
        id: "B1.4",
        label: "VFP stack integrity",
        status: "COMPLETE",
        evidence: "VPUSH/VPOP self-test passed",
      },
      {
        id: "B1.5",
        label: "Stop-thunk diagnosis",
        status: "COMPLETE",
        evidence: "Mismatch identified",
      },
      {
        id: "B1.6",
        label: "Stop-thunk name repair",
        status: "COMPLETE",
        evidence: "Commit 9fc6a95",
      },
      {
        id: "B1.7",
        label: "Fetch faults fail fast",
        status: "COMPLETE",
        evidence: "Commit 9fc6a95",
      },
      {
        id: "B2.1",
        label: "Constructor index 0",
        status: "COMPLETE",
        evidence: "Returns at PC=0xdead01c0 through P32_STOP",
      },
      {
        id: "B2.2",
        label: "Constructor prefix beyond index 0",
        status: "COMPLETE",
        evidence: "Constructor prefix beyond index 0 executed successfully",
      },
    ],
  },
  {
    id: "PHASE C",
    title: "nativeRecreateGfxState provenance",
    status: "ACTIVE",
    open: true,
    items: [
      {
        id: "C1.1",
        label: "Isolate nativeRecreateGfxState fault",
        status: "COMPLETE",
        evidence: "Raw fetch PC=0x000485bc, LR=0x4046a704",
      },
      {
        id: "C1.2",
        label: "Decode caller",
        status: "COMPLETE",
        evidence: "0x4046a700 is BL 0x40049518",
      },
      {
        id: "C1.3",
        label: "Verify mapped destination",
        status: "COMPLETE",
        evidence: "0x400485bc maps to ARM PUSH {lr}",
      },
      {
        id: "C2.1",
        label: "Audit dynamic relocation parser",
        status: "COMPLETE",
        evidence: "Current parser converts dynamic VAs to file offsets",
      },
      {
        id: "C3.1",
        label: "Decode live veneer and GOT slot",
        status: "COMPLETE",
        evidence:
          "GOT slot 0x40f51b74 = raw 0x000485bc; rebased target 0x400485bc",
      },
      {
        id: "C3.2",
        label: "Attribute raw fetch to the true guest invocation",
        status: "COMPLETE",
        evidence:
          "nativeResume healthy via P32_STOP (PC=0xdead01c0, status=0); nativeRender owns raw fetch (guest-fetch-fault phase=nativeRender, addr=0x000485bc, lr=0x4046a704)",
      },
      {
        id: "C3.3",
        label: "Classify slot 0x40f51b74 ownership",
        status: "COMPLETE",
        evidence:
          "libunity.so DT_JMPREL R_ARM_JUMP_SLOT 'syscall' unresolved; slot runtime-written to 0x000485bc (runtime-written-slot-or-other-source)",
      },
      {
        id: "C3.4",
        label: "Apply narrow slot-scoped repair",
        status: "COMPLETE",
        evidence:
          "c5-slot-repair wrote 0x400485bc to slot 0x40f51b74; zero guest-fetch-fault; nativeRender direct-end status=0 (UC_ERR_OK), run-end pc=0x00000000; nativeResume via P32_STOP pc=0xdead01c0 (evidence c5-device-evidence-20260908T234120Z.txt)",
      },
      {
        id: "C4.1",
        label: "nativeRecreateGfxState returns through P32_STOP",
        status: "PENDING",
        evidence: "Phase C completion criterion",
      },
    ],
  },
  {
    id: "PHASE D",
    title: "Controlled native resume",
    status: "NOT STARTED",
    open: false,
    items: [
      {
        id: "D1.1",
        label: "Execute nativeResume under the controlled runner",
        status: "NOT STARTED",
      },
      {
        id: "D1.2",
        label: "Validate controlled ARM and Thumb control flow",
        status: "NOT STARTED",
      },
      {
        id: "D1.3",
        label: "Validate VFP execution on the resume path",
        status: "NOT STARTED",
      },
      {
        id: "D1.4",
        label: "Classify the next runtime dependency from evidence",
        status: "NOT STARTED",
      },
      {
        id: "D1.5",
        label: "Stabilize controlled native resume return behavior",
        status: "NOT STARTED",
      },
      {
        id: "D1.6",
        label: "Record runtime telemetry and fault provenance",
        status: "NOT STARTED",
      },
    ],
  },
  {
    id: "PHASE E",
    title: "First safe native render and host EGL output",
    status: "NOT STARTED",
    open: false,
    items: [
      {
        id: "E1.1",
        label: "Execute the first safe nativeRender path",
        status: "NOT STARTED",
      },
      {
        id: "E1.2",
        label: "Retain host EGL output through the guest path",
        status: "NOT STARTED",
      },
      {
        id: "E1.3",
        label: "Validate guest surface and window handles",
        status: "NOT STARTED",
      },
      {
        id: "E1.4",
        label: "Validate guest EGL context and surface lifecycle",
        status: "NOT STARTED",
      },
      {
        id: "E1.5",
        label: "Bridge first GLES resource and state operations",
        status: "NOT STARTED",
      },
      {
        id: "E1.6",
        label: "Present a stable native-rendered frame",
        status: "NOT STARTED",
      },
    ],
  },
  {
    id: "PHASE F",
    title: "Runtime stabilization",
    status: "NOT STARTED",
    open: false,
    items: [
      {
        id: "F1.1",
        label: "Expand constructor prefix beyond the initial validated range",
        status: "NOT STARTED",
      },
      {
        id: "F1.2",
        label: "Stabilize guest threads and scheduling policy",
        status: "NOT STARTED",
      },
      {
        id: "F1.3",
        label: "Stabilize proven guest import behavior",
        status: "NOT STARTED",
      },
      {
        id: "F1.4",
        label: "Stabilize guest filesystem and runtime paths",
        status: "NOT STARTED",
      },
      {
        id: "F1.5",
        label: "Stabilize input, timing, and lifecycle behavior",
        status: "NOT STARTED",
      },
      {
        id: "F1.6",
        label: "Classify and remove temporary diagnostics",
        status: "NOT STARTED",
      },
      {
        id: "F1.7",
        label: "Remove generic runtime assumptions",
        status: "NOT STARTED",
      },
      {
        id: "F1.8",
        label: "Consolidate evidence-backed compatibility rules",
        status: "NOT STARTED",
      },
      {
        id: "F1.9",
        label: "Run repeated runtime regression sessions",
        status: "NOT STARTED",
      },
      {
        id: "F1.10",
        label: "Prepare a stable compatibility profile",
        status: "NOT STARTED",
      },
    ],
  },
  {
    id: "PHASE G",
    title: "Cleanup and release-quality validation",
    status: "NOT STARTED",
    open: false,
    items: [
      {
        id: "G1.1",
        label: "Cleanup temporary diagnostics and dead paths",
        status: "NOT STARTED",
      },
      {
        id: "G1.2",
        label: "Add deterministic regression runs",
        status: "NOT STARTED",
      },
      {
        id: "G1.3",
        label: "Validate repeated install and launch behavior",
        status: "NOT STARTED",
      },
      {
        id: "G1.4",
        label: "Validate device-specific compatibility behavior",
        status: "NOT STARTED",
      },
      {
        id: "G1.5",
        label: "Document known limitations and compatibility rules",
        status: "NOT STARTED",
      },
      {
        id: "G1.6",
        label: "Complete release-quality validation",
        status: "NOT STARTED",
      },
    ],
  },
];

export const project32Milestones = project32Phases.flatMap(
  (phase) => phase.items
);

export const project32CompletedCount = project32Milestones.filter(
  (milestone) => milestone.status === "COMPLETE"
).length;

export const project32TotalCount = project32Milestones.length;

export const project32Progress = Math.round(
  (project32CompletedCount / project32TotalCount) * 100
);
