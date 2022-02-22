# pylint: skip-file

"""primary nox definition file."""

import nox

nox.options.sessions = ["lint"]


@nox.session
def lint(session: nox.Session) -> None:
    """
    Run the linter.
    """
    session.install("-r", "requirements.test.txt")
    session.run("pre-commit", "run", "--all-files", *session.posargs)
