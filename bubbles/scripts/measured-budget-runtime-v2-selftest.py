#!/usr/bin/env python3
"""Adversarial IMP-055 MBE-1/2 typed-graph selftest."""
from __future__ import annotations

import importlib.util
import argparse
import contextlib
import hashlib
import io
import json
import shutil
import subprocess
import sys
import tempfile
import unittest
from pathlib import Path
from types import SimpleNamespace
from typing import Any, Callable
from unittest import mock

from jsonschema import Draft7Validator

HERE = Path(__file__).resolve().parent
SPEC = importlib.util.spec_from_file_location("mbe", HERE / "measured-budget-runtime.py")
if SPEC is None or SPEC.loader is None:
    raise RuntimeError("MBE runtime unavailable")
mbe = importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(mbe)

T = [f"2026-08-01T00:00:{second:02d}.000Z" for second in range(30)]
EXP = "2026-08-01T00:10:00.000Z"
D = [mbe.ecf.typed_digest("selftest", {"value": value}) for value in range(12)]


def complete_store_bytes(root: str) -> dict[str, bytes]:
    return {str(path.relative_to(root)): path.read_bytes()
            for path in sorted(Path(root).rglob("*")) if path.is_file()}


def amount(name: str, value: int, currency: str = "USD", scale: int = 2) -> dict[str, Any]:
    definition = mbe.DIMENSION_DEFINITIONS[name]
    return {"dimension": name, "amount": value, "unit": definition["unit"],
            "currency": currency if name == "monetaryMinorUnits" else None,
            "scale": scale if name == "monetaryMinorUnits" else None}


def policies(configured: dict[str, int]) -> list[dict[str, Any]]:
    return [{"dimension": name, "state": "configured" if name in configured else "unconfigured",
             "limit": configured.get(name), "unit": mbe.DIMENSION_DEFINITIONS[name]["unit"],
             "currency": "USD" if name == "monetaryMinorUnits" and name in configured else None,
             "scale": 2 if name == "monetaryMinorUnits" and name in configured else None}
            for name in mbe.DIMENSIONS]


class RuntimeCase(unittest.TestCase):
    def setUp(self) -> None:
        self.temp = tempfile.TemporaryDirectory(prefix="mbe-v2-")
        self.runtime = mbe.MeasuredBudgetRuntime(self.temp.name)

    def tearDown(self) -> None:
        self.temp.cleanup()

    def expect(self, code: str, call: Callable[[], Any]) -> None:
        with self.assertRaises(mbe.MbeError) as caught:
            call()
        self.assertEqual(caught.exception.code, code)

    def identity(self, session: str = "session:one", proof: str = D[1]) -> dict[str, Any]:
        record = {"contractType": "host-session-identity", "schemaVersion": 2,
                  "sessionIdentityId": session, "adapterId": "adapter:selftest",
                  "hostInstanceId": "host:one", "workspaceIdentity": "workspace:one",
                  "hostSessionId": session.replace(":", "."), "artifactSessionId": f"artifact:{session.split(':')[-1]}",
                  "repositoryDecisionId": "rb:selftest.7", "hostSchemaId": "selftest-v2",
                  "proofDigest": proof, "startedAt": T[0]}
        return self.runtime.usage_record(record=record)

    def open_budget(self, configured: dict[str, int], goal: str = "goal:selftest") -> dict[str, Any]:
        return self.runtime.budget_open(goal_id=goal, policy_digest=D[0], rollout_posture="reference-enforce",
                                        dimensions=policies(configured), opened_at=T[0], goal_deadline_at=EXP,
                                        max_occurrences=2, max_attempts_per_occurrence=2)

    def epoch(self, budget: dict[str, Any], identity: dict[str, Any], sequence: int = 1,
              previous: dict[str, Any] | None = None, at_index: int = 1) -> dict[str, Any]:
        snapshot = self.runtime.budget_snapshot(budget_id=budget["budgetId"], at=T[at_index])
        previous_session = identity["sessionIdentityId"] if previous is None else previous["hostSessionIdentityId"]
        boundary = self.runtime.epoch_boundary(
            goal_id=budget["goalId"], from_epoch_id="epoch:none" if previous is None else previous["epochId"],
            to_epoch_class=mbe.EPOCH_CLASSES[sequence - 1], boundary_kind="initial-host-checkpoint" if previous is None else "new-session",
            previous_session_identity_id=previous_session, next_session_identity_id=identity["sessionIdentityId"],
            continuation_digest=D[2], budget_snapshot_id=snapshot["snapshotId"], host_proof_digest=identity["proofDigest"],
            observed_at=T[at_index + 1])
        verification = self.runtime.epoch_verify(boundary_id=boundary["boundaryId"], host_proof_digest=identity["proofDigest"], verified_at=T[at_index + 2])
        return self.runtime.epoch_open(goal_id=budget["goalId"], budget_id=budget["budgetId"], epoch_class=mbe.EPOCH_CLASSES[sequence - 1],
                                       sequence=sequence, host_session_identity_id=identity["sessionIdentityId"],
                                       opened_by_boundary_id=boundary["boundaryId"], epoch_verification_id=verification["epochVerificationId"],
                                       continuation_digest=D[2], opened_at=T[at_index + 3])

    def prepare(self, configured: dict[str, int] | None = None, occurrence: str = "occ:one", attempt: str = "att:one",
                action_digest: str = D[3], fact_expiry: str = EXP,
                action_authorized: bool = True) -> dict[str, Any]:
        configured = configured or {"modelRequestCount": 4}
        identity = self.identity()
        budget = self.open_budget(configured)
        epoch = self.epoch(budget, identity)
        intent = self.runtime.dispatch_intent(goal_id=budget["goalId"], budget_id=budget["budgetId"], epoch_id=epoch["epochId"],
            session_identity_id=identity["sessionIdentityId"], occurrence_id=occurrence, attempt_id=attempt, agent="bubbles.test",
            phase="verification", action_class="subagent", action_family="agent", input_digest=D[4], action_digest=action_digest,
            work_boundary_id="scope:selftest", repository_decision_id="rb:selftest.7", created_at=T[5])
        negotiation = {"contractType":"usage-negotiation","schemaVersion":2,"negotiationId":f"neg:{attempt}","intentId":intent["intentId"],
            "adapterId":"adapter:selftest","adapterContractVersion":2,"hostSchemaId":"selftest-v2","sessionIdentityId":identity["sessionIdentityId"],
            "mappingDigest":D[5],"capabilitiesDigest":D[6],"negotiatedAt":T[6]}
        self.runtime.usage_record(record=negotiation)
        maximums = [amount(name, value) for name, value in configured.items()]
        dimension_digest = mbe.ecf.typed_digest("dimension-set", sorted(mbe.amount_key(row) for row in maximums))
        quote = {"contractType":"usage-quote","schemaVersion":2,"quoteId":f"quote:{attempt}","goalId":budget["goalId"],
            "budgetId":budget["budgetId"],"epochId":epoch["epochId"],"sessionIdentityId":identity["sessionIdentityId"],
            "occurrenceId":occurrence,"attemptId":attempt,"actionDigest":action_digest,"adapterId":"adapter:selftest",
            "intentId":intent["intentId"],"negotiationId":negotiation["negotiationId"],"mappingDigest":D[5],"ruleDigest":D[7],
            "dimensionSetDigest":dimension_digest,"maximums":maximums,"expiresAt":EXP,"quotedAt":T[7]}
        self.runtime.usage_record(record=quote)
        snapshot = self.runtime.budget_snapshot(budget_id=budget["budgetId"], at=T[8])
        reservation = self.runtime.budget_reserve(goal_id=budget["goalId"], budget_id=budget["budgetId"], epoch_id=epoch["epochId"],
            session_identity_id=identity["sessionIdentityId"], intent_id=intent["intentId"], occurrence_id=occurrence, attempt_id=attempt,
            action_digest=action_digest, adapter_id="adapter:selftest", negotiation_id=negotiation["negotiationId"], quote_id=quote["quoteId"],
            quote_digest=mbe.ecf.typed_digest("usage-quote", quote), dimension_set_digest=dimension_digest, amounts=maximums, expires_at=EXP,
            funding_reservation_id=None, retry_decision_id=None, expected_ecf_sequence=snapshot["ecfSequence"],
            expected_ecf_head_digest=snapshot["ecfHeadDigest"], at=T[9])
        facts = []
        for index, fact_type in enumerate(("phase-relevance","risk-tier","model-class","tool-grant","action-authorization","retry-eligibility")):
            authorized = action_authorized if fact_type == "action-authorization" else True
            facts.append(self.runtime.admission_fact(intent_id=intent["intentId"], fact_type=fact_type, source_record_id=f"source:{index}",
                source_digest=D[8], value_digest=mbe.ecf.typed_digest("fact-value", {"type":fact_type,"allowed":authorized}),
                state="verified" if authorized else "invalid", issued_at=T[10], expires_at=fact_expiry))
        records = self.runtime.records()
        verification = next(row for row in records if row.get("contractType") == "epoch-verification")
        decision = self.runtime.admission_evaluate(intent_id=intent["intentId"], budget_id=budget["budgetId"], epoch_id=epoch["epochId"],
            session_identity_id=identity["sessionIdentityId"], occurrence_id=occurrence, attempt_id=attempt, action_digest=action_digest,
            negotiation_id=negotiation["negotiationId"], quote_id=quote["quoteId"], reservation_id=reservation["reservationId"],
            epoch_verification_id=verification["epochVerificationId"], fact_ids=[row["factId"] for row in facts], evaluated_at=T[11])
        return locals()

    def dispatch(self, fixture: dict[str, Any], status: str = "measured", measurement: list[dict[str, Any]] | None = None,
                 revision: int = 1, supersedes_receipt: str | None = None, supersedes_verification: str | None = None) -> dict[str, Any]:
        decision, reservation, intent, identity = (fixture[name] for name in ("decision","reservation","intent","identity"))
        permit = self.runtime.permit_issue(decision_id=decision["decisionId"], nonce="nonce:one", expires_at=EXP, issued_at=T[12], enforcement_kind="repository-reference")
        consumption = self.runtime.permit_consume(permit_id=permit["permitId"], nonce="nonce:one", consumed_at=T[13])
        receipt_id = f"receipt:{revision}"
        receipt = {"contractType":"usage-receipt","schemaVersion":2,"usageReceiptId":receipt_id,"revision":revision,
            "supersedesReceiptId":supersedes_receipt,"intentId":intent["intentId"],"permitId":permit["permitId"],"goalId":permit["goalId"],
            "budgetId":permit["budgetId"],"epochId":permit["epochId"],"sessionIdentityId":identity["sessionIdentityId"],
            "occurrenceId":permit["occurrenceId"],"attemptId":permit["attemptId"],"actionDigest":permit["actionDigest"],
            "adapterId":"adapter:selftest","adapterContractVersion":2,"hostSchemaId":"selftest-v2","measurementStatus":status,
            "measurement":measurement if measurement is not None else reservation["amounts"],"providerReceiptDigest":D[9],"sourceProofDigest":D[10],
            "retainedProjectionDigest":None,"retainedProjectionBytes":0,"monotonicStartedNs":100,"monotonicFinishedNs":200,
            "startedAt":T[13],"finishedAt":T[14]}
        self.runtime.usage_record(record=receipt)
        verification = {"contractType":"usage-receipt-verification","schemaVersion":2,"verificationId":f"verification:{revision}",
            "usageReceiptId":receipt_id,"revision":revision,"supersedesVerificationId":supersedes_verification,"verdict":"valid",
            "proofDigest":D[10],"verifiedAt":T[15]}
        self.runtime.usage_record(record=verification)
        return {"permit":permit,"consumption":consumption,"receipt":receipt,"verification":verification}


class TypedGraphTests(RuntimeCase):
    def test_corpus_reports_counterfactual_coverage_exclusions_and_quality_pairing(self) -> None:
        rows = [
            {"rowId": "row:included", "sessionDigest": D[1], "mode": "implement", "phase": "implementation", "epochClass": "implementation", "riskClass": "bounded", "modelClass": "none", "toolFamily": "repository", "measurementStatus": "measured", "outcome": "complete", "evidenceDigest": D[2], "exclusionReason": None},
            {"rowId": "row:excluded", "sessionDigest": D[2], "mode": "implement", "phase": "verification", "epochClass": "verification", "riskClass": "bounded", "modelClass": "none", "toolFamily": "repository", "measurementStatus": "invalid", "outcome": "excluded", "evidenceDigest": D[3], "exclusionReason": "invalid-measurement"},
        ]
        corpus = self.runtime.corpus_seal(source_snapshot_digest=D[1], adapter_versions=["adapter-v2"], rows=rows, sealed_at=T[0])
        evaluation = self.runtime.corpus_evaluate(corpus_id=corpus["corpusId"], candidate_policy_digest=D[2], quality_report_digest=D[3], track="counterfactual", requested_reduction=False, evaluated_at=T[1])
        self.assertEqual(evaluation["track"], "counterfactual")
        self.assertEqual(evaluation["causalSavingsClaim"], "unsupported")
        self.assertIsNone(evaluation["reduction"])
        self.assertEqual(evaluation["qualityReportDigest"], D[3])
        self.assertEqual(evaluation["measurementCoverage"]["coverageBasisPoints"], 10_000)
        self.assertEqual(evaluation["exclusions"], [{"reason": "invalid-measurement", "count": 1}])
        self.expect("MBE-LIVE-SAVINGS-UNSUPPORTED", lambda: self.runtime.corpus_evaluate(corpus_id=corpus["corpusId"], candidate_policy_digest=D[2], quality_report_digest=D[3], track="live-canary", requested_reduction=False, evaluated_at=T[2]))
        self.expect("MBE-LIVE-SAVINGS-UNSUPPORTED", lambda: self.runtime.corpus_evaluate(corpus_id=corpus["corpusId"], candidate_policy_digest=D[2], quality_report_digest=D[3], track="counterfactual", requested_reduction=True, evaluated_at=T[2]))
        facade_input = Path(self.temp.name) / "facade-evaluate.json"
        facade_input.write_text(json.dumps({"corpus_id": corpus["corpusId"], "candidate_policy_digest": D[2], "quality_report_digest": D[3], "track": "counterfactual", "requested_reduction": False, "evaluated_at": T[3]}), encoding="utf-8")
        facade = subprocess.run(["bash", str(HERE / "cost-corpus-evaluate.sh"), "evaluate", "--store-root", self.temp.name, "--input", str(facade_input)], check=False, capture_output=True, text=True)
        self.assertEqual(facade.returncode, 0, facade.stderr)
        facade_report = json.loads(facade.stdout)
        self.assertEqual((facade_report["track"], facade_report["reduction"], facade_report["qualityReportDigest"]), ("counterfactual", None, D[3]))
        unknown = subprocess.run(["bash", str(HERE / "cost-corpus-evaluate.sh"), "publish", "--store-root", self.temp.name, "--input", str(facade_input)], check=False, capture_output=True, text=True)
        self.assertEqual(unknown.returncode, 2)
        self.assertIn("unsupported operation", unknown.stderr)
        relative = subprocess.run(["bash", str(HERE / "cost-corpus-evaluate.sh"), "evaluate", "--store-root", "relative-store", "--input", str(facade_input)], check=False, capture_output=True, text=True)
        self.assertEqual(relative.returncode, 2)
        self.assertIn("must be absolute", relative.stderr)
        for field, value in (("track", "live-canary"), ("requested_reduction", True)):
            refused_input = Path(self.temp.name) / f"facade-refused-{field}.json"
            refused_payload = json.loads(facade_input.read_text(encoding="utf-8"))
            refused_payload[field] = value
            refused_input.write_text(json.dumps(refused_payload), encoding="utf-8")
            refused = subprocess.run(["bash", str(HERE / "cost-corpus-evaluate.sh"), "evaluate", "--store-root", self.temp.name, "--input", str(refused_input)], check=False, capture_output=True, text=True)
            self.assertNotEqual(refused.returncode, 0)
            self.assertIn("MBE-LIVE-SAVINGS-UNSUPPORTED", refused.stderr)

    def test_ordinary_duplicate_reservation_refuses_without_store_mutation(self) -> None:
        fixture = self.prepare()
        head = self.runtime.current_head()
        before = complete_store_bytes(self.temp.name)
        self.expect("MBE-RESERVATION-CONFLICT", lambda: self.runtime.budget_reserve(
            goal_id=fixture["budget"]["goalId"], budget_id=fixture["budget"]["budgetId"],
            epoch_id=fixture["epoch"]["epochId"], session_identity_id=fixture["identity"]["sessionIdentityId"],
            intent_id=fixture["intent"]["intentId"], occurrence_id=fixture["occurrence"], attempt_id=fixture["attempt"],
            action_digest=fixture["action_digest"], adapter_id="adapter:selftest",
            negotiation_id=fixture["negotiation"]["negotiationId"], quote_id=fixture["quote"]["quoteId"],
            quote_digest=mbe.ecf.typed_digest("usage-quote", fixture["quote"]),
            dimension_set_digest=fixture["dimension_digest"], amounts=fixture["maximums"], expires_at=EXP,
            funding_reservation_id=None, retry_decision_id=None, expected_ecf_sequence=head["sequence"],
            expected_ecf_head_digest=head["eventDigest"], at=T[12]))
        self.assertEqual(self.runtime.current_head(), head)
        self.assertEqual(complete_store_bytes(self.temp.name), before)

    def test_admission_rejects_expired_and_cross_intent_facts(self) -> None:
        expired = self.prepare(fact_expiry=T[11])
        self.assertEqual((expired["decision"]["verdict"], expired["decision"]["reasonCode"]),
                         ("refused", "MBE-ADMISSION-FACT-EXPIRED"))
        with tempfile.TemporaryDirectory(prefix="mbe-cross-intent-") as root:
            runtime = mbe.MeasuredBudgetRuntime(root)
            self.runtime = runtime
            fixture = self.prepare()
            other_intent = runtime.dispatch_intent(
                goal_id=fixture["budget"]["goalId"], budget_id=fixture["budget"]["budgetId"], epoch_id=fixture["epoch"]["epochId"],
                session_identity_id=fixture["identity"]["sessionIdentityId"], occurrence_id="occ:two", attempt_id="att:two",
                agent="bubbles.test", phase="verification", action_class="subagent", action_family="agent", input_digest=D[4],
                action_digest=D[3], work_boundary_id="scope:selftest", repository_decision_id="rb:selftest.7", created_at=T[12])
            foreign = runtime.admission_fact(intent_id=other_intent["intentId"], fact_type="phase-relevance", source_record_id="source:foreign",
                source_digest=D[8], value_digest=D[9], state="verified", issued_at=T[12], expires_at=EXP)
            fact_ids = [foreign["factId"], *[row["factId"] for row in fixture["facts"] if row["factType"] != "phase-relevance"]]
            decision = runtime.admission_evaluate(intent_id=fixture["intent"]["intentId"], budget_id=fixture["budget"]["budgetId"],
                epoch_id=fixture["epoch"]["epochId"], session_identity_id=fixture["identity"]["sessionIdentityId"],
                occurrence_id=fixture["occurrence"], attempt_id=fixture["attempt"], action_digest=fixture["action_digest"],
                negotiation_id=fixture["negotiation"]["negotiationId"], quote_id=fixture["quote"]["quoteId"],
                reservation_id=fixture["reservation"]["reservationId"], epoch_verification_id=fixture["verification"]["epochVerificationId"],
                fact_ids=fact_ids, evaluated_at=T[13])
            self.assertEqual((decision["verdict"], decision["reasonCode"]),
                             ("refused", "MBE-ADMISSION-FACT-BINDING-MISMATCH"))

    def test_independent_action_authorization_denial_blocks_permit(self) -> None:
        fixture = self.prepare(action_authorized=False)
        action_fact = next(row for row in fixture["facts"] if row["factType"] == "action-authorization")
        self.assertEqual(action_fact["state"], "invalid")
        self.assertEqual((fixture["decision"]["verdict"], fixture["decision"]["reasonCode"]),
                         ("refused", "MBE-ADMISSION-FACT-INCOMPLETE"))
        self.expect("MBE-PERMIT-INVALID", lambda: self.runtime.permit_issue(
            decision_id=fixture["decision"]["decisionId"], nonce="nonce:denied",
            expires_at=EXP, issued_at=T[12], enforcement_kind="repository-reference"))

    def test_reference_broker_constructs_settlement_and_refuses_replay(self) -> None:
        argv = ["/usr/bin/test", "x", "=", "x"]
        canonical = json.dumps({"argv": argv}, sort_keys=True, separators=(",", ":"), ensure_ascii=False)
        action_digest = "sha256:" + hashlib.sha256(canonical.encode("utf-8")).hexdigest()
        fixture = self.prepare(action_digest=action_digest)
        permit = self.runtime.permit_issue(decision_id=fixture["decision"]["decisionId"], nonce="nonce:broker", expires_at=EXP,
            issued_at=T[12], enforcement_kind="repository-reference")
        action_file = Path(self.temp.name) / "action.json"
        consumption_file = Path(self.temp.name) / "consumption.json"
        action_file.write_text(json.dumps({"actionDigest": action_digest, "argv": argv}), encoding="utf-8")
        consumption_file.write_text(json.dumps({"permit_id": permit["permitId"], "nonce": "nonce:broker", "consumed_at": T[13],
                            "action_digest": action_digest}), encoding="utf-8")
        command = [str(HERE.parent / "adapters/dispatch/reference-broker.sh"), "dispatch", "--store-root", self.temp.name,
                   "--permit-consumption", str(consumption_file), "--action", str(action_file)]
        completed = subprocess.run(command, text=True, capture_output=True, timeout=30, check=False)
        self.assertEqual(completed.returncode, 0, completed.stderr)
        result = json.loads(completed.stdout)
        self.assertEqual(result["childExitCode"], 0,
                 "broker did not execute the exact authorized child argv")
        self.assertEqual(result["settlement"], "debit")
        records = self.runtime.records()
        receipt = next(row for row in records if row.get("contractType") == "usage-receipt")
        verification = next(row for row in records if row.get("contractType") == "usage-receipt-verification")
        settlement = next(row for row in records if row.get("contractType") == "budget-settlement")
        self.assertEqual(receipt["adapterId"], "reference-test")
        self.assertEqual(verification["proofDigest"], receipt["sourceProofDigest"])
        self.assertEqual(settlement["receiptVerificationId"], verification["verificationId"])
        replay = subprocess.run(command, text=True, capture_output=True, timeout=30, check=False)
        self.assertNotEqual(replay.returncode, 0)
        self.assertNotIn("reference-dispatch-result", replay.stdout,
                 "replayed dispatch reached the post-child result path")

    def test_reference_broker_action_mismatch_never_starts_child(self) -> None:
        marker = Path(self.temp.name) / "mismatched-child-started"
        argv = ["/usr/bin/touch", str(marker)]
        canonical = json.dumps({"argv": argv}, sort_keys=True, separators=(",", ":"), ensure_ascii=False)
        action_digest = "sha256:" + hashlib.sha256(canonical.encode("utf-8")).hexdigest()
        fixture = self.prepare(action_digest=action_digest)
        permit = self.runtime.permit_issue(
            decision_id=fixture["decision"]["decisionId"], nonce="nonce:action",
            expires_at=EXP, issued_at=T[12], enforcement_kind="repository-reference")
        action_file = Path(self.temp.name) / "mismatched-action.json"
        consumption_file = Path(self.temp.name) / "mismatched-consumption.json"
        action_file.write_text(json.dumps({"actionDigest": D[2], "argv": argv}), encoding="utf-8")
        consumption_file.write_text(json.dumps({
            "permit_id": permit["permitId"], "nonce": "nonce:action", "consumed_at": T[13],
            "action_digest": action_digest}), encoding="utf-8")
        denied = subprocess.run(
            [str(HERE.parent / "adapters/dispatch/reference-broker.sh"), "dispatch",
             "--store-root", self.temp.name, "--permit-consumption", str(consumption_file),
             "--action", str(action_file)],
            text=True, capture_output=True, timeout=30, check=False)
        self.assertEqual(denied.returncode, 4)
        self.assertIn("action digest does not match permit binding", denied.stderr)
        self.assertFalse(marker.exists(), "action mismatch started the child process")
        consumption = self.runtime.permit_consume(
            permit_id=permit["permitId"], nonce="nonce:action", consumed_at=T[13])
        self.assertEqual(consumption["permitId"], permit["permitId"],
                         "action mismatch consumed the permit before refusing")

    def test_reference_verifier_accepts_exact_graph_and_rejects_forged_epoch(self) -> None:
        fixture = self.prepare()
        permit = self.runtime.permit_issue(
            decision_id=fixture["decision"]["decisionId"], nonce="nonce:verify",
            expires_at=EXP, issued_at=T[12], enforcement_kind="repository-reference")
        context = {
            "budgetId": fixture["budget"]["budgetId"],
            "epochId": fixture["epoch"]["epochId"],
            "epochVerificationId": fixture["verification"]["epochVerificationId"],
            "admissionDecisionId": fixture["decision"]["decisionId"],
            "reservationId": fixture["reservation"]["reservationId"],
            "permitId": permit["permitId"],
            "occurrenceId": fixture["occurrence"],
            "attemptId": fixture["attempt"],
        }
        context_file = Path(self.temp.name) / "mbe-context.json"
        context_file.write_text(json.dumps(context), encoding="utf-8")
        command = [sys.executable, str(HERE / "mbe-reference-verify.py"), "--store-root", self.temp.name,
                   "--context", str(context_file), "--purpose", "dispatch",
                   "--action-digest", fixture["action_digest"]]
        verified = subprocess.run(command, text=True, capture_output=True, timeout=30, check=False)
        self.assertEqual(verified.returncode, 0, verified.stderr)
        self.assertFalse(json.loads(verified.stdout)["unresolvedHold"])

        context["epochId"] = "sep:forged"
        context_file.write_text(json.dumps(context), encoding="utf-8")
        forged = subprocess.run(command, text=True, capture_output=True, timeout=30, check=False)
        self.assertNotEqual(forged.returncode, 0)

    def test_reference_broker_denial_never_starts_child(self) -> None:
        marker = Path(self.temp.name) / "child-started"
        argv = ["/usr/bin/touch", str(marker)]
        canonical = json.dumps({"argv": argv}, sort_keys=True, separators=(",", ":"), ensure_ascii=False)
        action_digest = "sha256:" + hashlib.sha256(canonical.encode("utf-8")).hexdigest()
        fixture = self.prepare(action_digest=action_digest)
        permit = self.runtime.permit_issue(
            decision_id=fixture["decision"]["decisionId"], nonce="nonce:expected",
            expires_at=EXP, issued_at=T[12], enforcement_kind="repository-reference")
        action_file = Path(self.temp.name) / "denied-action.json"
        consumption_file = Path(self.temp.name) / "denied-consumption.json"
        action_file.write_text(json.dumps({"actionDigest": action_digest, "argv": argv}), encoding="utf-8")
        consumption_file.write_text(json.dumps({
            "permit_id": permit["permitId"], "nonce": "nonce:wrong", "consumed_at": T[13],
            "action_digest": action_digest}), encoding="utf-8")
        denied = subprocess.run(
            [str(HERE.parent / "adapters/dispatch/reference-broker.sh"), "dispatch",
             "--store-root", self.temp.name, "--permit-consumption", str(consumption_file),
             "--action", str(action_file)],
            text=True, capture_output=True, timeout=30, check=False)
        self.assertNotEqual(denied.returncode, 0)
        self.assertFalse(marker.exists(), "denied dispatch started the child process")

    def test_full_graph_is_acyclic_bound_and_one_use(self) -> None:
        fixture = self.prepare()
        self.assertEqual(fixture["decision"]["verdict"], "permit-eligible")
        dispatch = self.dispatch(fixture)
        self.expect("MBE-PERMIT-INVALID", lambda: self.runtime.permit_consume(permit_id=dispatch["permit"]["permitId"], nonce="nonce:one", consumed_at=T[16]))
        partition = [{"dimension":row["dimension"],"unit":row["unit"],"currency":row["currency"],"scale":row["scale"],
                      "reserved":row["amount"],"debit":row["amount"],"release":0,"hold":0} for row in fixture["reservation"]["amounts"]]
        settlement = self.runtime.budget_settle(budget_id=fixture["budget"]["budgetId"], reservation_id=fixture["reservation"]["reservationId"],
            permit_id=dispatch["permit"]["permitId"], consumption_id=dispatch["consumption"]["consumptionId"],
            usage_receipt_id=dispatch["receipt"]["usageReceiptId"], receipt_verification_id=dispatch["verification"]["verificationId"],
            revision=1, supersedes_settlement_id=None, partitions=partition, terminal_state="debit", settled_at=T[16])
        self.assertEqual(settlement["revision"], 1)
        graph = [row["contractType"] for row in self.runtime.records()]
        for required in ("host-session-identity","session-epoch","dispatch-intent","usage-negotiation","usage-quote","budget-reservation",
                         "admission-fact","admission-decision","dispatch-permit","permit-consumption","usage-receipt","usage-receipt-verification","budget-settlement"):
            self.assertIn(required, graph)

    def test_every_dimension_has_independent_exact_and_over_cap_behavior(self) -> None:
        for index, name in enumerate(mbe.DIMENSIONS):
            with self.subTest(dimension=name):
                with tempfile.TemporaryDirectory(prefix=f"mbe-cap-{index}-") as root:
                    runtime = mbe.MeasuredBudgetRuntime(root)
                    budget = runtime.budget_open(goal_id=f"goal:cap.{index}",policy_digest=D[0],rollout_posture="reference-enforce",
                        dimensions=policies({name:10}),opened_at=T[0],goal_deadline_at=EXP,max_occurrences=2,max_attempts_per_occurrence=1)
                    self.assertEqual(next(row for row in budget["dimensions"] if row["dimension"] == name)["limit"], 10)
                    self.expect("MBE-INPUT-INVALID", lambda: mbe.validate_amounts([amount(name, mbe.MAX_AMOUNT + 1)], "amounts"))

    def test_settlement_partition_and_close_refuse_unresolved_hold(self) -> None:
        fixture = self.prepare({"inputTokens":10,"outputTokens":8,"wallTimeMs":20})
        dispatch = self.dispatch(fixture, measurement=[amount("inputTokens",4),amount("outputTokens",3),amount("wallTimeMs",20)])
        partitions = [
            {"dimension":"inputTokens","unit":"tokens","currency":None,"scale":None,"reserved":10,"debit":4,"release":0,"hold":6},
            {"dimension":"outputTokens","unit":"tokens","currency":None,"scale":None,"reserved":8,"debit":3,"release":5,"hold":0},
            {"dimension":"wallTimeMs","unit":"milliseconds","currency":None,"scale":None,"reserved":20,"debit":20,"release":0,"hold":0}]
        settlement = self.runtime.budget_settle(budget_id=fixture["budget"]["budgetId"],reservation_id=fixture["reservation"]["reservationId"],
            permit_id=dispatch["permit"]["permitId"],consumption_id=dispatch["consumption"]["consumptionId"],usage_receipt_id=dispatch["receipt"]["usageReceiptId"],
            receipt_verification_id=dispatch["verification"]["verificationId"],revision=1,supersedes_settlement_id=None,partitions=partitions,
            terminal_state="hold",settled_at=T[16])
        self.expect("MBE-USAGE-UNRESOLVED", lambda: self.runtime.budget_close(budget_id=fixture["budget"]["budgetId"],occurrence_id="occ:close",attempt_id="att:close",action_digest=D[1],at=T[17],reason="close"))
        bad = [dict(row) for row in partitions]; bad[0]["release"] = 1
        self.expect("MBE-SETTLEMENT-PARTITION-MISMATCH", lambda: self.runtime.budget_settle(budget_id=fixture["budget"]["budgetId"],reservation_id=fixture["reservation"]["reservationId"],
            permit_id=dispatch["permit"]["permitId"],consumption_id=dispatch["consumption"]["consumptionId"],usage_receipt_id=dispatch["receipt"]["usageReceiptId"],
            receipt_verification_id=dispatch["verification"]["verificationId"],revision=2,supersedes_settlement_id=settlement["settlementId"],partitions=bad,terminal_state="hold",settled_at=T[17]))

    def test_hold_funded_retry_transfers_exact_partial_amount_once(self) -> None:
        fixture = self.prepare({"inputTokens":10,"outputTokens":8})
        dispatched = self.dispatch(fixture, measurement=[amount("inputTokens",4), amount("outputTokens",3)])
        parent_partitions = [
            {"dimension":"inputTokens","unit":"tokens","currency":None,"scale":None,"reserved":10,"debit":4,"release":0,"hold":6},
            {"dimension":"outputTokens","unit":"tokens","currency":None,"scale":None,"reserved":8,"debit":3,"release":5,"hold":0},
        ]
        self.runtime.budget_settle(budget_id=fixture["budget"]["budgetId"], reservation_id=fixture["reservation"]["reservationId"],
            permit_id=dispatched["permit"]["permitId"], consumption_id=dispatched["consumption"]["consumptionId"],
            usage_receipt_id=dispatched["receipt"]["usageReceiptId"], receipt_verification_id=dispatched["verification"]["verificationId"],
            revision=1, supersedes_settlement_id=None, partitions=parent_partitions, terminal_state="hold", settled_at=T[16])
        transfer = [amount("inputTokens",4), amount("outputTokens",0)]
        transfer_digest = mbe.ecf.typed_digest("dimension-set", sorted(mbe.amount_key(row) for row in transfer))
        retry = self.runtime.retry_decide(goal_id=fixture["budget"]["goalId"], budget_id=fixture["budget"]["budgetId"],
            epoch_id=fixture["epoch"]["epochId"], session_identity_id=fixture["identity"]["sessionIdentityId"],
            occurrence_id=fixture["occurrence"], prior_attempt_id=fixture["attempt"], next_attempt_id="att:two",
            action_digest=fixture["action_digest"], failure_class="transient", eligible=True,
            hold_funded_reservation_id=fixture["reservation"]["reservationId"], hold_transfer_dimension_set_digest=transfer_digest,
            hold_transfer_amounts=transfer, decided_at=T[17])
        self.expect("MBE-RETRY-UNAUTHORIZED", lambda: self.runtime.retry_decide(goal_id=fixture["budget"]["goalId"],
            budget_id=fixture["budget"]["budgetId"], epoch_id=fixture["epoch"]["epochId"],
            session_identity_id=fixture["identity"]["sessionIdentityId"], occurrence_id=fixture["occurrence"],
            prior_attempt_id=fixture["attempt"], next_attempt_id="att:over", action_digest=fixture["action_digest"],
            failure_class="transient", eligible=True, hold_funded_reservation_id=fixture["reservation"]["reservationId"],
            hold_transfer_dimension_set_digest=transfer_digest, hold_transfer_amounts=[amount("inputTokens",7), amount("outputTokens",0)],
            decided_at=T[18]))
        child_intent = self.runtime.dispatch_intent(goal_id=fixture["budget"]["goalId"], budget_id=fixture["budget"]["budgetId"],
            epoch_id=fixture["epoch"]["epochId"], session_identity_id=fixture["identity"]["sessionIdentityId"],
            occurrence_id=fixture["occurrence"], attempt_id="att:two", agent="bubbles.test", phase="verification",
            action_class="subagent", action_family="agent", input_digest=D[4], action_digest=fixture["action_digest"],
            work_boundary_id="scope:selftest", repository_decision_id="rb:selftest.7", created_at=T[18])
        negotiation = {"contractType":"usage-negotiation","schemaVersion":2,"negotiationId":"neg:att.two","intentId":child_intent["intentId"],
            "adapterId":"adapter:selftest","adapterContractVersion":2,"hostSchemaId":"selftest-v2","sessionIdentityId":fixture["identity"]["sessionIdentityId"],
            "mappingDigest":D[5],"capabilitiesDigest":D[6],"negotiatedAt":T[19]}
        self.runtime.usage_record(record=negotiation)
        quote = {"contractType":"usage-quote","schemaVersion":2,"quoteId":"quote:att.two","goalId":fixture["budget"]["goalId"],
            "budgetId":fixture["budget"]["budgetId"],"epochId":fixture["epoch"]["epochId"],"sessionIdentityId":fixture["identity"]["sessionIdentityId"],
            "occurrenceId":fixture["occurrence"],"attemptId":"att:two","actionDigest":fixture["action_digest"],"adapterId":"adapter:selftest",
            "intentId":child_intent["intentId"],"negotiationId":negotiation["negotiationId"],"mappingDigest":D[5],"ruleDigest":D[7],
            "dimensionSetDigest":transfer_digest,"maximums":transfer,"expiresAt":EXP,"quotedAt":T[20]}
        self.runtime.usage_record(record=quote)
        predecessor = self.runtime.budget_snapshot(budget_id=fixture["budget"]["budgetId"], at=T[21])
        latest = self.runtime.budget_snapshot(budget_id=fixture["budget"]["budgetId"], at=T[21])
        reservations_before = sum(row.get("contractType") == "budget-reservation" for row in self.runtime.records())
        self.expect("MBE-RESERVATION-CONFLICT", lambda: self.runtime.budget_reserve(goal_id=fixture["budget"]["goalId"], budget_id=fixture["budget"]["budgetId"],
            epoch_id=fixture["epoch"]["epochId"], session_identity_id=fixture["identity"]["sessionIdentityId"], intent_id=child_intent["intentId"],
            occurrence_id=fixture["occurrence"], attempt_id="att:two", action_digest=fixture["action_digest"], adapter_id="adapter:selftest",
            negotiation_id=negotiation["negotiationId"], quote_id=quote["quoteId"], quote_digest=mbe.ecf.typed_digest("usage-quote", quote),
            dimension_set_digest=transfer_digest, amounts=transfer, expires_at=EXP, funding_reservation_id=fixture["reservation"]["reservationId"],
            retry_decision_id=retry["retryDecisionId"], expected_ecf_sequence=predecessor["ecfSequence"],
            expected_ecf_head_digest=predecessor["ecfHeadDigest"], at=T[22]))
        self.assertEqual(sum(row.get("contractType") == "budget-reservation" for row in self.runtime.records()), reservations_before)
        self.expect("MBE-RETRY-UNAUTHORIZED", lambda: self.runtime.budget_reserve(goal_id=fixture["budget"]["goalId"], budget_id=fixture["budget"]["budgetId"],
            epoch_id=fixture["epoch"]["epochId"], session_identity_id=fixture["identity"]["sessionIdentityId"], intent_id=child_intent["intentId"],
            occurrence_id=fixture["occurrence"], attempt_id="att:two", action_digest=fixture["action_digest"], adapter_id="adapter:selftest",
            negotiation_id=negotiation["negotiationId"], quote_id=quote["quoteId"], quote_digest=mbe.ecf.typed_digest("usage-quote", quote),
            dimension_set_digest=transfer_digest, amounts=transfer, expires_at=EXP, funding_reservation_id="brs:wrong.parent",
            retry_decision_id=retry["retryDecisionId"], expected_ecf_sequence=latest["ecfSequence"],
            expected_ecf_head_digest=latest["ecfHeadDigest"], at=T[22]))
        self.assertEqual(sum(row.get("contractType") == "budget-reservation" for row in self.runtime.records()), reservations_before)
        predecessor = self.runtime.budget_snapshot(budget_id=fixture["budget"]["budgetId"], at=T[21])
        child = self.runtime.budget_reserve(goal_id=fixture["budget"]["goalId"], budget_id=fixture["budget"]["budgetId"],
            epoch_id=fixture["epoch"]["epochId"], session_identity_id=fixture["identity"]["sessionIdentityId"], intent_id=child_intent["intentId"],
            occurrence_id=fixture["occurrence"], attempt_id="att:two", action_digest=fixture["action_digest"], adapter_id="adapter:selftest",
            negotiation_id=negotiation["negotiationId"], quote_id=quote["quoteId"], quote_digest=mbe.ecf.typed_digest("usage-quote", quote),
            dimension_set_digest=transfer_digest, amounts=transfer, expires_at=EXP, funding_reservation_id=fixture["reservation"]["reservationId"],
            retry_decision_id=retry["retryDecisionId"], expected_ecf_sequence=predecessor["ecfSequence"],
            expected_ecf_head_digest=predecessor["ecfHeadDigest"], at=T[22])
        self.assertEqual(child["fundingReservationId"], fixture["reservation"]["reservationId"])
        replay_predecessor = self.runtime.budget_snapshot(budget_id=fixture["budget"]["budgetId"], at=T[23])
        self.expect("MBE-RETRY-UNAUTHORIZED", lambda: self.runtime.budget_reserve(goal_id=fixture["budget"]["goalId"], budget_id=fixture["budget"]["budgetId"],
            epoch_id=fixture["epoch"]["epochId"], session_identity_id=fixture["identity"]["sessionIdentityId"], intent_id=child_intent["intentId"],
            occurrence_id=fixture["occurrence"], attempt_id="att:two", action_digest=fixture["action_digest"], adapter_id="adapter:selftest",
            negotiation_id=negotiation["negotiationId"], quote_id=quote["quoteId"], quote_digest=mbe.ecf.typed_digest("usage-quote", quote),
            dimension_set_digest=transfer_digest, amounts=transfer, expires_at=EXP, funding_reservation_id=fixture["reservation"]["reservationId"],
            retry_decision_id=retry["retryDecisionId"], expected_ecf_sequence=replay_predecessor["ecfSequence"],
            expected_ecf_head_digest=replay_predecessor["ecfHeadDigest"], at=T[23]))
        snapshot = self.runtime.budget_snapshot(budget_id=fixture["budget"]["budgetId"], at=T[23])
        counters = {row["dimension"]: row for row in snapshot["dimensions"]}
        self.assertEqual((counters["inputTokens"]["reserved"], counters["inputTokens"]["held"]), (8, 2))
        self.assertEqual((counters["outputTokens"]["reserved"], counters["outputTokens"]["held"]), (3, 0))
        self.expect("MBE-RETRY-UNAUTHORIZED", lambda: self.runtime.retry_decide(goal_id=fixture["budget"]["goalId"],
            budget_id=fixture["budget"]["budgetId"], epoch_id=fixture["epoch"]["epochId"],
            session_identity_id=fixture["identity"]["sessionIdentityId"], occurrence_id=fixture["occurrence"],
            prior_attempt_id=fixture["attempt"], next_attempt_id="att:two", action_digest=fixture["action_digest"],
            failure_class="transient", eligible=True, hold_funded_reservation_id=fixture["reservation"]["reservationId"],
            hold_transfer_dimension_set_digest=transfer_digest, hold_transfer_amounts=transfer, decided_at=T[24]))

    def test_epoch_rollover_requires_closed_predecessor_and_exact_proof(self) -> None:
        first_identity = self.identity()
        budget = self.open_budget({"modelRequestCount":2})
        first = self.epoch(budget, first_identity)
        second_identity = self.identity("session:two", D[3])
        self.expect("MBE-IDENTITY-MISSING", lambda: self.epoch(budget, second_identity, 2, first, 8))
        self.runtime.epoch_close(epoch_id=first["epochId"],continuation_digest=D[2],closed_at=T[8])
        second = self.epoch(budget, second_identity, 2, first, 9)
        self.assertEqual(second["sequence"], 2)

    def test_capacity_preflight_refuses_before_first_goal_record(self) -> None:
        self.expect("MBE-GOAL-CAPACITY-EXCEEDED", lambda: self.runtime.budget_open(goal_id="goal:overflow",policy_digest=D[0],rollout_posture="reference-enforce",
            dimensions=policies({"toolCalls":1}),opened_at=T[0],goal_deadline_at=EXP,max_occurrences=mbe.ecf.MAX_EVENT_COUNT,max_attempts_per_occurrence=2))
        self.assertEqual(self.runtime.records(), [])

    def test_sensitive_aliases_are_separator_and_case_insensitive(self) -> None:
        identity = self.identity()
        bad = dict(identity); bad["Prompt-Content"] = "private"
        bad["sessionIdentityId"] = "session:bad"
        self.expect("MBE-SCHEMA-DRIFT", lambda: self.runtime.usage_record(record=bad))
        nested = {"contractType":"usage-snapshot","schemaVersion":2,"snapshotId":"snapshot:bad","adapterId":"adapter:selftest",
                  "sessionIdentityId":identity["sessionIdentityId"],"cursor":1,"previousCursor":0,"measurement":[],"observedAt":T[1],
                  "metadata":{"PrIvAtE_pAtH":"/home/private"}}
        self.expect("MBE-SCHEMA-DRIFT", lambda: self.runtime.usage_record(record=nested))

    def test_receipt_correction_must_replace_current_leaf(self) -> None:
        fixture = self.prepare()
        first = self.dispatch(fixture)
        corrected = dict(first["receipt"]); corrected.update({"usageReceiptId":"receipt:2","revision":2,"supersedesReceiptId":first["receipt"]["usageReceiptId"],"measurementStatus":"superseded"})
        self.runtime.usage_record(record=corrected)
        fork = dict(corrected); fork.update({"usageReceiptId":"receipt:fork","revision":2})
        self.expect("MBE-RECEIPT-REVISION-CONFLICT", lambda: self.runtime.usage_record(record=fork))


class ExtensionDiscoveryTests(RuntimeCase):
    def append_extension_event(self, extensions: list[dict[str, Any]], number: int) -> None:
        with self.runtime.store.locked():
            head = self.runtime.store.load_head()
            proposal = {
                "attemptId": f"att:extension.{number}", "contractType": "execution-control-event",
                "eventId": f"evt:extension.{number}", "eventType": "RECORD", "extensions": extensions,
                "objectDigest": extensions[number]["payloadDigest"], "occurrenceId": f"occ:extension.{number}",
                "posture": "reference-enforce", "recordedAt": T[number + 1], "schemaVersion": 2,
                "subject": {"id": f"extension:{number}", "kind": "x.mbe.domain.usage"},
                "supersedesEventId": None,
            }
            self.runtime.store.append(head["sequence"], head["eventDigest"], proposal)

    def test_mbe_extension_projection_is_order_independent_and_preserves_unrelated_extensions(self) -> None:
        projections = []
        for position in range(3):
            with self.subTest(position=position), tempfile.TemporaryDirectory(prefix="mbe-extension-order-") as root:
                runtime = mbe.MeasuredBudgetRuntime(root)
                record = {
                    "contractType": "host-session-identity", "schemaVersion": 2,
                    "sessionIdentityId": "session:extension", "adapterId": "adapter:selftest",
                    "hostInstanceId": "host:one", "workspaceIdentity": "workspace:one",
                    "hostSessionId": "session.extension", "artifactSessionId": "artifact:extension",
                    "repositoryDecisionId": "rb:selftest.7", "hostSchemaId": "selftest-v2",
                    "proofDigest": D[1], "startedAt": T[0],
                }
                unrelated_payloads = [{"kind": "alpha", "value": 1}, {"kind": "omega", "value": 2}]
                with runtime.store.locked():
                    mbe_object = runtime.store.put_object(record)
                    unrelated_objects = [runtime.store.put_object(payload) for payload in unrelated_payloads]
                unrelated = [
                    {"namespace": "org.example.alpha", "schemaVersion": 1, "payloadDigest": unrelated_objects[0]["objectDigest"]},
                    {"namespace": "org.example.omega", "schemaVersion": 1, "payloadDigest": unrelated_objects[1]["objectDigest"]},
                ]
                mbe_extension = {"namespace": "org.bubbles.mbe", "schemaVersion": 1, "payloadDigest": mbe_object["objectDigest"]}
                extensions = list(unrelated)
                extensions.insert(position, mbe_extension)
                case = ExtensionDiscoveryTests(methodName="runTest")
                case.runtime = runtime
                case.append_extension_event(extensions, position)
                projections.append(runtime.records())
                persisted = runtime.store.verified().events[0]["extensions"]
                persisted_unrelated = [extension for extension in persisted if extension["namespace"] != "org.bubbles.mbe"]
                self.assertEqual(persisted_unrelated, unrelated)
                self.assertEqual(mbe.ecf.canonical_line(persisted_unrelated), mbe.ecf.canonical_line(unrelated))
        self.assertEqual(projections, [[projections[0][0]]] * 3)

    def test_zero_mbe_extensions_are_omitted_and_duplicate_namespace_fails_closed(self) -> None:
        with self.runtime.store.locked():
            unrelated_object = self.runtime.store.put_object({"kind": "unrelated"})
        unrelated = {"namespace": "org.example.only", "schemaVersion": 1,
                     "payloadDigest": unrelated_object["objectDigest"]}
        self.append_extension_event([unrelated], 0)
        self.assertEqual(self.runtime.records(), [])
        duplicate_event = {"extensions": [
            {"namespace": "org.bubbles.mbe", "schemaVersion": 1, "payloadDigest": D[0]},
            {"namespace": "org.bubbles.mbe", "schemaVersion": 1, "payloadDigest": D[1]},
        ]}
        with mock.patch.object(self.runtime.store, "verified", return_value=SimpleNamespace(events=[duplicate_event])):
            self.expect("MBE-EXTENSION-DUPLICATE", self.runtime.records)


class ContractProjectionTests(RuntimeCase):
    def test_registry_rejects_circular_edge_and_schema_check_detects_drift_without_rewrite(self) -> None:
        registry = json.loads(mbe.contracts.REGISTRY.read_text(encoding="utf-8"))
        registry["graphEdges"].append([registry["graph"][0], registry["graph"][0]])
        with tempfile.TemporaryDirectory(prefix="mbe-contract-registry-") as root:
            temporary_registry = Path(root) / "registry.json"
            temporary_registry.write_text(json.dumps(registry), encoding="utf-8")
            with mock.patch.object(mbe.contracts, "REGISTRY", temporary_registry):
                with self.assertRaisesRegex(ValueError, "forward or circular graph edge"):
                    mbe.contracts.load_registry()

        with tempfile.TemporaryDirectory(prefix="mbe-schema-drift-") as root:
            schema_dir = Path(root)
            for name in ("dispatch-admission.schema.json", "usage-adapter-v2.schema.json", "session-epoch.schema.json"):
                shutil.copyfile(HERE.parent / "schemas" / name, schema_dir / name)
            mutated = schema_dir / "dispatch-admission.schema.json"
            mutated.write_bytes(mutated.read_bytes() + b" ")
            before = {path.name: path.read_bytes() for path in schema_dir.iterdir()}
            stderr = io.StringIO()
            with mock.patch.object(mbe.contracts, "SCHEMA_DIR", schema_dir), \
                    mock.patch.object(sys, "argv", ["measured-budget-contracts.py", "schema", "--check"]), \
                    contextlib.redirect_stderr(stderr):
                self.assertEqual(mbe.contracts.main(), 1)
            self.assertIn("schema drift: dispatch-admission.schema.json", stderr.getvalue())
            self.assertEqual({path.name: path.read_bytes() for path in schema_dir.iterdir()}, before)

    def test_every_emitted_record_matches_registry_and_draft7_projection_while_cross_record_drift_refuses(self) -> None:
        fixture = self.prepare()
        dispatched = self.dispatch(fixture)
        registry = mbe.contracts.load_registry()
        schemas = {name: json.loads((HERE.parent / "schemas" / name).read_text(encoding="utf-8"))
                   for name in ("dispatch-admission.schema.json", "usage-adapter-v2.schema.json", "session-epoch.schema.json")}
        for record in self.runtime.records():
            with self.subTest(contractType=record["contractType"]):
                mbe.contracts.validate_record(registry, record)
                row = mbe.contracts.contract_row(registry, record["contractType"])
                Draft7Validator(schemas[row["projection"]]).validate(record)

        invalid_verification = dict(dispatched["verification"])
        invalid_verification.update({"verificationId": "verification:cross.record", "revision": 2,
                                     "supersedesVerificationId": None})
        mbe.contracts.validate_record(registry, invalid_verification)
        verification_schema = schemas[mbe.contracts.contract_row(
            registry, invalid_verification["contractType"])["projection"]]
        Draft7Validator(verification_schema).validate(invalid_verification)
        self.expect("MBE-RECEIPT-REVISION-CONFLICT", lambda: self.runtime.usage_record(record=invalid_verification))


def emit_fixture(store_root: str, context_path: str, action_file: str | None,
                 action_argv_json: str | None, hold: bool) -> None:
    action_argv = json.loads(action_argv_json) if action_argv_json is not None else ["selftest-child"]
    if not isinstance(action_argv, list) or not all(isinstance(value, str) for value in action_argv):
        raise ValueError("--action-argv-json must be a JSON array of strings")
    canonical_action = json.dumps({"argv": action_argv}, sort_keys=True, separators=(",", ":"))
    action_digest = "sha256:" + hashlib.sha256(canonical_action.encode("utf-8")).hexdigest()

    fixture_case = RuntimeCase(methodName="runTest")
    fixture_case.runtime = mbe.MeasuredBudgetRuntime(store_root)
    fixture = fixture_case.prepare(action_digest=action_digest)
    permit = fixture_case.runtime.permit_issue(
        decision_id=fixture["decision"]["decisionId"], nonce="nonce:fixture",
        expires_at=EXP, issued_at=T[12], enforcement_kind="repository-reference")

    if hold:
        consumption = fixture_case.runtime.permit_consume(
            permit_id=permit["permitId"], nonce="nonce:fixture", consumed_at=T[13])
        receipt = {
            "contractType": "usage-receipt", "schemaVersion": 2,
            "usageReceiptId": "receipt:fixture", "revision": 1,
            "supersedesReceiptId": None, "intentId": fixture["intent"]["intentId"],
            "permitId": permit["permitId"], "goalId": permit["goalId"],
            "budgetId": permit["budgetId"], "epochId": permit["epochId"],
            "sessionIdentityId": fixture["identity"]["sessionIdentityId"],
            "occurrenceId": permit["occurrenceId"], "attemptId": permit["attemptId"],
            "actionDigest": permit["actionDigest"], "adapterId": "adapter:selftest",
            "adapterContractVersion": 2, "hostSchemaId": "selftest-v2",
            "measurementStatus": "measured",
            "measurement": [{**row, "amount": 0} for row in fixture["reservation"]["amounts"]],
            "providerReceiptDigest": D[9], "sourceProofDigest": D[10],
            "retainedProjectionDigest": None, "retainedProjectionBytes": 0,
            "monotonicStartedNs": 100, "monotonicFinishedNs": 200,
            "startedAt": T[13], "finishedAt": T[14],
        }
        fixture_case.runtime.usage_record(record=receipt)
        verification = {
            "contractType": "usage-receipt-verification", "schemaVersion": 2,
            "verificationId": "verification:fixture", "usageReceiptId": receipt["usageReceiptId"],
            "revision": 1, "supersedesVerificationId": None, "verdict": "valid",
            "proofDigest": D[10], "verifiedAt": T[15],
        }
        fixture_case.runtime.usage_record(record=verification)
        partitions = [
            {"dimension": row["dimension"], "unit": row["unit"],
             "currency": row["currency"], "scale": row["scale"],
             "reserved": row["amount"], "debit": 0, "release": 0, "hold": row["amount"]}
            for row in fixture["reservation"]["amounts"]
        ]
        fixture_case.runtime.budget_settle(
            budget_id=fixture["budget"]["budgetId"],
            reservation_id=fixture["reservation"]["reservationId"],
            permit_id=permit["permitId"], consumption_id=consumption["consumptionId"],
            usage_receipt_id=receipt["usageReceiptId"],
            receipt_verification_id=verification["verificationId"], revision=1,
            supersedes_settlement_id=None, partitions=partitions,
            terminal_state="hold", settled_at=T[16])

    verification = next(row for row in fixture_case.runtime.records()
                        if row.get("contractType") == "epoch-verification")
    context = {
        "budgetId": fixture["budget"]["budgetId"],
        "epochId": fixture["epoch"]["epochId"],
        "epochVerificationId": verification["epochVerificationId"],
        "admissionDecisionId": fixture["decision"]["decisionId"],
        "reservationId": fixture["reservation"]["reservationId"],
        "permitId": permit["permitId"],
        "occurrenceId": fixture["intent"]["occurrenceId"],
        "attemptId": fixture["intent"]["attemptId"],
    }
    Path(context_path).write_text(json.dumps(context, sort_keys=True, separators=(",", ":")) + "\n", encoding="utf-8")
    if action_file is not None:
        Path(action_file).write_text(json.dumps({"actionDigest": action_digest, "argv": action_argv},
                                               sort_keys=True, separators=(",", ":")) + "\n", encoding="utf-8")


if __name__ == "__main__":
    parser = argparse.ArgumentParser(add_help=False)
    parser.add_argument("--emit-fixture", action="store_true")
    parser.add_argument("--store-root")
    parser.add_argument("--context")
    parser.add_argument("--action-file")
    parser.add_argument("--action-argv-json")
    parser.add_argument("--hold", action="store_true")
    fixture_args, unittest_args = parser.parse_known_args()
    if fixture_args.emit_fixture:
        if fixture_args.store_root is None or fixture_args.context is None:
            parser.error("--emit-fixture requires --store-root and --context")
        emit_fixture(fixture_args.store_root, fixture_args.context, fixture_args.action_file,
                     fixture_args.action_argv_json, fixture_args.hold)
    else:
        unittest.main(argv=[sys.argv[0], *unittest_args], verbosity=2)