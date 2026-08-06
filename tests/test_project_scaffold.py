from pathlib import Path


def test_alembic_scaffold_is_present() -> None:
    root = Path(__file__).resolve().parents[1]

    assert (root / "alembic.ini").is_file()
    assert (root / "alembic" / "env.py").is_file()
    assert (root / "alembic" / "versions").is_dir()


def test_runtime_domain_packages_are_present() -> None:
    root = Path(__file__).resolve().parents[1]
    packages = [
        "agent",
        "api",
        "evidence",
        "evaluation",
        "harness",
        "ingestion",
        "retrieval",
        "skills",
        "sources",
        "workflow",
    ]

    for package in packages:
        assert (root / "app" / package / "__init__.py").is_file()
