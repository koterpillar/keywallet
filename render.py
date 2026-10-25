"""SVG framework: build sheets from shapes."""

import xml.etree.ElementTree as ET
from typing import Protocol

SVG_NS = "http://www.w3.org/2000/svg"


class Shape(Protocol):
    def add_to(self, svg: ET.Element) -> None: ...


def make_svg(shapes: list[Shape]) -> str:
    ET.register_namespace("", SVG_NS)
    svg = ET.Element(f"{{{SVG_NS}}}svg")
    for s in shapes:
        s.add_to(svg)
    return ET.tostring(svg, encoding="unicode")
