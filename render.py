"""SVG framework: build sheets from shapes."""

import subprocess
import tempfile
import xml.etree.ElementTree as ET
from typing import Protocol

SVG_NS = "http://www.w3.org/2000/svg"


class Shape(Protocol):
    def add_to(self, svg: ET.Element) -> None: ...


def make_svg(shapes: list[Shape]) -> bytes:
    ET.register_namespace("", SVG_NS)
    svg = ET.Element(f"{{{SVG_NS}}}svg")
    for s in shapes:
        s.add_to(svg)
    return ET.tostring(svg)


def make_pdf(shapes: list[Shape]) -> bytes:
    with tempfile.NamedTemporaryFile("wb", suffix=".svg") as f:
        f.write(make_svg(shapes))
        f.flush()
        pdf = f.name + ".pdf"
        subprocess.run(["magick", f.name, pdf], check=True)
    with open(pdf, "rb") as f:
        return f.read()
