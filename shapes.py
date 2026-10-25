"""Shapes that can add themselves to an SVG sheet."""

import xml.etree.ElementTree as ET
from dataclasses import dataclass

from render import SVG_NS, mm


@dataclass
class Rect:
    x: float
    y: float
    w: float
    h: float
    label: str = ""

    def add_to(self, svg: ET.Element, scale: float = 1.0) -> None:
        ET.SubElement(svg, f"{{{SVG_NS}}}rect", {
            "x": mm(self.x, scale), "y": mm(self.y, scale),
            "width": mm(self.w, scale), "height": mm(self.h, scale),
            "fill": "none", "stroke": "black", "stroke-width": mm(0.2),
        })
        if self.label:
            t = ET.SubElement(svg, f"{{{SVG_NS}}}text", {
                "x": mm(self.x + self.w / 2, scale), "y": mm(self.y + self.h / 2, scale),
                "font-size": mm(3), "text-anchor": "middle",
                "dominant-baseline": "middle",
            })
            t.text = self.label


MARGIN = 10


@dataclass
class Pane:
    x: float
    y: float
    w: float
    h: float
    top: bool = False
    bottom: bool = False
    label: str = ""

    def add_to(self, svg: ET.Element, scale: float = 1.0) -> None:
        Rect(x=self.x, y=self.y, w=self.w, h=self.h, label=self.label).add_to(svg, scale)
        Rect(x=self.x - MARGIN, y=self.y, w=MARGIN, h=self.h).add_to(svg, scale)
        Rect(x=self.x + self.w, y=self.y, w=MARGIN, h=self.h).add_to(svg, scale)
        if self.top:
            Rect(x=self.x, y=self.y - MARGIN, w=self.w, h=MARGIN).add_to(svg, scale)
        if self.bottom:
            Rect(x=self.x, y=self.y + self.h, w=self.w, h=MARGIN).add_to(svg, scale)
