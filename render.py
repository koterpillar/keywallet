"""SVG framework: build sheets from shapes."""

import xml.etree.ElementTree as ET
from typing import Protocol

SVG_NS = "http://www.w3.org/2000/svg"


class Shape(Protocol):
    def add_to(self, svg: ET.Element, scale: float = 1.0) -> None: ...


def make_svg(shapes: list[Shape], scale: float = 1.0) -> bytes:
    return ET.tostring(_svg_tree(shapes, scale))


def svg_size(shapes: list[Shape]) -> tuple[float, float]:
    root = _svg_tree(shapes)
    return (
        max(_mm(e.get("x", "0")) + _mm(e.get("width", "0"))
            for e in root.iter(f"{{{SVG_NS}}}rect")),
        max(_mm(e.get("y", "0")) + _mm(e.get("height", "0"))
            for e in root.iter(f"{{{SVG_NS}}}rect")),
    )


def _svg_tree(shapes: list[Shape], scale: float = 1.0) -> ET.Element:
    ET.register_namespace("", SVG_NS)
    svg = ET.Element(f"{{{SVG_NS}}}svg")
    for s in shapes:
        s.add_to(svg, scale)
    return svg


def mm(value: float, scale: float = 1.0) -> str:
    return f"{value * scale}mm"


def _mm(v: str) -> float:
    return float(v.removesuffix("mm"))
