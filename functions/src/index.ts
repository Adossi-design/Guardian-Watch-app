import * as admin from "firebase-admin";
import { onDocumentUpdated } from "firebase-functions/v2/firestore";
import { onSchedule } from "firebase-functions/v2/scheduler";

admin.initializeApp();

const db = admin.firestore();
const messaging = admin.messaging();

// ── Helpers ───────────────────────────────────────────────────────────────────

async function getMonitorTokens(householdId: string): Promise<string[]> {
  const snap = await db
    .collection("users")
    .where("householdId", "==", householdId)
    .where("role", "in", ["monitor", "admin"])
    .get();

  const tokens: string[] = [];
  snap.forEach((doc) => {
    const fcmToken: string | undefined = doc.data().fcmToken;
    if (fcmToken) tokens.push(fcmToken);
  });
  return tokens;
}

async function sendMulticast(
  tokens: string[],
  title: string,
  body: string,
  data: Record<string, string>
): Promise<void> {
  if (tokens.length === 0) return;

  // FCM v1 sendEachForMulticast supports up to 500 tokens per call
  const chunks: string[][] = [];
  for (let i = 0; i < tokens.length; i += 500) {
    chunks.push(tokens.slice(i, i + 500));
  }

  await Promise.all(
    chunks.map((chunk) =>
      messaging.sendEachForMulticast({
        tokens: chunk,
        notification: { title, body },
        data,
        android: {
          priority: "high",
          notification: { channelId: "guardian_emergency" },
        },
        apns: {
          payload: {
            aps: {
              sound: "default",
              "interruption-level": "critical",
            },
          },
        },
      })
    )
  );
}

// ── Trigger: status flips to 'active' ─────────────────────────────────────────

export const onEmergencyActivated = onDocumentUpdated(
  "emergency_incidents/{incidentId}",
  async (event) => {
    const before = event.data?.before.data();
    const after = event.data?.after.data();
    if (!before || !after) return;

    const wasActive = before.status === "active";
    const isNowActive = after.status === "active";
    if (wasActive || !isNowActive) return; // only fire on the transition

    const { householdId, userName, triggerType, id } = after as {
      householdId: string;
      userName: string;
      triggerType: string;
      id: string;
    };

    const tokens = await getMonitorTokens(householdId);
    const name = userName ?? "Guardian";
    const trigger = triggerType ?? "manual";

    await sendMulticast(
      tokens,
      "🚨 Emergency activated",
      `${name} has triggered an emergency (${trigger}). Tap to respond.`,
      { incidentId: id, type: "emergency_active" }
    );

    // Record first notification count
    await event.data!.after.ref.update({ notificationsSentCount: tokens.length });
  }
);

// ── Escalation: re-notify at T+60 s, T+120 s, T+300 s if unacknowledged ──────
// Implemented as a scheduled function that runs every minute and checks for
// active incidents that have not been acknowledged and are past each threshold.

export const escalateUnacknowledgedEmergencies = onSchedule(
  "every 1 minutes",
  async () => {
    const now = admin.firestore.Timestamp.now();
    const nowMs = now.toMillis();

    const snap = await db
      .collection("emergency_incidents")
      .where("status", "==", "active")
      .where("acknowledgedAt", "==", null)
      .get();

    await Promise.all(
      snap.docs.map(async (doc) => {
        const data = doc.data();
        const startedAt: admin.firestore.Timestamp = data.startedAt;
        const elapsedMs = nowMs - startedAt.toMillis();
        const lastEscalation: number = data.lastEscalationMs ?? 0;

        const thresholds = [60_000, 120_000, 300_000];
        const due = thresholds.find(
          (t) => elapsedMs >= t && lastEscalation < t
        );
        if (due === undefined) return;

        const tokens = await getMonitorTokens(data.householdId);
        const name: string = data.userName ?? "Guardian";
        const minutes = Math.round(due / 60_000);

        await sendMulticast(
          tokens,
          "🚨 Emergency — still unacknowledged",
          `${name}'s emergency has been active for ${minutes} min with no response.`,
          { incidentId: doc.id, type: "emergency_escalation" }
        );

        await doc.ref.update({ lastEscalationMs: due });
      })
    );
  }
);
