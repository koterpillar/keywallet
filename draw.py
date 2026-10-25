"""Draw rectangles (dimensions in mm) into a printable SVG."""

import os
import webbrowser
import xml.etree.ElementTree as ET
from dataclasses import dataclass
from typing import Protocol

A4 = (210, 297)  # mm
SVG_NS = "http://www.w3.org/2000/svg"


class Shape(Protocol):
    def add_to(self, svg: ET.Element) -> None: ...


@dataclass
class Rect:
    x: float  # mm
    y: float  # mm
    w: float  # mm
    h: float  # mm
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


def make_svg(sheet: tuple[float, float], shapes: list[Shape]) -> str:
    ET.register_namespace("", SVG_NS)
    svg = ET.Element(f"{{{SVG_NS}}}svg", {
        "width": f"{sheet[0]}mm",
        "height": f"{sheet[1]}mm",
        "viewBox": f"0 0 {sheet[0]} {sheet[1]}",
    })
    for s in shapes:
        s.add_to(svg)
    return ET.tostring(svg, encoding="unicode")


def main():
    # Edit these: your rectangles, all in mm.
    rects = [
        Rect(x=10, y=10, w=60, h=30, label="60 x 30"),
        Rect(x=80, y=10, w=25, h=25, label="25 x 25"),
    ]

    svg = make_svg(A4, rects)
    out = "output.svg"
    with open(out, "w") as f:
        f.write(svg)

    # @page sets the sheet size so the browser prints at 1:1 without scaling.
    html = (
        f"<!doctype html><style>@page {{ size: {A4[0]}mm {A4[1]}mm; margin: 0; }}"
        f"body {{ margin: 0; }}</style>"
        f"{svg}<script>window.print()</script>"
    )
    html_path = "print.html"
    with open(html_path, "w") as f:
        f.write(html)
    print(f"wrote {out} ({A4[0]} x {A4[1]} mm), opening print dialog...")
    here = os.path.dirname(os.path.abspath(__file__))
    webbrowser.open(f"file://{here}/{html_path}")


if __name__ == "__main__":
    main()
