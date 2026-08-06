import typer

app = typer.Typer(help="Runtime entrypoints for Vibe Trading Research Agent.")


@app.command()
def worker(once: bool = typer.Option(False, help="Run one worker iteration and exit.")) -> None:
    typer.echo("worker runtime started")
    if once:
        typer.echo("no tasks claimed")
        return
    typer.echo("worker loop placeholder")


@app.command()
def scheduler(
    once: bool = typer.Option(False, help="Run one scheduler iteration and exit."),
) -> None:
    typer.echo("scheduler runtime started")
    if once:
        typer.echo("no schedules due")
        return
    typer.echo("scheduler loop placeholder")


if __name__ == "__main__":
    app()
