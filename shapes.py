"""Shapes that can add themselves to an SVG sheet."""

import xml.etree.ElementTree as ET
from dataclasses import dataclass

from svgprint import SVG_NS


@dataclass
class Rect:
    x: float
    y: float
    w: float
    h: float
    label: str = ""

    def add_to(self, svg: ET.Element) -> None:
        ET.SubElement(svg, f"{{{SVG_NS}}}rect", {
            "x": str(self.x), "y": str(self.y),
            "width": str(self.w), "height": str(self.h),
            "fill": "none", "stroke": "black", "stroke-width": "0.2",
        })
        if self.label:
            t = ET.SubElement(svg, f"{{{SVG_NS}}}text", {
                "x": str(self.x + self.w / 2), "y": str(self.y + self.h / 2),
                "font-size": "3", "text-anchor": "middle",
                "dominant-baseline": "middle",
            })
            t.text = self.label
