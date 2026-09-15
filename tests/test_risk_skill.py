#!/usr/bin/env python3
"""Contract test for the risk skill. No network, no vault writes.

Usage:
  python3 tests/test_risk_skill.py
"""
from pathlib import Path
import sys

ROOT = Path(__file__).resolve().parent.parent
METHOD = ROOT / "skills" / "risk" / "references" / "method.md"
FIXTURE = ROOT / "skills" / "risk" / "references" / "fixture.md"
SKILL = ROOT / "skills" / "risk" / "SKILL.md"

COLUMNS = [
    "statement",
    "threat or opportunity",
    "category",
    "probability",
    "impact",
    "effort",
    "strategy",
    "action",
    "owner",
    "approver",
    "response cost",
    "cost if the risk occurs",
    "trigger",
    "status",
]

REQUIRED_METHOD = [
    "Low probability and high impact: monitor closely",
    "avoid",
    "escalate",
    "transfer",
    "mitigate",
    "accept",
    "exploit",
    "share",
    "enhance",
    "deep dive",
    "some mitigation",
    "review regularly",
    "appropriate to the significance",
    "cost-effective",
    "realistic",
    "agreed",
    "owned",
]


def fail(msg):
    print(f"FAIL: {msg}")
    return 1


def test_method():
    errors = 0
    if not METHOD.is_file():
        return fail(f"missing {METHOD}")
    text = METHOD.read_text(encoding="utf-8")
    lower = text.lower()
    for phrase in REQUIRED_METHOD:
        if phrase.lower() not in lower:
            errors += fail(f"method.md missing {phrase!r}")
    for fingerprint in ("As a project manager and", "at least 15 years of experience"):
        if fingerprint in text:
            errors += fail(f"method.md contains forbidden fingerprint {fingerprint!r}")
    register = lower.split("## register columns", 1)
    if len(register) != 2:
        errors += fail("method.md missing Register columns section")
        return errors
    columns_text = register[1]
    positions = []
    for column in COLUMNS:
        idx = columns_text.find(column)
        if idx < 0:
            errors += fail(f"method.md missing column {column!r}")
        else:
            positions.append(idx)
    if positions != sorted(positions):
        errors += fail("method.md columns are not in the required order")
    return errors


def test_fixture():
    errors = 0
    if not FIXTURE.is_file():
        return fail(f"missing {FIXTURE}")
    text = FIXTURE.read_text(encoding="utf-8")
    for phrase in ("North Quay kiosk", "no tolerances are stated", "not a vault page"):
        if phrase not in text:
            errors += fail(f"fixture.md missing {phrase!r}")
    for banned in ("Acme", "client", "confidential"):
        if banned.lower() in text.lower():
            errors += fail(f"fixture.md must not contain {banned!r}")
    return errors


REQUIRED_SKILL = [
    "risk plan",
    "risk step",
    "risk row",
    "ambiguity",
    "volatility",
    "identify",
    "appetite",
    "analyse",
    "strategic",
    "unknowns",
    "respond",
    "triggers",
    "file it",
    "Looks good",
    "wiki/notes/",
    "wiki/projects/",
    "wiki/areas/",
    "Do not file into Quibble-Vault",
    "Do not read a page the user has not confirmed",
    "Do not score until tolerances exist",
    "references/method.md",
    "type: synthesis",
    "wiki-lock.sh",
    "allocate-address.sh",
    "{Project} risk plan",
    "{Project} risk register",
    "Do not create a second register",
    "Only University-Vault and Work-Vault are supported targets",
    "A filed `risk step` or `risk row` still writes both pages",
    "Do not leave the register titled as the plan",
    "Do not invent appetite, tolerance, owner, approver, or money",
    "Do not write before the phrase",
    "Do not email, post, or export the pack",
    "Never write `.raw/`",
]

REFUSALS_PHRASES = [
    "Do not invent appetite, tolerance, owner, approver, or money",
    "Do not write before the phrase",
    "Do not email, post, or export the pack",
    "Do not file into Quibble-Vault",
    "Do not create a second register",
]


def test_skill():
    errors = 0
    if not SKILL.is_file():
        return fail(f"missing {SKILL}")
    text = SKILL.read_text(encoding="utf-8")
    for phrase in REQUIRED_SKILL:
        if phrase not in text:
            errors += fail(f"SKILL.md missing {phrase!r}")
    if "## Refusals" not in text:
        errors += fail("SKILL.md missing ## Refusals section")
    else:
        refusals_text = text.split("## Refusals", 1)[1]
        for phrase in REFUSALS_PHRASES:
            if phrase not in refusals_text:
                errors += fail(f"SKILL.md Refusals section missing {phrase!r}")
    for fingerprint in ("As a project manager and", "at least 15 years of experience"):
        if fingerprint in text:
            errors += fail(f"SKILL.md contains forbidden fingerprint {fingerprint!r}")
    return errors


if __name__ == "__main__":
    sys.exit(test_method() or test_fixture() or test_skill())
