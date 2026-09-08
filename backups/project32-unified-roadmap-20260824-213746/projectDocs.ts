export const projectDocs = {
  lovetap: {
    title: "LoveTap",
    status: "Active",
    progress: 78,
    eyebrow: "ANDROID APP PROJECT",
    intro:
      "A focused app experience shaped around simple, human interaction and release-ready polish.",
    capabilities: [
      "A complete user-facing product direction",
      "A refined interaction flow built around clarity and ease",
      "A defined release scope and public-facing identity",
      "A project foundation ready for final quality work",
    ],
    milestone:
      "Resolve the remaining release-blocking issues and prepare the first public release.",
  },

  project32droid: {
    title: "Project32Droid",
    status: "Active",
    progress: project32Progress(),
    eyebrow: "ANDROID COMPATIBILITY PROJECT",
    intro:
      "A focused project exploring how legacy 32-bit Android experiences can remain accessible on modern devices.",
    capabilities: [
      "A clear compatibility-focused product direction",
      "A structured project foundation for legacy Android experiences",
      "A dedicated environment for validating target applications",
      "A practical roadmap for continued compatibility work",
    ],
    milestone:
      "Complete the remaining emulator work and stabilize the target runtime experience.",
  },

  "cat-axiom": {
    title: "Cat / Axiom",
    status: "Planning",
    progress: 20,
    eyebrow: "PERSONAL AI COMPANION",
    intro:
      "A phone-first personal companion intended to feel present, helpful, and naturally integrated into everyday life.",
    capabilities: [
      "A defined vision for a personal AI companion",
      "A phone-first direction for daily use",
      "A voice-centered interaction goal",
      "A place inside the wider Ax-Homelab ecosystem",
    ],
    milestone:
      "Build the first phone-focused companion experience and establish its natural voice foundation.",
  },
} as const;

export function project32Progress(): number {
  const completed = [
    // Pre-Phase A
    "Android project builds and installs",
    "APK extraction and ELF loading",
    "Guest memory mapping and basic import stubs",
    "JNI environment and JNI_OnLoad execution",
    "Unity native-method discovery",
    "EGL/graphics host scaffolding",
    "Guest execution history and trap provenance tooling",

    // Phase A
    "A1.1",
    "A1.2",

    // Phase B
    "B0",
    "B1.1",
    "B1.2",
    "B1.3",
    "B1.4",
    "B1.5",
    "B1.6",
    "B1.7",
    "B1.8",

    // Phase C
    "C0",
    "C1",
    "C2",
    "C3",
  ];

  const total = 25;

  return Math.round((completed.length / total) * 100);
}
