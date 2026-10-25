"""Shapes that can add themselves to an SVG sheet."""

import xml.etree.ElementTree as ET
from dataclasses import dataclass

from render import SVG_NS


@dataclass
class Rect:
    x: float
    y: float
    w: float
    h: float
    label: str = ""

    def add_to(self, svg: ET.Element) -> None:
        ET.SubElement(svg, f"{{{SVG_NS}}}rect", {
            "x": f"{self.x}mm", "y": f"{self.y}mm",
            "width": f"{self.w}mm", "height": f"{self.h}mm",
            "fill": "none", "stroke": "black", "stroke-width": "0.2mm",
        })
        if self.label:
            t = ET.SubElement(svg, f"{{{SVG_NS}}}text", {
                "x": f"{self.x + self.w / 2}mm", "y": f"{self.y + self.h / 2}mm",
                "font-size": "3mm", "text-anchor": "middle",
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

    def add_to(self, svg: ET.Element) -> None:
        Rect(x=self.x, y=self.y, w=self.w, h=self.h, label=self.label).add_to(svg)
        Rect(x=self.x - MARGIN, y=self.y, w=MARGIN, h=self.h).add_to(svg)
        Rect(x=self.x + self.w, y=self.y, w=MARGIN, h=self.h).add_to(svg)
        if self.top:
            Rect(x=self.x, y=self.y - MARGIN, w=self.w, h=MARGIN).add_to(svg)
        if self.bottom:
            Rect(x=self.x, y=self.y + self.h, w=self.w, h=MARGIN).add_to(svg)
