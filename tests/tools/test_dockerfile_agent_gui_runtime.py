"""Contract tests for agent-owned GUI runtime support in the Docker image.

The role-agent containers need deterministic local pixels for tools such as
Krita, Pixelorama, and the Defold editor. These tests avoid doing a Docker build;
they pin the image contract that makes those tools agent-operable after deploy.
"""

from __future__ import annotations

from pathlib import Path


REPO_ROOT = Path(__file__).resolve().parents[2]
DOCKERFILE = REPO_ROOT / "Dockerfile"
GUI_SESSION = REPO_ROOT / "docker" / "agent-gui-session.sh"
DEFOLD_WRAPPER = REPO_ROOT / "docker" / "defold-wrapper.sh"


def _dockerfile_text() -> str:
    return DOCKERFILE.read_text()


def test_dockerfile_installs_agent_gui_runtime_packages() -> None:
    text = _dockerfile_text()

    for package in (
        "xvfb",
        "openbox",
        "xdotool",
        "wmctrl",
        "imagemagick",
        "ffmpeg",
        "krita",
        "fonts-dejavu-core",
        "fonts-liberation",
        "fonts-noto-color-emoji",
        "libgtk-3-0t64",
        "libasound2t64",
        "libfuse2t64",
        "fuse3",
    ):
        assert package in text, f"Dockerfile must install {package} for GUI tool smokes"


def test_dockerfile_exposes_agent_gui_environment() -> None:
    text = _dockerfile_text()

    for env_line in (
        "ENV HERMES_AGENT_GUI_DISPLAY=:99",
        "ENV HERMES_AGENT_GUI_SCREEN=1280x720x24",
        "ENV DISPLAY=:99",
        "ENV LIBGL_ALWAYS_SOFTWARE=1",
        "ENV ALSOFT_DRIVERS=null",
        "ENV NO_AT_BRIDGE=1",
    ):
        assert env_line in text


def test_dockerfile_installs_gui_helper_wrappers() -> None:
    text = _dockerfile_text()

    assert "docker/agent-gui-session.sh /usr/local/bin/agent-gui-session" in text
    assert "docker/defold-wrapper.sh /usr/local/bin/defold" in text
    assert GUI_SESSION.exists()
    assert DEFOLD_WRAPPER.exists()


def test_agent_gui_session_starts_xvfb_and_openbox() -> None:
    text = GUI_SESSION.read_text()

    assert "Xvfb" in text
    assert "openbox" in text
    assert "wmctrl" in text
    assert "LIBGL_ALWAYS_SOFTWARE" in text
    assert "ALSOFT_DRIVERS" in text


def test_defold_wrapper_requires_mounted_defold_home() -> None:
    text = DEFOLD_WRAPPER.read_text()

    assert "DEFOLD_HOME" in text
    assert "/opt/defold" in text
    assert "Mount the host Defold install" in text
