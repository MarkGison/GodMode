from pathlib import Path
import sys
import unittest

sys.path.insert(0, str(Path(__file__).resolve().parents[1]))
from ci import Report, pipeline


class PipelineTests(unittest.TestCase):
    def run_case(self, suite="full", package="none", failure=None, configured=False):
        called = []

        def action(stage):
            def execute():
                called.append(stage)
                if failure == stage:
                    raise RuntimeError("secret-must-never-be-serialized")
            return execute

        actions = {stage: action(stage) for stage in ["Environment", "Compilation", "Tests", "Archive", "Signing", "IPA"]}
        report = Report(suite, package)
        code = pipeline(suite, package, actions, report, configured)
        return code, report.data, called

    def test_compile_failure_does_not_run_tests(self):
        code, report, called = self.run_case(failure="Compilation")
        self.assertEqual(code, 1)
        self.assertEqual(report["Compilation"], "FAIL")
        self.assertEqual(report["Tests"], "NOT RUN")
        self.assertNotIn("Tests", called)
        self.assertNotIn("secret-must-never-be-serialized", str(report))

    def test_test_failure_preserves_compilation_success(self):
        code, report, called = self.run_case(package="unsigned", failure="Tests")
        self.assertEqual(code, 1)
        self.assertEqual(report["Compilation"], "PASS")
        self.assertEqual(report["Tests"], "FAIL")
        self.assertNotIn("Archive", called)

    def test_missing_signing_is_not_a_source_failure(self):
        code, report, called = self.run_case(package="signed")
        self.assertEqual(code, 0)
        self.assertEqual(report["Archive"], "PASS")
        self.assertEqual(report["Signing"], "NOT CONFIGURED")
        self.assertEqual(report["IPA"], "NOT GENERATED")
        self.assertNotIn("Signing", called)

    def test_unsigned_ipa_is_not_installable(self):
        code, report, _ = self.run_case(package="unsigned")
        self.assertEqual(code, 0)
        self.assertEqual(report["IPA"], "GENERATED")
        self.assertEqual(report["ipaKind"], "unsigned")
        self.assertFalse(report["installable"])
        self.assertEqual(report["Signing"], "NOT CONFIGURED")

    def test_signing_failure_does_not_overwrite_compile_or_test_results(self):
        code, report, called = self.run_case(package="signed", failure="Signing", configured=True)
        self.assertEqual(code, 1)
        self.assertEqual(report["Compilation"], "PASS")
        self.assertEqual(report["Tests"], "PASS")
        self.assertEqual(report["Signing"], "FAIL")
        self.assertNotIn("IPA", called)

    def test_archive_failure_keeps_source_results(self):
        code, report, called = self.run_case(package="unsigned", failure="Archive")
        self.assertEqual(code, 1)
        self.assertEqual(report["Archive"], "FAIL")
        self.assertEqual(report["Tests"], "PASS")
        self.assertNotIn("IPA", called)

    def test_compile_only_does_not_claim_tests_passed(self):
        code, report, _ = self.run_case(suite="compile")
        self.assertEqual(code, 0)
        self.assertEqual(report["Tests"], "NOT RUN")

    def test_incomplete_test_scope_cannot_package(self):
        for suite in ["compile", "unit"]:
            with self.assertRaises(ValueError):
                self.run_case(suite=suite, package="unsigned")

    def test_packaging_failure_is_not_generated(self):
        code, report, _ = self.run_case(package="unsigned", failure="IPA")
        self.assertEqual(code, 1)
        self.assertEqual(report["IPA"], "NOT GENERATED")


if __name__ == "__main__":
    unittest.main()
