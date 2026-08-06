from typer.testing import CliRunner

from app.runtime import app


def test_worker_runtime_role_starts_as_placeholder() -> None:
    runner = CliRunner()

    result = runner.invoke(app, ["worker", "--once"])

    assert result.exit_code == 0
    assert "worker runtime started" in result.output
    assert "no tasks claimed" in result.output


def test_scheduler_runtime_role_starts_as_placeholder() -> None:
    runner = CliRunner()

    result = runner.invoke(app, ["scheduler", "--once"])

    assert result.exit_code == 0
    assert "scheduler runtime started" in result.output
    assert "no schedules due" in result.output
